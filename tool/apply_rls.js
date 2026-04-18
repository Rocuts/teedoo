#!/usr/bin/env node
/**
 * Applies api/_lib/db/postgres/migrations/rls_policies.sql to Supabase using
 * the direct (non-pooled) connection. Substitute for `psql -f` since psql is
 * not installed in this environment.
 *
 * Run:  node tool/apply_rls.js
 * Requires: POSTGRES_URL_NON_POOLING in env.
 */

const fs = require('fs');
const path = require('path');
const postgres = require('postgres');

const sqlPath = path.join(
  __dirname,
  '..',
  'api',
  '_lib',
  'db',
  'postgres',
  'migrations',
  'rls_policies.sql',
);

(async () => {
  const url = process.env.POSTGRES_URL_NON_POOLING;
  if (!url) {
    console.error('POSTGRES_URL_NON_POOLING is not set.');
    process.exit(1);
  }
  const script = fs.readFileSync(sqlPath, 'utf8');

  // Use postgres-js unsafe() to execute the multi-statement script. Direct
  // (non-pooled) connection: prepared-statement constraint does not apply.
  const sql = postgres(url, {
    max: 1,
    idle_timeout: 5,
    connect_timeout: 10,
    prepare: false,
  });

  try {
    await sql.unsafe(script);
    console.log('rls_policies.sql applied successfully.');
  } catch (err) {
    console.error('Failed to apply RLS:', err.message);
    console.error(err);
    process.exitCode = 2;
  } finally {
    await sql.end({ timeout: 5 });
  }
})();
