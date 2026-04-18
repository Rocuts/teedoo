const postgres = require('postgres');
(async () => {
  const url = process.env.POSTGRES_URL;
  const sql = postgres(url, { max: 1, prepare: false });
  try {
    const [a] = await sql`SELECT current_setting('app.org_id', true) AS v, current_setting('app.org_id', true) IS NULL AS is_null, current_setting('app.org_id', true) = '' AS is_empty`;
    console.log('setting:', a);
    try {
      const [b] = await sql`SELECT ''::uuid AS x`;
      console.log('empty cast:', b);
    } catch (err) {
      console.log('empty cast err:', err.message);
    }
    // What does RLS actually apply? Fetch rows via explicit predicate match.
    const [c] = await sql`SELECT pg_has_role(current_user, 'postgres', 'MEMBER') AS is_owner`;
    console.log('owner?', c);
    const [d] = await sql`SELECT usename, usesuper, userepl, usebypassrls FROM pg_user WHERE usename = current_user`;
    console.log('user row:', d);
  } finally {
    await sql.end({ timeout: 5 });
  }
})();
