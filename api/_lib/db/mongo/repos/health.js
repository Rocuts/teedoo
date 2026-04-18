const { getMongo } = require('../client');
const { DbError } = require('../../errors');

/** @returns {import('../../types').HealthRepository} */
function createHealthRepo() {
  return {
    async ping() {
      const start = Date.now();
      try {
        const { db } = await getMongo();
        await db.command({ ping: 1 });
        return { ok: true, backend: 'mongo', latencyMs: Date.now() - start };
      } catch (err) {
        throw new DbError('Mongo ping failed', { cause: err });
      }
    },
  };
}

module.exports = { createHealthRepo };
