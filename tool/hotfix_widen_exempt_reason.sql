-- ─────────────────────────────────────────────────────────────────────
--  TeeDoo — widen invoice_lines.exempt_reason from varchar(16) → varchar(255)
-- ─────────────────────────────────────────────────────────────────────
--
--  CONTEXT (2026-04-18, applied by teedoo-db-migrator during Phase 3):
--  The seed fixture from teedoo-fiscal-compliance stores legal citations
--  in `exempt_reason` (e.g. "Art. 20.Uno.9º LIVA — servicios educativos
--  exentos.") which is ~60 chars. The Drizzle schema at
--  `api/_lib/db/postgres/schema/invoices.js` declared it as varchar(16),
--  causing "value too long for type character varying(16)" on seed.
--
--  This hot-fix only widens the column in the database. The Drizzle
--  schema source is still varchar(16); `teedoo-postgres-neon` must
--  update the schema file, regenerate the Drizzle migration, and
--  delete this hand-written migration once the source-of-truth is in
--  sync. Do NOT apply this migration to Production without that
--  cleanup — drizzle-kit will detect drift and try to shrink it back.
--
--  Idempotent: ALTER COLUMN ... TYPE is a no-op when the type already
--  matches, and Drizzle's migration runner will skip a file whose hash
--  is already recorded. We record the hash manually by running through
--  drizzle-kit migrate, OR apply this standalone via psql / node.
-- ─────────────────────────────────────────────────────────────────────

ALTER TABLE invoice_lines
    ALTER COLUMN exempt_reason TYPE varchar(255);
