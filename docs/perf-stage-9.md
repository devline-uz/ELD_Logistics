# Bosqich 9 — bundle byudjeti va build hisoboti (9.4)

O'lchov sanasi: **2026-09-09** · Vite 8.2 (rolldown/oxc) · `npm run build`
(prod, `mode=production`) · gzip level 9.

Qayta ishlab chiqarish:

```bash
cd admin && npm run build && npm run bundle:budget
```

## 1. Byudjet va natija

| Ko'rsatkich                 | Byudjet (TZ §12 F192) | O'lchangan  | Holat |
| --------------------------- | --------------------- | ----------- | ----- |
| Boshlang'ich JS (gzip)      | ≤ **250 KB**          | **152.0 KB** | ✅ 61% |
| Boshlang'ich CSS (gzip)     | ≤ 60 KB (ichki norma) | **6.4 KB**   | ✅ 11% |
| `index.html` inline script  | 0                     | **0**        | ✅     |
| Prod bundle'da `console.*`  | faqat `console.error` | 8 × `error`  | ✅     |

Byudjet qiymatlarini `BUNDLE_BUDGET_JS_KB` / `BUNDLE_BUDGET_CSS_KB` muhit
o'zgaruvchilari bilan vaqtincha o'zgartirish mumkin (CI'da o'zgartirilmaydi).

## 2. Boshlang'ich to'plam (gzip)

| Chunk                    | KB   | Nima                                    |
| ------------------------ | ---- | --------------------------------------- |
| `index-*.js`             | 59.9 | ilova karkasi: router, providerlar, layout |
| `react-dom-*.js`         | 41.4 | React DOM                               |
| `dist-*.js`              | 18.4 | TanStack Query                          |
| `format-*.js`            |  9.9 | `date-fns` + `date-fns-tz` (ishlatilgan qismi) |
| `ErrorState-*.js`        |  7.9 | xato/bo'sh holat ekranlari + i18n bazasi |
| `client-*.js`            |  5.2 | `openapi-fetch` klienti va middleware'lar |
| `createLucideIcon-*.js`  |  3.1 | ikonka fabrikasi (ikonkalar tree-shake) |
| `jsx-runtime-*.js`       |  2.9 | React JSX runtime                       |
| `useMutation-*.js`       |  1.8 | Query mutation qismi                    |
| `permissions-*.js`       |  1.2 | 104 ruxsat kaliti + checker             |
| `auth.api-*.js`          |  0.3 | login/refresh chaqiruvlari              |
| `index-*.css`            |  6.4 | Tailwind (purge qilingan)               |

## 3. Lazy chunk'lar

Jami **159** ta lazy chunk. Barcha marshrutlar `React.lazy` orqali —
`src/app/router/*.routes.tsx`.

| Lazy chunk           | gzip KB | Izoh                                            |
| -------------------- | ------- | ----------------------------------------------- |
| `mapReady-*.js`      | 261.3   | **`maplibre-gl`** — faqat xarita ekranlarida     |
| `schemas-*.js`       |  23.2   | zod sxemalari (formali ekranlar)                |
| `ListScreen-*.js`    |  13.8   | TanStack Table + umumiy ro'yxat karkasi         |
| `zod-*.js`           |  12.4   | zod runtime                                     |
| `LogViewPage-*.js`   |  10.4   | HOS log grafigi                                 |
| `browser-*.js`       |   8.6   | `qrcode` (driver QR)                            |
| `ChatPage-*.js`      |   7.2   | chat + WS abonentlari                           |

**`maplibre-gl` byudjetga kirmaydi va bu ataylab.** U `index.html` dagi
`modulepreload` ro'yxatida yo'q — `LazyMapCanvas` faqat xarita ko'rinadigan
ekranda `import()` qiladi. Buni `scripts/check-bundle-budget.mjs`
avtomatik tekshiradi: boshlang'ich to'plam `index.html` dan o'qiladi, ya'ni
kimdir xatoga yo'l qo'yib maplibre'ni statik import qilsa, byudjet
**152 → ~413 KB** ga sakraydi va CI yiqiladi.

> `maplibre-gl` 4.7 → 6.8 yangilanishidan keyin bu chunk 203 → 261 KB gzip
> ga o'sdi (globe/projeksiya kodi). Yangilash sababi — kritik XSS
> maslahatnomasi (GHSA-jrc7-96c5-q579), 9.10 ga qarang.

Build "chunks are larger than 500 kB" ogohlantirishini beradi — u aynan shu
maplibre chunk'iga tegishli va **kutilgan**: kutubxona monolit, uni bo'lish
mumkin emas; muhimi — u lazy.

## 4. Byudjet darvozasi

`admin/scripts/check-bundle-budget.mjs` (`npm run bundle:budget`) uch narsani
tekshiradi va biri buzilsa **1** bilan chiqadi:

1. **Boshlang'ich JS/CSS gzip hajmi** — `dist/index.html` dagi `<script
   src>` + `<link rel="modulepreload">` + `<link rel="stylesheet">`.
2. **Inline `<script>` yo'qligi** — CSP `script-src 'self'` ('unsafe-inline'
   siz) ishlashi uchun shart (F203).
3. **`console.log/info/debug/warn/trace` qolmaganligi** (F206).
   Bu tekshiruv konfiguratsiyaga emas, **haqiqiy `dist/*.js` ga** qaraydi.
   Sababi: Vite 8 minifikator sifatida esbuild o'rniga **oxc** ishlatadi va
   eski `vite.config.ts` dagi `esbuild: { pure: [...] }` bloki jimgina
   e'tiborsiz qolar edi — `console.*` prod'ga tushib ketardi. Endi
   `build.rollupOptions.treeshake.manualPureFunctions` ishlatiladi.

CI qadami: `.github/workflows/ci.yml` → "Bundle budget · inline-script ·
console.* gate" (build'dan keyin).

## 5. Vizual tahlil

```bash
npm run build:analyze     # ANALYZE=1 -> docs/bundle-stats.html
```

`rollup-plugin-visualizer` treemap (gzip + brotli hajmlari bilan). Hisobot
**gitignored** — har ishlab chiquvchi o'zi generatsiya qiladi.
Odatdagi `npm run build` ga ulanmagan: ~2 MB HTML yozadi va CI'ni sekinlashtiradi.

## 6. Keyingi optimizatsiya nomzodlari (hozir kerak emas)

Byudjetning 39% zaxirasi bor, shuning uchun quyidagilar **bajarilmadi**:

- `date-fns` o'rniga `Intl` — ~10 KB tejaydi, lekin `format.ts` ni qayta yozish kerak.
- `zod` ni faqat lazy sxemalarga qoldirish — allaqachon lazy.
- Protomaps/PMTiles + `maplibre-gl` o'rniga yengilroq render — §17 Q1 chiqish yo'li.
