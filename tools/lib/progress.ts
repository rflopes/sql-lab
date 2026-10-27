import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { PROGRESS_FILE } from './config.js';

export interface Progress {
  done: Record<string, string>;
}

export function readProgress(): Progress {
  if (!existsSync(PROGRESS_FILE)) return { done: {} };
  const parsed: unknown = JSON.parse(readFileSync(PROGRESS_FILE, 'utf8'));
  if (typeof parsed !== 'object' || parsed === null || typeof (parsed as Progress).done !== 'object') {
    throw new Error('progress.json is malformed (expected {"done": {...}}).');
  }
  return parsed as Progress;
}

export function markDone(id: string): void {
  const progress = readProgress();
  progress.done[id] = new Date().toISOString().slice(0, 10);
  const sorted = Object.fromEntries(Object.entries(progress.done).sort(([a], [b]) => a.localeCompare(b)));
  writeFileSync(PROGRESS_FILE, `${JSON.stringify({ done: sorted }, null, 2)}\n`);
}
