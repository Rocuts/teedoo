/**
 * Parties repository — MongoDB Atlas implementation.
 *
 * Collection: `parties`.
 * Public key: `id` (UUID v4 string). Mongo's `_id` is a server-generated
 * ObjectId and is never exposed — all reads project `{ _id: 0 }`.
 *
 * // dates are ISO-8601 strings for cross-DB parity
 */

const { randomUUID } = require('crypto');
const { getMongo } = require('../client');
const { ensureIndexes } = require('../indexes');
const { ensureValidators } = require('../validators');
const {
  DbError,
  NotFoundError,
  ConflictError,
  ValidationError,
} = require('../../errors');

const COLLECTION = 'parties';
const DEFAULT_LIMIT = 50;
const MAX_LIMIT = 200;

// ── Cursor helpers ────────────────────────────────────────────────────────
// Cursor is base64(JSON({ createdAt, id })). We sort by createdAt DESC,
// then id DESC as tiebreaker.

function encodeCursor(createdAt, id) {
  return Buffer.from(JSON.stringify({ createdAt, id }), 'utf8').toString('base64url');
}

function decodeCursor(cursor) {
  if (!cursor) return null;
  try {
    const raw = Buffer.from(cursor, 'base64url').toString('utf8');
    const parsed = JSON.parse(raw);
    if (typeof parsed.createdAt !== 'string' || typeof parsed.id !== 'string') {
      throw new Error('malformed cursor');
    }
    return parsed;
  } catch (err) {
    throw new ValidationError('Invalid cursor', { field: 'cursor' });
  }
}

function normalizeLimit(limit) {
  if (limit == null) return DEFAULT_LIMIT;
  if (!Number.isInteger(limit) || limit <= 0) {
    throw new ValidationError('limit must be a positive integer', { field: 'limit' });
  }
  return Math.min(limit, MAX_LIMIT);
}

// ── Validation ────────────────────────────────────────────────────────────

const VALID_TAX_ID_TYPES = new Set(['NIF', 'NIE', 'CIF', 'NIF_IVA', 'PASAPORTE', 'OTRO']);
const COUNTRY_PATTERN = /^[A-Z]{2}$/;

function validateParty(p) {
  if (!p || typeof p !== 'object') throw new ValidationError('Party is required');
  if (typeof p.id !== 'string' || !p.id) throw new ValidationError('id is required', { field: 'id' });
  if (typeof p.orgId !== 'string' || !p.orgId) {
    throw new ValidationError('orgId is required', { field: 'orgId' });
  }
  if (typeof p.taxId !== 'string' || !p.taxId) {
    throw new ValidationError('taxId is required', { field: 'taxId' });
  }
  if (!VALID_TAX_ID_TYPES.has(p.taxIdType)) {
    throw new ValidationError(`taxIdType must be one of ${[...VALID_TAX_ID_TYPES].join(', ')}`, {
      field: 'taxIdType',
    });
  }
  if (typeof p.name !== 'string' || !p.name) {
    throw new ValidationError('name is required', { field: 'name' });
  }
  if (typeof p.country !== 'string' || !COUNTRY_PATTERN.test(p.country)) {
    throw new ValidationError('country must be an ISO-3166-1 alpha-2 code (e.g. "ES")', {
      field: 'country',
    });
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
  for (const f of ['line1', 'postalCode', 'city', 'province', 'country']) {
    if (typeof p.address[f] !== 'string' || !p.address[f]) {
      throw new ValidationError(`address.${f} is required`, { field: `address.${f}` });
    }
  }
}

// ── Projection ────────────────────────────────────────────────────────────

const PROJECTION = { _id: 0 };

function toDomain(doc) {
  if (!doc) return null;
  return doc;
}

// ── Repo ──────────────────────────────────────────────────────────────────

/** @returns {import('../../types').PartiesRepository} */
function createPartiesRepo() {
  async function collection() {
    const { db } = await getMongo();
    // Cached per-instance; costs one pointer lookup on the hot path.
    await ensureIndexes(db);
    await ensureValidators(db);
    return db.collection(COLLECTION);
  }

  return {
    async get(orgId, id) {
      if (!orgId) throw new ValidationError('orgId is required', { field: 'orgId' });
      if (!id) throw new ValidationError('id is required', { field: 'id' });
      try {
        const col = await collection();
        const doc = await col.findOne({ orgId, id }, { projection: PROJECTION });
        if (!doc) throw new NotFoundError('Party', id);
        return toDomain(doc);
      } catch (err) {
        if (err instanceof DbError) throw err;
        throw new DbError('parties.get failed', { cause: err });
      }
    },

    async findByTaxId(orgId, taxId) {
      if (!orgId) throw new ValidationError('orgId is required', { field: 'orgId' });
      if (!taxId) throw new ValidationError('taxId is required', { field: 'taxId' });
      try {
        const col = await collection();
        const doc = await col.findOne({ orgId, taxId }, { projection: PROJECTION });
        return toDomain(doc);
      } catch (err) {
        if (err instanceof DbError) throw err;
        throw new DbError('parties.findByTaxId failed', { cause: err });
      }
    },

    async list(orgId, q = {}) {
      if (!orgId) throw new ValidationError('orgId is required', { field: 'orgId' });
      const limit = normalizeLimit(q.limit);
      const cursor = decodeCursor(q.cursor);
      try {
        const col = await collection();
        const filter = { orgId };
        if (cursor) {
          filter.$or = [
            { createdAt: { $lt: cursor.createdAt } },
            { createdAt: cursor.createdAt, id: { $lt: cursor.id } },
          ];
        }
        const items = await col
          .find(filter, { projection: PROJECTION })
          .sort({ createdAt: -1, id: -1 })
          .limit(limit + 1)
          .toArray();

        let nextCursor = null;
        if (items.length > limit) {
          const last = items[limit - 1];
          items.length = limit;
          nextCursor = encodeCursor(last.createdAt, last.id);
        }
        return { items, nextCursor };
      } catch (err) {
        if (err instanceof DbError) throw err;
        throw new DbError('parties.list failed', { cause: err });
      }
    },

    async upsert(p) {
      validateParty(p);
      const now = new Date().toISOString();
      const { id, orgId, taxId, taxIdType, name, country, email, phone, address } = p;
      const $set = {
        orgId,
        taxId,
        taxIdType,
        name,
        country,
        email: email ?? null,
        phone: phone ?? null,
        address,
        updatedAt: now,
      };
      const $setOnInsert = {
        id: id || randomUUID(),
        createdAt: now,
      };
      try {
        const col = await collection();
        const result = await col.findOneAndUpdate(
          { orgId, taxId },
          { $set, $setOnInsert },
          { upsert: true, returnDocument: 'after', projection: PROJECTION },
        );
        // driver v6: findOneAndUpdate returns the doc directly; v5 returns { value }.
        const doc = result && result.value !== undefined ? result.value : result;
        if (!doc) throw new DbError('parties.upsert returned no document');
        return toDomain(doc);
      } catch (err) {
        if (err instanceof DbError) throw err;
        if (err && err.code === 11000) {
          throw new ConflictError('Party with this (orgId, taxId) already exists', {
            cause: err,
            field: 'taxId',
          });
        }
        throw new DbError('parties.upsert failed', { cause: err });
      }
    },

    async delete(orgId, id) {
      if (!orgId) throw new ValidationError('orgId is required', { field: 'orgId' });
      if (!id) throw new ValidationError('id is required', { field: 'id' });
      try {
        const col = await collection();
        const result = await col.deleteOne({ orgId, id });
        if (result.deletedCount === 0) throw new NotFoundError('Party', id);
      } catch (err) {
        if (err instanceof DbError) throw err;
        throw new DbError('parties.delete failed', { cause: err });
      }
    },
  };
}

module.exports = { createPartiesRepo };
