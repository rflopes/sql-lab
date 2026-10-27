import { createInterface } from 'node:readline/promises';

/** Asks a yes/no question. Without a TTY the caller must pass --yes explicitly. */
export async function confirm(question: string, assumeYes: boolean): Promise<boolean> {
  if (assumeYes) return true;
  if (!process.stdin.isTTY) {
    console.error(`${question}\nNo terminal to ask on. Re-run with --yes to confirm.`);
    return false;
  }
  const rl = createInterface({ input: process.stdin, output: process.stdout });
  const answer = await rl.question(`${question} [y/N] `);
  rl.close();
  return /^y(es)?$/i.test(answer.trim());
}

export function hasFlag(flag: string): boolean {
  return process.argv.slice(2).includes(flag);
}
