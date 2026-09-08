# ONEBOOK ELD — ADMIN PANEL (WEB) TEXNIK TOPSHIRIQ

**Versiya:** 1.0 · **Sana:** 2026-09-07 · **Holat:** Ishlab chiqish uchun asos
**Manba TZ:** `tz.md` v2.2 (QISM A biznes-logika, QISM B §6.2 stack, QISM D API)
**Dizayn manbasi:** `design-inventory.md` (144 betlik prezentatsiya inventari, web qismi bet 12–82)
**API kontrakti:** `backend/docs/swagger.json` (125 path / 166 operatsiya, `v1` **muzlatilgan**)

> **Belgilar** (`tz.md` bilan bir xil): **[MUST]** — MVP'siz ishga tushmaydi · **[SHOULD]** — MVP'da kutiladi · **[MAY]** — 2-bosqich · **✅** — qabul qilingan qaror · **❓** — buyurtmachi tasdig'i kutilmoqda · **🎨** — dizayn kerak (Figma'da yo'q).
> **Qoida raqamlari:** ushbu hujjatning o'z qoidalari **`F<raqam>`** (Frontend). `Q<raqam>` — `tz.md` dagi biznes qoidalari, ularga havola qilinadi va ular ustun.

---

## Mundarija

| § | Bo'lim |
|---|---|
| 1 | Kirish — maqsad, qamrov, backend holati |
| 2 | Stack va loyiha tuzilmasi |
| 3 | API integratsiyasi |
| 4 | Ruxsatlar va navigatsiya |
| 5 | Dizayn tizimi |
| 6 | Umumiy patternlar |
| 7 | Ekranlar spetsifikatsiyasi |
| 8 | Real-vaqt (WebSocket) |
| 9 | Xarita |
| 10 | Fayllar |
| 11 | Hisobotlar va eksport |
| 12 | i18n, sana/vaqt, birliklar |
| 13 | Xavfsizlik |
| 14 | Sifat — testlar, a11y, performans |
| 15 | Nofunksional talablar (NFR) |
| 16 | Nomuvofiqliklar reestri (31 + 16) |
| 17 | Ochiq savollar (❓) |
| 18 | **Claude Code bilan bajarish tartibi** |

---

# 1. Kirish

## 1.1 Maqsad

ONEBOOK ELD platformasining **web admin paneli** — kompaniya ofisi (fleet manager, dispatcher, safety manager, service manager, administrator) uchun brauzer ilovasi. Haydovchi mobil/planshet ilovasi va ELD qurilmasi tomonidan yaratilgan ma'lumotni **ko'rish, boshqarish, tekshirish va hisobotga chiqarish** vositasi.

Admin panel **hech qachon** haydovchi nomidan log yozmaydi va imzo qo'ymaydi (`tz.md` Q26, Q31, §5.3). Log tahrirlash — faqat **taklif → haydovchi tasdig'i** modeli orqali.

## 1.2 Qamrov

**Ichida (MVP):** 19 seksiya, ~55 marshrut (§7). Dashboard, Tracking + xarita, Logs (unit/driver kesimi, log view, edit request, unidentified, violations), Fleet Management (Units, Drivers, ELD devices, Trailers, Shipping documents, Users, Roles), DVIR, Maintenance, Routes, Reports (4 tur + export jobs), Chat, Support & Feedback, Settings (Company, Branches, HOS policy, Notifications, Defect types, Profile, Security), Audit.

**Tashqarisida:** mobil ilova, planshet ilovasi (Flutter, alohida TZ), Super Admin konsoli (`/companies`, `super_admin` — **[MAY]**, §7.14), billing/self-service subscription (`tz.md` qaror 24 — MVP'da qo'lda).

## 1.3 Backend holati **[MUST bilib olish]**

| Nima | Qiymat |
|---|---|
| Bazaviy URL (prod) | `https://eldapi.stackyard.uz/api/v1` |
| Swagger UI | `https://eldapi.stackyard.uz/api/docs/index.html` (`Authorization: Bearer <DOCS_TOKEN>`) |
| Xom spec | `GET /api/docs/swagger.json` — **klient generatsiyasining yagona manbai** |
| WebSocket | `wss://eldapi.stackyard.uz/api/v1/ws` (Swagger'da yo'q — `backend/docs/websocket.md`) |
| Admin panel domeni | `https://eldadmin.stackyard.uz` (SSL tayyor, hozir placeholder) |
| API versiyasi | `v1` — **muzlatilgan**. Yangi endpoint kerak bo'lsa — CR orqali `tz.md` o'zgartiriladi, keyin backend |

**F1 [MUST]** Backend haqiqat manbai. Dizayn bilan backend to'qnashsa — **backend ustun**; farq §16 reestriga yoziladi.
**F2 [MUST]** Frontend backendni "to'g'rilash" uchun hech qanday work-around yozmaydi. Endpoint yetishmasa — §17 ga ochiq savol sifatida chiqadi, vaqtinchalik yechim (kompozitsiya) aniq belgilanadi.

## 1.4 Foydalanuvchilar

| Rol (default, `tz.md` Q82) | Asosiy ekranlar |
|---|---|
| Administrator | hammasi |
| Sub Admin (`scope=branch`) | hammasi, filiali doirasida; `company.update`, `roles.*`, `hos_policy.update` yo'q |
| Fleet Manager | Units, Drivers, Routes, Tracking, Logs (propose_edit) |
| Dispatcher | Tracking, Routes, Chat |
| Service Manager | DVIR (repair/certify), Maintenance |
| Safety Manager | Logs, Violations, DVIR (read+export), log edit |
| Data Analyst | barcha `.read`, `reports.export` |

## 1.5 Manbalar ustuvorligi

1. `backend/docs/swagger.json` va `backend/internal/auth/permissions.go` — texnik haqiqat
2. `tz.md` (ayniqsa §1.3 kanonik nomlar, §16 ruxsatlar, §18 validatsiya) — biznes haqiqat
3. `design-inventory.md` — vizual va UX haqiqat
4. `backend/docs/websocket.md` — real-vaqt kontrakti

---

# 2. Stack va loyiha tuzilmasi

## 2.1 Stack **[MUST]** (`tz.md` B§6.2 — o'zgartirilmaydi)

| Qatlam | Vosita | Versiya / izoh |
|---|---|---|
| Karkas | React | 18.3 |
| Til | TypeScript | 5.x, `strict: true` |
| Bundler | Vite | 5.x |
| Stil | Tailwind CSS | 3.4, `tailwind.config.ts` da dizayn tokenlari |
| Server-state | TanStack Query | v5 |
| Marshrutlash | React Router | v6 (`createBrowserRouter`, lazy route'lar) |
| Formalar | react-hook-form + zod | `@hookform/resolvers` |
| API klient | **`openapi-typescript` + `openapi-fetch`** | tiplar `swagger.json` dan generatsiya, **qo'lda tip yozilmaydi** |
| Xarita | MapLibre GL JS | v4 + `maplibre-gl` React wrapper qo'lda |
| WebSocket | `reconnecting-websocket` | |
| i18n | `react-i18next` + `i18next` | `en.json` birinchi kundan |
| Grafiklar | `recharts` | Dashboard va HOS halqalari uchun (halqalar — SVG qo'lda) |
| Sana | `date-fns` + `date-fns-tz` | `Intl` bilan birga (§12) |
| Jadval | TanStack Table v8 | ustun ko'rsatish/yashirish, saralash |
| Test | Vitest + Testing Library + Playwright + MSW | §14 |
| Lint | ESLint 9 (flat config) + Prettier + `eslint-plugin-jsx-a11y` | |

**F3 [MUST]** Yangi kutubxona qo'shish — faqat asoslangan CR bilan. Taqiqlanadi: UI-kit'lar (MUI, AntD, Chakra), `moment`, `axios` (`openapi-fetch` yetarli), `redux` (TanStack Query + Zustand yetarli).
**F4 [SHOULD]** Klient-state uchun `zustand` (faqat: auth sessiyasi, sidebar/UI holati, xarita filtrlari). Server-state **faqat** TanStack Query'da.

## 2.2 Papkalar tuzilmasi **[MUST]**

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
│  │  ├─ ui/                  # dizayn tizimi primitivlari (§5.6)
│  │  ├─ data/                # DataTable, Pagination, Filters, ColumnPicker
│  │  ├─ form/                # FormField, FormSelect, FormDatePicker…
│  │  ├─ map/                 # MapCanvas, UnitMarker, TripPolyline
│  │  └─ feedback/            # EmptyState, ErrorState, Skeleton, Toast
│  ├─ features/              # ekran mantiqi, modul bo'yicha
│  │  ├─ dashboard/  fleet/  logs/  dvir/  maintenance/
│  │  ├─ tracking/  routes/  reports/  chat/  support/  settings/  audit/
│  │  └─ auth/
│  ├─ hooks/                  # usePermission, useUnitSystem, useDateFormat…
│  ├─ lib/                    # format.ts, units.ts, hos.ts, errors.ts, ws.ts
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

**F5 [MUST]** `features/<modul>/` ichida faqat o'sha modul ekranlari va komponentlari. Ikki modul o'rtasida ulashiladigan narsa → `components/` yoki `lib/` ga chiqadi. `features/a` → `features/b` importi **taqiqlanadi** (ESLint `no-restricted-imports` bilan majburlanadi).

## 2.3 Konventsiyalar **[MUST]**

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
| Matn | **hech qanday hardcode string UI'da yo'q** — `t('units.title')` | §12 |

**F6 [MUST]** ESLint qoidalari: `@typescript-eslint/no-explicit-any` (error), `no-restricted-imports` (features kesishmasi, `date-fns/locale` to'liq import), `jsx-a11y/*` (recommended), `react-hooks/exhaustive-deps` (error), `i18next/no-literal-string` (warn → 1-bosqichdan keyin error).
**F7 [MUST]** Prettier: `printWidth 100`, `singleQuote true`, `semi true`, `trailingComma all`. Format tekshiruvi CI'da.
**F8 [MUST]** `tsc --noEmit`, `eslint`, `vitest run`, `vite build` — to'rttasi ham yashil bo'lmasa PR birlashtirilmaydi.

## 2.4 Muhit o'zgaruvchilari

| Nom | Misol | Izoh |
|---|---|---|
| `VITE_API_BASE_URL` | `https://eldapi.stackyard.uz/api/v1` | |
| `VITE_WS_URL` | `wss://eldapi.stackyard.uz/api/v1/ws` | |
| `VITE_MAP_STYLE_URL` | ❓ (§17) | MapLibre style JSON |
| `VITE_SENTRY_DSN` | ixtiyoriy | |

**F9 [MUST]** `.env` fayllari repozitoriyga tushmaydi; `.env.example` yuritiladi. Hech qanday maxfiy kalit (API key, token) frontend bundle'ida bo'lmaydi — xarita tile kaliti domen bo'yicha cheklangan bo'lishi shart.

---

# 3. API integratsiyasi

## 3.1 Klient generatsiyasi **[MUST]**

```jsonc
// package.json scripts
"api:fetch": "curl -fsSL -H \"Authorization: Bearer $DOCS_TOKEN\" $VITE_API_DOCS_URL/swagger.json -o openapi/swagger.json",
"api:gen":   "openapi-typescript openapi/swagger.json -o src/api/schema.d.ts",
"api":       "npm run api:fetch && npm run api:gen && npm run lint:fix"
```

**F10 [MUST]** `src/api/schema.d.ts` — **generatsiya natijasi**, qo'lda tahrirlanmaydi (fayl boshida `// @generated` banneri, ESLint `ignorePatterns`). Repozitoriyga **commit qilinadi** (CI'da backendga bog'liq bo'lmaslik uchun) va `openapi/swagger.json` snapshot bilan birga.
**F11 [MUST]** CI'da `npm run api:gen && git diff --exit-code src/api/schema.d.ts` — spec o'zgargan bo'lsa build yiqiladi. Bu backendning `v1` muzlatilganini nazorat qiladi.
**F12 [MUST]** Domen tiplari faqat alias orqali olinadi:

```ts
// src/api/types.ts
import type { components, paths } from './schema';
type Schemas = components['schemas'];
export type Unit   = Schemas['github_com_devline_onebook-eld_internal_domain_fleet_dto.Unit'];
export type Driver = Schemas['github_com_devline_onebook-eld_internal_domain_drivers_dto.Driver'];
export type ListMeta = Schemas['github_com_devline_onebook-eld_internal_domain_auth_dto.Meta'];
```
Go paket prefiksli uzun nomlar **hech qachon** komponentlarda ko'rinmaydi.

## 3.2 Klient va middleware

```ts
// src/api/client.ts (mazmuni)
const api = createClient<paths>({ baseUrl: import.meta.env.VITE_API_BASE_URL });
api.use(authMiddleware);        // Authorization: Bearer <access>
api.use(companyMiddleware);     // X-Company-Id — faqat super_admin rejimida
api.use(idempotencyMiddleware); // POST uchun Idempotency-Key
api.use(errorMiddleware);       // xatoni normalizatsiya qiladi (§3.5)
```

**F13 [MUST]** Barcha so'rovlar `openapi-fetch` orqali. `fetch`/`axios` bevosita chaqirilmaydi. Yagona istisno — presigned URL'ga fayl `PUT` qilish (§10) va PDF/eksport `blob` yuklab olish.

## 3.3 Autentifikatsiya oqimi **[MUST]**

```
POST /auth/login {username|email, password, device_type:"web", device_id}
   → 200 { access_token, expires_in: 900, refresh_token, refresh_expires_at,
           token_type:"Bearer", session_id, user,
           requires_totp_setup, replaced_session, subscription_readonly }
```

| Holat | UI reaksiyasi |
|---|---|
| `requires_totp_setup: true` | `refresh_token` bo'sh, token **cheklangan** — faqat `/auth/2fa/setup` va `/auth/2fa/verify`. UI 2FA enrolment ekraniga majburan o'tadi, boshqa marshrut ochilmaydi |
| `replaced_session: true` | Toast: «Another web session was signed out» (`tz.md` B§20 — 1 web + 1 telefon + 1 planshet) |
| `subscription_readonly: true` | Global banner (qizil-sariq) + **barcha yozuv amallari o'chiriladi** (tugmalar `disabled`, tooltip: obuna muddati tugagan) |
| `403 ACCOUNT_INACTIVE` | Login ekranida xato matni, qayta urinish bloklanmaydi |

**F14 [MUST] Token saqlash:**
- **`access_token` — faqat JS xotirasida** (Zustand store, `persist` YO'Q). `localStorage`/`sessionStorage`ga **hech qachon** yozilmaydi.
- **`refresh_token` — `sessionStorage`da**, `eld.rt` kaliti bilan.
  **Sabab:** backend `POST /auth/refresh` ni oddiy JSON endpoint sifatida beradi va cookie o'rnatmaydi (`swagger.json`: `public`, javob `TokensEnvelope`). Demak httpOnly cookie varianti **backend o'zgarishisiz mumkin emas** — bu `v1` muzlatilgani sababli MVP'da yo'q. `sessionStorage` tanlandi, chunki (a) tab yopilganda o'chadi, (b) `localStorage` dan farqli, boshqa tabga tarqalmaydi va uzoq yashamaydi. XSS riski §13 dagi CSP + hech qanday `dangerouslySetInnerHTML` bo'lmasligi bilan qoplanadi.
- **[MAY] 2-bosqich:** backendga `Set-Cookie: refresh_token; HttpOnly; Secure; SameSite=Strict` qo'shilsa — frontend `sessionStorage` ni tashlaydi (CR).

**F15 [MUST] Avtomatik yangilash:** `expires_in` (900 s) ning **80 %** ida (720 s) proaktiv `POST /auth/refresh`. Bundan tashqari har `401` javobda reaktiv refresh:

```
401 → refresh mutex olinadi → POST /auth/refresh {refresh_token}
      ├─ 200 → yangi juftlik saqlanadi → asl so'rov BIR marta takrorlanadi
      └─ 401/403 → to'liq logout (§F16)
```
Bir vaqtda 401 olgan barcha so'rovlar **bitta** refresh navbatini kutadi (mutex + kutish ro'yxati). Refresh so'rovining o'zi 401 bersa qayta refresh qilinmaydi.

**F16 [MUST] Refresh rotation va reuse:** backend har refreshda yangi `refresh_token` qaytaradi (rotation). Eski tokenni qayta ishlatish urinishi backendda **butun sessiya oilasini bekor qiladi**. Frontend uchun qoida: refresh `401 REFRESH_REUSED` (yoki har qanday 401/403) qaytarsa →
1. xotira va `sessionStorage` tozalanadi, TanStack Query keshi `queryClient.clear()`,
2. WebSocket yopiladi,
3. `/login?reason=session_expired` ga redirect,
4. toast: «Your session ended for security reasons. Please sign in again.»
Hech qanday "silent retry" yo'q.

**F17 [MUST]** `POST /auth/logout` chaqiriladi (sessiyani serverda yopish), javobdan qat'i nazar lokal tozalash bajariladi.
**F18 [SHOULD]** `GET /auth/sessions` va `DELETE /auth/sessions/{id}` — Settings › Security ekranida "Active sessions" ro'yxati (§7.13.7).
**F19 [MUST]** Ilova yuklanganda `GET /app/config` (public) chaqiriladi: `server_time` bilan **soat siljishi** tekshiriladi (>120 s farqda ogohlantirish banneri), `feature_flags` bilan modul yashiriladi, `access_token_ttl_seconds` refresh taymerini sozlaydi.
**F20 [MUST]** `GET /me` — profil, rol, permission ro'yxati, `company` (region, `unit_system`, `regulation_profile`, `timezone`). Bu javob — §4 va §12 ning asosi; ilova unisiz render qilinmaydi (to'liq ekranli splash + skeleton).

## 3.4 `Idempotency-Key` **[MUST]**

**F21** Swagger'da `Idempotency-Key` header'i belgilangan **har bir** `POST` operatsiyasida yuboriladi. Qiymat — `crypto.randomUUID()`, **forma sessiyasi boshida bir marta** generatsiya qilinadi va qayta urinishlarda **o'zgarmaydi** (aks holda ma'nosi yo'qoladi). Muvaffaqiyatli javobdan keyin kalit tashlanadi.
**F22 [MUST]** Kalit `useIdempotencyKey()` hook'i orqali beriladi; forma `reset()` qilinganda yangilanadi. Mutation `retry: false` (TanStack Query) — takroriy yuborishni faqat foydalanuvchi boshlaydi.

## 3.5 Xato formati va uni ko'rsatish **[MUST]**

Backend yagona konvert qaytaradi:
```json
{ "error": { "code": "VALIDATION_ERROR", "message": "validation failed",
             "details": [ {"field": "unit_number", "message": "required"} ] } }
```

**F23** `lib/errors.ts` da `normalizeError(response)` → `{ code, message, fields: Record<string,string> }`.

| `code` | HTTP | UI xatti-harakati |
|---|---|---|
| `VALIDATION_ERROR` | 400/422 | `details[]` → `setError(field, {message})` react-hook-form'ga; maydon ostida qizil matn. Noma'lum `field` → forma tepasidagi umumiy alert |
| `UNAUTHORIZED` | 401 | §F15 refresh oqimi |
| `FORBIDDEN` | 403 | **Sahifa:** «You do not have permission to view this page» + orqaga tugma. **Amal:** toast, tugma qayta faollashadi |
| `NOT_FOUND` | 404 | «Not found» ekrani. **Cross-tenant so'rov ham 404 qaytaradi** (§4.4) — UI farq qilmaydi, "topilmadi" deb ko'rsatadi |
| `CONFLICT` | 409 | Toast + ro'yxatni invalidatsiya qilish (kimdir o'zgartirgan). Formada: «This record changed. Reload?» |
| `RATE_LIMITED` | 429 | Toast + `Retry-After` bo'yicha countdown, tugma vaqtincha `disabled` |
| `SUBSCRIPTION_READONLY` | 403 | Global banner (§3.3) qayta ko'rsatiladi |
| `INTERNAL` / 5xx | 500+ | ErrorState komponenti + «Try again» + `trace_id` (agar javobda bo'lsa) nusxa olish tugmasi |
| Tarmoq xatosi | — | «You appear to be offline» banner; TanStack Query `retry: 2` (faqat GET) |

**F24 [MUST]** Xom `error.message` (ingliz, backenddan) foydalanuvchiga **to'g'ridan-to'g'ri ko'rsatilmaydi**, agar `code` uchun i18n kaliti mavjud bo'lsa. Kalit yo'q bo'lsa — fallback sifatida `message` ko'rsatiladi va `console.warn` bilan qayd etiladi (i18n bo'shlig'ini topish uchun).

## 3.6 Pagination, saralash, filtrlash **[MUST]**

Ro'yxat javobi:
```json
{ "data": [ … ], "meta": { "page": 1, "per_page": 25, "total": 123 } }
```

**F25** `per_page` **faqat `10 | 25 | 50`** (`tz.md` §18.3). Boshqa qiymat UI'dan yuborilmaydi. Default — **25**.
**F26** Sahifa, `per_page`, saralash va filtrlar **URL query-string'da** saqlanadi (`?page=2&per_page=25&sort=unit_number&order=asc&status=active&search=101`). Sabab: sahifani ulashish, orqaga tugmasi, yangilanishda holat yo'qolmasligi. `useListParams()` hook'i (`useSearchParams` ustida) — barcha ro'yxat ekranlarida bir xil.
**F27** `search` — **400 ms debounce**, so'rov `page=1` ga qaytaradi. Bo'sh qatorda parametr yuborilmaydi.
**F28** `sort`/`order` faqat spec'da `enum` bilan ruxsat etilgan qiymatlar (masalan `GET /units`: `unit_number|status|make|year|created_at`). Jadval sarlavhasi faqat shu ustunlarda bosiladigan bo'ladi; qolganlari statik.
**F29** Kursorli ro'yxatlar (`GET /chat/threads/{driver_id}/messages` — `before` + `limit`) uchun alohida pattern: "Load older" tugmasi / yuqoriga scroll (§7.11).
**F30 [SHOULD]** TanStack Query: `staleTime` — ro'yxatlar 30 s, `GET /me`/`GET /permissions` 10 daq, `GET /dashboard/summary` 0 (WS bilan yangilanadi). `placeholderData: keepPreviousData` — sahifa almashganda jadval "sakramaydi".

---

# 4. Ruxsatlar va navigatsiya

## 4.1 Manba **[MUST]**

**F31** Permission kalitlari — `backend/internal/auth/permissions.go` (105 kalit) va ish vaqtida `GET /permissions`. Frontendda kalitlar `src/lib/permissions.ts` da **konstanta sifatida** takrorlanadi (typo'ni kompilyatsiya vaqtida topish uchun), lekin CI testi ularni `GET /permissions` snapshot'i bilan solishtiradi.

```ts
export const PERM = {
  unitsRead: 'units.read', unitsCreate: 'units.create', … } as const;
export type Permission = typeof PERM[keyof typeof PERM];
```

**F32 [MUST]** Joriy foydalanuvchi ruxsatlari `GET /me` javobidan olinadi va `usePermission()` hook'i orqali tekshiriladi:
```ts
const can = usePermission();
can(PERM.unitsCreate)            // boolean
can.any([PERM.unitsRead, …])     // kamida bittasi
can.all([…])                     // hammasi
```
**F33 [MUST]** `super_admin` — alohida bayroq (rol emas): `x-permission: super_admin` bo'lgan endpointlar faqat unga ochiq (`/companies*`).

## 4.2 Menyu va tugmalarni boshqarish **[MUST]**

| Element | Ruxsat yo'q bo'lsa |
|---|---|
| Nav elementi / flyout punkti | **Yashiriladi** (DOM'da yo'q) |
| Ro'yxat sahifasi marshruti | Route guard → 403 ekrani (to'g'ridan-to'g'ri URL kiritilsa) |
| Asosiy amal tugmasi (`Add Unit`) | **Yashiriladi** |
| Satr amali (`Edit`, `Delete`) | Amal menyusidan **olib tashlanadi** |
| Tab (masalan `Inactive`) | Yashiriladi, agar `include_inactive` ruxsati yo'q bo'lsa |
| Maskalangan maydon (`license_no_masked`) | "Reveal" tugmasi yashiriladi (`drivers.license.view` yo'q) |

**F34 [MUST]** "Yashirish" — **UI qulayligi**, xavfsizlik emas. Har bir amal backendda ham tekshiriladi; frontend hech qachon ruxsatga ishonib yozuv qilmaydi.
**F35 [MUST]** `disabled` tugma **hech qachon** sababsiz qolmaydi: `title`/tooltip bilan sabab ko'rsatiladi («Requires the `units.create` permission», «Subscription is read-only»).

## 4.3 `scope` ta'siri **[MUST]** (`tz.md` Q82.1)

| `scope` | UI |
|---|---|
| `company` | Filiallar filtri ko'rinadi (`branch_id`), "All branches" default |
| `branch` | **Filial filtri yashiriladi va o'zgartirilmaydi** — backend avtomatik filtrlaydi. Sarlavha ostida `Branch: <nom>` yorlig'i. `POST/PATCH` formalarida `branch_id` maydoni yashirin va o'z filiali bilan to'ldiriladi |
| `self` | Driver roli — web admin panelga **kirmaydi**: login muvaffaqiyatli bo'lsa ham `/login` da xato («This account can only be used in the driver app») |

**F36 [MUST]** `scope=branch` foydalanuvchisi boshqa filialning yozuviga URL orqali kirsa — backend **404** qaytaradi, UI "Not found" ko'rsatadi (§4.4).

## 4.4 403 va 404 farqi **[MUST]**

**F37** Ikki holat qat'iy ajratiladi:
- **403 FORBIDDEN** — resurs mavjud va sizning kompaniyangizniki, lekin **ruxsat kaliti yo'q**. UI: «You do not have permission…» + qaysi kalit kerakligi (dev rejimda).
- **404 NOT_FOUND** — resurs yo'q **yoki boshqa tenantga tegishli**. Backend ataylab tafovut bermaydi (tenant enumeratsiyasini oldini olish). UI **hech qachon** «Bu boshqa kompaniyaniki» demaydi — faqat «Not found».
- WebSocket'da ham xuddi shunday: `filter.unit_ids` begona unit'ni nomlasa — `NOT_FOUND`, `FORBIDDEN` emas (`websocket.md` §2).

## 4.5 Navigatsiya tuzilishi **[MUST]** (kanonik nomlar — `tz.md` §1.3)

**QATLAM 1 — brend panel** (`#B7002C`): logotip `ONEBOOK ELD` · global qidiruv · bildirishnomalar qo'ng'irog'i (o'qilmaganlar soni) · profil avatari.
**QATLAM 2 — navigatsiya** (oq fon): faol element qizil + ostida 2 px qizil chiziq.
**QATLAM 3 — breadcrumb** (ichki ekranlarda).

| Nav elementi | Marshrut | Flyout punktlari | Ko'rinish sharti |
|---|---|---|---|
| Dashboard | `/` | — | `dashboard.read` |
| Tracking | `/tracking` | — | `tracking.view_live` |
| Logs ⌄ | — | Logs By Unit `/logs/by-unit` · Logs By Driver `/logs/by-driver` · Log Edit Requests `/logs/edit-requests` · Unassigned Driving `/logs/unassigned` · Violations `/violations` | `logs.read` (Violations — `violations.read`) |
| **Fleet Management** ⌄ | — | Unit Management `/units` · Driver Management `/drivers` · ELD Devices `/eld-devices` · Trailers `/trailers` · Shipping Documents `/shipping-documents` · Users `/users` · Roles & Permissions `/roles` | har punkt o'z `*.read` kaliti bilan |
| Maintenance ⌄ | `/maintenance` | Schedule · Due · History (tab sifatida) · DVIR `/dvir` | `maintenance.read` / `dvir.read` |
| **Reports** ⌄ | — | Activity Report · Distance by Region · Regulator Export · DVIR Report · Uncertified Logs · Export Jobs | `reports.read` |
| **Support & History** ⌄ | — | Histories `/audit` · Contact Support `/support` · Feedback `/feedback` | `audit.view` / `support.read` / `feedback.read` |
| Chat | `/chat` | — | `chat.read` |

**Nav tashqarisidagi ekranlar:** Settings (`/settings/*`) — profil menyusi orqali; Track on Map — Tracking/Unit'dan; Log view — Logs jadvalidan; Routes (`/routes`) — Tracking flyout'i ostida yoki Dashboard'dan.

**F38 [MUST]** Dizayndagi `Fleet Operations`, `Report`, `Histories` variantlari **ishlatilmaydi** — §16 reestriga muvofiq kanonik nomlar: **Fleet Management**, **Reports**, **Support & History**.
**F39 [MUST]** Flyout punktlarining tavsif matnlari yoziladi (dizaynda 3 tasida `lorem ipsum` qolgan) — §16.
**F40 [SHOULD]** Brend paneldagi global qidiruv (dizaynda `Search Driver`) — MVP'da **haydovchi va unit bo'yicha tez o'tish**: `GET /drivers?search=` + `GET /units?search=` parallel, natijalar ikki guruh bilan dropdown'da. Backendda global search endpointi yo'q — bu kompozitsiya (§17).

---

# 5. Dizayn tizimi

**Manba ustuvorligi:** `design-inventory.md` A bo'limi (Figma'dan o'lchangan aniq qiymatlar) → `tz.md` §1.2. Farq bo'lsa — inventar ustun, farq §16 da qayd etiladi.

## 5.1 Ranglar **[MUST]**

**Brend va fon:**
| Token | HEX | Ishlatilishi |
|---|---|---|
| `primary` | `#B7002C` | brend panel, asosiy tugma, faol nav + ostki chiziq, HOS CYCLE halqasi, faol sahifa raqami |
| `primary-hover` | `#9A0025` | hover (hisoblangan: primary −10 % lightness) 🎨 |
| `bg` | `#FCFCFD` | asosiy fon |
| `surface` | `#FFFFFF` | kartalar, jadval satrlari |
| `surface-muted` | `#F2F4F7` | jadval sarlavhasi foni |
| `stroke` | `#E5E7EB` | chegaralar |
| `light` | `#EFF4FB` | yumshoq aksent fon |

**Neutral (11 pog'ona, matn va chegaralar):**
`50 #FCFCFD` · `100 #F4F5F6` · `200 #E6E8EC` · `300 #D6D8E0` · `400 #B1B5C3` · `500 #777E90` · `600 #3F4352` · `700 #353945` · `800 #23262F` · `900 #1C1E24` · `950 #18191D`

**Holat ranglari — uch pog'ona (fon / asosiy / to'q):**
| Holat | `-bg` | `-base` | `-dark` |
|---|---|---|---|
| Success | `#C5EFD8` | `#2FA766` | `#103923` |
| Warning | `#FCEAC8` | `#F6BA47` | `#7B5D24` |
| Error | `#F9DADB` | `#E2464A` | `#5A1C1E` |

**F41 [MUST]** Warning = **`#F6BA47`**. Dizayn palitrasida `#F9B385` yozilgan, lekin o'sha rangning RGB qiymati `246,176,71` = `#F6BA47` va `tz.md` §1.2 ham `#F6BA47` beradi → **hex yozuvi xato, RGB to'g'ri** (§16, C-16).

**Dekorativ (7 rang, badge va diagrammalar uchun):** Pink `#EE4E68` · Teal `#30B0C7` · Green `#47BB75` · Purple `#7E5EF7` · Orange `#F5693D` · Yellow `#F7CB46` · Blue `#466FF7`

**F42 [MUST] Semantik rang xaritasi** (dizayndagi ishlatilishdan chiqarilgan, kod ichida to'g'ridan-to'g'ri hex ishlatilmaydi):

| Ma'no | Token |
|---|---|
| Duty status `DR` / DRIVE halqasi | `success-base` |
| Duty status `OFF` | `neutral-500` |
| Duty status `SB` | `decorative-purple` |
| Duty status `ON` | `warning-base` |
| `OFF (PC)` | `neutral-500` + shtrix pattern |
| `ON (YM)` | `warning-base` + shtrix pattern |
| BREAK halqasi | `warning-base` |
| SHIFT halqasi / log grid chizig'i | `decorative-blue` `#466FF7` |
| CYCLE halqasi | `primary` |
| `Online` · `Completed` · `Certified` · `Signed` | `success-*` |
| `Offline` · `N/A` | `neutral-400` |
| `Disconnected` · `Malfunction` · `Violation` · `Not Signed` · `Overdue` · `Not Found` | `error-*` |
| `Warning` satri · `Ongoing` · `Due` | `warning-*` |
| KPI: Total Drivers ko'k · Total Units to'q sariq · Disconnected ELD kulrang · Violations qizil · Status kartasi sariq | `decorative-blue` / `decorative-orange` / `neutral-500` / `error-base` / `warning-base` |

**F43 [MUST]** Dizaynda `Ongoing` **qizil** fon bilan chizilgan (Dashboard Route's Details). Bu noto'g'ri semantika: davom etayotgan marshrut xato emas. ✅ **`Ongoing` → `warning`** (sariq), `not_completed` → `error` (qizil), `completed` → `success`, `cancelled` → `neutral`. §16 ga yozildi.

## 5.2 Tipografika **[MUST]**

- **IBM Plex Sans** — asosiy (400/500/600/700), **Product Sans** — faqat Display darajasi.
- **F44 [MUST]** Shriftlar **lokal `woff2`** sifatida joylashtiriladi (`public/fonts/`), `font-display: swap`. Tashqi CDN'ga so'rov yo'q (CSP, §13). Product Sans litsenziyasi ❓ (§17) — mavjud bo'lmasa fallback **IBM Plex Sans 700**.

| Daraja | O'lcham / og'irlik | Ishlatilishi |
|---|---|---|
| Display 1 / 2 | 48 / 40 Product Sans Bold | login sahifasi, bo'sh holat sarlavhalari |
| Heading 1–4 | 48 / 40 / 32 / 24 Bold | H3 (32) — sahifa sarlavhasi, H4 (24) — modal sarlavhasi |
| Body-lg | 16 / 400 | asosiy matn |
| Body | 14 / 400 | jadval satri, forma qiymati |
| Body-sm | 12 / 400 | yordamchi matn, jadval sarlavhasi (uppercase), badge |
| Body-xs | 10 / 400 | tooltip, timeline belgilari |

**F45** Figma'da **0 ta lokal text style** va `Body 6`/`Body 7` dublikati bor — shkala shu 7 darajaga **normallashtiriladi** (§16).
**F46** Jadval sarlavhasi: `Body-sm`, `font-medium`, `uppercase`, `tracking-wide`, `neutral-500`, fon `surface-muted`.

## 5.3 Spacing va grid **[MUST]**

- Grid: **12 ustun, gutter 24 px, maksimal kontent kengligi 1440 px, sahifa padding 40 px** (dizayn: Desktop 12 Column, width 80, gutter 24).
- **F47** Dizaynda umumiy spacing shkalasi berilmagan → ✅ **4 pt shkala**: `0 · 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64`. Tailwind default (`0.5 = 2px`) shu bilan mos.
- **F48** `Dashboard with Sidebar` gridi (280 px sidebar) — **eskirgan**, amaldagi admin panelda sidebar yo'q. Ishlatilmaydi.

## 5.4 Radius va soyalar **[MUST]**

**F49** Dizaynda faqat bitta effekt uslubi berilgan: **`Carts Dropdown` — `DROP_SHADOW`, radius 27.25**. Bu **soyaning blur radiusi**, burchak radiusi emas. ✅ Qarorlar:

| Token | Qiymat | Izoh |
|---|---|---|
| `shadow-card` | `0 4px 27.25px rgba(28,30,36,0.08)` | dizayndagi `Carts Dropdown` (blur 27.25) |
| `shadow-dropdown` | `0 8px 27.25px rgba(28,30,36,0.12)` | flyout, amal menyusi |
| `shadow-modal` | `0 20px 48px rgba(28,30,36,0.20)` | modal |
| `radius-sm` | 4 px | badge, checkbox |
| `radius-md` | 8 px | input, tugma, select |
| `radius-lg` | 12 px | karta, jadval konteyneri |
| `radius-xl` | 16 px | modal, KPI kartasi |
| `radius-full` | 9999 px | avatar, halqa, status nuqtasi |

Radius qiymatlari dizaynda berilmagan — yuqoridagilar ✅ **qabul qilingan default**, Figma'dan aniqlashtirilsa yangilanadi (🎨).

## 5.5 Ikonkalar **[MUST]**

**F50** Ikonka nabori dizaynda ko'rsatilmagan → ✅ **`lucide-react`** (line uslub, 24×24 grid, `stroke-width 1.5`) — inventarda sanab o'tilgan barcha ikonkalar (lupa, qo'ng'iroq, avatar, `···`, `⋮`, `⌄`, qalam, yuklab olish, tashqi havola, nusxalash, ogohlantirish uchburchagi, ko'z, `+`/`−`) mavjud. Tree-shaking bilan bundle'ga faqat ishlatilganlari kiradi.
**F51** Quyosh/oy (tema) ikonkasi **olib tashlanadi** (§5.7).

## 5.6 Komponent kutubxonasi **[MUST]** (`src/components/ui/`)

| Komponent | Variantlar / holatlar |
|---|---|
| `Button` | `primary` · `secondary` (oq + stroke) · `ghost` · `danger`; `sm/md/lg`; `loading`, `disabled`, `iconLeft/iconRight`, `fullWidth` |
| `IconButton` | kvadrat, `aria-label` **majburiy** |
| `Input` | `text/number/password/search`; prefix/suffix ikonka, `error`, `hint`, `required`, `disabled`, `readOnly`, `maxLength` hisoblagichi |
| `Textarea` | belgilar hisoblagichi (Notes ≤ 60, `tz.md` §18.3) |
| `Select` | bitta tanlov, qidiruv bilan (`combobox`), `clearable`, async yuklash |
| `MultiSelect` | `Select All`, chip'lar bilan (IFTA States, Truck Defects) |
| `Checkbox` / `Radio` / `Switch` | label + tavsif satri |
| `DatePicker` | bitta sana; `regulation_profile` formati (§12) |
| `DateRangePicker` | `Start date – End date`, presetlar (Today, Last 7/8 days, This month, Last quarter) |
| `TimePicker` | `HH:mm:ss` — Insert duty status uchun |
| `Table` (`DataTable`) | saralash, ustun ko'rsatish/yashirish, satr bosilishi, `sticky` sarlavha, gorizontal scroll |
| `Pagination` | `Rows per page: 10/25/50` + `Previous · <sahifalar> · Next` |
| `Modal` | `sm/md/lg/xl`; sarlavha + kontent + footer (`Cancel`/`Save`); `Esc` va backdrop bilan yopilish (forma o'zgargan bo'lsa tasdiq so'raydi) |
| `ConfirmDialog` | sarlavha `Are you absolutely sure?` + matn + `Cancel`/`Confirm`; `variant: danger` |
| `Drawer` | o'ng paneldan chiquvchi (Track on Map yon paneli) |
| `Tabs` | pastki chiziqli, klaviatura bilan boshqariladigan (`role="tablist"`) |
| `Badge` | `success/warning/error/neutral/info`; `dot` variant (Online/Offline) |
| `StatusChip` | duty status (`OFF/SB/DR/ON/PC/YM`) — rang + qisqartma |
| `Toast` | `success/error/warning/info`; 5 s, `error` — qo'lda yopiladi; stack maksimum 3 |
| `Tooltip` | klaviatura fokusida ham ochiladi |
| `EmptyState` | ikonka/illyustratsiya + sarlavha + tavsif + ixtiyoriy amal |
| `ErrorState` | xato ikonkasi + kod + «Try again» |
| `Skeleton` | `text/line/card/table-row/map` |
| `Spinner` | inline va to'liq ekranli |
| `Avatar` | initsiallar fallback bilan |
| `Breadcrumb` | havola zanjiri, oxirgi element — matn |
| `Card` | sarlavha + amal + kontent |
| `KpiCard` | qiymat + label + ikonka + kesim matni + pastki rangli chiziq |
| `FileUpload` | drag&drop, progress, `accept`, hajm chegarasi (§10) |
| `SignaturePreview` | imzo rasmi (faqat ko'rish — admin imzo qo'ymaydi, Q26) |
| `PermissionGate` | `<PermissionGate perm="units.create">…</PermissionGate>` |

**F52 [MUST]** Har bir `ui/` komponenti uchun: (a) TypeScript props interfeysi, (b) Vitest testi (render + asosiy interaksiya + a11y roli), (c) `en.json` da hech qanday matn hardcode qilinmagan.

## 5.7 Tema **[MUST]**

**F53 ✅ MVP — faqat light tema. Header'dagi tema almashtirgich (quyosh ikonkasi) olib tashlanadi.**

**Asoslar:**
1. `design-inventory.md` bet 82: «ADMIN PANELDA DARK TEMA YO'Q» — header'da toggle chizilgan, lekin **birorta ham dark ekran yo'q** (dark tema faqat mobil 63 ekran + planshet 51 ekran uchun chizilgan).
2. Admin panelda ~55 ekran, 19 seksiya. Dark palitrani dizaynersiz "o'ylab topish" 50+ ekranda rang/kontrast xatolariga olib keladi va a11y kontrast talabini (§14.2) buzadi.
3. Ishlamaydigan toggle — dizayn qarzi va foydalanuvchi uchun yolg'on va'da.

**Texnik tayyorgarlik saqlanadi:** barcha ranglar CSS o'zgaruvchilari orqali (`--color-bg`, `--color-surface`, …) beriladi va `:root[data-theme]` selektoriga ulanadi. Dizayn kelganda dark tema **faqat token qiymatlarini qo'shish** bilan yoqiladi (`#1B222C` bg, `#233040` sidebar, `#303E4B` karta, `#52565F` stroke — palitrada mavjud). **[MAY] 2-bosqich.**

## 5.8 Tailwind konfiguratsiyasi

**F54 [MUST]** `tailwind.config.ts` da `theme.extend` orqali yuqoridagi barcha tokenlar e'lon qilinadi; komponentlarda **xom hex, xom px yoki `style={{}}` ishlatilmaydi** (istisno: xarita marker pozitsiyalari). ESLint `no-restricted-syntax` bilan tekshiriladi.

---

# 6. Umumiy patternlar

## 6.1 Ro'yxat-ekran patterni **[MUST]**

Barcha ro'yxat ekranlari bitta tuzilma bo'yicha (`design-inventory.md` A.8, bet 17–18):

```
┌ Breadcrumb (ichki ekranlarda)
├ Sahifa sarlavhasi (H3)                          [Asosiy amal tugmasi]
├ Tablar (Active / Inactive / …)                   ← ixtiyoriy
├ Filtr paneli: [🔍 Search…] [Sana] [Select…]  … [Export ▾] [Import] [⚙ Ustunlar]
├ Jadval: kulrang sarlavha · oq satrlar · 1 px ajratgich · oxirgi ustun `···`
└ Sahifalash: [Rows per page: 25 ▾]              [Previous  1 2 3  Next]
```

| Element | Qoida |
|---|---|
| Sahifa sarlavhasi | i18n kalit, breadcrumb bilan mos |
| Asosiy amal | `PermissionGate` bilan o'ralgan |
| Qidiruv | `F27` debounce 400 ms, `search` query paramiga |
| Filtrlar | **URL'da** (`F26`); faol filtrlar soni tugmada badge bilan; «Clear all» |
| Ustun tanlash | `⚙` tugmasi → `Select All` + har ustun checkbox. Tanlov `localStorage` da `columns:<screen>` kaliti bilan saqlanadi. Dizaynda faqat Unit va Driver'da chizilgan → ✅ **barcha ro'yxatlarga** kengaytiriladi |
| Saralash | faqat `F28` dagi ruxsat etilgan maydonlar; sarlavhada `↑/↓` |
| Eksport | §11; server-side eksport bo'lgan joyda (`/units/export`, `/drivers/export`) darhol fayl, qolganida `export-jobs` |
| Satr bosilishi | `View` ekraniga; `···` menyusi `stopPropagation` bilan |
| Amal menyusi (`···`) | `View · Edit · Activate/Deactivate · Delete · <modulga xos>` — har biri o'z ruxsati bilan |
| Bo'sh holat | §6.5 |
| Yuklanish | skeleton — jadval sarlavhasi ko'rinadi, 5 ta skeleton satr |
| Xato | `ErrorState` jadval o'rnida, filtrlar qoladi |

**F55 [MUST]** Jadval **hech qachon** sahifani gorizontal scroll qilmaydi — jadval konteyneri `overflow-x: auto`, birinchi ustun (`#` yoki asosiy identifikator) `sticky left-0`.
**F56 [SHOULD]** 10 dan ortiq ustunli jadvallarda (Maintenance History, Logs kengaytirilgan) default'da ustunlarning bir qismi yashirin; ustun tanlash panelida ochiladi.

## 6.2 Forma patterni **[MUST]**

```ts
const schema = z.object({ unit_number: z.string().min(1).max(32), … });
const form = useForm({ resolver: zodResolver(schema), mode: 'onBlur' });
```

**F57** Validatsiya **ikki qatlam**: (1) zod — `tz.md` §18.3 cheklovlari (Notes ≤ 60, Username 4–32 `[a-z0-9._]`, Parol ≥ 10 harf+raqam, VIN 17 belgi, `per_page` 10/25/50); (2) server — `VALIDATION_ERROR.details[]` maydonlarga bog'lanadi.
**F58** Server xatosini bog'lash:
```ts
onError: (e) => { const {fields, message} = normalizeError(e);
  Object.entries(fields).forEach(([f,m]) => form.setError(f as never, {message: m}));
  if (!Object.keys(fields).length) setFormError(message); }
```
Noma'lum `field` nomi (formada yo'q) → forma tepasidagi umumiy alert'ga tushadi, **yo'qolmaydi**.
**F59** Majburiy maydonlar `*` bilan (dizayndagidek) **va** `aria-required`. Majburiylik ro'yxati — `tz.md` §18.1 (dizayndan farq qiladigan joylar §16 da).
**F60** `Cancel` — o'zgarish bo'lsa `ConfirmDialog` («Discard unsaved changes?»); `Save`/`Update` — `loading`, ikki marta bosish bloklanadi, `Idempotency-Key` o'zgarmaydi (F21).
**F61** Yuborilgandan keyin: modal yopiladi → `queryClient.invalidateQueries(['<modul>'])` → success toast. Ro'yxat qayta yuklanadi, sahifa/filtrlar saqlanadi.
**F62 [SHOULD]** Optimistik yangilash faqat "yengil" amallarda (bildirishnomani o'qilgan deb belgilash, chat xabari). CRUD'da — yo'q.

## 6.3 Modal **[MUST]**

**F63** Add/Edit formalari **modal** (dizayndagidek, orqa fonda ro'yxat ko'rinadi). Uzun formalar (Driver — 18 maydon, Maintenance Add multiple) — modal ichida vertikal scroll, sarlavha va footer `sticky`.
**F64** Fokus tuzoq (`focus trap`), ochilganda birinchi maydonga fokus, yopilganda chaqirgan tugmaga qaytadi. `Esc` — yopadi (F60 tasdig'i bilan). `aria-modal="true"`, `aria-labelledby`.
**F65** Modal marshrutga bog'lanmaydi (URL o'zgarmaydi), **istisno**: `View` ekranlari — ular alohida marshrut (`/units/:id`), chunki ulashiladi.

## 6.4 Tasdiqlash dialogi **[MUST]**

Dizayndagi matnlar aynan saqlanadi:
| Amal | Sarlavha | Matn | Tugmalar |
|---|---|---|---|
| Deactivate | `Are you absolutely sure?` | «Are you sure you want to deactivate the {entity}?» | `Cancel` / `Confirm` |
| Delete | `Are you absolutely sure?` | «This action cannot be undone. Are you sure you want to delete the {entity}?» | `Cancel` / `Confirm` (danger) |

**F66** Dizayndagi «inactive the unit» → ✅ **«deactivate the unit»** (grammatik to'g'rilash, §16).
**F67 [MUST]** Qaytarib bo'lmaydigan va audit-muhim amallar (Delete, Deactivate, Log edit request, HOS policy publish, Role delete, Ticket status) **har doim** tasdiq dialogi orqali. Delete — `danger` variant.

## 6.5 Bo'sh holat **[MUST]**

| Kontekst | Sarlavha | Matn |
|---|---|---|
| Umumiy (default) | `No Data Found` | «There is no data to show you right now» |
| Filtr natijasi bo'sh | `No results` | «No records match your filters» + `Clear filters` tugmasi |
| Logs By Driver — haydovchi tanlanmagan | `Select a driver` | «Select driver first, to display the data in the table.» |
| Ruxsat yo'q | `No access` | «You do not have permission to view this data» |

**F68** Bo'sh holatda **jadval sarlavhasi va sahifalash ko'rinib turadi** (dizayndagidek). Illyustratsiya — bitta SVG (🎨 kerak, hozircha `lucide` ikonka + neutral fon).
**F69** «Filtr natijasi bo'sh» va «umuman ma'lumot yo'q» **farqlanadi** — dizaynda ikkalasi bir xil edi (§16).

## 6.6 Yuklanish holati **[MUST]**

**F70** Dizaynda yuklanish holati **hech qayerda ko'rsatilmagan** (`design-inventory.md` A.8) → ✅ to'liq frontend qarori:

| Kontekst | Ko'rinish |
|---|---|
| Ro'yxat (birinchi yuklash) | Jadval skeleton: sarlavha + 5 satr |
| Ro'yxat (sahifa/filtr almashishi) | Mavjud ma'lumot qoladi (`keepPreviousData`) + jadval ustida yarim shaffof overlay + yupqa progress chiziq |
| Karta / KPI | `Skeleton` blok |
| Modal forma (ma'lumot yuklanishi) | Skeleton maydonlar |
| Tugma amali | Tugma ichida spinner, matn qoladi, `aria-busy` |
| Xarita | Xarita konteyneri + markazda spinner |
| PDF/eksport | Progress + «Preparing your file…» |

**F71** Skeleton **500 ms dan tez** javob kelsa ko'rsatilmaydi (miltillashning oldini olish) — `useDelayedLoading(500)`.

## 6.7 Xato holati **[MUST]**

**F72** Dizaynda umumiy xato ekrani yo'q (faqat inline `Violation:`/`Warning:` satrlari) → ✅ uch daraja:
1. **Global** — ilova yuklanmadi (`GET /me` yiqildi): to'liq ekranli `ErrorState` + «Try again» + «Sign out».
2. **Ekran ichi** — ro'yxat/karta yuklanmadi: blok o'rnida `ErrorState`, qolgan sahifa ishlaydi.
3. **Amal** — mutation yiqildi: toast + forma ochiq qoladi, ma'lumot yo'qolmaydi.

**F73** React `ErrorBoundary` — har route atrofida; yiqilish `console.error` va (yoqilgan bo'lsa) Sentry'ga; foydalanuvchi oq ekran ko'rmaydi.

## 6.8 Toast **[MUST]**

**F74** Pozitsiya — o'ng yuqori (header ostida). `success` 4 s, `info/warning` 6 s, `error` — qo'lda yopiladi. Bir vaqtda maks. 3 ta, ortiqchasi navbatda. `role="status"` (success/info) va `role="alert"` (error).
**F75** Toast matni — **nima bo'lgani + obyekt**: «Unit 101 created», «Log edit request sent to John Smith», emas «Success».

## 6.9 Inline ogohlantirish satrlari **[MUST]**

Dizayndagi `Violation: <matn>` (qizil) va `Warning: <matn>` (sariq) satrlari — Log view'da grid ostida, Logs jadvallarida ustun ichida.
**F76** Manba — `GET /daily-logs/{id}` javobidagi `violations[]` va `GET /violations`. Har satr: ikonka + `severity` prefiksi + `type` ning i18n matni + vaqt + (agar `resolved_at` bo'lsa) «Resolved at …» kulrang. **Violation o'chmaydi** (`tz.md` Q58) — hal qilingani `resolved` badge bilan ko'rsatiladi.

---

# 7. Ekranlar spetsifikatsiyasi

## 7.0 Yozuv formati va umumiy qoidalar

Har ekran uchun: **maqsad · marshrut · ruxsat · endpointlar (`METHOD /path`) · ustunlar/maydonlar · filtrlar · amallar · holatlar · bo'sh/xato holati**.

**F77 [MUST] Minimal kenglik — 1280 px.** Dizayn 1440 px uchun. 1280–1439 px: sahifa padding 40 → 24 px, KPI kartalari 4 → 2 ustun, jadval gorizontal scroll bilan. `<1280 px`: «This panel requires a screen at least 1280 px wide» xabari + o'lchamni o'zgartirish taklifi. Planshet/telefon uchun web admin **qo'llab-quvvatlanmaydi** (haydovchi ilovalari alohida).
**F78 [MUST]** Har ekran `<title>` va `h1` — i18n kalitidan; breadcrumb marshrut ierarxiyasidan.
**F79 [MUST]** Barcha `id` — UUID. URL'da UUID ko'rinadi; foydalanuvchiga esa **inson o'qiy oladigan identifikator** (Unit #, Ticket #, Driver name) ko'rsatiladi.

---

## 7.1 Auth (nav tashqarisida, `AuthLayout`)

### 7.1.1 Login — `/login`
- **Ruxsat:** public. **Endpoint:** `POST /auth/login`
- **Maydonlar:** `Email or username *`, `Password *` (ko'z ikonkasi), `Remember this device` (checkbox → `device_id` `localStorage`da saqlanadi)
- **Amallar:** `Sign in` · «Forgot password?» havolasi
- **Holatlar:** `requires_totp_setup` → `/2fa/setup`; `replaced_session` → toast; `subscription_readonly` → banner; `403 ACCOUNT_INACTIVE` → inline xato; `429` → countdown
- **Xato:** kirish xatosi **maydonga bog'lanmaydi** (qaysi maydon noto'g'ri ekanini oshkor qilmaslik uchun) — forma tepasida umumiy xato
- 🎨 Login ekrani dizaynda **yo'q** (grid'da `Login` 5-ustunli styli bor, ekran chizilmagan) → brend panel rangi + logotip + markazlashgan karta (maks. 440 px)

### 7.1.2 Two-factor — `/2fa/setup`, `/2fa/verify`
- **Endpoint:** `POST /auth/2fa/setup` (QR + secret), `POST /auth/2fa/verify` (6 xonali kod)
- Faqat cheklangan token bilan kirish mumkin; boshqa marshrutlar bloklangan. 🎨 dizayn yo'q.

### 7.1.3 Parolni tiklash — `/forgot-password`, `/reset-password?token=`
- **Endpoint:** `POST /auth/password/forgot`, `POST /auth/password/reset`
- Forgot: har doim bir xil neytral javob («If the account exists, a link has been sent») — enumeratsiyaga qarshi.
- Reset: `New password *` + `Confirm *`, kuch indikatori (`tz.md` §18.3: ≥ 10 belgi, harf + raqam).

### 7.1.4 Taklifni qabul qilish — `/invitation/accept?token=`
- **Endpoint:** `POST /auth/invitation/accept` — parol o'rnatish, profilni yakunlash.
- ✅ Bu **yagona** parol o'rnatish yo'li (`tz.md` qaror 21). Driver/User formalarida `Password` maydoni **yo'q** (§16).

---

## 7.2 Dashboard — `/`

- **Maqsad:** kompaniyaning joriy holati bir ekranda. **Ruxsat:** `dashboard.read`
- **Endpointlar:** `GET /dashboard/summary` · WS `dashboard` kanali (`dashboard_summary`) · `GET /routes?status=ongoing` (kerak bo'lsa)
- **Yangilanish:** WS obunasi; WS yo'q bo'lsa **60 s polling** (`websocket.md` §4.4)

**KPI kartalari** (backend `kpi` obyekti — **9 ta maydon**, dizaynda 4 ta karta bor edi):

| Karta | Maydon | Kesim | Rang | Bosilganda |
|---|---|---|---|---|
| Active Units | `active_units` | Today | orange | `/units?status=active` |
| Active Drivers | `active_drivers` | — | blue | `/drivers?status=active` |
| Drivers On Duty | `drivers_on_duty` | Now | blue | `/tracking` |
| Violations | `violations` | This week | error | `/violations?from=<hafta boshi>` |
| Disconnected ELD | `disconnected_eld` | Now | neutral | `/tracking?online_status=disconnected` |
| Malfunction ELD | `malfunction_eld` | Now | error | `/eld-devices?status=malfunction` |
| Uncertified Logs | `uncertified_logs` | ≥2 kun | warning | `/reports/uncertified-logs` |
| Unassigned Driving | `unassigned_driving` | Pending | warning | `/logs/unassigned` |
| Pending Log Edits | `pending_log_edits` | Pending | warning | `/logs/edit-requests?status=pending` |

**F80** Dizayndagi 4 karta o'rniga **9 karta** ko'rsatiladi (backend beradi, `tz.md` §20 talab qiladi): 2 qatorli grid, birinchi qatorda eng muhim 5 tasi. Dizayndagi `Total Drivers`/`Total Units` → **`Active Drivers`/`Active Units`** (backend semantikasi: bugun telemetriya bergan). §16.
**F81** Dizayndagi «Disconnected ELD kartasi ostidagi chiziq **yashil**» — xato, semantikaga zid. ✅ `neutral`, qiymat > 0 bo'lsa `error`. §16.

**Status bloki** (beshinchi karta): `status.off/sb/dr/on` — 4 raqam + rangli nuqta. Bosilganda `/tracking?duty_status=…`.

**Units Tracking bloki:** MapLibre xarita (§9), marker'lar `GET /tracking/live` dan, WS `tracking` bilan yangilanadi. Afsona: `● Drive · ● Sleep · ● On-Duty · ● Off-Duty`. Vaqt filtri `Today / This week` — **faqat marker tarixi uchun**, jonli holat doim joriy.

**Route's Details jadvali** (`summary.routes[]`):
| Ustun | Manba | Format |
|---|---|---|
| Unit # | `unit_number` | |
| Date | `created_at` | §12 formati |
| Driver Name | `driver_name` | |
| From | `origin` | manzil matni, `truncate` + tooltip |
| To | `destination` | |
| Status | `status` | `ongoing` (warning) · `completed` (success) · `not_completed` (error) · `cancelled` (neutral) |

Dizaynda 10 satr + vertikal scroll, sahifalash yo'q — ✅ saqlanadi; «View all» havolasi `/routes` ga.

- **Bo'sh holat:** har blok alohida (`No routes today`, `No units reporting`)
- **Xato:** har blok mustaqil `ErrorState` — bittasining yiqilishi butun dashboardni buzmaydi

---

## 7.3 Fleet Management

### 7.3.1 Unit Management — `/units`
- **Ruxsat:** `units.read` · **Endpoint:** `GET /units`
- **Tablar:** `Active` (`status=active`) / `Inactive` (`status=inactive`)
- **Filtrlar:** `search` (unit #, plate, VIN) · `branch_id` (scope=company da) · `out_of_service` (boolean) · `include_inactive`
- **Saralash:** `unit_number | status | make | year | created_at`

| Ustun | Maydon | Izoh |
|---|---|---|
| # | tartib | `(page-1)*per_page + i + 1` |
| Unit # | `unit_number` | |
| License Plate | `license_plate` | + `plate_region` kichik matn |
| Make & Model | `make` + `model` | ✅ kanonik: **`Make & Model`** (dizayndagi `Manufacturer - Model` emas) |
| Year | `year` | |
| ELD | `eld_device_serial` | bo'sh → `Not Found` (error rangda). ✅ ustun nomi **`ELD`**, qiymat — **qurilma serial raqami** |
| VIN | `vin` | `truncate` + nusxalash ikonkasi |
| Status | `status` + `out_of_service` | `out_of_service=true` → qizil `Out of service` badge |
| Action | `···` | |

- **Amallar:** `Add Unit` (`units.create`) · satr: `View` · `Edit` (`units.update`) · `Track on Map` · `Activate/Deactivate` (`units.activate/deactivate`) · `Delete` (`units.delete`)
- **Panel amallari:** `Export Units` (`units.export` → `GET /units/export?format=csv|xlsx`) · `Import Units` (`units.import`, §7.3.3) · ustun tanlash
- **Bo'sh/xato:** §6.5 / §6.7

### 7.3.2 Unit — Add / Edit / View / Activities
| Ekran | Marshrut | Endpoint | Ruxsat |
|---|---|---|---|
| Add (modal) | `/units` + `?modal=add` | `POST /units` (`Idempotency-Key`) | `units.create` |
| Edit (modal) | `?modal=edit&id=` | `PATCH /units/{id}` | `units.update` |
| View | `/units/:id` | `GET /units/{id}` | `units.read` |
| Activities | `/units/:id/activities` (tab) | `GET /units/{id}/history` | `units.read` |
| Diagnostics | `/units/:id/diagnostics` (tab) | `GET /units/{id}/diagnostics` | `units.diagnostics` |
| Assign driver | modal | `POST /units/{id}/assign-driver` | `units.assign_driver` |

**Add/Edit forma — `UNIT DETAILS`** (majburiylik `tz.md` §18.1 bo'yicha, dizayndan farq §16 da):

| Maydon | Tur | Majburiy | Manba/qiymatlar |
|---|---|---|---|
| Unit # | text | ✅ | |
| Make | select | ✅ | erkin matn + tavsiya ro'yxati |
| Model | select | ✅ | |
| License Plate Number | text | ✅ | |
| Plate Issue Region | select | — | label `regulation_profile` ga bog'liq (`License Plate Issue State` / `Plate Issue Region`) |
| Fuel Type | select | ✅ | `diesel · petrol · cng · lpg · electric · hybrid` (backend enum) |
| Year | number | — | 1950…joriy+1 |
| ELD | select | — | `GET /eld-devices?status=active` dan; **ixtiyoriy** (`tz.md` §18.1) |
| VIN | text | — | 17 belgi; «Get VIN from ELD» / «Enter VIN manually» radio |
| Branch | select | — | `scope=company` da ko'rinadi |
| GVWR class | select | — | **[MAY]** |
| Sleeper Not Available | checkbox | — | «The Sleeper Berth (SB) status will be disabled.» → `sleeper_berth=false` |
| Notes | textarea | — | ≤ 60 belgi |

**F82** Dizaynda `ELD *` va `Fuel Type*` majburiy, `Make/Model` ham majburiy edi; `tz.md` §18.1: majburiy — **Unit #, Make, Model, License Plate, Fuel Type**; ELD va VIN — ixtiyoriy (VIN ECM'dan o'qilsa avtomatik). ✅ TZ ustun. §16.

**View — `UNIT DETAILS`:** sarlavha `Unit # <unit_number>`. Maydonlar: Drivers (primary + `(co)`), ELD, Activated On, VIN, Make, Model, Year, Sleeper Berth (`Available`/`Not Available`), License plate + region, Fuel Type, Branch, Notes, Status, Out of service.
**Activities** (`GET /units/{id}/history`): `Time Stamp · Action · Changed by · Details`. Dizaynda 2 ustun (`Time Stamp · Activity`) va barcha satrlar `Lorem ipsum` edi → backend `audit_log` yozuvlari asosida **4 ustun** (§16).
**Diagnostics tab:** `device_serial · device_vendor · device_model · device_firmware · connection_type · connection_state · sim_present · last_seen_at · malfunction_codes[] · telemetry{}` (VIN, engine hours, odometer, fuel, coolant, oil, bus). Birliklar §12 bo'yicha konvertatsiya qilinadi.

### 7.3.3 Import — Units va Drivers
- **Endpoint:** `GET /units/import-template?format=csv|xlsx` · `POST /units/import` (`multipart`, `Idempotency-Key`); driverlar uchun `/drivers/import*`
- **Oqim:** modal → (1) «Download template» → (2) fayl tanlash (drag&drop, ≤ 10 MB, `.csv/.xlsx`) → (3) yuborish → (4) natija: `ImportRowError[]` (`row`, `field`, `message`) jadvali
- **F83** `tz.md` §18.4: **all-or-nothing** — bitta kritik xato bo'lsa hech narsa yozilmaydi. UI buni aniq aytadi: «Nothing was imported. Fix N errors and try again.» Xatolar jadvalini CSV sifatida yuklab olish mumkin.

### 7.3.4 Driver Management — `/drivers`
- **Ruxsat:** `drivers.read` · **Endpoint:** `GET /drivers`
- **Tablar:** Active / Inactive (+ `invited` holati badge bilan)
- **Filtrlar:** `search` · `status` (`invited|active|inactive`) · `branch_id` · `fleet_manager_id` · `include_inactive`
- **Saralash:** `name | username | status | created_at`

| Ustun | Maydon |
|---|---|
| # | tartib |
| First Name | `first_name` |
| Last Name | `last_name` |
| Username | `username` |
| Co-Driver | `GET /drivers/{id}/co-drivers` (ro'yxatda ko'rsatilmaydi — §F84) |
| Fleet Manager | `fleet_manager_name` |
| Unit # | `default_unit_number` |
| App Version | `app_version` + rangli nuqta (eng yangi = success, eski = neutral) |
| Activated On | `activated_on` |
| Status | `status` badge (`invited` — warning) |
| Action | `···` |

**F84** Dizayndagi `Co-Driver` ustuni ro'yxat javobida **yo'q** (alohida endpoint `GET /drivers/{id}/co-drivers`). ✅ Ustun **default'da yashirin**; Driver View ichida to'liq ro'yxat. N+1 so'rov qilinmaydi. §16/§17.
**F85** `App Version` uchun "eng yangi versiya" — `GET /app/config` dagi `latest_version`. Eski bo'lsa neutral nuqta + tooltip `Update available`.

- **Amallar:** `Add Driver` · satr: `View · Edit · Change Password · Activate/Deactivate · Delete`
- **`Change Password` → ✅ `Send password reset`** (`POST /drivers/{id}/reset-password`, `drivers.reset_password`). Dizayndagi «admin yangi parol kiritadi» modali **olib tashlanadi** (`tz.md` qaror 21: parol faqat invitation/reset orqali). §16
- **Panel:** `Export Drivers` (`GET /drivers/export`) · `Import Drivers` · ustun tanlash

### 7.3.5 Driver — Add / Edit / View / Activities
| Ekran | Marshrut | Endpoint |
|---|---|---|
| Add | modal | `POST /drivers` |
| Edit | modal | `PATCH /drivers/{id}` |
| View (Information) | `/drivers/:id` | `GET /drivers/{id}` |
| Activities | `/drivers/:id/activities` | `GET /drivers/{id}/activities` |
| Daily logs | `/drivers/:id/logs` | `GET /drivers/{id}/daily-logs` |
| HOS summary | View ichidagi blok | `GET /drivers/{id}/hos-summary?date=` |
| Co-drivers | View ichidagi blok | `GET/POST/DELETE /drivers/{id}/co-drivers` (`drivers.manage_co_drivers`) |

**Forma — `DRIVER DETAILS`** (majburiylik `tz.md` §18.1):

| Maydon | Majburiy | Izoh |
|---|---|---|
| First Name / Last Name | ✅ | |
| Username | ✅ | 4–32, `[a-z0-9._]` |
| Email | ✅ (yoki Phone) | invitation kanali |
| Phone | ✅ (yoki Email) | |
| License No | ✅ | forma'da to'liq kiritiladi, ro'yxat/View'da **maskalangan** (§F86) |
| License Region | — | label profilga bog'liq |
| Default Unit | — | `GET /units?status=active` |
| Fleet Manager | — | `GET /users` |
| Branch | — | `scope=company` da |
| Home Terminal | — | |
| City / State / Zip / Address 1 / Address 2 | — | |
| Notes | — | ≤ 60 |

**F86 [MUST]** `Password` maydoni **yo'q** (dizaynda bor edi — §16). `Co-Driver` maydoni formadan olib tashlanadi va **ixtiyoriy** bo'lib View ichidagi alohida blokka ko'chadi (`tz.md` qaror 22). Dizaynda `Co-Driver *` majburiy edi — ✅ bekor qilinadi.
**F87 [MUST] License PII:** ro'yxat va View'da `license_no_masked` ko'rsatiladi. `drivers.license.view` ruxsati bo'lsa — «Reveal» tugmasi → `GET /drivers/{id}/license` → qiymat **30 soniyaga** ochiladi, keyin qayta maskalanadi; ochish `audit_log`ga tushadi. Ochilgan qiymat clipboard'ga faqat aniq bosish bilan.
**Activities:** `Time Stamp · Edited By · Activity` (dizayndagi 3 ustun saqlanadi, `audit_log` dan).

### 7.3.6 ELD Devices — `/eld-devices` 🎨
- **Ruxsat:** `eld_devices.read` · **Endpointlar:** `GET/POST /eld-devices`, `GET/PATCH/DELETE /eld-devices/{id}`, `POST /eld-devices/{id}/assign-unit`
- **Filtrlar:** `search` · `status` (`active|inactive|malfunction`) · `unit_id` · `connection_type` (`bluetooth|wifi|cellular|usb`) · saralash `serial|vendor|status|created_at`
- **Ustunlar:** `Serial · Vendor · Model · Firmware · Connection · Status · Assigned Unit · Last seen · Action`
- **Amallar:** `Register device` · `Edit` · `Assign to unit` · `Delete`
- **F88** Dizaynda bu ekran **yo'q** (ELD faqat Unit formasida select edi), lekin backendda to'liq CRUD bor va TZ §10 uni talab qiladi → 🎨 standart ro'yxat patterni bo'yicha quriladi.

### 7.3.7 Trailers — `/trailers` 🎨
- **Ruxsat:** `trailers.read` · `GET/POST /trailers`, `GET/PATCH/DELETE /trailers/{id}`; filtr `search`
- **Ustunlar:** `Number · Notes · Created · Action`. Dizaynda yo'q (`tz.md` §1: v1'da jadval yo'q edi) → 🎨 sodda CRUD.

### 7.3.8 Shipping Documents — `/shipping-documents` 🎨
- **Ruxsat:** `shipping_documents.read` · `GET/POST /shipping-documents`, `GET/PATCH/DELETE /shipping-documents/{id}`
- **Ustunlar:** `Number · Notes · Created · Action`. 🎨 sodda CRUD.

### 7.3.9 User Management — `/users`
- **Ruxsat:** `users.read` · `GET /users` · saralash `last_name|first_name|username|email|status|created_at`
- **Filtrlar:** `search` · `status` (`invited|active|inactive`) · `role_id` · `branch_id`
- **Ustunlar:** `# · First Name · Last Name · Email · **Role** (rol nomi) · Phone · Branch · Status · Action`
- **F89** Dizaynda `Role` ustunida **ism** yozilgan («Kiss Dorka») — placeholder xatosi. ✅ rol nomi. `Export Drivers` tugmasi → ✅ **`Export Users`**; backendda `/users/export` **yo'q** → tugma MVP'da **olib tashlanadi** (§17 CR nomzodi). §16
- **Amallar:** `Invite User` (`POST /users`, `users.create`) · `Edit` (`PATCH /users/{id}`) · `Activate/Deactivate` (`POST /users/{id}/activate|deactivate`, `users.update`) · `Resend invitation` (`POST /users/{id}/resend-invitation`, `users.invite`) · `Send password reset` (`POST /users/{id}/reset-password`) · `Delete` (`users.delete`)
- **Forma — `USER DETAILS`:** `First Name *`, `Last Name *`, `Email *`, `Phone`, `Role *` (`GET /roles`), `Branch` — 5 maydon dizayndagidek + Branch. `Password` maydoni **yo'q**.

### 7.3.10 Roles & Permissions — `/roles`
- **Ruxsat:** `roles.read` · `GET/POST /roles`, `PATCH/DELETE /roles/{id}` · `GET /permissions` (`permissions.read`)
- **Filtrlar:** `search` · `scope` (`company|branch|self`) · `is_system`
- **Ustunlar:** `# · Role Name · Scope · Users · System · Action`
- **F90 [MUST] Ruxsatlar ro'yxati to'liq qayta yoziladi.** Dizayndagi ro'yxat **go'zallik saloni domenidan** (`Salons`, `Clients`, `Employees`, `View salons reservation graph` …) — butunlay begona. ✅ Dizayndan **faqat struktura** olinadi: `Role Name *` + modullarga guruhlangan checkbox'lar. Manba — `GET /permissions` (105 kalit) va `backend/internal/auth/permissions.go`.

**Ruxsat guruhlari UI'da** (kalit prefiksidan avtomatik, i18n bilan nomlanadi):
`Company · Branches · HOS Policy · Notification Settings · Users · Roles · Units · Drivers · ELD Devices · Trailers · Shipping Documents · Logs · Inspection · Violations · Tracking · Routes · DVIR · Defect Types · Maintenance · Reports · Dashboard · Notifications · Chat · Support · Feedback · Files · Audit`

Har guruhda: guruh `Select All` + kalitlar. Kalit yorlig'i — amal nomi (`Read`, `Create`, `Update`, `Delete`, `Activate`, `Export`, `Import`, `Assign driver`, `Diagnostics`, `Reveal licence number`, …).
- **F91** `scope` tanlovi (`company | branch`) — rol formasida majburiy maydon (`tz.md` Q82.1). `self` — faqat tizim Driver roli, UI'da tanlanmaydi.
- **F92** `is_system=true` rollar (`Super Admin`, `Administrator`): tahrirlash va o'chirish **bloklangan**, `Duplicate` tugmasi taklif qilinadi.
- **F93** Rolni o'chirishda foydalanuvchilari bo'lsa — backend `409 CONFLICT`; UI: «N users still use this role. Reassign them first.» + `/users?role_id=` havolasi.
- **F94** Noma'lum permission kaliti hech qachon yuborilmaydi (backend `FilterKnown` bilan tashlaydi, lekin UI ham `GET /permissions` ro'yxati bilan cheklanadi).

---

## 7.4 Logs

### 7.4.1 Logs By Unit — `/logs/by-unit`
- **Maqsad:** bitta kun kesimida barcha unit'larning joriy holati va HOS hisoblagichlari.
- **Ruxsat:** `logs.read` + `tracking.view_live`
- **Endpointlar (kompozitsiya):** `GET /tracking/live` (sahifalangan: unit, driver, duty_status, online_status, joylashuv) + har satr uchun `GET /drivers/{driver_id}/hos-summary?date=<sana>` (faqat **kengaytirilgan** ustunlar ochiq bo'lganda) + `GET /violations?from=&to=` (bir so'rov, satrlarga guruhlanadi)

**F95 [MUST] Ma'lum bo'shliq.** Backendda «bir kun × barcha unitlar × HOS hisoblagichlari» beruvchi **yagona endpoint yo'q**. MVP yechimi:
1. Asosiy ustunlar `GET /tracking/live` dan (bitta so'rov).
2. `Break/Drive/Shift/Cycle/Recap` ustunlari **default'da yashirin**. Foydalanuvchi ularni ustun tanlash panelidan yoqsa — joriy sahifadagi (≤ 50) haydovchilar uchun `hos-summary` **parallel, `concurrency ≤ 6`** bilan olinadi va keshlanadi (`staleTime` 60 s).
3. §17 da CR nomzodi: `GET /logs/by-unit?date=` (v1.1).

| Ustun | Manba | Izoh |
|---|---|---|
| # | tartib | |
| Device Status | `online_status` | `online` (success) · `offline` (neutral) · `disconnected` (error) · `malfunction` (error + ikonka) |
| Unit # | `unit_number` | |
| Driver Name | `driver.name` | bo'sh → `Unassigned` |
| Status | `duty_status` | `StatusChip` |
| Last Known Location | `lat`, `lng`, `last_seen_at` | ✅ format: **`<Reverse-geocode matni>` · `lat, lng`** + nisbiy vaqt. Dizayndagi `48.8566, 2.3522, 30` uchinchi soni — aniqlanmagan; ✅ **GPS aniqligi (metr)** deb talqin qilinadi va **ko'rsatilmaydi** (backend bermaydi). §16 |
| Warnings & Violations | `GET /violations` | raqamli badge (soni) + hover'da ro'yxat; `severity` bo'yicha rang |
| Break / Drive / Shift / Cycle | `hos-summary.counters` | `HH:MM` **qolgan vaqt** (`tz.md` §4.1) |
| Recap | `hos-summary.recap[]` | ertaga qo'shiladigan soat (`tz.md` Q10.7) |

- **Filtrlar:** sana (bitta kun, default bugun) · `search` (driver) · `online_status` · `branch_id` · `Violations` (boolean) · `Warnings` (boolean) — mustaqil (`tz.md` Q59)
- **F96** Dizayndagi `Export Drivers`/`Import Drivers` tugmalari bu ekranda **ma'nosiz** → olib tashlanadi; o'rniga `Export` → `export-jobs` (`type=hos`). §16
- **Satr bosilganda:** `/logs/:dailyLogId` (Log view). `daily_log_id` `GET /drivers/{id}/daily-logs?from=<sana>&to=<sana>` orqali topiladi.
- **Ogohlantirish matnlari:** `Trailer not set.`, `Shipping document is not set`, `Shift Limit` — `violations[].type` ning i18n matnlari.
- **Jadval ustidagi izoh:** «Violations can be removed after completion of second qualify break.» → ✅ to'g'ri matn: **«A `break_required` violation is resolved after a qualifying break; drive and shift violations after a daily rest.»** (`tz.md` Q58). §16

### 7.4.2 Logs By Driver — `/logs/by-driver`
- **Ruxsat:** `logs.read` · **Endpoint:** `GET /drivers/{id}/daily-logs?from=&to=&page=&per_page=`
- **Majburiy tanlov:** haydovchi (`Select driver` combobox). Tanlanmaguncha jadval o'rnida: «Select driver first, to display the data in the table.» (§6.5)
- **Filtr:** `Start date – End date` (default: oxirgi 8 kun — sertifikatsiya oynasi)

| Ustun | Manba |
|---|---|
| # | tartib |
| Date | `log_date` |
| Unit # | `unit_ids[]` → nomlar (bir nechta bo'lsa vergul bilan) |
| Distance | `distance_m` → §12 konvertatsiya |
| OFF / SB / DR / ON | `totals` | `HH:MM` |
| Certification | `certification_status` (`uncertified` warning · `certified` success · `needs_recertify` error) + `signed_at` |
| Ready | `ready` (`Not Ready` = imzo yo'q, `tz.md` Q25) |
| Warnings & Violations | `GET /violations?driver_id=&from=&to=` |
| Break/Drive/Shift/Cycle/Recap | kengaytirilgan ustunlar, `GET /drivers/{id}/hos-summary?date=` |

- **Satr bosilganda:** `/logs/:id`
- **F97** Dizayndagi sarlavha `Log By Driver` → ✅ kanonik **`Logs By Driver`** (`Logs By Unit` bilan parallel). §16

### 7.4.3 Log view — `/logs/:id`
- **Ruxsat:** `logs.read` · **Endpoint:** `GET /daily-logs/{id}` → `DailyLogDetail` (`events[]`, `form`, `totals`, `violations[]`, `certification_status`)
- **Breadcrumb:** `Logs By Unit › Unit # <n> › <sana>` (kirish yo'liga qarab)
- **Sarlavha bloki:** haydovchi (nomi, platforma/ilova versiyasi, online holati, telefon, co-driver havolasi), sana navigatori `‹ <sana> ›` (`GET /drivers/{id}/daily-logs` bilan qo'shni kunlar), o'ngda `Report` va `Current Location` tugmalari

**HOS bloki — 4 halqa** (`GET /drivers/{id}/hos-summary?date=`):
| Halqa | Manba | Rang |
|---|---|---|
| BREAK | `counters.break_remaining_min` | warning |
| DRIVE | `counters.drive_remaining_min` | success |
| SHIFT | `counters.shift_remaining_min` | blue |
| CYCLE | `counters.cycle_remaining_min` | primary |

Ostida: `Certified: Yes/No` · `W.H <ish soati>` · `Violations: <soni>` · `Policy version` (tooltip'da `policy_version_id`, `tz.md` Q10.1).
**F98 [MUST]** Dizayndagi `CYCLE 65:00` — **placeholder**. Haqiqiy chegara `hos_policy.cycle_limit_min` (default **4200 = 70:00**, `tz.md` §4.2). UI hech qanday raqamni hardcode qilmaydi — hammasi `hos-summary` javobidan. §16/§17-1.

**Tablar:** `Driver's Log` · `Report` · `Trip Planner`

**(a) Driver's Log — 24 soatlik grid:**
- Qatorlar `OFF · SB · DR · ON`, o'ng chekkada har status jami (`HH:MM`), pastda `Total: HH:MM`
- Chiziq rangi `#466FF7`; `PC` va `YM` — shtrix pattern bilan ajratiladi
- Grid ustida hodisa markerlari: **faqat `pti · fuel · certify · malfunction`** (`tz.md` Q15)
- Hover'da tooltip: vaqt (`HH:mm:ss`), status, joylashuv
- **F99** Grid **SVG** bilan chiziladi (canvas emas) — a11y uchun `<title>`/`aria-label`, va ekranni kattalashtirilganda sifat yo'qolmasligi uchun. 1440 px da 1 soat ≈ 52 px.
- Grid ostida ogohlantirish satrlari (§6.9)

**Voqealar jadvali** (`events[]`):
`# · Status · Start · Duration · Last Known Location · Odometer · Engine Hours · Document · Trailer · Notes · Origin · Action`
- `Status` ikki tur: **duty status** (`DR/OFF/SB/ON`, davomiylikka ega) va **hodisa** (`PTI/POWER ON/POWER OFF/FUEL/CERTIFY/MALFUNCTION/…`, nuqtaviy)
- `Origin` ustuni (dizaynda yo'q, ✅ qo'shiladi): `auto · driver · driver_edit · admin_edit · assigned · manual_no_eld`. `admin_edit`/`driver_edit` → `✎` belgisi + tooltip'da asl qiymat, kim, qachon (`tz.md` Q17.2). `manual_no_eld` → sariq belgi (`tz.md` Q7.1)
- `Action` → `Propose edit` (`logs.propose_edit`)

**LOG FORM bloki** (`form`): `Unit #(lar) · Driver · Co-Driver · Distance · Trailers[] · Shipping Docs[] · Signature`
- Trailers/Docs — yashil badge'lar; `Signature` — `Signed` (success) yoki `Not Signed` (error) + imzo tasviri (faqat ko'rish)

**(b) INSERT / EDIT DUTY STATUS paneli** — grid ustiga bosilganda ochiladi
- **Ruxsat:** `logs.propose_edit` · **Endpoint:** `POST /log-edit-requests`
- **Maydonlar:** status tugmalari `OFF · SLEEP · DRIVING · ON (YM) · OFF (PC) · ON` · `From *` · `To *` · `Note *`
- **F100 [MUST] Bu — to'g'ridan-to'g'ri tahrir EMAS.** `tz.md` §5.3 (FMCSA §395.30): admin **taklif** yuboradi, haydovchi tasdiqlaydi. UI aniq aytadi:
  - Tugma `Confirm` → ✅ **`Send edit request`**
  - Panel tepasida izoh: «This will be sent to the driver for approval. The log is not changed until the driver approves.»
  - Yuborilgandan keyin: toast + `/logs/edit-requests` ga havola
  - **Taqiqlar** (`tz.md` Q17.1) UI darajasida ham: avtomatik `DR` intervalini **qisqartirish yoki boshqa statusga o'zgartirish mumkin emas** — bunday tanlovda tugma `disabled` + sabab; `intermediate`, `power_*`, `malfunction` eventlari tahrirlanmaydi (`Action` menyusi yo'q)
  - `Note *` majburiy, ≤ 60 belgi
- 🎨 Dizaynda tugma `Confirm` va hech qanday tasdiq oqimi ko'rsatilmagan — bu **eng katta dizayn↔TZ farqi**, §16 da qayd etilgan.

**(c) Report tabi:** `GET /daily-logs/{id}/pdf` (`logs.export`) → PDF `<iframe>`/`<object>` da ko'rsatiladi + `Download` tugmasi. Yuklanish — skeleton; xato — `ErrorState` + qayta urinish.

**(d) Trip Planner tabi:**
- **Endpointlar:** `GET /units/{id}/trips?date=` (`tracking.view_history`) · `GET /trips/{id}?include_polyline=true` · `POST /routes` (`routes.create`)
- Xarita + raqamli to'xtash markerlari; nuqta kartochkasi: `Status · Date · Odometer · Location · Coordinates · Duration · Stopped`
- **F101** Koordinata formati: **`36.9876543, 23.9746455`** — nuqta o'nlik ajratgich, vergul juftlik ajratgichi, **7 xona** (≈1 sm aniqlik). Dizayndagi `23,97464553778` — xato. §16
- **`Plan a Trip` formasi:** `From *` (matn + «Copy last location») · `To *` (manzil qidiruvi) · `Geofence radius` (default **300 m**, `tz.md` Q66) · `Note` → `POST /routes` → haydovchiga push. Tugma `Run Trip` → ✅ **`Create route`** (§16)
- `GET /routes/{id}/directions` — chizilgan marshrut polyline'i

### 7.4.4 Log Edit Requests — `/logs/edit-requests` 🎨
- **Ruxsat:** `logs.read` · **Endpointlar:** `GET /log-edit-requests?status=&driver_id=` · `POST /log-edit-requests/{id}/approve` (`logs.approve_edit`) · `POST /log-edit-requests/{id}/reject` (`logs.reject_edit`)
- **Tablar/filtr:** `Pending` · `Approved` · `Rejected`; `driver_id`
- **Ustunlar:** `# · Driver · Log date · Proposed change (from → to, status) · Note · Proposed by · Created · Status · Action`
- **Amallar:** `View` (log view'ga havola) · `Approve` / `Reject` (sabab majburiy) — **faqat tegishli ruxsat bilan**
- **F102** Dizaynda ekran **yo'q** (🎨) — `tz.md` §23 da «Pending edits ekranlari — dizayn buyurtmasi kerak» deb qayd etilgan. Standart ro'yxat patterni bilan quriladi.
- **F103** Adminning o'z taklifini o'zi tasdiqlashi backendda bloklanadi; UI'da ham `Approve` tugmasi taklif qiluvchi uchun ko'rinmaydi.

### 7.4.5 Unassigned Driving — `/logs/unassigned` 🎨
- **Ruxsat:** `logs.assign_unidentified` (ro'yxat) · **Endpointlar:** `GET /unidentified-events?status=&unit_id=&from=&to=` · `POST /unidentified-events/{id}/assign` (`logs.assign_unidentified`) · `POST /unidentified-events/{id}/annotate` (`logs.annotate_unidentified`) · `POST /unidentified-events/{id}/claim` (`logs.claim_unidentified`, mobil)
- **Ustunlar:** `# · Unit # · Start · End · Duration · Distance · Start/End location · Status (`pending|assigned|annotated`) · Action`
- **Amallar:** `Assign to driver` (select + izoh → **haydovchiga taklif ketadi**, `tz.md` §10.4) · `Annotate` (izoh bilan «unassigned» qoldirish, masalan mexanik test-drive) · xaritada trekni ko'rish
- **F104** 8 kundan ortiq `pending` — satr `error` fonda + Dashboard KPI (`unassigned_driving`) bilan bog'langan (`tz.md` Q57 `unidentified_driving` violation).

### 7.4.6 Violations — `/violations`
- **Ruxsat:** `violations.read` · **Endpointlar:** `GET /violations`, `GET /violations/{id}`
- **Filtrlar:** `driver_id` · `type` (10 qiymat: `form_manner_trailer, form_manner_doc, drive_limit, shift_limit, break_required, cycle_limit, uncertified_log, unidentified_driving, eld_malfunction, missing_dvir`) · `severity` (`warning|violation`) · `resolved` (boolean) · `from`/`to`
- **Ustunlar:** `# · Date · Driver · Unit · Type · Severity · Occurred at · Resolved at · Action`
- **Detal (`/violations/:id`):** tur tavsifi, HOS konteksti (o'sha kunning hisoblagichlari), tegishli daily log'ga havola, `resolved_at` va yopilish sababi
- **F105** Violation **o'chirilmaydi** (`tz.md` Q58, Q82.2) — `Delete` amali yo'q, faqat `resolved` badge.

---

## 7.5 DVIR — `/dvir`

- **Ruxsat:** `dvir.read` · **Endpointlar:** `GET /dvir-reports`, `GET /dvir-reports/{id}`, `GET /dvir-reports/pending-certification`, `POST /dvir-reports/{id}/repair` (`dvir.repair`), `POST /dvir-reports/{id}/certify` (`dvir.certify`), `GET /dvir-reports/{id}/pdf` (`dvir.export`)
- **Tablar:** `All` · `Pending certification` (`GET /dvir-reports/pending-certification`)
- **Filtrlar:** `unit_id` · `driver_id` · `type` (`pre_trip|post_trip`) · `status` · `from`/`to`

| Ustun | Manba |
|---|---|
| # | tartib |
| Driver Name | |
| Unit # / Trailer | |
| Type | `pre_trip` / `post_trip` badge |
| Defects | nuqsonlar soni; kritik bo'lsa qizil ikonka |
| Location | manzil matni |
| Created At | `created_at` |
| Status | 6 qiymat (quyida) |
| Action | `···` |

**F106 [MUST] Status to'plami — backend enum'i ustun:**
`draft · submitted_no_defects · submitted_defects_found · repaired · certified · closed_no_certification`
Dizayndagi 7 qiymat (`Not Started`, `In Progress`, `Submitted`, `Submitted - No Defects`, `Submitted - Defects Found`, `Repaired`, `Certified`) bilan moslashtirish:
| Dizayn | Backend | Qaror |
|---|---|---|
| `Not Started` | — | ✅ **derived**, ro'yxatda emas: «Units without a DVIR today» filtri (`tz.md` Q30.2) |
| `In Progress` | `draft` | ✅ faqat mobil lokal holat; admin ro'yxatida **ko'rsatilmaydi** (Q30.2) |
| `Submitted` | — | ✅ olib tashlanadi (ikki aniq holat bor) |
| `Submitted - No Defects` | `submitted_no_defects` | ✅ |
| `Submitted - Defects Found` | `submitted_defects_found` | ✅ |
| `Repaired` | `repaired` | ✅ |
| `Certified` | `certified` | ✅ |
| — | `closed_no_certification` | ✅ **yangi**: unit inactive bo'lganda yopilgan (Q30.1) |

- **Detal (`/dvir/:id`):** sarlavha + status · unit/trailer · tur · vaqt/joylashuv/odometer · nuqsonlar ro'yxati (kategoriya, `is_critical`, foto ≤ 5, izoh) · haydovchi imzosi (ko'rish) · mexanik imzosi (agar bor) · tarix (kim, qachon, qaysi holatga)
- **Amallar:** `Record repair` (`dvir.repair`) — modal: izoh (majburiy), invoice fayl (ixtiyoriy, §10) · `Certify` (`dvir.certify`) · `Download PDF`
- **F107 [MUST]** Admin **DVIR yaratmaydi** (`tz.md` Q31). Dizayndagi `Generate Report` formasi (`Paste driver signature here`, `Paste mechanic signature here`) — **olib tashlanadi**. Uning o'rniga: (a) `/dvir` ro'yxati + filtrlar, (b) `Export` → `POST /reports/export-jobs {type:"dvir"}` (§11). §16
- **F108** Kritik nuqsonli DVIR → unit `out_of_service` bayrog'i; ro'yxatda va Unit ekranida qizil banner (`tz.md` Q27.2).

---

## 7.6 Maintenance — `/maintenance`

**Uchta tab, uchta ma'lumot manbai:**

| Tab | Marshrut | Endpoint | Ruxsat |
|---|---|---|---|
| Schedule | `/maintenance/schedules` | `GET /maintenance-schedules?status=&q=` | `maintenance.read` |
| Due | `/maintenance/due` | `GET /maintenance/due?unit_id=&schedule_id=&status=` | `maintenance.read` |
| History | `/maintenance/history` | `GET /maintenance-records?unit_id=&status=completed\|cancelled&from=&to=` | `maintenance.read` |

**Schedule ustunlari:** `# · Unit # (yoki «N Units») · Type · Schedule Name · Maintenance Frequency · Status · Action`
**Due ustunlari:** `# · Unit # · License Plate · Type · Schedule Name · **Remaining Frequency** · **Reminder Sent** · Action`
**F109** Dizaynda bo'sh holatda `Remind`/`Due Date`, to'la holatda `Remaining Frequency`/`Reminder Sent` ustunlari edi. ✅ **Ikkalasida ham `Remaining Frequency` va `Reminder Sent`** — bo'sh va to'la holat ustunlari **hech qachon farq qilmaydi**. §16

**History ustunlari:** `Maintenance Date · Unit # · Driver Name · Make & Model · Type · Status · Invoice # · Vendor Name · Cost · Schedule Name · Odometer · Engine Hours · Attachment · Action`
(11 dan ortiq ustun → default'da `Odometer`, `Engine Hours`, `Attachment` yashirin — F56)

- **Amallar:** `Add Maintenance` (`POST /maintenance-schedules`, `maintenance.create`) · satr: `View · Edit (PATCH) · Mark as Complete (POST /maintenance-schedule-units/{id}/complete) · Cancel (POST …/cancel) · Delete (DELETE /maintenance-schedules/{id})`
- **Guruh ichiga kirish:** `N Units` satri bosilganda → `/maintenance/schedules/:id/units`, breadcrumb `Due › N units`, ustunlar Due bilan bir xil, `Refresh` tugmasi

**Add / Edit formasi — `MAINTENANCE DETAILS`** (imlo to'g'rilangan: dizaynda `MAINTAINANCE DETAILS`):

| Maydon | Tur | Majburiy | Izoh |
|---|---|---|---|
| Maintenance Type | select | ✅ | katalog: Oil Change, Tyre, Engine Oil Change, Lights Change, Lease Expiry, **Grease** (dizaynda `Grese`) |
| Mode | radio | ✅ | `Single Unit` / `Multiple Units` |
| Unit # | select | ✅ (single) | |
| Units | ko'p tanlov | ✅ (multiple) | `Select All` + har unit uchun `last_service_value` |
| Maintenance Frequency | son + birlik | ✅ | birlik: `km/mi` (§12) · `days` · `engine hours` |
| Set Reminder (before service due) | son + birlik | ✅ | |
| Schedule Name | text | ✅ | |
| Current Frequency → **Last service value** | son + birlik | — | `tz.md` Q33: dizayn labeli qoladi, ma'nosi tooltip'da |
| Alert Type | select | ✅ | ✅ **`maintenance_upcoming` / `maintenance_overdue`** (backend `alert_type` enum'idan) — dizaynda ro'yxat berilmagan edi |
| Delivery Method | ko'p tanlov | ✅ | ✅ **`push · email · sms · in_app`** (`tz.md` Q89) |
| Notify co-driver | checkbox | — | ✅ kanonik yozuv: **`Notify co-driver`** (kichik harf) |
| Notes | textarea | — | ≤ 60 |

**F110 Formulalar** (`tz.md` Q33, dizayn bet 45 bilan mos):
`next_due_value = last_service_value + interval` · `remaining = next_due_value − current_value` · `remaining < 0` → **Overdue**, qizil (dizaynda `0verdue` — imlo xatosi, §16)
UI hech qanday formulani o'zi hisoblamaydi — barcha qiymatlar backenddan. Faqat **birlik konvertatsiyasi** frontendda (§12).

**View (single):** `Unit # · Schedule Name · Maintenance type · Last service value · Maintenance Frequency · Next Frequency · Remind before · Alert Type · Delivery Method · Notify co-driver · Notes`
**View (multiple):** yuqoridagi + `UNITS` jadvali (`Unit · Last service value · Next Frequency · Remaining`)

**`MARK MAINTENANCE AS COMPLETE` modali** (`POST /maintenance-schedule-units/{id}/complete`, `maintenance.complete`):
`Invoice #` · `Vendor Name` · `Cost` · `Maintenance Date` · `Invoice` (fayl — §10, `kind=invoice`)
**F111** Dizaynda «faqat PDF» yozilgan; `tz.md` §18.3: **PDF/JPG/PNG ≤ 10 MB**. ✅ TZ ustun. §16
**Cancel modali** (`POST …/cancel`): sabab (majburiy). Cancelled yozuvda moliyaviy maydonlar bo'lmaydi.

**F112** Dizayndagi eskirgan `Verification` tabi va `Mark Maintenance as Rejected` oqimi **yo'q** (amaldagi qatlamda ham olib tashlangan, backendda ham yo'q).
**F113** History detalidagi `PRE-TRIP INSPECTION` / `POST-TRIP INSPECTION` bloklari — dizaynda bo'sh edi. ✅ O'sha unit uchun **o'sha sanadagi DVIR'lar** ro'yxati bilan to'ldiriladi (`GET /dvir-reports?unit_id=&from=&to=`), har biri `/dvir/:id` ga havola.

### 7.6.1 Defect Types — `/settings/defect-types` 🎨
- **Ruxsat:** `defect_types.read` · `GET/POST /defect-types`, `PATCH /defect-types/{id}`
- **Filtrlar:** `category` (`truck|trailer`) · `is_active` · `is_critical`
- **Ustunlar:** `Name · Category · Critical · Active · Action`
- **F114** Dizayndagi 44 bandli truck ro'yxatidagi **`Engine` dublikati va `Refresh`** (nuqson emas) **olib tashlanadi** (`tz.md` Q27.1). §16

---

## 7.7 Tracking

### 7.7.1 Tracking ro'yxati — `/tracking`
- **Ruxsat:** `tracking.view_live` · **Endpoint:** `GET /tracking/live` + WS `tracking` kanali
- **Filtrlar:** `unit_ids` · `branch_id` · `online_status` (`online|idle|offline|disconnected`) · `include_inactive` · `search` (driver/unit — klient tomonda, backend `search` bermaydi)

| Ustun | Manba |
|---|---|
| # | tartib |
| Driver Name | `driver.name` |
| Unit # | `unit_number` |
| Status | `duty_status` chip |
| Device | `online_status` badge + `eld_device_serial` |
| Speed | `speed_kmh` → §12 |
| Last Known Location | `lat`, `lng` + reverse-geocode matni + `last_seen_at` nisbiy vaqt |
| Action | `Track on Map` |

- **F115** WS `unit_last_state` kelganda satr **joyida yangilanadi** (jadval qayta yuklanmaydi): `queryClient.setQueryData` bilan. Yangilangan satr 600 ms `bg-light` bilan yonib o'chadi.
- **F116** `online_status` filtri backend enum'ida `idle` ham bor (`websocket.md` da yo'q) — UI to'rt qiymatni ham beradi.

### 7.7.2 Track on Map — `/tracking/units/:unitId` (yoki `/units/:id/track`)
- **Ruxsat:** `tracking.view_live` (+ `tracking.view_history` tarix uchun, `units.diagnostics` diagnostika uchun)
- **Endpointlar:** `GET /tracking/live?unit_ids=` · `GET /units/{id}/trips?date=` · `GET /trips/{id}?include_polyline=true` · `GET /units/{id}/diagnostics` · WS `tracking` (`filter.unit_ids`)
- **Breadcrumb:** `Unit Management › Unit # 101 › Track on Map` **yoki** `Tracking › Unit # 101` — ikki kirish yo'li
- **Tarkib:** xarita (to'liq kenglik) + o'ng yon panel (yig'ilgan/yoyilgan, `›` tugmasi bilan)
- **Xarita boshqaruvlari:** sarlavha `Unit # <n>` + `←` · `Refresh` (majburiy re-fetch, `tz.md` Q63) · sana navigatori `‹ <sana> ›` · qatlam tanlash · joylashuvga o'tish · `+`/`−` zoom
- **Yon panel — 3 blok:**
  1. **Haydovchi:** nomi + ogohlantirish ikonkasi, online holati, joylashuv, batareya, tezlik, vaqt tamg'asi, `Shift ends in HH:MM:SS` (`hos-summary` dan)
  2. **UNIT DIAGNOSTICS** (`GET /units/{id}/diagnostics` → `telemetry{}`): `VIN · Engine Hours · Odometer · Fuel · Bus · Coolant Level % · Coolant Temperature · Oil Level %` + `malfunction_codes[]`
  3. **HISTORIES** (`GET /units/{id}/trips?date=`): har segment — boshlanish nuqtasi, `Range`, `Duration`, tugash nuqtasi; vertikal timeline; segment bosilganda xaritada polyline yoritiladi
- **F117 [MUST]** Blok nomi **`Unit Diagnostics`** — ikkala kirish yo'lida ham (dizaynda Tracking'dan kirilganda `Unit Inspection` edi; `tz.md` §1.3 kanonik nomi `Unit Diagnostics`). §16

### 7.7.3 Routes — `/routes`
- **Ruxsat:** `routes.read` · **Endpointlar:** `GET/POST /routes`, `GET/PATCH/DELETE /routes/{id}`, `GET /routes/{id}/directions`, `POST /routes/{id}/not-completed` (`routes.complete`)
- **Filtrlar:** `status` (`ongoing|completed|not_completed|cancelled`) · `unit_id` · `driver_id`; saralash `created_at|sequence|status`
- **Ustunlar:** `# · Unit # · Driver · From · To · Sequence · Geofence · Started · Completed · Status · Action`
- **Amallar:** `Create route` · `Edit` · `Close as not completed` (sabab: `breakdown · cancelled · load_rejected · road_closed · driver_change · other` + izoh) · `Delete`
- **F118** `ongoing → completed` **avtomatik** (geofence ichida ≥ 2 daq, `tz.md` Q66–68) — UI'da qo'lda "Complete" tugmasi **yo'q**, faqat `not-completed`. §16/§17-10
- **F119** Dashboard DTO'sida route status enum'i `planned|in_progress|completed|not_completed|cancelled`, Routes DTO'sida `ongoing|completed|not_completed|cancelled`. ✅ **Routes DTO'si kanonik** (`tz.md` Q66); UI ikkala qiymatni ham qabul qiladigan normalizator yozadi (`planned|in_progress → ongoing`) va farqni §17 ga backend CR sifatida chiqaradi.

---

## 7.8 Reports

**Umumiy:** har hisobotda filtr paneli + jadval/ko'rsatkichlar + `Export` tugmasi. Eksport — **asinxron** (§11), istisno: `GET /units/export`, `GET /drivers/export` (darhol fayl).

### 7.8.1 Activity Report — `/reports/activity`
- **Ruxsat:** `reports.read` · **Endpoint:** `GET /reports/activity?subject=drivers|units&from*&to*&unit_id&driver_id`
- **Tablar:** `Drivers` / `Units` (`subject`)
- **Drivers ustunlari:** `Driver Name · Start Odometer · End Odometer · Odometer Change · Driving Time (HH:MM:SS)`
- **Units ustunlari:** `+ Unit #`
- **F120** Dizaynda oxirgi ustun `Odometer Change` deb ikki marta yozilgan. ✅ `tz.md` §1.3: **`End Odometer`** oxirgi ustun, `Odometer Change` alohida ustun (`= End − Start`, Q75). §16
- **F121** Dizaynda `Download CSV` tugmasi **ikki joyda** takrorlangan → ✅ **bitta**, filtr panelida. §16
- **Detal:** `/reports/activity/:subjectId` — breadcrumb `Activity Report › <nom>`; ustunlar `# · Date · Start · Duration · Location · Odometer · Eng. Hrs · Document · Notes`
- **Eksport:** `POST /reports/export-jobs {type:"activity", format:"csv|xlsx|pdf", params:{…}}`

### 7.8.2 Distance by Region — `/reports/distance-by-region` (dizaynda «IFTA Report»)
- **Ruxsat:** `reports.read` · **Endpoint:** `GET /reports/distance-by-region?quarter*&year*&mode=regions_and_units|regions_only&unit_id`
- **F122 [MUST]** Ekran nomi `regulation_profile` ga bog'liq (`tz.md` Q0.2): `fmcsa_us` → **`IFTA Report`**, `generic` → **`Distance by Region`**. Bitta i18n kalit, ikkita qiymat.
- **Yuqori ko'rsatkichlar:** `IFTA Miles / In-region distance` · `Non-IFTA / Out-of-region` · `Total` (`Total = In + Out`)
- **Tablar:** `Units` (`Unit # · VIN · Region · Distance · Month`) / `Regions` (`Region · Total distance`)
- **Filtrlar:** `Year *` · `Quarter *` · `Region` · `Unit`
- **F123** Dizayndagi eslatma «Reports will be ready by the fifth day of each month» **olib tashlanadi** — `tz.md` §14: kunlik agregat (`unit_region_distance_daily`), hisobot **darhol tayyor**. §16
- **F124** Dizayndagi shtat kodlari orasida `XT` bor — AQSh shtat kodi emas, test ma'lumoti xatosi. Regionlar ro'yxati **backenddan** (`company.settings.distance_regions`), hardcode qilinmaydi. §16
- **Generate modali:** `GENERATE AS` (`csv|pdf|xlsx`) · **`GET BY`** (dizaynda `GET BTY` — imlo xatosi) → `regions_and_units` / `regions_only` · `Regions *` (ko'p tanlov) · `Units *` (faqat `regions_and_units` rejimida — shartli maydon) · `Quarter *` · `Year *` → `POST /reports/export-jobs {type:"distance_by_region"}`

### 7.8.3 Regulator Export — `/reports/regulator` (dizaynda «FMCSA Report»)
- **Ruxsat:** `reports.read` / `reports.export` · **Endpointlar:** `GET /reports/export-jobs?type=regulator` · `POST /reports/export-jobs {type:"regulator"}` · `GET /reports/export-jobs/{id}`
- **F125** Ekran nomi profilga bog'liq: `fmcsa_us` → **`FMCSA Report`**, `generic` → **`Regulator Export`**.
- **Ustunlar:** `# · Driver Name · Comment · Start Date · End Date · Status (queued|running|done|failed) · Processed Time (finished_at) · Job ID · Action (Download)`
- **F126** Dizayndagi `Submission ID` (UUID) → ✅ **`Job ID`** = `export_job.id`. Dizayndagi `Status: Pending / Information` → backend enum'i `queued|running|done|failed`. §16
- **Generate modali — `REPORT DETAILS`:** `Type *` (`Roadside inspection report (8 days)` / `Custom Range`) · `Driver *` · `From */To *` (faqat Custom Range) · `Comment *`
- **F127** `tz.md` §14: `fmcsa_us` da FMCSA output file + web-service — **2-bosqich**; `generic` da PDF+CSV darhol. UI ikkalasini `export_job.format` orqali qo'llab-quvvatlaydi.

### 7.8.4 DVIR Report — `/reports/dvir`
- **Ruxsat:** `reports.read` · **Endpointlar:** `GET /dvir-reports` (jonli ro'yxat) · `POST /reports/export-jobs {type:"dvir"}`
- **F107** ga muvofiq: **imzo joylashtirish formasi yo'q**. Faqat filtr (`Driver`, `Unit`, `Date range`, `Type`, `Status`) + `Export` (`csv|xlsx|pdf`).

### 7.8.5 Uncertified Logs — `/reports/uncertified-logs`
- **Ruxsat:** `reports.read` · **Endpoint:** `GET /reports/uncertified-logs?driver_id&branch_id`
- **Ustunlar:** `Driver · Log date · Days uncertified · Unit · Totals · Action (Send reminder / Open log)`
- **F128** `tz.md` Q19.1: 8 kundan eskirgan sertifikatlanmagan kunlar **shu hisobotda** ko'rinadi (haydovchi ilovasidagi 8 kunlik oynadan tashqarida ham).

### 7.8.6 HOS Summary export
- `POST /reports/export-jobs {type:"hos", params:{driver_id, from, to}}` — alohida ekran emas, Logs By Driver va Driver View'dagi `Export` tugmasi.

### 7.8.7 Export Jobs — `/reports/exports`
- **Ruxsat:** `reports.read` · **Endpointlar:** `GET /reports/export-jobs?status&type&mine` · `GET /reports/export-jobs/{id}`
- **Ustunlar:** `# · Type · Format · Params · Requested by · Created · Started · Finished · Size · Status · Download`
- **F129** `mine=true` — default (o'z eksportlarim); `Show all` toggle bilan kompaniya bo'yicha. Batafsil oqim — §11.

---

## 7.9 Chat — `/chat`

- **Ruxsat:** `chat.read` (o'qish), `chat.send` (yozish) · **Endpointlar:** `GET /chat/threads?with_messages=` · `GET /chat/threads/{driver_id}/messages?before=&limit=` · `POST /chat/threads/{driver_id}/messages` · `POST /chat/messages/{id}/read` · WS `chat` kanali
- **Tarkib:** chapda suhbatlar ro'yxati (`Search driver`, oxirgi xabar parchasi, vaqt, o'qilmagan badge), o'ngda yozishma
- **Xabar:** matn ≤ 2000 (`tz.md` §15.4) · rasm/PDF ≤ 10 MB (`kind=chat`, §10) · joylashuv ulashish (ko'rish)
- **Holatlar:** `sent · delivered · read` — belgichalar; sana ajratgichlari (`Today`, `Yesterday`, `<hafta kuni>`)
- **F130** Yuklash: `before` kursori bilan yuqoriga scroll («Load older messages»). Yangi xabar WS `chat_message` orqali; ko'rinib turgan xabarlar `POST /chat/messages/{id}/read` bilan belgilanadi (IntersectionObserver + 1 s debounce).
- **F131 [MUST]** Dizayndagi demo yozishmalar («Did you finish the Hi-FI wireframes for flora app design?») **boshqa loyihadan** — butunlay olib tashlanadi. Bo'sh holat: `No conversations yet` / «Select a driver to start a conversation». §16
- **F132** Fayl biriktirish, o'qilgan belgisi, onlayn holati dizaynda **yo'q** → 🎨 qo'shiladi (TZ §15.4 talab qiladi).
- **F133** Haydovchi haydash rejimida bo'lsa (`duty_status=DR`) — admin tomonida ogohlantirish: «Driver is driving; the message will be delivered but not shown until they stop.» (`tz.md` §15.4).

---

## 7.10 Support & History

### 7.10.1 Contact Support — `/support`
- **Ruxsat:** `support.read` · **Endpointlar:** `GET /support-tickets`, `GET /support-tickets/{id}`, `GET/POST /support-tickets/{id}/messages` (`support.create`), `PATCH /support-tickets/{id}/status` (`support.update_status`), `POST /support-tickets` (`support.create`)
- **Filtrlar:** `status` (`new|in_progress|resolved|closed`) · `driver_id` · `search` · `from`/`to`; saralash `created_at|status|subject`
- **Ustunlar:** `**Ticket #** · Driver Name · **Subject** · Issue Date · Status · Action`
- **F134** Dizaynda bo'sh holatda `Ticket ID`/`Message`, to'la holatda `Ticket #`/`Subject` edi. ✅ `tz.md` §1.3: **`Ticket #`, `Subject`** — ikkala holatda ham. §16
- **F135** Status yozuvi: ✅ **`In Progress`** (dizaynda `In-Progress` varianti ham bor edi). Backend qiymati `in_progress`, ko'rsatiladigan matn `In Progress`. §16
- **Detal (`/support/:id`) — `TICKET DETAILS`:** `Ticket # · Status · Driver · Contact On · Email/Phone · Issue Date · Subject · Description` + **thread** (xabarlar ro'yxati + javob yozish maydoni + fayl ≤ 3)
- **F136** Dizaynda thread yo'q edi (faqat statik tavsif). ✅ `tz.md` §15 qo'shimchasi: admin javobi tiket ichida. 🎨
- **Status o'zgartirish modali:** `Status` select + `Cancel/Save`; `new → in_progress → resolved` (backendda `closed` ham bor)

### 7.10.2 Feedback — `/feedback`
- **Ruxsat:** `feedback.read` · **Endpoint:** `GET /feedback?driver_id&min_rating&from&to`; saralash `submitted_at|app_rating`
- **Ustunlar:** `# · Driver Name · App Rating (1–5 yulduz) · Feedback · App version · Submitted On`
- **F137** Feedback javob talab qilmaydi (`tz.md` Q79) — amal tugmasi yo'q. Uzun matn `truncate` + **satr bosilganda modal** bilan to'liq ko'rinadi (dizaynda ochilgan ko'rinish yo'q edi). 🎨

### 7.10.3 Histories — `/audit`
- **Ruxsat:** `audit.view` · **Endpointlar:** `GET /audit-log?table&record_id&user&action&from&to&order` · `GET /audit-log/tables`
- **F138 [MUST]** `tz.md` §17: UI'dagi **4 jurnal** (Unit Activities, Driver Activities, Histories, Company history) — bitta `audit_log` ustidagi **filtrlangan ko'rinishlar**. Alohida ma'lumot manbai yo'q.

| UI jurnali | Marshrut | Filtr |
|---|---|---|
| Histories (barcha) | `/audit` | filtrsiz + `table` tanlovi (`GET /audit-log/tables`) |
| Unit Activities | `/units/:id/activities` | `GET /units/{id}/history` |
| Driver Activities | `/drivers/:id/activities` | `GET /drivers/{id}/activities` |
| Company history | `/settings/company-history` | `GET /company/history` |

- **Ustunlar:** `Date · User (Edited By) · Action · Table · Record · Changes`
- **`Changes` formati:** `<FIELD> changed from <eski> to <yangi>`; bo'sh qiymat — ✅ **`N/A`** (dizaynda `na` va `N/A` aralash edi, `tz.md` §1.3). §16
- **F139** Dizayndagi `Histories` sahifasining `Add User` tugmasi **olib tashlanadi** (mos emas, `tz.md` §1.3). Filtr panelidagi `Export Drivers`/`Import Drivers` ham olib tashlanadi. §16
- **F140** Sana formati: hafta kuni **3 harf** (`Mon, Tue, Wed, Thu, Fri, Sat, Sun`) — dizayndagi `Tues`/`Thurs` (4 harf) to'g'rilanadi (`tz.md` §1.3). `Intl.DateTimeFormat` `weekday:'short'` buni avtomatik beradi. §16
- **F141** `audit_log` **append-only** — hech qanday tahrir/o'chirish amali yo'q.

---

## 7.11 Notifications (header dropdown + sahifa) — `/notifications`

- **Ruxsat:** `notifications.read` · **Endpointlar:** `GET /notifications?read&alert_type` · `PATCH /notifications/{id}/read` · `POST /notifications/read-all` · WS `notifications` kanali
- **Header dropdown:** oxirgi 10 ta, o'qilmaganlar soni badge'da, «Mark all as read», «See all»
- **Sahifa:** sana bo'yicha guruhlangan (`Today`, `Yesterday`, `<sana>`), filtr `alert_type` (16 qiymat) va `read`
- **F142** Har bildirishnoma `entity_type`/`entity_id` bo'yicha tegishli ekranga o'tadi: `violations → /violations/:id`, `dvir → /dvir/:id`, `log_edit_request → /logs/edit-requests`, `maintenance_* → /maintenance/due`, `chat_message → /chat`, `unidentified_driving → /logs/unassigned`.
- **F143** WS `notification_created` kelganda: (a) ro'yxat keshi yangilanadi, (b) `alert_type` `*_violation|dvir_critical|eld_malfunction` bo'lsa — toast ham chiqadi. Klient `user_id` bo'yicha filtrlaydi (`websocket.md` §4.2 — kanal butun kompaniyani tashiydi).
- **F144** Vaqt formati: ✅ **nisbiy 24 soatgacha** (`2 hours ago`), keyin absolyut (`28 May, 10:04`). Dizaynda mobil nisbiy / planshet absolyut edi. §16

---

## 7.12 Inspection logs — `/inspection` **[MAY]**
- **Ruxsat:** `inspection.view` · `GET /inspection/logs?driver_id&date`; `POST /inspection/email` (`inspection.email`), `POST /inspection/transfer` (`inspection.transfer`)
- Asosan haydovchi/planshet oqimi. Web'da faqat **tarix**: kim, qachon, qaysi haydovchi uchun yo'l tekshiruvini ochgan; hisobotni qayta yuborish. 🎨 dizayn yo'q.

---

## 7.13 Settings — `/settings/*`

Kirish — profil menyusi orqali (dizayndagidek). Chapda ichki vertikal navigatsiya.

| Tab | Marshrut | Endpoint | Ruxsat |
|---|---|---|---|
| Company | `/settings/company` | `GET/PATCH /company` | `company.read` / `company.update` |
| Branches | `/settings/branches` | `GET/POST /company/branches`, `PATCH/DELETE /company/branches/{id}` | `branches.*` |
| Users | `/users` (Fleet menyusidan) | — | — |
| Roles | `/roles` | — | — |
| HOS Policy | `/settings/hos-policy` | `GET /company/hos-policy`, `POST /company/hos-policy` | `hos_policy.read/update` |
| Notifications | `/settings/notifications` | `GET/PATCH /company/notification-settings` | `notification_settings.*` |
| Defect Types | `/settings/defect-types` | §7.6.1 | `defect_types.*` |
| Company history | `/settings/company-history` | `GET /company/history` | `company.history.view` |
| Profile | `/settings/profile` | `GET /me` | authenticated |
| Security | `/settings/security` | `GET/DELETE /auth/sessions`, `POST /auth/2fa/*`, `POST /auth/password/*` | authenticated |

### 7.13.1 Company
**Maydonlar:** `Company Name *` · `Address *` · `Home Terminal Address *` · `Timezone *` (IANA ro'yxati) · `Email *` · `Phone *` · **`Registration No`** (label: `regulation_profile=fmcsa_us` → `US DOT`) · `Logo` (fayl, `kind=logo`) · `Region` (`PK|UZ|US|other`) · `Unit system` (`metric|imperial`) · `Regulation profile` (`generic|fmcsa_us`) · `Distance regions`
**Faqat ko'rish:** `plan`, `subscription_status`, `subscription_end_at` (o'zgartirish — Super Admin).
**F145 [MUST]** `unit_system` yoki `regulation_profile` o'zgartirilganda: tasdiq dialogi («This changes date formats and units across the whole panel») + saqlangandan keyin `GET /me` qayta olinadi va butun UI qayta formatlanadi (§12).

### 7.13.2 Branches 🎨
`Name · Address · Timezone · Users · Units · Action`. Sodda CRUD (`tz.md` §1: «🎨 oddiy CRUD ekran kerak [SHOULD]»).

### 7.13.3 HOS Policy 🎨 **[MUST]**
- **Endpoint:** `GET /company/hos-policy` (joriy amaldagi), `POST /company/hos-policy` (yangi versiya chiqarish)
- **Maydonlar** (`tz.md` §4.2, 15 parametr): `drive_limit_min` · `shift_window_min` · `break_required_after_drive_min` · `break_duration_min` · `break_qualifying_statuses[]` · `daily_rest_min` · `cycle_limit_min` · `cycle_days` · `cycle_restart_min` · `sleeper_split_enabled` · `allow_pc` · `allow_ym` · `ym_max_speed_kmh` · `motion_threshold_kmh` · `warning_thresholds{}` · `short_haul_exception` **[MAY]** · `adverse_conditions_extension_min` **[MAY]**
- **F146 [MUST]** Vaqt parametrlari UI'da **soat:daqiqa** sifatida kiritiladi (`11:00`), API'ga **daqiqada** yuboriladi. Preset tugmalari: `FMCSA 70/8` · `FMCSA 60/7`.
- **F147 [MUST]** `POST` — **yangi versiya yaratadi** (`effective_from` bilan), eskisini o'zgartirmaydi (`tz.md` Q10.1: retroaktiv violation paydo bo'lmaydi). UI aniq aytadi: «Publishing creates a new policy version effective from <sana>. Past days keep the policy that was in force then.» + tasdiq dialogi.
- **Versiyalar tarixi:** `effective_from`, `created_by`, farqlar (diff) ko'rinishi.

### 7.13.4 Notification settings 🎨
- **Endpoint:** `GET/PATCH /company/notification-settings`
- **Matritsa:** qator — 16 `alert_type`, ustun — kanal (`push · email · sms · in_app`), katak — checkbox; qo'shimcha ustun: **qabul qiluvchi rollar**.
- **F148** `hos_*` va `eld_*` uchun push **o'chirilmaydi** (`tz.md` Q89) — checkbox `disabled` + tooltip sabab bilan.

### 7.13.5 Company history
`Edited By · Changes · Date` + filtrlar (`table`, `action`, `record_id`, `user`, `from`, `to`).
**F149** Dizayndagi uchta mustaqil qidiruv (`Search Driver` · `Search Dispatcher` · `Search Unit`) → ✅ **bitta `user` filtri + `table` filtri**. `Dispatcher` so'zi faqat shu ekranda uchraydi va rol nomi sifatida ishlatilgan — olib tashlanadi. §16

### 7.13.6 Profile
`First Name * · Last Name * · Email * · Phone` (+ avatar).
**F150** Dizayndagi **`Last Address *`** — imlo/mantiq xatosi, ✅ **`Last Name`**. Placeholder'lardagi `Lorem ipsum` va `Address` — haqiqiy matnga almashtiriladi. §16

### 7.13.7 Security
- `Change password`: `Current password *` · `New password *` · `Confirm *`
- **F151** Dizaynda **eski parolni so'rash maydoni yo'q** edi — ✅ qo'shiladi (xavfsizlik talabi, sessiya o'g'irlangan holatda parolni almashtirishning oldini oladi). §16
- `Two-factor authentication`: yoqish/qayta o'rnatish (`POST /auth/2fa/setup|verify`)
- `Active sessions`: `GET /auth/sessions` → `Device type · Device · IP · Last seen · Current` + `Revoke` (`DELETE /auth/sessions/{id}`). Joriy sessiya `Revoke` = logout (tasdiq bilan).

---

## 7.14 Super Admin — `/admin/companies` **[MAY]**
- **Ruxsat:** `super_admin` · `GET/POST /companies`, `PATCH /companies/{id}`, `PATCH /companies/{id}/subscription`
- **Filtrlar:** `search` · `status` (`trial|active|grace|readonly`) · `region`; saralash `name|created_at|subscription_end_at`
- **F152** Super Admin tenant tanlaganda barcha so'rovlarga `X-Company-Id` header'i qo'shiladi (WS handshake'da ham). UI'da doimiy banner: «Viewing as <Company>» + chiqish tugmasi.
- **F153** MVP'dan tashqarida (`tz.md` qaror 24 — billing qo'lda). Marshrut mavjud, lekin **9-bosqichda** (§18) quriladi.

---

# 8. Real-vaqt (WebSocket)

**Manba:** `backend/docs/websocket.md` (Swagger'da yo'q — bu yagona kontrakt).

## 8.1 Ulanish va auth **[MUST]**

- **URL:** `wss://eldapi.stackyard.uz/api/v1/ws`
- **F154 [MUST] Token URL'da — QAT'IY TAQIQ.** `?token=`, `?access_token=`, `?jwt=`, `?bearer=`, `?authorization=`, `?api_key=` — backend handshake'ni `401` bilan uzadi. Kredensial URL'da access-log, referer va proxy keshiga sizadi.
- **Brauzer cheklovi:** `WebSocket` API upgrade so'rovida qo'shimcha header yubora olmaydi → ✅ **ikkinchi usul ishlatiladi**: header'siz ulanish + **10 soniya ichida** birinchi freym:
```json
{"type":"auth","token":"<access_token>"}
```
- Muvaffaqiyatda server `{"type":"welcome","ts":"…"}` yuboradi. Undan **oldin hech qanday `subscribe` yuborilmaydi**.
- Super Admin rejimida `X-Company-Id` header'i kerak — brauzer WS'da buni bera olmaydi → **F155**: super-admin tenant rejimida real-vaqt **o'chiriladi** (polling'ga o'tadi) yoki backendga `auth` freymiga `company_id` maydonini qo'shish CR sifatida chiqadi (§17).

## 8.2 Kanallar **[MUST]**

| Kanal | Ruxsat | Nima uchun | Qaysi ekranda |
|---|---|---|---|
| `tracking` | `tracking.view_live` | `unit_last_state` | Dashboard xaritasi, `/tracking`, Track on Map |
| `notifications` | authenticated | `notification_created` | Global (header dropdown + toast) |
| `chat` | `chat.read` | `chat_message`, `chat_message_read` | `/chat` (global — o'qilmagan hisoblagich uchun) |
| `dashboard` | `dashboard.read` | `dashboard_summary` | `/` |

**F156** `notifications` — **global**, ilova ochilishi bilan obuna bo'linadi. `tracking`, `chat`, `dashboard` — **ekranga bog'liq**: komponent `mount` bo'lganda `subscribe`, `unmount` da `unsubscribe`.

## 8.3 Subscribe formati **[MUST]**

```json
{"type":"subscribe","channel":"tracking",
 "filter":{"unit_ids":["…"]},
 "since":"2026-09-06T17:55:00Z"}
```
- `filter.unit_ids` / `driver_ids` — **maksimum 500 id**. Ko'proq kerak bo'lsa filtrsiz obuna + klient tomonda filtrlash.
- `filter.company_id` **hech qachon yuborilmaydi** (yuborilsa o'z kompaniyasi bo'lishi shart, aks holda `FORBIDDEN`) — ortiqcha va xatarli.
- Javob: `{"type":"subscribed","channel":"…"}` — shundan keyingina ma'lumot keladi (deny-by-default).

## 8.4 `since` backfill **[MUST]**

**F157** Qayta ulanishda `since` = **oxirgi qayta ishlangan hodisaning `ts`** i (kanal bo'yicha alohida saqlanadi).
- Replay freymlari `"replay": true` bilan keladi → **toast chiqarilmaydi**, faqat kesh yangilanadi (dublikat bildirishnomaning oldini oladi).
- Maksimum **200 hodisa** har kanal uchun; `since` **24 soatdan** uzoq bo'lsa jimgina qisqartiriladi; kelajakdagi `since` → `TIME_IN_FUTURE`.
- **`since` — kafolat emas.** REST doimo haqiqat manbai: qayta ulanishdan keyin tegishli query'lar ham `invalidate` qilinadi.

## 8.5 Qayta ulanish strategiyasi **[MUST]**

`reconnecting-websocket` sozlamalari:
| Parametr | Qiymat |
|---|---|
| `minReconnectionDelay` | 1000 ms |
| `maxReconnectionDelay` | 30 000 ms |
| `reconnectionDelayGrowFactor` | 1.5 (eksponensial + ±20 % jitter) |
| `maxRetries` | `Infinity` |
| `connectionTimeout` | 10 000 ms |

**F158** Ulanish holati global (`Zustand`): `connecting | open | reconnecting | offline`. `reconnecting` 10 soniyadan uzoq davom etsa — header ostida ingichka sariq banner: «Live updates paused. Reconnecting…» + `Retry now`. Bu paytda ekranlar **60 s polling'ga** o'tadi.
**F159** Har muvaffaqiyatli ulanishdan keyin: `auth` → `welcome` kutish → barcha faol kanallarga `since` bilan `subscribe`.
**F160** Access token yangilanganda (F15) — WS **yopilmaydi**; server obunani sessiya bo'yicha ushlaydi. Faqat to'liq logoutda yopiladi (kod `1000`).
**F161** `document.visibilityState === 'hidden'` **5 daqiqadan** ortiq davom etsa — ulanish yopiladi (batareya/resurs); tab qaytganda `since` bilan qayta ulanadi.

## 8.6 Ping/pong va limitlar

| Sozlama | Qiymat |
|---|---|
| Server ping intervali | 30 s |
| O'qish deadline | 65 s |
| Auth deadline | upgrade'dan keyin 10 s |
| Maksimal kiruvchi freym | 32 KiB |
| Chiquvchi navbat | 256 xabar |

**F162** Brauzer protokol-darajadagi `pong`ni avtomatik yuboradi — qo'shimcha kod kerak emas. Lekin **60 s da bir marta** `{"type":"ping"}` amaliy keepalive yuboriladi (proxy timeout'lariga qarshi); `pong` kelmasa 10 s ichida — ulanish majburan qayta ochiladi.
**F163** Navbat to'lib ketishi mumkin (server xabarlarni tashlaydi) — shuning uchun **hech qanday holat faqat WS'ga tayanmaydi**: har WS hodisasi keshni yangilaydi, lekin ekranga kirishda doim REST so'rovi bo'ladi.

## 8.7 Xatolar

`{"type":"error","channel":"chat","code":"FORBIDDEN","message":"…"}` — freym darajasidagi xato **socketni yopmaydi**. UI: `FORBIDDEN`/`NOT_FOUND` → o'sha kanalga qayta obuna bo'lishga urinilmaydi, ekran REST'ga tayanadi, `console.warn`. `UNAUTHORIZED` → socket yopiladi → token yangilash → qayta ulanish.

---

# 9. Xarita

## 9.1 Texnologiya **[MUST]**

- **MapLibre GL JS v4** (`tz.md` B§6.2). React wrapper qo'lda yoziladi (`components/map/MapCanvas.tsx`) — `react-map-gl` qo'shimcha bog'liqlik sifatida qabul qilinmaydi (F3).
- **F164 ❓ Tile provayderi tasdiqlanmagan** (`tz.md` qaror 26, §23). Talablar: (a) style JSON `VITE_MAP_STYLE_URL` orqali, (b) kalit domen bo'yicha cheklangan, (c) kod hech bir provayderga **qattiq bog'lanmaydi** — `MapCanvas` faqat style URL qabul qiladi. Nomzodlar: MapTiler, Protomaps (self-host), OpenFreeMap.
- **F165** Xarita komponenti **lazy** yuklanadi (`React.lazy`) — MapLibre ~800 KB, asosiy bundle'ga kirmaydi.

## 9.2 Jonli kuzatuv **[MUST]**

- **Manba:** `GET /tracking/live` (dastlabki holat) + WS `tracking` → `unit_last_state`
- **Marker:** duty status bo'yicha ikonka va rang (`DR` — strelka `heading_deg` bo'yicha burilgan, `ON` — nuqta, `OFF` — pauza, `SB` — doira) + `online_status` bo'yicha halqa (online yashil, offline kulrang, disconnected qizil)
- **Marker kartochkasi** (dizayn 200×217): haydovchi nomi · holat · `Unit #` · `Odometer` · `Location` (tashqi havola ikonkasi) · nisbiy vaqt · `View Tracking ›`
- **F166** Pozitsiya yangilanishi **animatsiya bilan** (`easeTo` 500 ms) — sakrash bo'lmaydi. 60 s dan eski nuqta 50 % shaffof.
- **F167 [MUST] Klasterlash:** `unit_last_state` nuqtalari **GeoJSON source + `cluster: true`** (radius 50 px, `maxZoom 14`). 500+ unit'da ham xarita 60 fps ushlaydi. Klaster bosilganda zoom qilinadi; oxirgi darajada `spiderfy` o'rniga ro'yxat popup'i.
- **F168** Xarita `bounds` o'zgarganda `GET /tracking/live` **qayta chaqirilmaydi** (backend bbox filtrini bermaydi) — barcha unit'lar bir marta olinadi, ko'rinish klient tomonda filtrlanadi.

## 9.3 Trip polyline **[MUST]**

- **Manba:** `GET /units/{id}/trips?date=` → segmentlar; `GET /trips/{id}?include_polyline=true` → geometriya
- Chiziq: `primary` rangda, kenglik 4 px, `line-cap: round`; to'xtash nuqtalari raqamli markerlar (1,2,3…)
- Segment tanlanganda: qolganlari 30 % shaffof, xarita `fitBounds` qiladi (padding 64 px)
- **F169** Polyline `include_polyline=true` bilan **faqat kerak bo'lganda** so'raladi (ro'yxat uchun `false`) — javob hajmi katta.

## 9.4 Geofence va marshrut

- **F170** Route'ning `geofence_m` radiusi manzil nuqtasi atrofida **doira** (`circle` layer, fill 10 % `success`, stroke `success`) sifatida chiziladi. Default 300 m (`tz.md` Q66).
- `GET /routes/{id}/directions` — tavsiya etilgan yo'nalish, uzuq chiziq (`line-dasharray`), `neutral-400`.

## 9.5 Umumiy qoidalar

**F171** Xarita `<div role="application" aria-label="…">`; klaviatura bilan zoom/pan (MapLibre `keyboard` yoqilgan). Xarita **yagona** ma'lumot manbai bo'lmaydi — har xarita yonida jadval/ro'yxat ekvivalenti bor (a11y, §14.2).
**F172** Reverse-geocoding backendda (`tz.md` Q9, B§7.3) — frontend geocoding API'ga **to'g'ridan-to'g'ri so'rov yubormaydi. Backend matn bermasa — `lat, lng` ko'rsatiladi.

---

# 10. Fayllar

## 10.1 Yuklash oqimi **[MUST]**

```
1. POST /files/presign {kind, content_type, size_bytes, filename}   ← files.upload
     → {upload_url, method:"PUT", key, headers{}, max_bytes, expires_at}
2. PUT <upload_url>  (fetch, Content-Type va Content-Length AYNAN mos)
3. Domen endpointiga `key` yuboriladi (masalan DVIR repair invoice, chat xabari, company logo)
```

**F173 [MUST]** `size_bytes` — **haqiqiy fayl hajmi**; u URL'ga `Content-Length` sifatida imzolanadi, mos kelmasa storage `PUT` ni rad etadi. Fayl tanlangandan keyin (`File.size`) presign so'raladi, undan oldin emas.
**F174 [MUST]** Yuklash `XMLHttpRequest` bilan (progress event uchun; `fetch` upload progress bermaydi) — bu F13 ning ruxsat etilgan istisnosi.
**F175** `expires_at` o'tib ketsa (sekin tarmoq) — presign qayta so'raladi va yuklash qaytadan boshlanadi (maks. 2 urinish).

## 10.2 `kind` oq ro'yxati va cheklovlar **[MUST]**

| `kind` | Qayerda | MIME | Maks. hajm (`tz.md` §18.3) |
|---|---|---|---|
| `dvir_photo` | DVIR nuqson fotosi (ko'rish) | `image/jpeg`, `image/png` | 5 MB, ≤ 5 dona |
| `invoice` | Maintenance complete, DVIR repair | `application/pdf`, `image/jpeg`, `image/png` | 10 MB |
| `signature` | Imzo (faqat ko'rish, admin yaratmaydi) | `image/png` | 1 MB |
| `logo` | Settings › Company | `image/png`, `image/jpeg`, `image/svg+xml` | 2 MB |
| `chat` | Chat biriktirmasi | `image/*`, `application/pdf` | 10 MB |
| `import` | Units/Drivers import | `text/csv`, `.xlsx` | 10 MB |

**F176 [MUST]** `kind` — backend enum'i; boshqa qiymat yuborilmaydi. Klient tomonda MIME **va** kengaytma tekshiriladi; haqiqiy chegara `max_bytes` javobdan olinadi va UI'da ko'rsatiladi.
**F177 [MUST] SVG logotip** — `<img src>` sifatida ko'rsatiladi, **hech qachon inline** (`dangerouslySetInnerHTML`) qilinmaydi: SVG ichida skript bo'lishi mumkin (§13).
**F178** `FileUpload` komponenti: drag&drop zonasi, tanlangan fayl nomi + hajmi, progress bar (%), `Cancel` (`xhr.abort()`), xato holati (hajm/MIME/tarmoq) aniq matn bilan.

## 10.3 Yuklab olish

**F179** PDF va eksport fayllari `Authorization` header'i talab qiladi → oddiy `<a href>` ishlamaydi. Oqim: `fetch` → `blob` → `URL.createObjectURL` → dasturiy `<a download>` → `revokeObjectURL`. Yuklab olish davomida tugma `loading`. Katta fayllarda (≥ 20 MB) progress ko'rsatiladi.
**F180** `export_job.download_url` — **presigned**, `Authorization` talab qilmaydi → to'g'ridan-to'g'ri `<a href target="_blank" rel="noopener">`.

---

# 11. Hisobotlar va eksport

## 11.1 Ikki xil eksport **[MUST]**

| Tur | Endpoint | UI |
|---|---|---|
| **Sinxron** | `GET /units/export`, `GET /drivers/export`, `GET /daily-logs/{id}/pdf`, `GET /dvir-reports/{id}/pdf` | tugma → spinner → fayl yuklab olinadi (F179) |
| **Asinxron** | `POST /reports/export-jobs` | job oqimi (quyida) |

## 11.2 Asinxron oqim **[MUST]**

```
POST /reports/export-jobs {type, format, params}   ← reports.export, Idempotency-Key
   → 202 { id, status: "queued" }
   → toast: «Your export is being prepared. We'll notify you when it's ready.»
GET /reports/export-jobs/{id}   ← polling: 2s → 5s → 10s (maks. 5 daqiqa)
   ├─ running  → progress ko'rsatiladi
   ├─ done     → download_url (presigned, expires_at) + toast + bildirishnoma
   └─ failed   → error matni + «Try again»
```

**F181** Polling **5 daqiqadan** oshsa to'xtaydi va foydalanuvchiga `/reports/exports` sahifasi taklif qilinadi — job fonda davom etadi, tayyor bo'lganda **bildirishnoma** keladi (`notifications` kanali).
**F182** `download_url` **24 soat** amal qiladi (`tz.md` Q75). Ro'yxatda muddati o'tgan job'da `Download` o'rniga «Link expired — re-run export» tugmasi.
**F183** Ochiq (`queued`/`running`) job bor ekan — o'sha `type` + bir xil `params` bilan yangi so'rov yuborilmaydi; tugma `disabled` + «An export with these parameters is already running».
**F184** Eksport `audit_log` ga tushadi (`tz.md` §17: «kim nimani yuklab oldi») — UI foydalanuvchiga buni ogohlantirish sifatida ko'rsatadi (sezgir hisobotlarda).

## 11.3 Formatlar

| `type` | Ruxsat etilgan `format` | Default |
|---|---|---|
| `distance_by_region` | `csv`, `xlsx`, `pdf` | `xlsx` |
| `regulator` | `pdf`, `csv`, `zip` | `zip` (`generic`: PDF+CSV) |
| `activity` | `csv`, `xlsx`, `pdf` | `csv` |
| `hos` | `csv`, `pdf` | `pdf` |
| `dvir` | `csv`, `xlsx`, `pdf` | `pdf` |

**F185** Format tanlovi `POST` javobidagi xatolar bilan tekshiriladi; UI faqat yuqoridagi kombinatsiyalarni taklif qiladi. Dizaynda faqat IFTA'da CSV/PDF ko'rsatilgan edi (§16, aniqlanmagan nuqta 16 — hal qilindi).
**F186** `Print` tugmasi (Activity Report'da) — brauzer `window.print()` + `@media print` stillari (nav, filtrlar, tugmalar yashiriladi; jadval to'liq, sahifa sarlavhasi va sana oralig'i ko'rinadi).

---

# 12. i18n, sana/vaqt, birliklar

## 12.1 i18n **[MUST]**

**F187** `react-i18next`, `src/locales/en.json` — **birinchi kundan**. MVP faqat inglizcha (`tz.md` B§18), lekin **hech qanday matn kodda hardcode qilinmaydi**.
**Kalit tuzilishi:** `<modul>.<ekran>.<element>` — `units.list.title`, `units.form.unit_number.label`, `common.actions.save`, `errors.VALIDATION_ERROR`, `enums.duty_status.DR`, `enums.dvir_status.submitted_defects_found`.
**F188** Barcha backend `enum` qiymatlari uchun i18n kaliti bo'ladi (`enums.*`) — xom `snake_case` qiymat ekranga chiqmaydi.
**F189** Ko'plik — `i18next` `_one`/`_other`; o'zgaruvchilar `{{count}}`, `{{name}}` orqali. String konkatenatsiyasi **taqiqlanadi**.
**F190 [SHOULD]** Kelajakda RTL (Urdu) uchun: `dir` atributi `<html>` da, Tailwind `rtl:` variantlari, `ms-`/`me-` (logical) `ml-`/`mr-` o'rniga. MVP'da majburiy emas, lekin **yangi kodda logical property'lar ishlatiladi**.
**F191** `i18next-parser` bilan `npm run i18n:extract` — yo'qolgan kalitlarni topadi; CI'da yetishmayotgan kalit = xato.

## 12.2 Sana va vaqt **[MUST]**

**F192** Format `regulation_profile` ga bog'liq (`tz.md` §18.4) — dizayndagi **6 xil variant** shu ikkitaga qisqartiriladi (aniqlanmagan nuqta 15 — hal qilindi):

| Kontekst | `generic` | `fmcsa_us` |
|---|---|---|
| Sana | `DD/MM/YYYY` (`17/12/2025`) | `MM/DD/YYYY` (`12/17/2025`) |
| Sana + hafta kuni | `Fri, 17/12/2025` | `Fri, 12/17/2025` |
| Vaqt | 24 soat (`14:05`) | 12 soat (`02:05 PM`) |
| Sana + vaqt | `17/12/2025 14:05` | `12/17/2025 02:05 PM` |
| Davomiylik | `HH:MM` yoki `HH:MM:SS` | bir xil |
| Nisbiy | `2 hours ago` (< 24 soat) | bir xil |

**F193 [MUST] Timezone.** Backend hamma narsani **ISO 8601 UTC** da beradi. Ko'rsatish — **Company Home Terminal timezone** ida (`GET /me` → `company.timezone`), **brauzer TZ da emas**. Sabab: log kuni chegarasi Home Terminal TZ bo'yicha (`tz.md` Q10.2) — boshqa TZ da ko'rsatish auditni buzadi.
**F194** Har sana/vaqt yonida (jadval hujayrasi tooltip'ida) TZ qisqartmasi ko'rsatiladi (`14:05 CST`). Foydalanuvchi brauzer TZ si kompaniyanikidan farq qilsa — sahifada bir marta izoh: «Times are shown in the company time zone (America/Chicago)».
**F195** `lib/format.ts` da yagona funksiyalar: `formatDate`, `formatTime`, `formatDateTime`, `formatDuration`, `formatRelative`. Komponentlarda `date-fns` bevosita chaqirilmaydi (ESLint bilan cheklanadi).

## 12.3 Birliklar **[MUST]**

**F196 [MUST]** Backend **SI da qaytaradi**: masofa — **metr** (`odometer_m`, `distance_m`), tezlik — **km/h** (`speed_kmh`), engine hours — soat (`number`). `websocket.md`: «the backend performs no unit conversion». **Barcha konvertatsiya frontendda.**

| Qiymat | `metric` | `imperial` | Formula |
|---|---|---|---|
| Masofa | km | mi | `m / 1000` · `m / 1609.344` |
| Tezlik | km/h | mph | `kmh` · `kmh / 1.609344` |
| Harorat | °C | °F | `c` · `c * 9/5 + 32` |
| Hajm (yoqilg'i) | L | gal | `l` · `l / 3.785411784` |
| Og'irlik | kg | lb | `kg` · `kg * 2.20462262` |

**F197** `lib/units.ts`: `formatDistance(m)`, `formatSpeed(kmh)`, `formatVolume(l)`, `formatTemperature(c)` — hammasi `useUnitSystem()` orqali `company.unit_system` ni o'qiydi. Aylantirish natijasi **yaxlitlanadi**: masofa 1 xona, tezlik 0 xona, harorat 0 xona.
**F198 [MUST] Kiritishda teskari konvertatsiya:** foydalanuvchi `imperial` da `2000 miles` kiritsa — API'ga **metrda** yuboriladi. Bu ayniqsa Maintenance formasida muhim (`Maintenance Frequency`, `Set Reminder`, `Last service value`). Konvertatsiya `parseDistance(value, unitSystem)` orqali, bitta joyda.
**F199** Birlik yorlig'i (`Miles`/`Km`) input yonida **doim ko'rinadi** — foydalanuvchi qaysi birlikda kiritayotganini bilishi shart.
**F200** `tz.md` Q0.1: dizayndagi `mph`/`miles`/`°F` — faqat `imperial` rejimda. Dizayn AQSh birliklarida chizilgan, lekin **default `metric`** (`tz.md` §1.4).

---

# 13. Xavfsizlik

**F201 [MUST] XSS.** `dangerouslySetInnerHTML` **taqiqlanadi** (ESLint `react/no-danger` error). Markdown/HTML render qilish kerak bo'lsa — `DOMPurify` bilan tozalab, alohida ko'rib chiqilgan komponentda. Foydalanuvchi kiritgan matn (chat, notes, ticket, feedback, audit `changes`) — faqat matn tugunlari sifatida.
**F202 [MUST] URL injection.** Foydalanuvchi ma'lumotidan olingan havolalar (`Location` tashqi havolasi, `download_url`) `https?:` sxemasi bo'yicha tekshiriladi; `javascript:`/`data:` bloklanadi. Tashqi havolalar `rel="noopener noreferrer" target="_blank"`.
**F203 [MUST] CSP** (`eldadmin.stackyard.uz` da HTTP header sifatida; `<meta>` — zaxira):
```
default-src 'self';
script-src 'self';
style-src 'self' 'unsafe-inline';           /* Tailwind runtime style'lari uchun */
img-src 'self' data: blob: https://<tile-host>;
font-src 'self';
connect-src 'self' https://eldapi.stackyard.uz wss://eldapi.stackyard.uz https://<tile-host> https://<storage-host>;
worker-src 'self' blob:;                     /* MapLibre worker */
frame-ancestors 'none'; base-uri 'self'; form-action 'self'; object-src 'none';
upgrade-insecure-requests
```
Qo'shimcha header'lar: `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy: geolocation=(), camera=(), microphone=()`, `Strict-Transport-Security`.
**F204 [MUST] `script-src 'unsafe-inline'` va `'unsafe-eval'` — yo'q.** Vite prod build'i inline skript yaratmaydi (`build.modulePreload` va `html` inline skriptlarini o'chirish).
**F205 [MUST] Token saqlash** — §3.3 F14. `localStorage` da **hech qachon** token yo'q. Xotira token'i sahifa yangilanishida yo'qoladi va refresh orqali tiklanadi.
**F206 [MUST] Sezgir ma'lumot:**
- Haydovchi guvohnoma raqami — `license_no_masked`; ochish alohida ruxsat + alohida so'rov + audit (F87).
- Parol maydonlari `type="password"`, `autocomplete="new-password"`, forma `autocomplete="off"`.
- **Dizayndagi «Edit formasida parol ochiq ko'rinadi (`1234john5678`)» — bu jiddiy xato, olib tashlanadi** (§16).
- Xato xabarlari va `console` ga token, parol, guvohnoma raqami **yozilmaydi**. Prod build'da `console.log` `esbuild.drop` bilan olib tashlanadi (`console.error` qoladi).
**F207 [MUST] Audit-muhim amallar tasdiqlanadi** (F67): Delete, Deactivate, Role o'zgarishi, HOS policy publish, Log edit request, Unassigned assign, DVIR certify, Ticket status, License reveal, Session revoke, Export.
**F208** Clipboard: koordinata/VIN nusxalash — foydalanuvchi bosishi bilan; avtomatik clipboard yozish yo'q.
**F209 [SHOULD]** Bo'sh turish: **30 daqiqa** faoliyatsizlikdan keyin ogohlantirish modali (60 s countdown) → javob bo'lmasa logout. Har API so'rovi va foydalanuvchi harakati taymerni tiklaydi.
**F210 [MUST]** `npm audit` va `npm outdated` CI'da; `high`/`critical` zaiflik — build yiqiladi. Bog'liqliklar `package-lock.json` bilan pin qilinadi.
**F211** Sourcemap prod'da **yuklanmaydi** (yoki faqat Sentry'ga yuboriladi va serverdan o'chiriladi).

---

# 14. Sifat

## 14.1 Testlar **[MUST]**

| Daraja | Vosita | Qamrov |
|---|---|---|
| Unit | Vitest | `lib/*` (format, units, errors, permissions, hos) — **100 % branch** |
| Komponent | Vitest + Testing Library | `components/ui/*` — har biri; `components/data/DataTable` |
| Integratsiya | Vitest + **MSW** (`swagger.json` dan mock) | har modul uchun asosiy ekran: yuklanish → ro'yxat → filtr → forma → xato |
| E2E | Playwright | §14.4 dagi 8 oqim |

**F212 [MUST] Qamrov chegarasi:** `lib/` 100 %, `components/ui/` ≥ 90 %, umumiy ≥ **70 %** (statements). CI'da tekshiriladi.
**F213 [MUST]** MSW handler'lari `openapi/swagger.json` dan generatsiya qilinadi (`msw-auto-mock` yoki qo'lda, lekin **tiplari `schema.d.ts` dan**) — mock va real API bir xil shaklda bo'ladi.
**F214 [MUST] Permission testlari:** har modul uchun «ruxsat yo'q» ssenariysi — tugma yo'q, marshrut 403, satr amali yo'q. Bu `usePermission` regressiyasidan himoya qiladi.
**F215** Konvertatsiya testlari **majburiy**: `metric ↔ imperial` va `generic ↔ fmcsa_us` — chegaraviy qiymatlar bilan (0, manfiy, juda katta odometer).

## 14.2 A11y **[MUST]**

**F216** Klaviatura: har interaktiv element `Tab` bilan yetiladi, fokus **ko'rinadigan** halqa bilan (`focus-visible`, 2 px `primary`). Modal — fokus tuzoq. Jadval satri bosiladigan bo'lsa — `role="button"` + `Enter/Space`.
**F217** Kontrast **WCAG 2.1 AA**: matn ≥ 4.5:1, katta matn va UI elementlari ≥ 3:1. Tekshirilishi kerak bo'lgan joylar: `neutral-400` matn oq fonda (**yetarli emas** — faqat ikkilamchi, katta o'lchamda), `warning-base #F6BA47` oq fonda (**yetarli emas** — matn uchun `warning-dark #7B5D24` ishlatiladi), badge fon/matn juftliklari.
**F218 [MUST]** Ma'no **faqat rang bilan berilmaydi**: duty status chip'ida rang + **matn kodi** (`DR`), violation satrida rang + ikonka + `Violation:` prefiksi, KPI chizig'ida rang + qiymat.
**F219** ARIA: `aria-label` har `IconButton` da, `aria-live="polite"` toast va yuklanish holatida, `aria-sort` saralanadigan sarlavhalarda, `aria-invalid` + `aria-describedby` xato bo'lgan maydonlarda, `aria-busy` yuklanayotgan bloklarda.
**F220** Sahifa tuzilishi: bitta `h1`, mantiqiy `h2/h3`, `<main>`, `<nav>`, `Skip to content` havolasi.
**F221** `prefers-reduced-motion` hurmat qilinadi (animatsiyalar o'chiriladi, xarita `easeTo` → `jumpTo`).
**F222 [MUST]** CI'da `axe-core` (Playwright bilan) — asosiy 10 ekranda **kritik xato 0**.

## 14.3 Performans **[SHOULD]**

| Ko'rsatkich | Maqsad |
|---|---|
| Lighthouse Performance (desktop, `/`) | ≥ 90 |
| Lighthouse Accessibility | ≥ 95 |
| Lighthouse Best Practices | ≥ 95 |
| LCP | ≤ 2.0 s |
| CLS | ≤ 0.05 |
| INP | ≤ 200 ms |
| **Boshlang'ich JS** (gzip, xaritasiz) | ≤ **250 KB** |
| Route chunk (o'rtacha) | ≤ 80 KB |
| Xarita chunk (lazy) | ≤ 400 KB |

**F223 [MUST]** Har route — `React.lazy` + `Suspense`. MapLibre, PDF ko'ruvchi, `recharts` — alohida chunk.
**F224** `rollup-plugin-visualizer` bilan bundle hisoboti CI artefakti sifatida; chegara oshsa ogohlantirish.
**F225** 50 satrli jadval virtualizatsiyasiz ishlaydi (`per_page ≤ 50`). Virtualizatsiya faqat chat va audit oqimida (`@tanstack/react-virtual`) **[MAY]**.

## 14.4 E2E oqimlari (Playwright) **[MUST]**

1. Login → dashboard → logout
2. Unit yaratish → tahrirlash → deaktivatsiya → o'chirish (tasdiq dialoglari bilan)
3. Driver yaratish → invitation → license reveal (ruxsat bilan va ruxsatsiz)
4. Logs By Driver → Log view → **log edit request yuborish** (haydovchi tasdig'i kutilishi tekshiriladi)
5. Tracking → Track on Map → trip tanlash
6. Maintenance: schedule yaratish → due → mark as complete (invoice yuklash bilan)
7. Report: Distance by Region → export job → download
8. Permission: cheklangan rol bilan kirish → yashirilgan menyular va 403/404 ekranlari

**F226** E2E **MSW yoki test-backend** ga qarshi ishlaydi, prod ma'lumotiga tegmaydi.

---

# 15. Nofunksional talablar (NFR)

`tz.md` B§21 dan admin panelga tegishli qismi:

| Ko'rsatkich | Talab |
|---|---|
| Sahifa birinchi yuklanishi (LCP, desktop, 10 Mbit) | ≤ **2 s** |
| Ekranlar orasida o'tish (lazy chunk + so'rov) | ≤ 1 s |
| API p95 (backend tomonidan) | ≤ 300 ms ro'yxatlar, ≤ 800 ms hisobot so'rovi |
| WS joylashuv kechikishi (qurilma → xarita) | ≤ **5 s** onlayn holatda |
| Xarita 500 unit bilan | ≥ 30 fps pan/zoom |
| Brauzerlar | **so'nggi 2 versiya**: Chrome, Edge, Safari, Firefox |
| Minimal ekran kengligi | **1280 px** (F77) |
| Availability | 99.5 % (MVP) |
| Xavfsizlik | OWASP ASVS L2 (frontend qismi: §13) |

**F227** Brauzer qo'llab-quvvatlash `browserslist`: `last 2 Chrome versions, last 2 Edge versions, last 2 Firefox versions, last 2 Safari versions`. IE va eski Safari — yo'q. Qo'llab-quvvatlanmaydigan brauzerda banner.
**F228** Ilova **offline ishlamaydi** (admin panel — onlayn vosita). Tarmoq yo'qolganda: banner + keshdagi ma'lumot faqat ko'rish uchun, barcha yozuv amallari `disabled`.

---

# 16. Nomuvofiqliklar reestri

Dizayn inventarida **31 ta nomlash nomuvofiqligi** (B.1 + B.2), **16 ta imlo xatosi** (C) va **4 turdagi begona kontent** (B.3) qayd etilgan. Quyida har biri uchun **kanonik qaror**, **sabab** va **manba**. Qaror manbalari ustuvorligi: `backend` > `tz.md §1.3` > `tz.md` (boshqa) > `frontend qarori`.

## 16.1 Navigatsiya va ekran nomlari (B.1 — 10 ta)

| № | Dizayndagi variant | ✅ Kanonik qaror | Sabab | Manba |
|---|---|---|---|---|
| N1 | `Fleet Operations` / `Fleet Management` | **Fleet Management** | Kanonik nomlar jadvalida qat'iy belgilangan; «Operations» kengroq va noaniq | `tz.md` §1.3 |
| N2 | `Reports` / `Report` | **Reports** | Modul ko'plikda (4 hisobot turi) | `tz.md` §1.3 |
| N3 | `Support & History` / `Histories` | **Support & History** (ichida `Histories` punkti) | Ikkalasi ham kerak: modul nomi va ichki ekran nomi | `tz.md` §1.3 |
| N4 | `Inspection Report` / `DOT Report` | **Inspection Report** | `DOT` — AQSh domeni; `regulation_profile=generic` da ma'nosiz. Web'da faqat tarix ekrani (§7.12) | `tz.md` §1.3, Q0.2 |
| N5 | `Unit Diagnostics` / `Unit Inspection` | **Unit Diagnostics** | Blok ELD telemetriyasini ko'rsatadi, tekshiruv (inspection) emas — DVIR bilan chalkashadi | `tz.md` §1.3 |
| N6 | `Leave the Truck` / `Leave Truck` | **Leave Truck** | Mobil/planshet; web'ga taalluqli emas, terminologiya birligi uchun qayd | `tz.md` §1.3 |
| N7 | `In Progress` / `In-Progress` | **In Progress** (backend qiymati `in_progress`) | Backend enum'i `in_progress`; ko'rsatiladigan matn probel bilan | backend + `tz.md` §1.3 |
| N8 | `Yes, Driving` / `Yes, driving` | **Yes, driving** | Mobil; sentence-case umumiy qoidasi | `tz.md` §1.3 |
| N9 | `Dropoff`/`Checkout` vs `Drop off`/`Check out` | **Drop-off**, **Check-out** | Quick notes katalogi Company darajasida sozlanadi; default ro'yxat shu yozuvda | `tz.md` §1.3 |
| N10 | `Notify co-driver` / `Notify Co-driver` | **Notify co-driver** | Sentence-case; Maintenance formasi va View'da bir xil | `tz.md` §1.3 |

## 16.2 Ustun / maydon nomuvofiqliklari (B.2 — 21 ta)

| № | Muammo | ✅ Kanonik qaror | Sabab | Manba |
|---|---|---|---|---|
| N11 | `Maintenance › Due`: bo'shda `Remind`/`Due Date`, to'lada `Remaining Frequency`/`Reminder Sent` | **`Remaining Frequency` + `Reminder Sent`** ikkala holatda | Ustunlar to'plami ma'lumot borligiga qarab **hech qachon** o'zgarmaydi; bo'sh holatda ham sarlavha ko'rinadi | frontend (F109) |
| N12 | Contact Support: `Ticket ID`/`Message` vs `Ticket #`/`Subject` | **`Ticket #`, `Subject`** | Kanonik nomlar jadvali; backendda `subject` maydoni bor | `tz.md` §1.3 + backend |
| N13 | Unit jadvali: `Make & Model`/`ELD` vs `Manufacturer - Model`/`Device ID` | **`Make & Model`, `ELD`** | Backend maydonlari `make`, `model`, `eld_device_serial`; qisqaroq va ro'yxatga sig'adi | backend (F82) |
| N14 | ELD id formati `PT30_A9A1` vs `AP-AM4-0001172` | **Vendor serial raqami, format majburlanmaydi** | Har vendor o'z formatini beradi; UI validatsiya qilmaydi, faqat ko'rsatadi | `tz.md` §1.3, §10 |
| N15 | Activity Report oxirgi ustun `Odometer Change` (ikki marta) | **`End Odometer`** oxirgi ustun, `Odometer Change` alohida | `Odometer Change = End − Start`; ikkalasi ham kerak | `tz.md` §1.3, Q75 |
| N16 | User Management: `Role` ustunida ism; `Export Drivers` tugmasi | **Rol nomi**; tugma `Export Users` — lekin backendda endpoint yo'q → **MVP'da olib tashlanadi** | Placeholder xatosi; eksport endpointi mavjud emas (§17-Q7) | backend + `tz.md` §1.3 |
| N17 | `Histories` sahifasida `Add User` tugmasi | **Tugma olib tashlanadi** | Audit jurnaliga yozuv qo'shib bo'lmaydi (`audit_log` append-only, tashqi yozuvsiz) | `tz.md` §1.3, §17 |
| N18 | `Profile / Setting` birinchi ekrani FMCSA jadvalini ko'rsatadi | **Dizayn xatosi — e'tiborga olinmaydi** | Noto'g'ri komponent nusxalangan; Settings tabi §7.13 bo'yicha quriladi | frontend |
| N19 | Log jami formati `OFF 03:06` vs `Off - 00:00` | **`OFF 03:06`** (uppercase kod + probel + `HH:MM`) | Status kodlari hamma joyda uppercase (`OFF/SB/DR/ON`) | `tz.md` §1.3 |
| N20 | Bo'sh qiymat `na` vs `N/A` | **`N/A`** | Standart qisqartma; i18n kaliti `common.na` | `tz.md` §1.3 |
| N21 | Hafta kuni `Tues`, `Thurs` (4 harf) vs 3 harf | **3 harf** (`Mon Tue Wed Thu Fri Sat Sun`) | `Intl.DateTimeFormat({weekday:'short'})` avtomatik beradi | `tz.md` §1.3 (F140) |
| N22 | Truck defects: `Engine` ikki marta, `Refresh` nuqson emas | **Dublikat va `Refresh` olib tashlanadi** | Nuqson katalogi `defect_types` jadvalidan boshqariladi (§7.6.1) | `tz.md` Q27.1 |
| N23 | Quick notes: 10 bandli vs 8 bandli ikki to'plam | **Bitta ro'yxat, Company darajasida sozlanadi** | Default: PTI, Hook, Pickup, Drop-off, Delivery, Inspection, Check-in, Fueling, Check-out, Break, Other | `tz.md` §1.3 |
| N24 | Sertifikatsiya oynasi `Last 8 days` vs `Last 11 days` | **8 kun** (`certification_window_days = 8`) | Global konstanta; 8 kundan eskisi «Uncertified logs» hisobotida | `tz.md` Q19 |
| N25 | Log jadvali oxirgi ustuni: planshetda `Edit`, mobilda `Action` | **`Action`** (web admin uchun) | Ustun bitta amal emas, menyu (`···`) ni ochadi | frontend |
| N26 | Sana tasmasi: mobilda `Fri 07`, planshetda `07 Jan` | **Web'ga taalluqli emas**; web'da to'liq sana navigatori `‹ 17/12/2025 ›` | Web'da joy yetarli, qisqartma kerak emas | frontend (§12.2) |
| N27 | Bildirishnoma vaqti: nisbiy (`2hrs`) vs absolyut (`28 May, 10:04 am`) | **< 24 soat — nisbiy, keyin absolyut** | Yaqin hodisa uchun nisbiy tushunarli, eskisi uchun aniq sana kerak | frontend (F144) |
| N28 | ELD output file matni: «to the DOT officer» vs «to the Insection officer» | **«to the inspection officer»** (`generic`), «to the DOT officer» (`fmcsa_us`) | Imlo xatosi + domen bog'liqligi | `tz.md` Q0.2, C5 |
| N29 | Sana/vaqt formati — **6 xil variant** | **2 ta format**, `regulation_profile` ga bog'liq (§12.2 jadvali) | Yagona manba: `Intl` + company profili | `tz.md` §18.4 |
| N30 | DVIR holat to'plami: mobil 3 tur vs admin 7 holat | **Backend 6 holati kanonik** (§7.5, F106); mobil 3 turi — derived ko'rinish | Backend enum'i haqiqat; `Not Started`/`In Progress`/`Submitted` — UI derived yoki olib tashlangan | backend + `tz.md` Q30.2 |
| N31 | Dark/Light Figma tugun nomlari (`Edit Documents` → `edit doc`) | **E'tiborga olinmaydi** (Figma ichki nomlanishi) | Tugun nomi mahsulot matni emas; admin panelda dark tema yo'q (F53) | frontend |

## 16.3 Imlo xatolari (C — 16 ta)

Barchasi **to'g'rilangan holda** yoziladi; hech biri kodga yoki i18n fayliga xato holida tushmaydi.

| № | Dizaynda | ✅ To'g'risi | Qayerda |
|---|---|---|---|
| C1 | `Maintainance` | **Maintenance** | seksiya nomi, `MAINTAINANCE DETAILS` bloki, nav element |
| C2 | `Invocie` | **Invoice** | mobil upload formasi (web: Maintenance complete modali) |
| C3 | `Grese` | **Grease** | maintenance turi katalogi |
| C4 | `0verdue` (nol) | **Overdue** | maintenance `remaining < 0` holati |
| C5 | `Insection` | **Inspection** | Inspection Report matnlari |
| C6 | `Drivers Mangement` | **Driver Management** | ekran nomi (kanonik birlikda: `Driver Management`) |
| C7 | `Selecetd` | **Selected** | planshet ekran nomi |
| C8 | `easr avon` | **East Avon** | log detali namunasi (test ma'lumoti) |
| C9 | `GET BTY` | **GET BY** | Distance by Region / IFTA Generate formasi |
| C10 | `Last Address *` | **Last Name** | Settings › Profile (F150) |
| C11 | `cManagement - Inactive` | **Driver Management — Inactive** | ekran nomi |
| C12 | `automaticlly` | **automatically** | mobil komponent nomi |
| C13 | `5 mint idle` | **5 min idle** | planshet ekran nomi |
| C14 | `23,97464553778` | **23.9746455** | koordinata: nuqta o'nlik ajratgich, 7 xona (F101) |
| C15 | `XT` shtat kodi | **Ro'yxatdan chiqariladi** | AQSh shtat kodi emas; regionlar backenddan (`distance_regions`) — F124 |
| C16 | Warning `#F9B385` yozilgan, RGB `246,176,71` | **`#F6BA47`** | RGB to'g'ri, hex yozuvi xato; `tz.md` §1.2 ham `#F6BA47` (F41) |

## 16.4 Begona kontent (B.3 — 4 tur) **[MUST olib tashlanadi]**

| Nima | Qayerda | ✅ O'rniga nima |
|---|---|---|
| **Rolli ruxsatlar — go'zallik saloni domeni** (`Salons`, `Clients`, `Employees`, `View salons reservation graph`, `View male & female Salons piechart` …) | Add/Edit Role ekrani (`330:45466`, `331:46454`) | **`GET /permissions` dan 105 ta haqiqiy kalit**, 26 modul guruhiga bo'lingan (§7.3.10, F90). Dizayndan faqat tuzilma olinadi: `Role Name *` + guruhlangan checkbox ro'yxati |
| **Privacy Policy / Terms of Use — «Jusoor», «ONTime Log», «OnTime ELD»** (Saudiya biznes platformasi matni) | mobil `2627:25778`, planshet `2568:25226` | ❓ Buyurtmachidan **haqiqiy huquqiy matn** (`tz.md` qaror 28). Web admin'da bu ekranlar yo'q; footer'da havolalar bo'ladi — matn kelmaguncha havolalar **ko'rsatilmaydi** |
| **Chat demo xabarlari — dizayn jarayoni haqida** («Did you finish the Hi-FI wireframes for flora app design?») | admin `283:15887`, mobil `1118:114` | **Haqiqiy ssenariy**: dispetcher ↔ haydovchi yozishmasi. Demo/seed ma'lumot sifatida: yuk topshirish, dok raqami, kechikish, tanaffus (F131) |
| **Muqova sarlavhasi — «Seamless Healthcare Access Mobile App Design»** | `2142:16231` | **ONEBOOK ELD** — mahsulot nomi. Prezentatsiya artefakti, mahsulotga ta'sir qilmaydi |

**Placeholder qolgan joylar** (barchasi haqiqiy matn bilan almashtiriladi):
| Joy | ✅ Nima yoziladi |
|---|---|
| Logs flyout tavsiflari (`lorem ipsum`) | «View logs by unit for a single day» · «View logs by driver over a date range» · «Review and approve driver log edit requests» · «Assign unidentified driving to drivers» · «HOS warnings and violations» |
| Reports flyout tavsiflari | «Driving time and odometer by driver or unit» · «Distance travelled per region» · «Regulator export for roadside inspections» · «DVIR history and export» · «Logs that are still uncertified» · «Your export downloads» |
| Support & History flyout tavsiflari | «Full audit trail of every change» · «Driver support tickets» · «App ratings and comments from drivers» |
| Unit / Driver Activities jadvallari (`Lorem ipsum`) | `audit_log` yozuvlari: `<FIELD> changed from <eski> to <yangi>`, `Driver assigned`, `Deactivated`, … |
| Settings › Password tabi (`Lorem ipsum`, `Address`) | To'g'ri placeholder'lar: «Enter your current password», «At least 10 characters with a letter and a number» |

## 16.5 Qo'shimcha qarorlar (dizayn ↔ TZ/backend to'qnashuvi)

| № | Dizaynda | ✅ Qaror | Sabab | Manba |
|---|---|---|---|---|
| D1 | Header'da tema almashtirgich (quyosh) | **Olib tashlanadi**, MVP faqat light | Admin panelda birorta dark ekran chizilmagan (130 tugundan 0 tasi); toggle ishlamas bo'lardi. Texnik tayyorgarlik (CSS o'zgaruvchilar) saqlanadi | F53 |
| D2 | Driver formasida `Password *` maydoni; Edit'da parol **ochiq matnda** (`1234john5678`) | **Maydon olib tashlanadi**; parol faqat invitation / reset link orqali | Parolni admin bilishi audit va xavfsizlik buzilishi; ochiq ko'rsatish — jiddiy nuqson | `tz.md` qaror 21, F86, F206 |
| D3 | Driver formasida `Co-Driver *` majburiy | **Ixtiyoriy**, formadan View ichidagi blokka ko'chadi | Ko'p kompaniyada co-driver umuman yo'q | `tz.md` qaror 22 |
| D4 | `Insert duty status` → `Confirm` (to'g'ridan-to'g'ri tahrir) | **`Send edit request`** — taklif → haydovchi tasdig'i | FMCSA §395.30: admin logni bevosita o'zgartira olmaydi. Eng katta dizayn↔TZ farqi | `tz.md` §5.3, F100 |
| D5 | DVIR `Generate Report`: `Paste driver signature here`, `Paste mechanic signature here` | **Forma olib tashlanadi**; faqat filtr + eksport | Admin joylashtirgan imzo — auditda haqiqiy imzo emas | `tz.md` Q26, Q31, F107 |
| D6 | Admin `Change Password` modali (haydovchi uchun yangi parol kiritish) | **`Send password reset`** (`POST /drivers/{id}/reset-password`) | D2 bilan bir xil sabab | `tz.md` qaror 21 |
| D7 | Dashboard: 4 KPI karta (`Total Drivers`, `Total Units`, `Disconnected ELD`, `Violations`) | **9 karta**, nomlari `Active Drivers` / `Active Units` | Backend `kpi` obyektida 9 maydon; TZ §20 oltita karta talab qiladi | backend + `tz.md` §20, F80 |
| D8 | `Disconnected ELD` kartasi ostidagi chiziq **yashil** | **Neutral; qiymat > 0 bo'lsa qizil** | Uzilgan qurilma — muammo, yashil noto'g'ri signal | frontend, F81 |
| D9 | Dashboard `Ongoing` marshrut — **qizil** fon | **Sariq (warning)** | Davom etayotgan marshrut xato emas; qizil `not_completed` uchun | frontend, F43 |
| D10 | `Last Known Location` = `48.8566, 2.3522, 30` (uchinchi son noma'lum) | **`<manzil matni> · lat, lng`**; uchinchi son (GPS aniqligi) ko'rsatilmaydi | Backend aniqlik maydonini bermaydi; manzil matni foydaliroq | backend, F95 |
| D11 | `IFTA Report`, `FMCSA Report`, `US DOT` labellari | **`regulation_profile` ga bog'liq**: `generic` → `Distance by Region`, `Regulator Export`, `Registration No` | Bozor Pokiston/O'zbekiston; AQSh domeni faqat `fmcsa_us` da | `tz.md` Q0.2, F122/F125 |
| D12 | «Reports will be ready by the fifth day of each month» | **Olib tashlanadi** — hisobot darhol tayyor | Kunlik agregat jadvali (`unit_region_distance_daily`) | `tz.md` §14, F123 |
| D13 | Maintenance invoice — «faqat PDF» | **PDF / JPG / PNG ≤ 10 MB** | TZ cheklovlari | `tz.md` §18.3, F111 |
| D14 | Maintenance `Alert Type`, `Delivery Method` ro'yxatlari berilmagan | `maintenance_upcoming` / `maintenance_overdue`; `push · email · sms · in_app` | Backend `alert_type` enum'i va TZ Q89 | backend, F110 |
| D15 | Bo'sh holat va «filtr natijasi bo'sh» bir xil | **Ajratiladi** (ikki xil matn + `Clear filters`) | Foydalanuvchi filtr sababli bo'shligini bilishi kerak | frontend, F69 |
| D16 | Yuklanish holati **hech qayerda ko'rsatilmagan** | Skeleton / overlay / spinner tizimi (§6.6) | Dizayn bo'shlig'i; 500 ms kechikish bilan miltillash oldini olish | frontend, F70 |
| D17 | Umumiy xato ekrani yo'q | 3 darajali xato tizimi (§6.7) | Dizayn bo'shlig'i | frontend, F72 |
| D18 | Ustun tanlash faqat Unit va Driver'da | **Barcha ro'yxatlarda** | Bir xil pattern; `localStorage` da saqlanadi | frontend, §6.1 |
| D19 | Company history: 3 mustaqil qidiruv (`Driver`, `Dispatcher`, `Unit`) | **`user` + `table` filtrlari** | Backend `audit-log` filtrlari shunday; `Dispatcher` faqat shu ekranda uchraydi | backend, F149 |
| D20 | Settings › Password: eski parol so'ralmaydi | **`Current password *` qo'shiladi** | O'g'irlangan sessiyada parol almashtirishning oldini oladi | frontend, F151 |
| D21 | Route `Run Trip` tugmasi | **`Create route`** | Amal marshrut yaratadi (`POST /routes`), «yugurtirmaydi» | backend, §7.4.3(d) |
| D22 | «Violations can be removed after completion of second qualify break» | «A `break_required` violation is resolved after a qualifying break; drive and shift violations after a daily rest.» | Violation **o'chmaydi**, `resolved_at` bilan yopiladi | `tz.md` Q58, F96 |
| D23 | Tasdiq matni «inactive the unit» | «**deactivate** the unit» | Grammatika | frontend, F66 |
| D24 | Logs ekranlarida `Export Drivers` / `Import Drivers` tugmalari | **Olib tashlanadi**; o'rniga `Export` (`export-jobs`) | Log ekranida haydovchi import qilish ma'nosiz — nusxalash xatosi | frontend, F96 |
| D25 | `Log By Driver` sarlavhasi | **`Logs By Driver`** | `Logs By Unit` bilan parallel | frontend, F97 |

---

# 17. Ochiq savollar

## 17.1 Dizayn inventarining 16 «aniqlanmagan nuqtasi» — holati

| № | Savol | Holat | Javob / manba |
|---|---|---|---|
| 1 | HOS formulalari; `65:00` yoki `70:00` | ✅ **Hal qilingan** | `hos_policy.cycle_limit_min` default **4200 (70:00)**; `65:00` — dizayn placeholderi. UI raqamni hardcode qilmaydi (`tz.md` §4.2, F98) |
| 2 | `Recap` qanday hisoblanadi | ✅ | `recap[d] = cycle_limit − Σ(ON+DR, oxirgi cycle_days)`; backend `hos-summary.recap[]` beradi (`tz.md` Q10.7) |
| 3 | Sertifikatsiya oynasi 8 yoki 11 kun | ✅ | **8 kun** (`tz.md` Q19) |
| 4 | `Not Ready` sharti | ✅ | **Faqat imzo yo'q**; trailer/doc bo'sh — Warning (`tz.md` Q25) |
| 5 | Harakat chegarasi va manbasi | ✅ | ECM ≥ `motion_threshold_kmh` (default **8 km/h**); ECM yo'q bo'lsa GPS fallback (`tz.md` Q5) |
| 6 | Harakatsizlik so'roviga `No` / javobsizlik | ✅ | `No` yoki 1 daqiqa javobsizlik → `ON` (`tz.md` Q6) |
| 7 | Joylashuv aniqligi chegarasi | ✅ | **> 150 m** → «location might be inaccurate» (`tz.md` Q9) |
| 8 | Warning qachon Violation'ga aylanadi | ✅ | `tz.md` Q57 jadvali + `hos_policy.warning_thresholds` |
| 9 | DVIR holat o'tishlari; `Certified` kimga tegishli | ✅ | Holat mashinasi `tz.md` §7.2; `certify` — Service Manager (`dvir.certify`) |
| 10 | Route `Ongoing → Completed` | ✅ | **Avtomatik**: geofence (default 300 m) ichida ≥ 2 daqiqa (`tz.md` Q66–68). Qo'lda faqat `not_completed` |
| 11 | Inactive unit/driver'ning loglari | ✅ | Loglar/DVIR **o'chmaydi**; `include_inactive` filtri bilan ko'rinadi (`tz.md` Q3) |
| 12 | Rolli ruxsatlar ro'yxatining haqiqiy mazmuni | ✅ | **105 kalit** — `backend/internal/auth/permissions.go` + `GET /permissions` (F90) |
| 13 | ELD qurilma modellari ro'yxati (`Choose ELD Type`) | ❓ **Ochiq** | `tz.md` qaror 27: qurilma modeli tanlanmagan (⏸). UI'da `ELD` maydoni — `GET /eld-devices` dan ro'yxatga aylantirildi (model qattiq ro'yxat emas) |
| 14 | `Alert Type` va `Delivery Method` variantlari | ✅ | `maintenance_upcoming`/`maintenance_overdue`; `push · email · sms · in_app` (F110) |
| 15 | Sana/vaqt formati (6 xil variant) | ✅ | **2 format**, `regulation_profile` ga bog'liq (§12.2) |
| 16 | Export/Import fayl formatlari | ✅ | Import: `csv`, `xlsx`. Eksport: `csv`, `xlsx`, `pdf`, `zip` (§11.3) |

**Natija: 16 dan 15 tasi hal qilindi**, 1 tasi (№13) backend qaroriga bog'liq va ochiq qoladi.

## 17.2 Yangi ochiq savollar

### Buyurtmachi tasdig'i kerak (❓)

| № | Savol | Nima uchun muhim | Taklif |
|---|---|---|---|
| Q1 | **Xarita tile provayderi** (`tz.md` qaror 26, §23) | Style URL va kalit bo'lmasa xarita ekranlari (Dashboard, Tracking, Track on Map, Trip Planner) ishlamaydi. **4-bosqichni bloklaydi** | MapTiler (boshlang'ich) yoki Protomaps self-host (xarajatsiz, ma'lumot chiqmaydi) |
| Q2 | **Product Sans litsenziyasi** | Display darajasida ishlatiladi; litsenziya bo'lmasa huquqiy risk | Fallback: IBM Plex Sans 700 (vizual farq minimal) |
| Q3 | **Privacy Policy / Terms of Use matni** (`tz.md` qaror 28) | Footer havolalari; hozircha begona («Jusoor») matn | Matn kelmaguncha havolalar ko'rsatilmaydi |
| Q4 | **Admin panelda dark tema kerakmi** | MVP'da yo'q (F53); keyingi bosqichda 50+ ekran uchun dizayn kerak | Mobil/planshet dark palitrasi mavjud — web uchun moslashtirish 🎨 |
| Q5 | **Kompaniya logotipi va brend elementlari** | `Company Logo` maydoni bor, lekin panel brendi (logotip fayli) yo'q | 🎨 SVG logotip + favicon to'plami |
| Q6 | **Bo'sh holat illyustratsiyasi** | Dizaynda «illyustratsiya» deb yozilgan, fayl yo'q | 🎨 1 ta universal SVG |

### Backend CR nomzodlari (`v1` muzlatilgan — v1.1 uchun)

| № | Bo'shliq | Ta'siri | MVP vaqtinchalik yechimi |
|---|---|---|---|
| Q7 | `GET /users/export` yo'q | Dizayndagi `Export Users` tugmasi ishlamaydi | Tugma olib tashlanadi (N16) |
| Q8 | `GET /logs/by-unit?date=` yo'q | «Bir kun × barcha unitlar × HOS» ekrani N+1 so'rov talab qiladi | `GET /tracking/live` + sahifadagi haydovchilar uchun `hos-summary` (parallel ≤ 6), HOS ustunlari default'da yashirin (F95) |
| Q9 | Global qidiruv endpointi yo'q | Header'dagi qidiruv | `GET /drivers?search=` + `GET /units?search=` parallel (F40) |
| Q10 | WS `auth` freymida `company_id` yo'q | Super Admin tenant rejimida real-vaqt ishlamaydi | Super Admin rejimida WS o'chiriladi, 60 s polling (F155) |
| Q11 | Route status enum'i ikki xil (`dashboard_dto` vs `routes_dto`) | Tip xavfsizligi | Normalizator: `planned\|in_progress → ongoing` (F119) |
| Q12 | `GET /tracking/live` da bbox filtri yo'q | Katta parkda barcha unitlar bir marta yuklanadi | Klasterlash + klient tomonda filtrlash (F167/F168) |
| Q13 | Chat: fayl biriktirish uchun `kind=chat` presign bor, lekin xabar DTO'sida `file_key` bitta | Bir xabarga bir fayl | Bir xabar = bir fayl (F132) |

### Frontend ichki qarorlar (tasdiq talab qilmaydi, lekin qayd etiladi)

| № | Qaror |
|---|---|
| D-f1 | Refresh token `sessionStorage` da — backend httpOnly cookie bermagani uchun (F14). Backend CR bilan o'zgaradi |
| D-f2 | Minimal kenglik 1280 px; mobil/planshet web admin qo'llab-quvvatlanmaydi (F77) |
| D-f3 | Ikonka nabori — `lucide-react` (F50) |
| D-f4 | Radius shkalasi 4/8/12/16 — dizaynda berilmagan (F49) |
| D-f5 | Spacing shkalasi 4 pt — dizaynda berilmagan (F47) |
| D-f6 | Vaqt Company Home Terminal TZ da ko'rsatiladi, brauzer TZ da emas (F193) |

---

# 18. Claude Code bilan bajarish tartibi

Ushbu bo'lim — **ish protokoli**. Backend `eld-*` subagentlar orqali qurilgani kabi, frontend ham **bosqichma-bosqich, subagentlar orqali** quriladi. Har bosqich mustaqil tekshiriladigan natija beradi.

## 18.0 Umumiy ish qoidalari **[MUST]**

**W1 — Bitta tool chaqiruvi ≤ 5 daqiqa.** `npm install`, `npm run build`, Playwright — **fon rejimida** (`run_in_background: true`), keyin holati kuzatiladi. Foreground'da 5 daqiqadan uzoq buyruq ishga tushirilmaydi.

**W2 — Parallel agentlar kesishmaydigan fayl to'plamlarida ishlaydi.** Har agentga **aniq fayl/papka egaligi** beriladi. Ikki agent bitta faylni tahrirlamaydi — konflikt va yo'qolgan o'zgarish riski. Umumiy fayllar (`router.tsx`, `en.json`, `tailwind.config.ts`, `client.ts`) — **faqat bitta agent** yoki bosqich boshida/oxirida asosiy sessiya tomonidan.

**W3 — Har bosqich oxirida to'rt tekshiruv yashil:**
```bash
npm run typecheck   # tsc --noEmit
npm run lint        # eslint
npm run test        # vitest run
npm run build       # vite build
```
Bittasi qizil bo'lsa bosqich **tugallanmagan** hisoblanadi.

**W4 — Har bosqich oxirida ikki ko'rik:** `frontend-security-reviewer` (§13 chek-listi) va `frontend-code-reviewer` (konventsiyalar, dublikat, qatlam buzilishi). Backenddagi `eld-security-auditor` + `eld-code-reviewer` amaliyoti bilan bir xil.

**W5 — Katta fayl bo'lak-bo'lak yoziladi.** 500 qatordan uzun fayl bitta `Write` bilan emas, mantiqiy bo'laklarga bo'linadi.

**W6 — Har o'zgarishdan keyin i18n.** Yangi matn qo'shilsa `en.json` ham o'sha commit'da yangilanadi. `npm run i18n:extract` yo'qolgan kalitni topadi.

**W7 — `schema.d.ts` ga qo'lda tegilmaydi.** Faqat `npm run api` orqali yangilanadi.

**W8 — Migratsiya yo'q, backend o'zgarmaydi.** Frontend agenti `backend/` papkasiga **yozmaydi**. Backend bo'shlig'i topilsa — §17.2 jadvaliga qator qo'shiladi va MVP yechimi yoziladi.

**W9 — Har vazifadan keyin qisqa hisobot:** nima qilindi, qaysi fayllar, qaysi tekshiruvlar o'tdi, nima ochiq qoldi.

**W10 — Git:** har bosqich alohida branch (`feat/stage-<n>-<nom>`), har mantiqiy blok alohida commit. Asosiy branch'ga to'g'ridan-to'g'ri push yo'q.

## 18.1 Subagentlar

`.claude/agents/` ga qo'shiladigan frontend agentlari:

| Agent | Vazifasi | Skillari (o'qiydi) | Tool'lari |
|---|---|---|---|
| `fe-architect` | Karkas: Vite/TS/Tailwind/ESLint sozlash, router, provayderlar, layout'lar, `client.ts`, auth oqimi | `fe-conventions`, `fe-api` | Read, Write, Edit, Bash, Grep, Glob |
| `ui-component-builder` | `components/ui/*` va `components/data/*` — dizayn tizimi primitivlari + testlari | `fe-design-system`, `fe-a11y` | Read, Write, Edit, Bash, Grep |
| `api-integration` | `src/api/queries/*` — query/mutation hooklari, tip alias'lari, MSW handler'lari | `fe-api`, `fe-conventions` | Read, Write, Edit, Bash, Grep |
| `screen-implementer` | `features/<modul>/*` — ekranlar, formalar, jadvallar. **Modul bo'yicha parallel ishlaydi** | `fe-screens`, `fe-conventions`, `fe-design-system` | Read, Write, Edit, Bash, Grep, Glob |
| `map-engineer` | `components/map/*`, tracking va trip ekranlari | `fe-map` | Read, Write, Edit, Bash |
| `realtime-engineer` | `lib/ws.ts`, kanal hooklari, qayta ulanish, `since` backfill | `fe-realtime` | Read, Write, Edit, Bash |
| `a11y-reviewer` | Klaviatura, ARIA, kontrast, `axe` yugurtirish va tuzatish | `fe-a11y` | Read, Edit, Bash, Grep |
| `frontend-test-engineer` | Vitest integratsiya testlari, MSW, Playwright e2e | `fe-testing` | Read, Write, Edit, Bash |
| `frontend-security-reviewer` | §13 chek-listi: CSP, token, XSS, PII, audit tasdig'i | `fe-security` | Read, Edit, Bash, Grep |
| `frontend-code-reviewer` | Konventsiyalar, dublikat, qatlam buzilishi, DoD | `fe-conventions` | Read, Bash, Grep, Glob, Edit |
| `i18n-keeper` | `en.json` butunligi, yo'qolgan/ortiqcha kalitlar, hardcode matn ovi | `fe-conventions` | Read, Edit, Bash, Grep |

**Skillar** (`.claude/skills/` — siqilgan bilim, butun TZ ni qayta o'qimaslik uchun):
| Skill | Mazmuni |
|---|---|
| `fe-conventions` | Stack, papka tuzilmasi, nomlash, ESLint/Prettier, DoD (§2) |
| `fe-api` | Klient generatsiyasi, auth oqimi, xato formati, pagination (§3) |
| `fe-design-system` | Ranglar, tipografika, spacing, radius, komponent ro'yxati (§5) |
| `fe-screens` | Ro'yxat/forma/modal patternlari + ekran jadvali (§6, §7) |
| `fe-realtime` | WS protokoli, kanallar, qayta ulanish (§8) |
| `fe-map` | MapLibre, klasterlash, polyline, geofence (§9) |
| `fe-a11y` | Klaviatura, ARIA, kontrast qoidalari (§14.2) |
| `fe-testing` | Vitest/MSW/Playwright qoidalari, qamrov chegaralari (§14.1) |
| `fe-security` | CSP, token saqlash, XSS, PII, audit tasdig'i (§13) |
| `fe-permissions` | 105 permission kaliti, scope, 403/404 (§4) |

## 18.2 Bosqichlar

### Bosqich 0 — Karkas va autentifikatsiya
**Qamrov:** loyiha skeleti, API klienti, auth oqimi, layout, router, permission tizimi.
**Bog'liqlik:** yo'q.
**Agentlar:** `fe-architect` (asosiy), `api-integration` (klient), `frontend-security-reviewer` + `frontend-code-reviewer` (oxirida).
**Chiqish mezoni:** login qilib bo'ladi, `/` da bo'sh layout va haqiqiy nav ko'rinadi (ruxsatlar bo'yicha), 401 da avtomatik refresh ishlaydi, logout ishlaydi, 4 tekshiruv yashil.

```markdown
- [ ] 0.1 `admin/` papkasi, Vite + React 18 + TS strict, `npm create vite`
- [ ] 0.2 Tailwind 3.4 o'rnatish, `tailwind.config.ts` bo'sh token skeleti
- [ ] 0.3 ESLint 9 flat config + Prettier + `jsx-a11y` + `no-restricted-imports` (features kesishmasi)
- [ ] 0.4 `tsconfig` paths (`@/*`) + Vite alias
- [ ] 0.5 `package.json` skriptlari: `dev build preview typecheck lint lint:fix test test:cov e2e api api:gen i18n:extract`
- [ ] 0.6 `.env.example`, `README.md` (ishga tushirish yo'riqnomasi)
- [ ] 0.7 `npm run api` — `swagger.json` yuklab olish + `schema.d.ts` generatsiya, `openapi/swagger.json` commit
- [ ] 0.8 `src/api/types.ts` — 30+ domen tipi uchun alias
- [ ] 0.9 `src/api/client.ts` — `openapi-fetch` + 4 middleware (auth, company, idempotency, error)
- [ ] 0.10 `src/lib/errors.ts` — `normalizeError`, kod → i18n kaliti xaritasi
- [ ] 0.11 `src/features/auth/` — login, forgot/reset password, invitation accept, 2FA
- [ ] 0.12 Auth store (Zustand): access token xotirada, refresh `sessionStorage` da
- [ ] 0.13 Refresh mutex + proaktiv (80 % TTL) + reaktiv (401) yangilash; reuse → to'liq logout
- [ ] 0.14 `GET /app/config` bootstrap: soat siljishi, feature flags
- [ ] 0.15 `GET /me` — profil, ruxsatlar, company (region, unit_system, regulation_profile, timezone)
- [ ] 0.16 `src/lib/permissions.ts` — 105 kalit konstantasi + `usePermission()` + `PermissionGate`
- [ ] 0.17 CI testi: konstantalar `GET /permissions` snapshot'i bilan mos
- [ ] 0.18 `AppLayout` — 3 qatlamli header (brend + nav + breadcrumb), profil menyusi
- [ ] 0.19 Nav va flyout'lar ruxsat bo'yicha filtrlanadi (§4.5 jadvali)
- [ ] 0.20 `router.tsx` — barcha marshrutlar lazy, route guard, 403/404/ErrorBoundary ekranlari
- [ ] 0.21 i18n sozlash + `en.json` skeleti (`common.*`, `errors.*`, `nav.*`, `enums.*`)
- [ ] 0.22 Idle timeout (30 daq) + `subscription_readonly` banneri + `replaced_session` toast
- [ ] 0.23 GitHub Actions: typecheck, lint, test, build, `schema.d.ts` diff tekshiruvi
- [ ] 0.24 `frontend-security-reviewer` + `frontend-code-reviewer`
```

### Bosqich 1 — Dizayn tizimi va komponent kutubxonasi
**Qamrov:** §5 tokenlari + §5.6 dagi 30+ komponent + §6 patternlari.
**Bog'liqlik:** Bosqich 0.
**Agentlar:** `ui-component-builder` (asosiy), `a11y-reviewer`, `frontend-test-engineer`.
**Chiqish mezoni:** har komponent testi bor, `components/ui/` qamrovi ≥ 90 %, `axe` kritik xato 0, hech qanday hardcode hex/px/string yo'q.

```markdown
- [ ] 1.1 `tailwind.config.ts` — ranglar (CSS o'zgaruvchilar orqali), tipografika, spacing, radius, soyalar
- [ ] 1.2 Shriftlar lokal `woff2` (IBM Plex Sans; Product Sans yoki fallback)
- [ ] 1.3 `lucide-react` o'rnatish, `Icon` wrapper
- [ ] 1.4 Primitivlar: Button, IconButton, Input, Textarea, Select, MultiSelect, Checkbox, Radio, Switch
- [ ] 1.5 Sana/vaqt: DatePicker, DateRangePicker (presetlar bilan), TimePicker
- [ ] 1.6 Overlay: Modal (focus trap), ConfirmDialog, Drawer, Tooltip, Toast provayderi
- [ ] 1.7 Ko'rsatish: Badge, StatusChip, Avatar, Card, KpiCard, Breadcrumb, Tabs
- [ ] 1.8 Holatlar: EmptyState, ErrorState, Skeleton, Spinner, `useDelayedLoading`
- [ ] 1.9 `DataTable` — saralash, ustun ko'rsatish/yashirish (`localStorage`), sticky birinchi ustun, `overflow-x`
- [ ] 1.10 `Pagination` (10/25/50) + `useListParams` (URL query-string sinxronizatsiyasi)
- [ ] 1.11 `FiltersBar` — qidiruv (400 ms debounce), select filtrlar, faol filtr badge'i, `Clear all`
- [ ] 1.12 `FormField` oilasi — react-hook-form + zod integratsiyasi, server xatolarini bog'lash
- [ ] 1.13 `FileUpload` — presign oqimi, progress (XHR), MIME/hajm tekshiruvi
- [ ] 1.14 `lib/format.ts` (sana/vaqt/davomiylik/nisbiy) + `lib/units.ts` (SI ↔ imperial) + testlari
- [ ] 1.15 `ListScreen` shabloni — §6.1 tuzilmasini beruvchi kompozitsiya
- [ ] 1.16 Har komponent uchun Vitest testi (render + interaksiya + rol)
- [ ] 1.17 `a11y-reviewer`: fokus halqasi, ARIA, kontrast; `warning-base` matn uchun `warning-dark` ga almashtirish
- [ ] 1.18 `frontend-code-reviewer`
```

### Bosqich 2 — Fleet moduli
**Qamrov:** Units, Drivers, ELD devices, Trailers, Shipping documents, Users, Roles (§7.3), import/export.
**Bog'liqlik:** 0, 1.
**Agentlar:** `api-integration` (queries) → `screen-implementer` ×2 **parallel** (A: units+eld+trailers+docs · B: drivers+users+roles) → `frontend-test-engineer` → ko'riklar.
**Fayl egaligi:** A → `features/fleet/units/`, `features/fleet/eld/`, `features/fleet/trailers/`, `features/fleet/documents/`; B → `features/fleet/drivers/`, `features/fleet/users/`, `features/fleet/roles/`. `api/queries/` — bosqich boshida `api-integration` tomonidan **to'liq yoziladi**, keyin faqat o'qiladi.
**Chiqish mezoni:** 7 ekranda CRUD to'liq ishlaydi, permission testlari o'tadi, import xato hisoboti ko'rinadi, license reveal audit bilan.

```markdown
- [ ] 2.1 `api/queries/units.ts`, `drivers.ts`, `eldDevices.ts`, `trailers.ts`, `shippingDocuments.ts`, `users.ts`, `roles.ts`, `permissions.ts`
- [ ] 2.2 Unit: ro'yxat (tablar, filtrlar, saralash, ustun tanlash) + Add/Edit modal + View + Activities + Diagnostics
- [ ] 2.3 Unit import/export (shablon yuklab olish, all-or-nothing xato jadvali)
- [ ] 2.4 Driver: ro'yxat + Add/Edit + View (Information/Activities/Daily logs) + co-driver boshqaruvi
- [ ] 2.5 Driver: `Send password reset` (dizayndagi parol modali o'rniga) + license reveal (30 s, audit)
- [ ] 2.6 ELD devices CRUD + `assign-unit` 🎨
- [ ] 2.7 Trailers, Shipping documents CRUD 🎨
- [ ] 2.8 Users: ro'yxat + invite + edit + activate/deactivate + resend invitation + reset password
- [ ] 2.9 Roles: ro'yxat + Add/Edit (105 kalit, 26 guruh, `scope` tanlovi) + system rol himoyasi + 409 ishlovi
- [ ] 2.10 Barcha formalarda `Password` maydoni yo'qligi tekshiriladi (D2)
- [ ] 2.11 Integratsiya testlari (MSW): har modul uchun ro'yxat + filtr + forma + xato + permission
- [ ] 2.12 `frontend-security-reviewer` (PII, mass-assignment, ruxsat) + `frontend-code-reviewer`
```

### Bosqich 3 — Logs va HOS
**Qamrov:** Logs By Unit / By Driver, Log view (3 tab + grid), Log edit requests, Unassigned driving, Violations (§7.4).
**Bog'liqlik:** 0, 1, 2 (driver/unit select'lari).
**Agentlar:** `screen-implementer` (asosiy), `ui-component-builder` (24 soatlik SVG grid), `frontend-test-engineer`.
**Chiqish mezoni:** grid to'g'ri chiziladi (golden snapshot testi), **log edit request oqimi** to'liq ishlaydi va hech qanday to'g'ridan-to'g'ri tahrir yo'q, HOS raqamlari faqat backenddan.

```markdown
- [ ] 3.1 `api/queries/logs.ts`, `hos.ts`, `violations.ts`, `logEditRequests.ts`, `unidentified.ts`
- [ ] 3.2 Logs By Unit — `tracking/live` + shartli `hos-summary` kompozitsiyasi (concurrency ≤ 6, kesh 60 s)
- [ ] 3.3 Logs By Driver — driver select + sana oralig'i + `daily-logs`
- [ ] 3.4 `HosRings` komponenti — 4 halqa, qiymatlar `hos-summary` dan, hech qanday hardcode chegara
- [ ] 3.5 `DutyGrid` — 24 soatlik SVG grid, PC/YM shtrixi, hodisa markerlari (`pti/fuel/certify/malfunction`), tooltip
- [ ] 3.6 Voqealar jadvali — `origin` ustuni, `✎` belgisi + asl qiymat tooltip'i
- [ ] 3.7 Log Form bloki — trailers/docs badge'lari, imzo (faqat ko'rish)
- [ ] 3.8 **`Send edit request` paneli** — status tugmalari, From/To/Note, Q17.1 taqiqlari UI'da bloklangan
- [ ] 3.9 Report tabi — PDF ko'rish + download (blob, `Authorization`)
- [ ] 3.10 Trip Planner tabi — xarita joy egallaydi (to'liq 4-bosqichda), segmentlar ro'yxati, `Create route` formasi
- [ ] 3.11 Log Edit Requests ekrani — approve/reject (sabab majburiy), o'z taklifini tasdiqlash bloklangan 🎨
- [ ] 3.12 Unassigned Driving ekrani — assign / annotate, 8 kun qoidasi 🎨
- [ ] 3.13 Violations ro'yxati + detal, `resolved` badge, delete yo'q
- [ ] 3.14 Golden testlar: grid render (snapshot), HOS format, violation matnlari
- [ ] 3.15 `frontend-security-reviewer` (audit tasdig'i, taqiqlar) + `frontend-code-reviewer`
```

### Bosqich 4 — Tracking va xarita
**Qamrov:** Tracking ro'yxati, Track on Map, Routes, Dashboard xaritasi, Trip Planner xaritasi (§7.7, §9).
**Bog'liqlik:** 0, 1, 3 (Trip Planner), **Q1 (tile provayderi) hal bo'lishi shart**.
**Agentlar:** `map-engineer` (asosiy), `realtime-engineer` (WS tracking), `screen-implementer`.
**Chiqish mezoni:** 500 marker bilan xarita ≥ 30 fps, WS yangilanishi ≤ 5 s, xarita chunk lazy va ≤ 400 KB.

```markdown
- [ ] 4.1 ❓ Q1 hal qilinadi; `VITE_MAP_STYLE_URL` sozlanadi
- [ ] 4.2 `components/map/MapCanvas.tsx` — MapLibre wrapper, lazy chunk, `prefers-reduced-motion`
- [ ] 4.3 GeoJSON source + klasterlash (radius 50, maxZoom 14) + duty status ikonkalari
- [ ] 4.4 `UnitMarkerCard` popup (dizayn 200×217 tarkibi)
- [ ] 4.5 Tracking ro'yxati — filtrlar, satr yangilanishi joyida (WS), `Track on Map` amali
- [ ] 4.6 Track on Map — ikki kirish yo'li, breadcrumb, sana navigatori, `Refresh`
- [ ] 4.7 Yon panel: haydovchi bloki + **Unit Diagnostics** + Histories (trip timeline)
- [ ] 4.8 Trip polyline (`include_polyline=true` faqat kerakda), segment tanlash, `fitBounds`
- [ ] 4.9 Routes CRUD + geofence doirasi + `not-completed` sabab modali + `directions`
- [ ] 4.10 Trip Planner tabini xarita bilan yakunlash (3.10 dan davomi)
- [ ] 4.11 Xarita a11y: `role="application"`, klaviatura, jadval ekvivalenti
- [ ] 4.12 Performans o'lchovi: 500 marker sinov ma'lumoti bilan fps va bundle hisoboti
- [ ] 4.13 `frontend-code-reviewer`
```

### Bosqich 5 — DVIR va Maintenance
**Qamrov:** §7.5, §7.6, §7.6.1.
**Bog'liqlik:** 0, 1, 2 (unit/driver select'lari), 10-bo'lim (fayl yuklash — 1.13 da tayyor).
**Agentlar:** `screen-implementer` ×2 **parallel** (A: `features/dvir/` · B: `features/maintenance/`).
**Chiqish mezoni:** DVIR holat mashinasi to'g'ri (6 holat), admin DVIR yaratmaydi, maintenance birlik konvertatsiyasi ikki tomonlama to'g'ri.

```markdown
- [ ] 5.1 `api/queries/dvir.ts`, `maintenance.ts`, `defectTypes.ts`
- [ ] 5.2 DVIR ro'yxati — filtrlar, 6 holat badge'i, `Pending certification` tabi
- [ ] 5.3 DVIR detali — nuqsonlar, fotolar (lightbox), imzolar (ko'rish), holat tarixi
- [ ] 5.4 `Record repair` (izoh + invoice fayl) va `Certify` amallari (tasdiq bilan)
- [ ] 5.5 DVIR PDF yuklab olish; kritik nuqson → `out_of_service` banneri
- [ ] 5.6 Maintenance 3 tab (Schedule / Due / History), ustunlar §7.6 bo'yicha, bo'sh va to'la holat **bir xil ustunlar**
- [ ] 5.7 Add/Edit — single va multiple rejimi, `Select All`, alert bloki
- [ ] 5.8 **Birlik konvertatsiyasi** — kiritishda `parseDistance`, ko'rsatishda `formatDistance`; birlik yorlig'i doim ko'rinadi
- [ ] 5.9 View (single/multiple), guruh ichiga kirish (`N Units` → alohida ekran)
- [ ] 5.10 `Mark as Complete` modali (invoice PDF/JPG/PNG ≤ 10 MB) va `Cancel` (sabab)
- [ ] 5.11 History detali + `PRE/POST-TRIP INSPECTION` bloklari DVIR'lar bilan to'ldiriladi
- [ ] 5.12 Defect Types CRUD (dublikat `Engine` va `Refresh` yo'q) 🎨
- [ ] 5.13 Testlar: holat mashinasi, konvertatsiya chegaraviy qiymatlari, fayl yuklash
- [ ] 5.14 `frontend-security-reviewer` (fayl yuklash, MIME) + `frontend-code-reviewer`
```

### Bosqich 6 — Reports va eksport
**Qamrov:** §7.8 (6 ekran) + §11 asinxron oqim.
**Bog'liqlik:** 0, 1, 2.
**Agentlar:** `screen-implementer`, `api-integration` (export-jobs polling hook'i).
**Chiqish mezoni:** export job oqimi to'liq (yaratish → polling → download → muddati o'tishi), `regulation_profile` bo'yicha nomlar to'g'ri almashadi, print stillari ishlaydi.

```markdown
- [ ] 6.1 `api/queries/reports.ts` + `useExportJob(id)` polling hook'i (2→5→10 s, maks. 5 daq)
- [ ] 6.2 Activity Report (Drivers/Units tablari) + detal ekrani + `Print`
- [ ] 6.3 Distance by Region / IFTA — ko'rsatkichlar, Units/Regions tablari, Generate modali (shartli `Units` maydoni)
- [ ] 6.4 Regulator Export / FMCSA — job ro'yxati, Generate modali (8 kun / Custom Range)
- [ ] 6.5 DVIR Report — filtr + eksport (imzo formasi **yo'q**)
- [ ] 6.6 Uncertified Logs hisoboti + `Send reminder`
- [ ] 6.7 Export Jobs ekrani (`mine` toggle, muddati o'tgan havola ishlovi)
- [ ] 6.8 `regulation_profile` ga bog'liq nom almashinuvi (i18n bilan) — testda ikkala profil
- [ ] 6.9 `@media print` stillari
- [ ] 6.10 Testlar: job oqimi (queued→running→done→expired), format kombinatsiyalari
- [ ] 6.11 `frontend-code-reviewer`
```

### Bosqich 7 — Real-vaqt, Chat, Notifications, Dashboard
**Qamrov:** §8 to'liq, §7.2 Dashboard, §7.9 Chat, §7.11 Notifications.
**Bog'liqlik:** 0, 1, 4 (tracking kanali xarita bilan bog'lanadi).
**Agentlar:** `realtime-engineer` (asosiy, `lib/ws.ts` egasi), `screen-implementer` (Chat, Dashboard, Notifications).
**Chiqish mezoni:** 4 kanal ishlaydi, qayta ulanish va `since` backfill tekshirilgan, dublikat toast yo'q, token URL'da emasligi testda majburlangan.

```markdown
- [ ] 7.1 `lib/ws.ts` — `reconnecting-websocket`, `auth` freymi, `welcome` kutish, kanal registri
- [ ] 7.2 **Test: URL'da hech qanday token yo'q** (`?token=`, `?access_token=` … ) — majburiy negativ test
- [ ] 7.3 `useChannel(channel, filter, onEvent)` hook'i — mount/unmount da subscribe/unsubscribe
- [ ] 7.4 `since` kuzatuvi (kanal bo'yicha oxirgi `ts`), `replay: true` da toast bosilmaydi
- [ ] 7.5 Ulanish holati store + «Live updates paused» banneri + polling fallback (60 s)
- [ ] 7.6 60 s amaliy `ping`, `visibilitychange` bo'yicha 5 daqiqadan keyin uzish
- [ ] 7.7 Dashboard — 9 KPI karta, status bloki, xarita, Route's Details, WS `dashboard`
- [ ] 7.8 Notifications — header dropdown + sahifa, `entity_type` bo'yicha navigatsiya, `user_id` filtri
- [ ] 7.9 Chat — threadlar, kursorli yuklash (`before`), yuborish, o'qilgan belgisi (IntersectionObserver)
- [ ] 7.10 Chat: fayl biriktirish (`kind=chat`), haydash rejimi ogohlantirishi 🎨
- [ ] 7.11 Testlar: qayta ulanish, backfill dublikati, `FORBIDDEN` kanalga qayta urinmaslik
- [ ] 7.12 `frontend-security-reviewer` (WS auth, tenant izolyatsiyasi) + `frontend-code-reviewer`
```

### Bosqich 8 — Settings, Support, Audit
**Qamrov:** §7.10, §7.13, §7.12.
**Bog'liqlik:** 0, 1, 2.
**Agentlar:** `screen-implementer` ×2 **parallel** (A: `features/settings/` · B: `features/support/` + `features/audit/`).
**Chiqish mezoni:** HOS policy versiyalash oqimi to'g'ri, `unit_system`/`regulation_profile` o'zgarishi butun UI ni qayta formatlaydi, audit 4 ko'rinishi bitta manbadan.

```markdown
- [ ] 8.1 `api/queries/company.ts`, `branches.ts`, `hosPolicy.ts`, `notificationSettings.ts`, `support.ts`, `feedback.ts`, `audit.ts`
- [ ] 8.2 Settings › Company — barcha maydonlar, logo yuklash, profil o'zgarishida tasdiq + qayta formatlash
- [ ] 8.3 Settings › Branches CRUD 🎨
- [ ] 8.4 Settings › HOS Policy — 15 parametr, soat:daqiqa kiritish, presetlar, **yangi versiya** semantikasi + tarix/diff 🎨
- [ ] 8.5 Settings › Notifications — 16 × 4 matritsa, `hos_*`/`eld_*` push majburiy 🎨
- [ ] 8.6 Settings › Profile (`Last Name`, to'g'ri placeholder'lar) va Security (joriy parol, 2FA, sessiyalar)
- [ ] 8.7 Settings › Company history (filtrlar `user`/`table`)
- [ ] 8.8 Contact Support — ro'yxat, detal + **thread**, status modali 🎨
- [ ] 8.9 Feedback — ro'yxat + to'liq matn modali 🎨
- [ ] 8.10 Audit (`Histories`) — `audit-log` + `audit-log/tables`, `Add User` tugmasi yo'q, `N/A`, 3 harfli hafta kuni
- [ ] 8.11 Inspection logs ekrani **[MAY]** 🎨
- [ ] 8.12 Testlar: HOS policy publish tasdig'i, profil o'zgarishida format almashinuvi
- [ ] 8.13 `frontend-security-reviewer` + `frontend-code-reviewer`
```

### Bosqich 9 — Sayqal, testlar, ishga tushirish
**Qamrov:** e2e, a11y, performans, i18n butunligi, deploy.
**Bog'liqlik:** 0–8.
**Agentlar:** `frontend-test-engineer`, `a11y-reviewer`, `i18n-keeper`, `frontend-security-reviewer`, `frontend-code-reviewer`.
**Chiqish mezoni:** §14 va §15 dagi barcha maqsadlar bajarilgan, `eldadmin.stackyard.uz` da ishlaydi.

```markdown
- [ ] 9.1 Playwright: §14.4 dagi 8 oqim
- [ ] 9.2 `axe-core` asosiy 10 ekranda — kritik xato 0
- [ ] 9.3 Lighthouse: Performance ≥ 90, A11y ≥ 95, Best Practices ≥ 95
- [ ] 9.4 Bundle byudjeti: boshlang'ich JS ≤ 250 KB gzip; `rollup-plugin-visualizer` hisoboti
- [ ] 9.5 `i18n-keeper`: yo'qolgan/ortiqcha kalitlar 0, hardcode string 0 (`i18next/no-literal-string` → error)
- [ ] 9.6 Barcha `enum` qiymatlari uchun i18n kalitlari (`enums.*`) to'liqligi testi
- [ ] 9.7 Xato kodlari uchun i18n kalitlari to'liqligi
- [ ] 9.8 `metric`/`imperial` va `generic`/`fmcsa_us` bo'yicha to'liq e2e o'tish
- [ ] 9.9 CSP va xavfsizlik header'lari (nginx/Caddy konfiguratsiyasi) + `securityheaders.com` tekshiruvi
- [ ] 9.10 `npm audit` — `high`/`critical` 0
- [ ] 9.11 Deploy: statik build → `eldadmin.stackyard.uz`, SPA fallback (`try_files … /index.html`), gzip/brotli, cache header'lari (`index.html` — `no-cache`, assets — `immutable`)
- [ ] 9.12 Sentry (ixtiyoriy) + sourcemap serverdan olib tashlanadi
- [ ] 9.13 `README` — ishga tushirish, `npm run api` oqimi, bosqichlar holati
- [ ] 9.14 **Yakuniy ko'rik:** `frontend-security-reviewer` + `frontend-code-reviewer` + §16/§17 reestrini yangilash
- [ ] 9.15 **[MAY]** Super Admin konsoli (§7.14)
```

## 18.3 Parallel ishlash xaritasi

| Bosqich | Parallel ishlash mumkinmi | Fayl egaligi |
|---|---|---|
| 0 | Yo'q (asos) | bitta agent |
| 1 | Qisman: `ui/` primitivlari 2 agentga bo'linadi (A: form elementlari · B: overlay + holatlar) | `components/ui/<fayl>` bo'yicha aniq bo'lish |
| 2 | **Ha** — 2 agent (A: units/eld/trailers/docs · B: drivers/users/roles) | `features/fleet/<submodul>/` |
| 3 | Yo'q (grid va log view o'zaro bog'liq) | bitta agent + grid uchun yordamchi |
| 4 | Qisman: `map-engineer` + `realtime-engineer` | `components/map/` vs `lib/ws.ts` |
| 5 | **Ha** — 2 agent (DVIR · Maintenance) | `features/dvir/` vs `features/maintenance/` |
| 6 | Yo'q (export-jobs hook'i umumiy) | bitta agent |
| 7 | Qisman: WS infratuzilma → keyin 3 ekran parallel | `lib/ws.ts` bitta agentda |
| 8 | **Ha** — 2 agent (Settings · Support+Audit) | `features/settings/` vs `features/support/`+`features/audit/` |
| 9 | **Ha** — 4 ko'rikchi parallel (test, a11y, i18n, security) | har biri o'z hisobotini beradi, tuzatishlar ketma-ket qo'llanadi |

**W11 [MUST]** Parallel agentlar `en.json`, `router.tsx`, `tailwind.config.ts`, `api/queries/index.ts` fayllariga **yozmaydi**. Ular uchun har agent o'z bo'lagini alohida faylga yozadi (`locales/en/<modul>.json`, `router/<modul>.routes.ts`) va asosiy sessiya bosqich oxirida birlashtiradi.

## 18.4 Definition of Done

### Har **vazifa** uchun (checkbox yopilishi shartlari)
- [ ] Kod TypeScript `strict` bilan kompilyatsiya bo'ladi (`any` yo'q)
- [ ] ESLint va Prettier toza
- [ ] Barcha UI matnlari `en.json` da, kodda hardcode string yo'q
- [ ] API chaqiruvlari faqat `openapi-fetch` orqali, tiplar `schema.d.ts` dan
- [ ] Ruxsat tekshiruvi qo'shilgan (menyu/tugma/marshrut) va tegishli kalit §4 dan
- [ ] Yuklanish, bo'sh va xato holatlari **uchalasi ham** amalga oshirilgan
- [ ] Forma bo'lsa: zod sxemasi + server xatolarini maydonlarga bog'lash + `Idempotency-Key`
- [ ] Ro'yxat bo'lsa: URL query-string sinxronizatsiyasi + 10/25/50 + saralash (ruxsat etilganlar)
- [ ] Sana/vaqt `lib/format.ts` orqali, masofa/tezlik `lib/units.ts` orqali
- [ ] Kamida bitta test (komponent yoki integratsiya)
- [ ] Klaviatura bilan boshqarish va `aria-label`/`aria-live` mavjud
- [ ] Konsolda ogohlantirish yo'q (React key, deprecated API)

### Har **bosqich** uchun
- [ ] Barcha vazifa checkbox'lari yopilgan
- [ ] `typecheck` + `lint` + `test` + `build` — **to'rttasi ham yashil**
- [ ] Qamrov chegaralari saqlangan (§14.1)
- [ ] `frontend-security-reviewer` hisoboti — kritik topilma 0
- [ ] `frontend-code-reviewer` hisoboti — qatlam buzilishi va dublikat 0
- [ ] Yangi topilgan dizayn↔backend farqlari §16 ga, ochiq savollar §17 ga yozilgan
- [ ] `tasks.md` (yoki bosqich checkbox ro'yxati) yangilangan
- [ ] Branch birlashtirilgan, CI yashil

### **Loyiha** uchun (9-bosqich oxirida)
- [ ] §7 dagi barcha ekranlar amalga oshirilgan yoki aniq sabab bilan **[MAY]** ga ko'chirilgan
- [ ] §14 (testlar, a11y, performans) va §15 (NFR) maqsadlariga erishilgan
- [ ] §16 reestridagi 31 + 16 + 4 element **kodda** to'g'ri aks etgan (ko'rik bilan tasdiqlangan)
- [ ] §17 dagi ochiq savollar yopilgan yoki buyurtmachiga rasman uzatilgan
- [ ] `https://eldadmin.stackyard.uz` da ishlaydi, CSP va xavfsizlik header'lari o'rnatilgan
- [ ] `README` va ishga tushirish yo'riqnomasi to'liq

---

## 18.5 Birinchi qadam (Claude Code uchun)

```
1. `.claude/skills/fe-*` skillarini shu TZ dan yarating (10 ta skill, §18.1 jadvali).
2. `.claude/agents/` ga 11 ta frontend agentini qo'shing.
3. Bosqich 0 ni `fe-architect` bilan boshlang: `admin/` papkasi, W1–W10 qoidalariga rioya qilib.
4. Har bosqich oxirida W3 va W4 ni bajaring, keyin keyingi bosqichga o'ting.
5. Q1 (xarita provayderi) 4-bosqichgacha hal qilinishi kerak — buni erta so'rang.
```

---

**Hujjat oxiri.** Savollar va o'zgarishlar — CR orqali: avval `tz.md` yoki ushbu hujjat yangilanadi, keyin kod.
