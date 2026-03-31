const OPENAI_URL = 'https://api.openai.com/v1/realtime/client_secrets';

function json(res, status, body) {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Cache-Control', 'no-store');
  res.end(JSON.stringify(body));
}

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

function sanitizeSession(session = {}) {
  const sanitized = {
    type: 'realtime',
    model: typeof session.model === 'string' ? session.model : 'gpt-realtime',
    instructions:
      typeof session.instructions === 'string' ? session.instructions : '',
    audio: session.audio && typeof session.audio === 'object'
      ? session.audio
      : { output: { voice: 'coral' } },
    tools: Array.isArray(session.tools) ? session.tools : [],
  };
  return sanitized;
}

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return json(res, 405, { error: { message: 'Method Not Allowed' } });
  }

  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    return json(res, 500, {
      error: { message: 'OPENAI_API_KEY no está configurada en el servidor.' },
    });
  }

  let payload = {};
  try {
    if (req.body && typeof req.body === 'object') {
      payload = req.body;
    } else {
      const raw = await readBody(req);
      payload = raw ? JSON.parse(raw) : {};
    }
  } catch {
    return json(res, 400, { error: { message: 'JSON inválido.' } });
  }

  const session = sanitizeSession(payload.session);

  try {
    const upstream = await fetch(OPENAI_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ session }),
    });

    const text = await upstream.text();
    let body;
    try {
      body = JSON.parse(text);
    } catch {
      body = { error: { message: text || 'Respuesta no JSON del upstream.' } };
    }

    return json(res, upstream.status, body);
  } catch {
    return json(res, 502, {
      error: { message: 'No se pudo contactar con OpenAI.' },
    });
  }
};
