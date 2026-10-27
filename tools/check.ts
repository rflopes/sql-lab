import { readFileSync } from 'node:fs';
import { evaluate, type Outcome } from './lib/checker.js';
import { ConfigError } from './lib/config.js';
import { cleanupStaleChecks, connectAdmin } from './lib/db.js';
import { listExercises, moduleLabel, type Exercise } from './lib/exercises.js';
import { markDone, readProgress } from './lib/progress.js';
import { bar, bold, cyan, dim, fail, green, red, yellow } from './lib/ui.js';

const args = process.argv.slice(2);
const exercises = listExercises();

function moduleProgress(module: string): { done: number; total: number } {
  const all = exercises.filter((e) => e.module === module && !e.optional);
  const done = readProgress().done;
  return { done: all.filter((e) => done[e.id]).length, total: all.length };
}

function printOutcome(ex: Exercise, outcome: Outcome): void {
  const title = `${ex.id}  ${ex.type}${ex.optional ? ' (optional)' : ''}`;
  if (outcome.pending) {
    console.log(`${yellow('…')} ${bold(title)}  ${dim('waiting for you')}`);
  } else {
    console.log(`${outcome.passed ? green('✓') : red('✗')} ${bold(title)}${outcome.passed ? '' : '  not there yet'}`);
  }
  for (const line of outcome.lines) console.log(`    ${line.replace(/\n/g, '\n    ')}`);
}

function afterPass(ex: Exercise): void {
  markDone(ex.id);
  const { done, total } = moduleProgress(ex.module);
  console.log(`    ${green('Nice.')} Module ${ex.module} ${moduleLabel(ex)}: ${bar(done, total, 16)} ${done}/${total}`);
}

async function main(): Promise<void> {
  if (args.length === 0) {
    fail('Usage: pnpm check <id>   (for example: pnpm check 05-07)\n       pnpm check module <MM>');
  }

  let selected: Exercise[];
  if (args[0] === 'module') {
    const mm = (args[1] ?? '').padStart(2, '0');
    selected = exercises.filter((e) => e.module === mm);
    if (selected.length === 0) fail(`No exercises found for module "${args[1] ?? ''}".`);
  } else {
    const found = exercises.find((e) => e.id === args[0]);
    if (!found) fail(`Unknown exercise "${args[0]}". Ids look like 05-07.`);
    selected = [found];
  }

  const admin = await connectAdmin();
  try {
    await cleanupStaleChecks(admin);
    let passed = 0;
    for (const ex of selected) {
      const outcome = await evaluate(ex, readFileSync(ex.file, 'utf8'), admin);
      printOutcome(ex, outcome);
      if (outcome.passed) {
        passed++;
        afterPass(ex);
      }
    }
    if (selected.length > 1) {
      console.log(`\n${cyan(`Module ${selected[0]?.module}`)}: ${passed}/${selected.length} exercises green in this run.`);
    }
  } finally {
    await admin.end();
  }
}

main().catch((err: unknown) => {
  if (err instanceof ConfigError) fail(err.message);
  const e = err as { code?: string; message: string };
  if (e.code === 'ECONNREFUSED') fail('Could not reach the PostgreSQL server (connection refused). Is it running? Check host/port in .env.');
  if (e.code === '28P01' || e.code === '28000') fail(`Authentication failed: ${e.message}. Check PGUSER/PGPASSWORD in .env.`);
  fail(e.message);
});
