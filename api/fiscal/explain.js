const OPENAI_URL = 'https://api.openai.com/v1/chat/completions';

function json(res, status, body) {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Cache-Control', 'no-store');
  res.end(JSON.stringify(body));
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (chunk) => { data += chunk; });
    req.on('end', () => resolve(data));
    req.on('error', reject);
  });
}

// ─────────────────────────────────────────────────────────────────────
// SYSTEM PROMPT — OpenAI SOLO redacta, NUNCA decide fiscalidad
// ─────────────────────────────────────────────────────────────────────
const SYSTEM_PROMPT = `Eres un redactor fiscal profesional especializado en normativa tributaria española.
Tu ÚNICA función es transformar hallazgos fiscales YA DETERMINADOS por un sistema automatizado en explicaciones claras, profesionales y comprensibles.

REGLAS ABSOLUTAS:
1. NO determines si una deducción aplica o no. Esa decisión ya fue tomada por el motor de reglas.
2. NO inventes artículos de ley, consultas vinculantes ni criterios que NO estén en el campo "legalReference" del input.
3. NO agregues recomendaciones fiscales más allá de las indicadas en "actionRequired".
4. SOLO cita la base normativa proporcionada en "legalReference".
5. Si "confidenceLevel" es "low", menciona explícitamente que requiere validación profesional.
6. Usa tono formal pero comprensible para un empresario no especialista.
7. Responde SIEMPRE en español de España.
8. NO uses emojis.
9. Si no puedes generar una explicación fiel al input, pon "valid": false y explica por qué en "rejectionReason".

ESTRUCTURA DE RESPUESTA:
- summary: resumen de 1-2 líneas del hallazgo
- detail: explicación completa de 3-4 párrafos
- legalCitation: SOLO la referencia legal del input, textual
- nextSteps: pasos concretos basados en "actionRequired" del input
- confidenceNote: nota sobre nivel de certeza
- disclaimer: advertencia legal estándar

Responde en JSON válido.`;

// ─────────────────────────────────────────────────────────────────────
// Build user prompt from structured input
// ─────────────────────────────────────────────────────────────────────
function buildUserPrompt(payload) {
  return `Redacta una justificación fiscal profesional para el siguiente hallazgo determinado por el sistema:

REGLA: ${payload.ruleName}
REFERENCIA LEGAL: ${payload.legalReference}
EJERCICIO FISCAL: ${payload.fiscalYear}
COMUNIDAD AUTÓNOMA: ${payload.autonomousCommunity || 'No especificada'}
AHORRO ESTIMADO: ${Number(payload.estimatedSaving).toFixed(2)} EUR
NIVEL DE CONFIANZA: ${payload.confidenceLevel || 'medium'}
NIVEL DE RIESGO: ${payload.riskLevel || 'low'}

ANÁLISIS DEL MOTOR DE REGLAS:
${payload.ruleExplanation}

ACCIÓN REQUERIDA:
${payload.actionRequired || 'Consultar con asesor fiscal.'}

IMPORTANTE: Solo puedes citar "${payload.legalReference}" como base normativa. No inventes otros artículos.
Responde en JSON con campos: valid, summary, detail, legalCitation, nextSteps, confidenceNote, disclaimer.`;
}

// ─────────────────────────────────────────────────────────────────────
// Payload validation
// ─────────────────────────────────────────────────────────────────────
function validatePayload(payload) {
  const required = ['ruleName', 'ruleExplanation', 'legalReference', 'estimatedSaving', 'fiscalYear'];
  const missing = required.filter((key) => payload[key] == null);
  if (missing.length > 0) return `Campos requeridos faltantes: ${missing.join(', ')}`;
  if (typeof payload.estimatedSaving !== 'number') return 'estimatedSaving debe ser un número.';
  if (typeof payload.fiscalYear !== 'number') return 'fiscalYear debe ser un número.';
  return null;
}

// ─────────────────────────────────────────────────────────────────────
// POST-VALIDATION — Anti-alucinación
// Verifica que OpenAI no inventó fundamentos legales
// ─────────────────────────────────────────────────────────────────────
function postValidate(input, output) {
  const errors = [];

  // 1. Verificar que legalCitation coincide con el input
  if (output.legalCitation) {
    const inputRef = (input.legalReference || '').toLowerCase();
    const outputRef = output.legalCitation.toLowerCase();
    // Extraer número de artículo del input
    const inputArtMatch = inputRef.match(/art[^\d]*(\d+)/);
    if (inputArtMatch && !outputRef.includes(inputArtMatch[1])) {
      errors.push('LEGAL_CITATION_MISMATCH: La cita legal no coincide con el input');
    }
  }

  // 2. Buscar artículos en el detail que no estén en el input
  if (output.detail) {
    const detailArticles = (output.detail.match(/art[íi]culo?\s+(\d+)/gi) || [])
      .map(a => (a.match(/\d+/) || [''])[0]).filter(Boolean);
    const inputArticles = ((input.legalReference || '').match(/art[íi]culo?\s+(\d+)/gi) || [])
      .map(a => (a.match(/\d+/) || [''])[0]).filter(Boolean);

    const hallucinated = detailArticles.filter(a => !inputArticles.includes(a));
    if (hallucinated.length > 0) {
      errors.push(`HALLUCINATED_ARTICLES: Artículos inventados: ${hallucinated.join(', ')}`);
    }
  }

  // 3. Verificar que el ahorro mencionado es coherente
  if (output.summary && input.estimatedSaving > 0) {
    const savingStr = Number(input.estimatedSaving).toFixed(2).replace('.', ',');
    const savingStrAlt = Number(input.estimatedSaving).toFixed(2);
    const summaryHasSaving = output.summary.includes(savingStr) ||
      output.summary.includes(savingStrAlt) ||
      output.summary.includes(Math.round(input.estimatedSaving).toString());
    if (!summaryHasSaving) {
      errors.push('SAVINGS_MISMATCH: El ahorro citado no coincide con el input');
    }
  }

  // 4. Verificar que confianza baja se refleja
  if (input.confidenceLevel === 'low' && output.detail) {
    const detail = output.detail.toLowerCase();
    if (!detail.includes('revisión') && !detail.includes('profesional') && !detail.includes('asesor')) {
      errors.push('LOW_CONFIDENCE_NOT_FLAGGED');
    }
  }

  const hasCritical = errors.some(e =>
    e.startsWith('HALLUCINATED') || e.startsWith('LEGAL_CITATION_MISMATCH')
  );

  return {
    valid: errors.length === 0,
    errors,
    severity: hasCritical ? 'critical' : 'warning',
  };
}

// ─────────────────────────────────────────────────────────────────────
// Handler
// ─────────────────────────────────────────────────────────────────────
module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return json(res, 405, { error: { message: 'Method Not Allowed' } });
  }

  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    return json(res, 500, { error: { message: 'OPENAI_API_KEY no está configurada.' } });
  }

  // Parse body
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

  // Validate input
  const validationError = validatePayload(payload);
  if (validationError) {
    return json(res, 400, { error: { message: validationError } });
  }

  const userPrompt = buildUserPrompt(payload);
  const startTime = Date.now();

  // ── Call OpenAI ──
  const callOpenAI = async (attempt) => {
    const response = await fetch(OPENAI_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        temperature: 0.1,       // Muy baja — salidas controladas
        max_tokens: 1200,
        response_format: { type: 'json_object' },
        messages: [
          { role: 'system', content: SYSTEM_PROMPT },
          { role: 'user', content: userPrompt },
        ],
      }),
    });

    const text = await response.text();
    if (!response.ok) {
      let errorBody;
      try { errorBody = JSON.parse(text); } catch { errorBody = { error: { message: text } }; }
      throw new Error(errorBody.error?.message || `OpenAI HTTP ${response.status}`);
    }

    const body = JSON.parse(text);
    const content = body.choices?.[0]?.message?.content;
    if (!content) throw new Error('Respuesta vacía de OpenAI');

    const parsed = JSON.parse(content);
    return {
      parsed,
      model: body.model,
      tokens: body.usage?.total_tokens || 0,
    };
  };

  try {
    // Intento 1
    let result = await callOpenAI(1);
    let validation = postValidate(payload, result.parsed);

    // Si hay errores críticos, reintentar una vez
    if (!validation.valid && validation.severity === 'critical') {
      console.warn(`[fiscal/explain] Attempt 1 rejected:`, validation.errors);
      try {
        result = await callOpenAI(2);
        validation = postValidate(payload, result.parsed);
      } catch (retryErr) {
        console.error(`[fiscal/explain] Retry failed:`, retryErr.message);
      }
    }

    // Si sigue con errores críticos después del reintento, rechazar
    if (!validation.valid && validation.severity === 'critical') {
      console.error(`[fiscal/explain] REJECTED after 2 attempts:`, validation.errors);
      return json(res, 422, {
        error: {
          message: 'La explicación generada no pasó la validación de coherencia.',
          details: validation.errors,
        },
        // Devolver la explicación del motor de reglas como fallback
        fallbackExplanation: payload.ruleExplanation,
      });
    }

    const elapsed = Date.now() - startTime;

    // Log de auditoría
    console.log(JSON.stringify({
      type: 'fiscal_explanation',
      ruleName: payload.ruleName,
      model: result.model,
      tokens: result.tokens,
      elapsed_ms: elapsed,
      validation_valid: validation.valid,
      validation_errors: validation.errors,
      timestamp: new Date().toISOString(),
    }));

    // Construir respuesta
    const output = result.parsed;
    return json(res, 200, {
      explanation: [
        output.summary || '',
        '',
        output.detail || '',
        '',
        `Referencia legal: ${output.legalCitation || payload.legalReference}`,
        '',
        `Próximos pasos: ${output.nextSteps || ''}`,
        '',
        output.confidenceNote || '',
        '',
        output.disclaimer || 'Este análisis es orientativo y no sustituye el asesoramiento fiscal profesional.',
      ].join('\n').trim(),
      keyPoints: [
        output.summary,
        `Ahorro estimado: ${Number(payload.estimatedSaving).toFixed(2)} EUR`,
        `Base legal: ${payload.legalReference}`,
      ].filter(Boolean),
      disclaimer: output.disclaimer || 'Este análisis es orientativo y no sustituye el asesoramiento fiscal profesional.',
      metadata: {
        model: result.model,
        tokens: result.tokens,
        elapsed_ms: elapsed,
        validation: validation,
      },
    });

  } catch (err) {
    console.error('[fiscal/explain] Error:', err.message);
    return json(res, 502, {
      error: { message: `Error al generar explicación: ${err.message}` },
      fallbackExplanation: payload.ruleExplanation,
    });
  }
};
