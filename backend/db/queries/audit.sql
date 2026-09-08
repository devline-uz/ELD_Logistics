-- name: InsertAuditLog :one
INSERT INTO audit_log (
  company_id, table_name, record_id, field, old_value, new_value,
  action, edited_by, ip, user_agent, ts
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10, COALESCE($11::timestamptz, now()))
RETURNING *;

-- Audit-log ko'rinishi (TZ A§17) — faqat o'qish, filtr + pagination.
-- name: ListAuditLog :many
SELECT a.*, u.first_name, u.last_name, u.username
FROM audit_log a
-- The actor is resolved inside the tenant only: a platform super admin (whose
-- users row carries company_id IS NULL) must stay anonymous in a tenant journal.
LEFT JOIN users u ON u.id = a.edited_by AND u.company_id = a.company_id
WHERE a.company_id = sqlc.arg(company_id)
  AND (sqlc.narg(table_name)::text IS NULL OR a.table_name = sqlc.narg(table_name)::text)
  AND (sqlc.narg(record_id)::uuid IS NULL OR a.record_id = sqlc.narg(record_id)::uuid)
  AND (sqlc.narg(edited_by)::uuid IS NULL OR a.edited_by = sqlc.narg(edited_by)::uuid)
  AND (sqlc.narg(action)::text IS NULL OR a.action = sqlc.narg(action)::text)
  AND (sqlc.narg(from_ts)::timestamptz IS NULL OR a.ts >= sqlc.narg(from_ts)::timestamptz)
  AND (sqlc.narg(to_ts)::timestamptz IS NULL OR a.ts < sqlc.narg(to_ts)::timestamptz)
ORDER BY
  CASE WHEN sqlc.arg(sort_dir)::text = 'asc' THEN a.ts END ASC,
  a.ts DESC
LIMIT sqlc.arg(row_limit) OFFSET sqlc.arg(row_offset);

-- name: CountAuditLog :one
SELECT count(*) FROM audit_log a
WHERE a.company_id = sqlc.arg(company_id)
  AND (sqlc.narg(table_name)::text IS NULL OR a.table_name = sqlc.narg(table_name)::text)
  AND (sqlc.narg(record_id)::uuid IS NULL OR a.record_id = sqlc.narg(record_id)::uuid)
  AND (sqlc.narg(edited_by)::uuid IS NULL OR a.edited_by = sqlc.narg(edited_by)::uuid)
  AND (sqlc.narg(action)::text IS NULL OR a.action = sqlc.narg(action)::text)
  AND (sqlc.narg(from_ts)::timestamptz IS NULL OR a.ts >= sqlc.narg(from_ts)::timestamptz)
  AND (sqlc.narg(to_ts)::timestamptz IS NULL OR a.ts < sqlc.narg(to_ts)::timestamptz);

-- Audit-log filtri uchun tanlanadigan jadval nomlari (UI dropdown).
-- name: ListAuditLogTables :many
SELECT DISTINCT a.table_name FROM audit_log a
WHERE a.company_id = $1
ORDER BY a.table_name;

-- name: ListRecordHistory :many
SELECT * FROM audit_log
WHERE company_id = $1 AND table_name = $2 AND record_id = $3
ORDER BY ts DESC
LIMIT $4 OFFSET $5;

-- name: ListCompanyHistory :many
SELECT a.*, u.first_name, u.last_name
FROM audit_log a
LEFT JOIN users u ON u.id = a.edited_by AND u.company_id = a.company_id
WHERE a.company_id = $1 AND a.table_name IN ('companies','hos_policy_versions','branches','notification_settings')
ORDER BY a.ts DESC
LIMIT $2 OFFSET $3;
