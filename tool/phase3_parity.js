#!/usr/bin/env node
/**
 * Cross-backend parity spot-check. Lists invoices per backend and compares
 * key canonical fields: id, series/number, status, totals.totalCents.
 */
const { MongoClient } = require('mongodb');
const postgres = require('postgres');

const ORG_ID = '00000000-0000-4000-8000-000000000001';

(async () => {
  const uri = process.env.MONGODB_URI;
  const dbName = process.env.MONGODB_DB || 'teedoo';
  const client = new MongoClient(uri);
  await client.connect();
  const db = client.db(dbName);

  const mongoInv = await db
    .collection('invoices')
    .find({ orgId: ORG_ID }, { projection: { _id: 0, id: 1, series: 1, number: 1, status: 1, 'totals.totalCents': 1, regime: 1, operationType: 1, fiscalRegion: 1 } })
    .sort({ number: 1 })
    .toArray();

  const sql = postgres(process.env.POSTGRES_URL, { max: 1, prepare: false });
  const pgInv = await sql.begin(async (tx) => {
    await tx`SELECT set_config('app.org_id', ${ORG_ID}, true)`;
    return tx`SELECT id, series, number, status, total_cents AS "totalCents", regime, operation_type AS "operationType", fiscal_region AS "fiscalRegion"
             FROM invoices WHERE org_id = ${ORG_ID} ORDER BY number`;
  });

  const fmtM = (r) => ({ id: r.id, series: r.series, number: r.number, status: r.status, total: r.totals?.totalCents, regime: r.regime, op: r.operationType, region: r.fiscalRegion });
  const fmtP = (r) => ({ id: r.id, series: r.series, number: r.number, status: r.status, total: r.totalCents, regime: r.regime, op: r.operationType, region: r.fiscalRegion });

  const m = mongoInv.map(fmtM);
  const p = pgInv.map(fmtP);

  console.log('MONGO:'); console.table(m);
  console.log('POSTGRES:'); console.table(p);

  let ok = true;
  for (let i = 0; i < Math.max(m.length, p.length); i++) {
    const a = m[i]; const b = p[i];
    if (!a || !b || a.id !== b.id || a.series !== b.series || a.number !== b.number || a.status !== b.status || a.total !== b.total || a.regime !== b.regime || a.op !== b.op || a.region !== b.region) {
      console.log(`DRIFT at index ${i}:`, { mongo: a, postgres: b });
      ok = false;
    }
  }
  console.log(ok ? '\nPARITY OK' : '\nPARITY DRIFT');

  await sql.end({ timeout: 5 });
  await client.close();
})();
