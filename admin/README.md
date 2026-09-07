# ELD Admin Panel — frontend

ONEBOOK ELD platformasining web admin paneli.
Texnik topshiriq: [`../docs/tz-admin-frontend.md`](../docs/tz-admin-frontend.md).
Vazifalar reestri: [`../tasks.md`](../tasks.md).

## Stack

React 18.3 · TypeScript 5 (`strict`) · Vite 5 · Tailwind CSS 3.4 ·
TanStack Query v5 · React Router v6 · react-hook-form + zod ·
`openapi-typescript` + `openapi-fetch` · Vitest + Testing Library + Playwright ·
ESLint 9 (flat config) + Prettier.

**Taqiqlangan:** UI-kit'lar (MUI, AntD, Chakra), `moment`, `axios`, `redux`.
Yangi kutubxona faqat asoslangan CR bilan.

## Talablar

- Node.js **≥ 20** (ishlab chiqilgan versiya: 24.x)
- npm 10+

## Ishga tushirish

```bash
cd admin
cp .env.example .env      # qiymatlarni to'ldiring
npm install
npm run dev               # http://localhost:5173
```

## Muhit o'zgaruvchilari

| Nom                  | Kerakli  | Izoh                                                    |
| -------------------- | -------- | ------------------------------------------------------- |
| `VITE_API_BASE_URL`  | ha       | `https://eldapi.stackyard.uz/api/v1`                    |
| `VITE_WS_URL`        | ha       | `wss://eldapi.stackyard.uz/api/v1/ws`                   |
| `VITE_MAP_STYLE_URL` | keyinroq | MapLibre style JSON (§17 Q1 — provayder tasdiqlanmagan) |
| `VITE_SENTRY_DSN`    | yo'q     | ixtiyoriy                                               |
| `VITE_API_DOCS_URL`  | dev      | Swagger docs bazasi — `npm run api` uchun               |
| `DOCS_TOKEN`         | dev      | Swagger spec bearer tokeni — **bundle'ga tushmaydi**    |

`.env` fayllari repozitoriyga tushmaydi; `.env.example` yuritiladi.
Bundle'ga hech qanday maxfiy kalit qo'yilmaydi — xarita tile kaliti domen bo'yicha
cheklangan bo'lishi shart.

## Skriptlar

| Buyruq                 | Nima qiladi                                                         |
| ---------------------- | ------------------------------------------------------------------- |
| `npm run dev`          | Vite dev server (5173)                                              |
| `npm run build`        | `tsc -b --noEmit` + `vite build` → `dist/`                          |
| `npm run preview`      | build natijasini lokal ko'rish                                      |
| `npm run typecheck`    | `tsc -b --noEmit`                                                   |
| `npm run lint`         | ESLint + Prettier tekshiruvi                                        |
| `npm run lint:fix`     | ESLint `--fix` + Prettier `--write`                                 |
| `npm run test`         | Vitest (bir marta)                                                  |
| `npm run test:cov`     | Vitest + v8 qamrov hisoboti                                         |
| `npm run e2e`          | Playwright                                                          |
| `npm run api`          | spec yuklab olish → tip generatsiyasi → `lint:fix`                  |
| `npm run api:fetch`    | `openapi/swagger.json` ni yuklab oladi (`DOCS_TOKEN` kerak)         |
| `npm run api:gen`      | `openapi-typescript` → `src/api/schema.d.ts`                        |
| `npm run i18n:extract` | kodda ishlatilgan i18n kalitlarini `src/locales/en.json` ga yig'adi |

### API tiplarini yangilash

```bash
DOCS_TOKEN=<bearer> npm run api
```

`https://eldapi.stackyard.uz/api/docs/swagger.json` bearer token talab qiladi
(tokensiz `401 UNAUTHORIZED`). Token `.env` dagi `DOCS_TOKEN` dan ham o'qiladi.

- `src/api/schema.d.ts` — **generatsiya natijasi**, qo'lda tegilmaydi (W7).
- `openapi/swagger.json` snapshot bilan birga commit qilinadi.
- CI: `npm run api:gen && git diff --exit-code src/api/schema.d.ts` — spec o'zgargan
  bo'lsa build yiqiladi.

> **Hozirgi holat (BLOKER):** `DOCS_TOKEN` hali berilmagan, shu sababli
> `src/api/schema.d.ts` — placeholder va `src/api/types.ts` alias'lari `unknown`
> ga yechiladi. Token olinishi bilan `npm run api` ishga tushiriladi.

## Papkalar tuzilmasi

```
src/
├─ api/        schema.d.ts (generatsiya) · client.ts · session.ts · types.ts · queries/
├─ app/        router.tsx · providers.tsx · layouts/
├─ components/ ui/ data/ form/ map/ feedback/
├─ features/   modul bo'yicha ekran mantiqi
├─ hooks/      lib/       locales/       styles/
└─ main.tsx
e2e/           Playwright testlari
```

`features/a` → `features/b` importi ESLint (`no-restricted-imports`) bilan
**taqiqlangan**. Ulashiladigan kod `components/` yoki `lib/` ga chiqariladi.
Absolyut importlar `@/` alias'i orqali (`tsconfig` paths + Vite alias).

## API klienti

`src/api/client.ts` — `openapi-fetch` instansiyasi va to'rt middleware:

1. `authMiddleware` — `Authorization: Bearer <access>` (public endpointlardan tashqari)
2. `companyMiddleware` — `X-Company-Id` (faqat super_admin kontekstida)
3. `idempotencyMiddleware` — `POST/PUT/PATCH/DELETE` uchun `Idempotency-Key` (UUID);
   chaqiruvchi bergan kalit qayta yozilmaydi
4. `errorMiddleware` — `normalizeError()` orqali `ApiError` otadi (`src/lib/errors.ts`)

`fetch`/`axios` bevosita chaqirilmaydi. Yagona istisnolar: presigned URL'ga fayl `PUT`
va PDF/eksport `blob` yuklab olish.

**Token saqlash:** access token **faqat xotirada** (`src/api/session.ts`), refresh token
`sessionStorage` (`eld.rt`). `localStorage` da token yo'q.

## Sifat darvozasi

```bash
npm run typecheck && npm run lint && npm run test && npm run build
```

To'rttasi yashil bo'lmasa PR birlashtirilmaydi.

## Brauzerlar

So'nggi 2 versiya: Chrome, Edge, Firefox, Safari. Minimal ekran kengligi **1280 px**.
Ilova offline ishlamaydi — tarmoq yo'qolganda banner va yozuv amallari `disabled`.
