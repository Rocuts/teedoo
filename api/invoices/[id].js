/**
 * /api/invoices/:id
 *   GET    → fetch one invoice.
 *   PATCH  → update whitelisted header / child fields. Lines & totals follow
 *            replace-full-set semantics when arrays are provided (see the
 *            Postgres repo for the full contract).
 *   DELETE → 204 on success. Postgres cascades child rows; Mongo removes
 *            the single document.
 *
 * Path-param routing: relies on Vercel's filesystem convention
 * `api/invoices/[id].js`. Locally, `req.query.id` is populated.
 */

const { getRepositories } = require('../_lib/db/factory');
const { activeOrgId } = require('../_lib/session');
const {
  json,
  parseJsonBody,
  getDataSource,
  setCorsHeaders,
  handlePreflight,
  handleError,
  extractPathId,
} = require('../_lib/http');

function buildOverrides(source) {
  if (!source) return {};
  return { invoices: source, parties: source };
}

module.exports = async function handler(req, res) {
  if (handlePreflight(req, res)) return;
  setCorsHeaders(res);

  let source;
  try {
    source = getDataSource(req);
  } catch (err) {
    return handleError(res, err, 'invoices[id]');
  }

  const id = extractPathId(req, 'id');
  if (!id) {
    return json(res, 400, { error: { message: 'id path parameter is required' } });
  }

  let repos;
  try {
    repos = getRepositories({ overrides: buildOverrides(source) });
  } catch (err) {
    console.error('[invoices/:id] factory error:', err.message);
    return json(res, 500, { error: { message: 'Data source is not configured' } });
  }

  const started = Date.now();

  if (req.method === 'GET') {
    try {
      const doc = await repos.invoices.get(activeOrgId, id);
      console.log(JSON.stringify({
        type: 'invoices.get',
        orgId: activeOrgId,
        invoiceId: id,
        source: source || process.env.DATA_SOURCE || 'unknown',
        elapsed_ms: Date.now() - started,
        timestamp: new Date().toISOString(),
      }));
      return json(res, 200, doc);
    } catch (err) {
      return handleError(res, err, 'invoices.get');
    }
  }

  if (req.method === 'PATCH') {
    let patch;
    try {
      patch = await parseJsonBody(req);
    } catch (err) {
      return handleError(res, err, 'invoices.update');
    }
    if (!patch || typeof patch !== 'object') {
      return json(res, 400, { error: { message: 'Patch body must be a JSON object' } });
    }
    // Defense-in-depth: the Mongo repo refuses `id`/`orgId`/`createdAt`,
    // but dropping them here keeps the error shape consistent and matches
    // the Postgres repo which ignores unrecognized keys.
    delete patch.id;
    delete patch.orgId;
    delete patch.createdAt;

    try {
      const updated = await repos.invoices.update(activeOrgId, id, patch);
      console.log(JSON.stringify({
        type: 'invoices.update',
        orgId: activeOrgId,
        invoiceId: id,
        patchedFields: Object.keys(patch),
        source: source || process.env.DATA_SOURCE || 'unknown',
        elapsed_ms: Date.now() - started,
        timestamp: new Date().toISOString(),
      }));
      return json(res, 200, updated);
    } catch (err) {
      return handleError(res, err, 'invoices.update');
    }
  }

  if (req.method === 'DELETE') {
    try {
      await repos.invoices.delete(activeOrgId, id);
      console.log(JSON.stringify({
        type: 'invoices.delete',
        orgId: activeOrgId,
        invoiceId: id,
        source: source || process.env.DATA_SOURCE || 'unknown',
        elapsed_ms: Date.now() - started,
        timestamp: new Date().toISOString(),
      }));
      res.statusCode = 204;
      res.end();
      return;
    } catch (err) {
      return handleError(res, err, 'invoices.delete');
    }
  }

  return json(res, 405, { error: { message: 'Method Not Allowed' } });
};
