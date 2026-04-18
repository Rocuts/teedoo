/**
 * Shared repository interfaces for the TeeDoo dual-DB layer.
 *
 * Every repository — MongoDB Atlas or Supabase Postgres — MUST conform to
 * these contracts. Handlers under `api/**` receive repositories from
 * `factory.js` and never import drivers directly.
 *
 * Conventions:
 *  - Primary keys: UUID v4 strings (`id`).
 *  - Money: integer cents (`amountCents: number`).
 *  - Dates: ISO-8601 strings (`createdAt: string`).
 *  - Errors: NotFoundError | ConflictError | ValidationError | DbError.
 */

export type UUID = string;

export interface Paginated<T> {
  items: T[];
  nextCursor: string | null;
}

export interface PageQuery {
  limit?: number;
  cursor?: string | null;
}

export interface HealthRepository {
  ping(): Promise<{ ok: true; backend: 'mongo' | 'postgres'; latencyMs: number }>;
}

/**
 * The full repository set exposed by the factory.
 * Add new domain interfaces here, then implement in both mongo/ and postgres/.
 */
export interface Repositories {
  health: HealthRepository;
}

export type DataSource = 'mongo' | 'postgres';

export interface FactoryOptions {
  /** Override the global DATA_SOURCE for a single domain. */
  overrides?: Partial<Record<keyof Repositories, DataSource>>;
}
