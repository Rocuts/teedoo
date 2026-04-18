/**
 * Index bootstrap for the TeeDoo Mongo collections.
 *
 * Usage (from any repo constructor):
 *   await ensureIndexes(db);
 *
 * The function is idempotent (Mongo's `createIndex` is a no-op when the index
 * already exists with the same spec) and per-instance-cached: a process that
 * handles many concurrent requests only pays the bootstrap cost once.
 *
 * Notes:
 *  - Indexes are built in background on Atlas by default (mongod 4.2+), so
 *    calling this on cold start does not block other operations.
 *  - Every compound index is prefixed with `orgId` because every repo method
 *    filters by tenant. This keeps a single index usable for the cheap
 *    "give me everything for this org" query AND for the more specific
 *    filters below (index prefix rule).
 */

const CACHE_KEY = Symbol.for('teedoo.mongo.indexes');

/** @type {Record<string, Array<{ keys: Record<string, 1 | -1>, options?: object }>>} */
const SPECS = {
  parties: [
    { keys: { orgId: 1, taxId: 1 }, options: { unique: true, name: 'uniq_org_taxId' } },
    { keys: { orgId: 1, name: 1 }, options: { name: 'org_name' } },
  ],
  invoices: [
    {
      keys: { orgId: 1, series: 1, number: 1 },
      options: { unique: true, name: 'uniq_org_series_number' },
    },
    { keys: { orgId: 1, issueDate: -1 }, options: { name: 'org_issueDate_desc' } },
    {
      keys: { orgId: 1, status: 1, issueDate: -1 },
      options: { name: 'org_status_issueDate_desc' },
    },
    { keys: { orgId: 1, issuerId: 1 }, options: { name: 'org_issuer' } },
    { keys: { orgId: 1, recipientId: 1 }, options: { name: 'org_recipient' } },
    // Cursor pagination sort key: createdAt DESC, then _id as tiebreaker.
    { keys: { orgId: 1, createdAt: -1, _id: -1 }, options: { name: 'org_createdAt_desc_id' } },
  ],
};

/**
 * Guarantees every index in `SPECS` exists on the given `db`. Safe to call on
 * every request — work is done exactly once per process (keyed on the
 * underlying `MongoClient.topology.id` so a reconnect refreshes the cache).
 *
 * @param {import('mongodb').Db} db
 * @returns {Promise<void>}
 */
async function ensureIndexes(db) {
  const bucket = globalThis[CACHE_KEY] || (globalThis[CACHE_KEY] = new Map());

  // Derive a stable cache key per client so that if the cached client gets
  // replaced (e.g. after a crash + reconnect) we rebuild the indexes.
  const topologyId =
    (db && db.client && db.client.topology && db.client.topology.s && db.client.topology.s.id) ||
    db.databaseName;

  if (bucket.has(topologyId)) return bucket.get(topologyId);

  const promise = (async () => {
    for (const [collectionName, specs] of Object.entries(SPECS)) {
      const col = db.collection(collectionName);
      for (const spec of specs) {
        await col.createIndex(spec.keys, spec.options || {});
      }
    }
  })();

  bucket.set(topologyId, promise);

  try {
    await promise;
  } catch (err) {
    // On failure, evict the cache entry so a subsequent call retries.
    bucket.delete(topologyId);
    throw err;
  }
}

module.exports = { ensureIndexes };
