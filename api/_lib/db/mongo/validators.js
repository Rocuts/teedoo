/**
 * JSON Schema validators for TeeDoo MongoDB collections.
 *
 * Wire-canonical enum values follow the fiscal spec decided 2026-04-18 by
 * `teedoo-fiscal-compliance` (SCREAMING_SNAKE_CASE on persistence; see
 * `api/_lib/db/types.d.ts` for the shared TypeScript contract).
 *
 * `validationLevel: 'strict'` + `validationAction: 'error'` so every insert and
 * update is gated against the schema. Idempotent bootstrap via `ensureValidators`
 * — cached per topology like `ensureIndexes`.
 */

const CACHE_KEY = Symbol.for('teedoo.mongo.validators');

const TAX_ID_TYPES = ['NIF', 'NIE', 'CIF', 'NIF_IVA', 'PASAPORTE', 'OTRO'];

const VAT_RATES = [
  'IVA_GENERAL_21',
  'IVA_REDUCIDO_10',
  'IVA_SUPERREDUCIDO_4',
  'IVA_CERO',
  'EXENTO',
  'NO_SUJETO',
  'IGIC_GENERAL_7',
  'IGIC_REDUCIDO_3',
  'IGIC_CERO',
  'IPSI',
];

const FISCAL_REGIONS = [
  'PENINSULA_BALEARES',
  'CANARIAS',
  'CEUTA',
  'MELILLA',
  'PAIS_VASCO_ARABA',
  'PAIS_VASCO_BIZKAIA',
  'PAIS_VASCO_GIPUZKOA',
  'NAVARRA',
];

const OPERATION_TYPES = ['F1', 'F2', 'F3', 'F4', 'F5', 'R1', 'R2', 'R3', 'R4', 'R5'];

const INVOICE_REGIMES = [
  'GENERAL',
  'SIMPLIFICADO',
  'RECARGO_EQUIVALENCIA',
  'REAGP',
  'BIENES_USADOS_REBU',
  'AGENCIAS_VIAJES_REAV',
  'CRITERIO_CAJA_RECC',
  'GRUPO_ENTIDADES_REGE',
  'EXENTO',
];

const INVOICE_STATUSES = [
  'draft',
  'pendingReview',
  'readyToSend',
  'sent',
  'accepted',
  'rejected',
  'cancelled',
];

const ENUMS = {
  TAX_ID_TYPES,
  VAT_RATES,
  FISCAL_REGIONS,
  OPERATION_TYPES,
  INVOICE_REGIMES,
  INVOICE_STATUSES,
};

const ISO_COUNTRY_PATTERN = '^[A-Z]{2}$';
const ISO_DATE_PATTERN = '^\\d{4}-\\d{2}-\\d{2}';

const addressSchema = {
  bsonType: 'object',
  required: ['line1', 'postalCode', 'city', 'province', 'country'],
  properties: {
    line1: { bsonType: 'string', minLength: 1 },
    line2: { bsonType: ['string', 'null'] },
    postalCode: { bsonType: 'string', minLength: 1 },
    city: { bsonType: 'string', minLength: 1 },
    province: { bsonType: 'string', minLength: 1 },
    country: { bsonType: 'string', pattern: ISO_COUNTRY_PATTERN },
  },
};

const partiesSchema = {
  bsonType: 'object',
  required: ['id', 'orgId', 'taxIdType', 'taxId', 'name', 'country', 'address'],
  properties: {
    id: { bsonType: 'string', minLength: 1 },
    orgId: { bsonType: 'string', minLength: 1 },
    taxIdType: { enum: TAX_ID_TYPES },
    taxId: { bsonType: 'string', minLength: 1 },
    name: { bsonType: 'string', minLength: 1 },
    country: { bsonType: 'string', pattern: ISO_COUNTRY_PATTERN },
    email: { bsonType: ['string', 'null'] },
    phone: { bsonType: ['string', 'null'] },
    address: addressSchema,
    createdAt: { bsonType: ['string', 'date'] },
    updatedAt: { bsonType: ['string', 'date'] },
  },
};

const lineSchema = {
  bsonType: 'object',
  required: ['description', 'quantity', 'unitPriceCents', 'vatRate'],
  properties: {
    description: { bsonType: 'string', minLength: 1 },
    quantity: { bsonType: ['double', 'int', 'long'] },
    unitPriceCents: { bsonType: ['int', 'long'] },
    vatRate: { enum: VAT_RATES },
    vatCents: { bsonType: ['int', 'long'] },
    baseCents: { bsonType: ['int', 'long'] },
  },
};

const vatBreakdownSchema = {
  bsonType: 'object',
  required: ['vatRate', 'baseCents', 'vatCents'],
  properties: {
    vatRate: { enum: VAT_RATES },
    baseCents: { bsonType: ['int', 'long'] },
    vatCents: { bsonType: ['int', 'long'] },
  },
};

const attachmentSchema = {
  bsonType: 'object',
  required: ['id', 'fileName', 'url'],
  properties: {
    id: { bsonType: 'string' },
    fileName: { bsonType: 'string' },
    url: { bsonType: 'string', minLength: 1 },
    storageKey: { bsonType: ['string', 'null'] },
    mimeType: { bsonType: ['string', 'null'] },
    sizeBytes: { bsonType: ['int', 'long', 'null'] },
  },
};

const auditSchema = {
  bsonType: 'object',
  required: ['at', 'actorId', 'action'],
  properties: {
    at: { bsonType: ['string', 'date'] },
    actorId: { bsonType: 'string', minLength: 1 },
    action: { bsonType: 'string', minLength: 1 },
    notes: { bsonType: ['string', 'array', 'null'] },
  },
};

const totalsSchema = {
  bsonType: 'object',
  // Canonical shape per `api/_lib/db/types.d.ts` InvoiceDoc.totals:
  //   { subtotalCents, vatBreakdown[], irpfCents, totalCents, currency }
  // No top-level `baseCents`/`vatCents` — those live inside vatBreakdown items.
  required: ['currency', 'subtotalCents', 'totalCents', 'vatBreakdown'],
  properties: {
    currency: { bsonType: 'string', pattern: '^[A-Z]{3}$' },
    subtotalCents: { bsonType: ['int', 'long'] },
    totalCents: { bsonType: ['int', 'long'] },
    irpfCents: { bsonType: ['int', 'long', 'null'] },
    vatBreakdown: {
      bsonType: 'array',
      items: vatBreakdownSchema,
    },
  },
};

const invoicesSchema = {
  bsonType: 'object',
  required: [
    'id',
    'orgId',
    'series',
    'number',
    'issueDate',
    'issuerId',
    'recipientId',
    'regime',
    'operationType',
    'fiscalRegion',
    'status',
    'lines',
    'totals',
  ],
  properties: {
    id: { bsonType: 'string', minLength: 1 },
    orgId: { bsonType: 'string', minLength: 1 },
    series: { bsonType: 'string', minLength: 1 },
    number: { bsonType: ['string', 'int', 'long'] },
    issueDate: { bsonType: 'string', pattern: ISO_DATE_PATTERN },
    operationDate: { bsonType: ['string', 'null'] },
    issuerId: { bsonType: 'string', minLength: 1 },
    recipientId: { bsonType: 'string', minLength: 1 },
    regime: { enum: INVOICE_REGIMES },
    operationType: { enum: OPERATION_TYPES },
    fiscalRegion: { enum: FISCAL_REGIONS },
    status: { enum: INVOICE_STATUSES },
    lines: { bsonType: 'array', minItems: 1, items: lineSchema },
    totals: totalsSchema,
    paymentTerms: { bsonType: ['object', 'null'] },
    attachments: { bsonType: ['array', 'null'], items: attachmentSchema },
    audit: { bsonType: ['array', 'null'], items: auditSchema },
    compliance: { bsonType: ['object', 'null'] },
    notes: { bsonType: ['string', 'null'] },
    createdAt: { bsonType: ['string', 'date'] },
    updatedAt: { bsonType: ['string', 'date'] },
  },
};

const VALIDATOR_SPECS = {
  parties: {
    validator: { $jsonSchema: partiesSchema },
    validationLevel: 'strict',
    validationAction: 'error',
  },
  invoices: {
    validator: { $jsonSchema: invoicesSchema },
    validationLevel: 'strict',
    validationAction: 'error',
  },
};

async function ensureValidators(db) {
  const bucket = globalThis[CACHE_KEY] || (globalThis[CACHE_KEY] = new Map());

  const topologyId =
    (db && db.client && db.client.topology && db.client.topology.s && db.client.topology.s.id) ||
    db.databaseName;

  if (bucket.has(topologyId)) return bucket.get(topologyId);

  const promise = (async () => {
    const existing = await db
      .listCollections({}, { nameOnly: true })
      .toArray();
    const existingNames = new Set(existing.map((c) => c.name));

    for (const [name, spec] of Object.entries(VALIDATOR_SPECS)) {
      try {
        if (existingNames.has(name)) {
          await db.command({ collMod: name, ...spec });
        } else {
          await db.createCollection(name, spec);
        }
      } catch (err) {
        // Atlas Marketplace users ship with `readWrite` by default; `collMod`
        // and `createCollection` with validators require `dbAdmin`. When
        // permissions are missing we fall back to *repo-level* validation
        // only (see `validateInvoice` / `validateParty`) — defense-in-depth
        // is weaker but the contract still holds. Log once and move on.
        const code = err && (err.code || (err.codeName && err.codeName));
        const msg = (err && err.message) || String(err);
        const isPermissionError =
          code === 13 ||
          err?.codeName === 'Unauthorized' ||
          /not allowed to do action/i.test(msg) ||
          /requires authentication/i.test(msg);
        if (!isPermissionError) throw err;
        console.warn(
          `[mongo.validators] Skipped ${name}: ${msg}. ` +
            'Upgrade the Atlas user to dbAdmin to enable server-side $jsonSchema.',
        );
      }
    }
  })();

  bucket.set(topologyId, promise);

  try {
    await promise;
  } catch (err) {
    bucket.delete(topologyId);
    throw err;
  }
}

module.exports = { ensureValidators, ENUMS, VALIDATOR_SPECS };
