#!/usr/bin/env node
/**
 * Swagger 2.0 → OpenAPI 3.0 konvertatsiyasi.
 *
 *   openapi/swagger.json  (backend beradigan xom spec, Swagger 2.0)
 *     → openapi/openapi3.json  (oraliq artefakt, commit qilinadi)
 *
 * Sabab: `openapi-typescript` faqat OpenAPI 3.x qabul qiladi, backend esa
 * swaggo bilan Swagger 2.0 chiqaradi. Konvertatsiya `swagger2openapi` orqali,
 * deterministik (kalitlar tartibi saqlanadi, `patch: true` bilan mayda
 * nomuvofiqliklar tuzatiladi).
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { convertObj } from 'swagger2openapi';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const IN = resolve(ROOT, 'openapi/swagger.json');
const OUT = resolve(ROOT, 'openapi/openapi3.json');

const source = JSON.parse(readFileSync(IN, 'utf8'));

if (source.swagger !== '2.0') {
  console.error(`Kutilgan Swagger 2.0, topildi: ${source.swagger ?? source.openapi ?? '?'}`);
  process.exit(1);
}

const { openapi } = await convertObj(source, {
  patch: true, // spec'dagi mayda nuqsonlarni tuzatadi (xatoga tushirmaydi)
  warnOnly: true, // konvertatsiya ogohlantirishlari build'ni yiqitmasin
  refSiblings: 'preserve',
});

// Server manzili `.env` dagi VITE_API_BASE_URL bilan boshqariladi — spec ichida
// faqat basePath saqlanadi, host emas (spec'da `host` bo'sh keladi).
writeFileSync(OUT, `${JSON.stringify(openapi, null, 2)}\n`, 'utf8');

const paths = Object.keys(openapi.paths ?? {}).length;
const schemas = Object.keys(openapi.components?.schemas ?? {}).length;
console.log(`OpenAPI 3.0 saqlandi: openapi/openapi3.json (${paths} path, ${schemas} schema)`);
