// Canonical catalogue of data-store backends the app can target at runtime.
//
// Matches the backend allowlist in `api/_lib/db/types.d.ts` — both sides must
// use the same wire vocabulary (`mongo` | `postgres`).
//
// Display labels may differ from the wire value: Postgres is presented to
// the user as "Supabase" during Sprint 1 because Supabase is the Marketplace
// integration providing the Postgres connection (and matches the owner's
// demo framing).

/// Wire-level enum for the active backend.
///
/// Serialised by `.name` (→ "mongo" / "postgres") when sent as the
/// `X-Data-Source` HTTP header.
enum DataSource { mongo, postgres }

extension DataSourceX on DataSource {
  /// Header value sent to the backend. Must match the allowlist in
  /// `api/_lib/db/types.d.ts` (`DataSource`).
  String get header => name;

  /// User-facing label shown in segmented selectors and "served by" chips.
  String get label => switch (this) {
    DataSource.mongo => 'MongoDB',
    DataSource.postgres => 'Supabase',
  };

  /// Short caption ("Mongo" / "Supabase") for compact chips where the
  /// full brand name would wrap.
  String get shortLabel => switch (this) {
    DataSource.mongo => 'Mongo',
    DataSource.postgres => 'Supabase',
  };
}
