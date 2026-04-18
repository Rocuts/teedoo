const { sql } = require('drizzle-orm');
const { getMysql } = require('../client');
const { DbError } = require('../../errors');

/** @returns {import('../../types').HealthRepository} */
function createHealthRepo() {
  return {
    async ping() {
      const start = Date.now();
      try {
        const { db } = getMysql();
        await db.execute(sql`SELECT 1`);
        return { ok: true, backend: 'mysql', latencyMs: Date.now() - start };
      } catch (err) {
        throw new DbError('MySQL ping failed', { cause: err });
      }
    },
  };
}

module.exports = { createHealthRepo };
