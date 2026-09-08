# testutil — integration test harness

Every integration package (`internal/domain/{companies,company,drivers,files,fleet,users}`,
`internal/testutil`) calls `testutil.RunMain(m)` from its `TestMain`. That gives each
package a Postgres (TimescaleDB) and a Redis it can talk to. Where those come from is
decided by two environment variables.

## Slow path (default) — one container set per package

```sh
make test-integration     # go test -tags=integration ./...
```

With no env vars set, every test binary starts its own Postgres + Redis via
testcontainers and applies all migrations from scratch. Correct but slow: the container
start plus 18 goose migrations are paid once per package, so the full run takes
10+ minutes.

## Fast path — one shared stack for every package

```sh
make test-env-up            # postgres on :55432, redis on :56379, migrated once
make test-integration-fast  # runs ./... against that stack
make test-env-down          # remove the containers when you are done
```

`test-env-up` prints the exports if you would rather drive `go test` yourself:

```sh
export TEST_DATABASE_URL='postgres://postgres:postgres@127.0.0.1:55432/eld_test?sslmode=disable'
export TEST_REDIS_URL='redis://127.0.0.1:56379/0'
go test -tags integration -count=1 ./internal/domain/fleet/...
```

## Environment variables

| Variable | Effect |
| --- | --- |
| `TEST_DATABASE_URL` | Superuser DSN of an already running Postgres. No container is started, migrations run only when the schema is behind, and `Shutdown` leaves the server alone. |
| `TEST_APP_DATABASE_URL` | Optional. Overrides the `eld_app` DSN, which is otherwise derived from `TEST_DATABASE_URL` by swapping the credentials. |
| `TEST_REDIS_URL` | `redis://` URL of an already running Redis. Same reuse semantics. |
| `TEST_POSTGRES_IMAGE` / `TEST_REDIS_IMAGE` | Pin the images used on the slow path. |

## Why sharing one database is safe

Isolation is per **company** (`company_id`), never per schema: fixtures create a fresh
company per test and the RLS policies are what keep tests apart. So a database reused
across packages behaves exactly like a fresh one.

Two things are made idempotent so parallel test binaries can share it:

* `applyMigrations` compares `max(version_id)` in `schema_migrations` against the newest
  file in `db/migrations` and skips `goose.Up` when the schema is current.
* `provisionAppRole` skips its DDL when `eld_app` already exists with the right flags and
  `app_role` membership.

Both are wrapped in a Postgres session advisory lock, so the first binary migrates and
the others wait rather than racing.

## Caveats

* `testutil.Truncate` empties a table for the **whole database**, not just one company.
  It works against a shared server, but a package that truncates a table can wipe rows a
  concurrently running package is using. Prefer `CountIn`/per-company assertions; if you
  must truncate, do it in a test that is not `t.Parallel()` and keep the table list
  narrow. `audit_log` cannot be truncated (append-only trigger).
* The shared stack is not reset between runs. `make test-env-down && make test-env-up`
  gives you a clean database.
