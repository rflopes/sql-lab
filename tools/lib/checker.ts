import type pg from 'pg';
import { BASE_DB } from './config.js';
import { connect, createDatabase, dropDatabase, newCheckDbName } from './db.js';
import { loadCheck, type Exercise } from './exercises.js';
import { compare, normalize } from './result.js';
import { forbiddenReason, inOpenTransaction, lastRowsResult, runScript, stripComments } from './run.js';

export interface Outcome {
  passed: boolean;
  /** Not a failure: the exercise is waiting for something from the student (e.g. a prediction). */
  pending?: boolean;
  lines: string[];
}

const fail = (...lines: string[]): Outcome => ({ passed: false, lines });

/** Runs `fn` against a throwaway copy of the base database and always drops it afterwards. */
export async function withTempDb<T>(admin: pg.Client, fn: (database: string) => Promise<T>): Promise<T> {
  const name = newCheckDbName();
  try {
    await createDatabase(admin, name, BASE_DB);
  } catch (err) {
    const code = (err as { code?: string }).code;
    if (code === '3D000') throw new Error('The base database "sqllab" does not exist. Run: pnpm run setup');
    if (code === '55006') {
      throw new Error(
        'Another session is connected to "sqllab" (the template for every check). Close it. For free exploration use "pnpm sql", which works on a copy.',
      );
    }
    throw err;
  }
  try {
    return await fn(name);
  } finally {
    await dropDatabase(admin, name, true).catch(() => undefined);
  }
}

export async function evaluate(ex: Exercise, text: string, admin: pg.Client): Promise<Outcome> {
  const spec = loadCheck(ex.id);
  const code = stripComments(text).trim();

  if (spec.kind !== 'predict-rows' && spec.kind !== 'predict-plan' && code === '') {
    return fail('Nothing to check yet: write your SQL below the "Write your query below" line.');
  }
  const forbidden = forbiddenReason(text);
  if (forbidden) return fail(forbidden);

  return withTempDb(admin, async (database) => {
    if (spec.kind === 'result') return evaluateResult(spec, text, database);
    if (spec.kind === 'script') return evaluateScript(spec, text, database);
    const guess = /^--\s*GUESS:[ \t]*(.*)$/im.exec(text)?.[1]?.trim() ?? '';
    if (guess === '') return { passed: false, pending: true, lines: ['Write your prediction first, on the "-- GUESS:" line, then run the check again.'] };
    return spec.kind === 'predict-rows'
      ? evaluatePredictRows(guess, text, database)
      : evaluatePredictPlan(guess, spec.table, text, database);
  });
}

async function evaluateResult(
  spec: Extract<ReturnType<typeof loadCheck>, { kind: 'result' }>,
  text: string,
  database: string,
): Promise<Outcome> {
  const db = await connect(database, { raw: true });
  try {
    const run = await runScript(db, text);
    if (!run.ok) return fail(run.message);
    const rows = lastRowsResult(run.results);
    if (!rows) return fail('Your file must contain a query that returns rows (end it with a SELECT).');
    const cmp = compare(normalize(rows), spec.expected, spec.orderMatters);
    return { passed: cmp.ok, lines: cmp.lines };
  } finally {
    await db.end();
  }
}

async function evaluateScript(
  spec: Extract<ReturnType<typeof loadCheck>, { kind: 'script' }>,
  text: string,
  database: string,
): Promise<Outcome> {
  const { verify } = spec;
  const runner = await connect(database, { raw: true });
  let note: string | null = null;
  try {
    const run = await runScript(runner, text);
    if (!run.ok) return fail('Your script stopped with an error (nothing after it ran):', run.message);
    if (spec.returns) {
      const rows = lastRowsResult(run.results);
      const cmp = rows ? compare(normalize(rows), spec.returns, false) : null;
      if (!cmp) return fail('This exercise also expects your script to return rows (for example with RETURNING), but none came back.');
      if (!cmp.ok) return fail('The rows your script returns are not as expected:', ...cmp.lines.map((l) => `  ${l}`));
    }
    if (await inOpenTransaction(runner)) {
      note = 'Your script ended inside a transaction that was never committed, so its changes were discarded.';
    }
  } finally {
    await runner.end();
  }

  const checker = await connect(database, { raw: true });
  const problems: string[] = [];
  try {
    for (const [i, step] of verify.entries()) {
      const tag = `Check ${i + 1}/${verify.length} (${step.label})`;
      await checker.query('BEGIN');
      try {
        if (step.kind === 'result') {
          const res = await checker.query({ text: step.sql, rowMode: 'array' });
          const cmp = compare(normalize(res as pg.QueryResult<unknown[]>), step.expected, false);
          if (!cmp.ok) problems.push(`${tag}: not as expected.`, ...cmp.lines.map((l) => `  ${l}`));
        } else if (step.kind === 'works') {
          await checker.query(step.sql).catch((e: Error) => problems.push(`${tag}: this should work but failed: ${e.message}`));
        } else {
          let rejected: { code?: string } | null = null;
          await checker.query(step.sql).catch((e: { code?: string }) => (rejected = e));
          if (!rejected) problems.push(`${tag}: this statement should have been rejected by the database, but it was accepted.`);
          else if (step.code && (rejected as { code?: string }).code !== step.code) {
            problems.push(`${tag}: rejected, but for a different reason than expected (SQLSTATE ${(rejected as { code?: string }).code}).`);
          }
        }
      } catch (err) {
        problems.push(`${tag}: could not be evaluated (${(err as Error).message}).`);
      } finally {
        await checker.query('ROLLBACK').catch(() => undefined);
      }
    }
  } finally {
    await checker.end();
  }
  if (problems.length > 0 && note) problems.push(note);
  return { passed: problems.length === 0, lines: problems };
}

async function evaluatePredictRows(guess: string, text: string, database: string): Promise<Outcome> {
  const n = Number(guess);
  if (!Number.isInteger(n) || n < 0) return { passed: false, pending: true, lines: [`"-- GUESS: ${guess}" is not a row count. Write a whole number.`] };
  const db = await connect(database, { raw: true });
  try {
    const run = await runScript(db, text);
    if (!run.ok) return fail(run.message);
    const rows = lastRowsResult(run.results);
    if (!rows) return fail('The file has no query that returns rows.');
    const actual = rows.rows.length;
    const diff = actual - n;
    return {
      passed: true,
      lines: [diff === 0 ? `Spot on: the query returns ${actual} rows.` : `You guessed ${n}, the query returns ${actual} rows (off by ${Math.abs(diff)}). Why? Worth a line in GOTCHAS.md.`],
    };
  } finally {
    await db.end();
  }
}

interface PlanNode {
  'Node Type': string;
  'Relation Name'?: string;
  Plans?: PlanNode[];
}

function findScan(node: PlanNode, table: string): PlanNode | null {
  if (node['Relation Name'] === table) return node;
  for (const child of node.Plans ?? []) {
    const hit = findScan(child, table);
    if (hit) return hit;
  }
  return null;
}

async function evaluatePredictPlan(guess: string, table: string, text: string, database: string): Promise<Outcome> {
  const db = await connect(database, { raw: true });
  try {
    const exists = await db.query('SELECT to_regclass($1) IS NOT NULL AS ok', [table]);
    if (exists.rows[0]?.ok !== 't') return fail(`The table "${table}" does not exist yet. Run: pnpm run setup:bridge`);
    await db.query(`ANALYZE ${table}`);
    const query = stripComments(text).trim().replace(/;\s*$/, '');
    const res = await db.query({ text: `EXPLAIN (FORMAT JSON) ${query}`, rowMode: 'array' });
    const plan = JSON.parse(String((res.rows[0] as string[])[0])) as { Plan: PlanNode }[];
    const scan = findScan((plan[0] as { Plan: PlanNode }).Plan, table);
    if (!scan) return fail(`The plan has no scan of "${table}".`);
    const actual = scan['Node Type'].replace(/^Parallel /, '');
    const same = actual.toLowerCase() === guess.replace(/\s+/g, ' ').toLowerCase();
    return {
      passed: true,
      lines: [same ? `Spot on: the planner chose "${actual}".` : `You guessed "${guess}", the planner chose "${actual}". Why? Worth a line in GOTCHAS.md.`],
    };
  } finally {
    await db.end();
  }
}
