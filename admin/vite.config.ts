import { fileURLToPath, URL } from 'node:url';

import { sentryVitePlugin } from '@sentry/vite-plugin';
import react from '@vitejs/plugin-react';
import { visualizer } from 'rollup-plugin-visualizer';
import { defineConfig } from 'vitest/config';

/**
 * `ANALYZE=1 npm run build` -> `docs/bundle-stats.html` (gitignored).
 * Vizualizator odatdagi build'ga ulanmaydi: u har build'da ~2 MB HTML
 * yozadi va CI vaqtini uzaytiradi.
 */
const analyze = process.env.ANALYZE === '1';

/**
 * Sentry release + sourcemap yuklash faqat `SENTRY_AUTH_TOKEN` berilganda
 * ishlaydi (CI secret; bundle'ga TUSHMAYDI — `VITE_` prefiksi yo'q).
 * Token bo'lmasa plagin umuman ulanmaydi va build oflayn ishlaydi.
 */
const sentryAuthToken = process.env.SENTRY_AUTH_TOKEN;

export default defineConfig(({ mode }) => ({
  plugins: [
    react(),
    ...(analyze
      ? [
          visualizer({
            filename: '../docs/bundle-stats.html',
            template: 'treemap',
            gzipSize: true,
            brotliSize: true,
            emitFile: false,
          }),
        ]
      : []),
    ...(sentryAuthToken
      ? [
          sentryVitePlugin({
            authToken: sentryAuthToken,
            org: process.env.SENTRY_ORG,
            project: process.env.SENTRY_PROJECT,
            release: process.env.SENTRY_RELEASE ? { name: process.env.SENTRY_RELEASE } : undefined,
            sourcemaps: {
              // Yuklangandan keyin `.map` fayllari `dist/` dan O'CHIRILADI —
              // deploy'dagi `rsync --exclude '*.map'` + nginx 404 ikkinchi
              // himoya bo'lib qoladi (TD8).
              filesToDeleteAfterUpload: ['./dist/**/*.map'],
            },
            telemetry: false,
          }),
        ]
      : []),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  server: {
    port: 5173,
  },
  build: {
    outDir: 'dist',
    // F211 / TD8: `.map` fayllari prod'da **yuklanmaydi** — 'hidden' sourcemap'ni
    // yozadi, lekin bundle'ga `//# sourceMappingURL` izohini qo'ymaydi
    // (xato monitoringiga qo'lda yuklash uchun qoladi, brauzer so'ramaydi).
    // Fayllar `dist/` da qoladi, shuning uchun deploy ularni KO'CHIRMAYDI:
    // `rsync --exclude '*.map'` + nginx `location ~* \.map$ { return 404; }`.
    sourcemap: 'hidden',
    rollupOptions: {
      treeshake: {
        preset: 'recommended',
        // F206: prod bundle'da `console.*` qolmaydi. `console.error` xato
        // monitoringi uchun SAQLANADI — shuning uchun butun `console` emas,
        // faqat qolgan metodlar "sof funksiya" deb belgilanadi va natijasi
        // ishlatilmagani uchun tree-shaking ularni olib tashlaydi.
        //
        // ⚠️ Nega `esbuild: { pure }` emas: Vite 8 minifikatsiya uchun
        // esbuild o'rniga **oxc** ishlatadi va eski `esbuild` bloki JIM
        // e'tiborsiz qolar edi. Rollup darajasidagi `manualPureFunctions`
        // minifikator tanlovidan qat'i nazar ishlaydi.
        // Haqiqiy natija `scripts/check-bundle-budget.mjs` da tekshiriladi.
        manualPureFunctions:
          mode === 'production'
            ? ['console.log', 'console.info', 'console.debug', 'console.warn', 'console.trace']
            : [],
      },
    },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.ts'],
    css: false,
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
    // MSW so'rovlarni ushlab olishi uchun mutlaq (absolyut) baza kerak —
    // `.env.local` haqiqiy prod URL'ini beradi, lekin testlar backendga
    // ulanmasligi shart (fe-api §1, W12: haqiqiy backendga urinilmaydi).
    env: {
      VITE_API_BASE_URL: 'http://eldapi.test/api/v1',
    },
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      include: ['src/**/*.{ts,tsx}'],
      exclude: ['src/**/*.d.ts', 'src/main.tsx', 'src/api/schema.d.ts'],
    },
  },
}));
