/**
 * Drizzle Postgres schema entry point (Supabase-backed).
 *
 * Each domain defines its table in its own file under this directory, then
 * re-exports from here so `drizzle-kit` picks them up via a single path.
 *
 * Example:
 *   const { pgTable, uuid, timestamp, varchar } = require('drizzle-orm/pg-core');
 *   const users = pgTable('users', {
 *     id: uuid('id').primaryKey().defaultRandom(),
 *     email: varchar('email', { length: 255 }).notNull().unique(),
 *     createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
 *   });
 *   module.exports = { users };
 *
 * Supabase tip: enable Row-Level Security (RLS) on every table and define
 * policies in a companion SQL migration — Drizzle does not manage RLS for you.
 */
module.exports = {};
