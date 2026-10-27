import type pg from 'pg';

export type ScriptOutcome = { ok: true; results: pg.QueryResult<unknown[]>[] } | { ok: false; message: string };

export function stripComments(sql: string): string {
  return sql.replace(/\/\*[\s\S]*?\*\//g, '').replace(/--[^\n]*/g, '');
}

const FORBIDDEN = [
  /\b(create|drop|alter)\s+(database|role|user|tablespace)\b/i,
  /\bset\s+(session\s+authorization|role)\b/i,
  /\bpg_terminate_backend\b/i,
  /^\s*\\/m,
];

/** Exercises run in a throwaway copy, but they must not reach beyond it. */
export function forbiddenReason(sql: string): string | null {
  const code = stripComments(sql);
  return FORBIDDEN.some((re) => re.test(code))
    ? 'Your file contains a statement that is not allowed here (database/role administration, role switching or psql meta-commands). Exercises only use plain SQL on the tables.'
    : null;
}

interface PgError extends Error {
  code?: string;
  position?: string;
  hint?: string;
  detail?: string;
}

export function formatPgError(err: unknown, sql: string): string {
  const e = err as PgError;
  if (e.code === '57014') {
    return 'The statement ran longer than 5 seconds and was cancelled. Look for a missing join condition (a cartesian product) or an accidental huge result.';
  }
  const out = [`ERROR${e.code ? ` [${e.code}]` : ''}: ${e.message}`];
  const pos = e.position ? Number(e.position) : NaN;
  if (Number.isInteger(pos) && pos > 0) {
    const before = sql.slice(0, pos - 1);
    const line = before.split('\n').length;
    const col = pos - before.lastIndexOf('\n') - 1;
    const text = sql.split('\n')[line - 1] ?? '';
    out.push(`  at line ${line}, column ${col}:`, `    ${text}`, `    ${' '.repeat(Math.max(col - 1, 0))}^`);
  }
  if (e.detail) out.push(`  DETAIL: ${e.detail}`);
  if (e.hint) out.push(`  HINT: ${e.hint}`);
  return out.join('\n');
}

/** Runs all statements of `sql` in one simple-query round trip. */
export async function runScript(client: pg.Client, sql: string): Promise<ScriptOutcome> {
  try {
    const res = await client.query({ text: sql, rowMode: 'array' });
    const results = (Array.isArray(res) ? res : [res]) as pg.QueryResult<unknown[]>[];
    return { ok: true, results };
  } catch (err) {
    return { ok: false, message: formatPgError(err, sql) };
  }
}

/** The last statement that returned columns. */
export function lastRowsResult(results: pg.QueryResult<unknown[]>[]): pg.QueryResult<unknown[]> | undefined {
  return results.filter((r) => r.fields.length > 0).at(-1);
}

export async function inOpenTransaction(client: pg.Client): Promise<boolean> {
  try {
    const r = await client.query('SELECT now() <> statement_timestamp() AS open');
    return r.rows[0]?.open === true || r.rows[0]?.open === 't';
  } catch {
    return false;
  }
}
