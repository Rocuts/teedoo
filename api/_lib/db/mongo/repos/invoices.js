/**
 * Invoices repository — MongoDB Atlas implementation.
 *
 * Collection: `invoices`.
 * Document shape: single, flat document per invoice. `lines`, `totals.vatBreakdown`,
 * `attachments` and `audit` are embedded arrays. One write = one atomic document
 * update — no multi-document transactions required.
 *
 * Cross-DB contract:
 *  - Public key is `id` (UUID v4). Mongo's `_id` is a server-generated ObjectId
 *    that never leaves the repo (projected out on every read).
 *  - // dates are ISO-8601 strings for cross-DB parity
 *  - Money fields are `Int32` cents. Validated at the repo boundary.
 */

const { randomUUID } = require('crypto');
const { getMongo } = require('../client');
const { ensureIndexes } = require('../indexes');
const {
  DbError,
  NotFoundError,
  ConflictError,
  ValidationError,
} = require('../../errors');

const COLLECTION = 'invoices';
const DEFAULT_LIMIT = 25;
const MAX_LIMIT = 100;

const VALID_STATUSES = new Set([
  'draft',
  'pendingReview',
  'readyToSend',
  'sent',
  'accepted',
  'rejected',
  'cancelled',
]);

// ── Cursor helpers (createdAt DESC, _id DESC tiebreaker) ──────────────────

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

// ── Validation helpers ────────────────────────────────────────────────────

function requireCents(v, field) {
  if (!Number.isInteger(v)) {
    throw new ValidationError(`${field} must be an integer number of cents`, { field });
  }
}

function requireString(v, field) {
  if (typeof v !== 'string' || !v) {
    throw new ValidationError(`${field} is required`, { field });
  }
}

function validateInvoice(doc) {
  if (!doc || typeof doc !== 'object') {
    throw new ValidationError('invoice is required');
  }
  requireString(doc.id, 'id');
  requireString(doc.orgId, 'orgId');
  requireString(doc.series, 'series');
  requireString(doc.number, 'number');
  requireString(doc.issueDate, 'issueDate');
  requireString(doc.issuerId, 'issuerId');
  requireString(doc.recipientId, 'recipientId');
  requireString(doc.regime, 'regime');
  requireString(doc.operationType, 'operationType');
  requireString(doc.fiscalRegion, 'fiscalRegion');
  if (!VALID_STATUSES.has(doc.status)) {
    throw new ValidationError(`status must be one of ${[...VALID_STATUSES].join(', ')}`, {
      field: 'status',
    });
  }
  if (!Array.isArray(doc.lines) || doc.lines.length === 0) {
    throw new ValidationError('lines must be a non-empty array', { field: 'lines' });
  }
  doc.lines.forEach((l, i) => {
    requireString(l.id, `lines[${i}].id`);
    requireCents(l.unitPriceCents, `lines[${i}].unitPriceCents`);
    requireCents(l.lineTotalCents, `lines[${i}].lineTotalCents`);
  });
  if (!doc.totals || typeof doc.totals !== 'object') {
    throw new ValidationError('totals is required', { field: 'totals' });
  }
  requireCents(doc.totals.subtotalCents, 'totals.subtotalCents');
  requireCents(doc.totals.irpfCents, 'totals.irpfCents');
  requireCents(doc.totals.totalCents, 'totals.totalCents');
  requireString(doc.totals.currency, 'totals.currency');
  if (!Array.isArray(doc.totals.vatBreakdown)) {
    throw new ValidationError('totals.vatBreakdown must be an array', {
      field: 'totals.vatBreakdown',
    });
  }
  doc.totals.vatBreakdown.forEach((v, i) => {
    requireCents(v.baseCents, `totals.vatBreakdown[${i}].baseCents`);
    requireCents(v.vatCents, `totals.vatBreakdown[${i}].vatCents`);
  });
  if (!doc.compliance || typeof doc.compliance !== 'object') {
    throw new ValidationError('compliance is required', { field: 'compliance' });
  }
  if (!Array.isArray(doc.attachments)) {
    throw new ValidationError('attachments must be an array', { field: 'attachments' });
  }
  if (!Array.isArray(doc.audit)) {
    throw new ValidationError('audit must be an array', { field: 'audit' });
  }
  requireString(doc.createdAt, 'createdAt');
  requireString(doc.updatedAt, 'updatedAt');
}

function validatePatch(patch) {
  if (!patch || typeof patch !== 'object') {
    throw new ValidationError('patch is required');
  }
  // Block fields that must never be patched after creation.
  for (const f of ['id', 'orgId', '_id', 'createdAt']) {
    if (f in patch) {
      throw new ValidationError(`${f} is immutable`, { field: f });
    }
  }
  if ('status' in patch && !VALID_STATUSES.has(patch.status)) {
    throw new ValidationError(`status must be one of ${[...VALID_STATUSES].join(', ')}`, {
      field: 'status',
    });
  }
  if (patch.totals) {
    if ('subtotalCents' in patch.totals) requireCents(patch.totals.subtotalCents, 'totals.subtotalCents');
    if ('irpfCents' in patch.totals) requireCents(patch.totals.irpfCents, 'totals.irpfCents');
    if ('totalCents' in patch.totals) requireCents(patch.totals.totalCents, 'totals.totalCents');
  }
}

// ── Projection ────────────────────────────────────────────────────────────

const PROJECTION = { _id: 0 };

function toDomain(doc) {
  if (!doc) return null;
  return doc;
}

// ── Party-name denormalization ────────────────────────────────────────────
//
// Denormalized shape (documented here for the handlers agent):
//
//   {
//     ...InvoiceDoc,
//     issuerName: "Acme Consulting S.L.",     // snapshot-at-issue of Party.name
//     recipientName: "Cliente Ejemplo S.A.",  // idem
//   }
//
// Both fields are filled by `create` and refreshed by `update` whenever the
// corresponding *Id changes (or on any update, to keep the code simple).
// `types.d.ts` will mark them optional; the owner extends it in Phase 2.

async function resolvePartyName(db, orgId, partyId, field) {
  if (!partyId) throw new ValidationError(`${field} is required`, { field });
  const doc = await db
    .collection('parties')
    .findOne({ orgId, id: partyId }, { projection: { _id: 0, id: 1, name: 1 } });
  if (!doc) {
    throw new ValidationError('Party not found', { field });
  }
  return doc.name;
}

// ── Repo ──────────────────────────────────────────────────────────────────

/** @returns {import('../../types').InvoicesRepository} */
function createInvoicesRepo() {
  async function handles() {
    const { db } = await getMongo();
    await ensureIndexes(db);
    return { db, col: db.collection(COLLECTION) };
  }

  async function collection() {
    const { col } = await handles();
    return col;
  }

  return {
    async get(orgId, id) {
      if (!orgId) throw new ValidationError('orgId is required', { field: 'orgId' });
      if (!id) throw new ValidationError('id is required', { field: 'id' });
      try {
        const col = await collection();
        const doc = await col.findOne({ orgId, id }, { projection: PROJECTION });
        if (!doc) throw new NotFoundError('Invoice', id);
        return toDomain(doc);
      } catch (err) {
        if (err instanceof DbError) throw err;
        throw new DbError('invoices.get failed', { cause: err });
      }
    },

    async list(orgId, q = {}) {
      if (!orgId) throw new ValidationError('orgId is required', { field: 'orgId' });
      const limit = normalizeLimit(q.limit);
      const cursor = decodeCursor(q.cursor);

      const filter = { orgId };
      if (q.status) {
        if (!VALID_STATUSES.has(q.status)) {
          throw new ValidationError(`status must be one of ${[...VALID_STATUSES].join(', ')}`, {
            field: 'status',
          });
        }
        filter.status = q.status;
      }
      if (q.issuerId) filter.issuerId = q.issuerId;
      if (q.recipientId) filter.recipientId = q.recipientId;
      if (q.fromDate || q.toDate) {
        filter.issueDate = {};
        if (q.fromDate) filter.issueDate.$gte = q.fromDate;
        if (q.toDate) filter.issueDate.$lte = q.toDate;
      }
      if (cursor) {
        filter.$or = [
          { createdAt: { $lt: cursor.createdAt } },
          { createdAt: cursor.createdAt, id: { $lt: cursor.id } },
        ];
      }

      try {
        const col = await collection();
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
        throw new DbError('invoices.list failed', { cause: err });
      }
    },

    async create(doc) {
      validateInvoice(doc);
      // Repo guarantees timestamps are server-assigned if missing.
      const now = new Date().toISOString();
      try {
        const { db, col } = await handles();

        // Staleness by design: a later parties.upsert that renames the Party
        // does NOT back-propagate. List views are the primary consumer and
        // accept snapshot-at-issue semantics.
        const [issuerName, recipientName] = await Promise.all([
          resolvePartyName(db, doc.orgId, doc.issuerId, 'issuerId'),
          resolvePartyName(db, doc.orgId, doc.recipientId, 'recipientId'),
        ]);

        const toInsert = {
          ...doc,
          id: doc.id || randomUUID(),
          issuerName,
          recipientName,
          createdAt: doc.createdAt || now,
          updatedAt: doc.updatedAt || now,
        };

        await col.insertOne(toInsert);
        // Re-read projection-pure copy (strip _id the driver added in place).
        const { _id, ...clean } = toInsert;
        return toDomain(clean);
      } catch (err) {
        if (err instanceof DbError) throw err;
        if (err && err.code === 11000) {
          throw new ConflictError(
            `Invoice (orgId, series, number) already exists: ${doc.series}/${doc.number}`,
            { cause: err, field: 'number' },
          );
        }
        throw new DbError('invoices.create failed', { cause: err });
      }
    },

    async update(orgId, id, patch) {
      if (!orgId) throw new ValidationError('orgId is required', { field: 'orgId' });
      if (!id) throw new ValidationError('id is required', { field: 'id' });
      validatePatch(patch);

      const $set = { ...patch, updatedAt: new Date().toISOString() };
      try {
        const { db, col } = await handles();

        // Staleness by design: a later parties.upsert that renames the Party
        // does NOT back-propagate. List views are the primary consumer and
        // accept snapshot-at-issue semantics. We only refresh the denormalized
        // name when the caller explicitly swaps the Party reference.
        if (patch.issuerId) {
          $set.issuerName = await resolvePartyName(db, orgId, patch.issuerId, 'issuerId');
        }
        if (patch.recipientId) {
          $set.recipientName = await resolvePartyName(
            db,
            orgId,
            patch.recipientId,
            'recipientId',
          );
        }

        const result = await col.findOneAndUpdate(
          { orgId, id },
          { $set },
          { returnDocument: 'after', projection: PROJECTION },
        );
        const updated = result && result.value !== undefined ? result.value : result;
        if (!updated) throw new NotFoundError('Invoice', id);
        return toDomain(updated);
      } catch (err) {
        if (err instanceof DbError) throw err;
        if (err && err.code === 11000) {
          throw new ConflictError('Invoice (orgId, series, number) conflict on update', {
            cause: err,
            field: 'number',
          });
        }
        throw new DbError('invoices.update failed', { cause: err });
      }
    },

    async delete(orgId, id) {
      if (!orgId) throw new ValidationError('orgId is required', { field: 'orgId' });
      if (!id) throw new ValidationError('id is required', { field: 'id' });
      try {
        const col = await collection();
        const result = await col.deleteOne({ orgId, id });
        if (result.deletedCount === 0) throw new NotFoundError('Invoice', id);
      } catch (err) {
        if (err instanceof DbError) throw err;
        throw new DbError('invoices.delete failed', { cause: err });
      }
    },

    async count(orgId) {
      if (!orgId) throw new ValidationError('orgId is required', { field: 'orgId' });
      try {
        const col = await collection();
        // countDocuments uses the { orgId: 1, ... } index prefix — cheap.
        return await col.countDocuments({ orgId });
      } catch (err) {
        throw new DbError('invoices.count failed', { cause: err });
      }
    },
  };
}

module.exports = { createInvoicesRepo };
