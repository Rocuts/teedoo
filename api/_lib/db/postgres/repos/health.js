const { sql } = require('drizzle-orm');
const { getPostgres } = require('../client');
const { DbError } = require('../../errors');

/** @returns {import('../../types').HealthRepository} */
function createHealthRepo() {
  return {
    async ping() {
      const start = Date.now();
      try {
        const { db } = getPostgres();
        await db.execute(sql`SELECT 1`);
        return { ok: true, backend: 'postgres', latencyMs: Date.now() - start };
      } catch (err) {
        throw new DbError('Postgres ping failed', { cause: err });
      }
    },
  };
}

module.exports = { createHealthRepo };
