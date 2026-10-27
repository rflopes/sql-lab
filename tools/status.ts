import { listExercises, moduleTitle } from './lib/exercises.js';
import { readProgress } from './lib/progress.js';
import { bar, bold, cyan, dim, green } from './lib/ui.js';

const exercises = listExercises();
const done = readProgress().done;

const modules = [...new Set(exercises.map((e) => e.module))].sort();
let totalDone = 0;
let total = 0;

console.log(`\n${bold('sql-lab progress')}\n`);
for (const mm of modules) {
  const all = exercises.filter((e) => e.module === mm);
  const required = all.filter((e) => !e.optional);
  const pool = required.length > 0 ? required : all;
  const n = pool.filter((e) => done[e.id]).length;
  totalDone += n;
  total += pool.length;
  const name = moduleTitle(mm, all[0]?.moduleName ?? '');
  const tag = required.length === 0 ? dim(' (optional)') : '';
  console.log(`  ${mm}  ${name.padEnd(24)} ${bar(n, pool.length)}  ${String(n).padStart(2)}/${pool.length}${tag}${n === pool.length ? ` ${green('✓')}` : ''}`);
}
console.log(`\n  ${bold('Total')}  ${bar(totalDone, total, 30)}  ${totalDone}/${total}`);

const next = exercises.find((e) => !done[e.id]);
console.log(next ? `\n  Next up: ${cyan(next.id)}  (${next.file.replace(/^.*\/modules\//, 'modules/')})\n` : `\n  ${green('Everything is green.')}\n`);
