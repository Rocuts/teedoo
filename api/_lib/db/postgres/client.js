const postgres = require('postgres');
const { drizzle } = require('drizzle-orm/postgres-js');

const CACHE_KEY = Symbol.for('teedoo.postgres.client');

function getEnv() {
  // POSTGRES_URL is the Supabase-pooled connection (pgbouncer, port 6543).
  // POSTGRES_URL_NON_POOLING is the direct connection (port 5432) — only for
  // migrations and long transactions. Runtime code always uses the pooled URL.
  const url = process.env.POSTGRES_URL;
  if (!url) throw new Error('POSTGRES_URL is not set.');
  return { url };
}

/**
 * Returns a cached { sql, db } pair. `sql` is a postgres-js client with its
 * own internal pool; `db` is the Drizzle ORM wrapper. Cached on globalThis so
 * Fluid Compute reuses the warm connection across invocations.
 *
 * @returns {{ sql: import('postgres').Sql, db: ReturnType<typeof drizzle> }}
 */
function getPostgres() {
  const cached = globalThis[CACHE_KEY];
  if (cached) return cached;

  const { url } = getEnv();

  const sql = postgres(url, {
    max: 10,
    idle_timeout: 60,
    connect_timeout: 10,
    prepare: false, // pgbouncer in transaction mode does not support prepared statements
  });

  const db = drizzle(sql);

  const value = { sql, db };
  globalThis[CACHE_KEY] = value;
  return value;
}

module.exports = { getPostgres };
