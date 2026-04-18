// Hard-coded active organisation id for Sprint 1.
//
// Phase 2 of the dual-DB capture assumes a single tenant while we stabilise
// the repository layer, parties normalisation and the runtime DB switch.
// Phase 3 will replace this with a `currentOrgProvider` backed by the auth
// session (JWT claim `org_id`) and a tenant picker in the topbar.
//
// IMPORTANT: this UUID MUST match the seed row inserted by the backend
// bootstrap script (see `api/_lib/db/seed/*`). Do NOT invent a new value
// without coordinating with teedoo-api-backend.

/// Active organisation id used by all Flutter → API calls until Phase 3.
///
/// Stable UUID v4 — pick the same value when seeding Mongo and Postgres so
/// the `X-Data-Source` switch is transparent.
const String activeOrgId = '00000000-0000-4000-8000-000000000001';
