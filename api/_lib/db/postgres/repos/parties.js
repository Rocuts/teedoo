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

const ALLOWED_TAX_ID_TYPES = new Set(['NIF', 'NIE', 'NIF_IVA', 'PASAPORTE', 'OTRO']);

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
 */
async function withOrg(orgId, fn) {
  assertUuid(orgId, 'orgId');
  const { sql: pg, db } = getPostgres();
  // postgres-js `sql.begin` yields a transaction-scoped sql tag. We pass
  // it to `drizzle(...)` so Drizzle runs all statements on the same tx.
  return pg.begin(async (txSql) => {
    await txSql`SELECT set_config('app.org_id', ${orgId}, true)`;
    // Reuse the outer Drizzle wrapper — postgres-js tx handle shares the
    // same connection, and Drizzle statements internally delegate to
    // whichever `sql` tag is in scope. However, to guarantee the tx
    // connection is used, we build a transaction-local Drizzle:
    const { drizzle } = require('drizzle-orm/postgres-js');
    const txDb = drizzle(txSql);
    return fn({ db: txDb, sql: txSql });
  });
  // Suppress unused `db` warning — intentional: we build a tx-scoped db.
  // eslint-disable-next-line no-unused-vars
  void db;
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
        country: (p.address.country || 'ES').toUpperCase(),
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
