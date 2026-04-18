#!/usr/bin/env node
/**
 * Phase 3 hot-fix applier:
 *  1. Widen invoice_lines.exempt_reason from varchar(16) to varchar(255).
 *  2. Clean the partial seed inserted during a half-failed run in this
 *     same session (PG dev DB — no legacy data per owner context).
 *
 * Uses POSTGRES_URL_NON_POOLING. Safe on preview/dev only.
 */
const postgres = require('postgres');

const ORG_ID = '00000000-0000-4000-8000-000000000001';

(async () => {
  const url = process.env.POSTGRES_URL_NON_POOLING;
  if (!url) {
    console.error('POSTGRES_URL_NON_POOLING is not set.');
    process.exit(1);
  }
  const sql = postgres(url, { max: 1, prepare: false, idle_timeout: 5, connect_timeout: 10 });
  try {
    // 1. widen column
    await sql`ALTER TABLE invoice_lines ALTER COLUMN exempt_reason TYPE varchar(255)`;
    console.log('exempt_reason widened to varchar(255).');

    // 2. clean partial seed for demo org only
    await sql.begin(async (tx) => {
      await tx`SELECT set_config('app.org_id', ${ORG_ID}, true)`;
      await tx`DELETE FROM invoice_audit WHERE org_id = ${ORG_ID}`;
      await tx`DELETE FROM invoice_attachments WHERE org_id = ${ORG_ID}`;
      await tx`DELETE FROM invoice_vat_breakdowns WHERE org_id = ${ORG_ID}`;
      await tx`DELETE FROM invoice_lines WHERE org_id = ${ORG_ID}`;
      await tx`DELETE FROM invoices WHERE org_id = ${ORG_ID}`;
      await tx`DELETE FROM parties WHERE org_id = ${ORG_ID}`;
    });
    console.log('Demo-org rows deleted from all Postgres tables.');

    const [c] = await sql`SELECT count(*)::int AS n FROM invoices WHERE org_id = ${ORG_ID}`;
    console.log(`invoices remaining for demo org: ${c.n}`);
  } catch (err) {
    console.error('ERR:', err.message);
    console.error(err);
    process.exitCode = 2;
  } finally {
    await sql.end({ timeout: 5 });
  }
})();
