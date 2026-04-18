-- ─────────────────────────────────────────────────────────────────────
--  TeeDoo — Row-Level Security policies (Supabase Postgres)
-- ─────────────────────────────────────────────────────────────────────
--
--  Apply this file AFTER the Drizzle-generated schema migrations.
--  Drizzle does not manage RLS; this file is hand-maintained and kept in
--  version control next to the generated SQL in
--  `api/_lib/db/postgres/migrations/`.
--
--  HOW ORG SCOPING WORKS AT RUNTIME
--  --------------------------------
--  Every policy below evaluates:
--
--      org_id = current_setting('app.org_id', true)::uuid
--
--  The second argument `true` makes `current_setting` return NULL (not
--  error) when the GUC is unset, so the predicate fails closed and no
--  rows are visible.
--
--  The handler (or repo, when it opens its own transaction) MUST execute
--  at the start of every transaction:
--
--      SET LOCAL app.org_id = '<uuid>';
--
--  Using `SET LOCAL` (not plain `SET`) is CRITICAL — pgbouncer in
--  transaction pooling mode hands the connection back to the pool on
--  COMMIT, and `SET LOCAL` resets automatically. A bare `SET` would leak
--  the GUC to the next tenant on the same physical connection.
--
--  The repo (`repos/invoices.js` / `repos/parties.js`) calls
--  `sql.begin(async (tx) => { await tx\`SET LOCAL app.org_id = ${orgId}\`; ... })`.
--
--  NOTE on Supabase roles: Supabase runs app queries as the `authenticated`
--  role (or `anon` / `service_role`). We enable RLS unconditionally and
--  apply the policies to `PUBLIC` so they match whichever role your
--  connection string uses. Tighten to specific roles once auth is wired.
-- ─────────────────────────────────────────────────────────────────────

-- 1. Enable RLS on every multi-tenant table.
ALTER TABLE parties                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_lines            ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_vat_breakdowns   ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_attachments      ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_audit            ENABLE ROW LEVEL SECURITY;

-- Force RLS even for table owners (prevents accidental bypass in
-- migrations / admin scripts that forgot SET LOCAL).
ALTER TABLE parties                  FORCE ROW LEVEL SECURITY;
ALTER TABLE invoices                 FORCE ROW LEVEL SECURITY;
ALTER TABLE invoice_lines            FORCE ROW LEVEL SECURITY;
ALTER TABLE invoice_vat_breakdowns   FORCE ROW LEVEL SECURITY;
ALTER TABLE invoice_attachments      FORCE ROW LEVEL SECURITY;
ALTER TABLE invoice_audit            FORCE ROW LEVEL SECURITY;

-- 2. Policies. One FOR ALL policy per table that covers SELECT / INSERT
--    / UPDATE / DELETE with identical USING and WITH CHECK predicates.
--    Re-running this file is safe: we DROP IF EXISTS first.

DROP POLICY IF EXISTS parties_org_isolation ON parties;
CREATE POLICY parties_org_isolation ON parties
    FOR ALL
    TO PUBLIC
    USING      (org_id = current_setting('app.org_id', true)::uuid)
    WITH CHECK (org_id = current_setting('app.org_id', true)::uuid);

DROP POLICY IF EXISTS invoices_org_isolation ON invoices;
CREATE POLICY invoices_org_isolation ON invoices
    FOR ALL
    TO PUBLIC
    USING      (org_id = current_setting('app.org_id', true)::uuid)
    WITH CHECK (org_id = current_setting('app.org_id', true)::uuid);

DROP POLICY IF EXISTS invoice_lines_org_isolation ON invoice_lines;
CREATE POLICY invoice_lines_org_isolation ON invoice_lines
    FOR ALL
    TO PUBLIC
    USING      (org_id = current_setting('app.org_id', true)::uuid)
    WITH CHECK (org_id = current_setting('app.org_id', true)::uuid);

DROP POLICY IF EXISTS invoice_vat_breakdowns_org_isolation ON invoice_vat_breakdowns;
CREATE POLICY invoice_vat_breakdowns_org_isolation ON invoice_vat_breakdowns
    FOR ALL
    TO PUBLIC
    USING      (org_id = current_setting('app.org_id', true)::uuid)
    WITH CHECK (org_id = current_setting('app.org_id', true)::uuid);

DROP POLICY IF EXISTS invoice_attachments_org_isolation ON invoice_attachments;
CREATE POLICY invoice_attachments_org_isolation ON invoice_attachments
    FOR ALL
    TO PUBLIC
    USING      (org_id = current_setting('app.org_id', true)::uuid)
    WITH CHECK (org_id = current_setting('app.org_id', true)::uuid);

DROP POLICY IF EXISTS invoice_audit_org_isolation ON invoice_audit;
CREATE POLICY invoice_audit_org_isolation ON invoice_audit
    FOR ALL
    TO PUBLIC
    USING      (org_id = current_setting('app.org_id', true)::uuid)
    WITH CHECK (org_id = current_setting('app.org_id', true)::uuid);
