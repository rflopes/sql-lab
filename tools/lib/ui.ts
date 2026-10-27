const useColor = process.stdout.isTTY === true && !process.env['NO_COLOR'];
const wrap = (code: number) => (s: string) => (useColor ? `\u001b[${code}m${s}\u001b[0m` : s);

export const green = wrap(32);
export const red = wrap(31);
export const yellow = wrap(33);
export const cyan = wrap(36);
export const dim = wrap(2);
export const bold = wrap(1);

export function bar(done: number, total: number, width = 20): string {
  const filled = total === 0 ? 0 : Math.round((done / total) * width);
  return green('█'.repeat(filled)) + dim('░'.repeat(width - filled));
}

export function fail(message: string): never {
  console.error(red(`\n${message}\n`));
  process.exit(1);
}
