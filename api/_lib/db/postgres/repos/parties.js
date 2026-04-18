/**
 * Parties repository — Supabase Postgres.
 *
 * Implements `PartiesRepository` from `api/_lib/db/types.d.ts`:
 *   get, findByTaxId, list, upsert, delete
 *
 * Multi-tenancy: every query opens a transaction and runs
 *   `SET LOCAL app.org_id = '<uuid>'`
 * so RLS policies in `migrations/rls_policies.sql` apply uniformly.
 * SET LOCAL is mandatory — pgbouncer transaction pooling resets it on
 * COMMIT automatically; a bare SET would leak across tenants.
 */

const { eq, and, sql } = require('drizzle-orm');
const { getPostgres } = require('../client');
const { parties } = require('../schema/parties');
const {
  NotFoundError,
  ConflictError,
  ValidationError,
  DbError,
} = require('../../errors');

// ─── helpers ──────────────────────────────────────────────────────────

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function assertUuid(value, field) {
  if (typeof value !== 'string' || !UUID_RE.test(value)) {
    throw new ValidationError(`${field} must be a UUID`, { field });
  }
}

function normalizeTaxId(raw) {
  if (typeof raw !== 'string') {
    throw new ValidationError('taxId must be a string', { field: 'taxId' });
  }
  const trimmed = raw.trim().toUpperCase();
  if (!trimmed) throw new ValidationError('taxId cannot be empty', { field: 'taxId' });
  if (trimmed.length > 32) {
    throw new ValidationError('taxId exceeds 32 chars', { field: 'taxId' });
  }
  return trimmed;
}

const ALLOWED_TAX_ID_TYPES = new Set(['NIF', 'NIE', 'CIF', 'NIF_IVA', 'PASAPORTE', 'OTRO']);

function assertTaxIdType(type) {
  if (!ALLOWED_TAX_ID_TYPES.has(type)) {
    throw new ValidationError(
      `taxIdType must be one of ${[...ALLOWED_TAX_ID_TYPES].join(', ')}`,
      { field: 'taxIdType' },
    );
  }
}

function toDomain(row) {
  if (!row) return null;
  return {
    id: row.id,
    orgId: row.orgId,
    taxId: row.taxId,
    taxIdType: row.taxIdType,
    name: row.name,
    country: row.country || 'ES',
    email: row.email || null,
    phone: row.phone || null,
    address: {
      line1: row.addressLine1 || '',
      line2: row.addressLine2 || undefined,
      postalCode: row.postalCode || '',
      city: row.city || '',
      province: row.province || '',
      country: row.country || 'ES',
    },
    createdAt: row.createdAt instanceof Date ? row.createdAt.toISOString() : row.createdAt,
    updatedAt: row.updatedAt instanceof Date ? row.updatedAt.toISOString() : row.updatedAt,
  };
}

function validatePartyInput(p) {
  if (!p || typeof p !== 'object') {
    throw new ValidationError('party must be an object');
  }
  assertUuid(p.orgId, 'orgId');
  if (p.id !== undefined) assertUuid(p.id, 'id');
  assertTaxIdType(p.taxIdType);
  if (typeof p.name !== 'string' || !p.name.trim()) {
    throw new ValidationError('name is required', { field: 'name' });
  }
  if (p.country !== undefined && p.country !== null) {
    if (typeof p.country !== 'string' || !/^[A-Z]{2}$/.test(p.country)) {
      throw new ValidationError('country must be ISO-3166-1 alpha-2', { field: 'country' });
    }
  }
  if (p.email != null && typeof p.email !== 'string') {
    throw new ValidationError('email must be a string when present', { field: 'email' });
  }
  if (p.phone != null && typeof p.phone !== 'string') {
    throw new ValidationError('phone must be a string when present', { field: 'phone' });
  }
  if (!p.address || typeof p.address !== 'object') {
    throw new ValidationError('address is required', { field: 'address' });
  }
  const country = p.address.country;
  if (typeof country !== 'string' || !/^[A-Z]{2}$/.test(country)) {
    throw new ValidationError('address.country must be ISO-3166 alpha-2', {
      field: 'address.country',
    });
  }
}

/**
 * Run `fn` inside a transaction with `SET LOCAL app.org_id` applied,
 * so RLS predicates match. Returns whatever `fn` returns.
 *
 * Uses Drizzle's native `db.transaction(...)` rather than wrapping a
 * `postgres-js` transaction sql tag: the latter lacks the `.options`
 * surface that `drizzle(...)` reads (`client.options.parsers`), and
 * Drizzle 0.37 throws `Cannot read properties of undefined (reading
 * 'parsers')` if you try. `db.transaction` opens the tx on the same
 * underlying pooled connection, and the `SET LOCAL` we issue is reset
 * automatically by pgbouncer on COMMIT — identical semantics to the
 * previous implementation, minus the driver mismatch.
 */
async function withOrg(orgId, fn) {
  assertUuid(orgId, 'orgId');
  const { db } = getPostgres();
  return db.transaction(async (tx) => {
    await tx.execute(sql`SELECT set_config('app.org_id', ${orgId}, true)`);
    return fn({ db: tx, sql });
  });
}

// ─── repo ─────────────────────────────────────────────────────────────

/** @returns {import('../../types').PartiesRepository} */
function createPartiesRepo() {
  return {
    async get(orgId, id) {
      assertUuid(orgId, 'orgId');
      assertUuid(id, 'id');
      try {
        return await withOrg(orgId, async ({ db }) => {
          const rows = await db
            .select()
            .from(parties)
            .where(and(eq(parties.orgId, orgId), eq(parties.id, id)))
            .limit(1);
          if (!rows[0]) throw new NotFoundError('Party', id);
          return toDomain(rows[0]);
        });
      } catch (err) {
        if (err instanceof DbError) throw err;
        throw new DbError('parties.get failed', { cause: err });
      }
    },

    async findByTaxId(orgId, taxId) {
      assertUuid(orgId, 'orgId');
      const normalized = normalizeTaxId(taxId);
      try {
        return await withOrg(orgId, async ({ db }) => {
          const rows = await db
            .select()
            .from(parties)
            .where(and(eq(parties.orgId, orgId), eq(parties.taxId, normalized)))
            .limit(1);
          return rows[0] ? toDomain(rows[0]) : null;
        });
      } catch (err) {
        if (err instanceof DbError) throw err;
        throw new DbError('parties.findByTaxId failed', { cause: err });
      }
    },

    async list(orgId, q = {}) {
      assertUuid(orgId, 'orgId');
      const limit = Math.min(Math.max(Number(q.limit) || 50, 1), 200);
      const cursor = q.cursor || null;
      try {
        return await withOrg(orgId, async ({ db }) => {
          // Cursor = `${createdAt ISO}|${id}` (stable tuple sort).
          const conds = [eq(parties.orgId, orgId)];
          if (cursor) {
            const sep = cursor.lastIndexOf('|');
            if (sep <= 0) {
              throw new ValidationError('Invalid cursor', { field: 'cursor' });
            }
            const createdAt = cursor.slice(0, sep);
            const lastId = cursor.slice(sep + 1);
            // Strictly after (createdAt, id).
            conds.push(
              sql`(${parties.createdAt}, ${parties.id}) > (${new Date(createdAt)}, ${lastId}::uuid)`,
            );
          }
          const rows = await db
            .select()
            .from(parties)
            .where(and(...conds))
            .orderBy(parties.createdAt, parties.id)
            .limit(limit + 1);

          let nextCursor = null;
          if (rows.length > limit) {
            const last = rows[limit - 1];
            const iso =
              last.createdAt instanceof Date
                ? last.createdAt.toISOString()
                : last.createdAt;
            nextCursor = `${iso}|${last.id}`;
            rows.length = limit;
          }
          return { items: rows.map(toDomain), nextCursor };
        });
      } catch (err) {
        if (err instanceof DbError) throw err;
        throw new DbError('parties.list failed', { cause: err });
      }
    },

    async upsert(p) {
      validatePartyInput(p);
      const now = new Date();
      const topCountry = (p.country || p.address.country || 'ES').toUpperCase();
      const row = {
        id: p.id || undefined,
        orgId: p.orgId,
        taxId: normalizeTaxId(p.taxId),
        taxIdType: p.taxIdType,
        name: p.name.trim(),
        addressLine1: p.address.line1 || null,
        addressLine2: p.address.line2 || null,
        postalCode: p.address.postalCode || null,
        city: p.address.city || null,
        province: p.address.province || null,
        country: topCountry,
        email: p.email || null,
        phone: p.phone || null,
        updatedAt: now,
      };
      try {
        return await withOrg(p.orgId, async ({ db }) => {
          const inserted = await db
            .insert(parties)
            .values(row)
            .onConflictDoUpdate({
              target: [parties.orgId, parties.taxId],
              set: {
                taxIdType: row.taxIdType,
                name: row.name,
                addressLine1: row.addressLine1,
                addressLine2: row.addressLine2,
                postalCode: row.postalCode,
                city: row.city,
                province: row.province,
                country: row.country,
                email: row.email,
                phone: row.phone,
                updatedAt: now,
              },
            })
            .returning();
          return toDomain(inserted[0]);
        });
      } catch (err) {
        if (err instanceof DbError) throw err;
        // 23505 unique_violation on a DIFFERENT unique index (e.g. a
        // future one) — the ON CONFLICT target handles (orgId, taxId).
        if (err && err.code === '23505') {
          throw new ConflictError('Party conflict', { cause: err });
        }
        throw new DbError('parties.upsert failed', { cause: err });
      }
    },

    async delete(orgId, id) {
      assertUuid(orgId, 'orgId');
      assertUuid(id, 'id');
      try {
        await withOrg(orgId, async ({ db }) => {
          const deleted = await db
            .delete(parties)
            .where(and(eq(parties.orgId, orgId), eq(parties.id, id)))
            .returning({ id: parties.id });
          if (!deleted[0]) throw new NotFoundError('Party', id);
        });
      } catch (err) {
        if (err instanceof DbError) throw err;
        // FK from invoices.issuer_id / recipient_id uses ON DELETE RESTRICT.
        if (err && err.code === '23503') {
          throw new ConflictError('Party is referenced by invoices', {
            cause: err,
            field: 'id',
          });
        }
        throw new DbError('parties.delete failed', { cause: err });
      }
    },
  };
}

module.exports = { createPartiesRepo };
