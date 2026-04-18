const { MongoClient } = require('mongodb');

const CACHE_KEY = Symbol.for('teedoo.mongo.client');

function getEnv() {
  const uri = process.env.MONGODB_URI;
  // Atlas Marketplace does not inject MONGODB_DB — default to "teedoo",
  // override via env if a different database name is needed.
  const dbName = process.env.MONGODB_DB || 'teedoo';
  if (!uri) throw new Error('MONGODB_URI is not set.');
  return { uri, dbName };
}

/**
 * Returns a cached { client, db } pair. Under Fluid Compute, the same function
 * instance handles many concurrent requests; we cache on globalThis so the
 * MongoClient (and its connection pool) survives across invocations.
 *
 * @returns {Promise<{ client: import('mongodb').MongoClient, db: import('mongodb').Db }>}
 */
async function getMongo() {
  const cache = globalThis[CACHE_KEY];
  if (cache && cache.promise) return cache.promise;

  const { uri, dbName } = getEnv();

  const promise = (async () => {
    const client = new MongoClient(uri, {
      maxPoolSize: 10,
      minPoolSize: 0,
      maxIdleTimeMS: 60_000,
      serverSelectionTimeoutMS: 10_000,
      retryWrites: true,
    });
    await client.connect();
    return { client, db: client.db(dbName) };
  })();

  globalThis[CACHE_KEY] = { promise };

  try {
    return await promise;
  } catch (err) {
    globalThis[CACHE_KEY] = null;
    throw err;
  }
}

module.exports = { getMongo };
