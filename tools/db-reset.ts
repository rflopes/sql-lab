import { BASE_DB, PLAY_DB } from './lib/config.js';
import { assertServerVersion, buildBaseDatabase, dropBaseDatabases } from './lib/build.js';
import { connectAdmin } from './lib/db.js';
import { handleFatal } from './lib/errors.js';
import { confirm, hasFlag } from './lib/prompt.js';
import { fail, green, yellow } from './lib/ui.js';

async function main(): Promise<void> {
  console.log(yellow(`This drops "${BASE_DB}" and "${PLAY_DB}" (only if this role created them) and rebuilds "${BASE_DB}" from data/.`));
  console.log('If you had run "pnpm run setup:bridge", run it again afterwards.\n');
  if (!(await confirm('Rebuild from scratch?', hasFlag('--yes')))) fail('Cancelled. Nothing was changed.');

  await dropBaseDatabases();
  const admin = await connectAdmin();
  try {
    await assertServerVersion(admin);
    await buildBaseDatabase(admin);
  } finally {
    await admin.end();
  }
  console.log(green('✓'), `Database "${BASE_DB}" rebuilt.`);
}

main().catch(handleFatal);
