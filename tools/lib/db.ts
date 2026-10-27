import pg from 'pg';
import { randomBytes } from 'node:crypto';
import {
  BASE_DB,
  CHECK_DB_PREFIX,
  PLAY_DB,
  STATEMENT_TIMEOUT_MS,
  serverConfig,
  type ServerConfig,
} from './config.js';

const PROJECT_DB_RE = /^sqllab(_[a-z0-9]+)*$/;

/** Fails closed: every CREATE/DROP DATABASE goes through this guard. */
export function assertProjectDb(name: string): void {
  if (!PROJECT_DB_RE.test(name)) {
    throw new Error(`Refusing to touch database "${name}": this project only operates on databases named sqllab*.`);
  }
}

/** Raw strings for every type; the checker normalizes by type id itself. */
const rawTypes: pg.ClientConfig['types'] = {
  getTypeParser: (() => (value: string) => value) as unknown as NonNullable<pg.ClientConfig['types']>['getTypeParser'],
};

export interface ConnectOptions {
  /** Statement timeout in ms; 0 disables it. */
  timeoutMs?: number;
  raw?: boolean;
}

export async function connect(database: string, options: ConnectOptions = {}): Promise<pg.Client> {
  const cfg: ServerConfig = serverConfig();
  const client = new pg.Client({
    host: cfg.host,
    port: cfg.port,
    user: cfg.user,
    password: cfg.password,
    database,
    options: '-c TimeZone=UTC',
    statement_timeout: options.timeoutMs ?? STATEMENT_TIMEOUT_MS,
    connectionTimeoutMillis: 5000,
    ...(options.raw ? { types: rawTypes } : {}),
  });
  client.on('error', () => {
    /* connection-level errors surface through the pending query */
  });
  await client.connect();
  return client;
}

/** Maintenance connection, used only to issue guarded CREATE/DROP DATABASE statements. */
export function connectAdmin(): Promise<pg.Client> {
  return connect('postgres', { timeoutMs: 0 });
}

const ident = (name: string): string => `"${name.replace(/"/g, '""')}"`;

export async function databaseExists(admin: pg.Client, name: string): Promise<boolean> {
  const r = await admin.query('SELECT 1 FROM pg_database WHERE datname = $1', [name]);
  return r.rowCount === 1;
}

export async function isOwnedByMe(admin: pg.Client, name: string): Promise<boolean> {
  const r = await admin.query(
    'SELECT pg_get_userbyid(datdba) = current_user AS mine FROM pg_database WHERE datname = $1',
    [name],
  );
  return r.rows[0]?.mine === true;
}

/** Creates `name`, as a copy of `template` or (base database) from template0 with the C collation. */
export async function createDatabase(admin: pg.Client, name: string, template: string | null): Promise<void> {
  assertProjectDb(name);
  if (template === null) {
    await admin.query(
      `CREATE DATABASE ${ident(name)} TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'C' LC_CTYPE 'C'`,
    );
  } else {
    assertProjectDb(template);
    await admin.query(`CREATE DATABASE ${ident(name)} TEMPLATE ${ident(template)}`);
  }
}

/** Drops a database only if it exists and was created by the current role. */
export async function dropDatabase(admin: pg.Client, name: string, force = false): Promise<void> {
  assertProjectDb(name);
  if (!(await databaseExists(admin, name))) return;
  if (!(await isOwnedByMe(admin, name))) {
    throw new Error(`Database "${name}" is not owned by the current role; refusing to drop it.`);
  }
  await admin.query(`DROP DATABASE ${ident(name)}${force ? ' WITH (FORCE)' : ''}`);
}

/** Removes leftover sqllab_chk_* databases (best effort; databases still in use are skipped). */
export async function cleanupStaleChecks(admin: pg.Client): Promise<void> {
  const r = await admin.query<{ datname: string }>(
    `SELECT datname FROM pg_database
      WHERE datname LIKE 'sqllab\\_chk\\_%' AND pg_get_userbyid(datdba) = current_user`,
  );
  for (const { datname } of r.rows) {
    try {
      await dropDatabase(admin, datname);
    } catch {
      /* in use by a concurrent check, leave it */
    }
  }
}

export function newCheckDbName(): string {
  return `${CHECK_DB_PREFIX}${randomBytes(4).toString('hex')}`;
}

export { BASE_DB, PLAY_DB };
