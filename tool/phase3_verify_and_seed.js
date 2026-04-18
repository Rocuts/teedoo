#!/usr/bin/env node
/**
 * Phase 3 Step 1 verifier + dual-DB seeder.
 *
 * Steps:
 *   1. RLS lockdown check: SELECT count(*) FROM invoices with NO app.org_id
 *      must be 0 (policy fails closed when GUC is unset).
 *   2. Invoke api/seed.js handler in-process twice (mongo, then postgres),
 *      emulating the Vercel req/res contract. Prints the JSON response.
 *   3. Count rows per backend to confirm parity:
 *        parties == 4, invoices == 6 each.
 *
 * Env: loaded from .env.local via dotenv-cli when wrapped with npx dotenv.
 */

const postgres = require('postgres');
const { MongoClient } = require('mongodb');

const ORG_ID = '00000000-0000-4000-8000-000000000001';

// ── Mock req/res for Vercel-style handlers ───────────────────────────────

function makeReq({ method = 'POST', url = '/api/seed', headers = {}, body = null } = {}) {
  return {
    method,
    url,
    headers: Object.fromEntries(
      Object.entries(headers).map(([k, v]) => [k.toLowerCase(), v]),
    ),
    body,
  };
}

function makeRes() {
  const res = {
    statusCode: 200,
    _headers: {},
    _body: '',
    _ended: false,
    setHeader(k, v) { this._headers[k.toLowerCase()] = v; },
    getHeader(k) { return this._headers[k.toLowerCase()]; },
    writeHead(code, headers) {
      this.statusCode = code;
      if (headers) for (const [k, v] of Object.entries(headers)) this.setHeader(k, v);
    },
    end(chunk) {
      if (chunk != null) this._body += chunk;
      this._ended = true;
    },
    write(chunk) { if (chunk != null) this._body += chunk; },
  };
  return res;
}

async function invokeSeed(source) {
  const handler = require('../api/seed.js');
  const token = process.env.SEED_TOKEN;
  if (!token) throw new Error('SEED_TOKEN not set');
  const req = makeReq({
    headers: {
      'authorization': `Bearer ${token}`,
      'x-data-source': source,
      'content-type': 'application/json',
    },
  });
  const res = makeRes();
  await handler(req, res);
  let parsed = null;
  try { parsed = JSON.parse(res._body); } catch { /* keep raw */ }
  return { status: res.statusCode, body: parsed || res._body };
}

// ── RLS check via direct-pool (POSTGRES_URL is the pooled pgbouncer URL;
// RLS policies evaluate the same way on either connection). ──────────────

async function rlsLockdownCheck() {
  const url = process.env.POSTGRES_URL;
  if (!url) throw new Error('POSTGRES_URL not set');
  const sql = postgres(url, { max: 1, prepare: false, idle_timeout: 5, connect_timeout: 10 });
  try {
    // No set_config → RLS predicate: org_id = NULL → fails closed.
    const [row] = await sql`SELECT count(*)::int AS n FROM invoices`;
    return row.n;
  } finally {
    await sql.end({ timeout: 5 });
  }
}

// ── Counts per backend (independent of HTTP layer) ───────────────────────

async function pgCounts() {
  const url = process.env.POSTGRES_URL;
  const sql = postgres(url, { max: 1, prepare: false, idle_timeout: 5, connect_timeout: 10 });
  try {
    return await sql.begin(async (tx) => {
      await tx`SELECT set_config('app.org_id', ${ORG_ID}, true)`;
      const [p] = await tx`SELECT count(*)::int AS n FROM parties  WHERE org_id = ${ORG_ID}`;
      const [i] = await tx`SELECT count(*)::int AS n FROM invoices WHERE org_id = ${ORG_ID}`;
      const [l] = await tx`SELECT count(*)::int AS n FROM invoice_lines WHERE org_id = ${ORG_ID}`;
      const [v] = await tx`SELECT count(*)::int AS n FROM invoice_vat_breakdowns WHERE org_id = ${ORG_ID}`;
      const [a] = await tx`SELECT count(*)::int AS n FROM invoice_audit WHERE org_id = ${ORG_ID}`;
      return { parties: p.n, invoices: i.n, lines: l.n, vat: v.n, audit: a.n };
    });
  } finally {
    await sql.end({ timeout: 5 });
  }
}

async function mongoCounts() {
  const uri = process.env.MONGODB_URI;
  if (!uri) throw new Error('MONGODB_URI not set');
  const client = new MongoClient(uri);
  try {
    await client.connect();
    // Repo uses client.db('teedoo') (see api/_lib/db/mongo/client.js — MONGODB_DB
     // env fallback = 'teedoo'). Mirror that here so counts target the same db.
    const db = client.db(process.env.MONGODB_DB || 'teedoo');
    const parties = await db.collection('parties').countDocuments({ orgId: ORG_ID });
    const invoices = await db.collection('invoices').countDocuments({ orgId: ORG_ID });
    return { parties, invoices, dbName: db.databaseName };
  } finally {
    await client.close();
  }
}

// ── Main ─────────────────────────────────────────────────────────────────

(async () => {
  console.log('\n=== 1. RLS lockdown (should return 0) ===');
  try {
    const n = await rlsLockdownCheck();
    console.log(`invoices without app.org_id → count = ${n}  ${n === 0 ? 'PASS' : 'FAIL'}`);
  } catch (err) {
    console.log(`RLS check failed: ${err.message}`);
  }

  console.log('\n=== 2. Seed via handler (mongo, then postgres) ===');
  for (const src of ['mongo', 'postgres']) {
    try {
      const r = await invokeSeed(src);
      console.log(`[${src}] status=${r.status} body=${JSON.stringify(r.body)}`);
    } catch (err) {
      console.log(`[${src}] ERROR: ${err.message}`);
      console.log(err.stack);
    }
  }

  console.log('\n=== 3. Post-seed counts ===');
  try {
    const m = await mongoCounts();
    console.log(`mongo    (db=${m.dbName}): parties=${m.parties} invoices=${m.invoices}`);
  } catch (err) {
    console.log(`mongo counts error: ${err.message}`);
  }
  try {
    const p = await pgCounts();
    console.log(`postgres: parties=${p.parties} invoices=${p.invoices} lines=${p.lines} vatBD=${p.vat} audit=${p.audit}`);
  } catch (err) {
    console.log(`postgres counts error: ${err.message}`);
  }

  // ensure node process exits cleanly (postgres client cache + mongo kept-alive)
  setTimeout(() => process.exit(0), 500).unref();
})().catch((err) => {
  console.error('Fatal:', err);
  process.exit(1);
});
