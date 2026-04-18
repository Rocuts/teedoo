/**
 * /api/parties
 *   GET  → list parties for the active org (cursor-paginated).
 *   POST → upsert by (orgId, taxId). The repo is idempotent by design,
 *          so repeated POSTs with the same taxId update the existing row.
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
  return { invoices: source, parties: source };
}

function coerceLimit(raw) {
  if (raw == null || raw === '') return undefined;
  const n = Number(raw);
  if (!Number.isFinite(n) || !Number.isInteger(n) || n <= 0) return 'invalid';
  return n;
}

module.exports = async function handler(req, res) {
  if (handlePreflight(req, res)) return;
  setCorsHeaders(res);

  let source;
  try {
    source = getDataSource(req);
  } catch (err) {
    return handleError(res, err, 'parties');
  }

  let repos;
  try {
    repos = getRepositories({ overrides: buildOverrides(source) });
  } catch (err) {
    console.error('[parties] factory error:', err.message);
    return json(res, 500, { error: { message: 'Data source is not configured' } });
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

    try {
      const page = await repos.parties.list(activeOrgId, q);
      console.log(JSON.stringify({
        type: 'parties.list',
        orgId: activeOrgId,
        source: source || process.env.DATA_SOURCE || 'unknown',
        count: page.items.length,
        hasNextCursor: !!page.nextCursor,
        elapsed_ms: Date.now() - started,
        timestamp: new Date().toISOString(),
      }));
      return json(res, 200, page);
    } catch (err) {
      return handleError(res, err, 'parties.list');
    }
  }

  if (req.method === 'POST') {
    let payload;
    try {
      payload = await parseJsonBody(req);
    } catch (err) {
      return handleError(res, err, 'parties.upsert');
    }
    if (!payload || typeof payload !== 'object') {
      return json(res, 400, { error: { message: 'Request body must be a JSON object' } });
    }

    const now = new Date().toISOString();
    const party = {
      ...payload,
      id: payload.id || randomUUID(),
      orgId: activeOrgId,
      createdAt: payload.createdAt || now,
      updatedAt: now,
    };

    try {
      const saved = await repos.parties.upsert(party);
      console.log(JSON.stringify({
        type: 'parties.upsert',
        orgId: activeOrgId,
        partyId: saved.id,
        taxId: saved.taxId,
        source: source || process.env.DATA_SOURCE || 'unknown',
        elapsed_ms: Date.now() - started,
        timestamp: new Date().toISOString(),
      }));
      // Upsert can be either insert or update — we return 200 uniformly
      // so clients don't need to treat the two cases differently.
      return json(res, 200, saved);
    } catch (err) {
      return handleError(res, err, 'parties.upsert');
    }
  }

  return json(res, 405, { error: { message: 'Method Not Allowed' } });
};
