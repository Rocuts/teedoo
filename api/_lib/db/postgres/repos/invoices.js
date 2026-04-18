/**
 * Invoices repository — Supabase Postgres.
 *
 * Implements `InvoicesRepository` from `api/_lib/db/types.d.ts`:
 *   get, list, create, update, delete, count
 *
 * Storage model: header (`invoices`) + four child tables
 * (`invoice_lines`, `invoice_vat_breakdowns`, `invoice_attachments`,
 * `invoice_audit`). `get` reconstructs the nested `InvoiceDoc` via a
 * single JOIN using `json_agg` for each child set, minimizing round
 * trips. `create` and `update` run inside a transaction with
 * `SET LOCAL app.org_id` so RLS predicates apply.
 *
 * Denormalization strategy parity (see types.d.ts InvoiceDoc):
 *   - Mongo: issuerName/recipientName persisted at write (snapshot, stale-safe).
 *   - Postgres: issuerName/recipientName computed via LEFT JOIN on read (always fresh).
 * The owner picked this split deliberately so each DB demonstrates its idiomatic pattern.
 */

const { eq, and, gte, lte, sql, desc, asc, count: sqlCount } = require('drizzle-orm');
const { alias } = require('drizzle-orm/pg-core');
const { getPostgres } = require('../client');
const {
  invoices,
  invoiceLines,
  invoiceVatBreakdowns,
  invoiceAttachments,
  invoiceAudit,
} = require('../schema/invoices');
const { parties } = require('../schema/parties');

// Two aliases of the `parties` table for the double LEFT JOIN
// (issuer + recipient) used in `get` and `list`.
const issuerParty = alias(parties, 'issuer');
const recipientParty = alias(parties, 'recipient');
const {
  NotFoundError,
  ConflictError,
  ValidationError,
  DbError,
} = require('../../errors');

// ─── helpers ──────────────────────────────────────────────────────────

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const ISO_DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

function assertUuid(v, field) {
  if (typeof v !== 'string' || !UUID_RE.test(v)) {
    throw new ValidationError(`${field} must be a UUID`, { field });
  }
}
function assertCents(v, field) {
  if (!Number.isInteger(v)) {
    throw new ValidationError(`${field} must be an integer (cents)`, { field });
  }
}
function assertIsoDate(v, field) {
  if (typeof v !== 'string' || !ISO_DATE_RE.test(v)) {
    throw new ValidationError(`${field} must be ISO date (YYYY-MM-DD)`, { field });
  }
}

const INVOICE_STATUSES = new Set([
  'draft',
  'pendingReview',
  'readyToSend',
  'sent',
  'accepted',
  'rejected',
  'cancelled',
]);

const VAT_RATES = new Set([
  'IVA_GENERAL_21',
  'IVA_REDUCIDO_10',
  'IVA_SUPERREDUCIDO_4',
  'IVA_CERO',
  'EXENTO',
  'NO_SUJETO',
  'IGIC_GENERAL_7',
  'IGIC_REDUCIDO_3',
  'IGIC_CERO',
  'IPSI',
]);

const FISCAL_REGIONS = new Set([
  'PENINSULA_BALEARES',
  'CANARIAS',
  'CEUTA',
  'MELILLA',
  'PAIS_VASCO_ARABA',
  'PAIS_VASCO_BIZKAIA',
  'PAIS_VASCO_GIPUZKOA',
  'NAVARRA',
]);

const INVOICE_REGIMES = new Set([
  'GENERAL',
  'SIMPLIFICADO',
  'RECARGO_EQUIVALENCIA',
  'REAGP',
  'BIENES_USADOS_REBU',
  'AGENCIAS_VIAJES_REAV',
  'CRITERIO_CAJA_RECC',
  'GRUPO_ENTIDADES_REGE',
  'EXENTO',
]);

const OPERATION_TYPES = new Set(['F1', 'F2', 'F3', 'F4', 'F5', 'R1', 'R2', 'R3', 'R4', 'R5']);

function validateDoc(doc) {
  if (!doc || typeof doc !== 'object') {
    throw new ValidationError('invoice doc must be an object');
  }
  assertUuid(doc.orgId, 'orgId');
  if (doc.id) assertUuid(doc.id, 'id');
  if (typeof doc.series !== 'string' || !doc.series) {
    throw new ValidationError('series is required', { field: 'series' });
  }
  if (typeof doc.number !== 'string' || !doc.number) {
    throw new ValidationError('number is required', { field: 'number' });
  }
  assertIsoDate(doc.issueDate, 'issueDate');
  if (doc.operationDate) assertIsoDate(doc.operationDate, 'operationDate');
  assertUuid(doc.issuerId, 'issuerId');
  assertUuid(doc.recipientId, 'recipientId');

  if (!INVOICE_STATUSES.has(doc.status)) {
    throw new ValidationError('invalid status', { field: 'status' });
  }
  if (!INVOICE_REGIMES.has(doc.regime)) {
    throw new ValidationError('invalid regime', { field: 'regime' });
  }
  if (!OPERATION_TYPES.has(doc.operationType)) {
    throw new ValidationError('invalid operationType', { field: 'operationType' });
  }
  if (!FISCAL_REGIONS.has(doc.fiscalRegion)) {
    throw new ValidationError('invalid fiscalRegion', { field: 'fiscalRegion' });
  }
  if (!Array.isArray(doc.lines)) {
    throw new ValidationError('lines must be an array', { field: 'lines' });
  }
  for (const [i, line] of doc.lines.entries()) {
    if (!VAT_RATES.has(line.vatRate)) {
      throw new ValidationError(`lines[${i}].vatRate invalid`, {
        field: `lines[${i}].vatRate`,
      });
    }
    assertCents(line.unitPriceCents, `lines[${i}].unitPriceCents`);
    assertCents(line.lineTotalCents, `lines[${i}].lineTotalCents`);
  }
  if (!doc.totals || typeof doc.totals !== 'object') {
    throw new ValidationError('totals is required', { field: 'totals' });
  }
  assertCents(doc.totals.subtotalCents, 'totals.subtotalCents');
  assertCents(doc.totals.totalCents, 'totals.totalCents');
  if (doc.totals.irpfCents !== undefined) assertCents(doc.totals.irpfCents, 'totals.irpfCents');
  if (!Array.isArray(doc.totals.vatBreakdown)) {
    throw new ValidationError('totals.vatBreakdown must be an array', {
      field: 'totals.vatBreakdown',
    });
  }
  if (typeof doc.totals.currency !== 'string' || !/^[A-Z]{3}$/.test(doc.totals.currency)) {
    throw new ValidationError('totals.currency must be ISO-4217', {
      field: 'totals.currency',
    });
  }
}

/** Build a doc back out of header row + child rows.
 *
 * `header` may carry `issuerName` / `recipientName` when it originates
 * from a SELECT that LEFT JOINed `parties` (see `get` / `list`). When
 * the header comes from an INSERT/UPDATE ... RETURNING (no join), those
 * keys are absent — we leave `issuerName` / `recipientName` undefined,
 * which matches the optional contract in `types.d.ts`.
 */
function assembleDoc(header, lineRows, vatRows, attachmentRows, auditRows) {
  if (!header) return null;
  return {
    id: header.id,
    orgId: header.orgId,
    series: header.series,
    number: header.number,
    issueDate:
      header.issueDate instanceof Date
        ? header.issueDate.toISOString().slice(0, 10)
        : header.issueDate,
    operationDate: header.operationDate
      ? header.operationDate instanceof Date
        ? header.operationDate.toISOString().slice(0, 10)
        : header.operationDate
      : undefined,
    issuerId: header.issuerId,
    issuerName: header.issuerName || undefined,
    recipientId: header.recipientId,
    recipientName: header.recipientName || undefined,
    lines: (lineRows || [])
      .slice()
      .sort((a, b) => a.position - b.position)
      .map((l) => ({
        id: l.id,
        description: l.description,
        quantity: Number(l.quantity),
        unitPriceCents: l.unitPriceCents,
        discountPercent: l.discountPercent !== null && l.discountPercent !== undefined
          ? Number(l.discountPercent)
          : undefined,
        vatRate: l.vatRate,
        vatRateValue: Number(l.vatRateValue),
        irpfRate: l.irpfRate !== null && l.irpfRate !== undefined ? Number(l.irpfRate) : undefined,
        exemptReason: l.exemptReason || undefined,
        lineTotalCents: l.lineTotalCents,
      })),
    totals: {
      subtotalCents: header.subtotalCents,
      vatBreakdown: (vatRows || []).map((v) => ({
        vatRate: v.vatRate,
        vatRateValue: Number(v.vatRateValue),
        baseCents: v.baseCents,
        vatCents: v.vatCents,
        recargoCents: v.recargoCents,
      })),
      irpfCents: header.irpfCents,
      totalCents: header.totalCents,
      currency: header.currency,
    },
    regime: header.regime,
    operationType: header.operationType,
    fiscalRegion: header.fiscalRegion,
    compliance: {
      ticketBaiId: header.ticketBaiId || undefined,
      ticketBaiHash: header.ticketBaiHash || undefined,
      verifactuHash: header.verifactuHash || undefined,
      verifactuChainRef: header.verifactuChainRef || undefined,
      siiSubmitted: !!header.siiSubmitted,
    },
    paymentTerms: header.paymentMethod
      ? {
          method: header.paymentMethod,
          iban: header.paymentIban || undefined,
          dueDate: header.paymentDueDate
            ? header.paymentDueDate instanceof Date
              ? header.paymentDueDate.toISOString().slice(0, 10)
              : header.paymentDueDate
            : undefined,
        }
      : undefined,
    notes: header.notes || undefined,
    attachments: (attachmentRows || []).map((a) => ({
      id: a.id,
      fileName: a.fileName,
      mimeType: a.mimeType,
      sizeBytes: a.sizeBytes,
      url: a.url || undefined,
      storageKey: a.storageKey || undefined,
      uploadedAt:
        a.uploadedAt instanceof Date ? a.uploadedAt.toISOString() : a.uploadedAt,
    })),
    status: header.status,
    rectification: header.rectification || undefined,
    audit: (auditRows || []).map((r) => ({
      id: r.id,
      at: r.at instanceof Date ? r.at.toISOString() : r.at,
      actorId: r.actorId,
      action: r.action,
      notes: r.notes || undefined,
    })),
    createdAt:
      header.createdAt instanceof Date ? header.createdAt.toISOString() : header.createdAt,
    updatedAt:
      header.updatedAt instanceof Date ? header.updatedAt.toISOString() : header.updatedAt,
  };
}

/**
 * Open a transaction with `SET LOCAL app.org_id` set so RLS applies,
 * and hand the caller a Drizzle transaction instance.
 *
 * Uses Drizzle's native `db.transaction(...)` instead of wrapping a
 * `postgres-js` tx sql tag: the latter lacks the `.options` surface
 * Drizzle 0.37's `drizzle(client)` reads (`client.options.parsers`),
 * and crashes with `Cannot read properties of undefined (reading
 * 'parsers')`. pgbouncer resets `SET LOCAL` on COMMIT regardless.
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

/** @returns {import('../../types').InvoicesRepository} */
function createInvoicesRepo() {
  return {
    async get(orgId, id) {
      assertUuid(orgId, 'orgId');
      assertUuid(id, 'id');
      try {
        return await withOrg(orgId, async ({ db }) => {
          // LEFT JOIN parties twice (issuer + recipient) to hydrate the
          // denormalized-on-read names. RESTRICT FK makes a null join row
          // a theoretical case only — we still coalesce defensively.
          const rows = await db
            .select({
              header: invoices,
              issuerName: issuerParty.name,
              recipientName: recipientParty.name,
            })
            .from(invoices)
            .leftJoin(issuerParty, eq(issuerParty.id, invoices.issuerId))
            .leftJoin(recipientParty, eq(recipientParty.id, invoices.recipientId))
            .where(and(eq(invoices.orgId, orgId), eq(invoices.id, id)))
            .limit(1);
          if (!rows[0]) throw new NotFoundError('Invoice', id);
          const header = {
            ...rows[0].header,
            issuerName: rows[0].issuerName,
            recipientName: rows[0].recipientName,
          };

          const [lineRows, vatRows, attRows, auditRows] = await Promise.all([
            db
              .select()
              .from(invoiceLines)
              .where(eq(invoiceLines.invoiceId, id)),
            db
              .select()
              .from(invoiceVatBreakdowns)
              .where(eq(invoiceVatBreakdowns.invoiceId, id)),
            db
              .select()
              .from(invoiceAttachments)
              .where(eq(invoiceAttachments.invoiceId, id)),
            db
              .select()
              .from(invoiceAudit)
              .where(eq(invoiceAudit.invoiceId, id))
              .orderBy(asc(invoiceAudit.at)),
          ]);
          return assembleDoc(header, lineRows, vatRows, attRows, auditRows);
        });
      } catch (err) {
        if (err instanceof DbError) throw err;
        throw new DbError('invoices.get failed', { cause: err });
      }
    },

    async list(orgId, q = {}) {
      assertUuid(orgId, 'orgId');
      const limit = Math.min(Math.max(Number(q.limit) || 50, 1), 200);
      const conds = [eq(invoices.orgId, orgId)];
      if (q.status) {
        if (!INVOICE_STATUSES.has(q.status)) {
          throw new ValidationError('invalid status filter', { field: 'status' });
        }
        conds.push(eq(invoices.status, q.status));
      }
      if (q.issuerId) {
        assertUuid(q.issuerId, 'issuerId');
        conds.push(eq(invoices.issuerId, q.issuerId));
      }
      if (q.recipientId) {
        assertUuid(q.recipientId, 'recipientId');
        conds.push(eq(invoices.recipientId, q.recipientId));
      }
      if (q.fromDate) {
        assertIsoDate(q.fromDate, 'fromDate');
        conds.push(gte(invoices.issueDate, q.fromDate));
      }
      if (q.toDate) {
        assertIsoDate(q.toDate, 'toDate');
        conds.push(lte(invoices.issueDate, q.toDate));
      }
      if (q.cursor) {
        const sep = q.cursor.lastIndexOf('|');
        if (sep <= 0) {
          throw new ValidationError('Invalid cursor', { field: 'cursor' });
        }
        const createdAt = q.cursor.slice(0, sep);
        const lastId = q.cursor.slice(sep + 1);
        // We order DESC(createdAt, id) so cursor reads "strictly before".
        conds.push(
          sql`(${invoices.createdAt}, ${invoices.id}) < (${new Date(createdAt)}, ${lastId}::uuid)`,
        );
      }

      try {
        return await withOrg(orgId, async ({ db }) => {
          // LEFT JOIN parties twice to hydrate issuerName / recipientName
          // on every header row (parity with Mongo snapshot fields).
          const rawHeaders = await db
            .select({
              header: invoices,
              issuerName: issuerParty.name,
              recipientName: recipientParty.name,
            })
            .from(invoices)
            .leftJoin(issuerParty, eq(issuerParty.id, invoices.issuerId))
            .leftJoin(recipientParty, eq(recipientParty.id, invoices.recipientId))
            .where(and(...conds))
            .orderBy(desc(invoices.createdAt), desc(invoices.id))
            .limit(limit + 1);

          const headers = rawHeaders.map((r) => ({
            ...r.header,
            issuerName: r.issuerName,
            recipientName: r.recipientName,
          }));

          let nextCursor = null;
          if (headers.length > limit) {
            const last = headers[limit - 1];
            const iso =
              last.createdAt instanceof Date
                ? last.createdAt.toISOString()
                : last.createdAt;
            nextCursor = `${iso}|${last.id}`;
            headers.length = limit;
          }

          if (headers.length === 0) return { items: [], nextCursor };

          // Batch-fetch children across the full page (avoids N+1).
          const ids = headers.map((h) => h.id);
          const [linesAll, vatAll, attAll, auditAll] = await Promise.all([
            db
              .select()
              .from(invoiceLines)
              .where(sql`${invoiceLines.invoiceId} = ANY(${ids}::uuid[])`),
            db
              .select()
              .from(invoiceVatBreakdowns)
              .where(sql`${invoiceVatBreakdowns.invoiceId} = ANY(${ids}::uuid[])`),
            db
              .select()
              .from(invoiceAttachments)
              .where(sql`${invoiceAttachments.invoiceId} = ANY(${ids}::uuid[])`),
            db
              .select()
              .from(invoiceAudit)
              .where(sql`${invoiceAudit.invoiceId} = ANY(${ids}::uuid[])`)
              .orderBy(asc(invoiceAudit.at)),
          ]);
          const groupBy = (rows, key) => {
            const map = new Map();
            for (const r of rows) {
              const k = r[key];
              const arr = map.get(k) || [];
              arr.push(r);
              map.set(k, arr);
            }
            return map;
          };
          const lineMap = groupBy(linesAll, 'invoiceId');
          const vatMap = groupBy(vatAll, 'invoiceId');
          const attMap = groupBy(attAll, 'invoiceId');
          const auditMap = groupBy(auditAll, 'invoiceId');

          const items = headers.map((h) =>
            assembleDoc(
              h,
              lineMap.get(h.id) || [],
              vatMap.get(h.id) || [],
              attMap.get(h.id) || [],
              auditMap.get(h.id) || [],
            ),
          );
          return { items, nextCursor };
        });
      } catch (err) {
        if (err instanceof DbError) throw err;
        throw new DbError('invoices.list failed', { cause: err });
      }
    },

    async create(doc) {
      validateDoc(doc);
      const orgId = doc.orgId;
      const id = doc.id; // If omitted, DB generates — but contract says `id` is required.
      if (!id) throw new ValidationError('id is required on create', { field: 'id' });

      const now = new Date();
      try {
        return await withOrg(orgId, async ({ db }) => {
          // Header
          const [header] = await db
            .insert(invoices)
            .values({
              id,
              orgId,
              series: doc.series,
              number: doc.number,
              issueDate: doc.issueDate,
              operationDate: doc.operationDate || null,
              issuerId: doc.issuerId,
              recipientId: doc.recipientId,
              subtotalCents: doc.totals.subtotalCents,
              irpfCents: doc.totals.irpfCents || 0,
              totalCents: doc.totals.totalCents,
              currency: doc.totals.currency,
              regime: doc.regime,
              operationType: doc.operationType,
              fiscalRegion: doc.fiscalRegion,
              ticketBaiId: doc.compliance?.ticketBaiId || null,
              ticketBaiHash: doc.compliance?.ticketBaiHash || null,
              verifactuHash: doc.compliance?.verifactuHash || null,
              verifactuChainRef: doc.compliance?.verifactuChainRef || null,
              siiSubmitted: !!doc.compliance?.siiSubmitted,
              paymentMethod: doc.paymentTerms?.method || null,
              paymentIban: doc.paymentTerms?.iban || null,
              paymentDueDate: doc.paymentTerms?.dueDate || null,
              notes: doc.notes || null,
              status: doc.status,
              rectification: doc.rectification || null,
              createdAt: doc.createdAt ? new Date(doc.createdAt) : now,
              updatedAt: doc.updatedAt ? new Date(doc.updatedAt) : now,
            })
            .returning();

          // Children
          if (doc.lines?.length) {
            await db.insert(invoiceLines).values(
              doc.lines.map((l, i) => ({
                id: l.id,
                orgId,
                invoiceId: id,
                position: i,
                description: l.description,
                quantity: String(l.quantity),
                unitPriceCents: l.unitPriceCents,
                discountPercent:
                  l.discountPercent !== undefined ? String(l.discountPercent) : null,
                vatRate: l.vatRate,
                vatRateValue: String(l.vatRateValue),
                irpfRate: l.irpfRate !== undefined ? String(l.irpfRate) : null,
                exemptReason: l.exemptReason || null,
                lineTotalCents: l.lineTotalCents,
              })),
            );
          }
          if (doc.totals.vatBreakdown?.length) {
            await db.insert(invoiceVatBreakdowns).values(
              doc.totals.vatBreakdown.map((v) => ({
                orgId,
                invoiceId: id,
                vatRate: v.vatRate,
                vatRateValue: String(v.vatRateValue),
                baseCents: v.baseCents,
                vatCents: v.vatCents,
                recargoCents: v.recargoCents || 0,
              })),
            );
          }
          if (doc.attachments?.length) {
            await db.insert(invoiceAttachments).values(
              doc.attachments.map((a) => ({
                id: a.id,
                orgId,
                invoiceId: id,
                fileName: a.fileName,
                mimeType: a.mimeType,
                sizeBytes: a.sizeBytes,
                url: a.url || null,
                storageKey: a.storageKey || null,
                uploadedAt: a.uploadedAt ? new Date(a.uploadedAt) : now,
              })),
            );
          }
          if (doc.audit?.length) {
            await db.insert(invoiceAudit).values(
              doc.audit.map((s) => ({
                id: s.id,
                orgId,
                invoiceId: id,
                at: s.at ? new Date(s.at) : now,
                actorId: s.actorId,
                action: s.action,
                notes: s.notes || null,
              })),
            );
          }

          // Round-trip so the returned shape is authoritative.
          const [lineRows, vatRows, attRows, auditRows] = await Promise.all([
            db.select().from(invoiceLines).where(eq(invoiceLines.invoiceId, id)),
            db
              .select()
              .from(invoiceVatBreakdowns)
              .where(eq(invoiceVatBreakdowns.invoiceId, id)),
            db.select().from(invoiceAttachments).where(eq(invoiceAttachments.invoiceId, id)),
            db
              .select()
              .from(invoiceAudit)
              .where(eq(invoiceAudit.invoiceId, id))
              .orderBy(asc(invoiceAudit.at)),
          ]);
          return assembleDoc(header, lineRows, vatRows, attRows, auditRows);
        });
      } catch (err) {
        if (err instanceof DbError) throw err;
        if (err && err.code === '23505') {
          throw new ConflictError('Invoice conflict (series/number already exists)', {
            cause: err,
          });
        }
        if (err && err.code === '23503') {
          throw new ConflictError('Referenced party does not exist', { cause: err });
        }
        throw new DbError('invoices.create failed', { cause: err });
      }
    },

    async update(orgId, id, patch) {
      assertUuid(orgId, 'orgId');
      assertUuid(id, 'id');
      if (!patch || typeof patch !== 'object') {
        throw new ValidationError('patch must be an object');
      }
      // Only whitelisted header fields are patchable here. To replace
      // lines / vat / attachments / audit, pass the full arrays and we
      // overwrite.
      const now = new Date();
      const headerSet = { updatedAt: now };
      if (patch.series !== undefined) headerSet.series = patch.series;
      if (patch.number !== undefined) headerSet.number = patch.number;
      if (patch.issueDate !== undefined) {
        assertIsoDate(patch.issueDate, 'issueDate');
        headerSet.issueDate = patch.issueDate;
      }
      if (patch.operationDate !== undefined) {
        if (patch.operationDate) assertIsoDate(patch.operationDate, 'operationDate');
        headerSet.operationDate = patch.operationDate || null;
      }
      if (patch.issuerId !== undefined) {
        assertUuid(patch.issuerId, 'issuerId');
        headerSet.issuerId = patch.issuerId;
      }
      if (patch.recipientId !== undefined) {
        assertUuid(patch.recipientId, 'recipientId');
        headerSet.recipientId = patch.recipientId;
      }
      if (patch.status !== undefined) {
        if (!INVOICE_STATUSES.has(patch.status)) {
          throw new ValidationError('invalid status', { field: 'status' });
        }
        headerSet.status = patch.status;
      }
      if (patch.regime !== undefined) headerSet.regime = patch.regime;
      if (patch.operationType !== undefined) headerSet.operationType = patch.operationType;
      if (patch.fiscalRegion !== undefined) headerSet.fiscalRegion = patch.fiscalRegion;
      if (patch.notes !== undefined) headerSet.notes = patch.notes || null;
      if (patch.rectification !== undefined) headerSet.rectification = patch.rectification || null;
      if (patch.totals) {
        if (patch.totals.subtotalCents !== undefined) {
          assertCents(patch.totals.subtotalCents, 'totals.subtotalCents');
          headerSet.subtotalCents = patch.totals.subtotalCents;
        }
        if (patch.totals.irpfCents !== undefined) {
          assertCents(patch.totals.irpfCents, 'totals.irpfCents');
          headerSet.irpfCents = patch.totals.irpfCents;
        }
        if (patch.totals.totalCents !== undefined) {
          assertCents(patch.totals.totalCents, 'totals.totalCents');
          headerSet.totalCents = patch.totals.totalCents;
        }
        if (patch.totals.currency !== undefined) headerSet.currency = patch.totals.currency;
      }
      if (patch.compliance) {
        if (patch.compliance.ticketBaiId !== undefined)
          headerSet.ticketBaiId = patch.compliance.ticketBaiId || null;
        if (patch.compliance.ticketBaiHash !== undefined)
          headerSet.ticketBaiHash = patch.compliance.ticketBaiHash || null;
        if (patch.compliance.verifactuHash !== undefined)
          headerSet.verifactuHash = patch.compliance.verifactuHash || null;
        if (patch.compliance.verifactuChainRef !== undefined)
          headerSet.verifactuChainRef = patch.compliance.verifactuChainRef || null;
        if (patch.compliance.siiSubmitted !== undefined)
          headerSet.siiSubmitted = !!patch.compliance.siiSubmitted;
      }
      if (patch.paymentTerms !== undefined) {
        const pt = patch.paymentTerms || {};
        headerSet.paymentMethod = pt.method || null;
        headerSet.paymentIban = pt.iban || null;
        headerSet.paymentDueDate = pt.dueDate || null;
      }

      try {
        return await withOrg(orgId, async ({ db }) => {
          const [header] = await db
            .update(invoices)
            .set(headerSet)
            .where(and(eq(invoices.orgId, orgId), eq(invoices.id, id)))
            .returning();
          if (!header) throw new NotFoundError('Invoice', id);

          // Replace-full-set semantics for child arrays when provided.
          if (Array.isArray(patch.lines)) {
            await db.delete(invoiceLines).where(eq(invoiceLines.invoiceId, id));
            if (patch.lines.length) {
              await db.insert(invoiceLines).values(
                patch.lines.map((l, i) => ({
                  id: l.id,
                  orgId,
                  invoiceId: id,
                  position: i,
                  description: l.description,
                  quantity: String(l.quantity),
                  unitPriceCents: l.unitPriceCents,
                  discountPercent:
                    l.discountPercent !== undefined ? String(l.discountPercent) : null,
                  vatRate: l.vatRate,
                  vatRateValue: String(l.vatRateValue),
                  irpfRate: l.irpfRate !== undefined ? String(l.irpfRate) : null,
                  exemptReason: l.exemptReason || null,
                  lineTotalCents: l.lineTotalCents,
                })),
              );
            }
          }
          if (patch.totals && Array.isArray(patch.totals.vatBreakdown)) {
            await db
              .delete(invoiceVatBreakdowns)
              .where(eq(invoiceVatBreakdowns.invoiceId, id));
            if (patch.totals.vatBreakdown.length) {
              await db.insert(invoiceVatBreakdowns).values(
                patch.totals.vatBreakdown.map((v) => ({
                  orgId,
                  invoiceId: id,
                  vatRate: v.vatRate,
                  vatRateValue: String(v.vatRateValue),
                  baseCents: v.baseCents,
                  vatCents: v.vatCents,
                  recargoCents: v.recargoCents || 0,
                })),
              );
            }
          }
          if (Array.isArray(patch.attachments)) {
            await db.delete(invoiceAttachments).where(eq(invoiceAttachments.invoiceId, id));
            if (patch.attachments.length) {
              await db.insert(invoiceAttachments).values(
                patch.attachments.map((a) => ({
                  id: a.id,
                  orgId,
                  invoiceId: id,
                  fileName: a.fileName,
                  mimeType: a.mimeType,
                  sizeBytes: a.sizeBytes,
                  url: a.url || null,
                  storageKey: a.storageKey || null,
                  uploadedAt: a.uploadedAt ? new Date(a.uploadedAt) : now,
                })),
              );
            }
          }
          if (Array.isArray(patch.audit)) {
            // Audit is append-only; we do NOT delete existing stamps. We
            // insert only those entries that do not yet exist by id.
            const existing = await db
              .select({ id: invoiceAudit.id })
              .from(invoiceAudit)
              .where(eq(invoiceAudit.invoiceId, id));
            const have = new Set(existing.map((r) => r.id));
            const toInsert = patch.audit.filter((s) => s.id && !have.has(s.id));
            if (toInsert.length) {
              await db.insert(invoiceAudit).values(
                toInsert.map((s) => ({
                  id: s.id,
                  orgId,
                  invoiceId: id,
                  at: s.at ? new Date(s.at) : now,
                  actorId: s.actorId,
                  action: s.action,
                  notes: s.notes || null,
                })),
              );
            }
          }

          const [lineRows, vatRows, attRows, auditRows] = await Promise.all([
            db.select().from(invoiceLines).where(eq(invoiceLines.invoiceId, id)),
            db
              .select()
              .from(invoiceVatBreakdowns)
              .where(eq(invoiceVatBreakdowns.invoiceId, id)),
            db.select().from(invoiceAttachments).where(eq(invoiceAttachments.invoiceId, id)),
            db
              .select()
              .from(invoiceAudit)
              .where(eq(invoiceAudit.invoiceId, id))
              .orderBy(asc(invoiceAudit.at)),
          ]);
          return assembleDoc(header, lineRows, vatRows, attRows, auditRows);
        });
      } catch (err) {
        if (err instanceof DbError) throw err;
        if (err && err.code === '23505') {
          throw new ConflictError('Invoice conflict (series/number already exists)', {
            cause: err,
          });
        }
        if (err && err.code === '23503') {
          throw new ConflictError('Referenced party does not exist', { cause: err });
        }
        throw new DbError('invoices.update failed', { cause: err });
      }
    },

    async delete(orgId, id) {
      assertUuid(orgId, 'orgId');
      assertUuid(id, 'id');
      try {
        await withOrg(orgId, async ({ db }) => {
          const deleted = await db
            .delete(invoices)
            .where(and(eq(invoices.orgId, orgId), eq(invoices.id, id)))
            .returning({ id: invoices.id });
          if (!deleted[0]) throw new NotFoundError('Invoice', id);
          // Child rows cascade via FK ON DELETE CASCADE.
        });
      } catch (err) {
        if (err instanceof DbError) throw err;
        throw new DbError('invoices.delete failed', { cause: err });
      }
    },

    async count(orgId) {
      assertUuid(orgId, 'orgId');
      try {
        return await withOrg(orgId, async ({ db }) => {
          const [row] = await db
            .select({ n: sqlCount() })
            .from(invoices)
            .where(eq(invoices.orgId, orgId));
          return Number(row?.n || 0);
        });
      } catch (err) {
        if (err instanceof DbError) throw err;
        throw new DbError('invoices.count failed', { cause: err });
      }
    },
  };
}

module.exports = { createInvoicesRepo };
