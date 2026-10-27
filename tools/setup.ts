import { spawnSync } from 'node:child_process';
import { writeFileSync, existsSync } from 'node:fs';
import { BASE_DB, CONSENT_FILE, serverConfig } from './lib/config.js';
import { assertServerVersion, buildBaseDatabase } from './lib/build.js';
import { connectAdmin, databaseExists } from './lib/db.js';
import { handleFatal } from './lib/errors.js';
import { confirm, hasFlag } from './lib/prompt.js';
import { green, yellow, fail } from './lib/ui.js';

async function main(): Promise<void> {
  const psql = spawnSync('psql', ['--version'], { encoding: 'utf8' });
  if (psql.error || psql.status !== 0) {
    fail('The psql client was not found on your PATH.\nInstall it (macOS: "brew install libpq" and add it to PATH, or use Postgres.app), then run this again.');
  }
  console.log(green('✓'), psql.stdout.trim());

  const cfg = serverConfig();
  const admin = await connectAdmin();
  try {
    const version = await assertServerVersion(admin);
    console.log(green('✓'), `Connected to PostgreSQL ${version} at ${cfg.host}:${cfg.port} as "${cfg.user}"`);

    if (await databaseExists(admin, BASE_DB)) {
      console.log(green('✓'), `Database "${BASE_DB}" already exists. Nothing to do. (Rebuild from scratch with: pnpm db:reset)`);
      return;
    }

    if (!existsSync(CONSENT_FILE)) {
      console.log(yellow(`\nThis will create ONE database named "${BASE_DB}" on ${cfg.host}:${cfg.port} (C collation) and load the shop dataset into it.`));
      console.log('Temporary sqllab_chk_* databases are created and dropped by the checker; sqllab_play is created by "pnpm sql".');
      console.log('No other database on the server is touched.\n');
      if (!(await confirm('Continue?', hasFlag('--yes')))) fail('Cancelled. Nothing was changed.');
      writeFileSync(CONSENT_FILE, `${new Date().toISOString()}\n`);
    }

    await buildBaseDatabase(admin);
    console.log(green('✓'), `Database "${BASE_DB}" created and loaded.`);
    console.log('\nNext: pnpm status   then read modules/01-introduction/README.md');
  } finally {
    await admin.end();
  }
}

main().catch(handleFatal);
