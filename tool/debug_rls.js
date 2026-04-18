const postgres = require('postgres');

(async () => {
  const url = process.env.POSTGRES_URL;
  const sql = postgres(url, { max: 1, prepare: false });
  try {
    const [who] = await sql`SELECT current_user, current_setting('is_superuser') AS su, current_setting('app.org_id', true) AS org`;
    console.log('pooled current_user:', who);
    const [c1] = await sql`SELECT count(*)::int AS n FROM invoices`;
    console.log('pooled invoices count (no GUC):', c1.n);

    // Check RLS settings
    const rls = await sql`SELECT relname, relrowsecurity, relforcerowsecurity FROM pg_class WHERE relname IN ('invoices','parties')`;
    console.log('RLS flags:', rls);

    const pol = await sql`SELECT schemaname, tablename, policyname, roles, cmd, qual FROM pg_policies WHERE tablename IN ('invoices','parties')`;
    console.log('policies:', pol);
  } finally {
    await sql.end({ timeout: 5 });
  }
})();
