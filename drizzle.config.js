require('dotenv').config({ path: '.env.local' });

/** @type {import('drizzle-kit').Config} */
module.exports = {
  schema: './api/_lib/db/mysql/schema/index.js',
  out: './api/_lib/db/mysql/migrations',
  dialect: 'mysql',
  dbCredentials: {
    url: process.env.MYSQL_URL,
  },
  verbose: true,
  strict: true,
};
