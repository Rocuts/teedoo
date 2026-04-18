# TeeDoo Agent Team

Especialistas Claude Code para TeeDoo, todos corriendo **Opus 4.7** (`model: opus`).

Cada agente conoce el proyecto de 0 a 100: stack Flutter + Vercel Functions, Clean Architecture, compliance fiscal español, design system violeta glassmórfico, e iniciativa activa de dual-database (MongoDB Atlas + Neon Postgres con switch runtime).

## Roster

| # | Agente | Especialidad | Invocar cuando... |
|---|---|---|---|
| 1 | `teedoo-architect` | Coordinador / arquitectura whole-stack | Una tarea cruza múltiples capas. Empieza aquí si no sabes a quién delegar. |
| 2 | `teedoo-flutter-frontend` | Flutter/Dart, Riverpod, GoRouter, Dio, theme | Cambios dentro de `lib/` — screens, providers, widgets, navegación. |
| 3 | `teedoo-api-backend` | Vercel Functions Node.js, Fluid Compute | Cambios en `/api/*` — handlers, validación, OpenAI, streaming. |
| 4 | `teedoo-db-switcher` | Dual-DB abstraction, DATA_SOURCE switch, DI | Diseño de la capa de repositorios o del factory de switch. |
| 5 | `teedoo-mongodb` | MongoDB Atlas (Vercel Marketplace) | Esquemas Mongo, índices, pipelines, repos `_lib/db/mongo/`. |
| 6 | `teedoo-postgres-neon` | Neon Postgres (Vercel Marketplace) + Drizzle ORM | Esquemas Postgres, migraciones, queries tipadas, repos `_lib/db/postgres/`. |
| 7 | `teedoo-vercel-platform` | vercel.ts/vercel.json, env vars, Marketplace, CI/CD, CSP | Deploy config, provisioning, env sync, seguridad headers. |
| 8 | `teedoo-fiscal-compliance` | TicketBAI, Verifactu, SII 2026, anti-alucinación IA | Reglas fiscales, prompts OpenAI, validadores post-IA. |
| 9 | `teedoo-design-system` | Colores, tipografía, spacing, glassmorphism, motion | Tokens, parity dark/light, consistencia visual. |
| 10 | `teedoo-code-reviewer` | Review cross-stack: calidad, seguridad, perf, parity | Antes de mergear cualquier cambio no-trivial. |
| 11 | `teedoo-invoice-forms` | Formulario de factura dual-DB (Mongo + MySQL), 2 modelos Dart, selector de backend | Cualquier trabajo end-to-end sobre la captura de facturas. |

## Cómo invocar

Desde dentro de Claude Code, usa el tool `Agent` con `subagent_type` apuntando al nombre del agente:

```
Agent(subagent_type: "teedoo-architect", prompt: "...")
Agent(subagent_type: "teedoo-db-switcher", prompt: "...")
```

O referéncialos por nombre cuando hables con Claude:
> "Pásale esto al `teedoo-mongodb`, quiero que diseñe el schema de audit_events."

## Flujo de trabajo típico

```
Usuario pide una feature que toca frontend + backend + DB
         │
         ▼
[1] teedoo-architect  → diseña plan, reparte owners
         │
         ├─→ [2] teedoo-db-switcher      → define interface en types.d.ts
         │        │
         │        ├─→ [3a] teedoo-mongodb        (paralelo)
         │        └─→ [3b] teedoo-postgres-neon  (paralelo)
         │
         ├─→ [4] teedoo-api-backend       → handler que usa los repos
         ├─→ [5] teedoo-flutter-frontend  → UI que consume el endpoint
         ├─→ [6] teedoo-design-system     → revisa tokens si hay UI nueva
         ├─→ [7] teedoo-vercel-platform   → añade env vars / Marketplace
         └─→ [8] teedoo-fiscal-compliance → si el endpoint toca fiscalidad
         │
         ▼
[9] teedoo-code-reviewer → gate final antes de merge
```

## Principios compartidos (todos los agentes los respetan)

- **Boundary:** el frontend Flutter **NUNCA** toca una DB directamente. Todo fluye por `/api/*`. El switch dual-DB vive server-side.
- **2026 Vercel:** Fluid Compute + Node 24 LTS. Sin Edge Functions por defecto. `vercel.ts` preferido sobre `vercel.json` para proyectos nuevos.
- **Parity:** Mongo y Postgres repos devuelven JSON idéntico, con UUIDs, dinero en céntimos enteros, fechas ISO-8601. Tests de parity obligatorios.
- **No mezcla de drivers:** `mongodb` y `@neondatabase/serverless` solo dentro de `api/_lib/db/**`. Jamás en handlers.
- **Compliance fiscal sagrado:** IA redacta, nunca decide. `postValidate` tras cada llamada. Fallback al rules engine si falla la validación crítica.
- **Design tokens obligatorios:** nada de colores ni paddings hardcoded en Dart.

## Arquitectura dual-DB propuesta (2026, Vercel Marketplace)

```
api/
└── _lib/
    └── db/
        ├── index.js              ← Factory: lee DATA_SOURCE, cachea repos
        ├── types.d.ts            ← Interfaces compartidas
        ├── errors.js             ← NotFoundError, ConflictError, ValidationError, DbError
        ├── mongo/                ← teedoo-mongodb owns
        │   ├── client.js         ← MongoClient @ module scope
        │   ├── repositories/*.js
        │   └── migrations/*.js   ← índices, idempotentes
        └── postgres/             ← teedoo-postgres-neon owns
            ├── client.js         ← @neondatabase/serverless + drizzle
            ├── schema/*.ts       ← Drizzle tables
            ├── migrations/       ← drizzle-kit generated
            └── repositories/*.js
```

**Switch runtime:**
- `DATA_SOURCE=postgres` | `mongodb` — global
- `DATA_SOURCE_AUDIT=mongodb` — override per dominio (modo híbrido)

**Recomendación híbrida por defecto** (open para decisión del usuario):
- Invoices, users, fiscal, customers → Postgres (integridad relacional, reporting, cumplimiento normativo)
- Audit, compliance checks, AI explanations → MongoDB (payloads variables, write-heavy, agregaciones flexibles)

## Archivos

```
.claude/agents/
├── README.md                         ← este archivo
├── teedoo-architect.md
├── teedoo-flutter-frontend.md
├── teedoo-api-backend.md
├── teedoo-db-switcher.md
├── teedoo-mongodb.md
├── teedoo-postgres-neon.md
├── teedoo-vercel-platform.md
├── teedoo-fiscal-compliance.md
├── teedoo-design-system.md
└── teedoo-code-reviewer.md
```

Cada archivo es un agente completo: frontmatter YAML (`name`, `description`, `tools`, `model: opus`) + system prompt extenso con contexto TeeDoo + especialidad + best practices 2026 + antipatrones.

## Próximos pasos sugeridos

1. **Probar el equipo:** invoca `teedoo-architect` con una primera tarea: "Diseña la puesta en marcha del dual-DB para el dominio de invoices — quiero un plan step-by-step con owners por paso."
2. **Provisionar Marketplace:** cuando el plan esté aprobado, `teedoo-vercel-platform` ejecuta `vercel integration add neon` y `vercel integration add mongodb-atlas`.
3. **Definir la interfaz:** `teedoo-db-switcher` escribe `types.d.ts` y el factory `_lib/db/index.js`.
4. **Implementar en paralelo:** `teedoo-mongodb` y `teedoo-postgres-neon` trabajan las dos implementaciones simultáneamente contra el mismo contrato.
5. **Parity test:** `teedoo-code-reviewer` audita que ambas implementaciones devuelven exactamente lo mismo para fixtures idénticos.
6. **Integrar en handlers:** `teedoo-api-backend` reemplaza cualquier fetch mock por llamadas al factory de repos.
7. **UI sin cambios:** `teedoo-flutter-frontend` no debería necesitar tocar nada — la API contract no cambia.
