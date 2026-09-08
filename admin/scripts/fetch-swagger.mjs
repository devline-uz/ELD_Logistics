#!/usr/bin/env node
/**
 * Swagger spec'ini yuklab oladi — klient generatsiyasining yagona manbai.
 *
 *   DOCS_TOKEN=<bearer> npm run api
 *
 * Token `.env` (yoki `.env.local`) faylidan ham o'qiladi. Spec `Authorization:
 * Bearer <DOCS_TOKEN>` talab qiladi — tokensiz endpoint 401 qaytaradi.
 */
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const OUT = resolve(ROOT, 'openapi/swagger.json');
const DEFAULT_DOCS_URL = 'https://eldapi.stackyard.uz/api/docs';

/** `.env` fayllaridan oddiy KEY=VALUE juftliklarini o'qiydi (dotenv'siz). */
function readEnvFiles() {
  const env = {};
  for (const name of ['.env', '.env.local']) {
    const file = resolve(ROOT, name);
    if (!existsSync(file)) continue;
    for (const line of readFileSync(file, 'utf8').split('\n')) {
      const match = /^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/.exec(line);
      if (!match) continue;
      env[match[1]] = match[2].replace(/^["']|["']$/g, '');
    }
  }
  return env;
}

const fileEnv = readEnvFiles();
const token = process.env.DOCS_TOKEN ?? fileEnv.DOCS_TOKEN;
const docsUrl = process.env.VITE_API_DOCS_URL ?? fileEnv.VITE_API_DOCS_URL ?? DEFAULT_DOCS_URL;
const specUrl = `${docsUrl.replace(/\/$/, '')}/swagger.json`;

if (!token) {
  console.error(
    [
      'DOCS_TOKEN topilmadi.',
      `${specUrl} bearer token talab qiladi.`,
      "Tokenni .env ga qo'ying (DOCS_TOKEN=...) yoki: DOCS_TOKEN=<token> npm run api",
    ].join('\n'),
  );
  process.exit(1);
}

const response = await fetch(specUrl, {
  headers: { Authorization: `Bearer ${token}`, Accept: 'application/json' },
});

if (!response.ok) {
  console.error(`Spec yuklab olinmadi: ${response.status} ${response.statusText} — ${specUrl}`);
  process.exit(1);
}

const spec = await response.json();
mkdirSync(dirname(OUT), { recursive: true });
writeFileSync(OUT, `${JSON.stringify(spec, null, 2)}\n`, 'utf8');
console.log(`Spec saqlandi: openapi/swagger.json (${Object.keys(spec.paths ?? {}).length} path)`);
