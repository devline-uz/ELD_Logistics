#!/usr/bin/env node
/**
 * Bundle byudjeti darvozasi (vazifa 9.4, TZ §12 F192).
 *
 * `dist/index.html` dan **boshlang'ich** (initial) yuklanadigan resurslarni
 * aniqlaydi va gzip hajmini byudjet bilan solishtiradi. Lazy chunk'lar
 * (`import()` orqali kelganlar) hisobga OLINMAYDI — ular birinchi bo'yoqni
 * bloklamaydi. Shu sabab `maplibre-gl` (~200 KB gzip) byudjetga kirmaydi:
 * u faqat xarita ekranida yuklanadi.
 *
 * Boshlang'ich to'plam = `index.html` dagi
 *   <script type="module" src>  +  <link rel="modulepreload">  +
 *   <link rel="stylesheet">
 * va ularning tranzitiv `modulepreload` zanjiri (Vite hammasini `index.html`
 * ga yozadi, shuning uchun bir daraja yetarli).
 *
 * Qo'shimcha tekshiruvlar:
 *   - `index.html` da mazmunli inline `<script>` yo'qligi — CSP `script-src
 *     'self'` ('unsafe-inline' YO'Q) ishlashi uchun shart (F203).
 *   - prod bundle'da `console.log/info/debug/warn/trace` qolmaganligi (F206).
 *     ⚠️ Vite 8 esbuild o'rniga oxc ishlatadi va eski `esbuild.pure`
 *     sozlamasi JIM e'tiborsiz qolgan bo'lardi — shuning uchun bu tekshiruv
 *     konfiguratsiyaga emas, HAQIQIY chiqishga qaraydi.
 *
 * Ishlatish:  npm run build && npm run bundle:budget
 *             BUNDLE_BUDGET_JS_KB=300 npm run bundle:budget
 */
import { gzipSync } from 'node:zlib';
import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const dist = join(root, 'dist');

/** Byudjetlar — TZ §12: boshlang'ich JS ≤ 250 KB gzip. */
const BUDGET = {
  js: Number(process.env.BUNDLE_BUDGET_JS_KB ?? 250),
  css: Number(process.env.BUNDLE_BUDGET_CSS_KB ?? 60),
};

const KB = 1024;
const gzipKb = (buf) => gzipSync(buf, { level: 9 }).length / KB;
const fmt = (n) => `${n.toFixed(1)} KB`;

function readDist(rel) {
  return readFileSync(join(dist, rel.replace(/^\//, '')));
}

let html;
try {
  html = readFileSync(join(dist, 'index.html'), 'utf8');
} catch {
  console.error('✖ dist/index.html topilmadi — avval `npm run build` bajaring.');
  process.exit(1);
}

// --- 1. Boshlang'ich resurslar ---------------------------------------------
const initial = { js: new Set(), css: new Set() };

for (const m of html.matchAll(/<script\b[^>]*\bsrc="([^"]+)"[^>]*>/g)) initial.js.add(m[1]);
for (const m of html.matchAll(/<link\b[^>]*\brel="modulepreload"[^>]*\bhref="([^"]+)"/g))
  initial.js.add(m[1]);
for (const m of html.matchAll(/<link\b[^>]*\brel="stylesheet"[^>]*\bhref="([^"]+)"/g))
  initial.css.add(m[1]);

const rows = [];
let jsKb = 0;
let cssKb = 0;

for (const href of [...initial.js].sort()) {
  const kb = gzipKb(readDist(href));
  jsKb += kb;
  rows.push(['js', href, kb]);
}
for (const href of [...initial.css].sort()) {
  const kb = gzipKb(readDist(href));
  cssKb += kb;
  rows.push(['css', href, kb]);
}

// --- 2. Eng katta lazy chunk'lar (ma'lumot uchun) ---------------------------
const allJs = [];
const walk = (dir) => {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) walk(p);
    else if (name.endsWith('.js')) allJs.push(p);
  }
};
walk(dist);

const initialAbs = new Set([...initial.js].map((h) => join(dist, h.replace(/^\//, ''))));
const lazy = allJs
  .filter((p) => !initialAbs.has(p))
  .map((p) => [p.slice(dist.length + 1), gzipKb(readFileSync(p))])
  .sort((a, b) => b[1] - a[1]);

// --- 3. Inline skript yo'qligi (CSP script-src 'self') ---------------------
const inlineScripts = [...html.matchAll(/<script\b(?![^>]*\bsrc=)[^>]*>([\s\S]*?)<\/script>/g)]
  .map((m) => m[1].trim())
  .filter(Boolean);

// --- 4. console.* qoldiqlari (F206) ----------------------------------------
const BANNED = /\bconsole\s*\.\s*(log|info|debug|warn|trace)\s*\(/g;
const consoleHits = [];
for (const p of allJs) {
  const n = (readFileSync(p, 'utf8').match(BANNED) ?? []).length;
  if (n) consoleHits.push([p.slice(dist.length + 1), n]);
}

// --- Hisobot ---------------------------------------------------------------
console.log("Boshlang'ich (initial) resurslar — gzip:");
for (const [kind, href, kb] of rows)
  console.log(`  ${kind.padEnd(3)} ${href.padEnd(48)} ${fmt(kb)}`);
console.log('');
console.log(`  JS  jami: ${fmt(jsKb)}  / byudjet ${BUDGET.js} KB`);
console.log(`  CSS jami: ${fmt(cssKb)}  / byudjet ${BUDGET.css} KB`);
console.log('');
console.log(`Lazy chunk'lar: ${lazy.length} ta, eng kattalari:`);
for (const [name, kb] of lazy.slice(0, 8)) console.log(`  ${name.padEnd(52)} ${fmt(kb)}`);

const errors = [];
if (jsKb > BUDGET.js) errors.push(`Boshlang'ich JS ${fmt(jsKb)} > byudjet ${BUDGET.js} KB`);
if (cssKb > BUDGET.css) errors.push(`Boshlang'ich CSS ${fmt(cssKb)} > byudjet ${BUDGET.css} KB`);
if (inlineScripts.length)
  errors.push(
    `index.html da ${inlineScripts.length} ta inline <script> — CSP script-src 'self' buziladi`,
  );
if (consoleHits.length)
  errors.push(
    `Prod bundle'da console.* qoldi (F206): ` +
      consoleHits.map(([n, c]) => `${n} (${c})`).join(', '),
  );

console.log('');
if (errors.length) {
  for (const e of errors) console.error(`✖ ${e}`);
  process.exit(1);
}
console.log("✔ Bundle byudjeti, inline-script va console.* tekshiruvlari o'tdi.");
