# ONEBOOK ELD — Backend ish rejasi (Go)

**Manba:** `tz.md` v2.2 · **Qamrov:** faqat backend · **Papka:** `backend/`
**Bajarish tartibi:** har vazifa subagent orqali; `[x]` = tugadi va tekshirildi, `[~]` = jarayonda, `[ ]` = boshlanmagan.
**Har bosqich oxirida majburiy:** `eld-security-auditor` + `eld-code-reviewer` + `go build ./... && go vet ./... && go test ./...` yashil.

Holat belgilari: ✅ tugadi · 🔄 jarayonda · ⏳ navbatda

---

## Bosqich 0 — Fundament ✅

### 0.1 Loyiha karkasi — `eld-go-architect` ✅
- [x] `go.mod` + stack kutubxonalari (chi, pgx, goose, asynq, swaggo, ...)
- [x] `internal/config` — env config + validatsiya
- [x] `internal/apierr` — xato kodlari bitta const blokida + `E` tipi
- [x] `internal/httpx` — WriteJSON/WriteError, DecodeAndValidate, pagination, PII mask
- [x] `internal/tenant` — Principal, kontekst helperlari
- [x] `internal/db` — pgxpool, `WithTx` + `SET LOCAL app.company_id`
- [x] `internal/middleware` — RequestID, Logger, Recover, SecurityHeaders, BodyLimit, CORS
- [x] `internal/audit` — Recorder interfeysi + pgx implementatsiyasi
- [x] `internal/server` — Module interfeysi, NewRouter
- [x] `cmd/api`, `cmd/worker`, `cmd/migrate`
- [x] `deploy/` (Dockerfile, docker-compose), `.github/workflows/ci.yml`, `Makefile`, `.golangci.yml`
- [x] `go build ./... && go vet ./...` xatosiz

### 0.2 DB sxemasi va migratsiyalar — `eld-db-engineer` ✅
- [x] 00001 extensions (pgcrypto, postgis, timescaledb) + `set_updated_at()`
- [x] 00002 companies, hos_policy_versions, branches, system_settings
- [x] 00003 users, roles, role_permissions, sessions, invitations
- [x] 00004 drivers, driver_pairs, signatures, units, eld_devices, assignments, trailers, shipping_documents
- [x] 00005 duty_status_events, daily_logs, log_edit_requests, unidentified_events, violations
- [x] 00006 telemetry (hypertable) + continuous aggregates, unit_last_state, trips, unit_region_distance_daily, regions (PostGIS)
- [x] 00007 dvir_reports, defect_types, maintenance_*
- [x] 00008 routes, notifications, support, feedback, chat, report_export_jobs
- [x] 00009 audit_log + append-only trigger
- [x] 00010 RLS policy'lari (ENABLE + FORCE + tenant_isolation) + app_role grantlari
- [x] 00011 retention policy'lari (raw 90 kun, agregat 3 yil)
- [x] 00012 seed: permission kalitlari, 8 default rol, defect_types katalogi, system_settings
- [x] `db/queries/*.sql` (sqlc manbasi, har query'da `company_id`)
- [x] `sqlc.yaml`
- [x] `sqlc generate` — 276 query, `go build`/`go vet` yashil
- [x] Docker'da migratsiyalar haqiqatan ishga tushdi + RLS cross-tenant tekshiruvi

### 0.3 HOS engine — `eld-hos-engineer` ✅
- [x] `internal/hos` types/compute/day/split/cycle/violations/special (faqat stdlib)
- [x] `testdata/hos-test-vectors.json` — 35 ssenariy
- [x] `go test ./internal/hos/...` yashil

### 0.4 Auth va xavfsizlik qatlami — `eld-security-auditor` ✅
- [x] `internal/crypto` — AES-256-GCM (license_no, totp_secret, signature key)
- [x] `internal/auth` — Argon2id, JWT (15 daq), refresh rotation + reuse detection
- [x] Session policy: 1 web + 1 phone + 1 tablet, `replaced_session`, paused (Leave Truck)
- [x] Login + brute-force lockout (5/min/IP, 10/soat/akkaunt, 15 daq)
- [x] 2FA TOTP + 10 recovery kod; Super Admin/Administrator uchun majburiy
- [x] PIN (6 xona) — Switch / Return to truck
- [x] Invitation oqimi (72 soat), parol tiklash/forgot
- [x] `internal/middleware` — Authenticate, RequirePermission, Scope (company/branch/self), RateLimit (Redis), Idempotency
- [x] Endpointlar: `/auth/*`, `/me`, `/app/config`
- [x] Xavfsizlik testlari: cross-tenant → 404, permission → 403, lockout, token reuse

### 0.5 Test infratuzilmasi — `eld-test-engineer` ✅
*(9-bosqichdan oldinga surildi — keyingi barcha bosqichlar shunga tayanadi)*
- [x] `internal/testutil` — testcontainers (timescaledb-ha:pg16 + redis:7), docker context aniqlash, docker yo'q bo'lsa skip
- [x] goose migratsiyalarni konteynerga qo'llash + `eld_app` roli (NOSUPERUSER/NOBYPASSRLS) tekshiruvi
- [x] Izolyatsiya `company_id` bo'yicha → barcha testlar `t.Parallel()` bilan
- [x] Fixture builderlar (company, branch, role, user, driver, unit, eld_device, trailer, doc, event, daily_log, dvir) + `SeedTwoCompanies`
- [x] HTTP test klienti (`server.NewRouter` ustida, `AsPrincipal` — auth paketiga bog'liq emas)
- [x] Assert helperlari (status, error code, PII yo'qligi, SQLSTATE)
- [x] `rls_test.go` — **26 test yashil**: cross-tenant o'qish/yozish, audit_log append-only, DELETE taqiqlari, partial unique index
- [x] `deploy/k6/` — smoke.js, list_p95.js (p95 300/800 ms), README

### 0.6 Bosqich yakuni ✅
- [x] `sqlc generate` + `go build ./...` + `go vet ./...` yashil
- [x] `go test ./...` yashil (hos 44 + auth/middleware/crypto/domain 95 + testutil integratsiya 26)
- [x] `swag init` ishlaydi, `/api/docs` da 13 auth endpointi
- [x] Cross-tenant integratsiya testi o'tdi (RLS `eld_app` roli bilan)
- [x] `docs/history/v0.0.json` saqlandi (oasdiff uchun bazaviy nusxa)

**Chiqish mezoni (TZ D§4):** cross-tenant test o'tdi · invitation oqimi e2e · Swagger UI'da auth endpointlari misollar bilan.

---

## Bosqich 1 — Asosiy obyektlar ✅
`eld-api-developer` (modullar parallel) + `eld-db-engineer` (yetishmagan query'lar)

- [x] `companies` (Super Admin): CRUD, subscription; yaratishda to'liq provisioning (hos_policy + rollar + notification defaultlari + Administrator invitation) bitta tranzaksiyada
- [x] `company`: GET/PATCH, branches CRUD, hos-policy (versiyalash, retroaktiv emas), notification-settings, history
- [x] `users` + `roles` + `permissions`: CRUD, activate/deactivate, resend-invitation, reset-password, kesh invalidatsiyasi + sessiya bekor qilish
- [x] `units`: CRUD, activate/deactivate, assign-driver, diagnostics, history *(import/export — drivers agentida)*
- [x] `drivers`: CRUD, activate/deactivate, activities, co-drivers (license_no AES-256-GCM bilan shifrlangan) — testlar yashil (6.5 s)
- [x] `eld_devices`: CRUD, assign-unit (bir unitda bitta faol qurilma — DB partial unique)
- [x] `trailers`, `shipping_documents`: CRUD
- [x] `files/presign` (kind oq ro'yxati, size/content-type tekshiruvi) — testlar yashil (12.2 s)
- [x] CSV/XLSX import/export + shablonlar, qator-qator validatsiya, all-or-nothing
- [x] Har modulda: swag annotatsiya to'liq, audit yozuvi, permission mapping
- [x] Markazlashgan wiring (`cmd/api/wire.go`) — 8 modul ulandi, S3 sozlanmagan bo'lsa fake fallback (panic yo'q)
- [x] `swag init` — **61 path / 88 endpoint / 137 definition**; `@x-permission` yo'q: 0, `security` yo'q: 0, `example` yo'q maydon: 0/564
- [x] Smoke test: server ko'tarildi, `/health` `/ready` `/api/docs/swagger.json` 200; himoyalangan marshrutlar 401, `/app/config` 200
- [x] `docs/history/v0.1.json` saqlandi
- [x] **Kod ko'rigi o'tkazildi** — `internal/pgconv` (7 modulda 20 ta dublikat konvertor birlashtirildi, NULL semantikasi bir xil), `drivers/service.go` 807→4 fayl, `.golangci.yml` v1→v2 (CI lint job umuman ishlamayotgan ekan), goimports 69 faylga qo'llandi, lint 358→258
- [x] Permission katalogi farqi tekshirildi — `drivers.reset_password` `00017` migratsiyasida allaqachon hal qilingan, yangi migratsiya kerak emas
- [x] **Xavfsizlik auditi o'tkazildi** — 0 critical, 3 high (hammasi tuzatildi + regression testlar), 3 medium tuzatildi
- [x] Bosqich yakuni: security audit + code review + testlar

**Chiqish mezoni:** CSV import 1000 satr < 30 s.

---

## Xavfsizlik: 1-bosqich medium/low topilmalari ✅ (hammasi yopildi)
- [x] `/metrics` va `/api/docs` — `mw.Gate`: disabled→404, IP oq ro'yxati, constant-time bearer token; prod/staging'da token/CIDR'siz **boot xatosi**
- [x] Litsenziya reveal — alohida `drivers.license.view` kaliti + audit yozuvi **fail-closed** (audit tushmasa ochiq qiymat qaytmaydi), audit'ga faqat maskalangan qiymat
- [x] Presign hajmi — SigV4 `content-length` ni imzolaydi; `size_bytes` dan katta body imzoni buzadi
- [x] `role_permissions` RLS — `company_id` predikati USING va WITH CHECK bilan (00020)
- [x] `SuperAdminCompanySelector` — `mw.Authenticate` ichiga ko'chirildi (global middleware principal'dan oldin ishlagani uchun); super admin bo'lmagan `X-Company-Id` → 403
- [x] TOTP replay — Redis `SetNX` bilan ishlatilgan kod 90 s bloklanadi
- [x] `MarkInvitationUsed` — token parol yozilishidan **oldin** kuydiriladi, xato qaytariladi
- [x] `/app/config` — 60/min/IP rate limit + 45 s Redis kesh
- [x] `GET /permissions` — `RequireAnyPermission(permissions.read, roles.read)`

## Bosqich 2 — Telemetriya va qurilma ✅
`eld-sync-engineer`

- [x] `pkg/eldproto` — `Frame`/`Decoder`/vendor registry + FMCSA P/E/T/L/R/S/O kodlari; `pt30` (NMEA-uslub, XOR checksum) va `teltonika` (Codec 8 AVL, IO 239/67/16/48/32/102/253) parserlari
- [x] Telemetriya ingestion — bo'lakli (1000) `INSERT ... ON CONFLICT (unit_id, ts) DO NOTHING`, chegara 5000, `accepted`/`duplicate`
- [x] `unit_last_state` upsert + Redis `unit:last:<id>` (TTL 10 daq) + WS `tracking` kanaliga publish
- [x] Trip segmentatsiyasi (ignition on→off yoki ≥15 daq to'xtash), masofa: odometer ustun, aks holda haversine; polyline object storage'ga
- [x] `unidentified_events` buferi (ochilish/accrue/yopilish)
- [x] ELD holati va malfunction kodlari yozuvi (`online|idle|offline|disconnected`; malfunction `eld_devices` dan hosil qilinadi)
- [x] `GET /tracking/live`, `GET /units/{id}/trips?date` (Company TZ kun chegarasi), `GET /trips/{id}`, `GET /unidentified-events`
- [x] `internal/jobs` — asynq task registri + `MarkStaleUnitsOffline` (@every 1m)
- [x] Migratsiya `00019_tracking.sql` + yangi permissionlar (`tracking.view_live`, `tracking.view_history`) rollarga grant qilindi
- [x] Testlar: 21 unit + 31 integratsiya (jami 49) — hammasi yashil, regressiya yo'q
- [ ] Bosqich yakuni: security audit + code review
- [x] **`swag` blokeri hal qilindi** — sabab tip aliasi EMAS ekan: `swag --parseDependency` tiplarni `cmd/api/main.go` dan boshlangan bog'liqlik daraxti bo'yicha yechadi, ulanmagan modul `dto` paketlari ro'yxatdan o'tmay ambiguity beradi. **Xulosa: har yangi modul `wire.go` ga ulangach `swag init` ishlaydi**
- [x] 2–3-bosqich modullari ulandi (`telemetry`, `tracking`, `duty`, `sync`); `buildModules` ga `ws.Publisher` qo'shildi
- [x] Worker to'liq ishlaydi — `jobs.Register` + fan-out task (cron'da tenant yo'q, shuning uchun `CompanyLister` orqali har kompaniyaga sweep enqueue qilinadi). Real sinov: 1 daqiqadan keyin cron ishga tushdi, 6 kompaniyaga sweep yuborildi
- [x] Swagger: **69 path / 96 operatsiya / 179 definition**; `@x-permission` yo'q: 0, `example` yo'q: 0; `docs/history/v0.3.json`
- [x] Smoke test: `/health` `/ready` `/api/docs/swagger.json` 200; `/tracking/live`, `/sync/push`, `/hos-summary` → 401

**Chiqish mezoni:** 8 soatlik oqim testida 0 yo'qotish.

---

## Bosqich 3 — Duty status, sync, HOS integratsiyasi ✅
`eld-sync-engineer`

- [x] `internal/sync` — sof qoida/konflikt qatlami (faqat stdlib, `time.Now()` yo'q), 12 test / 76 jadval holati
- [x] `POST /sync/push` — events/telemetry/dvir/chat, batch chegaralari, `accepted|duplicate|rejected`
- [x] Idempotency (`client_event_id` UNIQUE + `Idempotency-Key` majburiy, 60/min/device)
- [x] Konflikt qoidalari 1–5: `time_source` → `device_seq` → `received_at` → `client_event_id` (deterministik), yutqazgan `superseded_by` bilan **saqlanadi**
- [x] `time_in_future`, `log_locked` rad etishlari; cross-tenant `client_event_id` → `duplicate` (yozuvsiz)
- [x] `GET /sync/pull?since=` — kursor `next_since` = qaytarilgan eng yangi `updated_at` (kesilgan sahifa aniq davom etadi), `truncated` bayrog'i
- [x] Vaqt yaxlitligi: `time_source`, `time_unverified`, `clock_skew_sec`; 2 daq ogohlantirish, 10 daq → `T` malfunction
- [x] Server tomonida tekshiruv: auto-DR, YM chiqish, `pc_not_allowed`/`ym_not_allowed`/`sleeper_berth_unavailable`/`drive_not_manual`
- [x] HOS integratsiyasi — har kun uchun **o'sha kunda amal qilgan** `hos_policy_versions` (Q10.1 retroaktiv emas)
- [x] `GET /drivers/{id}/duty-status-events`, `GET /drivers/{id}/hos-summary` (Driver = `self`)
- [x] Testlar: 12 unit (76 holat) + 28 integratsiya, 3 marta ketma-ket flake'siz
- [ ] Bosqich yakuni: security audit + code review

**Chiqish mezoni:** 30 golden vektor o'tdi · 24 soat offline sync testi · 0 yo'qolgan event.

---

## Bosqich 4 — Daily log, sertifikatsiya, tahrirlash, violations ✅
`eld-api-developer`

- [x] `daily_logs` (kun chegarasi Home Terminal TZ), totals, Log Form; `GET /drivers/{id}/daily-logs`, `GET /daily-logs/{id}`
- [x] `POST /daily-logs/{id}/certify` — imzo, `locked=true`, `signed_ip`/`signed_by`; **Q26: admin haydovchi nomidan sertifikatlay olmaydi (403)**
- [x] `needs_recertify` mantiqi; `GET /reports/uncertified-logs`
- [x] `GET /daily-logs/{id}/pdf` — chromedp; Chromium bo'lmasa HTML fallback
- [x] `log_edit_requests`: create (admin) → approve/reject (faqat haydovchi), `superseded_by`, `origin` turlari, `needs_recertify`
- [x] **Q17.1 taqiqlari**: avto-`DR` segmenti bilan kesishuv → `DR_IMMUTABLE` (istisno: haydovchining `pc`/`ym` deb qayta belgilashi); `intermediate`/`power_*`/`malfunction` → `EVENT_IMMUTABLE`. Tekshiruv **taklif yaratilganda ham, tasdiqlanganda ham**
- [x] Driver self-edit (`POST /daily-logs/{id}/events`, note majburiy)
- [x] Unidentified: `assign` → edit request (`proposed`), `claim` (`origin=assigned`), `annotate`
- [x] Violations — server kanonik, `policy_version_id` bilan; engine qaytarmay qo'yganlari `resolved_at`+`resolved_reason` bilan **yopiladi, o'chirilmaydi**; ochiq violation uchun partial unique indeks (dublikat yo'q)
- [x] `GET /violations`, `/violations/{id}`
- [x] Inspection: read-only token (`Principal.Restricted="inspection"` — hech qanday permissionsiz), `/inspection/logs`, `/inspection/email`, `/inspection/transfer` (generic: CSV+PDF ZIP)
- [x] Migratsiya `00021_logs_stage4.sql` — violation turlari **hos katalogiga** ko'chirildi
- [x] Testlar 22/22 yashil; Swagger **87 path / 115 operatsiya**, `@x-permission` yo'q: 0; smoke test 401 lar to'g'ri
- [x] **2–4-bosqich xavfsizlik auditi + kod ko'rigi** — 3 high, 2 medium tuzatildi, 4 low tavsiya
- [x] Swagger qayta generatsiya qilindi ~~`enums` o'zgardi~~ — `swag init` qayta yuritilsin

### Auditda topilgan 3 ta HIGH (tuzatildi)
- [x] **`/sync/push` origin soxtalashtirish** — qurilma `origin=admin_edit|driver_edit|assigned` yubora olardi: (a) FMCSA yozuvida soxta provenance ("admin tahrirladi"), (b) `assigned` `isManual()` ro'yxatida yo'qligi sabab **Q4 "DR qo'lda tanlanmaydi" tekshiruvi chetlab o'tilardi**, (c) bunday DR keyin `DR_IMMUTABLE` himoyasidan tashqarida qolib, haydovchi uni qisqartira olardi. Yechim: `ValidDeviceOrigin()` oq ro'yxati (`auto|driver|manual_no_eld`)
- [x] **`GET /violations/{id}` scope'siz** — Driver roli seed'da `violations.read` ga ega, ya'ni **har haydovchi boshqa haydovchining buzilishini o'qiy olardi**. Yechim: branch+self scope → 404
- [x] **`POST /log-edit-requests` scope'siz** — Driver roli `logs.propose_edit` ga ega: haydovchi A haydovchi B ning logiga tahrir taklifi yarata olardi; branch-admin boshqa filialga. Yechim: 404
- [x] Medium: inspection `applyScope` **fail-open** edi (driver yozuvi topilmasa filtr umuman qo'llanmasdi → butun kompaniya buzilishlari); unidentified assign'da maqsadli haydovchi scope'i tekshirilmasdi
- [ ] **TZ CR:** `POST /inspection/begin` D§3 jadvalida yo'q (read-only token beruvchi endpoint)
- [x] `AssignUnidentified` **bitta tranzaksiyada** (`CreateAssignmentRequest`) — regression test: o'rtada FK xatosi bo'lsa na request, na status o'zgarishi saqlanmaydi
- [ ] `unidentified_driving` (8 kun) va `uncertified_log` violation'lari uchun nightly cron — servis metodlari tayyor, scheduler ulanmagan
- [x] Log-edit bildirishnomasi — `logs.Alerter` consumer interfeysi: taklif yaratilganda haydovchiga (`log_edit_request`), approve/reject da adminga (`log_edit_resolved`); 4 ta test
- [ ] `LogMailer` faqat log yozadi — `internal/notify` kelganda almashtirilsin; deploy image'ga Chromium qo'shilsin
- [ ] `fmcsa_us` FMCSA ELD output file — hozir 501 `FEATURE_DISABLED` (7-bosqich)

**Chiqish mezoni:** edit request e2e · violation'lar vektorlarga mos.

---

## Bosqich 5 — Real-vaqt, bildirishnoma, chat ✅
`eld-sync-engineer`

- [x] `internal/ws` to'liq transport: upgrade, auth (`Bearer` header YOKI birinchi `auth` freym; **query'dagi 6 xil token parametri upgrade'dan oldin 401**), ping 30 s / 2 pong o'tkazilsa uzish, 32 KiB read limit, 10 s write deadline
- [x] Kanallar: `tracking` → `tracking.view_live`, `chat` → `chat.read`, `dashboard` → `dashboard.read`, `notifications` → authenticated. **Deny-by-default**; har `subscribe` da permission + `company_id` + unit egaligi qayta tekshiriladi
- [x] `since` backfill (≤200 event, 24 soat oynasi, `"replay": true` belgisi bilan)
- [x] Redis pub/sub `Bridge` — ko'p node uchun fan-out
- [x] `docs/websocket.md`
- [x] `internal/notify` — TZ A§19 matritsasi; FCM HTTP v1 (service-account RS256) va APNs HTTP/2 (ES256) **yangi SDK bog'liqliksiz**, SMTP/SES, SMS, Telegram; kalitlar bo'lmasa `NopSender` + WARN
- [x] `GET /notifications`, `PATCH /{id}/read`, `POST /read-all`, `POST /devices/push-token`
- [x] Chat: threads, kursor pagination, `sent/delivered/read`, **haydash rejimida bloklash** (`DRIVING_MODE_BLOCKED` 409), 1 yil retention
- [x] `GET /dashboard/summary` — KPI kartalar, status bloki, bugungi marshrutlar
- [x] Cron: soatlik fan-out har tenant lokal soatiga moslab — 20:00 `uncertified_log`, 07:00 `unidentified_driving` (+ 4-bosqichdagi `SyncUnidentifiedViolations`), 03:00 chat retention; `subscription_expiring` 14/3/1 kun. Task id `type:company:local_date` — takroriy tick no-op
- [x] Migratsiya `00023` — `device_push_tokens` (+RLS), `users.telegram_chat_id`, notification_settings CHECK'lari
- [x] Testlar: 45 unit + 24 integratsiya, hammasi yashil
- [x] Wiring: `ws` moduli + Redis `Bridge` (Publisher sifatida **bridge** uzatiladi), notify dispatcher + `dvir`/`maintenance` alerter adapterlari, worker cron (5 yozuv Redis'da tasdiqlandi)
- [x] **Kritik nuqson topildi va tuzatildi:** `middleware/logger.go` dagi `statusWriter` `http.Hijacker` ni implement qilmagan → **har qanday `/ws` upgrade 500 qaytarardi**, ya'ni WebSocket umuman ishlamasdi. `Hijack()`+`Flush()` qo'shildi, endi `101 Switching Protocols`
- [x] Swagger: **110 path / 144 operatsiya / 276 definition**; `@x-permission` yo'q: 0, `example` yo'q: 0 (1428 maydondan); `docs/history/v0.6.json`
- [x] Smoke: `/ws?token=` → **401 upgrade'dan oldin**; `Bearer bad` → 401; token'siz → 101 + auth-freym kutiladi (TZ B§3.6 ikkala usulni ruxsat beradi)
- [x] **5–6-bosqich xavfsizlik auditi** — 2 CRITICAL, 4 high, 2 medium tuzatildi

### Auditda topilgan 2 ta CRITICAL (tuzatildi)
- [x] **Chat butun kompaniyaga broadcast qilinardi** — `chat` WS kanaliga har xabar `company_id` bo'yicha tarqatilardi. Driver roli seed'da `chat.read` ga ega → **istalgan haydovchi barcha haydovchilarning yozishmalarini** (matn, `file_key`, lokatsiya) real vaqtda o'qiy olardi
- [x] **Bildirishnomalar butun kompaniyaga broadcast qilinardi** — `notifications` kanali permissionsiz edi, har bildirishnoma (title/body/entity) kompaniyadagi barcha ulangan foydalanuvchilarga borardi → shaxsiy inbox sizishi
- [x] Sabab bitta: WS hub'ida **tenant izolyatsiyasi bor edi, lekin tenant ichida manzil yo'q edi**. Yechim: `ws.Audience{UserID, Office, BranchID}` + `Client.Scope/BranchID`, deny-by-default; `since` replay ham shu filtrdan o'tadi
- [x] HIGH: `chat markRead` scope'ni **mutatsiyadan keyin** tekshirardi — boshqa driver xabarini `read` qilib, matn bilan event publish qilish mumkin edi
- [x] HIGH: klient bergan `file_key`/`photo_keys`/`signature_key`/`invoice_key` tenant prefiksiga tekshirilmasdi → **cross-tenant fayl havolasi**. Yangi `storage.OwnsKey()`, 6 nuqtada 422
- [x] MEDIUM: WS token query kalitlari ro'yxati 6 → 14 variantga kengaytirildi; `dashboard.sql` dagi `r.status='in_progress'` o'lik shart (routes agenti `ongoing` ga o'tkazgan) tuzatildi

### 5-bosqichdan qolgan TODO'lar
- [x] **WS `Backfiller` yozildi** — `chat` (haydovchi: faqat o'z threadi; ofis: oxirgi 50 faol thread, `since` dan eski birinchi threadda to'xtaydi) va `notifications` (`ws` → `notifications` → `notify` → `ws` import tsiklidan qochish uchun sqlc'ni to'g'ridan-to'g'ri chaqiradi). Chegaralar: ≤200 xabar, 24 soat; `tenant.WithCompanyID` + `Audience` filtri — cross-tenant izolyatsiya testi bilan
- [x] `ws.MultiBackfiller` — wiring uchun bir nechta kanalni birlashtiradi
- [x] Dashboard WS cron — `jobs.RegisterDashboard`, `@every 30s` (60 s polling NFR'ining yarmi), `asynq.Unique(25s)` overlapni yig'ib qo'yadi
- [ ] **Diqqat:** `dashboard.Service.Publish` `Audience.BranchID` siz butun kompaniyaga broadcast qiladi — shu sabab cron doim `branch_id=nil` summary yuboradi. Filial darajasidagi real-vaqt kerak bo'lsa `Publish` ga `BranchID` audience qo'shilishi kerak (aks holda filial ma'lumoti boshqa filialga oqadi)
- [ ] `chat.use`/`dashboard.view` o'rniga mavjud `chat.read`/`chat.send`/`dashboard.read` ishlatildi (katalogda shular bor) — TZ A§16 bilan solishtirib CR kerakmi, tekshirilsin

**Chiqish mezoni:** qurilma → admin kechikishi ≤ 5 s.

---

## Bosqich 6 — DVIR va Maintenance ✅
`eld-api-developer`

- [x] DVIR yaratish (mobil, **faqat driver** — admin 403, Q31), pre/post trip, defects + foto ≤5, Time/Location/Odometer telemetriyadan
- [x] Holat mashinasi: `draft → submitted_no_defects` / `draft → submitted_defects_found → repaired → certified` + `closed_no_certification`; noto'g'ri o'tish → 409 `DVIR_INVALID_TRANSITION`
- [x] **Q27.2 kritik nuqson → `units.out_of_service=true`** + alert; certify'dan keyin tozalanadi
- [x] `pending-certification` oqimi; **Q30.1 fallback**: 7 kun ichida keyingi DVIR bo'lmasa yoki boshqa haydovchi tasdiqlasa ham qabul; inactive unit → `closed_no_certification` (cron, idempotent)
- [x] `GET /dvir-reports/{id}/pdf` (Chromium bo'lmasa HTML fallback); `defect_types` katalogi (system yozuvlar read-only)
- [x] Maintenance: schedules CRUD, `maintenance_schedule_units` (`last_service_value`, `next_due_value`, `remaining`), `current_value` **telemetriyadan** (km/mi/engine_hours/days)
- [x] `GET /maintenance/due` (overdue), complete (**Q42.1**: `last_service_value` = o'sha paytdagi ko'rsatkich, `Due → Schedule`), cancel (moliyaviy maydonsiz), `maintenance_records`
- [x] Reminder **bir marta** (`reminder_sent_at`), co-driver'ga ham; cron `jobs.RegisterStage6` (@every 1h, fan-out)
- [x] Migratsiya `00022` — status CHECK almashtirildi, eski qiymatlar ko'chirildi; yangi apierr kodlari (7 ta)
- [x] Testlar 30/30 yashil
- [ ] Bosqich yakuni: security audit + code review

**Chiqish mezoni:** overdue hisobi telemetriya bilan tekshirildi.

---

## Bosqich 7 — Marshrutlar va hisobotlar ✅
`eld-api-developer` + `eld-sync-engineer`

- [x] `internal/geo` — `GeoProvider` (Nominatim/Photon/OSRM, Google, Nop), **100 m grid keshi**, FMCSA formati (`"12 km NE of <shahar>"`), haversine + 8 nuqtali kompas
- [x] `routes` CRUD; geofence (default **300 m**, ≥2 daqiqa turish) → `completed`; dwell chiqib ketganda reset
- [x] **Q68**: bir unitda faqat eng kichik `sequence` li `ongoing` route tekshiriladi
- [x] `not_completed` — 6 ta sabab; `other` uchun izoh majburiy
- [x] `GET /routes/{id}/directions` (kesh bilan)
- [x] `GET /reports/activity` — `Odometer Change = End − Start`, telemetriyasiz unit uchun `has_data=false`
- [x] `GET /reports/distance-by-region` — `unit_region_distance_daily` agregatidan (darhol tayyor); kunlik roll-up cron (idempotent)
- [x] HOS Summary, DVIR hisoboti, Regulator Export (`generic`: ZIP; `fmcsa_us`: 501 `FEATURE_DISABLED`)
- [x] `POST /reports/export-jobs` + `GET /{id}` — asinxron, CSV/XLSX/PDF/ZIP, **24 soat havola** (muddat o'tgach havola berilmaydi), eksport audit'ga
- [x] Migratsiya `00024` — `routes.status` `ongoing|completed|not_completed|cancelled` ga keltirildi (eski `planned`/`in_progress` ko'chirildi), `geofence_m` 200→300
- [x] Cron: geofence sweep (@every 1m), region distance roll-up (01:30)
- [x] Testlar: routes, reports, geo, storage, jobs — hammasi yashil
- [x] **7–8-bosqich xavfsizlik auditi** — 3 high, 6 medium tuzatildi

### Auditda topilgan HIGH (tuzatildi)
- [x] **`routes` da `self` scope umuman yo'q edi** — Driver roli `routes.read`+`routes.complete` ga ega: butun kompaniya marshrutlarini ko'rar va **boshqa haydovchining reysini `not-completed` bilan yopa olardi**
- [x] **`GEO_API_KEY` logga tushardi** — `client.Do` xatosi `%v` bilan o'ralganda `*url.Error` to'liq URL'ni (`key=<API_KEY>` va koordinatalar bilan) bosardi; `MaskSecrets` `key=` ni tozalamaydi. Yechim: `transportError()` URL'ni olib tashlaydi
- [x] **Support attachment cross-tenant** — `file_key` tenant prefiksiga tekshirilmasdi (`storage.OwnsKey` qo'shildi)
- [x] MEDIUM: eksport `downloadURL` imzolashdan oldin egalik tekshirmasdi + TTL `min(..., 24h)` ga qattiq chegaralandi; `SetStatus` da scope; **CSV formula injection** (`=`/`+`/`@` bilan boshlanuvchi katak Excel'da bajariladi) — `safeCell()`; geo kesh kaliti (koordinata = PII) loglanmaydi; geo HTTP so'rovlariga 8 s timeout

### Auditdan qolgan tavsiyalar — ✅ yopildi
- [x] **`branch` scope**: `routes` va `reports` — `drivers.branch_id` bo'yicha (asos: marshrut = haydovchiga topshiriq; yozishda unit filiali ham tekshiriladi, aks holda filial menejeri o'zga filial mashinasini tortib olardi). `auditlog` — **ataylab `company` scope talab qiladi (403)**: `audit_log` ~30 jadvalga ishora qiladi, ko'pida `branch_id` yo'q; `edited_by → users.branch_id` filtri ikki tomonlama noto'g'ri natija berardi
- [x] `storage` `Remove`/`PresignRemover`/`NopRemover` — `jobs.FileRemover` kontrakti bajarildi
- [x] `PgSubscriptionSource.Invalidate(ctx, companyID)`
- [x] `audit.sql LEFT JOIN users` ga `AND u.company_id = a.company_id`
- [x] `internal/notify` testi — 16 ta TZ jadvali + 4 kengaytma alohida tekshiriladi
- [x] `jwtRe` imzo uzunligi cheklovi olib tashlandi; 400+ qatorli 3 fayl → 10 faylga bo'lindi (hammasi <300 qator)
- [x] Migratsiya `00026` — branch scope indekslari

### Yangi qolgan topilmalar
- [x] `dvir.ReportFilter.BranchID` qo'shildi ~~yo'q~~ → hisobotlardagi DVIR eksporti branch scope'da hamon butun kompaniyani beradi
- [x] `DashboardKPI` — har kartada branch filtri ~~yo'q~~
- [x] `phoneRe` `time.Parse(DateOnly)` bilan sanalarni ajratadi ~~sanalarni~~ (`2026-09-06`) telefon deb maskalaydi (log false positive)
- [x] Wiring: `RetentionDeps.Files` (`newFileRemover`), `SubscriptionInvalidator` ~~kerak~~ (prod — `PresignRemover`, dev — `NopRemover`); `Invalidate` ni `company` subscription handleri va `HandleSubscriptionExpiring` chaqirsin

### 7-bosqichdan qolgan TODO'lar
- [x] **`regions` seed va import mexanizmi** — migratsiya `00027`: 72 hudud kodi/nomi (PK 7, UZ 14, US 51), `geom=NULL`; **poligon koordinatalari xotiradan yozilmadi** (masofa hisoboti soliq/regulator hujjati — taxminiy koordinata xavfli). `deploy/regions/geojson_to_migration.py` — rasmiy GeoJSON'dan goose migratsiyasi generatori, `deploy/regions/README.md` da manbalar (GADM, Natural Earth/TIGER, OSM) va qadamlar
- [x] `FindRegionByPoint` tie-break — `ORDER BY ST_Area(geom::geography) ASC` (enclave/shahar viloyat ichidan aniqroq javob beradi); Docker'da tasdiqlandi
- [ ] **Buyurtmachidan kerak:** rasmiy GeoJSON fayllar (`deploy/regions/{pk,uz,us}.geojson`) — ularsiz Distance by Region bo'sh qaytadi
- [x] Wiring bajarildi: `RegisterStage7`, cron'lar, `ExportEnqueuer`, `reports.DvirLister ← *dvir.Service`, `ChromeRenderer`+HTML fallback
- [ ] `GET /reports/export-jobs` (ro'yxat) — TZ D§3 da yo'q, CR kerak

**Chiqish mezoni:** masofa hisoboti GPS trekka ±2 % mos.

---

## Bosqich 8 — Support, audit, sayqal ✅
`eld-api-developer`

- [x] Support tiketlari (thread, fayl ≤3), status faqat oldinga `new→in_progress→resolved` (teskari → 409), driver `self` scope
- [x] Feedback (`app_rating` yoki `text` shart, javobsiz)
- [x] `GET /audit-log` + `/audit-log/tables` — filtr, pagination, **read-only**, PII maskalash (`password_hash`, `license_no_enc`, `refresh_token_hash`, ichma-ich JSON dagi email/api_key/JWT)
- [x] **`RequireWritableSubscription`** — readonly/grace tugagan bo'lsa admin yozuvi 403. **Ikki qatlamli himoya:** middleware ichida GET/HEAD/OPTIONS, `IsSuperAdmin` va `Scope==self` (driver ilovasi) **doim o'tadi** — noto'g'ri wiring ham HOS yozuvini to'xtata olmaydi; manba yo'q bo'lsa fail-closed (503)
- [x] Retention cron (04:17): notifications 1 yil, eskirgan sessiyalar, eksport fayl kalitlari 24 soat (satr audit uchun qoladi); telemetriya 90 kun Timescale policy'si start-upda tekshiriladi
- [x] `internal/metrics` — `eld_http_request_duration_seconds{route,method,status}` (route = chi patterni, **id label bo'lmaydi** — kardinallik portlashi yo'q), in-flight, response size, WS ulanishlar, DB pool, asynq queue lag
- [x] `deploy/prometheus.yml`, `docs/runbook.md` (deploy, migratsiya, backup/PITR, incident checklist)
- [x] Migratsiya `00025` — ticket status `open→new`, `support.update_status` kaliti
- [x] Testlar: support, auditlog, middleware, jobs, metrics — hammasi yashil
- [ ] Bosqich yakuni: security audit + code review

### 8-bosqichdan qolgan TODO'lar
- [x] ~~`FileRemover`~~ — `storage.Remove`/`PresignRemover`/`NopRemover` yozildi (wiring yakuniy agentda)
- [x] Wiring bajarildi: `support`, `auditlog`, `server.Deps.Pool`, `jobs.RegisterRetention`, `metrics.PollQueues`, `CheckTelemetryPolicy`
- [x] **Yozuv guardi** — `cmd/api/writeguard.go`: domen paketlariga tegmasdan `chi.Router` ni o'raydi, faqat `POST/PUT/PATCH/DELETE` ni ushlaydi. To'liq guard: company, users/roles, fleet, drivers, routes, maintenance, support. Naqsh bo'yicha: `dvir → /defect-types`, `logs → log-edit approve|reject`, `reports → POST /export-jobs`. **Hech qachon o'ralmagan**: auth, platform, files, tracking, duty, sync, notifications, chat, dashboard, auditlog, ws

## Yakuniy wiring va tizim holati ✅
- [x] **Swagger: 125 path / 166 operatsiya**; `@x-permission` yo'q: 0
- [x] Smoke: `/health` 200, himoyalangan marshrutlar 401, `/metrics` 200 (`eld_http_request_duration_seconds` faol)
- [x] **Worker: 8 ta cron Redis'da tasdiqlandi** — stale units (1 daq), geofence sweep (1 daq), alerts fan-out (soatlik), DVIR overdue (1 soat), maintenance reminder (1 soat), subscription expiring (08:00), region distance (01:30), retention (04:17). 6 daqiqa xatosiz ishladi
- [x] `docs/history/v0.8.json`
- [x] `go build` / `go vet` / `go test` — toza va yashil

## Bosqich 9 — Yakuniy sifat va API muzlatish ✅

### YAKUNIY HOLAT — `v1` MUZLATILDI
- [x] Swagger: **125 path / 166 operatsiya / 320 definition**; `@x-permission` yo'q: **0**; sana formati: **175 maydon**; `example` yo'q: **0**
- [x] `docs/history/v1.0.json` — muzlatilgan spec
- [x] `oasdiff` (v0.8 → v1.0): 16 breaking, hammasi `format: none → date-time/date` (ongli yaxshilanish) + `GET /company/history` permission o'zgarishi
- [x] `make lint` — **0 muammo**; `go build`/`go vet`/`gofmt` toza
- [x] `go test ./...` — barcha paketlar ok
- [x] Integratsiya — **37/37 paket yashil**
- [x] `make test-matrix` — **1224 tekshiruv, 0 nomuvofiqlik**
- [x] Smoke: API va worker ko'tarildi, javoblar to'g'ri
- [x] `docs/api-review.md` §8 — `v1` muzlatish qarori: **Ready to freeze**
- [x] `README.md` — "Status: v1 frozen"


### 9.1 CI, oasdiff, hujjatlar ✅
- [x] **To'liq CI zanjiri** (`.github/workflows/ci.yml`): lint → swagger (`swag init` + `git diff --exit-code docs/`) → **oasdiff** → test → integratsiya → docker → staging (avtomatik) → production (`environment: production` orqali qo'lda tasdiq)
- [x] Integratsiya job'i **bitta** service konteyner ishlatadi (`TEST_DATABASE_URL`/`TEST_REDIS_URL`) — har paket o'zinikini ko'tarmaydi
- [x] `oasdiff` haqiqatan ishlatildi: `v0.6` → joriy = **3 ta buzuvchi o'zgarish**, hammasi bitta joyda — `POST /sync/push` dagi `origin` enum'idan `admin_edit|assigned|driver_edit` olib tashlangan (bu **ataylab qilingan xavfsizlik tuzatishi**, auditda topilgan provenance soxtalashtirish). `v0.8` bilan farq 0
- [x] `make oasdiff`, `make ci` target'lari
- [x] `docs/api-review.md` — `v1` muzlatish uchun ko'rik + 6 ta chetlashishga tavsiya
- [x] **k6 skriptlarida 3 ta real xato topildi va tuzatildi**: mavjud bo'lmagan endpointlar (`/logs`, `/dvir`, `/reports/hos-summary`...), login payload'da `company` o'rniga `company_id`, `distance-by-region` ga noto'g'ri query (doim 422 qaytarardi)
- [x] `.golangci.yml` izohli istisnolar: **565 → 127 muammo**

### 9.2 Lint topilmalari ✅ — **127 → 1** (qolgani `testutil` da, boshqa hudud)
- [x] **`bodyclose` 15 → 0. Haqiqiy bug:** `internal/ws` testlarida barcha WS handshake javoblari yopilmasdi (resurs sizishi)
- [x] **`gosec` 31 → 0.** Zaiflik topilmadi, lekin ikki joyda mustahkamlash: `?page=` **yuqori chegarasi yo'q edi** → katta qiymatda `Offset()` int32 overflow xavfi (`MaxPage=1_000_000`); PDF javoblariga `X-Content-Type-Options: nosniff`
- [x] `errorlint` 24 → 0 (`pgx.ErrNoRows` solishtirishlari `errors.Is` ga, `%v` → `%w`)
- [x] **`gocritic`: haqiqiy test bug** — `password_security_test.go` dagi "bad salt base64" holati `strings.Replace(x, y, y, 1)` sabab **hech narsani sinamasdi**
- [x] `nilerr` 4 → 0 (ataylab fail-open cache, izohli `//nolint`), `staticcheck` 5, `goconst` 9, `lll` 23, `unparam` 4, `govet` 1, `revive` 1 (`geo.GeoProvider` → `geo.Provider`)
- [x] **`gocyclo` 7 → 0** — `auth.Login`, `companies.Provision`, `company.mergePolicy`, `files.validate{Driver,Unit}Rows`, `users.UpdateUser`, `sync.ValidateEvent` bo'lindi
- [x] **Swagger sana formatlari: 168 maydon, 22 DTO fayli** — `time.Time` → `format:"date-time"`, `YYYY-MM-DD` → `format:"date"` (Go tipi + `example` shakli bo'yicha aniqlandi, soxta pozitiv yo'q)
- [x] **400+ qatorli 7 fayl bo'lindi** — hammasi <400 qator, xatti-harakat o'zgarmagan

### 9.3 Permission matritsasi, kontrakt testlari, k6 NFR ✅
- [x] **Permission matritsasi: 166 operatsiya × 8 rol = 1224 tekshiruv, 0 nomuvofiqlik.** `docs/swagger.json` dan operatsiyalar, `role_permissions` dan haqiqiy rol huquqlari o'qiladi — qo'lda ro'yxat yo'q, ya'ni yangi endpoint noto'g'ri permission bilan qo'shilsa test darhol qizil bo'ladi
- [x] `super_admin` operatsiyalari (companies CRUD) — hech bir default rol o'ta olmasligi tasdiqlandi
- [x] Kontrakt testlari: 160/166 auth'siz → **401**, 6 public; 40 ta `{id}` operatsiyasi — noto'g'ri UUID → 422, mavjud bo'lmagan → 404, cross-tenant → **404** (403 emas); javob shakllari swagger bilan mos
- [x] **k6 NFR haqiqatan o'lchandi** (3000 unit, 1200 driver, 12000 daily log bilan seed): ro'yxatlar p95 = **234 ms** (talab ≤300) ✅, hisobotlar p95 = **698 ms** (talab ≤800) ✅. N+1 yoki indeks muammosi topilmadi (eng sekini `maintenance-schedules` ~120 ms)
- [x] `deploy/k6/seed.sql` (idempotent), `make test-matrix`

### 9.4 Matritsa/k6 topilgan haqiqiy nuqsonlar (tuzatilishi kerak)
- [x] `LoginRateLimit` endi `cfg.RateLimit.Login` dan oladi ~~5/min/IP qattiq kodlangan~~ (`internal/middleware/ratelimit.go`) — `RATE_LIMIT_LOGIN` konfiguratsiyasi faqat `auth.Guard` lockout'iga ta'sir qiladi, HTTP middleware'ga umuman ta'sir qilmaydi. Har qanday muhitda bitta IP'dan 1 daqiqada >5 akkaunt token ololmaydi
- [x] `per_page` qat'iy {10,25,50}, boshqasi 422 ~~cheklanmagan~~ (`internal/httpx/pagination.go`) — istalgan `[1,100]` qabul qilinadi, TZ §18.3 esa uchta qiymat deydi
- [x] O'lik kalitlar: `tracking.read`, `tracking.history`, `trips.read`, `support.update` **olib tashlandi** (00028); `company.history.view` `GET /company/history` ga ulandi ~~o'lik kalitlar~~: `company.history.view`, `support.update`, `tracking.read`, `tracking.history`, `trips.read` — Go katalogida va seed'da bor, lekin hech qanday endpoint enforce qilmaydi (`GET /company/history` aslida `audit.view` talab qiladi)
- [ ] (ma'lum cheklov) `mw.RequireAnyPermission` (OR) bilan qo'riqlangan endpointlarda swag faqat bitta kalit ko'rsatadi (swag OR sintaksisiga ega emas) — `GET /unidentified-events`, `GET /permissions`
- [ ] `/reports/activity` va `/reports/distance-by-region` k6 o'lchovi deyarli bo'sh ma'lumot ustida bo'lgan (telemetriya/agregat seed qilinmagan) — haqiqiy hajmda qayta o'lchash kerak

### 9.5 To'liq integratsiya tekshiruvi ✅
- [x] **`go test -tags integration ./internal/...` — 37 paket, 0 xato** (barcha parallel bosqichlardan keyin regressiya yo'q)
- [x] Eslatma: to'g'ri DSN `postgres://postgres:postgres@127.0.0.1:55432/eld_test` (`make test-env-up` chiqaradi) — noto'g'ri baza nomi bilan testlar 120 s timeout beradi

**Chiqish mezoni (TZ D§6):** DoD barcha bandlari · cross-tenant 404 · brute-force lockout · PII loglarda yo'q · NFR yuk testi o'tdi.

---

## API kontraktdan chetlashishlar — TZ ga CR kerak
Barchasi **qo'shimcha** (kontraktdagi hech bir endpoint yetishmayapti):
- [ ] `DELETE /company/branches/{id}` — kontraktda DELETE yo'q
- [ ] `POST /users/{id}/activate|deactivate` — kontraktda users uchun yo'q
- [ ] `GET /units/import-template`, `GET /drivers/import-template`
- [ ] `GET /drivers/{id}/license` — PII-sezgir (shifrlangan license_no), xavfsizlik ko'rigi kerak
- [ ] `DELETE /drivers/{id}/co-drivers/{co_driver_id}` vs kontraktdagi `DELETE /drivers/{id}/co-drivers` — ikkalasi ham ro'yxatda, bittasini tanlash kerak
- [ ] `GET /units/{id}/diagnostics`, `GET /units/{id}/history`

## Texnik qarz (keyingi bosqichda hal qilinadi)
- [ ] **Arxitektura:** 15 ta `service*.go` `internal/db` ni import qiladi (repo interfeyslari `db.XxxRow` qaytaradi) — "service DB haqida bilmaydi" konventsiyasidan chetlashish. Katta refaktoring, alohida vazifa
- [x] ~~`gocyclo > 20`~~ — 9-bosqichda barcha 7 funksiya bo'lindi
- [x] ~~258 lint muammosi~~ — 9-bosqichda **127 → 1** ga tushirildi
- [ ] Ishlatilmaydigan sqlc query'lar: `audit.sql:ListCompanyHistory`, `users.sql:GetUserByUsername`, `GetUserByEmail`
- [x] ~~400+ qatorli fayllar~~ — 9-bosqichda 7 fayl bo'lindi, hammasi <400 qator
- [x] `internal/testutil` — `TEST_DATABASE_URL`/`TEST_REDIS_URL` bilan umumiy konteyner; migratsiya va `eld_app` roli idempotent (advisory lock bilan). Natija: paket boshiga **7.02 s → 1.37 s**. `make test-env-up` / `test-integration-fast` / `test-env-down`
- [ ] `db/queries/audit.sql` dagi ishlatilmaydigan `ListCompanyHistory` (o'rniga `ListCompanyAuditHistory`) — audit moduli bosqichida tozalansin

## Doimiy qoidalar
- Har PR: `golangci-lint` → `swag init` + `git diff --exit-code docs/` → `oasdiff breaking` → `go test`
- Migratsiyalar forward-only; mavjudini tahrirlash taqiq
- Endpoint TZ D§3 jadvalidan chetlashsa — avval TZ CR
- `internal/hos`, `internal/sync` — faqat stdlib

---

## Ochiq savollar / qabul qilingan taxminlar (buyurtchi tasdig'i kerak)

HOS engine yozilishida TZ da aniq bo'lmagan joylar — kod shu taxminlar bilan ishlaydi, tasdiqlangach TZ ga CR kiritiladi:

- [ ] **Split sleeper va 14h oyna.** TZ (Q10.6) faqat uzun qism 14h oynani to'xtatadi deydi; FMCSA 2020 esa ikkala qismni ham hisobga olmaydi. Kod **TZ bo'yicha** ishlaydi.
- [ ] **Split juftligi** to'liq daily-rest ekvivalenti (reset) sifatida qaraladi, FMCSA uslubidagi "birinchi dam olish oxiridan qayta hisoblash" emas.
- [ ] **7h SB / 2h juftlik chegaralari** policy kaliti emas, paket konstantasi (`SplitMinSleeperMin`, `SplitMinPartnerMin`).
- [ ] **PC** daily rest, break va cycle restart yig'ishida OFF sifatida hisoblanadi.
- [ ] **`shift_limit` va `cycle_limit` violation faqat DR bo'lganda** yoziladi (ON — faqat warning), Q57 jadvali matniga ko'ra.
- [ ] **Recap "ertaga qaytadigan soat"** = `cycle_days − 1` kun oldingi kun (TZ matnidagi "cycle_days kun oldingi kun" oynadan tashqarida qolar edi).
- [ ] **Birinchi eventdan oldingi tarix** = OFF va to'liq dam olgan holat.
- [ ] **Timescale columnstore (siqish) RLS bilan ishlamaydi** — `telemetry` siqilmaydi, faqat 90 kunlik retention. Katta hajmda disk xarajati oshadi; muqobil: RLS'ni telemetry uchun ilova qatlamiga tashlash (tavsiya etilmaydi) yoki siqishsiz qoldirish.
- [ ] **Continuous aggregate (`telemetry_1min/5min`) — VIEW, RLS qo'llanmaydi** → bu view'larga murojaat qiluvchi har query'da `company_id = $1` sharti majburiy (kod ko'rigida tekshiriladi).
- [ ] **`hos-test-vectors.json` formati** kengaytirildi (`day` ixtiyoriy, `policy` — qisman override, `driving_time_left_min`). Dart porti shu formatni ishlatadi — o'zgarsa CR kerak.

---

## Frontend TZ dan chiqqan backend CR nomzodlari
`tz-admin-frontend.md` yozilishida aniqlangan — API `v1` muzlatilgani uchun MVP'da vaqtinchalik yechim bilan ishlanadi, keyingi versiyada CR sifatida ko'rib chiqilsin:
- [ ] `GET /users/export` yo'q (drivers va units uchun bor)
- [ ] Unit bo'yicha loglarni olish endpointi yo'q → frontend `tracking/live` + `hos-summary` kompozitsiyasi bilan yechadi
- [ ] Global qidiruv endpointi yo'q (har modulda alohida `search` bor)
- [ ] WS xabarlarida `company_id` qaytmaydi (klient tomonda tekshirish uchun foydali bo'lardi)
- [ ] `routes.status` enum'i dizayn va backend orasida ikki xil nomlangan
- [ ] Refresh token uchun httpOnly cookie berilmaydi → frontend `sessionStorage` ishlatadi (XSS yuzasi kengroq)
- [ ] `/api/v1/ws` da kanal bo'yicha xato kodlari hujjatlashtirilgan, lekin `close code` lar standartlashtirilmagan

