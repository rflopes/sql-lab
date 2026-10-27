import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

export const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
export const MODULES_DIR = path.join(ROOT, 'modules');
export const CHECKS_DIR = path.join(ROOT, 'checks');
export const DATA_DIR = path.join(ROOT, 'data');
export const PROGRESS_FILE = path.join(ROOT, 'progress.json');
export const CONSENT_FILE = path.join(ROOT, '.setup-confirmed');
export const PSQLRC = path.join(ROOT, '.psqlrc');

/** The only database names this project is allowed to touch. */
export const BASE_DB = 'sqllab';
export const PLAY_DB = 'sqllab_play';
export const CHECK_DB_PREFIX = 'sqllab_chk_';

export const STATEMENT_TIMEOUT_MS = 5000;
export const MIN_SERVER_VERSION_NUM = 130000;

export interface ServerConfig {
  host: string;
  port: number;
  user: string;
  password: string | undefined;
}

export class ConfigError extends Error {}

const envPath = path.join(ROOT, '.env');
if (existsSync(envPath)) process.loadEnvFile(envPath);

/** Reads the connection from SQLLAB_DATABASE_URL or PG* variables. Never guesses. */
export function serverConfig(): ServerConfig {
  const url = process.env['SQLLAB_DATABASE_URL'];
  if (url) {
    let parsed: URL;
    try {
      parsed = new URL(url);
    } catch {
      throw new ConfigError('SQLLAB_DATABASE_URL is not a valid URL (expected postgresql://user:pass@host:port/).');
    }
    const port = Number(parsed.port);
    if (!parsed.hostname || !parsed.username || !Number.isInteger(port) || port <= 0) {
      throw new ConfigError('SQLLAB_DATABASE_URL must include user, host and port.');
    }
    return {
      host: parsed.hostname,
      port,
      user: decodeURIComponent(parsed.username),
      password: parsed.password ? decodeURIComponent(parsed.password) : undefined,
    };
  }

  const host = process.env['PGHOST'];
  const portRaw = process.env['PGPORT'];
  const user = process.env['PGUSER'];
  const missing = [!host && 'PGHOST', !portRaw && 'PGPORT', !user && 'PGUSER'].filter(Boolean);
  if (missing.length > 0) {
    throw new ConfigError(
      `Missing connection settings: ${missing.join(', ')}.\n` +
        'Copy .env.example to .env and fill it in (see README.md, "Connect to your local server").',
    );
  }
  const port = Number(portRaw);
  if (!Number.isInteger(port) || port <= 0) throw new ConfigError(`PGPORT must be a number, got "${portRaw}".`);
  return { host: host as string, port, user: user as string, password: process.env['PGPASSWORD'] || undefined };
}
