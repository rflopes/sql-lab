import { readFileSync } from 'node:fs';
import path from 'node:path';
import { BASE_DB, DATA_DIR, MIN_SERVER_VERSION_NUM } from './config.js';
import { connect, createDatabase, dropDatabase, connectAdmin, PLAY_DB } from './db.js';
import type pg from 'pg';

export async function assertServerVersion(admin: pg.Client): Promise<string> {
  const r = await admin.query<{ num: string; text: string; super: boolean }>(
    `SELECT current_setting('server_version_num') AS num,
            current_setting('server_version') AS text,
            (SELECT rolsuper FROM pg_roles WHERE rolname = current_user) AS super`,
  );
  const row = r.rows[0];
  if (!row) throw new Error('Could not read the server version.');
  if (Number(row.num) < MIN_SERVER_VERSION_NUM) {
    throw new Error(
      `PostgreSQL ${row.text} is too old for this project (needs 13+: window functions, recursive CTEs, FILTER, identity columns, RETURNING).`,
    );
  }
  if (row.super) {
    console.warn('Warning: you are connected as a superuser. A dedicated role with only LOGIN and CREATEDB is recommended (see README).');
  }
  return row.text;
}

/** Creates `sqllab` (C collation) and loads schema.sql + seed.sql. Fails if it already exists. */
export async function buildBaseDatabase(admin: pg.Client): Promise<void> {
  await createDatabase(admin, BASE_DB, null);
  const db = await connect(BASE_DB, { timeoutMs: 0 });
  try {
    const schema = readFileSync(path.join(DATA_DIR, 'schema.sql'), 'utf8');
    const seed = readFileSync(path.join(DATA_DIR, 'seed.sql'), 'utf8');
    await db.query(`BEGIN;\n${schema}\n${seed}\nCOMMIT;`);
    await db.query('ANALYZE');
  } catch (error) {
    await db.end();
    await dropDatabase(admin, BASE_DB, true);
    throw error;
  }
  await db.end();
}

/** Drops sqllab and its disposable play copy. */
export async function dropBaseDatabases(): Promise<void> {
  const admin = await connectAdmin();
  try {
    await dropDatabase(admin, PLAY_DB, true);
    await dropDatabase(admin, BASE_DB, true);
  } finally {
    await admin.end();
  }
}
