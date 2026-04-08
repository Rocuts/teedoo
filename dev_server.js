#!/usr/bin/env node
//
// Local dev proxy for API endpoints.
// Reads OPENAI_API_KEY from .env and proxies to Vercel serverless functions.
//
// Usage:  node dev_server.js
// Then run Flutter with: flutter run -d chrome --web-port 8080 --web-hostname localhost
//
// The server runs on port 3001 by default.

const http = require('http');
const fs = require('fs');
const path = require('path');

// ── Load .env ──
const envPath = path.join(__dirname, '.env');
if (fs.existsSync(envPath)) {
  const lines = fs.readFileSync(envPath, 'utf-8').split('\n');
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const idx = trimmed.indexOf('=');
    if (idx === -1) continue;
    const key = trimmed.slice(0, idx).trim();
    const value = trimmed.slice(idx + 1).trim();
    if (!process.env[key]) process.env[key] = value;
  }
}

const realtimeHandler = require('./api/realtime/client-secrets.js');
const fiscalHandler = require('./api/fiscal/explain.js');

const PORT = process.env.DEV_SERVER_PORT || 3001;

// ── Route table ──
const routes = {
  '/api/realtime/client-secrets': realtimeHandler,
  '/api/fiscal/explain': fiscalHandler,
};

const server = http.createServer(async (req, res) => {
  // CORS headers — restricted to local Flutter dev server origins only
  const allowedOrigins = ['http://localhost:8080', 'http://127.0.0.1:8080'];
  const origin = req.headers.origin;
  if (allowedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  }
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const handler = routes[req.url];
  if (handler) {
    try {
      await handler(req, res);
    } catch (err) {
      console.error(`Handler error [${req.url}]:`, err);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: { message: err.message } }));
    }
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: { message: 'Not found' } }));
  }
});

server.listen(PORT, () => {
  console.log(`\n  Dev API server running on http://localhost:${PORT}`);
  console.log(`  Routes:`);
  for (const route of Object.keys(routes)) {
    console.log(`    POST http://localhost:${PORT}${route}`);
  }
  console.log(`  OPENAI_API_KEY: ${process.env.OPENAI_API_KEY ? '***redacted' : 'NOT SET'}\n`);
});
