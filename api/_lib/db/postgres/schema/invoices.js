/**
 * Invoices — Supabase Postgres schema.
 *
 * Decomposed into header + child tables so we can enforce FKs, RLS per
 * table and paginate/aggregate natively. Each child carries its own
 * `org_id` so a single RLS predicate works uniformly across all six
 * tables (see `migrations/rls_policies.sql`).
 *
 * Money is stored as integer cents (NEVER numeric). Dates: `timestamptz`
 * for instants, `date` for civil calendar dates (issueDate, operationDate,
 * dueDate).
 *
 * Enums (invoice_status_code, vat_rate, regime, operation_type,
 * fiscal_region) are text+CHECK, not pg_enum — same rationale as in
 * `parties.js`: regulatory sets mutate (new VAT codes, TicketBAI regional
 * tweaks) and `text+CHECK` is far cheaper to migrate than pg_enum.
 *
 * JSONB is reserved for two escape hatches:
 *   - `rectification` (optional nested doc, variable codes)
 *   - `compliance_extra` (future Verifactu/SII fields, not in contract)
 * The mandated compliance fields live on typed columns.
 */

const {
  pgTable,
  uuid,
  varchar,
  text,
  integer,
  boolean,
  timestamp,
  date,
  jsonb,
  index,
  uniqueIndex,
  check,
} = require('drizzle-orm/pg-core');
const { sql } = require('drizzle-orm');
const { parties } = require('./parties');

// ─── header ───────────────────────────────────────────────────────────
const invoices = pgTable(
  'invoices',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    orgId: uuid('org_id').notNull(),

    series: varchar('series', { length: 32 }).notNull(),
    number: varchar('number', { length: 64 }).notNull(),

    issueDate: date('issue_date').notNull(),
    operationDate: date('operation_date'),

    issuerId: uuid('issuer_id')
      .notNull()
      .references(() => parties.id, { onDelete: 'restrict' }),
    recipientId: uuid('recipient_id')
      .notNull()
      .references(() => parties.id, { onDelete: 'restrict' }),

    // Totals (computed upstream in Dart; stored for read path speed).
    subtotalCents: integer('subtotal_cents').notNull(),
    irpfCents: integer('irpf_cents').notNull().default(0),
    totalCents: integer('total_cents').notNull(),
    currency: varchar('currency', { length: 3 }).notNull().default('EUR'),

    regime: text('regime').notNull(),
    operationType: text('operation_type').notNull(),
    fiscalRegion: text('fiscal_region').notNull(),

    // Compliance (TicketBAI / Verifactu / SII).
    ticketBaiId: varchar('ticketbai_id', { length: 128 }),
    ticketBaiHash: varchar('ticketbai_hash', { length: 128 }),
    verifactuHash: varchar('verifactu_hash', { length: 128 }),
    verifactuChainRef: varchar('verifactu_chain_ref', { length: 128 }),
    siiSubmitted: boolean('sii_submitted').notNull().default(false),

    // Payment terms (optional — nullable columns, no child table needed).
    paymentMethod: varchar('payment_method', { length: 64 }),
    paymentIban: varchar('payment_iban', { length: 34 }),
    paymentDueDate: date('payment_due_date'),

    notes: text('notes'),

    status: text('status').notNull(),

    // Rectification is a free-form sub-doc per contract (R1-R5 variants).
    rectification: jsonb('rectification'),

    createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
  },
  (t) => ({
    // Legal uniqueness: (orgId, series, number).
    orgSeriesNumberUnique: uniqueIndex('invoices_org_series_number_unique').on(
      t.orgId,
      t.series,
      t.number,
    ),
    // Cursor pagination ordering key — kept org-scoped.
    orgCreatedIdIdx: index('invoices_org_created_id_idx').on(t.orgId, t.createdAt, t.id),
    orgIssueDateIdx: index('invoices_org_issue_date_idx').on(t.orgId, t.issueDate),
    orgStatusIdx: index('invoices_org_status_idx').on(t.orgId, t.status),
    orgIssuerIdx: index('invoices_org_issuer_idx').on(t.orgId, t.issuerId),
    orgRecipientIdx: index('invoices_org_recipient_idx').on(t.orgId, t.recipientId),

    statusCheck: check(
      'invoices_status_check',
      sql`${t.status} IN ('draft','pendingReview','readyToSend','sent','accepted','rejected','cancelled')`,
    ),
    regimeCheck: check(
      'invoices_regime_check',
      sql`${t.regime} IN ('GENERAL','SIMPLIFICADO','RECARGO_EQUIVALENCIA','REAGP','BIENES_USADOS_REBU','AGENCIAS_VIAJES_REAV','CRITERIO_CAJA_RECC','GRUPO_ENTIDADES_REGE','EXENTO')`,
    ),
    operationTypeCheck: check(
      'invoices_operation_type_check',
      sql`${t.operationType} IN ('F1','F2','F3','F4','F5','R1','R2','R3','R4','R5')`,
    ),
    fiscalRegionCheck: check(
      'invoices_fiscal_region_check',
      sql`${t.fiscalRegion} IN ('PENINSULA_BALEARES','CANARIAS','CEUTA','MELILLA','PAIS_VASCO_ARABA','PAIS_VASCO_BIZKAIA','PAIS_VASCO_GIPUZKOA','NAVARRA')`,
    ),
    currencyFormatCheck: check(
      'invoices_currency_format_check',
      sql`${t.currency} ~ '^[A-Z]{3}$'`,
    ),
    totalsSignCheck: check(
      'invoices_totals_sign_check',
      sql`${t.subtotalCents} IS NOT NULL AND ${t.totalCents} IS NOT NULL`,
    ),
  }),
);

// ─── lines ────────────────────────────────────────────────────────────
const invoiceLines = pgTable(
  'invoice_lines',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    orgId: uuid('org_id').notNull(), // propagated for uniform RLS
    invoiceId: uuid('invoice_id')
      .notNull()
      .references(() => invoices.id, { onDelete: 'cascade' }),

    position: integer('position').notNull(),

    description: text('description').notNull(),
    // Quantity allows decimals (kg, h, m³). Stored as text (ISO decimal)
    // to avoid float drift — repo parses/serializes.
    quantity: varchar('quantity', { length: 32 }).notNull(),

    unitPriceCents: integer('unit_price_cents').notNull(),
    discountPercent: varchar('discount_percent', { length: 16 }),

    vatRate: text('vat_rate').notNull(),
    vatRateValue: varchar('vat_rate_value', { length: 16 }).notNull(),

    irpfRate: varchar('irpf_rate', { length: 16 }),
    exemptReason: varchar('exempt_reason', { length: 255 }),

    lineTotalCents: integer('line_total_cents').notNull(),

    createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  },
  (t) => ({
    invoiceIdx: index('invoice_lines_invoice_idx').on(t.invoiceId, t.position),
    orgIdx: index('invoice_lines_org_idx').on(t.orgId),
    vatRateCheck: check(
      'invoice_lines_vat_rate_check',
      sql`${t.vatRate} IN ('IVA_GENERAL_21','IVA_REDUCIDO_10','IVA_SUPERREDUCIDO_4','IVA_CERO','EXENTO','NO_SUJETO','IGIC_GENERAL_7','IGIC_REDUCIDO_3','IGIC_CERO','IPSI')`,
    ),
  }),
);

// ─── vat breakdowns ──────────────────────────────────────────────────
const invoiceVatBreakdowns = pgTable(
  'invoice_vat_breakdowns',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    orgId: uuid('org_id').notNull(),
    invoiceId: uuid('invoice_id')
      .notNull()
      .references(() => invoices.id, { onDelete: 'cascade' }),

    vatRate: text('vat_rate').notNull(),
    vatRateValue: varchar('vat_rate_value', { length: 16 }).notNull(),
    baseCents: integer('base_cents').notNull(),
    vatCents: integer('vat_cents').notNull(),
    recargoCents: integer('recargo_cents').notNull().default(0),
  },
  (t) => ({
    invoiceIdx: index('invoice_vat_breakdowns_invoice_idx').on(t.invoiceId),
    orgIdx: index('invoice_vat_breakdowns_org_idx').on(t.orgId),
    invoiceRateUnique: uniqueIndex(
      'invoice_vat_breakdowns_invoice_rate_unique',
    ).on(t.invoiceId, t.vatRate, t.vatRateValue),
    vatRateCheck: check(
      'invoice_vat_breakdowns_rate_check',
      sql`${t.vatRate} IN ('IVA_GENERAL_21','IVA_REDUCIDO_10','IVA_SUPERREDUCIDO_4','IVA_CERO','EXENTO','NO_SUJETO','IGIC_GENERAL_7','IGIC_REDUCIDO_3','IGIC_CERO','IPSI')`,
    ),
  }),
);

// ─── attachments ─────────────────────────────────────────────────────
const invoiceAttachments = pgTable(
  'invoice_attachments',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    orgId: uuid('org_id').notNull(),
    invoiceId: uuid('invoice_id')
      .notNull()
      .references(() => invoices.id, { onDelete: 'cascade' }),

    fileName: varchar('file_name', { length: 255 }).notNull(),
    mimeType: varchar('mime_type', { length: 128 }).notNull(),
    sizeBytes: integer('size_bytes').notNull(),
    url: text('url').notNull(),
    storageKey: text('storage_key'),
    uploadedAt: timestamp('uploaded_at', { withTimezone: true }).notNull().defaultNow(),
  },
  (t) => ({
    invoiceIdx: index('invoice_attachments_invoice_idx').on(t.invoiceId),
    orgIdx: index('invoice_attachments_org_idx').on(t.orgId),
  }),
);

// ─── audit trail ─────────────────────────────────────────────────────
const invoiceAudit = pgTable(
  'invoice_audit',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    orgId: uuid('org_id').notNull(),
    invoiceId: uuid('invoice_id')
      .notNull()
      .references(() => invoices.id, { onDelete: 'cascade' }),

    at: timestamp('at', { withTimezone: true }).notNull().defaultNow(),
    actorId: varchar('actor_id', { length: 255 }).notNull(),
    action: varchar('action', { length: 64 }).notNull(),
    notes: text('notes'),
  },
  (t) => ({
    invoiceAtIdx: index('invoice_audit_invoice_at_idx').on(t.invoiceId, t.at),
    orgIdx: index('invoice_audit_org_idx').on(t.orgId),
  }),
);

module.exports = {
  invoices,
  invoiceLines,
  invoiceVatBreakdowns,
  invoiceAttachments,
  invoiceAudit,
};
