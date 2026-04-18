/**
 * HTTP helpers shared across the Vercel Functions layer.
 *
 * Every domain handler (invoices, parties, seed, ...) pulls from here so
 * the wire shape stays consistent and matches what `api/fiscal/explain.js`
 * already uses. Kept intentionally small — no middleware framework, no
 * Express — because Vercel Functions on Fluid Compute are single handlers
 * receiving bare (req, res).
 */

const {
  NotFoundError,
  ConflictError,
  ValidationError,
  DbError,
} = require('./db/errors');

const VALID_DATA_SOURCES = new Set(['mongo', 'postgres']);

/**
 * Write a JSON response. Mutations should never be cached, so the default
 * `Cache-Control: no-store` applies to every response. Callers can override
 * by setting the header before calling `json()` on the shared res — but
 * that is rare.
 */
function json(res, status, body) {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Cache-Control', 'no-store');
  res.end(JSON.stringify(body));
}

/**
 * Consume the request body stream into a raw string. Vercel sometimes
 * pre-parses the body onto `req.body`; handlers should prefer
 * `parseJsonBody` which handles both cases.
 */
function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (chunk) => {
      data += chunk;
    });
    req.on('end', () => resolve(data));
    req.on('error', reject);
  });
}

/**
 * Parse JSON body. Returns `null` for empty bodies. Throws a `ValidationError`
 * when the body is present but not valid JSON — handlers catch and turn it
 * into a 400.
 */
async function parseJsonBody(req) {
  if (req.body && typeof req.body === 'object') return req.body;
  const raw = await readBody(req);
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch {
    throw new ValidationError('Invalid JSON body');
  }
}

/**
 * Resolve the requested data source from the `X-Data-Source` header.
 *   - Absent → returns `null` (handler falls back to env-level DATA_SOURCE).
 *   - Valid ('mongo' | 'postgres') → returned as-is.
 *   - Invalid → throws ValidationError (handler turns it into a 400).
 */
function getDataSource(req) {
  const raw = req.headers['x-data-source'];
  if (raw === undefined || raw === null || raw === '') return null;
  const normalized = String(raw).toLowerCase();
  if (!VALID_DATA_SOURCES.has(normalized)) {
    throw new ValidationError('Invalid X-Data-Source');
  }
  return normalized;
}

/**
 * Emit the permissive CORS preamble every API handler needs for the Flutter
 * Web dev build served on a different origin (localhost:8080 / localhost:3000)
 * than the Vercel Functions (localhost:3001 / *.vercel.app).
 *
 * Used for both OPTIONS preflights and normal 2xx/4xx responses.
 */
function setCorsHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, DELETE, OPTIONS');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'Content-Type, Authorization, X-Data-Source',
  );
  res.setHeader('Access-Control-Max-Age', '86400');
}

/**
 * Returns true and writes the 204 preflight response when the request is an
 * OPTIONS call. Handlers should short-circuit on `true`.
 */
function handlePreflight(req, res) {
  if (req.method !== 'OPTIONS') return false;
  setCorsHeaders(res);
  res.statusCode = 204;
  res.end();
  return true;
}

/**
 * Map domain errors to HTTP. SQL strings, driver codes, connection URIs, and
 * stack traces are NEVER propagated to the client — we log them server-side
 * and return a generic 500 instead.
 */
function handleError(res, err, context = 'handler') {
  if (err instanceof NotFoundError) {
    return json(res, 404, {
      error: { message: err.message, code: err.code, entity: err.entity },
    });
  }
  if (err instanceof ValidationError) {
    return json(res, 400, {
      error: {
        message: err.message,
        code: err.code,
        field: err.field,
      },
    });
  }
  if (err instanceof ConflictError) {
    return json(res, 409, {
      error: { message: err.message, code: err.code, field: err.field },
    });
  }
  if (err instanceof DbError) {
    // Swallow the SQL / driver detail; log it for Vercel Observability.
    console.error(`[${context}] DbError:`, err.message, err.cause?.message || '');
    return json(res, 500, { error: { message: 'Internal database error' } });
  }
  // Unknown error: log everything, return generic message.
  console.error(`[${context}] Unexpected error:`, err.message);
  if (err.stack) console.error(err.stack);
  return json(res, 500, { error: { message: 'Internal server error' } });
}

/**
 * Extract a single path parameter from the request URL.
 * Works with both Vercel's `req.query` (when available) and raw path parsing.
 */
function extractPathId(req, segment) {
  // Vercel populates req.query with dynamic segment values.
  if (req.query && typeof req.query === 'object') {
    const fromQuery = req.query.id ?? req.query[segment];
    if (typeof fromQuery === 'string' && fromQuery) return fromQuery;
    if (Array.isArray(fromQuery) && fromQuery[0]) return fromQuery[0];
  }
  // Fallback: parse the URL ourselves. We look at the last non-empty
  // path segment, dropping any query string.
  const url = req.url || '';
  const pathOnly = url.split('?')[0];
  const segments = pathOnly.split('/').filter(Boolean);
  return segments[segments.length - 1] || '';
}

module.exports = {
  json,
  readBody,
  parseJsonBody,
  getDataSource,
  setCorsHeaders,
  handlePreflight,
  handleError,
  extractPathId,
  VALID_DATA_SOURCES,
};
