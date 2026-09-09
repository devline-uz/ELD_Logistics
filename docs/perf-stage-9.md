# Bosqich 9 — bundle byudjeti va build hisoboti (9.4)

O'lchov sanasi: **2026-09-09** · Vite 8.2 (rolldown/oxc) · `npm run build`
(prod, `mode=production`) · gzip level 9.

Qayta ishlab chiqarish:

```bash
cd admin && npm run build && npm run bundle:budget
```

## 1. Byudjet va natija

| Ko'rsatkich                | Byudjet (TZ §12 F192) | O'lchangan   | Holat  |
| -------------------------- | --------------------- | ------------ | ------ |
| Boshlang'ich JS (gzip)     | ≤ **250 KB**          | **152.0 KB** | ✅ 61% |
| Boshlang'ich CSS (gzip)    | ≤ 60 KB (ichki norma) | **6.4 KB**   | ✅ 11% |
| `index.html` inline script | 0                     | **0**        | ✅     |
| Prod bundle'da `console.*` | faqat `console.error` | 8 × `error`  | ✅     |

Byudjet qiymatlarini `BUNDLE_BUDGET_JS_KB` / `BUNDLE_BUDGET_CSS_KB` muhit
o'zgaruvchilari bilan vaqtincha o'zgartirish mumkin (CI'da o'zgartirilmaydi).

## 2. Boshlang'ich to'plam (gzip)

| Chunk                   | KB   | Nima                                           |
| ----------------------- | ---- | ---------------------------------------------- |
| `index-*.js`            | 59.9 | ilova karkasi: router, providerlar, layout     |
| `react-dom-*.js`        | 41.4 | React DOM                                      |
| `dist-*.js`             | 18.4 | TanStack Query                                 |
| `format-*.js`           | 9.9  | `date-fns` + `date-fns-tz` (ishlatilgan qismi) |
| `ErrorState-*.js`       | 7.9  | xato/bo'sh holat ekranlari + i18n bazasi       |
| `client-*.js`           | 5.2  | `openapi-fetch` klienti va middleware'lar      |
| `createLucideIcon-*.js` | 3.1  | ikonka fabrikasi (ikonkalar tree-shake)        |
| `jsx-runtime-*.js`      | 2.9  | React JSX runtime                              |
| `useMutation-*.js`      | 1.8  | Query mutation qismi                           |
| `permissions-*.js`      | 1.2  | 104 ruxsat kaliti + checker                    |
| `auth.api-*.js`         | 0.3  | login/refresh chaqiruvlari                     |
| `index-*.css`           | 6.4  | Tailwind (purge qilingan)                      |

## 3. Lazy chunk'lar

Jami **159** ta lazy chunk. Barcha marshrutlar `React.lazy` orqali —
`src/app/router/*.routes.tsx`.

| Lazy chunk         | gzip KB | Izoh                                         |
| ------------------ | ------- | -------------------------------------------- |
| `mapReady-*.js`    | 261.3   | **`maplibre-gl`** — faqat xarita ekranlarida |
| `schemas-*.js`     | 23.2    | zod sxemalari (formali ekranlar)             |
| `ListScreen-*.js`  | 13.8    | TanStack Table + umumiy ro'yxat karkasi      |
| `zod-*.js`         | 12.4    | zod runtime                                  |
| `LogViewPage-*.js` | 10.4    | HOS log grafigi                              |
| `browser-*.js`     | 8.6     | `qrcode` (driver QR)                         |
| `ChatPage-*.js`    | 7.2     | chat + WS abonentlari                        |

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

---

# Bosqich 9 — Lighthouse o'lchovi (9.3)

O'lchov sanasi: **2026-09-09** · Lighthouse **13.4.1** · Chrome (stable,
`--headless=new`) · **desktop** preset (`desktopDense4G` throttling,
1350×940, DPR 1) · har ekran uchun **3 ta yugurish, Performance bo'yicha
mediana**.

Qayta ishlab chiqarish:

```bash
cd admin && npm run lighthouse          # LH_RUNS=3 npm run lighthouse
```

Hisobotlar: `admin/dist-lh/reports/<ekran>.{html,json}` (gitignored).

## 1. Natijalar (TZ §14.3 maqsadi: Perf ≥ 90 · A11y ≥ 95 · BP ≥ 95)

| Ekran                  | Perf   | A11y    | BP      | SEO | Holat |
| ---------------------- | ------ | ------- | ------- | --- | ----- |
| Login (`/login`)       | **99** | **98**  | **100** | 45  | ✅    |
| Dashboard (`/`)        | **97** | **98**  | **100** | 45  | ✅    |
| Units (`/units`)       | **94** | **100** | **100** | 45  | ✅    |
| Tracking (`/tracking`) | **98** | **100** | **100** | 45  | ✅    |

Asosiy metrikalar (mediana yugurish):

| Ekran     | FCP   | LCP       | Speed Index | TBT      | CLS       | TTI   |
| --------- | ----- | --------- | ----------- | -------- | --------- | ----- |
| Login     | 0.6 s | **0.8 s** | 0.6 s       | **0 ms** | **0**     | 0.8 s |
| Dashboard | 0.7 s | **1.2 s** | 0.7 s       | **0 ms** | **0**     | 1.2 s |
| Units     | 0.8 s | **1.5 s** | 0.8 s       | **0 ms** | **0.017** | 1.5 s |
| Tracking  | 0.7 s | **1.1 s** | 0.7 s       | **0 ms** | **0.013** | 1.1 s |

**Uchala maqsad ham to'rt ekranda bajarilgan.** `npm run lighthouse` maqsad
buzilsa **1** kodi bilan chiqadi (CI'da bloklamaydigan qadam, 4-bo'lim).

**SEO 45 — ataylab va tuzatilmaydi.** Admin panel `<meta name="robots"
content="noindex, nofollow">` bilan yopilgan, `robots.txt`/`meta description`
yo'q; yiqilgan auditlar aynan shular (`is-crawlable`, `robots-txt`,
`meta-description`, `llms-txt`). TZ §14.3 SEO uchun maqsad qo'ymaydi.

## 2. O'lchov metodikasi (nega maxsus build kerak)

Prod bundle'da MSW **yo'q**: `src/main.tsx` uni faqat `import.meta.env.DEV &&
VITE_ENABLE_MSW === '1'` bo'lganda dinamik import qiladi (9.4 — bundle
byudjeti). Shuning uchun oddiy `npm run build && vite preview` backend'siz
bo'sh ekran beradi, dev serverda o'lchash esa noto'g'ri (minifikatsiya yo'q,
HMR klienti bor).

`admin/scripts/lighthouse.mjs` shu bo'shliqni **manba kodga tegmasdan**
yopadi — faqat o'lchov uchun prod build (`dist-lh/`, gitignored, deploy
qilinmaydi):

1. Rollup `transform` hook `src/main.tsx` dagi MSW shartini build vaqtida
   `true` ga almashtiradi (fayl o'zgarmaydi; shart matni o'zgarsa skript
   xato bilan to'xtaydi — jimgina noto'g'ri o'lchov bo'lmaydi).
2. `transformIndexHtml` `index.html` ga kichik seed skripti qo'shadi:
   `?lh_role=admin` bo'lsa `sessionStorage['eld.rt'] = 'refresh-token-admin'`.
   Ilova bootstrap'da `POST /auth/refresh` bilan sessiyani tiklaydi — bu
   `e2e/fixtures.ts` bilan aynan bir xil strategiya (`localStorage` da token
   yo'q, F-security buzilmaydi).
3. Qolgani — haqiqiy prod konfiguratsiyasi: `vite.config.ts`, minifikatsiya,
   code splitting, hashli aktivlar, `mode=production`.

Ikkita `define` o'lchov artefaktini olib tashlaydi (ikkalasi ham prod'da
mavjud emas):

| `define`            | Qiymat                       | Nega                                                                                                                                                           |
| ------------------- | ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `VITE_API_BASE_URL` | `https://eldapi.test/api/v1` | `http://` mock bazasi Lighthouse `is-on-https` auditini (BP, w=5) yiqitardi. MSW handler'lari ham shu o'zgaruvchidan quriladi — moslik saqlanadi.              |
| `VITE_WS_URL`       | `''`                         | WS mock'lanmagan; bo'sh qiymat `lib/ws.ts` da ulanishni o'chiradi. Aks holda haqiqiy `wss://eldapi.stackyard.uz` ga 403 va `errors-in-console` (BP) yiqilardi. |

Birinchi yugurishda aynan shu ikki artefakt BP ni **77–81** ga tushirgan
edi; ikkalasi ham ilova kodidagi muammo emas.

MSW service worker'i har navigatsiyada qayta ro'yxatdan o'tadi va barcha
API so'rovlarini brauzerda ushlaydi — bu **qo'shimcha yuk**, ya'ni yuqoridagi
ballar haqiqiy backend bilan bo'ladigan natijaning **pastki chegarasi**
(tarmoq kechikishi hisobga olinmaydi).

## 3. Qilingan/qilinmagan optimizatsiyalar

Maqsad barcha ekranda birinchi urinishdayoq bajarilgani uchun **kod
o'zgartirilmadi**. Ko'rib chiqilgan va **rad etilgan** arzon nomzodlar:

- **Font `preload`** — rad etildi. `public/fonts/*.woff2` (4 × ~12 KB) allaqachon
  `font-display: swap` bilan va tarmoq yozuvida **167–196 ms** da tugaydi,
  ya'ni FCP (600 ms) dan ancha oldin. Preload nol foyda berib, ishlatilmagan
  og'irlik ogohlantirishini qo'shardi.
- **`render-blocking-insight`** (yagona CSS, 6.4 KB gzip) — kritik CSS ni
  ajratish 500+ qatorlik Tailwind pipeline o'zgarishini talab qiladi, foyda
  esa < 50 ms. Rad etildi.
- **`unused-javascript` (~71–93 KiB)** — bu boshlang'ich karkasning hali
  ishlatilmagan qismi (router + query + i18n bazasi). Marshrutlar allaqachon
  100% lazy (9.4), qolganini bo'lish faqat sun'iy chunk'lar beradi.
- **`bf-cache`** — sahifada ochiq WebSocket/`beforeunload` bo'lgani uchun
  brauzer back/forward cache'ga qo'ymaydi; bu real-vaqt paneli uchun
  kutilgan xatti-harakat.

## 4. CI

`.github/workflows/ci.yml` → **`admin — lighthouse (bloklamaydi)`** job'i
(`continue-on-error: true`). Hisobotlar `lighthouse-reports` artefakti
sifatida 7 kun saqlanadi. Bloklamasligining sababi: LH balli runner yuki va
tarmoq shovqiniga sezgir (±3 ball) — u signal beradi, PR ni yiqitmaydi.
Qattiq darvoza — `admin` job'idagi bundle byudjeti (9.4).

`lighthouse` va `chrome-launcher` **`package.json` ga qo'shilmagan**: ular
o'lchov vositasi, ilova bog'liqligi emas (va `npm audit` yuzasini kengaytirmasligi
kerak). Skript ularni birinchi ishga tushishda `admin/.lh-tools/` ga
o'rnatadi (gitignored).

## 5. Qolgan a11y kuzatuvlari (ball ≥ 95, lekin tuzatishga arziydi)

Lighthouse maqsadga xalal bermaydi, ammo 9.2 (a11y ko'rigi) uchun qayd:

- `/login` — `landmark-one-main`: sahifada `<main>` yo'q (login layout
  `AppLayout` dan tashqarida).
- `/` — `heading-order`: `<h3>` `<h2>` siz keladi (dashboard kartalari).
- `/` — `label-content-name-mismatch`: KPI kartalari `aria-label="Active
Units"` ko'rinadigan matn bilan to'liq mos emas (raqam + sarlavha).

Uchalasi ham `src/features/**` / `src/components/**` da — 9.2 egaligida.
