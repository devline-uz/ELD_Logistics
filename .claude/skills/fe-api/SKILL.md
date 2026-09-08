---
name: fe-api
description: ELD Admin Panel frontendida API klient, autentifikatsiya (login/refresh/logout), xato normalizatsiyasi, pagination/filtrlash, fayl yuklash (presign) va hisobot eksporti bilan ishlaydigan kodni yozish yoki ko'rib chiqishda ishlatiladi.
---

# fe-api — ELD Admin Panel API integratsiyasi

Ushbu skill `docs/tz-admin-frontend.md` §1.3, §3, §10, §11 ning siqilgan bilimi. Maqsad — TZ ni qayta o'qimasdan API integratsiyasi bo'yicha to'g'ri qaror qabul qilish.

## 1. Backend manzillari **[MUST]**

| Nima               | Qiymat                                                                                                                      |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| Bazaviy URL (prod) | `https://eldapi.stackyard.uz/api/v1`                                                                                        |
| Swagger UI         | `https://eldapi.stackyard.uz/api/docs/index.html` (`Authorization: Bearer <DOCS_TOKEN>`)                                    |
| Xom spec           | `GET /api/docs/swagger.json` — klient generatsiyasining **yagona manbai**. Format: **Swagger 2.0** (swaggo), OpenAPI 3 emas |
| WebSocket          | `wss://eldapi.stackyard.uz/api/v1/ws` (Swagger'da yo'q, `backend/docs/websocket.md` ga qarang)                              |
| Admin panel domeni | `https://eldadmin.stackyard.uz`                                                                                             |
| API versiyasi      | `v1` — **muzlatilgan**. Yangi endpoint kerak bo'lsa CR orqali `tz.md` o'zgaradi, keyin backend                              |

### Tasdiqlangan integratsiya faktlari **[MUST]**

- **Spec Swagger 2.0** (`"swagger": "2.0"`, `basePath: /api/v1`, `host` bo'sh). 125 path, 166 operatsiya, 320 definition. `openapi-typescript` faqat OAS 3.x qabul qiladi → §2 dagi konvertatsiya bosqichi majburiy.
- **Cross-tenant murojaat `404` qaytaradi, `403` emas.** Spec'da bevosita yozilgan: «Cross-tenant reads answer 404, never 403 (TZ B§3.5)». UI hech qanday «boshqa kompaniya» ishorasini bermaydi — oddiy «Not found» ekrani (§3.5/§4.4 uchun tuzatish).
- **`per_page` faqat `10 | 25 | 50`** — boshqa qiymat **422**. Spec'da `per_page` oddiy `integer` (`default: 25`, `enum` YO'Q), cheklov faqat tavsifda («Rows per page (10/25/50)») — shuning uchun frontend tip darajasida majburlaydi (`PerPage` union, `src/api/types.ts`).
- **Login rate limit: 5 so'rov/daqiqa/IP** (`POST /auth/login` → `429`). E2E/dev testlarida login takrorlanmaydi: bitta `storageState` olinib qayta ishlatiladi, har test o'z login'ini qilmaydi. (`/app/config` alohida: 60/daq/IP.)
- **WS autentifikatsiyasi:** token **faqat** `Authorization: Bearer <access>` header'ida yoki ulangandan keyingi **birinchi `auth` freym**ida yuboriladi. URL query'da token (`?token=…`) yuborilsa server **upgrade'dan oldin 401** beradi — token log'larga tushmasligi uchun.
- **Xato konverti:** `{"error":{"code","message","details"}}` (`httpx_dto.ErrorBody` + `httpx_dto.FieldError`). Har domenning o'z `ErrorResponse` DTO'si bor, ammo ichki shakl bir xil.
- **Auth endpointlari (spec'da tasdiqlangan):** `POST /auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/2fa/setup`, `/auth/2fa/verify`, `/auth/pin/verify`, `/auth/invitation/accept`, `/auth/password/forgot`, `/auth/password/reset`; `GET /auth/sessions`, `DELETE /auth/sessions/{id}`; `GET /me`, `GET /permissions`, `GET /app/config`.
- **Sana maydonlari:** 175 maydonda `format: date-time`/`date` — generator ularni `string` qiladi. Brand tip shart emas; nomlangan alias `IsoDateTime` / `IsoDate` (`src/api/types.ts`) faqat o'qish qulayligi uchun.
- **Ro'yxat konverti:** `{ data: [...], meta: { page, per_page, total } }`. swaggo DTO'larida `required` yo'q → generatsiya qilingan `*ListEnvelope` da `data`/`meta` **ixtiyoriy** (`?`); qo'lda yozilgan `ListResponse<T>` ham shu shaklda. Istisnolar: `notifications_dto.ListMeta` (+`unread`), `chat_dto.CursorMeta` (`has_more`, `next_before`, `per_page`, `unread`).

Qoida: backend — haqiqat manbai. Dizayn/backend to'qnashsa backend ustun (farq §16 reestriga yoziladi). Frontend backendni "to'g'rilash" uchun work-around yozmaydi — yetishmagan endpoint §17 ochiq savol sifatida chiqadi.

## 2. Klient generatsiyasi **[MUST]**

Spec **Swagger 2.0**, `openapi-typescript` esa faqat **OpenAPI 3.x** qabul qiladi → oraliq konvertatsiya bosqichi bor:

```
openapi/swagger.json    ← fetch (Swagger 2.0, DOCS_TOKEN bilan)   [commit]
      ↓ swagger2openapi
openapi/openapi3.json   ← konvertatsiya (OpenAPI 3.0)             [commit]
      ↓ openapi-typescript
src/api/schema.d.ts     ← tiplar (~20k qator)                     [commit]
```

```jsonc
// package.json scripts
"api":         "npm run api:fetch && npm run api:convert && npm run api:gen && npm run lint:fix",
"api:fetch":   "node scripts/fetch-swagger.mjs",      // DOCS_TOKEN .env.local dan
"api:convert": "node scripts/convert-openapi.mjs",    // swagger2openapi (devDependency)
"api:gen":     "openapi-typescript openapi/openapi3.json -o src/api/schema.d.ts && node scripts/api-banner.mjs"
```

- **Uchala artefakt ham commit qilinadi.** `openapi3.json` oraliq bo'lsa-da repoda saqlanadi: CI da `git diff --exit-code` tekshiruvi barqarorroq bo'ladi va konvertatsiya bosqichidagi o'zgarish tip generatsiyasidagi o'zgarishdan ajratib ko'rinadi.
- `fetch-swagger.mjs` javobni `JSON.stringify(spec, null, 2)` bilan **normallashtirib** yozadi — serverning formatlash o'zgarishi diff shovqin bermaydi.
- `src/api/schema.d.ts` — **generatsiya natijasi**, qo'lda tahrirlanmaydi. `@generated` bannerini `scripts/api-banner.mjs` har generatsiyada qayta qo'yadi (openapi-typescript o'zi banner yozmaydi). ESLint `ignores` + `.prettierignore` da: `src/api/schema.d.ts`, `openapi/swagger.json`, `openapi/openapi3.json`.
- CI: `npm run api:convert && npm run api:gen && git diff --exit-code openapi/openapi3.json src/api/schema.d.ts` — spec o'zgargan bo'lsa build yiqiladi.
- `DOCS_TOKEN` — faqat `admin/.env.local` (gitignored) yoki CI secret. Kodga/log'ga/commitga **hech qachon** yozilmaydi.
- Domen tiplari faqat alias orqali (`src/api/types.ts`):

```ts
// src/api/types.ts — `Dto<domen, DtoNomi>` helper'i nomni tekshiradi:
// domen yoki DTO nomi spec'da bo'lmasa TypeScript XATO beradi (`unknown` ga yechilmaydi).
export type Unit = Dto<"fleet", "Unit">;
export type Driver = Dto<"drivers", "Driver">;
export type ListMeta = Dto<"auth", "Meta">;
export type ErrorBody = Httpx<"ErrorBody">; // internal/httpx/dto — boshqa prefiks
```

Go paket prefiksli uzun nomlar komponentlarda hech qachon ko'rinmaydi. `src/api/types.test.ts` har domen uchun alias `unknown`/`never` emasligini kompilyatsiya vaqtida tasdiqlaydi.

Domen ↔ Go paket mosligi (kutilmaganlari): joriy tenant kompaniyasi — `company_dto`, platforma (super admin) ro'yxati — `companies_dto`; foydalanuvchi/rol/ruxsat — `users_dto` (`auth_dto` emas); `GET /me` javobi — `auth_dto.Profile` (`Me` DTO'si YO'Q); login javobi — `auth_dto.LoginResult` (`LoginResponse` YO'Q); HOS — `duty_dto`; audit — `auditlog_dto`; bildirishnoma sozlamalari — `company_dto`. `sync_dto.*` — faqat mobil klient uchun, admin panelda ishlatilmaydi.

## 3. Klient va 4 middleware **[MUST]**

```ts
// src/api/client.ts
const api = createClient<paths>({ baseUrl: import.meta.env.VITE_API_BASE_URL });
api.use(authMiddleware); // Authorization: Bearer <access>
api.use(companyMiddleware); // X-Company-Id — faqat super_admin rejimida
api.use(idempotencyMiddleware); // POST uchun Idempotency-Key
api.use(errorMiddleware); // xatoni normalizatsiya qiladi (§5)
```

Barcha so'rovlar `openapi-fetch` orqali; `fetch`/`axios` bevosita chaqirilmaydi. Yagona istisnolar: presigned URL'ga fayl `PUT` (§6) va PDF/eksport `blob` yuklab olish (§7).

## 4. Autentifikatsiya oqimi **[MUST]**

```
POST /auth/login {username|email, password, device_type:"web", device_id}
   → 200 { access_token, expires_in: 900, refresh_token, refresh_expires_at,
           token_type:"Bearer", session_id, user,
           requires_totp_setup, replaced_session, subscription_readonly }
```

| Holat                         | UI reaksiyasi                                                                                                                      |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `requires_totp_setup: true`   | `refresh_token` bo'sh, token cheklangan — faqat `/auth/2fa/setup` va `/auth/2fa/verify`. UI majburan 2FA enrolment ekraniga o'tadi |
| `replaced_session: true`      | Toast: «Another web session was signed out» (1 web + 1 telefon + 1 planshet siyosati)                                              |
| `subscription_readonly: true` | Global qizil-sariq banner + barcha yozuv amallari `disabled` (tooltip: obuna muddati tugagan)                                      |
| `403 ACCOUNT_INACTIVE`        | Login ekranida xato matni, qayta urinish bloklanmaydi                                                                              |

**Token saqlash qoidasi:**

- `access_token` — **faqat JS xotirasida** (Zustand store, `persist` YO'Q). `localStorage`/`sessionStorage`ga hech qachon yozilmaydi.
- `refresh_token` — `sessionStorage`da, kalit `eld.rt`. Sabab: backend `POST /auth/refresh` cookie o'rnatmaydi (oddiy JSON, `TokensEnvelope`), httpOnly cookie `v1` muzlatilgani sababli MVP'da mumkin emas. `sessionStorage` — tab yopilganda o'chadi, boshqa tabga tarqalmaydi.
- [MAY] 2-bosqich: backend `Set-Cookie: refresh_token; HttpOnly; Secure; SameSite=Strict` qo'shsa — `sessionStorage` tashlanadi (CR orqali).

**Avtomatik yangilash (proaktiv + reaktiv):**

- Proaktiv: `expires_in` (900s) ning **80%**ida (720s) `POST /auth/refresh` chaqiriladi.
- Reaktiv: har `401` javobda:

```
401 → refresh mutex olinadi → POST /auth/refresh {refresh_token}
      ├─ 200 → yangi juftlik saqlanadi → asl so'rov BIR marta takrorlanadi
      └─ 401/403 → to'liq logout
```

Bir vaqtda 401 olgan barcha so'rovlar **bitta** refresh navbatini kutadi (mutex + kutish ro'yxati). Refresh so'rovining o'zi 401 bersa — qayta refresh qilinmaydi.

**Rotation va reuse detection:** backend har refreshda yangi `refresh_token` qaytaradi. Eski tokenni qayta ishlatish urinishi backendda butun sessiya oilasini bekor qiladi. Frontend qoidasi: refresh `401 REFRESH_REUSED` (yoki har qanday 401/403) qaytarsa →

1. xotira va `sessionStorage` tozalanadi, `queryClient.clear()`,
2. WebSocket yopiladi,
3. `/login?reason=session_expired` ga redirect,
4. toast: «Your session ended for security reasons. Please sign in again.»

Hech qanday "silent retry" yo'q.

**Boshqa auth qoidalar:**

- `POST /auth/logout` chaqiriladi (server sessiyasini yopish), javobdan qat'i nazar lokal tozalash bajariladi.
- [SHOULD] `GET /auth/sessions` va `DELETE /auth/sessions/{id}` — Settings › Security "Active sessions" ro'yxati.
- Ilova yuklanganda `GET /app/config` (public): `server_time` bilan soat siljishi tekshiriladi (>120s farqda ogohlantirish banneri), `feature_flags` bilan modul yashiriladi, `access_token_ttl_seconds` refresh taymerini sozlaydi.
- `GET /me` — profil, rol, permission ro'yxati, `company` (region, `unit_system`, `regulation_profile`, `timezone`). Ilova bu javobsiz render qilinmaydi (to'liq ekranli splash + skeleton).

## 5. `Idempotency-Key` **[MUST]**

- Swagger'da `Idempotency-Key` header'i belgilangan **har bir** `POST` operatsiyasida yuboriladi.
- Qiymat — `crypto.randomUUID()`, **forma sessiyasi boshida bir marta** generatsiya qilinadi, qayta urinishlarda o'zgarmaydi. Muvaffaqiyatli javobdan keyin kalit tashlanadi.
- Kalit `useIdempotencyKey()` hook orqali beriladi; forma `reset()` qilinganda yangilanadi. Mutation `retry: false` (TanStack Query) — takroriy yuborishni faqat foydalanuvchi boshlaydi.

## 6. Xato formati va normalizatsiya **[MUST]**

Backend yagona konvert qaytaradi:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "validation failed",
    "details": [{ "field": "unit_number", "message": "required" }]
  }
}
```

`lib/errors.ts` da `normalizeError(response)` → `{ code, message, fields: Record<string,string> }`.

| `code`                  | HTTP    | UI xatti-harakati                                                                                                                         |
| ----------------------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `VALIDATION_ERROR`      | 400/422 | `details[]` → `setError(field, {message})` react-hook-form'ga; maydon ostida qizil matn. Noma'lum `field` → forma tepasidagi umumiy alert |
| `UNAUTHORIZED`          | 401     | §4 refresh oqimi                                                                                                                          |
| `FORBIDDEN`             | 403     | Sahifa: «You do not have permission to view this page» + orqaga tugma. Amal: toast, tugma qayta faollashadi                               |
| `NOT_FOUND`             | 404     | «Not found» ekrani. Cross-tenant so'rov ham 404 qaytaradi — UI farq qilmaydi                                                              |
| `CONFLICT`              | 409     | Toast + ro'yxatni invalidatsiya qilish. Formada: «This record changed. Reload?»                                                           |
| `RATE_LIMITED`          | 429     | Toast + `Retry-After` bo'yicha countdown, tugma vaqtincha `disabled`                                                                      |
| `SUBSCRIPTION_READONLY` | 403     | Global banner qayta ko'rsatiladi                                                                                                          |
| `INTERNAL` / 5xx        | 500+    | ErrorState komponenti + «Try again» + `trace_id` (bo'lsa) nusxa olish tugmasi                                                             |
| Tarmoq xatosi           | —       | «You appear to be offline» banner; TanStack Query `retry: 2` (faqat GET)                                                                  |

Xom `error.message` (ingliz, backenddan) foydalanuvchiga to'g'ridan-to'g'ri ko'rsatilmaydi, agar `code` uchun i18n kaliti mavjud bo'lsa. Kalit yo'q bo'lsa — fallback sifatida `message` ko'rsatiladi va `console.warn` bilan qayd etiladi.

## 7. Pagination, saralash, filtrlash **[MUST]**

Ro'yxat javobi:

```json
{ "data": [ … ], "meta": { "page": 1, "per_page": 25, "total": 123 } }
```

- `per_page` faqat `10 | 25 | 50` — boshqa qiymat backendda **422**. Default — **25**. Tip: `PerPage` union (`src/api/types.ts`), ro'yxat: `PER_PAGE_OPTIONS`.
- Sahifa/`per_page`/saralash/filtrlar **URL query-string'da**: `?page=2&per_page=25&sort=unit_number&order=asc&status=active&search=101`. `useListParams()` hook (`useSearchParams` ustida) — barcha ro'yxat ekranlarida bir xil.
- `search` — **400ms debounce**, `page=1` ga qaytaradi. Bo'sh qatorda parametr yuborilmaydi.
- `sort`/`order` faqat spec'da `enum` bilan ruxsat etilgan qiymatlar (masalan `GET /units`: `unit_number|status|make|year|created_at`). Jadval sarlavhasi faqat shu ustunlarda bosiladigan.
- Kursorli ro'yxatlar (`GET /chat/threads/{driver_id}/messages` — `before` + `limit`) uchun "Load older" tugmasi / yuqoriga scroll pattern.
- [SHOULD] TanStack Query `staleTime`: ro'yxatlar 30s, `GET /me`/`GET /permissions` 10 daq, `GET /dashboard/summary` 0 (WS bilan yangilanadi). `placeholderData: keepPreviousData` — sahifa almashganda jadval "sakramaydi".

## 8. Fayl yuklash — presign oqimi **[MUST]**

```
1. POST /files/presign {kind, content_type, size_bytes, filename}   ← files.upload
     → {upload_url, method:"PUT", key, headers{}, max_bytes, expires_at}
2. PUT <upload_url>  (Content-Type va Content-Length AYNAN mos)
3. Domen endpointiga `key` yuboriladi (masalan DVIR repair invoice, chat xabari, company logo)
```

- `size_bytes` — haqiqiy fayl hajmi; `Content-Length` sifatida URL'ga imzolanadi, mos kelmasa storage `PUT`ni rad etadi. Fayl tanlangandan keyin (`File.size`) presign so'raladi, undan oldin emas.
- Yuklash `XMLHttpRequest` bilan (progress event uchun; `fetch` upload progress bermaydi) — F13 istisnosi.
- `expires_at` o'tib ketsa — presign qayta so'raladi, yuklash qaytadan boshlanadi (maks. 2 urinish).

### `kind` oq ro'yxati va cheklovlar (TO'LIQ jadval)

| `kind`       | Qayerda                                | MIME                                         | Maks. hajm     |
| ------------ | -------------------------------------- | -------------------------------------------- | -------------- |
| `dvir_photo` | DVIR nuqson fotosi (ko'rish)           | `image/jpeg`, `image/png`                    | 5 MB, ≤ 5 dona |
| `invoice`    | Maintenance complete, DVIR repair      | `application/pdf`, `image/jpeg`, `image/png` | 10 MB          |
| `signature`  | Imzo (faqat ko'rish, admin yaratmaydi) | `image/png`                                  | 1 MB           |
| `logo`       | Settings › Company                     | `image/png`, `image/jpeg`, `image/svg+xml`   | 2 MB           |
| `chat`       | Chat biriktirmasi                      | `image/*`, `application/pdf`                 | 10 MB          |
| `import`     | Units/Drivers import                   | `text/csv`, `.xlsx`                          | 10 MB          |

- `kind` — backend enum'i; boshqa qiymat yuborilmaydi. Klient tomonda MIME **va** kengaytma tekshiriladi; haqiqiy chegara `max_bytes` javobdan olinadi va UI'da ko'rsatiladi.
- SVG logotip `<img src>` sifatida ko'rsatiladi, **hech qachon inline** (`dangerouslySetInnerHTML`) qilinmaydi — SVG ichida skript bo'lishi mumkin.
- `FileUpload` komponenti: drag&drop zonasi, tanlangan fayl nomi+hajmi, progress bar (%), `Cancel` (`xhr.abort()`), xato holati (hajm/MIME/tarmoq) aniq matn bilan.

### Yuklab olish

- PDF va eksport fayllari `Authorization` header talab qiladi → oddiy `<a href>` ishlamaydi. Oqim: `fetch` → `blob` → `URL.createObjectURL` → dasturiy `<a download>` → `revokeObjectURL`. Yuklab olish davomida tugma `loading`. Katta fayllarda (≥20 MB) progress ko'rsatiladi.
- `export_job.download_url` — presigned, `Authorization` talab qilmaydi → to'g'ridan-to'g'ri `<a href target="_blank" rel="noopener">`.

## 9. Hisobotlar va eksport **[MUST]**

Ikki xil eksport:

| Tur      | Endpoint                                                                                             | UI                                                      |
| -------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| Sinxron  | `GET /units/export`, `GET /drivers/export`, `GET /daily-logs/{id}/pdf`, `GET /dvir-reports/{id}/pdf` | tugma → spinner → fayl yuklab olinadi (§8 yuklab olish) |
| Asinxron | `POST /reports/export-jobs`                                                                          | job polling oqimi (quyida)                              |

**Asinxron oqim:**

```
POST /reports/export-jobs {type, format, params}   ← reports.export, Idempotency-Key
   → 202 { id, status: "queued" }
   → toast: «Your export is being prepared. We'll notify you when it's ready.»
GET /reports/export-jobs/{id}   ← polling: 2s → 5s → 10s (maks. 5 daqiqa)
   ├─ running  → progress ko'rsatiladi
   ├─ done     → download_url (presigned, expires_at) + toast + bildirishnoma
   └─ failed   → error matni + «Try again»
```

- Polling 5 daqiqadan oshsa to'xtaydi, `/reports/exports` sahifasi taklif qilinadi — job fonda davom etadi, tayyor bo'lganda bildirishnoma keladi (`notifications` kanali).
- `download_url` **24 soat** amal qiladi. Ro'yxatda muddati o'tgan job'da `Download` o'rniga «Link expired — re-run export» tugmasi.
- Ochiq (`queued`/`running`) job bor ekan — o'sha `type` + bir xil `params` bilan yangi so'rov yuborilmaydi; tugma `disabled` + «An export with these parameters is already running».
- Eksport `audit_log`ga tushadi (kim nimani yuklab oldi) — UI sezgir hisobotlarda buni ogohlantirish sifatida ko'rsatadi.

**Formatlar:**

| `type`               | Ruxsat etilgan `format` | Default                    |
| -------------------- | ----------------------- | -------------------------- |
| `distance_by_region` | `csv`, `xlsx`, `pdf`    | `xlsx`                     |
| `regulator`          | `pdf`, `csv`, `zip`     | `zip` (`generic`: PDF+CSV) |
| `activity`           | `csv`, `xlsx`, `pdf`    | `csv`                      |
| `hos`                | `csv`, `pdf`            | `pdf`                      |
| `dvir`               | `csv`, `xlsx`, `pdf`    | `pdf`                      |

- Format tanlovi `POST` javobidagi xatolar bilan tekshiriladi; UI faqat yuqoridagi kombinatsiyalarni taklif qiladi.
- `Print` tugmasi (Activity Report'da) — brauzer `window.print()` + `@media print` stillari (nav, filtrlar, tugmalar yashiriladi; jadval to'liq, sahifa sarlavhasi va sana oralig'i ko'rinadi).

## To'liq manba

`docs/tz-admin-frontend.md`:

- §1.3 Backend holati — qatorlar 52–66
- §3 API integratsiyasi (3.1–3.6) — qatorlar 185–310
- §10 Fayllar, §11 Hisobotlar va eksport — qatorlar 1464–1541
