import { readdirSync, readFileSync, existsSync } from 'node:fs';
import path from 'node:path';
import { CHECKS_DIR, MODULES_DIR } from './config.js';

export type ExerciseType = 'QUERY' | 'DEBUG' | 'PREDICT' | 'DML' | 'DDL';

export interface Exercise {
  id: string;
  module: string;
  moduleDir: string;
  moduleName: string;
  type: ExerciseType;
  optional: boolean;
  file: string;
}

const HEADER_RE = /^--\s+(\d{2})-(\d{2})\s+(QUERY|DEBUG|PREDICT|DML|DDL)(\s+\(optional\))?/;

export function listExercises(): Exercise[] {
  if (!existsSync(MODULES_DIR)) return [];
  const result: Exercise[] = [];
  for (const dir of readdirSync(MODULES_DIR).sort()) {
    const moduleMatch = /^(\d{2})-(.+)$/.exec(dir);
    if (!moduleMatch) continue;
    const full = path.join(MODULES_DIR, dir);
    for (const name of readdirSync(full).sort()) {
      if (!name.endsWith('.sql')) continue;
      const file = path.join(full, name);
      const first = readFileSync(file, 'utf8').split('\n', 1)[0] ?? '';
      const m = HEADER_RE.exec(first);
      if (!m) continue;
      result.push({
        id: `${m[1]}-${m[2]}`,
        module: m[1] as string,
        moduleDir: dir,
        moduleName: (moduleMatch[2] as string).replace(/-/g, ' '),
        type: m[3] as ExerciseType,
        optional: m[4] !== undefined,
        file,
      });
    }
  }
  return result;
}

const MODULE_TITLES: Record<string, string> = {
  '01': 'Introduction',
  '02': 'SQL Basics',
  '03': 'Manipulating Data',
  '04': 'Defining Tables',
  '05': 'Multi-Table Queries',
  '06': 'Aggregate Functions',
  '07': 'Scalar Functions',
  '08': 'Subqueries and CTEs',
  '09': 'Window Functions',
  '10': 'Bridge',
};

export function moduleTitle(module: string, fallback: string): string {
  return MODULE_TITLES[module] ?? fallback.replace(/^./, (c) => c.toUpperCase());
}

export function moduleLabel(ex: Exercise): string {
  return moduleTitle(ex.module, ex.moduleName);
}

export interface ResultSpec {
  columns: string[];
  rowCount: number;
  /** Hash of the whole (order-insensitive) result. */
  hash: string;
  /** One hash per row, in reference order. */
  rowHashes: string[];
}

export type VerifyStep =
  | { kind: 'result'; label: string; sql: string; expected: ResultSpec }
  | { kind: 'fails'; label: string; sql: string; code?: string }
  | { kind: 'works'; label: string; sql: string };

export type CheckSpec =
  | { kind: 'result'; orderMatters: boolean; expected: ResultSpec }
  | { kind: 'script'; verify: VerifyStep[]; returns?: ResultSpec }
  | { kind: 'predict-rows' }
  | { kind: 'predict-plan'; table: string };

export function loadCheck(id: string): CheckSpec {
  const file = path.join(CHECKS_DIR, `${id}.json`);
  if (!existsSync(file)) throw new Error(`No check file for ${id} (checks/${id}.json is missing).`);
  return JSON.parse(readFileSync(file, 'utf8')) as CheckSpec;
}
