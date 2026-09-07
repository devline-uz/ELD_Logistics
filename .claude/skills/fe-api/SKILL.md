---
name: fe-api
description: ELD Admin Panel frontendida API klient, autentifikatsiya (login/refresh/logout), xato normalizatsiyasi, pagination/filtrlash, fayl yuklash (presign) va hisobot eksporti bilan ishlaydigan kodni yozish yoki ko'rib chiqishda ishlatiladi.
---

# fe-api — ELD Admin Panel API integratsiyasi

Ushbu skill `docs/tz-admin-frontend.md` §1.3, §3, §10, §11 ning siqilgan bilimi. Maqsad — TZ ni qayta o'qimasdan API integratsiyasi bo'yicha to'g'ri qaror qabul qilish.

## 1. Backend manzillari **[MUST]**

| Nima | Qiymat |
|---|---|
| Bazaviy URL (prod) | `https://eldapi.stackyard.uz/api/v1` |
| Swagger UI | `https://eldapi.stackyard.uz/api/docs/index.html` (`Authorization: Bearer <DOCS_TOKEN>`) |
| Xom spec | `GET /api/docs/swagger.json` — klient generatsiyasining **yagona manbai** |
| WebSocket | `wss://eldapi.stackyard.uz/api/v1/ws` (Swagger'da yo'q, `backend/docs/websocket.md` ga qarang) |
| Admin panel domeni | `https://eldadmin.stackyard.uz` |
| API versiyasi | `v1` — **muzlatilgan**. Yangi endpoint kerak bo'lsa CR orqali `tz.md` o'zgaradi, keyin backend |

Qoida: backend — haqiqat manbai. Dizayn/backend to'qnashsa backend ustun (farq §16 reestriga yoziladi). Frontend backendni "to'g'rilash" uchun work-around yozmaydi — yetishmagan endpoint §17 ochiq savol sifatida chiqadi.

## 2. Klient generatsiyasi **[MUST]**

```jsonc
// package.json scripts
"api:fetch": "curl -fsSL -H \"Authorization: Bearer $DOCS_TOKEN\" $VITE_API_DOCS_URL/swagger.json -o openapi/swagger.json",
"api:gen":   "openapi-typescript openapi/swagger.json -o src/api/schema.d.ts",
"api":       "npm run api:fetch && npm run api:gen && npm run lint:fix"
```

- `src/api/schema.d.ts` — **generatsiya natijasi**, qo'lda tahrirlanmaydi (`// @generated` banneri, ESLint `ignorePatterns`). Repoga commit qilinadi, `openapi/swagger.json` snapshot bilan birga.
- CI: `npm run api:gen && git diff --exit-code src/api/schema.d.ts` — spec o'zgargan bo'lsa build yiqiladi.
- Domen tiplari faqat alias orqali (`src/api/types.ts`):

```ts
import type { components, paths } from './schema';
type Schemas = components['schemas'];
export type Unit   = Schemas['github_com_devline_onebook-eld_internal_domain_fleet_dto.Unit'];
export type Driver = Schemas['github_com_devline_onebook-eld_internal_domain_drivers_dto.Driver'];
export type ListMeta = Schemas['github_com_devline_onebook-eld_internal_domain_auth_dto.Meta'];
```
Go paket prefiksli uzun nomlar komponentlarda hech qachon ko'rinmaydi.

## 3. Klient va 4 middleware **[MUST]**

```ts
// src/api/client.ts
const api = createClient<paths>({ baseUrl: import.meta.env.VITE_API_BASE_URL });
api.use(authMiddleware);        // Authorization: Bearer <access>
api.use(companyMiddleware);     // X-Company-Id — faqat super_admin rejimida
api.use(idempotencyMiddleware); // POST uchun Idempotency-Key
api.use(errorMiddleware);       // xatoni normalizatsiya qiladi (§5)
```

Barcha so'rovlar `openapi-fetch` orqali; `fetch`/`axios` bevosita chaqirilmaydi. Yagona istisnolar: presigned URL'ga fayl `PUT` (§6) va PDF/eksport `blob` yuklab olish (§7).

## 4. Autentifikatsiya oqimi **[MUST]**

```
POST /auth/login {username|email, password, device_type:"web", device_id}
   → 200 { access_token, expires_in: 900, refresh_token, refresh_expires_at,
           token_type:"Bearer", session_id, user,
           requires_totp_setup, replaced_session, subscription_readonly }
```

| Holat | UI reaksiyasi |
|---|---|
| `requires_totp_setup: true` | `refresh_token` bo'sh, token cheklangan — faqat `/auth/2fa/setup` va `/auth/2fa/verify`. UI majburan 2FA enrolment ekraniga o'tadi |
| `replaced_session: true` | Toast: «Another web session was signed out» (1 web + 1 telefon + 1 planshet siyosati) |
| `subscription_readonly: true` | Global qizil-sariq banner + barcha yozuv amallari `disabled` (tooltip: obuna muddati tugagan) |
| `403 ACCOUNT_INACTIVE` | Login ekranida xato matni, qayta urinish bloklanmaydi |

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
{ "error": { "code": "VALIDATION_ERROR", "message": "validation failed",
             "details": [ {"field": "unit_number", "message": "required"} ] } }
```
`lib/errors.ts` da `normalizeError(response)` → `{ code, message, fields: Record<string,string> }`.

| `code` | HTTP | UI xatti-harakati |
|---|---|---|
| `VALIDATION_ERROR` | 400/422 | `details[]` → `setError(field, {message})` react-hook-form'ga; maydon ostida qizil matn. Noma'lum `field` → forma tepasidagi umumiy alert |
| `UNAUTHORIZED` | 401 | §4 refresh oqimi |
| `FORBIDDEN` | 403 | Sahifa: «You do not have permission to view this page» + orqaga tugma. Amal: toast, tugma qayta faollashadi |
| `NOT_FOUND` | 404 | «Not found» ekrani. Cross-tenant so'rov ham 404 qaytaradi — UI farq qilmaydi |
| `CONFLICT` | 409 | Toast + ro'yxatni invalidatsiya qilish. Formada: «This record changed. Reload?» |
| `RATE_LIMITED` | 429 | Toast + `Retry-After` bo'yicha countdown, tugma vaqtincha `disabled` |
| `SUBSCRIPTION_READONLY` | 403 | Global banner qayta ko'rsatiladi |
| `INTERNAL` / 5xx | 500+ | ErrorState komponenti + «Try again» + `trace_id` (bo'lsa) nusxa olish tugmasi |
| Tarmoq xatosi | — | «You appear to be offline» banner; TanStack Query `retry: 2` (faqat GET) |

Xom `error.message` (ingliz, backenddan) foydalanuvchiga to'g'ridan-to'g'ri ko'rsatilmaydi, agar `code` uchun i18n kaliti mavjud bo'lsa. Kalit yo'q bo'lsa — fallback sifatida `message` ko'rsatiladi va `console.warn` bilan qayd etiladi.

## 7. Pagination, saralash, filtrlash **[MUST]**

Ro'yxat javobi:
```json
{ "data": [ … ], "meta": { "page": 1, "per_page": 25, "total": 123 } }
```

- `per_page` faqat `10 | 25 | 50`. Boshqa qiymat yuborilmaydi. Default — **25**.
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

| `kind` | Qayerda | MIME | Maks. hajm |
|---|---|---|---|
| `dvir_photo` | DVIR nuqson fotosi (ko'rish) | `image/jpeg`, `image/png` | 5 MB, ≤ 5 dona |
| `invoice` | Maintenance complete, DVIR repair | `application/pdf`, `image/jpeg`, `image/png` | 10 MB |
| `signature` | Imzo (faqat ko'rish, admin yaratmaydi) | `image/png` | 1 MB |
| `logo` | Settings › Company | `image/png`, `image/jpeg`, `image/svg+xml` | 2 MB |
| `chat` | Chat biriktirmasi | `image/*`, `application/pdf` | 10 MB |
| `import` | Units/Drivers import | `text/csv`, `.xlsx` | 10 MB |

- `kind` — backend enum'i; boshqa qiymat yuborilmaydi. Klient tomonda MIME **va** kengaytma tekshiriladi; haqiqiy chegara `max_bytes` javobdan olinadi va UI'da ko'rsatiladi.
- SVG logotip `<img src>` sifatida ko'rsatiladi, **hech qachon inline** (`dangerouslySetInnerHTML`) qilinmaydi — SVG ichida skript bo'lishi mumkin.
- `FileUpload` komponenti: drag&drop zonasi, tanlangan fayl nomi+hajmi, progress bar (%), `Cancel` (`xhr.abort()`), xato holati (hajm/MIME/tarmoq) aniq matn bilan.

### Yuklab olish

- PDF va eksport fayllari `Authorization` header talab qiladi → oddiy `<a href>` ishlamaydi. Oqim: `fetch` → `blob` → `URL.createObjectURL` → dasturiy `<a download>` → `revokeObjectURL`. Yuklab olish davomida tugma `loading`. Katta fayllarda (≥20 MB) progress ko'rsatiladi.
- `export_job.download_url` — presigned, `Authorization` talab qilmaydi → to'g'ridan-to'g'ri `<a href target="_blank" rel="noopener">`.

## 9. Hisobotlar va eksport **[MUST]**

Ikki xil eksport:

| Tur | Endpoint | UI |
|---|---|---|
| Sinxron | `GET /units/export`, `GET /drivers/export`, `GET /daily-logs/{id}/pdf`, `GET /dvir-reports/{id}/pdf` | tugma → spinner → fayl yuklab olinadi (§8 yuklab olish) |
| Asinxron | `POST /reports/export-jobs` | job polling oqimi (quyida) |

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

| `type` | Ruxsat etilgan `format` | Default |
|---|---|---|
| `distance_by_region` | `csv`, `xlsx`, `pdf` | `xlsx` |
| `regulator` | `pdf`, `csv`, `zip` | `zip` (`generic`: PDF+CSV) |
| `activity` | `csv`, `xlsx`, `pdf` | `csv` |
| `hos` | `csv`, `pdf` | `pdf` |
| `dvir` | `csv`, `xlsx`, `pdf` | `pdf` |

- Format tanlovi `POST` javobidagi xatolar bilan tekshiriladi; UI faqat yuqoridagi kombinatsiyalarni taklif qiladi.
- `Print` tugmasi (Activity Report'da) — brauzer `window.print()` + `@media print` stillari (nav, filtrlar, tugmalar yashiriladi; jadval to'liq, sahifa sarlavhasi va sana oralig'i ko'rinadi).

## To'liq manba

`docs/tz-admin-frontend.md`:
- §1.3 Backend holati — qatorlar 52–66
- §3 API integratsiyasi (3.1–3.6) — qatorlar 185–310
- §10 Fayllar, §11 Hisobotlar va eksport — qatorlar 1464–1541
