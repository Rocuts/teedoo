/**
 * Deterministic demo fixtures for POST /api/seed.
 *
 * Contracts honored:
 *  - Every row carries a fixed UUID so seeding the SAME org to Mongo and to
 *    Postgres yields cross-DB-comparable ids (useful for migration diffs).
 *  - All 3 parties are in ES; tax IDs are obviously fake but schema-valid.
 *  - All 5 invoices: `fiscalRegion: 'peninsulaBaleares'`, `regime: 'general'`,
 *    `currency: 'EUR'`.
 *  - Covers the fiscal status matrix the user specified:
 *      1. DRAFT      — IVA 21
 *      2. SENT       — IVA 10 + IRPF 15
 *      3. ACCEPTED   — IVA 4 (superreducido)
 *      4. REJECTED   — operationType F2 (simplified factura)
 *      5. CANCELLED  — exempt line citing art. 20 LIVA
 *  - Totals (cents) are hand-balanced per invoice; the repo validators
 *    require every line / totals field to be an integer in cents.
 *
 * Usage:
 *   const { seedParties, seedInvoices } = require('./invoices');
 *   const parties = seedParties(orgId);
 *   const invoices = seedInvoices(orgId);
 */

// ── Fixed UUIDs (v4) ──────────────────────────────────────────────────
//
// Hand-picked so the seed is byte-for-byte reproducible across runs.

const PARTY_ISSUER = '10000000-0000-4000-8000-000000000001';
const PARTY_CLIENT_A = '10000000-0000-4000-8000-000000000002';
const PARTY_CLIENT_B = '10000000-0000-4000-8000-000000000003';

const INVOICE_DRAFT = '20000000-0000-4000-8000-000000000001';
const INVOICE_SENT = '20000000-0000-4000-8000-000000000002';
const INVOICE_ACCEPTED = '20000000-0000-4000-8000-000000000003';
const INVOICE_REJECTED = '20000000-0000-4000-8000-000000000004';
const INVOICE_CANCELLED = '20000000-0000-4000-8000-000000000005';

// Fixed timestamps — ISO-8601 — so cross-DB seeds match exactly.
const ISSUE_DATE = '2026-01-15';
const NOW = '2026-01-15T10:00:00.000Z';

// Helper: build an audit stamp with a deterministic id per invoice.
function audit(invoiceSuffix, action = 'created', at = NOW) {
  return {
    id: `30000000-0000-4000-8000-00000000000${invoiceSuffix}`,
    at,
    actor: 'demo',
    action,
  };
}

// ── Parties ───────────────────────────────────────────────────────────

function seedParties(orgId) {
  const base = {
    orgId,
    createdAt: NOW,
    updatedAt: NOW,
  };
  return [
    {
      ...base,
      id: PARTY_ISSUER,
      taxId: 'B12345678',
      taxIdType: 'NIF',
      name: 'TeeDoo Demo Emisor S.L.',
      address: {
        line1: 'Calle Mayor 1',
        postalCode: '28013',
        city: 'Madrid',
        province: 'Madrid',
        country: 'ES',
      },
    },
    {
      ...base,
      id: PARTY_CLIENT_A,
      taxId: 'B87654321',
      taxIdType: 'NIF',
      name: 'Cliente Ejemplo A S.A.',
      address: {
        line1: 'Avinguda Diagonal 100',
        postalCode: '08019',
        city: 'Barcelona',
        province: 'Barcelona',
        country: 'ES',
      },
    },
    {
      ...base,
      id: PARTY_CLIENT_B,
      taxId: '12345678Z',
      taxIdType: 'NIF',
      name: 'Cliente Ejemplo B (Autónomo)',
      address: {
        line1: 'Calle Sierpes 42',
        postalCode: '41004',
        city: 'Sevilla',
        province: 'Sevilla',
        country: 'ES',
      },
    },
  ];
}

// ── Invoice helpers ───────────────────────────────────────────────────
//
// Money math is trivial but strict: every *Cents field must be an integer.
// We compute `lineTotalCents = quantity * unitPriceCents` (no discount),
// `baseCents = sum(line.lineTotalCents)`, `vatCents = round(base * rate/100)`,
// and `totalCents = base + vatCents - irpfCents + recargoCents`.

function makeInvoiceBase(orgId, id, suffix) {
  return {
    id,
    orgId,
    createdAt: NOW,
    updatedAt: NOW,
    fiscalRegion: 'peninsulaBaleares',
    regime: 'general',
    operationDate: ISSUE_DATE,
    issueDate: ISSUE_DATE,
    attachments: [],
    compliance: {
      siiSubmitted: false,
    },
    audit: [audit(suffix)],
  };
}

// ── Invoices ──────────────────────────────────────────────────────────

function seedInvoices(orgId) {
  // 1. DRAFT — IVA 21 — consulting fee 1000.00 EUR
  const draft = {
    ...makeInvoiceBase(orgId, INVOICE_DRAFT, '1'),
    series: 'DEMO',
    number: '2026-0001',
    issuerId: PARTY_ISSUER,
    recipientId: PARTY_CLIENT_A,
    status: 'draft',
    operationType: 'F1',
    lines: [
      {
        id: '40000000-0000-4000-8000-000000000001',
        description: 'Consultoría fiscal — enero 2026',
        quantity: 1,
        unitPriceCents: 100000, // 1000.00 EUR
        vatRate: 'IVA_21',
        vatRateValue: 21,
        lineTotalCents: 100000,
      },
    ],
    totals: {
      subtotalCents: 100000,
      vatBreakdown: [
        { vatRate: 'IVA_21', vatRateValue: 21, baseCents: 100000, vatCents: 21000 },
      ],
      irpfCents: 0,
      totalCents: 121000, // 1000 + 210 IVA
      currency: 'EUR',
    },
  };

  // 2. SENT — IVA 10 + IRPF 15% — catering 500.00 EUR
  const sent = {
    ...makeInvoiceBase(orgId, INVOICE_SENT, '2'),
    series: 'DEMO',
    number: '2026-0002',
    issuerId: PARTY_ISSUER,
    recipientId: PARTY_CLIENT_B,
    status: 'sent',
    operationType: 'F1',
    lines: [
      {
        id: '40000000-0000-4000-8000-000000000002',
        description: 'Servicio de restauración — evento corporativo',
        quantity: 1,
        unitPriceCents: 50000, // 500.00 EUR
        vatRate: 'IVA_10',
        vatRateValue: 10,
        irpfRate: 15,
        lineTotalCents: 50000,
      },
    ],
    totals: {
      subtotalCents: 50000,
      vatBreakdown: [
        { vatRate: 'IVA_10', vatRateValue: 10, baseCents: 50000, vatCents: 5000 },
      ],
      irpfCents: 7500, // 15% de 500
      totalCents: 47500, // 500 + 50 IVA - 75 IRPF
      currency: 'EUR',
    },
  };

  // 3. ACCEPTED — IVA 4 (superreducido) — libros 40.00 EUR
  const accepted = {
    ...makeInvoiceBase(orgId, INVOICE_ACCEPTED, '3'),
    series: 'DEMO',
    number: '2026-0003',
    issuerId: PARTY_ISSUER,
    recipientId: PARTY_CLIENT_A,
    status: 'accepted',
    operationType: 'F1',
    lines: [
      {
        id: '40000000-0000-4000-8000-000000000003',
        description: 'Libros de referencia fiscal (IVA superreducido)',
        quantity: 2,
        unitPriceCents: 2000, // 20.00 EUR c/u
        vatRate: 'IVA_4',
        vatRateValue: 4,
        lineTotalCents: 4000,
      },
    ],
    totals: {
      subtotalCents: 4000,
      vatBreakdown: [
        { vatRate: 'IVA_4', vatRateValue: 4, baseCents: 4000, vatCents: 160 },
      ],
      irpfCents: 0,
      totalCents: 4160,
      currency: 'EUR',
    },
  };

  // 4. REJECTED — operationType F2 (simplified) — small ticket 25.00 EUR IVA 21
  const rejected = {
    ...makeInvoiceBase(orgId, INVOICE_REJECTED, '4'),
    series: 'DEMOF2',
    number: '2026-0004',
    issuerId: PARTY_ISSUER,
    recipientId: PARTY_CLIENT_B,
    status: 'rejected',
    operationType: 'F2', // factura simplificada (antes llamada "ticket")
    lines: [
      {
        id: '40000000-0000-4000-8000-000000000004',
        description: 'Material de oficina — ticket simplificado',
        quantity: 1,
        unitPriceCents: 2500, // 25.00 EUR
        vatRate: 'IVA_21',
        vatRateValue: 21,
        lineTotalCents: 2500,
      },
    ],
    totals: {
      subtotalCents: 2500,
      vatBreakdown: [
        { vatRate: 'IVA_21', vatRateValue: 21, baseCents: 2500, vatCents: 525 },
      ],
      irpfCents: 0,
      totalCents: 3025,
      currency: 'EUR',
    },
  };

  // 5. CANCELLED — línea exenta (art. 20 LIVA)
  const cancelled = {
    ...makeInvoiceBase(orgId, INVOICE_CANCELLED, '5'),
    series: 'DEMO',
    number: '2026-0005',
    issuerId: PARTY_ISSUER,
    recipientId: PARTY_CLIENT_A,
    status: 'cancelled',
    operationType: 'F1',
    lines: [
      {
        id: '40000000-0000-4000-8000-000000000005',
        description: 'Formación reglada — exenta de IVA',
        quantity: 1,
        unitPriceCents: 30000, // 300.00 EUR
        vatRate: 'EXENTO',
        vatRateValue: 0,
        exemptReason: 'Art. 20.Uno.9º LIVA — servicios educativos exentos.',
        lineTotalCents: 30000,
      },
    ],
    totals: {
      subtotalCents: 30000,
      vatBreakdown: [
        { vatRate: 'EXENTO', vatRateValue: 0, baseCents: 30000, vatCents: 0 },
      ],
      irpfCents: 0,
      totalCents: 30000,
      currency: 'EUR',
    },
  };

  return [draft, sent, accepted, rejected, cancelled];
}

module.exports = {
  seedParties,
  seedInvoices,
};
