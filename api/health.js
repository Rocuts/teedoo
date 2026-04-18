const { getRepositories } = require('./_lib/db/factory');

function json(res, status, body) {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Cache-Control', 'no-store');
  res.end(JSON.stringify(body));
}

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return json(res, 405, { error: { message: 'Method Not Allowed' } });
  }

  try {
    const { health } = getRepositories();
    const result = await health.ping();
    return json(res, 200, result);
  } catch (err) {
    return json(res, 500, {
      error: { message: err.message, code: err.code || 'INTERNAL' },
    });
  }
};
