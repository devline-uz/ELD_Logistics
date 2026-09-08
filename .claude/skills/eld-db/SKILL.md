---
name: eld-db
description: PostgreSQL 16 + TimescaleDB + PostGIS sxema konventsiyalari, goose migratsiya va sqlc qoidalari, RLS, soft-delete, audit_log, retention. DB migratsiya yoki query yozayotganda majburiy.
---

# DB — sxema, migratsiya, sqlc (TZ D§1, B§2, B§4, B§7.2)

**To'liq jadval ro'yxati manbasi:** loyiha ildizidagi `tz.md`, **765–895-qatorlar** (`sed -n '765,895p' tz.md`). Faqat shu qismni o'qi, butun faylni emas.

## Umumiy konventsiyalar [MUST]
- PK: `id UUID PRIMARY KEY DEFAULT gen_random_uuid()` (`pgcrypto`).
- Tenant jadvallarida `company_id UUID NOT NULL REFERENCES companies(id)`.
- Har jadvalda `created_at timestamptz NOT NULL DEFAULT now()`, `updated_at timestamptz NOT NULL DEFAULT now()`, kerak bo'lsa `deleted_at timestamptz NULL`.
- **Soft-delete:** faqat `deleted_at`; `is_deleted` ustuni YO'Q. Unique — partial: `CREATE UNIQUE INDEX ... WHERE deleted_at IS NULL`.
- Enum'lar — `TEXT` + `CHECK (col IN (...))` (migratsiya qulayligi uchun; PG enum ishlatilmaydi).
- Masofa `_m` (metr, bigint), tezlik `_kmh`, vaqt `timestamptz` (UTC), pul `numeric(14,2)` + `currency TEXT`.
- JSONB: `settings`, `policy`, `totals`, `defects`, `changes`, `details`, `params`, `old_value/new_value`.
- Massivlar: `UUID[]` (`trailer_ids`, `shipping_doc_ids`, `unit_ids`), `TEXT[]` (`channels`, `malfunction_codes`).
- FK'larda `ON DELETE RESTRICT` (audit jadvallar hech qachon CASCADE emas).
- `updated_at` uchun umumiy trigger funksiyasi `set_updated_at()`.

## Indekslar (majburiy minimum)
`duty_status_events(driver_id, event_time)`, `(unit_id, event_time)`, `UNIQUE(client_event_id)`, `(company_id, event_time)`;
`daily_logs UNIQUE(driver_id, log_date)`; `telemetry(unit_id, ts DESC)`; `violations(company_id, driver_id, occurred_at)`;
`audit_log(company_id, table_name, record_id, ts)`; har tenant jadvalida `(company_id)` yoki kompozit birinchi ustun sifatida.

## RLS [MUST]
Har tenant jadvali uchun migratsiyada:
```sql
ALTER TABLE <t> ENABLE ROW LEVEL SECURITY;
ALTER TABLE <t> FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON <t>
  USING (company_id = NULLIF(current_setting('app.company_id', true), '')::uuid);
```
Super Admin uchun alohida DB roli emas — `app.company_id` bo'sh bo'lsa policy hech nima qaytarmaydi; super-admin query'lari `internal/db` da alohida "system" pool orqali (RLS bypass roli, faqat companies/users/audit uchun).
`audit_log`: `REVOKE UPDATE, DELETE ON audit_log FROM <app_role>` + `BEFORE UPDATE OR DELETE` trigger `RAISE EXCEPTION`.

## Timescale / PostGIS
- `telemetry` → `SELECT create_hypertable('telemetry','ts', chunk_time_interval => INTERVAL '1 day');` PK `(unit_id, ts)`.
- Continuous aggregate `telemetry_1min`, `telemetry_5min` (avg speed, last lat/lng, max odometer) + refresh policy.
- Retention policy: `telemetry` raw **90 kun**; agregatlar 3 yil; `chat_messages` 1 yil; log/DVIR/audit/violations **3 yil**; `unit_region_distance_daily` 5 yil (retention job `internal/jobs`).
- `regions.geom geometry(MultiPolygon, 4326)` + GiST index; `trips.polyline_key` — object storage kaliti (poliliniya faylda, DB'da emas).
- Kengaytmalar: `pgcrypto`, `postgis`, `timescaledb`.

## goose
- `db/migrations/NNNNN_<snake_name>.sql`, ketma-ket raqam (`00001_...`), **forward-only**.
- Format:
```sql
-- +goose Up
-- +goose StatementBegin
...
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS ...;
-- +goose StatementEnd
```
- Bitta migratsiya = bitta mantiqiy o'zgarish. Timescale/`CREATE INDEX CONCURRENTLY` uchun `-- +goose NO TRANSACTION`.
- Yaratilgan migratsiyani **hech qachon tahrirlama** — yangisini qo'sh.

## sqlc
`backend/sqlc.yaml`:
```yaml
version: "2"
sql:
  - engine: postgresql
    schema: db/migrations
    queries: db/queries
    gen:
      go:
        package: db
        out: internal/db
        sql_package: pgx/v5
        emit_json_tags: false
        emit_pointers_for_null_types: true
        emit_prepared_queries: false
        overrides:
          - db_type: uuid
            go_type: github.com/google/uuid.UUID
          - db_type: timestamptz
            go_type: time.Time
```
- `db/queries/<domen>.sql`, nomlash: `-- name: CreateUnit :one`, `ListUnits :many`, `SoftDeleteUnit :exec`.
- Har query'da `company_id = $1` sharti (RLS ustiga qo'shimcha).
- Pagination query'lari `LIMIT $n OFFSET $m` + alohida `Count...` query.
- **`internal/db` fayllari qo'lda tahrirlanmaydi** (generated).

## Tranzaksiya patterni
`internal/db.Pool.WithTx(ctx, companyID, func(q *db.Queries) error)` — tx ochadi, `SET LOCAL app.company_id`, `q := db.New(tx)`, rollback/commit.
