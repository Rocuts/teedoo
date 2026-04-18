require('dotenv').config({ path: '.env.local' });

/** @type {import('drizzle-kit').Config} */
module.exports = {
  schema: './api/_lib/db/postgres/schema/index.js',
  out: './api/_lib/db/postgres/migrations',
  dialect: 'postgresql',
  dbCredentials: {
    // Use the direct (non-pooled) connection for migrations. pgbouncer in
    // transaction mode breaks DDL / multi-statement scripts.
    url: process.env.POSTGRES_URL_NON_POOLING || process.env.POSTGRES_URL,
  },
  verbose: true,
  strict: true,
};
