# k6 load tests

NFR verification for the ONEBOOK ELD API (TZ B§8): list endpoints must answer at
**p95 ≤ 300 ms**, report endpoints at **p95 ≤ 800 ms**, with an error rate below 1 %.

## Install

```bash
brew install k6            # macOS
# or: docker run --rm -i grafana/k6 run - < deploy/k6/smoke.js
```

## Scripts

| Script        | Purpose                                                                    |
|---------------|----------------------------------------------------------------------------|
| `smoke.js`    | 1 VU / 1 iteration: `/health`, `/ready`, 401 on an anonymous list, login, one page of every list endpoint, plus a PII guard on the bodies. Use it as a deploy gate. |
| `list_p95.js` | Ramped load against the list endpoints plus a parallel report scenario; fails the run when a latency threshold is crossed. |

## Environment

| Variable            | Default                 | Meaning                                        |
|---------------------|-------------------------|------------------------------------------------|
| `BASE_URL`          | `http://localhost:8080` | API base URL, no trailing slash                 |
| `USERNAME`          | `admin`                 | Login username                                  |
| `PASSWORD`          | –                       | Login password (required)                       |
| `COMPANY`           | –                       | Optional `company_id` (uuid) hint sent with the login, for a username that exists in more than one tenant |
| `VUS`               | `50`                    | Peak virtual users (`list_p95.js`)              |
| `DURATION`          | `3m`                    | Plateau duration (`list_p95.js`)                |

Never point these at production with a real user: the load scenario issues
thousands of authenticated requests.

## Run

```bash
# 1. Smoke test against a local stack (make docker-up first).
k6 run -e BASE_URL=http://localhost:8080 -e USERNAME=admin -e PASSWORD=secret \
       deploy/k6/smoke.js

# 2. NFR load test against staging.
k6 run -e BASE_URL=https://staging.example.com -e USERNAME=loadtest \
       -e PASSWORD="$LOADTEST_PASSWORD" -e VUS=50 -e DURATION=3m \
       deploy/k6/list_p95.js

# 3. Machine readable summary for CI.
k6 run --summary-export=k6-summary.json deploy/k6/list_p95.js
```

## Reading the result

`list_p95.js` defines the budget as k6 thresholds, so a violation makes k6 exit
with code 99 and prints the offending metric:

```
✗ list_latency..............: p(95)=412ms  (threshold p(95)<300 FAILED)
```

`list_latency` and `report_latency` are custom trends; per endpoint numbers are
tagged with `name="GET /api/v1/units"` and show up in the `http_req_duration`
breakdown, which is where to look when the aggregate p95 regresses.

The report scenario always exercises `/reports/activity`,
`/reports/distance-by-region` and `/reports/uncertified-logs` — the only three
report endpoints registered in the router — each with the query parameters it
actually requires (`from`/`to` for the first, `quarter`/`year` for the
second, none for the third). Update `REPORT_ENDPOINTS`/`REPORT_QUERY` in
`list_p95.js` together if a new report endpoint is added; `LIST_ENDPOINTS` in
`smoke.js` is the one list kept in sync with `internal/domain/*/http.go` by
hand — re-check it after adding or renaming a list route.

## Seed data

The p95 targets only mean something against a realistic dataset. Point the run
at an environment with at least a few thousand `units` / `drivers` /
`duty_status_events` rows for the tenant you log in as; an empty database will
pass any threshold.

For a local run against `make test-env-up`'s stack, `seed.sql` does this for
you — 3000 units, 1200 drivers, ~3000 rows each of dvir_reports/violations/
notifications, 12000 daily_logs, etc., under one fixed company, plus a
`k6admin` / `office1..300` login pool (idempotent; a second run is a no-op):

```bash
docker exec -i eld-test-pg psql -U postgres -d eld_test < deploy/k6/seed.sql
```

It does not seed `telemetry` (TimescaleDB hypertable) or
`unit_region_distance_daily` (needs `regions` PostGIS rows) — `/reports/activity`
and `/reports/distance-by-region` therefore run against near-empty data in
this pass; only `/reports/uncertified-logs` (backed by `daily_logs`) is
measured at realistic scale.

## Multiple accounts under load (USER_POOL_*)

`list_p95.js` logs in once and hands that single token to every VU by
default — fine at low VUS, but every request then shares **one account's**
rate limit bucket (`DefaultPerUserPerMinute` = 600/min). Above roughly 10 VUs
sustained, the run degrades into a 429 flood instead of a latency
measurement. `USER_POOL_PREFIX`/`USER_POOL_SIZE` log in as
`USER_POOL_PREFIX1..N` instead (matches `seed.sql`'s `office1..300`) and
spread VUs across them:

```bash
k6 run -e BASE_URL=http://127.0.0.1:8080 -e USERNAME=k6admin \
       -e PASSWORD='Load-Test-Passw0rd!' -e USER_POOL_PREFIX=office \
       -e USER_POOL_SIZE=8 -e VUS=20 -e DURATION=45s deploy/k6/list_p95.js
```

**Found bug, budget accordingly:** `internal/middleware/ratelimit.go`'s
`LoginRateLimit` hard-codes 5 logins/minute/IP; `RATE_LIMIT_LOGIN` only
reaches the separate `internal/auth.Guard` lockout further inside the login
service, not this HTTP-level gate in front of it. `setup()` therefore paces
pool logins at `LOGIN_PACING_MS` (default 12500 ms) regardless of how high
`RATE_LIMIT_LOGIN` is set on the server, and `setupTimeout` is raised to 5m to
give it room. A pool of 8 takes ~90s to log in before the load stages start —
budget `--setup-timeout`/your CI job timeout accordingly, or pre-seed a
smaller pool for a quick check.
