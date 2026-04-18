/**
 * Session / tenancy context.
 *
 * Sprint 1: auth is not wired yet. Every handler scopes DB work to a
 * hardcoded demo org. Replace with real auth (Supabase / Clerk / JWT)
 * once the login flow lands — at that point, `activeOrgId` becomes a
 * per-request value resolved from the verified token, not a module-
 * level constant.
 */

// UUID v4 (RFC 4122). Chosen because Postgres `parties.org_id` is a
// `uuid` column and the Postgres repos assert UUID format.
const activeOrgId = '00000000-0000-4000-8000-000000000001';

module.exports = { activeOrgId };
