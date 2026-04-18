/**
 * /api/invoices
 *   GET  → list invoices for the active org (cursor-paginated).
 *   POST → create a new invoice. The server fills id / timestamps / orgId
 *          / the initial audit stamp. Lines & totals come from the client.
 *
 * Data source resolution:
 *   1. `X-Data-Source` header ('mongo' | 'postgres') → override for this request.
 *   2. Fallback to process.env.DATA_SOURCE.
 *
 * Auth: sprint 1 uses a hardcoded demo orgId (see `_lib/session.js`).
 */

const { randomUUID } = require('crypto');
const { getRepositories } = require('../_lib/db/factory');
const { activeOrgId } = require('../_lib/session');
const {
  json,
  parseJsonBody,
  getDataSource,
  setCorsHeaders,
  handlePreflight,
  handleError,
} = require('../_lib/http');

function buildOverrides(source) {
  if (!source) return {};
  // Parties and invoices must live in the same backend for foreign-key
  // integrity (both on Mongo, or both on Postgres) — never cross them.
  return { invoices: source, parties: source };
}

function coerceLimit(raw) {
  if (raw == null || raw === '') return undefined;
  const n = Number(raw);
  if (!Number.isFinite(n) || !Number.isInteger(n) || n <= 0) {
    return 'invalid';
  }
  return n;
}

module.exports = async function handler(req, res) {
  if (handlePreflight(req, res)) return;
  setCorsHeaders(res);

  let source;
  try {
    source = getDataSource(req);
  } catch (err) {
    return handleError(res, err, 'invoices');
  }

  let repos;
  try {
    repos = getRepositories({ overrides: buildOverrides(source) });
  } catch (err) {
    console.error('[invoices] factory error:', err.message);
    return json(res, 500, {
      error: { message: 'Data source is not configured' },
    });
  }

  const started = Date.now();

  if (req.method === 'GET') {
    const url = new URL(req.url, 'http://internal');
    const q = {};
    const rawLimit = url.searchParams.get('limit');
    const limit = coerceLimit(rawLimit);
    if (limit === 'invalid') {
      return json(res, 400, {
        error: { message: 'limit must be a positive integer', field: 'limit' },
      });
    }
    if (limit !== undefined) q.limit = limit;
    const cursor = url.searchParams.get('cursor');
    if (cursor) q.cursor = cursor;
    const status = url.searchParams.get('status');
    if (status) q.status = status;
    const issuerId = url.searchParams.get('issuerId');
    if (issuerId) q.issuerId = issuerId;
    const recipientId = url.searchParams.get('recipientId');
    if (recipientId) q.recipientId = recipientId;
    const fromDate = url.searchParams.get('fromDate');
    if (fromDate) q.fromDate = fromDate;
    const toDate = url.searchParams.get('toDate');
    if (toDate) q.toDate = toDate;

    try {
      const page = await repos.invoices.list(activeOrgId, q);
      console.log(JSON.stringify({
        type: 'invoices.list',
        orgId: activeOrgId,
        source: source || process.env.DATA_SOURCE || 'unknown',
        count: page.items.length,
        hasNextCursor: !!page.nextCursor,
        elapsed_ms: Date.now() - started,
        timestamp: new Date().toISOString(),
      }));
      return json(res, 200, page);
    } catch (err) {
      return handleError(res, err, 'invoices.list');
    }
  }

  if (req.method === 'POST') {
    let payload;
    try {
      payload = await parseJsonBody(req);
    } catch (err) {
      return handleError(res, err, 'invoices.create');
    }
    if (!payload || typeof payload !== 'object') {
      return json(res, 400, { error: { message: 'Request body must be a JSON object' } });
    }

    const now = new Date().toISOString();
    const id = payload.id || randomUUID();
    const doc = {
      ...payload,
      id,
      orgId: activeOrgId, // authoritative: never trust the client for tenancy
      createdAt: now,
      updatedAt: now,
      attachments: Array.isArray(payload.attachments) ? payload.attachments : [],
      audit: [
        {
          id: randomUUID(),
          at: now,
          actor: 'demo',
          action: 'created',
        },
      ],
    };

    try {
      const created = await repos.invoices.create(doc);
      console.log(JSON.stringify({
        type: 'invoices.create',
        orgId: activeOrgId,
        invoiceId: created.id,
        series: created.series,
        number: created.number,
        status: created.status,
        source: source || process.env.DATA_SOURCE || 'unknown',
        elapsed_ms: Date.now() - started,
        timestamp: new Date().toISOString(),
      }));
      return json(res, 201, created);
    } catch (err) {
      return handleError(res, err, 'invoices.create');
    }
  }

  return json(res, 405, { error: { message: 'Method Not Allowed' } });
};
