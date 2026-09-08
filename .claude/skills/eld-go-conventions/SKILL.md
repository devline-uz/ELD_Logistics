---
name: eld-go-conventions
description: ONEBOOK ELD backend uchun majburiy Go stack, papka tuzilmasi, qatlamlar, xato formati, logging, test va Definition of Done qoidalari. Har qanday Go fayl yozishdan/o'zgartirishdan OLDIN o'qi.
---

# ELD Backend — Go konventsiyalari (TZ B§6.1, D§6)

Ildiz: `backend/`. Module: `github.com/devline/onebook-eld`. Go 1.23+ (mahalliy toolchain 1.25).

## Stack (o'zgartirish MUMKIN EMAS)
| Qatlam | Kutubxona |
|---|---|
| Router | `github.com/go-chi/chi/v5` (+ `chi/middleware`) |
| Swagger | `github.com/swaggo/swag`, `github.com/swaggo/http-swagger` |
| Validatsiya | `github.com/go-playground/validator/v10` |
| DB | `github.com/jackc/pgx/v5` (pool) + **sqlc** (ORM YO'Q) |
| Migratsiya | `github.com/pressly/goose/v3` (SQL, forward-only) |
| WS | `github.com/gorilla/websocket` + Redis pub/sub |
| Queue/Cron | `github.com/hibiken/asynq` |
| Cache | `github.com/redis/go-redis/v9` |
| Auth | `github.com/golang-jwt/jwt/v5`, `golang.org/x/crypto/argon2` (Argon2id), `github.com/pquerna/otp` |
| Config | `github.com/caarlos0/env/v11` |
| Log | stdlib `log/slog` (JSON handler) |
| Test | `testing` + `github.com/stretchr/testify` + `github.com/testcontainers/testcontainers-go` |
| Geo | PostGIS (SQL) + `github.com/paulmach/orb` |
| Excel/PDF | `github.com/xuri/excelize/v2`, `github.com/chromedp/chromedp` |
| Rate limit | Redis (`go-redis`) asosida sanoq |

## Papka tuzilmasi (qat'iy)
```
backend/
  cmd/api/main.go          HTTP+WS server
  cmd/worker/main.go       asynq worker + scheduler
  cmd/migrate/main.go      goose wrapper
  db/migrations/*.sql      goose
  db/queries/*.sql         sqlc manbasi
  internal/db/             sqlc chiqishi (generated, qo'lda tegilmaydi) + pool
  internal/config/         env config
  internal/apierr/         xato kodlari (bitta const bloki) + ErrorResponse
  internal/httpx/          javob yozish, pagination, decode+validate helperlari
  internal/middleware/     auth, tenant, permission, ratelimit, requestlog, recover
  internal/auth/           login, token, session, 2FA, PIN, invitation
  internal/tenant/         company_id konteksti + `SET LOCAL app.company_id`
  internal/audit/          audit_log yozuvchi
  internal/hos/            HOS engine — FAQAT stdlib, DB yo'q, golden testlar
  internal/sync/           offline sync (push/pull, idempotency, konflikt) — stdlib
  internal/domain/<name>/  dto/ service.go repo.go http.go
  internal/ws/             hub, kanallar
  internal/notify/         Notifier interfeysi (push/email/sms/telegram)
  internal/geo/            GeoProvider interfeysi
  internal/jobs/           asynq task'lar
  pkg/eldproto/            ELD qurilma protokoli parserlari
  docs/                    swag chiqishi (commit qilinadi) + websocket.md
  docs/history/            bosqich swagger.json nusxalari (oasdiff)
  deploy/                  Dockerfile, docker-compose.yml, GitHub Actions
```

## Qatlam qoidalari [MUST]
1. Har domen paketida: `dto/` (request/response struct), `service.go` (biznes), `repo.go` (sqlc chaqiruvlari), `http.go` (handler + swag annotatsiyalar).
2. **sqlc modeli hech qachon javobga chiqmaydi** — faqat DTO. DTO→domain konvertatsiya `service.go` yoki `dto/map.go` da.
3. `company_id` va `*auth.Principal` **faqat kontekstdan** olinadi (`tenant.CompanyID(ctx)`), so'rov body/query'dan EMAS.
4. Har DB tranzaksiya `SET LOCAL app.company_id = $1` bilan boshlanadi (RLS ikkinchi qatlam).
5. `internal/hos` va `internal/sync` — tashqi bog'liqliksiz (faqat stdlib), chunki Dart portiga mos bo'lishi kerak.
6. Handler biznes-logika yozmaydi; service DB haqida bilmaydi (repo interfeysi orqali).
7. Barcha vaqtlar `time.Time` UTC; DB'da `timestamptz`. Masofa — metr (`_m`), tezlik — km/h. UI konvertatsiyasi backendda emas.
8. Kontekst har doim birinchi argument: `func (s *Service) Create(ctx context.Context, in dto.X) (*dto.Y, error)`.

## Xatolar
- Barcha kod `internal/apierr` dagi **bitta const blokida**: `VALIDATION_ERROR`, `UNAUTHORIZED`, `FORBIDDEN`, `NOT_FOUND`, `CONFLICT`, `UNIQUE_VIOLATION`, `RATE_LIMITED`, `ACCOUNT_INACTIVE`, `DR_IMMUTABLE`, `LOG_NOT_READY`, `TIME_IN_FUTURE`, `DUPLICATE_EVENT`, `SESSION_REPLACED`, `INVALID_CREDENTIALS`, `TOTP_REQUIRED`, `LOCKED_OUT`, `SUBSCRIPTION_READONLY` …
- Javob shakli:
```json
{"error":{"code":"VALIDATION_ERROR","message":"...","details":[{"field":"unit_number","message":"required"}]}}
```
- HTTP: 400 noto'g'ri so'rov · 401 auth yo'q · 403 permission/tenant · 404 topilmadi (cross-tenant ham **404**) · 409 konflikt · 422 validatsiya · 429 rate limit.
- `apierr.E` tipi: `Code`, `HTTPStatus`, `Message`, `Details`, `Err` (wrap). `errors.As` bilan `httpx.WriteError` markazlashgan javob beradi.

## Logging
`slog` JSON; har so'rovda `request_id`, `user_id`, `company_id`, `method`, `path`, `status`, `dur_ms`. **PII (parol, token, license_no, telefon, email, lat/lng) loglanmaydi** — mask helper `internal/httpx/mask.go`.

## Pagination / filtr
`?page=1&per_page=25` (10/25/50, max 100), javob: `{"data":[...],"meta":{"page":1,"per_page":25,"total":123}}`. Saralash `?sort=field&order=asc|desc` (oq ro'yxat). Filtr — aniq nomlangan query paramlar.

## Test
- Sof paketlar (`hos`, `sync`, permission) — jadval testlar, golden JSON.
- Repo/integratsiya — `testcontainers-go` (postgres+timescale+postgis image), har test o'z sxemasida.
- Har PR: `go vet ./...`, `golangci-lint run`, `go test ./...` yashil.

## Definition of Done (har vazifa)
kod kompilyatsiya bo'ladi (`go build ./...`) · `go vet` toza · unit test bor (hos/permission/sync majburiy) · swag annotatsiyasi to'liq · DTO'da `example` teglari · migratsiya bor · audit_log yozuvi bor · xato kodlari `apierr` da · PII loglanmaydi.

## Kod uslubi
Ortiqcha izoh yozma; izohlar — faqat `Q<raqam>` TZ qoidasiga havola (masalan `// Q10.4: break qoidasi`). Fayl 400 qatordan oshsa bo'l. Nomlar inglizcha, izohlar inglizcha.

## Uzoq buyruqlar — QAT'IY QOIDA (watchdog)
Bitta tool chaqiruvi **5 daqiqadan oshmasin**. 600 s jimlik agentni o'ldiradi va ish uziladi.

- `go test -tags integration ./...` ni **HECH QACHON** butun loyiha bo'yicha ishlatma — har paket o'z Postgres+Redis konteynerini ko'taradi va migratsiyalarni qayta qo'llaydi.
- To'g'ri: **bitta paket, bitta chaqiruv**, har doim timeout bilan:
  `go test -tags integration -count=1 -timeout 240s ./internal/domain/<sening_paketing>/...`
- Test 4 daqiqadan uzoq bo'lsa `-run 'TestX|TestY'` bilan bo'lib ishlat.
- `go build ./...` ni har o'zgarishdan keyin emas, faqat o'z paketing uchun (`go build ./internal/domain/<x>/...`), to'liq buildni ish oxirida bir marta.
- Docker image tortish kerak bo'lsa alohida chaqiruvda (`docker pull ...`), test bilan aralashtirma.
- Har 2–3 daqiqada kamida bitta tool chaqiruvi bo'lsin — uzoq "o'ylash" ham uzilishga olib keladi.
