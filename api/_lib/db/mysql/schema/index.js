/**
 * Drizzle MySQL schema entry point.
 *
 * Each domain defines its table in its own file under this directory, then
 * re-exports from here so `drizzle-kit` picks them up via a single path.
 *
 * Example:
 *   const { mysqlTable, varchar, timestamp } = require('drizzle-orm/mysql-core');
 *   const users = mysqlTable('users', {
 *     id: varchar('id', { length: 36 }).primaryKey(),
 *     createdAt: timestamp('created_at').notNull().defaultNow(),
 *   });
 *   module.exports = { users };
 */
module.exports = {};
