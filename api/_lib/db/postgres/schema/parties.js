/**
 * Parties (issuers / recipients) — Supabase Postgres schema.
 *
 * Multi-tenant: every row carries `org_id`. RLS policies enforce
 * isolation (see `migrations/rls_policies.sql`).
 *
 * Tax identifier catalogue is kept as text+CHECK instead of a native
 * pg_enum because:
 *   1. The Dart enum (NIF, NIE, CIF, VAT_EU, PASSPORT, OTHER) evolves more
 *      frequently than the contract in `types.d.ts` (NIF, NIF_IVA,
 *      PASAPORTE, OTRO). text+CHECK lets us alter the allowed set with a
 *      single migration — a pg_enum needs ALTER TYPE ... ADD VALUE in its
 *      own transaction and cannot drop values at all.
 *   2. Drizzle serializes enums as strings anyway; no runtime benefit.
 */

const {
  pgTable,
  uuid,
  varchar,
  text,
  timestamp,
  uniqueIndex,
  index,
  check,
} = require('drizzle-orm/pg-core');
const { sql } = require('drizzle-orm');

const parties = pgTable(
  'parties',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    orgId: uuid('org_id').notNull(),

    taxId: varchar('tax_id', { length: 32 }).notNull(),
    taxIdType: text('tax_id_type').notNull(),

    name: varchar('name', { length: 255 }).notNull(),

    addressLine1: varchar('address_line1', { length: 255 }),
    addressLine2: varchar('address_line2', { length: 255 }),
    postalCode: varchar('postal_code', { length: 16 }),
    city: varchar('city', { length: 128 }),
    province: varchar('province', { length: 128 }),
    country: varchar('country', { length: 2 }).notNull().default('ES'),

    email: varchar('email', { length: 255 }),
    phone: varchar('phone', { length: 32 }),

    createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
  },
  (t) => ({
    orgTaxIdUnique: uniqueIndex('parties_org_tax_id_unique').on(t.orgId, t.taxId),
    orgCreatedAtIdx: index('parties_org_created_at_idx').on(t.orgId, t.createdAt),
    taxIdTypeCheck: check(
      'parties_tax_id_type_check',
      sql`${t.taxIdType} IN ('NIF','NIE','CIF','NIF_IVA','PASAPORTE','OTRO')`,
    ),
    countryFormatCheck: check(
      'parties_country_format_check',
      sql`${t.country} ~ '^[A-Z]{2}$'`,
    ),
  }),
);

module.exports = { parties };
