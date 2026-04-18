const postgres = require('postgres');
const { drizzle } = require('drizzle-orm/postgres-js');
const { sql } = require('drizzle-orm');

(async () => {
  const url = process.env.POSTGRES_URL;
  const pg = postgres(url, { max: 1, prepare: false });
  const db = drizzle(pg);
  try {
    const result = await db.transaction(async (tx) => {
      await tx.execute(sql`SELECT set_config('app.org_id', '00000000-0000-4000-8000-000000000001', true)`);
      const rows = await tx.execute(sql`SELECT current_setting('app.org_id', true) AS org`);
      return rows;
    });
    console.log('tx ok, rows:', result);
  } catch (err) {
    console.error('ERR:', err.message);
    console.error(err.stack);
  } finally {
    await pg.end({ timeout: 5 });
  }
})();
