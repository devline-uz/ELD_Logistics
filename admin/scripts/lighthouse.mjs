/**
 * Lighthouse o'lchovi (9.3, TZ §14.3 — Performance ≥ 90, Accessibility ≥ 95,
 * Best Practices ≥ 95).
 *
 * Nega alohida build: ilova prod bundle'ida MSW YO'Q (`src/main.tsx` uni
 * faqat `import.meta.env.DEV && VITE_ENABLE_MSW==='1'` da yuklaydi), shuning
 * uchun oddiy `vite preview` backend'siz bo'sh ekran beradi. Dev serverda
 * o'lchash esa noto'g'ri (minifikatsiya yo'q, HMR klienti bor).
 *
 * Yechim — **faqat o'lchov uchun** prod build (`dist-lh/`, gitignored):
 *   1. `src/main.tsx` MSW sharti build vaqtida `true` ga almashtiriladi
 *      (manba fayl O'ZGARMAYDI — Rollup transform hook);
 *   2. `index.html` ga kichik seed skripti qo'shiladi: `?lh_role=admin`
 *      bo'lsa `sessionStorage['eld.rt']` ga MSW kutgan refresh token
 *      yoziladi — ilova bootstrap'da `POST /auth/refresh` bilan sessiyani
 *      tiklaydi (`e2e/fixtures.ts` bilan bir xil strategiya).
 * Qolgani — haqiqiy prod konfiguratsiyasi (`vite.config.ts`, minifikatsiya,
 * code splitting, hashli aktivlar).
 *
 * Ishlatish:
 *   node scripts/lighthouse.mjs            # build + preview + 4 ekran
 *   node scripts/lighthouse.mjs --skip-build
 *   LH_RUNS=3 node scripts/lighthouse.mjs  # har ekran uchun 3 marta, mediana
 *   LH_HEADFUL=1 node scripts/lighthouse.mjs
 *
 * Hisobotlar: `dist-lh/reports/<id>.html` + `.json`, konsolga markdown jadval.
 * `lighthouse` va `chrome-launcher` asosiy `package.json` ga QO'SHILMAGAN
 * (o'lchov vositasi, ilova bog'liqligi emas) — skript ularni birinchi
 * ishga tushishda `admin/.lh-tools/` ga o'rnatadi.
 */
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const OUT_DIR = 'dist-lh';
const REPORT_DIR = path.join(ROOT, OUT_DIR, 'reports');
const PORT = Number(process.env.LH_PORT ?? 4180);
const RUNS = Number(process.env.LH_RUNS ?? 1);
const BASE = `http://localhost:${PORT}`;

/** MSW `browser.ts` `refresh-token-<role>` shaklidagi tokenni tan oladi. */
const ROLE = 'admin';

/** O'lchanadigan ekranlar (TZ §14.3: login + dashboard + og'ir ro'yxat). */
const TARGETS = [
  { id: 'login', title: 'Login', url: '/login', auth: false },
  { id: 'dashboard', title: 'Dashboard', url: '/', auth: true },
  { id: 'units', title: 'Units (ro’yxat)', url: '/units', auth: true },
  { id: 'tracking', title: 'Tracking (ro’yxat)', url: '/tracking', auth: true },
];

const CATEGORIES = ['performance', 'accessibility', 'best-practices', 'seo'];
const METRICS = [
  'largest-contentful-paint',
  'cumulative-layout-shift',
  'total-blocking-time',
  'first-contentful-paint',
  'speed-index',
];

// ---------------------------------------------------------------- vosita
/** `lighthouse` + `chrome-launcher` ni topadi, bo'lmasa `.lh-tools` ga o'rnatadi. */
async function loadTools() {
  const toolsDir = path.join(ROOT, '.lh-tools');
  if (!existsSync(path.join(toolsDir, 'node_modules', 'lighthouse'))) {
    mkdirSync(toolsDir, { recursive: true });
    writeFileSync(
      path.join(toolsDir, 'package.json'),
      `${JSON.stringify({ name: 'lh-tools', private: true, type: 'module' }, null, 2)}\n`,
    );
    console.log('[lh] lighthouse o’rnatilmoqda (.lh-tools, bir marta)…');
    execFileSync(
      'npm',
      ['install', 'lighthouse@13', 'chrome-launcher', '--no-audit', '--no-fund'],
      {
        cwd: toolsDir,
        stdio: 'inherit',
      },
    );
  }
  const req = createRequire(path.join(toolsDir, 'package.json'));
  const [lighthouse, chromeLauncher, desktopConfig] = await Promise.all([
    import(pathToFileURL(req.resolve('lighthouse')).href),
    import(pathToFileURL(req.resolve('chrome-launcher')).href),
    import(pathToFileURL(req.resolve('lighthouse/core/config/desktop-config.js')).href),
  ]);
  return {
    lighthouse: lighthouse.default,
    launch: chromeLauncher.launch,
    desktopConfig: desktopConfig.default,
  };
}

// ---------------------------------------------------------------- build
const SEED_SCRIPT = `(function(){try{var r=new URLSearchParams(location.search).get('lh_role');if(r){sessionStorage.setItem('eld.rt','refresh-token-'+r);}}catch(e){}})();`;

const MSW_CONDITION = "import.meta.env.DEV && import.meta.env.VITE_ENABLE_MSW === '1'";

/** Faqat o'lchov build'i uchun: MSW ni yoqadi + sessiya seed skriptini qo'shadi. */
function lighthouseMeasurementPlugin() {
  return {
    name: 'lh-measurement-build',
    enforce: 'pre',
    transform(code, id) {
      if (!id.replace(/\\/g, '/').endsWith('/src/main.tsx')) return null;
      if (!code.includes(MSW_CONDITION)) {
        throw new Error(
          '[lh] src/main.tsx dagi MSW sharti o’zgargan — scripts/lighthouse.mjs ni yangilang',
        );
      }
      return { code: code.replace(MSW_CONDITION, '/* lh */ true'), map: null };
    },
    transformIndexHtml() {
      return [{ tag: 'script', children: SEED_SCRIPT, injectTo: 'head-prepend' }];
    },
  };
}

async function buildMeasurementBundle() {
  const { build } = await import('vite');
  console.log(`[lh] o’lchov build’i → ${OUT_DIR}/ …`);
  await build({
    root: ROOT,
    logLevel: 'warn',
    plugins: [lighthouseMeasurementPlugin()],
    define: {
      // `https://` ataylab: MSW barcha so'rovlarni ushlaydi, lekin Lighthouse
      // `is-on-https` auditi (Best Practices, w=5) tarmoq yozuvidagi sxemaga
      // qaraydi — `http://` mock bazasi prod'da bo'lmaydigan "muammo"ni
      // ko'rsatardi. Handler'lar `url()` orqali shu o'zgaruvchidan quriladi,
      // shuning uchun moslik saqlanadi.
      'import.meta.env.VITE_API_BASE_URL': JSON.stringify('https://eldapi.test/api/v1'),
      // WebSocket mock'lanmagan: bo'sh qiymat `lib/ws.ts` da ulanishni
      // butunlay o'chiradi (aks holda haqiqiy `wss://` ga 403 va
      // `errors-in-console` auditi yiqiladi — o'lchov artefakti).
      'import.meta.env.VITE_WS_URL': JSON.stringify(''),
      'import.meta.env.VITE_SENTRY_DSN': JSON.stringify(''),
    },
    build: { outDir: OUT_DIR, sourcemap: false, emptyOutDir: true },
  });
}

// ---------------------------------------------------------------- run
function medianOf(values) {
  const sorted = [...values].sort((a, b) => a - b);
  return sorted[Math.floor((sorted.length - 1) / 2)];
}

async function main() {
  const skipBuild = process.argv.includes('--skip-build');
  const tools = await loadTools();
  if (!skipBuild) await buildMeasurementBundle();

  const { preview } = await import('vite');
  const server = await preview({
    root: ROOT,
    logLevel: 'error',
    build: { outDir: OUT_DIR },
    preview: { port: PORT, strictPort: true, open: false },
  });

  const chrome = await tools.launch({
    chromeFlags: [
      ...(process.env.LH_HEADFUL === '1' ? [] : ['--headless=new']),
      '--no-first-run',
      '--no-default-browser-check',
      '--disable-extensions',
    ],
  });

  mkdirSync(REPORT_DIR, { recursive: true });
  const rows = [];

  try {
    for (const target of TARGETS) {
      const url = `${BASE}${target.url}${target.auth ? `?lh_role=${ROLE}` : ''}`;
      const samples = [];
      for (let run = 0; run < RUNS; run += 1) {
        process.stdout.write(`[lh] ${target.id} (${run + 1}/${RUNS})… `);
        const result = await tools.lighthouse(
          url,
          { port: chrome.port, output: ['json', 'html'], logLevel: 'error' },
          tools.desktopConfig,
        );
        if (!result) throw new Error(`[lh] ${target.id}: natija yo’q`);
        samples.push(result);
        console.log(
          CATEGORIES.map(
            (c) => `${c[0]}${Math.round((result.lhr.categories[c]?.score ?? 0) * 100)}`,
          ).join(' '),
        );
      }

      const perfScores = samples.map((s) => s.lhr.categories.performance?.score ?? 0);
      const pick = samples[perfScores.indexOf(medianOf(perfScores))];
      writeFileSync(path.join(REPORT_DIR, `${target.id}.html`), pick.report[1]);
      writeFileSync(path.join(REPORT_DIR, `${target.id}.json`), pick.report[0]);

      rows.push({
        target,
        scores: Object.fromEntries(
          CATEGORIES.map((c) => [c, Math.round((pick.lhr.categories[c]?.score ?? 0) * 100)]),
        ),
        metrics: Object.fromEntries(
          METRICS.map((m) => [m, pick.lhr.audits[m]?.displayValue ?? 'n/a']),
        ),
        failed: Object.values(pick.lhr.audits)
          .filter((a) => a.score !== null && a.score < 1 && a.scoreDisplayMode !== 'informative')
          .map((a) => a.id),
      });
    }
  } finally {
    await chrome.kill();
    server.httpServer.close();
  }

  console.log('\n| Ekran | Perf | A11y | BP | SEO | LCP | CLS | TBT |');
  console.log('| --- | --- | --- | --- | --- | --- | --- | --- |');
  for (const r of rows) {
    console.log(
      `| ${r.target.title} | ${r.scores.performance} | ${r.scores.accessibility} | ` +
        `${r.scores['best-practices']} | ${r.scores.seo} | ` +
        `${r.metrics['largest-contentful-paint']} | ${r.metrics['cumulative-layout-shift']} | ` +
        `${r.metrics['total-blocking-time']} |`,
    );
  }
  for (const r of rows) {
    console.log(`\n[${r.target.id}] yiqilgan auditlar: ${r.failed.join(', ') || 'yo’q'}`);
  }

  const budget = { performance: 90, accessibility: 95, 'best-practices': 95 };
  const violations = rows.flatMap((r) =>
    Object.entries(budget)
      .filter(([c, min]) => r.scores[c] < min)
      .map(([c, min]) => `${r.target.id}/${c}: ${r.scores[c]} < ${min}`),
  );
  if (violations.length > 0) {
    console.error(`\n[lh] MAQSADGA YETMADI:\n  ${violations.join('\n  ')}`);
    process.exitCode = 1;
  } else {
    console.log('\n[lh] Barcha maqsadlar bajarildi (Perf≥90, A11y≥95, BP≥95).');
  }
}

await main();
