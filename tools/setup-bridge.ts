import { BASE_DB } from './lib/config.js';
import { connect } from './lib/db.js';
import { handleFatal } from './lib/errors.js';
import { green } from './lib/ui.js';

/** Deterministic: no random(), no now(). ~200k rows so the planner has a real choice to make. */
const SQL = `
BEGIN;
DROP TABLE IF EXISTS page_views;
CREATE TABLE page_views (
  view_id     integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id integer     NOT NULL,
  product_id  integer     NOT NULL,
  viewed_at   timestamptz NOT NULL,
  device      text        NOT NULL,
  duration_ms integer     NOT NULL
);
INSERT INTO page_views (customer_id, product_id, viewed_at, device, duration_ms)
SELECT (g * 7919) % 300 + 1,
       (g * 104729) % 72 + 1,
       timestamptz '2024-01-01 00:00:00+00' + (g * 263 % 63072000) * interval '1 second',
       (ARRAY['desktop', 'mobile', 'tablet'])[(g * 31) % 3 + 1],
       (g * 8191) % 120000
FROM generate_series(1::bigint, 200000) AS g;
COMMIT;
ANALYZE page_views;
`;

async function main(): Promise<void> {
  const db = await connect(BASE_DB, { timeoutMs: 0 });
  try {
    await db.query(SQL);
    const r = await db.query('SELECT count(*) AS n FROM page_views');
    console.log(green('✓'), `Table page_views created in "${BASE_DB}" (${r.rows[0]?.n} rows). You can start module 10.`);
  } finally {
    await db.end();
  }
}

main().catch(handleFatal);
