/**
 * D2 [MUST]: admin panel hech qachon parol o'rnatmaydi — `features/fleet/
 * {drivers,users,roles}` ichida `type="password"` maydon **yo'q** (faqat
 * `Send password reset`/invitation). Bu test kelajakda kimdir shu ekranlarga
 * parol maydoni qo'shib qo'yishining oldini oladi.
 */
import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';

const OWNED_MODULES = ['drivers', 'users', 'roles'];
const FLEET_DIR = join(__dirname, '..', '..');

/**
 * Manba matnidan `/* ... *\/` va `// ...` izohlarini olib tashlaydi, shunda
 * izoh ichidagi hujjatlashtirish uchun keltirilgan `type="password"` matni
 * (masalan shu faylning o'zidagi kabi) soxta-musbat bermaydi — faqat haqiqiy
 * JSX/HTML atributi tekshiriladi.
 */
function stripComments(source: string): string {
  return source.replace(/\/\*[\s\S]*?\*\//g, '').replace(/(^|[^:])\/\/.*$/gm, '$1');
}

function listFiles(dir: string): string[] {
  const entries = readdirSync(dir);
  const files: string[] = [];
  for (const entry of entries) {
    const full = join(dir, entry);
    const stat = statSync(full);
    if (stat.isDirectory()) {
      files.push(...listFiles(full));
    } else if (
      /\.(tsx?|jsx?)$/.test(entry) &&
      !entry.endsWith('.test.ts') &&
      !entry.endsWith('.test.tsx')
    ) {
      files.push(full);
    }
  }
  return files;
}

describe('D2 — no password field in fleet drivers/users/roles', () => {
  for (const module of OWNED_MODULES) {
    it(`"${module}" — hech qanday type="password" yo'q`, () => {
      const dir = join(FLEET_DIR, module);
      const files = listFiles(dir);
      expect(files.length).toBeGreaterThan(0);

      for (const file of files) {
        const content = stripComments(readFileSync(file, 'utf8'));
        expect(content).not.toMatch(/type\s*=\s*["']password["']/);
      }
    });
  }
});
