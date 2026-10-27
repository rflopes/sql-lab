import { ConfigError } from './config.js';
import { fail } from './ui.js';

export function handleFatal(err: unknown): never {
  if (err instanceof ConfigError) fail(err.message);
  const e = err as { code?: string; message?: string };
  if (e.code === 'ECONNREFUSED') fail('Could not reach the PostgreSQL server (connection refused). Is it running? Check host/port in .env.');
  if (e.code === '28P01' || e.code === '28000') fail(`Authentication failed: ${e.message ?? ''}\nCheck PGUSER/PGPASSWORD in .env.`);
  if (e.code === '42501') fail(`Permission denied: ${e.message ?? ''}\nThe role needs LOGIN and CREATEDB (see README).`);
  fail(e.message ?? String(err));
}
