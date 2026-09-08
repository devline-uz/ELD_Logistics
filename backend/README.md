# ONEBOOK ELD — backend

Multi-tenant ELD / fleet management API. Go 1.23, chi, pgx + sqlc, goose, asynq, Redis.

## Status: `v1` frozen

All 10 stages (TZ v2.2 timeline) are implemented and reviewed:

1. Foundation — config, error envelope, auth (login, refresh, 2FA, PIN, sessions), RBAC/tenant middleware.
2. Fleet & drivers — units, drivers, ELD devices, trailers, shipping documents, co-drivers.
3. HOS engine & duty status — `internal/hos` (stdlib only), daily logs, certification, violations.
4. Offline sync & telemetry — `internal/sync` (push/pull, idempotency, conflicts), `pkg/eldproto` device parsers.
5. Realtime — WebSocket hub (Redis pub/sub bridge), live tracking, chat, notifications.
6. DVIR & maintenance — inspections, defect types, maintenance schedules.
7. Routes & reporting — trip planner, report exports (CSV/XLSX/PDF), region distance rollups.
8. Support & audit — support tickets/feedback, `audit_log`, retention sweeps.
9. Hardening — golangci-lint (0 issues), permission matrix (153 gated operations × 8 default roles = 1224 checks, 0 mismatches), k6 NFR runs, OWASP ASVS L2 pass.
10. Freeze — pagination/permission-catalogue cleanup, branch-scope gaps closed, `docs/swagger.json` → `docs/history/v1.0.json`, this README.

**API surface:** 125 paths, 166 operations, 320 schema definitions (`docs/swagger.json`). Every operation carries `@x-permission`; every scalar DTO field carries an `example`. See `docs/api-review.md` for the full pre-freeze contract review and the `v1` decisions log.

## Quick start

```bash
cp .env.example .env          # adjust DATABASE_URL / REDIS_URL if needed
make docker-up                # postgres (timescale) + redis + api + worker
# or run against local services:
make migrate-up && make run
```

### Dev

```bash
make docker-up          # postgres+timescale+postgis, redis, api, worker (deploy/docker-compose.yml)
make docker-logs        # tail api + worker
make docker-down        # stop (make docker-clean to also drop volumes)
```

Or run the Go binaries directly against local/dockerised Postgres+Redis:

```bash
make migrate-up          # apply db/migrations (goose)
make run                 # cmd/api on :8080 (APP_ENV=local by default, see .env.example)
make run-worker          # cmd/worker (asynq: alerts, retention, reports, telemetry rollups)
```

### Test

```bash
make test                     # unit tests (internal/hos, internal/sync, permission tables, ...)
make test-env-up              # one-time: start the shared postgres+redis test stack + migrate it
make test-integration-fast    # testcontainers-free integration tests against that shared stack
make test-matrix              # permission matrix (153 ops × 8 roles) + HTTP contract tests
make cover                    # unit tests + coverage report
make test-integration         # integration tests, each package provisions its own testcontainers
```

`make test-integration-fast` / `make test-matrix` need `make test-env-up` first; both read
`TEST_DATABASE_URL` / `TEST_REDIS_URL` (printed by `test-env-up`). `make test-integration` needs
no shared stack — every package brings up its own Postgres+TimescaleDB+PostGIS and Redis
containers via `testcontainers-go` — but never run it with `-tags integration ./...` in one
invocation; run one package at a time or use the Makefile targets, which already scope it
correctly.

### Prod

```bash
docker build -f deploy/Dockerfile --target api -t onebook-eld-api .
docker build -f deploy/Dockerfile --target worker -t onebook-eld-worker .
docker build -f deploy/Dockerfile --target migrate -t onebook-eld-migrate .
```

Multi-stage, distroless (`gcr.io/distroless/static-debian12:nonroot`) final images, `CGO_ENABLED=0`.
Run `migrate` once against the production database before starting `api`/`worker`. See
`deploy/docker-compose.yml` for the full wiring (Postgres+TimescaleDB+PostGIS, Redis, api, worker)
and `.env.example` for every required/optional variable. `APP_ENV=staging|prod` turns a handful of
defaults (open `/metrics`, `/api/docs/*`, permissive CORS) into hard startup errors — see
"Quick start" above and the `METRICS_*`/`DOCS_*` table below.

* API: `http://localhost:8080/api/v1`
* Swagger UI: `http://localhost:8080/api/docs/index.html`
* Raw spec: `http://localhost:8080/api/docs/swagger.json`
* Probes: `/health` (liveness), `/ready` (db + redis), `/metrics` (Prometheus)

`/metrics` and `/api/docs/*` leak internal detail (endpoint names, traffic
volume, the Go runtime, the whole API surface), so they are gated by
`METRICS_*` / `DOCS_*`:

| Variable | Meaning |
|---|---|
| `METRICS_ENABLED` / `DOCS_ENABLED` | `false` answers 404 |
| `METRICS_TOKEN` / `DOCS_TOKEN` | required credential, sent as `Authorization: Bearer …` (never in the query string) |
| `METRICS_ALLOW_CIDR` / `DOCS_ALLOW_CIDR` | comma separated networks or addresses that skip the token |

With `APP_ENV=staging|prod` a surface that is enabled without a token and
without an allowlist is a **startup error**. In `local`/`dev` both stay open.

## Realtime (`WS_*`)

`GET /api/v1/ws` upgrades to the WebSocket hub. The handshake carries its own
credential (an `Authorization: Bearer …` header or a first `auth` frame) — a
token in the query string is rejected before the upgrade. Every process
publishes through a Redis pub/sub bridge, so a client attached to another API
node receives the same event. Channels are documented in `docs/websocket.md`.

| Variable | Default | Meaning |
|---|---|---|
| `WS_ENABLED` | `true` | `false` removes the `/ws` route entirely |
| `WS_ALLOWED_ORIGINS` | empty | browser origin allowlist; empty means same-origin only, `*` is development only |
| `WS_PING_PERIOD` | `30s` | server keepalive interval |
| `WS_PONG_WAIT` | `65s` | silence budget before the connection is dropped |

## Map provider (`GEO_*`)

`internal/geo` turns a coordinate into the FMCSA location text every log and
DVIR record carries (Q9) and draws the trip planner directions (Q66.1). Both
operations are cached (`GEO_CACHE_GRID_M`), so a deployment is billed once per
grid cell, not once per request. Without a working provider the process still
starts — reads degrade to the `nop` provider (empty location text, no route
geometry) with one warning, never a failure of the write path that triggered
the lookup.

| Variable | Default | Meaning |
|---|---|---|
| `GEO_PROVIDER` | `nominatim` | `nominatim` \| `photon` \| `google` \| `nop` |
| `GEO_GEOCODE_URL` | empty | self hosted Nominatim/Photon base URL |
| `GEO_ROUTING_URL` | empty | self hosted OSRM base URL (directions) |
| `GEO_API_KEY` | empty | Google Maps Platform key (`GEO_PROVIDER=google`) |
| `GEO_REGION` | empty | biases the Google geocoder, e.g. `us` |
| `GEO_USER_AGENT` | `onebook-eld/1.0` | required by the Nominatim usage policy |
| `GEO_CACHE_GRID_M` | `100` | reverse geocode cache cell size, metres |

## Notifications (`NOTIFY_*`)

Every alert goes through `internal/notify`: the dispatcher resolves the
recipients and the channels from the company's `notification_settings`, writes
the in-app row, publishes it on the `notifications` WebSocket channel and hands
it to each provider. **Every credential is optional** — a missing one disables
that channel with a warning instead of failing the boot, and the in-app inbox
is always written.

| Prefix | Channel | Key variables |
|---|---|---|
| `NOTIFY_FCM_` | push (Android / web) | `PROJECT_ID`, `SERVICE_ACCOUNT_FILE` or `SERVICE_ACCOUNT_JSON` |
| `NOTIFY_APNS_` | push (iOS) | `AUTH_KEY_FILE` or `AUTH_KEY`, `KEY_ID`, `TEAM_ID`, `TOPIC`, `PRODUCTION` |
| `NOTIFY_SMTP_` | email | `HOST`, `PORT`, `USERNAME`, `PASSWORD`, `FROM`, `STARTTLS` |
| `NOTIFY_SMS_` | sms | `ENDPOINT`, `TOKEN`, `TO_FIELD`, `TEXT_FIELD` |
| `NOTIFY_TELEGRAM_` | telegram | `BOT_TOKEN` |

The `*_FILE` variants read the secret from disk; the inline variants take
precedence. Secrets are never logged, only the failure to read them.

## Layout

```
cmd/api        HTTP + WebSocket server
cmd/worker     asynq worker + scheduler
cmd/migrate    goose wrapper over db/migrations
db/migrations  goose SQL migrations (forward-only in production)
db/queries     sqlc source queries
internal/config      env configuration
internal/apierr      error codes + apierr.E
internal/httpx       responses, decode+validate, pagination, PII masking
internal/httpx/dto   shared response envelopes used by swagger annotations
internal/tenant      principal + company_id context
internal/db          pgx pool, WithTx/WithConn, pg error mapping, sqlc output
internal/middleware  request id, logging, recover, CORS, auth, permissions
internal/audit       audit_log recorder
internal/ws          WebSocket hub + Redis pub/sub bridge
internal/notify      alert dispatcher, provider senders, domain alert adapters
internal/jobs        asynq task handlers and cron entries
internal/server      router assembly and the Module interface
docs/                swag output (committed, verified in CI)
deploy/              Dockerfile (distroless) + docker-compose
```

## Conventions

* `company_id` and the principal come **only** from the context
  (`tenant.CompanyID(ctx)`, `tenant.PrincipalFrom(ctx)`), never from the payload.
* Every write runs inside `db.Pool.WithTx`, which issues
  `SET LOCAL app.company_id` so RLS acts as a second line of defence.
* All error codes live in one const block in `internal/apierr`; handlers return
  `error` and `httpx.WriteError` renders the envelope.
* Times are UTC `timestamptz`, distances metres (`_m`), speeds km/h.
* PII (password, token, license, phone, email, coordinates) is never logged —
  use `internal/httpx/mask.go`. Serving a clear text licence number requires
  `drivers.license.view` and is written to `audit_log` as `license_reveal`.
* A super admin selects the tenant it operates on with the `X-Company-Id`
  header; `middleware.Authenticate` rejects that header with 403 for anybody
  else.
* Swagger is code-first: annotate the handler, then `make swag`. CI fails when
  `docs/` is stale. WebSocket channels are documented in `docs/websocket.md`.
* A lapsed subscription freezes the admin panel's write routes (TZ B§15,
  `middleware.RequireWritableSubscription`, 403 `SUBSCRIPTION_READONLY`). No
  domain package imports it: `cmd/api/writeguard.go` wraps the affected
  modules (fleet, drivers, company, users, routes, maintenance, support, the
  DVIR defect type catalogue, the log edit approve/reject step and queuing a
  report export) with a `chi.Router` decorator that adds the guard to their
  mutating routes only. The driver application, `/sync/*`, `/auth/*`,
  `/files/*`, `/chat/*` and the platform (super admin) routes are never
  wrapped, and the middleware itself lets a `self` scoped principal and a
  super admin through as a second line of defence.

## Adding a domain module

```go
package units

func (m *Module) RegisterRoutes(r chi.Router) {
    r.Route("/units", func(r chi.Router) {
        r.Use(middleware.Authenticate(m.verifier))
        r.With(middleware.RequirePermission("units.read")).Get("/", m.list)
        r.With(middleware.RequirePermission("units.create")).Post("/", m.create)
    })
}
```

Then pass it to `server.NewRouter(cfg, deps, unitsModule, ...)` in `cmd/api/main.go`.

## Common targets

Run `make help` for the live, self-documenting list. Summary:

| Target | Purpose |
|---|---|
| `make run` / `make run-worker` | run api / worker locally |
| `make build` | build `bin/api`, `bin/worker`, `bin/migrate` |
| `make tidy` | `go mod tidy` |
| `make test` / `make cover` | unit tests / unit tests + coverage report |
| `make test-env-up` / `make test-env-down` | start/stop the shared Postgres+Redis test stack |
| `make test-integration-fast` | integration tests against the shared stack (needs `test-env-up`) |
| `make test-matrix` | permission matrix + HTTP contract tests (needs `test-env-up`) |
| `make test-integration` | integration tests, each package provisions its own testcontainers |
| `make vet` / `make lint` / `make fmt` | go vet / golangci-lint / gofmt -s -w |
| `make check` | `vet` + `lint` + `test` |
| `make ci` | full local approximation of the CI pipeline (needs docker) |
| `make swag` / `make swag-check` | regenerate `docs/` / fail if `docs/` is stale |
| `make oasdiff` | fail when the current spec breaks the latest `docs/history/` snapshot |
| `make sqlc` | regenerate `internal/db` from `db/queries` |
| `make tools` | install swag, sqlc, golangci-lint, goose, oasdiff |
| `make migrate-up` / `make migrate-down` | apply / roll back one migration (local only) |
| `make migrate-status` / `make migrate-create name=x` | show status / scaffold a new goose migration |
| `make docker-up` / `make docker-down` | start / stop the local stack |
| `make docker-clean` / `make docker-logs` | stop + drop volumes / tail api+worker logs |
