import { spawnSync } from 'node:child_process';
import { BASE_DB, PLAY_DB, PSQLRC, serverConfig } from './lib/config.js';
import { connectAdmin, createDatabase, databaseExists, dropDatabase } from './lib/db.js';
import { handleFatal } from './lib/errors.js';
import { hasFlag } from './lib/prompt.js';
import { dim, fail } from './lib/ui.js';

async function main(): Promise<void> {
  const cfg = serverConfig();
  const admin = await connectAdmin();
  try {
    if (!(await databaseExists(admin, BASE_DB))) fail('The base database does not exist yet. Run: pnpm run setup');
    const reset = hasFlag('--reset');
    if (reset) await dropDatabase(admin, PLAY_DB, true);
    if (!(await databaseExists(admin, PLAY_DB))) {
      try {
        await createDatabase(admin, PLAY_DB, BASE_DB);
      } catch (err) {
        if ((err as { code?: string }).code === '55006') fail(`Another session is connected to "${BASE_DB}". Close it and try again.`);
        throw err;
      }
      console.log(dim(`Created a fresh disposable copy: ${PLAY_DB}`));
    } else if (reset) {
      console.log(dim(`Recreated ${PLAY_DB}`));
    }
  } finally {
    await admin.end();
  }

  console.log(dim(`Connected to ${PLAY_DB} (a copy: break things freely). Type \\q to leave, \\dt to list tables.`));
  const result = spawnSync('psql', ['-h', cfg.host, '-p', String(cfg.port), '-U', cfg.user, '-d', PLAY_DB], {
    stdio: 'inherit',
    env: { ...process.env, PGPASSWORD: cfg.password ?? '', PGTZ: 'UTC', PSQLRC },
  });
  if (result.error) fail('Could not start psql. Is it on your PATH?');
  process.exit(result.status ?? 0);
}

main().catch(handleFatal);
