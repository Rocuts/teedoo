/**
 * Shared repository interfaces for the TeeDoo dual-DB layer.
 *
 * Every repository — MongoDB Atlas or Supabase Postgres — MUST conform to
 * these contracts. Handlers under `api/**` receive repositories from
 * `factory.js` and never import drivers directly.
 *
 * Conventions:
 *  - Primary keys: UUID v4 strings (`id`).
 *  - Multi-tenant scoping: every row carries `orgId` (for sprint 1 = "org_default").
 *  - Money: integer cents (`amountCents: number`).
 *  - Dates: ISO-8601 strings at the repo boundary (parse in Dart only).
 *  - Errors: NotFoundError | ConflictError | ValidationError | DbError.
 *
 * Document shapes mirror the Dart domain entity defined in
 * `lib/features/invoices/domain/invoice.dart` — keep them in sync.
 */

export type UUID = string;
export type ISODateTime = string;
export type ISODate = string;

export interface Paginated<T> {
  items: T[];
  nextCursor: string | null;
}

export interface PageQuery {
  limit?: number;
  cursor?: string | null;
}

// ────────────────────────────────────────────────────────────────────
// Health
// ────────────────────────────────────────────────────────────────────

export interface HealthRepository {
  ping(): Promise<{ ok: true; backend: 'mongo' | 'postgres'; latencyMs: number }>;
}

// ────────────────────────────────────────────────────────────────────
// Parties (issuers / recipients, normalized in both DBs)
// ────────────────────────────────────────────────────────────────────

export type TaxIdType = 'NIF' | 'NIE' | 'NIF_IVA' | 'PASAPORTE' | 'OTRO';
// CIF (pre-2008 legal-entity ID) projects to NIF at the repo boundary.

export interface PartyAddress {
  line1: string;
  line2?: string;
  postalCode: string;
  city: string;
  province: string;
  country: string; // ISO-3166-alpha-2, default "ES"
}

export interface Party {
  id: UUID;
  orgId: UUID;
  taxId: string;
  taxIdType: TaxIdType;
  name: string;
  address: PartyAddress;
  createdAt: ISODateTime;
  updatedAt: ISODateTime;
}

export interface PartiesRepository {
  get(orgId: UUID, id: UUID): Promise<Party>;
  findByTaxId(orgId: UUID, taxId: string): Promise<Party | null>;
  list(orgId: UUID, q?: PageQuery): Promise<Paginated<Party>>;
  /** Inserts or updates by (orgId, taxId). Returns the canonical row. */
  upsert(p: Party): Promise<Party>;
  delete(orgId: UUID, id: UUID): Promise<void>;
}

// ────────────────────────────────────────────────────────────────────
// Invoices
//
// The full nested shape is too large to type rigorously here; repos
// accept and return the document as a plain object. The authoritative
// shape is the Dart `Invoice` entity. Each implementation is
// responsible for validating required fields at the repo boundary.
// ────────────────────────────────────────────────────────────────────

export type VatRate = 'IVA_21' | 'IVA_10' | 'IVA_4' | 'IVA_0' | 'EXENTO' | 'NO_SUJETO';
export type InvoiceStatusCode =
  | 'draft'
  | 'pendingReview'
  | 'readyToSend'
  | 'sent'
  | 'accepted'
  | 'rejected'
  | 'cancelled';

export interface InvoiceLineDoc {
  id: UUID;
  description: string;
  quantity: number;
  unitPriceCents: number;
  discountPercent?: number;
  vatRate: VatRate;
  vatRateValue: number;
  irpfRate?: number;
  exemptReason?: string;
  lineTotalCents: number;
}

export interface VatBreakdownDoc {
  vatRate: VatRate;
  vatRateValue: number;
  baseCents: number;
  vatCents: number;
  recargoCents?: number;
}

export interface AttachmentDoc {
  id: UUID;
  fileName: string;
  mimeType: string;
  sizeBytes: number;
  url?: string;
  storageKey?: string;
  uploadedAt: ISODateTime;
}

export interface AuditStampDoc {
  id: UUID;
  at: ISODateTime;
  actor: string;
  action: string;
  notes?: string;
}

export interface InvoiceDoc {
  id: UUID;
  orgId: UUID;
  series: string;
  number: string;
  issueDate: ISODate;
  operationDate?: ISODate;
  issuerId: UUID;
  recipientId: UUID;
  /**
   * Denormalized display names of issuer and recipient at the time of issue.
   * Both backends populate them on write so list views never need a join.
   * Staleness by design: renaming a Party does NOT back-propagate. The
   * canonical name stays in the `parties` collection/table.
   */
  issuerName?: string;
  recipientName?: string;
  lines: InvoiceLineDoc[];
  totals: {
    subtotalCents: number;
    vatBreakdown: VatBreakdownDoc[];
    irpfCents: number;
    totalCents: number;
    currency: string; // ISO-4217
  };
  regime: string;
  operationType: string;
  fiscalRegion: string;
  compliance: {
    ticketBaiId?: string;
    ticketBaiHash?: string;
    verifactuHash?: string;
    verifactuChainRef?: string;
    siiSubmitted: boolean;
  };
  paymentTerms?: {
    method: string;
    iban?: string;
    dueDate?: ISODate;
  };
  notes?: string;
  attachments: AttachmentDoc[];
  status: InvoiceStatusCode;
  rectification?: Record<string, unknown>;
  audit: AuditStampDoc[];
  createdAt: ISODateTime;
  updatedAt: ISODateTime;
}

export interface InvoicesQuery extends PageQuery {
  status?: InvoiceStatusCode;
  issuerId?: UUID;
  recipientId?: UUID;
  fromDate?: ISODate;
  toDate?: ISODate;
}

export interface InvoicesRepository {
  get(orgId: UUID, id: UUID): Promise<InvoiceDoc>;
  list(orgId: UUID, q?: InvoicesQuery): Promise<Paginated<InvoiceDoc>>;
  create(doc: InvoiceDoc): Promise<InvoiceDoc>;
  update(orgId: UUID, id: UUID, patch: Partial<InvoiceDoc>): Promise<InvoiceDoc>;
  delete(orgId: UUID, id: UUID): Promise<void>;
  count(orgId: UUID): Promise<number>;
}

// ────────────────────────────────────────────────────────────────────
// Factory
// ────────────────────────────────────────────────────────────────────

export interface Repositories {
  health: HealthRepository;
  parties: PartiesRepository;
  invoices: InvoicesRepository;
}

export type DataSource = 'mongo' | 'postgres';

export interface FactoryOptions {
  /** Override the global DATA_SOURCE for a single domain. */
  overrides?: Partial<Record<keyof Repositories, DataSource>>;
}
