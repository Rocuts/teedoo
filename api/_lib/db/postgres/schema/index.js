/**
 * Drizzle Postgres schema entry point (Supabase-backed).
 *
 * Each domain defines its tables in its own file, then re-exports from
 * here so `drizzle-kit` picks everything up via a single import path.
 *
 * Supabase tip: Row-Level Security is enabled and policies are defined
 * in `../migrations/rls_policies.sql` — Drizzle does NOT manage RLS for
 * you. That SQL file must be applied AFTER the generated schema
 * migrations.
 */

const parties = require('./parties');
const invoices = require('./invoices');

module.exports = {
  ...parties,
  ...invoices,
};
