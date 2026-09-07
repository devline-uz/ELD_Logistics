#!/usr/bin/env node
/**
 * `openapi-typescript` chiqargan faylga `@generated` bannerini qo'yadi (W7).
 * Banner har generatsiyada qayta yoziladi — fayl qo'lda tahrirlanmasligi kerak.
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const FILE = resolve(ROOT, 'src/api/schema.d.ts');

const BANNER = `/**
 * @generated
 *
 * GENERATSIYA NATIJASI — QO'LDA TEGILMAYDI.
 * Yangilash: \`DOCS_TOKEN=<token> npm run api\`
 *
 * Oqim:
 *   openapi/swagger.json   ← backend (Swagger 2.0, swaggo)
 *   openapi/openapi3.json  ← swagger2openapi konvertatsiyasi (OpenAPI 3.0)
 *   src/api/schema.d.ts    ← openapi-typescript (shu fayl)
 *
 * Domen tiplari komponentlarda \`src/api/types.ts\` alias'lari orqali ishlatiladi.
 */
`;

const body = readFileSync(FILE, 'utf8').replace(/^\/\*\*[\s\S]*?\*\/\s*/, '');
writeFileSync(FILE, `${BANNER}\n${body.replace(/^\n+/, '')}`, 'utf8');
console.log('Banner qo‘yildi: src/api/schema.d.ts');
