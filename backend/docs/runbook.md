# ONEBOOK ELD — Operations runbook

Audience: whoever is on call. Every command is run from `backend/`.
Related: `deploy/docker-compose.yml`, `deploy/Dockerfile`, `deploy/prometheus.yml`,
`db/migrations/`, `docs/websocket.md`.

---

## 1. Services and their shape

| Process | Image target | What it does | Fails how |
|---|---|---|---|
| `api` | `deploy/Dockerfile` target `api` | HTTP + WebSocket (`/api/v1`, `/ws`) | stateless, safe to restart / scale horizontally |
| `worker` | target `worker` | asynq consumer **and** scheduler (cron) | stateless, but **run exactly one scheduler** |
| `migrate` | target `migrate` | goose wrapper, runs once per release | must finish before `api`/`worker` start |
| `postgres` | `timescale/timescaledb-ha:pg16` | Postgres 16 + TimescaleDB + PostGIS | the only stateful component |
| `redis` | `redis:7-alpine` | cache, rate limit counters, asynq queue, WS pub/sub | `maxmemory-policy noeviction` is mandatory — eviction loses queued jobs |

Health endpoints: `GET /health` (liveness, no dependencies) and `GET /ready`
(readiness: pings Postgres and Redis). Point the orchestrator's liveness probe at
`/health` and the readiness probe at `/ready`, never the other way round — a
brief database blip must not restart the process.

`/metrics` and `/api/docs` are gated by `METRICS_*` / `DOCS_*`
(`internal/middleware/gate.go`). `config.Validate` refuses to boot a staging or
production instance that exposes either without a token or a CIDR allow list.

---

## 2. Deploy

Ordering matters: **migrate → worker → api**. Migrations are forward-only and
backward compatible by rule, so a running old binary tolerates the new schema
for the length of the rollout.

```bash
# 1. Build and tag
docker compose -f deploy/docker-compose.yml build

# 2. Apply migrations (idempotent; safe to re-run)
docker compose -f deploy/docker-compose.yml run --rm migrate up

# 3. Roll the worker, then the API
docker compose -f deploy/docker-compose.yml up -d worker
docker compose -f deploy/docker-compose.yml up -d api

# 4. Verify
curl -fsS http://localhost:8080/health
curl -fsS http://localhost:8080/ready
```

Post-deploy checklist:

- [ ] `/ready` returns 200 on every replica.
- [ ] `make migrate-status` shows no pending migration.
- [ ] `eld_http_request_duration_seconds_count{status=~"5.."}` is flat.
- [ ] `eld_queue_latency_seconds` is falling back towards zero.
- [ ] `eld_ws_connections` recovers to roughly the pre-deploy level within a
      few minutes (clients reconnect with backoff).
- [ ] Swagger (`/api/docs/index.html`) matches the release tag.

### Rollback

Redeploy the previous image tag. **Do not run `goose down` to roll back a
release** — see §3.

---

## 3. Migrations

- Forward-only. Editing a migration that already ran anywhere is forbidden;
  write a new one.
- `goose down` exists for local development only. In production a bad migration
  is corrected with a new forward migration, because `down` on a table holding
  compliance data (`duty_status_events`, `daily_logs`, `audit_log`) destroys
  records the regulator expects to exist.
- `audit_log` is append-only at the database level: a trigger rejects `UPDATE`,
  `DELETE` and `TRUNCATE` for every role, superuser included. A migration that
  needs to touch it must drop the trigger explicitly and re-create it in the
  same transaction — and that needs a written reason in the PR.

```bash
make migrate-status          # what is applied
make migrate-up              # apply everything pending
make migrate-create name=x   # new empty migration
```

Long migrations: take the advisory lock into account — goose serialises itself,
so a second deploy started in parallel waits rather than corrupting the state.
For an index on a large table use `CREATE INDEX CONCURRENTLY` inside a
`-- +goose NO TRANSACTION` migration (see `00011_retention.sql` for the pattern).

---

## 4. Backup and PITR restore

### What is backed up

| Data | Mechanism | Window |
|---|---|---|
| Postgres (everything) | `pg_basebackup` nightly + WAL archiving | 30 days of PITR |
| Object storage (files, exports, signatures) | bucket versioning + lifecycle | 30 days |
| Redis | **not backed up** — it is a cache and a queue; a lost queue re-fills from the cron fan-outs | — |

Retention inside the database is enforced separately (TZ B§15):

- raw `telemetry` — 90 days, TimescaleDB retention policy (`00011_retention.sql`);
- `telemetry_1min` / `telemetry_5min` — 3 years, Timescale policy;
- `chat_messages` — 1 year, `jobs.TypeChatRetention`;
- `notifications` — 1 year, `jobs.TypeRetentionSweep`;
- `report_export_jobs` files — 24 hours, same sweep (the row survives, the
  `file_key` is cleared and the object deleted);
- expired `sessions` — same sweep;
- HOS records (`daily_logs`, `duty_status_events`, `dvir_reports`,
  `violations`, `audit_log`) — 3 years, never swept automatically.

Verify the Timescale policy survived a restore:

```sql
SELECT hypertable_name, schedule_interval, config
FROM timescaledb_information.jobs
WHERE proc_name = 'policy_retention';
-- `telemetry` must be present with drop_after = 90 days.
```

The worker calls `jobs.CheckTelemetryPolicy` at start-up and logs
`retention: telemetry policy missing` if it is gone — re-apply
`db/migrations/00011_retention.sql`.

### Nightly base backup

```bash
pg_basebackup -h $PGHOST -U replicator -D /backup/base/$(date +%F) \
  -Ft -z -Xs -P -c fast
```

WAL archiving (`postgresql.conf`):

```
wal_level = replica
archive_mode = on
archive_command = 'test ! -f /backup/wal/%f && cp %p /backup/wal/%f'
```

### Point-in-time recovery

Target: restore to just before the damaging statement.

```bash
# 1. Find the moment. audit_log is append-only, so it survives a bad UPDATE and
#    tells you when the damage started.
psql -c "SELECT ts, table_name, record_id, action, edited_by
         FROM audit_log WHERE ts > now() - interval '6 hours' ORDER BY ts;"

# 2. Stop the writers. Leave postgres up.
docker compose -f deploy/docker-compose.yml stop api worker

# 3. Restore the newest base backup that predates the target time.
systemctl stop postgresql
mv /var/lib/postgresql/16/main /var/lib/postgresql/16/main.broken
mkdir -p /var/lib/postgresql/16/main
tar -xzf /backup/base/2026-09-06/base.tar.gz -C /var/lib/postgresql/16/main

# 4. Point recovery at the target time.
cat >> /var/lib/postgresql/16/main/postgresql.auto.conf <<'CONF'
restore_command = 'cp /backup/wal/%f %p'
recovery_target_time = '2026-09-07 09:14:00+00'
recovery_target_action = 'promote'
CONF
touch /var/lib/postgresql/16/main/recovery.signal

# 5. Start and watch it replay.
systemctl start postgresql
tail -f /var/log/postgresql/postgresql-16-main.log   # wait for "database system is ready"

# 6. Sanity check BEFORE letting traffic back in.
psql -c "SELECT count(*) FROM duty_status_events WHERE event_time > now() - interval '1 day';"
psql -c "SELECT max(ts) FROM audit_log;"
make migrate-status

# 7. Release.
docker compose -f deploy/docker-compose.yml start worker api
```

After any PITR: the offline mobile clients still hold events the restored
database no longer has. They re-push them through `/sync/push`, which is
idempotent on `client_event_id`, so the gap closes on its own — **do not** clear
the clients' outbox.

Restore drill: run the full procedure against a scratch host **once a quarter**
and record the wall-clock RTO. A backup that has never been restored is not a
backup.

---

## 5. Monitoring

Scrape config: `deploy/prometheus.yml`. Series and suggested alert rules are
documented at the bottom of that file.

What each signal means:

| Symptom | Look at | Usual cause |
|---|---|---|
| p95 latency climbing on one route | `eld_http_request_duration_seconds{route=...}` | a missing index, or an export running on the request path |
| latency climbing everywhere | `eld_db_pool_idle_connections` at 0 | pool exhausted: a slow query is holding connections |
| `eld_queue_latency_seconds` growing | `eld_queue_tasks{state="pending"}` | worker down, or one handler blocking the queue |
| `eld_ws_connections` collapses | api logs, load balancer idle timeout | LB closing idle upgrades; raise the idle timeout above the ping interval |
| `eld_queue_scrape_errors_total` rising | Redis reachability from the worker | Redis failover in progress |
| 403 `SUBSCRIPTION_READONLY` spike | `companies.subscription_status` | a tenant's paid period plus the 7 day grace ran out — billing, not an incident. The **driver app is unaffected by design**: HOS recording never stops. |

---

## 6. Incident checklist

**First five minutes**

1. `curl /health` and `/ready` on every replica — is it the app or a dependency?
2. Grafana: error rate, p95 latency, queue lag, pool saturation.
3. `docker compose -f deploy/docker-compose.yml logs --tail=200 api worker` —
   logs are JSON, filter by `request_id` to follow one request end to end.
4. Did anything deploy or migrate in the last hour? If yes, **roll back first,
   diagnose after**.

**Triage by symptom**

- *API 5xx, database fine* → check the pool gauges; restart one replica and see
  if it clears. If it does, look for a connection leak in the last change.
- *API 503 on every route* → `/ready` is failing. Check Postgres and Redis
  directly (`pg_isready`, `redis-cli ping`).
- *Queue lag only* → the API is healthy and drivers are unaffected. Scale the
  worker; check `asynq` dead-letter with the inspector before retrying.
- *Postgres out of connections* → find the blocker:
  ```sql
  SELECT pid, state, wait_event_type, now() - query_start AS age, left(query, 120)
  FROM pg_stat_activity WHERE state <> 'idle' ORDER BY age DESC LIMIT 20;
  SELECT pg_terminate_backend(<pid>);   -- last resort, one pid at a time
  ```
- *Disk filling on Postgres* → almost always `telemetry`. Confirm the retention
  policy exists (§4), then check WAL is being archived and removed.
- *Suspected data tampering* → `audit_log` is append-only and cannot have been
  edited. Query it for the window and the actor; it is admissible evidence.

**Escalate immediately** (do not wait for a fix) when any of these is true:

- HOS data loss is suspected — this is a compliance event, not just an outage;
- `audit_log` writes are failing (a mutation that cannot be audited must fail);
- a cross-tenant read is observed (`cross_tenant_attempt` in `audit_log`);
- a PITR restore is being considered.

**After the incident**

- [ ] Timeline written from `request_id` traces and `audit_log`, not memory.
- [ ] If data was lost: which tenants, which date range, was HOS affected?
- [ ] A regression test lands before the fix is closed.
- [ ] If a runbook step was wrong or missing, this file is edited in the same PR.
