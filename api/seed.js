/**
 * POST /api/seed
 *
 * Demo-only endpoint that populates the selected backend with 3 parties +
 * 5 invoices covering the fiscal status matrix (see `_lib/seeds/invoices.js`).
 *
 * Auth: Bearer token in the `Authorization` header, compared to `SEED_TOKEN`
 * via constant-time equality. Missing, malformed, or wrong token → 401 with
 * a generic message (no hint about *which* part was wrong).
 *
 * Idempotency: if `invoices.count(activeOrgId) > 0`, we return `{ skipped }`.
 * This lets CI / demo setup scripts call the endpoint repeatedly without
 * risk of duplicating seed rows.
 *
 * Backend selection:
 *   X-Data-Source: mongo|postgres (optional). Falls back to env DATA_SOURCE.
 *
 * NOT for production. Guard with Vercel deployment protection + rotate
 * SEED_TOKEN between environments.
 */

const crypto = require('crypto');
const { getRepositories } = require('./_lib/db/factory');
const { activeOrgId } = require('./_lib/session');
const {
  json,
  getDataSource,
  setCorsHeaders,
  handlePreflight,
  handleError,
} = require('./_lib/http');
const { seedParties, seedInvoices } = require('./_lib/seeds/invoices');

function buildOverrides(source) {
  if (!source) return {};
  return { invoices: source, parties: source };
}

function timingSafeEqual(a, b) {
  // constant-time compare; returns false for mismatched lengths without
  // leaking which input is longer via early-exit timing.
  const aBuf = Buffer.from(a, 'utf8');
  const bBuf = Buffer.from(b, 'utf8');
  if (aBuf.length !== bBuf.length) return false;
  return crypto.timingSafeEqual(aBuf, bBuf);
}

function extractBearer(req) {
  const raw = req.headers['authorization'];
  if (!raw || typeof raw !== 'string') return null;
  if (!raw.startsWith('Bearer ')) return null;
  return raw.slice('Bearer '.length).trim() || null;
}

module.exports = async function handler(req, res) {
  if (handlePreflight(req, res)) return;
  setCorsHeaders(res);

  if (req.method !== 'POST') {
    return json(res, 405, { error: { message: 'Method Not Allowed' } });
  }

  // ── Auth ────────────────────────────────────────────────────────────
  const expected = process.env.SEED_TOKEN;
  if (!expected) {
    console.error('[seed] SEED_TOKEN is not configured');
    return json(res, 500, { error: { message: 'Seed endpoint is not configured' } });
  }
  const token = extractBearer(req);
  if (!token || !timingSafeEqual(token, expected)) {
    return json(res, 401, { error: { message: 'Unauthorized' } });
  }

  // ── Data source ────────────────────────────────────────────────────
  let source;
  try {
    source = getDataSource(req);
  } catch (err) {
    return handleError(res, err, 'seed');
  }
  const resolvedBackend = source || process.env.DATA_SOURCE || 'unknown';

  let repos;
  try {
    repos = getRepositories({ overrides: buildOverrides(source) });
  } catch (err) {
    console.error('[seed] factory error:', err.message);
    return json(res, 500, { error: { message: 'Data source is not configured' } });
  }

  const started = Date.now();

  // ── Idempotency gate ───────────────────────────────────────────────
  try {
    const existing = await repos.invoices.count(activeOrgId);
    if (existing > 0) {
      console.log(JSON.stringify({
        type: 'seed.skipped',
        reason: 'already_seeded',
        orgId: activeOrgId,
        backend: resolvedBackend,
        existingInvoices: existing,
        elapsed_ms: Date.now() - started,
        timestamp: new Date().toISOString(),
      }));
      return json(res, 200, {
        skipped: true,
        reason: 'already_seeded',
        existingInvoices: existing,
        backend: resolvedBackend,
      });
    }
  } catch (err) {
    return handleError(res, err, 'seed.count');
  }

  // ── Seed parties first (invoices FK-reference them in Postgres) ───
  const parties = seedParties(activeOrgId);
  const invoices = seedInvoices(activeOrgId);

  try {
    for (const p of parties) {
      await repos.parties.upsert(p);
    }
    for (const inv of invoices) {
      await repos.invoices.create(inv);
    }
  } catch (err) {
    console.error('[seed] seeding failed:', err.message);
    return handleError(res, err, 'seed.write');
  }

  const elapsed = Date.now() - started;
  console.log(JSON.stringify({
    type: 'seed.completed',
    orgId: activeOrgId,
    backend: resolvedBackend,
    parties: parties.length,
    invoices: invoices.length,
    elapsed_ms: elapsed,
    timestamp: new Date().toISOString(),
  }));

  return json(res, 200, {
    seeded: true,
    parties: parties.length,
    invoices: invoices.length,
    backend: resolvedBackend,
  });
};
