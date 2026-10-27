import { createHash } from 'node:crypto';
import type pg from 'pg';
import type { ResultSpec } from './exercises.js';

export type Value = string | number | boolean | null;

export interface Normalized {
  columns: string[];
  rows: Value[][];
}

const NUMERIC_OIDS = new Set([20, 21, 23, 26, 700, 701, 1700]);
const BOOL_OID = 16;
const TIMESTAMPTZ_OID = 1184;

function normalizeValue(raw: string | null, oid: number): Value {
  if (raw === null) return null;
  if (oid === BOOL_OID) return raw === 't';
  if (NUMERIC_OIDS.has(oid)) {
    const n = Number(raw);
    if (Number.isNaN(n) || !Number.isFinite(n)) return raw;
    const rounded = Math.round(n * 100) / 100;
    return rounded === 0 ? 0 : rounded;
  }
  if (oid === TIMESTAMPTZ_OID) {
    const iso = raw.replace(' ', 'T').replace(/([+-]\d{2})$/, '$1:00');
    const d = new Date(iso);
    return Number.isNaN(d.getTime()) ? raw : d.toISOString();
  }
  return raw;
}

/** Expects a result fetched with rowMode "array" on a connection that returns raw strings. */
export function normalize(result: pg.QueryResult<unknown[]>): Normalized {
  const oids = result.fields.map((f) => f.dataTypeID);
  return {
    columns: result.fields.map((f) => f.name.toLowerCase()),
    rows: (result.rows as (string | null)[][]).map((row) => row.map((v, i) => normalizeValue(v, oids[i] as number))),
  };
}

const sha = (s: string): string => createHash('sha256').update(s).digest('hex').slice(0, 16);

export const rowHash = (row: Value[]): string => sha(JSON.stringify(row));

/** Builds the expected-result record that is stored (hashes only) in checks/. */
export function specFrom(n: Normalized): ResultSpec {
  const rowHashes = n.rows.map(rowHash);
  return { columns: n.columns, rowCount: n.rows.length, hash: sha([...rowHashes].sort().join(',')), rowHashes };
}

export interface Comparison {
  ok: boolean;
  lines: string[];
}

function show(columns: string[], row: Value[]): string {
  return `{ ${columns.map((c, i) => `${c}: ${JSON.stringify(row[i])}`).join(', ')} }`;
}

export function compare(actual: Normalized, expected: ResultSpec, orderMatters: boolean): Comparison {
  const lines: string[] = [];
  const dup = actual.columns.find((c, i) => actual.columns.indexOf(c) !== i);
  if (dup !== undefined) {
    return { ok: false, lines: [`Your result has two columns named "${dup}". Give each column its own name (alias).`] };
  }

  const missing = expected.columns.filter((c) => !actual.columns.includes(c));
  const extra = actual.columns.filter((c) => !expected.columns.includes(c));
  if (missing.length > 0 || extra.length > 0) {
    if (missing.length > 0) lines.push(`Missing column(s): ${missing.join(', ')}`);
    if (extra.length > 0) lines.push(`Unexpected column(s): ${extra.join(', ')}`);
    lines.push(`Rows: expected ${expected.rowCount}, got ${actual.rows.length}`);
    return { ok: false, lines };
  }

  const order = expected.columns.map((c) => actual.columns.indexOf(c));
  const rows = actual.rows.map((r) => order.map((i) => r[i] as Value));
  const hashes = rows.map(rowHash);

  if (rows.length !== expected.rowCount) lines.push(`Rows: expected ${expected.rowCount}, got ${rows.length}`);

  const remaining = new Map<string, number>();
  for (const h of expected.rowHashes) remaining.set(h, (remaining.get(h) ?? 0) + 1);
  const notExpected: number[] = [];
  hashes.forEach((h, i) => {
    const left = remaining.get(h) ?? 0;
    if (left > 0) remaining.set(h, left - 1);
    else notExpected.push(i);
  });
  const absent = [...remaining.values()].reduce((a, b) => a + b, 0);

  if (notExpected.length > 0) {
    lines.push(`${notExpected.length} of your rows are not in the expected result, for example:`);
    for (const i of notExpected.slice(0, 3)) lines.push(`    ${show(expected.columns, rows[i] as Value[])}`);
  }
  if (absent > 0) lines.push(`${absent} expected row(s) are missing from your result.`);

  if (lines.length === 0 && orderMatters) {
    const k = hashes.findIndex((h, i) => h !== expected.rowHashes[i]);
    if (k !== -1) {
      lines.push(`The rows are right but the order is not. First difference at row ${k + 1}; your row ${k + 1}:`);
      lines.push(`    ${show(expected.columns, rows[k] as Value[])}`);
    }
  }
  return { ok: lines.length === 0, lines };
}
