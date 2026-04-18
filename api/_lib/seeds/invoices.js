/**
 * Deterministic demo fixtures for POST /api/seed.
 *
 * Wire-canonical values follow the fiscal spec decided 2026-04-18 by
 * `teedoo-fiscal-compliance` — SCREAMING_SNAKE_CASE on persistence. See
 * `api/_lib/db/types.d.ts` for the shared contract.
 *
 * Every row carries a fixed UUID so seeding the SAME org to Mongo and to
 * Postgres yields cross-DB-comparable ids.
 *
 * Fiscal status matrix covered (5 invoices + 1 Canary):
 *   1. DRAFT      — IVA_GENERAL_21, PENINSULA_BALEARES, F1
 *   2. SENT       — IVA_REDUCIDO_10 + IRPF 15, PENINSULA_BALEARES, F1
 *   3. ACCEPTED   — IVA_SUPERREDUCIDO_4, PENINSULA_BALEARES, F1
 *   4. REJECTED   — IVA_GENERAL_21, PENINSULA_BALEARES, F2 (simplificada)
 *   5. CANCELLED  — EXENTO (art. 20 LIVA), PENINSULA_BALEARES, F1
 *   6. (bonus)    — IGIC_GENERAL_7, CANARIAS, F1 (parity demo)
 */

const PARTY_ISSUER = '10000000-0000-4000-8000-000000000001';
const PARTY_CLIENT_A = '10000000-0000-4000-8000-000000000002';
const PARTY_CLIENT_B = '10000000-0000-4000-8000-000000000003';
const PARTY_CLIENT_CN = '10000000-0000-4000-8000-000000000004';

const INVOICE_DRAFT = '20000000-0000-4000-8000-000000000001';
const INVOICE_SENT = '20000000-0000-4000-8000-000000000002';
const INVOICE_ACCEPTED = '20000000-0000-4000-8000-000000000003';
const INVOICE_REJECTED = '20000000-0000-4000-8000-000000000004';
const INVOICE_CANCELLED = '20000000-0000-4000-8000-000000000005';
const INVOICE_IGIC = '20000000-0000-4000-8000-000000000006';

const ISSUE_DATE = '2026-01-15';
const NOW = '2026-01-15T10:00:00.000Z';

function audit(invoiceSuffix, action = 'created', at = NOW) {
  return {
    id: `30000000-0000-4000-8000-00000000000${invoiceSuffix}`,
    at,
    actorId: 'demo',
    action,
  };
}

function seedParties(orgId) {
  const base = { orgId, createdAt: NOW, updatedAt: NOW };
  return [
    {
      ...base,
      id: PARTY_ISSUER,
      taxId: 'B12345678',
      taxIdType: 'CIF',
      name: 'TeeDoo Demo Emisor S.L.',
      country: 'ES',
      email: 'facturacion@teedoo-demo.es',
      phone: '+34 910 000 001',
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
      taxIdType: 'CIF',
      name: 'Cliente Ejemplo A S.A.',
      country: 'ES',
      email: 'cuentas@cliente-a.example',
      phone: '+34 932 000 002',
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
      country: 'ES',
      email: 'autonomo-b@example.es',
      phone: '+34 954 000 003',
      address: {
        line1: 'Calle Sierpes 42',
        postalCode: '41004',
        city: 'Sevilla',
        province: 'Sevilla',
        country: 'ES',
      },
    },
    {
      ...base,
      id: PARTY_CLIENT_CN,
      taxId: 'B55555555',
      taxIdType: 'CIF',
      name: 'Cliente Canario Demo S.L.',
      country: 'ES',
      email: 'contacto@canario-demo.es',
      phone: '+34 928 000 004',
      address: {
        line1: 'Calle Triana 1',
        postalCode: '35002',
        city: 'Las Palmas de Gran Canaria',
        province: 'Las Palmas',
        country: 'ES',
      },
    },
  ];
}

function makeInvoiceBase(orgId, id, suffix, fiscalRegion = 'PENINSULA_BALEARES') {
  return {
    id,
    orgId,
    createdAt: NOW,
    updatedAt: NOW,
    fiscalRegion,
    regime: 'GENERAL',
    operationDate: ISSUE_DATE,
    issueDate: ISSUE_DATE,
    attachments: [],
    compliance: { siiSubmitted: false },
    audit: [audit(suffix)],
  };
}

function seedInvoices(orgId) {
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
        unitPriceCents: 100000,
        vatRate: 'IVA_GENERAL_21',
        vatRateValue: 21,
        lineTotalCents: 100000,
      },
    ],
    totals: {
      subtotalCents: 100000,
      vatBreakdown: [
        { vatRate: 'IVA_GENERAL_21', vatRateValue: 21, baseCents: 100000, vatCents: 21000 },
      ],
      irpfCents: 0,
      totalCents: 121000,
      currency: 'EUR',
    },
  };

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
        unitPriceCents: 50000,
        vatRate: 'IVA_REDUCIDO_10',
        vatRateValue: 10,
        irpfRate: 15,
        lineTotalCents: 50000,
      },
    ],
    totals: {
      subtotalCents: 50000,
      vatBreakdown: [
        { vatRate: 'IVA_REDUCIDO_10', vatRateValue: 10, baseCents: 50000, vatCents: 5000 },
      ],
      irpfCents: 7500,
      totalCents: 47500,
      currency: 'EUR',
    },
  };

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
        unitPriceCents: 2000,
        vatRate: 'IVA_SUPERREDUCIDO_4',
        vatRateValue: 4,
        lineTotalCents: 4000,
      },
    ],
    totals: {
      subtotalCents: 4000,
      vatBreakdown: [
        { vatRate: 'IVA_SUPERREDUCIDO_4', vatRateValue: 4, baseCents: 4000, vatCents: 160 },
      ],
      irpfCents: 0,
      totalCents: 4160,
      currency: 'EUR',
    },
  };

  const rejected = {
    ...makeInvoiceBase(orgId, INVOICE_REJECTED, '4'),
    series: 'DEMOF2',
    number: '2026-0004',
    issuerId: PARTY_ISSUER,
    recipientId: PARTY_CLIENT_B,
    status: 'rejected',
    operationType: 'F2',
    lines: [
      {
        id: '40000000-0000-4000-8000-000000000004',
        description: 'Material de oficina — ticket simplificado',
        quantity: 1,
        unitPriceCents: 2500,
        vatRate: 'IVA_GENERAL_21',
        vatRateValue: 21,
        lineTotalCents: 2500,
      },
    ],
    totals: {
      subtotalCents: 2500,
      vatBreakdown: [
        { vatRate: 'IVA_GENERAL_21', vatRateValue: 21, baseCents: 2500, vatCents: 525 },
      ],
      irpfCents: 0,
      totalCents: 3025,
      currency: 'EUR',
    },
  };

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
        unitPriceCents: 30000,
        vatRate: 'EXENTO',
        vatRateValue: 0,
        exemptReason: 'Art. 20.Uno.9º LIVA — servicios educativos exentos.',
        lineTotalCents: 30000,
      },
    ],
    totals: {
      subtotalCents: 30000,
      vatBreakdown: [{ vatRate: 'EXENTO', vatRateValue: 0, baseCents: 30000, vatCents: 0 }],
      irpfCents: 0,
      totalCents: 30000,
      currency: 'EUR',
    },
  };

  const igic = {
    ...makeInvoiceBase(orgId, INVOICE_IGIC, '6', 'CANARIAS'),
    series: 'DEMO',
    number: '2026-0006',
    issuerId: PARTY_ISSUER,
    recipientId: PARTY_CLIENT_CN,
    status: 'sent',
    operationType: 'F1',
    lines: [
      {
        id: '40000000-0000-4000-8000-000000000006',
        description: 'Servicios profesionales — cliente canario (IGIC 7%)',
        quantity: 1,
        unitPriceCents: 80000,
        vatRate: 'IGIC_GENERAL_7',
        vatRateValue: 7,
        lineTotalCents: 80000,
      },
    ],
    totals: {
      subtotalCents: 80000,
      vatBreakdown: [
        { vatRate: 'IGIC_GENERAL_7', vatRateValue: 7, baseCents: 80000, vatCents: 5600 },
      ],
      irpfCents: 0,
      totalCents: 85600,
      currency: 'EUR',
    },
  };

  return [draft, sent, accepted, rejected, cancelled, igic];
}

module.exports = {
  seedParties,
  seedInvoices,
};
