---
name: fe-conventions
description: ELD Admin Panel frontend uchun stack, papka tuzilmasi, nomlash konventsiyalari, ESLint/Prettier qoidalari, env o'zgaruvchilar, ish qoidalari (W1-W11) va Definition of Done. Har qanday frontend kod yozish/ko'rib chiqish vazifasidan oldin yuklanadi (fe-architect, screen-implementer, frontend-code-reviewer, i18n-keeper agentlari uchun asosiy skill).
---

# fe-conventions — ELD Admin Panel frontend konventsiyalari

Bu skill TZ ni almashtirmaydi, siqadi. To'liq matn kerak bo'lsa — pastdagi "To'liq manba" bo'limiga qara.

## 1. Stack **[MUST]** (o'zgartirilmaydi, faqat asoslangan CR bilan)

| Qatlam | Vosita | Versiya / izoh |
|---|---|---|
| Karkas | React | 18.3 |
| Til | TypeScript | 5.x, `strict: true` |
| Bundler | Vite | 5.x |
| Stil | Tailwind CSS | 3.4, dizayn tokenlari `tailwind.config.ts` da |
| Server-state | TanStack Query | v5 |
| Marshrutlash | React Router | v6 (`createBrowserRouter`, lazy route'lar) |
| Formalar | react-hook-form + zod | `@hookform/resolvers` |
| API klient | `openapi-typescript` + `openapi-fetch` | tiplar `swagger.json` dan generatsiya, **qo'lda tip yozilmaydi** |
| Xarita | MapLibre GL JS | v4 + `maplibre-gl` React wrapper qo'lda |
| WebSocket | `reconnecting-websocket` | |
| i18n | `react-i18next` + `i18next` | `en.json` birinchi kundan |
| Grafiklar | `recharts` | Dashboard va HOS halqalari uchun (halqalar — SVG qo'lda) |
| Sana | `date-fns` + `date-fns-tz` | `Intl` bilan birga |
| Jadval | TanStack Table v8 | ustun ko'rsatish/yashirish, saralash |
| Test | Vitest + Testing Library + Playwright + MSW | |
| Lint | ESLint 9 (flat config) + Prettier + `eslint-plugin-jsx-a11y` | |

**Taqiqlangan kutubxonalar:** UI-kit'lar (MUI, AntD, Chakra), `moment`, `axios` (`openapi-fetch` yetarli), `redux` (TanStack Query + Zustand yetarli). Yangi kutubxona faqat asoslangan CR bilan.

**Klient-state:** `zustand` — faqat auth sessiyasi, sidebar/UI holati, xarita filtrlari. Server-state **faqat** TanStack Query'da.

## 2. Papkalar tuzilmasi **[MUST]**

```
admin/
├─ src/
│  ├─ api/
│  │  ├─ schema.d.ts          # GENERATSIYA — qo'lda tegilmaydi
│  │  ├─ client.ts            # openapi-fetch instansiyasi, middleware
│  │  ├─ types.ts             # schema.d.ts dan qulay alias'lar
│  │  └─ queries/             # modul bo'yicha query/mutation hooklar
│  │     ├─ units.ts  drivers.ts  logs.ts  dvir.ts  …
│  ├─ app/
│  │  ├─ router.tsx           # marshrutlar daraxti
│  │  ├─ providers.tsx        # Query, i18n, Toast, Auth
│  │  └─ layouts/             # RootLayout, AuthLayout, AppLayout
│  ├─ components/
│  │  ├─ ui/                  # dizayn tizimi primitivlari (fe-design-system)
│  │  ├─ data/                # DataTable, Pagination, Filters, ColumnPicker
│  │  ├─ form/                # FormField, FormSelect, FormDatePicker…
│  │  ├─ map/                 # MapCanvas, UnitMarker, TripPolyline
│  │  └─ feedback/            # EmptyState, ErrorState, Skeleton, Toast
│  ├─ features/              # ekran mantiqi, modul bo'yicha
│  │  ├─ dashboard/  fleet/  logs/  dvir/  maintenance/
│  │  ├─ tracking/  routes/  reports/  chat/  support/  settings/  audit/
│  │  └─ auth/
│  ├─ hooks/                  # usePermission, useUnitSystem, useDateFormat…
│  ├─ lib/                    # format.ts, units.ts, hos.ts, errors.ts, ws.ts, permissions.ts
│  ├─ locales/en.json
│  ├─ styles/index.css
│  └─ main.tsx
├─ e2e/                       # Playwright
├─ public/
├─ .env.example
├─ tailwind.config.ts
├─ vite.config.ts
├─ eslint.config.js
└─ package.json
```

**Qoida:** `features/<modul>/` ichida faqat o'sha modul ekranlari/komponentlari. Ulashiladigan narsa → `components/` yoki `lib/` ga chiqadi. `features/a` → `features/b` importi **taqiqlanadi** (ESLint `no-restricted-imports`).

## 3. Nomlash konventsiyalari **[MUST]**

| Nima | Qoida | Misol |
|---|---|---|
| Komponent fayli | `PascalCase.tsx`, bitta default eksport komponent | `UnitTable.tsx` |
| Hook fayli | `camelCase.ts`, `use` prefiksi | `usePermission.ts` |
| Query hook | `use<Entity><Action>` | `useUnitsList`, `useUnitCreate` |
| Query key | `['units', 'list', params]` — modul → tur → parametr | |
| Route komponenti | `<Screen>Page.tsx`, `features/<modul>/pages/` | `UnitListPage.tsx` |
| Zod sxema | `<entity>Schema`, `features/<modul>/schemas.ts` | `unitCreateSchema` |
| Absolyut import | `@/` → `src/` (`vite.config.ts` alias + `tsconfig.paths`) | `import { Button } from '@/components/ui/Button'` |
| CSS | faqat Tailwind sinflari; `@apply` — faqat `components/ui/` ichida | |
| Matn | hech qanday hardcode string UI'da yo'q — `t('units.title')` | |

## 4. ESLint / Prettier **[MUST]**

- `@typescript-eslint/no-explicit-any` — error
- `no-restricted-imports` — features kesishmasi, `date-fns/locale` to'liq import taqiqlangan
- `jsx-a11y/*` — recommended
- `react-hooks/exhaustive-deps` — error
- `i18next/no-literal-string` — warn → 1-bosqichdan keyin error
- Prettier: `printWidth 100`, `singleQuote true`, `semi true`, `trailingComma all`. Format tekshiruvi CI'da.
- `tsc --noEmit`, `eslint`, `vitest run`, `vite build` — to'rttasi ham yashil bo'lmasa PR birlashtirilmaydi.

## 5. Muhit o'zgaruvchilari

| Nom | Misol | Izoh |
|---|---|---|
| `VITE_API_BASE_URL` | `https://eldapi.stackyard.uz/api/v1` | |
| `VITE_WS_URL` | `wss://eldapi.stackyard.uz/api/v1/ws` | |
| `VITE_MAP_STYLE_URL` | ❓ ochiq (§17 Q1) | MapLibre style JSON — provayder hali tasdiqlanmagan (MapTiler yoki Protomaps self-host) |
| `VITE_SENTRY_DSN` | ixtiyoriy | |

`.env` fayllari repozitoriyga tushmaydi; `.env.example` yuritiladi. Hech qanday maxfiy kalit frontend bundle'ida bo'lmaydi — xarita tile kaliti domen bo'yicha cheklangan bo'lishi shart.

## 6. NFR maqsadlari (§15)

| Ko'rsatkich | Talab |
|---|---|
| Sahifa birinchi yuklanishi (LCP, desktop, 10 Mbit) | ≤ 2 s |
| Ekranlar orasida o'tish (lazy chunk + so'rov) | ≤ 1 s |
| API p95 (backend) | ≤ 300 ms ro'yxatlar, ≤ 800 ms hisobot |
| WS joylashuv kechikishi | ≤ 5 s onlayn holatda |
| Xarita 500 unit bilan | ≥ 30 fps pan/zoom |
| Brauzerlar | so'nggi 2 versiya: Chrome, Edge, Safari, Firefox |
| Minimal ekran kengligi | 1280 px |
| Availability | 99.5% (MVP) |
| Xavfsizlik | OWASP ASVS L2 (frontend qismi — fe-security) |

Brauzer qo'llab-quvvatlash `browserslist`: `last 2 Chrome versions, last 2 Edge versions, last 2 Firefox versions, last 2 Safari versions`. IE va eski Safari yo'q — qo'llab-quvvatlanmaydigan brauzerda banner.

Ilova **offline ishlamaydi** (onlayn vosita). Tarmoq yo'qolganda: banner + keshdagi ma'lumot faqat ko'rish uchun, barcha yozuv amallari `disabled`.

## 7. Umumiy ish qoidalari W1–W11 **[MUST]**

- **W1** — Bitta tool chaqiruvi ≤ 5 daqiqa. `npm install`, `npm run build`, Playwright — fon rejimida (`run_in_background: true`), holati kuzatiladi. Foreground'da 5 daqiqadan uzoq buyruq ishga tushirilmaydi.
- **W2** — Parallel agentlar kesishmaydigan fayl to'plamlarida ishlaydi. Har agentga aniq fayl/papka egaligi beriladi. Umumiy fayllar (`router.tsx`, `en.json`, `tailwind.config.ts`, `client.ts`) — faqat bitta agent yoki bosqich boshida/oxirida asosiy sessiya tomonidan.
- **W3** — Har bosqich oxirida to'rt tekshiruv yashil: `npm run typecheck`, `npm run lint`, `npm run test`, `npm run build`. Bittasi qizil bo'lsa bosqich tugallanmagan.
- **W4** — Har bosqich oxirida ikki ko'rik: `frontend-security-reviewer` (fe-security chek-listi) va `frontend-code-reviewer` (konventsiyalar, dublikat, qatlam buzilishi).
- **W5** — Katta fayl bo'lak-bo'lak yoziladi. 500 qatordan uzun fayl bitta `Write` bilan emas, mantiqiy bo'laklarga bo'linadi.
- **W6** — Har o'zgarishdan keyin i18n. Yangi matn qo'shilsa `en.json` ham o'sha commit'da yangilanadi. `npm run i18n:extract` yo'qolgan kalitni topadi.
- **W7** — `schema.d.ts` ga qo'lda tegilmaydi. Faqat `npm run api` orqali yangilanadi.
- **W8** — Migratsiya yo'q, backend o'zgarmaydi. Frontend agenti `backend/` papkasiga yozmaydi. Backend bo'shlig'i topilsa — §17.2 jadvaliga qator qo'shiladi va MVP yechimi yoziladi.
- **W9** — Har vazifadan keyin qisqa hisobot: nima qilindi, qaysi fayllar, qaysi tekshiruvlar o'tdi, nima ochiq qoldi.
- **W10** — Git: har bosqich alohida branch (`feat/stage-<n>-<nom>`), har mantiqiy blok alohida commit. Asosiy branch'ga to'g'ridan-to'g'ri push yo'q.
- **W11** — Kanonik nomlash: §16 reestridagi kanonik nomlar (masalan **Fleet Management**, **Reports**, **Support & History**) ishlatiladi; dizayndagi variantlar (`Fleet Operations`, `Report`, `Histories`) ishlatilmaydi.

## 8. §16 reestridan eng muhim qoidalar (siqilgan)

To'liq jadval: `docs/tz/16-17-registry-open-questions.md`. Kod yozishda tez-tez kerak bo'ladigan kanonik qarorlar:

- **Nomlar:** Fleet Management (Fleet Operations emas), Reports (Report emas), Support & History (Histories — ichki punkt sifatida qoladi), Inspection Report (DOT Report emas, faqat `generic` profilda), Unit Diagnostics (Unit Inspection emas), Logs By Driver (Log By Driver emas).
- **Ustunlar:** `Make & Model` + `ELD` (Unit jadvali); `Ticket #` + `Subject` (Support); `Remaining Frequency` + `Reminder Sent` (Maintenance Due — har doim shu ikkisi, ma'lumot bor-yo'qligidan qat'i nazar); `End Odometer` oxirgi ustun, `Odometer Change` alohida.
- **Format:** status kodlari uppercase + probel (`OFF 03:06`); bo'sh qiymat `N/A` (na emas); hafta kuni 3 harf (`Mon Tue Wed…`); koordinata nuqta bilan, 7 xona (`23.9746455`).
- **Olib tashlanadi:** `Export Users`/`Export Drivers`/`Import Drivers` tugmalari (backend endpoint yo'q); `Add User` Histories sahifasida; DVIR imzo paste formasi; admin `Change Password` (parolni ko'rish) — o'rniga `Send password reset`; parol maydoni Driver formasida.
- **Rang:** Warning `#F6BA47` (hex `#F9B385` xato edi, RGB to'g'ri); Disconnected ELD chizig'i neutral/qizil (yashil emas); Dashboard `Ongoing` — sariq (qizil emas).
- **D4 (eng katta farq):** log to'g'ridan-to'g'ri tahrirlanmaydi — `Insert duty status → Confirm` o'rniga **`Send edit request`** (FMCSA §395.30).
- **D21:** Route `Run Trip` emas — **`Create route`** (`POST /routes`).
- Imlo xatolari (16 tasi) to'g'irlangan holda yoziladi: `Maintenance`, `Invoice`, `Grease`, `Overdue`, `Inspection`, `Driver Management`, `Selected`, `automatically`, `5 min idle`, `GET BY`.
- Begona kontent (salon domeni, Jusoor huquqiy matni, chat demo xabarlari, noto'g'ri muqova sarlavhasi) — kodga tushmaydi, faqat tuzilma dizayndan olinadi.

## 9. Definition of Done

### Har vazifa uchun
- [ ] TypeScript `strict` bilan kompilyatsiya (`any` yo'q)
- [ ] ESLint va Prettier toza
- [ ] Barcha UI matnlari `en.json` da, hardcode string yo'q
- [ ] API chaqiruvlari faqat `openapi-fetch` orqali, tiplar `schema.d.ts` dan
- [ ] Ruxsat tekshiruvi qo'shilgan (menyu/tugma/marshrut), tegishli kalit fe-permissions dan
- [ ] Yuklanish, bo'sh va xato holatlari uchalasi ham amalga oshirilgan
- [ ] Forma bo'lsa: zod sxemasi + server xatolarini maydonlarga bog'lash + `Idempotency-Key`
- [ ] Ro'yxat bo'lsa: URL query-string sinxronizatsiyasi + 10/25/50 + saralash
- [ ] Sana/vaqt `lib/format.ts` orqali, masofa/tezlik `lib/units.ts` orqali
- [ ] Kamida bitta test (komponent yoki integratsiya)
- [ ] Klaviatura bilan boshqarish va `aria-label`/`aria-live` mavjud
- [ ] Konsolda ogohlantirish yo'q

### Har bosqich uchun
- [ ] Barcha vazifa checkbox'lari yopilgan
- [ ] `typecheck` + `lint` + `test` + `build` — to'rttasi ham yashil
- [ ] Qamrov chegaralari saqlangan (fe-testing)
- [ ] `frontend-security-reviewer` hisoboti — kritik topilma 0
- [ ] `frontend-code-reviewer` hisoboti — qatlam buzilishi va dublikat 0
- [ ] Yangi topilgan dizayn↔backend farqlari §16 ga, ochiq savollar §17 ga yozilgan
- [ ] `tasks.md` yangilangan
- [ ] Branch birlashtirilgan, CI yashil

### Loyiha uchun (oxirgi bosqich)
- [ ] §7 dagi barcha ekranlar amalga oshirilgan yoki [MAY] ga ko'chirilgan
- [ ] §14 (testlar, a11y, performans) va §15 (NFR) maqsadlariga erishilgan
- [ ] §16 reestridagi 31+16+4 element kodda to'g'ri aks etgan
- [ ] §17 dagi ochiq savollar yopilgan yoki buyurtmachiga uzatilgan
- [ ] `https://eldadmin.stackyard.uz` da ishlaydi, CSP va xavfsizlik header'lari o'rnatilgan
- [ ] README va ishga tushirish yo'riqnomasi to'liq

## To'liq manba

- `docs/tz-admin-frontend.md` §2 (Stack, papka, konventsiya, env) — qatorlar 87–184
- `docs/tz-admin-frontend.md` §15 (NFR) — qatorlar 1680–1700
- `docs/tz-admin-frontend.md` §18.0–18.1 (W1–W10, agent/skill jadvali) — qatorlar 1886–1946
- `docs/tz-admin-frontend.md` §18.4 (Definition of Done) — qatorlar 2204–2245
- `docs/tz/16-17-registry-open-questions.md` — to'liq §16 nomuvofiqliklar reestri va §17 ochiq savollar


## Token tejash qoidalari (W12–W14) **[MUST]**

O'lchangan fakt: subagent token sarfi **tool chaqiruvlari soniga chiziqli** bog'liq
(~2000 token/chaqiruv, 22 agent bo'yicha barqaror). Ya'ni qimmat narsa — bitta katta
o'qish emas, **takroriy chaqiruvlar va shovqinli chiqish**.

**W12 — Tekshiruvlarni birlashtir.** `typecheck`, `lint`, `test`, `build` ni alohida-alohida
va bir necha marta yugurtirma. Ish oxirida **bir marta** zanjir bilan:
```bash
npm run typecheck && npm run lint && npm run test && npm run build
```
Oraliq tekshiruv kerak bo'lsa faqat o'zgargan qismga: `npx vitest run src/features/<modul>`.

**W13 — Katta fayllarni to'liq o'qima.** Hajmlari (o'lchangan):

| Fayl | Taxminiy token |
|---|---|
| `admin/src/api/schema.d.ts` | ~199k |
| `admin/openapi/openapi3.json` | ~209k |
| `admin/openapi/swagger.json` | ~176k |
| `admin/package-lock.json` | ~102k |
| `docs/tz-admin-frontend.md` | ~43k |

Bularni **hech qachon** `Read` bilan to'liq ochma. Endpoint shaklini topish uchun:
```bash
python3 -c "import json;d=json.load(open('openapi/swagger.json'));print(json.dumps(d['paths']['/units/{id}'],indent=1))"
```
`swagger.json` da bitta qator 1030 belgigacha — `grep` natijasi ham qimmat, `cut -c1-200` bilan qirq.

**W14 — Chiqishni filtrla.** `npm run test` ning to'liq chiqishi ~3k token (ilgari 15k edi —
`vitest.setup.ts` da React Router future-flag ogohlantirishi va jsdom canvas xatosi
bostirilgandan keyin). Baribir kerak bo'lsa xulosani ol:
```bash
npm run test 2>&1 | tail -5
npm run typecheck 2>&1 | grep "error TS" | head -20
```
Muvaffaqiyatli buyruq chiqishini umuman o'qish shart emas: `npm run build >/dev/null 2>&1 && echo OK`.
