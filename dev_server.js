#!/usr/bin/env node
//
// Local dev proxy for API endpoints.
// Loads .env + .env.local and routes to the Vercel Function handlers under
// `api/*`, including the dynamic `/api/invoices/:id` and `/api/parties/:id`
// routes that Vercel rewrites in production.
//
// Usage:  node dev_server.js
// Then:   flutter run -d chrome --web-port 8080 --web-hostname localhost \
//           --dart-define=TEEDOO_API_BASE_URL=http://localhost:3001/api
//
// The server runs on port 3001 by default.

const http = require('http');
const fs = require('fs');
const path = require('path');

// ── Load .env + .env.local (the latter wins) ─────────────────────────────
function loadEnv(file) {
  const full = path.join(__dirname, file);
  if (!fs.existsSync(full)) return;
  const lines = fs.readFileSync(full, 'utf-8').split('\n');
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const idx = trimmed.indexOf('=');
    if (idx === -1) continue;
    const key = trimmed.slice(0, idx).trim();
    let value = trimmed.slice(idx + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    // .env.local overrides .env.
    process.env[key] = value;
  }
}
loadEnv('.env');
loadEnv('.env.local');

const realtimeHandler = require('./api/realtime/client-secrets.js');
const fiscalHandler = require('./api/fiscal/explain.js');
const healthHandler = require('./api/health.js');
const invoicesIndexHandler = require('./api/invoices/index.js');
const invoicesItemHandler = require('./api/invoices/[id].js');
const partiesIndexHandler = require('./api/parties/index.js');
const partiesItemHandler = require('./api/parties/[id].js');

const PORT = process.env.DEV_SERVER_PORT || 3001;

// ── Route table ──
// `test` is a regex applied to the path (without query string). When the
// regex captures a group, its first capture becomes `req.query[paramName]`
// so the Vercel dynamic-segment contract works the same locally.
const routes = [
  {
    test: /^\/api\/realtime\/client-secrets$/,
    methods: ['POST', 'OPTIONS'],
    handler: realtimeHandler,
  },
  {
    test: /^\/api\/fiscal\/explain$/,
    methods: ['POST', 'OPTIONS'],
    handler: fiscalHandler,
  },
  {
    test: /^\/api\/health$/,
    methods: ['GET', 'OPTIONS'],
    handler: healthHandler,
  },
  {
    test: /^\/api\/invoices\/([^/]+)$/,
    methods: ['GET', 'PATCH', 'DELETE', 'OPTIONS'],
    handler: invoicesItemHandler,
    paramName: 'id',
  },
  {
    test: /^\/api\/invoices$/,
    methods: ['GET', 'POST', 'OPTIONS'],
    handler: invoicesIndexHandler,
  },
  {
    test: /^\/api\/parties\/([^/]+)$/,
    methods: ['GET', 'PATCH', 'DELETE', 'OPTIONS'],
    handler: partiesItemHandler,
    paramName: 'id',
  },
  {
    test: /^\/api\/parties$/,
    methods: ['GET', 'POST', 'OPTIONS'],
    handler: partiesIndexHandler,
  },
];

const ALLOWED_ORIGINS = [
  'http://localhost:8080',
  'http://127.0.0.1:8080',
  'http://localhost:3000',
];

const server = http.createServer(async (req, res) => {
  const origin = req.headers.origin;
  if (origin && ALLOWED_ORIGINS.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  } else if (!origin) {
    res.setHeader('Access-Control-Allow-Origin', '*');
  }
  res.setHeader(
    'Access-Control-Allow-Methods',
    'GET, POST, PATCH, DELETE, OPTIONS',
  );
  res.setHeader(
    'Access-Control-Allow-Headers',
    'Content-Type, Authorization, X-Data-Source',
  );
  res.setHeader('Access-Control-Max-Age', '86400');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const pathOnly = (req.url || '').split('?')[0];
  const match = routes.find((r) => r.test.test(pathOnly));
  if (!match) {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: { message: 'Not found' } }));
    return;
  }
  if (!match.methods.includes(req.method)) {
    res.writeHead(405, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: { message: 'Method Not Allowed' } }));
    return;
  }

  // Populate req.query with captured segment so the shared helpers in
  // api/_lib/http.js (extractPathId) find the id in `req.query[paramName]`.
  if (match.paramName) {
    const captured = pathOnly.match(match.test);
    const value =
      captured && captured[1] ? decodeURIComponent(captured[1]) : '';
    req.query = Object.assign({}, req.query, { [match.paramName]: value });
  }

  try {
    await match.handler(req, res);
  } catch (err) {
    console.error(`Handler error [${req.url}]:`, err);
    if (!res.headersSent) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: { message: err.message } }));
    }
  }
});

server.listen(PORT, () => {
  console.log(`\n  Dev API server running on http://localhost:${PORT}`);
  console.log(`  Routes:`);
  for (const r of routes) {
    console.log(`    ${r.methods.join('/').padEnd(24)} ${r.test}`);
  }
  console.log(
    `  DATA_SOURCE:    ${process.env.DATA_SOURCE || '(unset — request must send X-Data-Source)'}`,
  );
  console.log(
    `  MONGODB_URI:    ${process.env.MONGODB_URI ? '*** set' : 'NOT SET'}`,
  );
  console.log(
    `  POSTGRES_URL:   ${process.env.POSTGRES_URL ? '*** set' : 'NOT SET'}`,
  );
  console.log(
    `  OPENAI_API_KEY: ${process.env.OPENAI_API_KEY ? '*** set' : 'NOT SET'}\n`,
  );
});
