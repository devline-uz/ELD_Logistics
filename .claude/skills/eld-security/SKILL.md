---
name: eld-security
description: ELD backend xavfsizlik bazasi — auth/token/sessiya, RBAC va scope, tenant izolyatsiyasi (RLS), shifrlash, rate limit, audit, OWASP ASVS L2 tekshiruv ro'yxati. Auth, middleware yoki xavfsizlik ko'rigida majburiy.
---

# Xavfsizlik bazasi (TZ B§3, A§16, D§6.5)

## Token va sessiya
- Access: JWT HS256/EdDSA, **15 daqiqa**. Claim'lar: `sub` (user_id), `cid` (company_id, super admin uchun null), `rid` (role_id), `scope` (company/branch/self), `bid` (branch_id), `sid` (session_id), `dt` (device_type), `exp`, `iat`, `jti`.
- Refresh: **opaque random 32 bayt**, DB'da faqat `sha256` hash (`sessions.refresh_token_hash`). Driver 30 kun **sliding**, Admin 7 kun.
- `expires_at = min(muddat, company.subscription_end_at + 7 kun grace)`.
- **Rotation**: har refresh'da yangi token, eskisi bekor. Eski token qayta ishlatilsa → **butun sessiya bekor** + audit `token_reuse`.
- Session policy: bitta user uchun `device_type` bo'yicha bittadan (1 web + 1 phone + 1 tablet). Yangi login o'sha turdagi eskisini `revoked` qiladi, javobda `replaced_session: true`.
- Bekor qilish sabablari: logout, Leave Truck (`paused`), user inactive, parol o'zgarishi, permission o'zgarishi.
- PIN (6 xona, Argon2id hash) — Switch / Return to truck uchun (`POST /auth/pin/verify`).

## Parol va 2FA
- Argon2id: `time=3, memory=64MB, threads=4, keyLen=32`, random 16-bayt salt; format `$argon2id$v=19$m=65536,t=3,p=4$<salt>$<hash>`.
- Parol ≥10 belgi, harf+raqam. Parol faqat invitation orqali o'rnatiladi (link 72 soat, token DB'da hash).
- 2FA TOTP (`pquerna/otp`) — Super Admin va Administrator uchun **majburiy**; 10 ta recovery kod (hash). `totp_secret_enc` — AES-256-GCM.
- Brute-force: login **5/min/IP** + **10/soat/akkaunt** → `locked_until` 15 daqiqa + adminга alert. `failed_logins` sanaladi.

## RBAC
- Permission kalitlari — TZ A§16 Q82 ro'yxati (`units.read`, `logs.propose_edit`, `company.update` …). Bitta Go const bloki `internal/auth/permissions.go`.
- Middleware `RequirePermission("units.create")` — role_permissions Redis'da keshlanadi (TTL 5 daq, rol o'zgarganda invalidate).
- Scope: `company` — butun kompaniya; `branch` — har query `branch_id` filtri bilan; `self` (Driver) — faqat `driver_id = me`.
- Audit-muhim modullarda (`logs`, `dvir`, `violations`, `telemetry`, `audit_log`) `delete` permission **yo'q** va DELETE endpoint yozilmaydi.

## Tenant izolyatsiyasi [MUST] — ikki qatlam
1. **App**: har repo query'da `company_id = $ctx`; `company_id` faqat JWT'dan. Super Admin `X-Company-Id` header bilan tanlaydi (faqat `company_id IS NULL` bo'lgan userlar uchun).
2. **DB RLS**: har tenant jadvalida
   ```sql
   ALTER TABLE units ENABLE ROW LEVEL SECURITY;
   ALTER TABLE units FORCE ROW LEVEL SECURITY;
   CREATE POLICY tenant_isolation ON units USING (company_id = current_setting('app.company_id', true)::uuid);
   ```
   Har tranzaksiya boshida `SET LOCAL app.company_id = $1`. Ilova roli **superuser/BYPASSRLS emas**.
3. Cross-tenant so'rov → **404** (403 emas — mavjudlikni oshkor qilmaslik).

## Shifrlash va sirlar
- TLS 1.2+ har joyda; HSTS.
- AES-256-GCM (`crypto/aes`+`cipher.NewGCM`, random 12-bayt nonce, `internal/crypto`): `drivers.license_no_enc`, `users.totp_secret_enc`, `signatures.image_key_enc`.
- Kalitlar env/secret manager'dan (`ENCRYPTION_KEY`, `JWT_SECRET`) — kodda hech qachon hardcode emas, `.env` faqat dev; `.env` **gitignore**.
- Fayllar: presigned URL 15 daqiqa, server faqat `key` saqlaydi; `POST /files/presign` `kind` oq ro'yxati (dvir_photo/invoice/signature/logo/chat/import), content-type va max size tekshiruvi.

## API himoyasi
- Rate limit (Redis): login 5/min/IP + 10/soat/akkaunt; umumiy **600 req/min/user**; `sync/push` **60/min/device**. `429` + `Retry-After`.
- Body limit: umumiy 1 MB, sync/push 10 MB. Batch chegarasi: ≤500 event, ≤5000 telemetriya.
- Idempotency: `Idempotency-Key` header (POST'larda ixtiyoriy, sync'da majburiy) — Redis 24 soat.
- CORS: aniq origin oq ro'yxati (env), `credentials` yo'q (Bearer token).
- Xavfsizlik header'lari: `X-Content-Type-Options`, `X-Frame-Options: DENY`, `Referrer-Policy`, `Content-Security-Policy` (docs uchun yumshoq).
- SQL — faqat parametrlangan (sqlc); string konkatenatsiya **taqiq** (sort/filter — oq ro'yxat).
- WS auth: `Authorization: Bearer` header YOKI ulanishdan keyingi birinchi `auth` xabari. **URL query'da token TAQIQ.** Ping/pong 30 s, 2 o'tkazilsa uzish. Har `subscribe` da obyekt egaligi tekshiriladi.

## Audit
`audit_log` **append-only**: ilova DB roli uchun `REVOKE UPDATE, DELETE ON audit_log`. Yoziladi: har CRUD (old/new JSONB), login/logout/failed_login, permission o'zgarishi, eksport (kim nimani yukladi), log-edit request, hos_policy o'zgarishi, token_reuse, cross-tenant urinish.

## Ko'rik chek-listi (OWASP ASVS L2)
1. Har endpointda authn + permission + scope bormi?
2. `company_id` body/query'dan olinmayaptimi?
3. IDOR: `:id` bo'yicha olishda `company_id` shartida bormi?
4. Mass-assignment: DTO'da faqat ruxsat etilgan maydonlar (status/role/company_id klient'dan kelmaydi)?
5. Parol/token/PII javobda yoki logda chiqmayaptimi?
6. Xato xabari ichki detal (SQL, stack) oshkor qilmayaptimi?
7. Rate limit va lockout bormi?
8. Fayl yuklashda kind/size/content-type tekshiruvi bormi?
9. Migratsiyada RLS policy yaratilganmi va `FORCE` qo'yilganmi?
10. Audit yozuvi bormi?
11. Random — `crypto/rand` (`math/rand` taqiq)?
12. Taqqoslash — `subtle.ConstantTimeCompare` (token/PIN)?
