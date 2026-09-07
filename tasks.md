# ELD Admin Panel — Vazifalar reestri

Manba: `docs/tz-admin-frontend.md` §18.2. Har bosqich alohida branch (`feat/stage-<n>-<nom>`).
Belgilash: `[ ]` bajarilmagan · `[~]` jarayonda · `[x]` bajarilgan (DoD §18.4 bo'yicha yopilgan).

## Bosqich -1 — Tayyorgarlik (infratuzilma)

- [x] -1.1 `docs/tz-admin-frontend.md` repozitoriyga ko'chirildi
- [x] -1.2 §7 modul bo'yicha `docs/tz/*.md` ga bo'lindi (agent kontekstini tejash uchun)
- [x] -1.3 `.claude/skills/fe-*` — 10 ta skill yaratildi
- [x] -1.4 `.claude/agents/*` — 11 ta subagent yaratildi
- [x] -1.5 `tasks.md` yuritish tartibi kelishildi
- [x] -1.6 `DOCS_TOKEN` olindi; `admin/openapi/swagger.json` (Swagger 2.0, 125 path) commit qilindi
- [x] -1.7 `docs/api/permissions.md` — 104 kalit `x-permission` dan generatsiya qilindi (`scripts/gen-permissions-doc.py`)

## 18.2 Bosqichlar

### Bosqich 0 — Karkas va autentifikatsiya
**Qamrov:** loyiha skeleti, API klienti, auth oqimi, layout, router, permission tizimi.
**Bog'liqlik:** yo'q.
**Agentlar:** `fe-architect` (asosiy), `api-integration` (klient), `frontend-security-reviewer` + `frontend-code-reviewer` (oxirida).
**Chiqish mezoni:** login qilib bo'ladi, `/` da bo'sh layout va haqiqiy nav ko'rinadi (ruxsatlar bo'yicha), 401 da avtomatik refresh ishlaydi, logout ishlaydi, 4 tekshiruv yashil.

```markdown
- [x] 0.1 `admin/` papkasi, Vite + React 18 + TS strict, `npm create vite`
- [x] 0.2 Tailwind 3.4 o'rnatish, `tailwind.config.ts` bo'sh token skeleti
- [x] 0.3 ESLint 9 flat config + Prettier + `jsx-a11y` + `no-restricted-imports` (features kesishmasi)
- [x] 0.4 `tsconfig` paths (`@/*`) + Vite alias
- [x] 0.5 `package.json` skriptlari: `dev build preview typecheck lint lint:fix test test:cov e2e api api:gen i18n:extract`
- [x] 0.6 `.env.example`, `README.md` (ishga tushirish yo'riqnomasi)
- [x] 0.7 `npm run api` — 3 bosqichli oqim: fetch → convert (Swagger 2.0 → OAS3) → gen. `openapi/{swagger,openapi3}.json` va `schema.d.ts` (19854 qator) commit qilindi
- [x] 0.8 `src/api/types.ts` — 165 schema-backed alias, 30+ domen. `Dto<>` helper nom spec'da yo'q bo'lsa kompilyatsiya xatosi beradi
- [x] 0.9 `src/api/client.ts` — `openapi-fetch` + 4 middleware (auth, company, idempotency, error)
- [x] 0.10 `src/lib/errors.ts` — `normalizeError`, kod → i18n kaliti xaritasi
- [x] 0.11 `src/features/auth/` — LoginPage, 2FA setup/verify, forgot/reset password, invitation accept + `AuthLayout` + zod sxemalari
- [x] 0.12 Auth store (Zustand): access token **faqat xotirada**, refresh `sessionStorage` (`eld.rt`) da
- [x] 0.13 Refresh mutex (single-flight) + proaktiv 80% TTL + reaktiv 401→refresh→retry; reuse → to'liq logout; refresh 401 halqasi yo'q (5 test)
- [x] 0.14 `GET /app/config` bootstrap: soat siljishi, feature flags (`BootstrapGate`)
- [x] 0.15 `GET /me` — profil → ruxsatlar `PermissionsProvider` ga, company → company store
- [x] 0.16 `src/lib/permissions.ts` — **104 haqiqiy kalit** (TZ dagi 105 noto'g'ri), 28 guruh + `usePermission()` + `PermissionGate`
- [x] 0.17 `permissions.catalog.test.ts` — `swagger.json` dagi `x-permission` bilan ikki tomonlama solishtirish (8 test), OR istisnolari hujjatlashtirildi
- [x] 0.18 `AppLayout` — 3 qatlamli header (brend + nav + breadcrumb), profil menyusi
- [x] 0.19 Nav va flyout'lar ruxsat bo'yicha filtrlanadi (§4.5 jadvali)
- [x] 0.20 `router.tsx` — barcha marshrutlar lazy (modul bo'yicha `app/router/*.routes.tsx`), `RouteGuard`, 403/404/ErrorBoundary ekranlari
- [x] 0.21 i18n sozlash + `en.json` skeleti (`common.*`, `errors.*`, `nav.*`, `enums.*`)
- [x] 0.22 Idle timeout (30 daq) + `subscription_readonly` banneri + `replaced_session` toast
- [x] 0.23 GitHub Actions: typecheck, lint, test, build, `schema.d.ts` diff tekshiruvi (`DOCS_TOKEN` bo'lmasa diff qadami o'tkazib yuboriladi)
- [x] 0.24 `frontend-security-reviewer` (kritik 0) + `frontend-code-reviewer` (qatlam buzilishi 0, dublikat 0)
```

### Bosqich 1 — Dizayn tizimi va komponent kutubxonasi
**Qamrov:** §5 tokenlari + §5.6 dagi 30+ komponent + §6 patternlari.
**Bog'liqlik:** Bosqich 0.
**Agentlar:** `ui-component-builder` (asosiy), `a11y-reviewer`, `frontend-test-engineer`.
**Chiqish mezoni:** har komponent testi bor, `components/ui/` qamrovi ≥ 90 %, `axe` kritik xato 0, hech qanday hardcode hex/px/string yo'q.

```markdown
- [x] 1.1 `tailwind.config.ts` — ranglar (CSS o'zgaruvchilar orqali), tipografika, spacing, radius, soyalar
- [x] 1.2 Shriftlar lokal `woff2` (IBM Plex Sans; Product Sans yoki fallback)
- [x] 1.3 `lucide-react` o'rnatish, `Icon` wrapper
- [x] 1.4 Primitivlar: Button, IconButton, Input, Textarea, Select, MultiSelect, Checkbox, Radio, Switch
- [x] 1.5 Sana/vaqt: DatePicker, DateRangePicker (presetlar bilan), TimePicker
- [x] 1.6 Overlay: Modal (focus trap), ConfirmDialog, Drawer, Tooltip, Toast provayderi
- [x] 1.7 Ko'rsatish: Badge, StatusChip, Avatar, Card, KpiCard, Breadcrumb, Tabs
- [x] 1.8 Holatlar: EmptyState, ErrorState, Skeleton, Spinner, `useDelayedLoading`
- [x] 1.9 `DataTable` — saralash, ustun ko'rsatish/yashirish (`localStorage`), sticky birinchi ustun, `overflow-x`
- [x] 1.10 `Pagination` (10/25/50) + `useListParams` (URL query-string sinxronizatsiyasi)
- [x] 1.11 `FiltersBar` — qidiruv (400 ms debounce), select filtrlar, faol filtr badge'i, `Clear all`
- [x] 1.12 `FormField` oilasi — react-hook-form + zod integratsiyasi, server xatolarini bog'lash
- [x] 1.13 `FileUpload` — presign oqimi, progress (XHR), MIME/hajm tekshiruvi
- [x] 1.14 `lib/format.ts` (sana/vaqt/davomiylik/nisbiy) + `lib/units.ts` (SI ↔ imperial) + testlari
- [x] 1.15 `ListScreen` shabloni — §6.1 tuzilmasini beruvchi kompozitsiya
- [x] 1.16 Har komponent uchun Vitest testi (render + interaksiya + rol)
- [x] 1.17 `a11y-reviewer`: axe kritik 0 (34 test), 2 kritik + 2 yuqori tuzatildi, `error-base` matn kontrasti -> `error-dark`
- [x] 1.18 `frontend-code-reviewer`: `components/ui/` qamrovi 93.65%, auth dublikatlari tozalandi, `Alert` umumiy primitivga chiqarildi
```

### Bosqich 2 — Fleet moduli
**Qamrov:** Units, Drivers, ELD devices, Trailers, Shipping documents, Users, Roles (§7.3), import/export.
**Bog'liqlik:** 0, 1.
**Agentlar:** `api-integration` (queries) → `screen-implementer` ×2 **parallel** (A: units+eld+trailers+docs · B: drivers+users+roles) → `frontend-test-engineer` → ko'riklar.
**Fayl egaligi:** A → `features/fleet/units/`, `features/fleet/eld/`, `features/fleet/trailers/`, `features/fleet/documents/`; B → `features/fleet/drivers/`, `features/fleet/users/`, `features/fleet/roles/`. `api/queries/` — bosqich boshida `api-integration` tomonidan **to'liq yoziladi**, keyin faqat o'qiladi.
**Chiqish mezoni:** 7 ekranda CRUD to'liq ishlaydi, permission testlari o'tadi, import xato hisoboti ko'rinadi, license reveal audit bilan.

```markdown
- [x] 2.1 `api/queries/units.ts`, `drivers.ts`, `eldDevices.ts`, `trailers.ts`, `shippingDocuments.ts`, `users.ts`, `roles.ts`, `permissions.ts`
- [x] 2.2 Unit: ro'yxat (tablar, filtrlar, saralash, ustun tanlash) + Add/Edit modal + View + Activities + Diagnostics
- [x] 2.3 Unit import/export (shablon yuklab olish, all-or-nothing xato jadvali)
- [x] 2.4 Driver: ro'yxat + Add/Edit + View (Information/Activities/Daily logs) + co-driver boshqaruvi
- [x] 2.5 Driver: `Send password reset` (dizayndagi parol modali o'rniga) + license reveal (30 s, audit)
- [x] 2.6 ELD devices CRUD + `assign-unit` 🎨
- [x] 2.7 Trailers, Shipping documents CRUD 🎨
- [x] 2.8 Users: ro'yxat + invite + edit + activate/deactivate + resend invitation + reset password
- [x] 2.9 Roles: ro'yxat + Add/Edit (105 kalit, 26 guruh, `scope` tanlovi) + system rol himoyasi + 409 ishlovi
- [x] 2.10 Barcha formalarda `Password` maydoni yo'qligi tekshiriladi (D2)
- [x] 2.11 Integratsiya testlari (MSW): har modul uchun ro'yxat + filtr + forma + xato + permission
- [x] 2.12 `frontend-security-reviewer` (kritik 0; license reveal va mass-assignment toza) + `frontend-code-reviewer` (dublikat 0, qatlam buzilishi 0)
```

### Bosqich 3 — Logs va HOS
**Qamrov:** Logs By Unit / By Driver, Log view (3 tab + grid), Log edit requests, Unassigned driving, Violations (§7.4).
**Bog'liqlik:** 0, 1, 2 (driver/unit select'lari).
**Agentlar:** `screen-implementer` (asosiy), `ui-component-builder` (24 soatlik SVG grid), `frontend-test-engineer`.
**Chiqish mezoni:** grid to'g'ri chiziladi (golden snapshot testi), **log edit request oqimi** to'liq ishlaydi va hech qanday to'g'ridan-to'g'ri tahrir yo'q, HOS raqamlari faqat backenddan.

```markdown
- [x] 3.1 `api/queries/logs.ts`, `hos.ts`, `violations.ts`, `logEditRequests.ts`, `unidentified.ts`
- [x] 3.2 Logs By Unit — `tracking/live` + shartli `hos-summary` kompozitsiyasi (concurrency ≤ 6, kesh 60 s)
- [x] 3.3 Logs By Driver — driver select + sana oralig'i + `daily-logs`
- [x] 3.4 `HosRings` komponenti — 4 halqa, qiymatlar `hos-summary` dan, hech qanday hardcode chegara
- [x] 3.5 `DutyGrid` — 24 soatlik SVG grid, PC/YM shtrixi, hodisa markerlari (`pti/fuel/certify/malfunction`), tooltip
- [x] 3.6 Voqealar jadvali — `origin` ustuni, `✎` belgisi + asl qiymat tooltip'i
- [x] 3.7 Log Form bloki — trailers/docs badge'lari, imzo (faqat ko'rish)
- [x] 3.8 **`Send edit request` paneli** — status tugmalari, From/To/Note, Q17.1 taqiqlari UI'da bloklangan
- [x] 3.9 Report tabi — PDF ko'rish + download (blob, `Authorization`)
- [x] 3.10 Trip Planner tabi — xarita joy egallaydi (to'liq 4-bosqichda), segmentlar ro'yxati, `Create route` formasi
- [x] 3.11 Log Edit Requests ekrani — approve/reject (sabab majburiy), o'z taklifini tasdiqlash bloklangan 🎨
- [x] 3.12 Unassigned Driving ekrani — assign / annotate, 8 kun qoidasi 🎨
- [x] 3.13 Violations ro'yxati + detal, `resolved` badge, delete yo'q
- [x] 3.14 Golden testlar: grid render (snapshot), HOS format, violation matnlari
- [x] 3.15 `frontend-security-reviewer` (kritik 0; F100/Q17.1/F103 tasdiqlandi) + `frontend-code-reviewer` (PDF blob leak va o'lik qidiruv tuzatildi)
```

### Bosqich 4 — Tracking va xarita
**Qamrov:** Tracking ro'yxati, Track on Map, Routes, Dashboard xaritasi, Trip Planner xaritasi (§7.7, §9).
**Bog'liqlik:** 0, 1, 3 (Trip Planner), **Q1 (tile provayderi) hal bo'lishi shart**.
**Agentlar:** `map-engineer` (asosiy), `realtime-engineer` (WS tracking), `screen-implementer`.
**Chiqish mezoni:** 500 marker bilan xarita ≥ 30 fps, WS yangilanishi ≤ 5 s, xarita chunk lazy va ≤ 400 KB.

```markdown
- [x] 4.1 ✅ Q1 hal qilindi — **MapTiler Cloud** (MVP), chiqish yo'li Protomaps/PMTiles. Qaror: `docs/tz/16-17-registry-open-questions.md` → D-Q1. Qoladi: buyurtmachidan domen bo'yicha cheklangan kalit → `VITE_MAP_STYLE_URL`
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

---

## Bosqich holati

| Bosqich | Nomi | Holat | Branch |
|---|---|---|---|
| -1 | Tayyorgarlik | ✅ | `main` |
| 0 | Karkas va autentifikatsiya | ✅ | `feat/stage-0-skeleton` |
| 1 | Dizayn tizimi | ✅ | `feat/stage-0-skeleton` |
| 2 | Fleet moduli | ✅ | `feat/stage-2-fleet` |
| 3 | Logs va HOS | ✅ | `feat/stage-3-logs` |
| 4 | Tracking va xarita | 🔄 jarayonda | `feat/stage-4-tracking` |
| 5 | DVIR va Maintenance | ⬜ | `feat/stage-5-dvir-maintenance` |
| 6 | Reports va eksport | ⬜ | `feat/stage-6-reports` |
| 7 | Real-vaqt, Chat, Dashboard | ⬜ | `feat/stage-7-realtime` |
| 8 | Settings, Support, Audit | ⬜ | `feat/stage-8-settings` |
| 9 | Sayqal va deploy | ⬜ | `feat/stage-9-polish` |


---

## Texnik qarz (bosqich oxirida hal qilinadi)

- [ ] TD1 `features/logs/lib/tripPlannerApi.ts` → `api/queries/routes.ts` ga ko'chirish
      (qatlam buzilishi — tasdiqlangan; `map-engineer` `routes.ts` ni tugatgach mexanik ko'chirish)
- [ ] TD2 `batchSettled<T,R>(items, fn, concurrency)` yordamchisini `lib/` ga chiqarish
      (`api/queries/hos.ts` va `features/logs/lib/hosByDate.ts` da chunking algoritmi takrorlangan)
- [ ] TD3 Qidiruv faqat joriy sahifada ishlashini UI'da ko'rsatish
      (`LogsByUnitPage`, `ViolationsPage`, `UnassignedDrivingPage` — backend `search` parametri yo'q,
      lekin pagination `total` filtrlanmagan holda keladi → foydalanuvchi chalg'ishi mumkin)
- [ ] TD4 `ConfirmDialog` da sabab uzunligi (3–500) tekshirilmaydi — faqat bo'sh emasligi
      (13 ekran ishlatadi; backend yakuniy hakam, lekin klient tekshiruvi foydali)
