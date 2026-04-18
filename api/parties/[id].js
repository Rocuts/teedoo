/**
 * /api/parties/:id
 *   GET    → fetch one party.
 *   DELETE → 204 on success. Postgres refuses delete when invoices
 *            reference the party (FK ON DELETE RESTRICT) → 409.
 */

const { getRepositories } = require('../_lib/db/factory');
const { activeOrgId } = require('../_lib/session');
const {
  json,
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
    return handleError(res, err, 'parties[id]');
  }

  const id = extractPathId(req, 'id');
  if (!id) {
    return json(res, 400, { error: { message: 'id path parameter is required' } });
  }

  let repos;
  try {
    repos = getRepositories({ overrides: buildOverrides(source) });
  } catch (err) {
    console.error('[parties/:id] factory error:', err.message);
    return json(res, 500, { error: { message: 'Data source is not configured' } });
  }

  const started = Date.now();

  if (req.method === 'GET') {
    try {
      const party = await repos.parties.get(activeOrgId, id);
      console.log(JSON.stringify({
        type: 'parties.get',
        orgId: activeOrgId,
        partyId: id,
        source: source || process.env.DATA_SOURCE || 'unknown',
        elapsed_ms: Date.now() - started,
        timestamp: new Date().toISOString(),
      }));
      return json(res, 200, party);
    } catch (err) {
      return handleError(res, err, 'parties.get');
    }
  }

  if (req.method === 'DELETE') {
    try {
      await repos.parties.delete(activeOrgId, id);
      console.log(JSON.stringify({
        type: 'parties.delete',
        orgId: activeOrgId,
        partyId: id,
        source: source || process.env.DATA_SOURCE || 'unknown',
        elapsed_ms: Date.now() - started,
        timestamp: new Date().toISOString(),
      }));
      res.statusCode = 204;
      res.end();
      return;
    } catch (err) {
      return handleError(res, err, 'parties.delete');
    }
  }

  return json(res, 405, { error: { message: 'Method Not Allowed' } });
};
