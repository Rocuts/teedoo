const mongoHealth = require('./mongo/repos/health');
const postgresHealth = require('./postgres/repos/health');

const VALID_SOURCES = new Set(['mongo', 'postgres']);

function resolveSource(domain, overrides = {}) {
  const override = overrides[domain] || process.env[`DATA_SOURCE_${domain.toUpperCase()}`];
  const source = override || process.env.DATA_SOURCE;
  if (!source) throw new Error('DATA_SOURCE is not set (expected "mongo" or "postgres").');
  if (!VALID_SOURCES.has(source)) throw new Error(`Invalid DATA_SOURCE="${source}".`);
  return source;
}

const BUILDERS = {
  health: {
    mongo: mongoHealth.createHealthRepo,
    postgres: postgresHealth.createHealthRepo,
  },
};

/**
 * Build repositories for the current request. Each domain resolves its own
 * backend from DATA_SOURCE (or per-domain DATA_SOURCE_<DOMAIN> overrides),
 * so hybrid deployments (some domains on Mongo, others on Postgres) work.
 *
 * @param {import('./types').FactoryOptions} [opts]
 * @returns {import('./types').Repositories}
 */
function getRepositories(opts = {}) {
  const overrides = opts.overrides || {};
  const repos = {};
  for (const domain of Object.keys(BUILDERS)) {
    const source = resolveSource(domain, overrides);
    repos[domain] = BUILDERS[domain][source]();
  }
  return repos;
}

module.exports = { getRepositories };
