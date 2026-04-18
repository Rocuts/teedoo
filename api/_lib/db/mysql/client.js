const mysql = require('mysql2/promise');
const { drizzle } = require('drizzle-orm/mysql2');

const CACHE_KEY = Symbol.for('teedoo.mysql.client');

function getEnv() {
  const url = process.env.MYSQL_URL;
  if (!url) throw new Error('MYSQL_URL is not set.');
  return { url };
}

/**
 * Returns a cached { pool, db } pair. `pool` is a mysql2 connection pool
 * reused across Fluid Compute invocations; `db` is the Drizzle ORM wrapper.
 *
 * @returns {{ pool: import('mysql2/promise').Pool, db: ReturnType<typeof drizzle> }}
 */
function getMysql() {
  const cached = globalThis[CACHE_KEY];
  if (cached) return cached;

  const { url } = getEnv();

  const pool = mysql.createPool({
    uri: url,
    connectionLimit: 10,
    waitForConnections: true,
    enableKeepAlive: true,
    keepAliveInitialDelay: 10_000,
    connectTimeout: 10_000,
  });

  const db = drizzle(pool, { mode: 'default' });

  const value = { pool, db };
  globalThis[CACHE_KEY] = value;
  return value;
}

module.exports = { getMysql };
