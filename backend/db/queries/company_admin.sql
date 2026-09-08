-- Company boshqaruv modullari (internal/domain/companies, internal/domain/company)
-- uchun so'rovlar. Boshqa modullar egallagan fayllarga tegmaslik uchun alohida.

-- name: ProvisionCompanyRoles :many
-- Yangi kompaniya uchun tizim rol shablonlarining (company_id IS NULL) nusxasi.
INSERT INTO roles (company_id, name, description, scope, is_system)
SELECT sqlc.arg(company_id), t.name, t.description, t.scope, false
FROM roles t
WHERE t.company_id IS NULL AND t.is_system AND t.deleted_at IS NULL
ON CONFLICT DO NOTHING
RETURNING *;

-- name: ProvisionCompanyRolePermissions :exec
-- Nusxalangan rollarga shablon permission to'plamini ko'chiradi (nom bo'yicha).
INSERT INTO role_permissions (role_id, permission_key)
SELECT nr.id, rp.permission_key
FROM roles nr
JOIN roles tpl
  ON tpl.company_id IS NULL AND tpl.is_system AND tpl.deleted_at IS NULL
 AND lower(tpl.name) = lower(nr.name)
JOIN role_permissions rp ON rp.role_id = tpl.id
WHERE nr.company_id = sqlc.arg(company_id) AND nr.deleted_at IS NULL
ON CONFLICT DO NOTHING;

-- name: GetCompanyRoleByName :one
SELECT * FROM roles
WHERE company_id = sqlc.arg(company_id)
  AND lower(name) = lower(sqlc.arg(name)::text)
  AND deleted_at IS NULL;

-- name: InsertNotificationSettingDefault :exec
-- Kompaniya yaratilganda TZ A§19 jadvalidagi default kanallar.
INSERT INTO notification_settings (company_id, alert_type, channels, recipient_roles, enabled)
VALUES (sqlc.arg(company_id), sqlc.arg(alert_type), sqlc.arg(channels), sqlc.arg(recipient_roles), true)
ON CONFLICT (company_id, alert_type) DO NOTHING;

-- name: CountBranchUsers :one
SELECT count(*) FROM users
WHERE company_id = sqlc.arg(company_id) AND branch_id = sqlc.arg(branch_id) AND deleted_at IS NULL;

-- name: ListCompanyAuditHistory :many
-- GET /company/history — audit_log ning kompaniya sozlamalari bo'yicha kesimi.
SELECT a.*, u.first_name, u.last_name, u.username
FROM audit_log a
LEFT JOIN users u ON u.id = a.edited_by
WHERE a.company_id = sqlc.arg(company_id)
  AND (sqlc.narg(table_name)::text IS NULL OR a.table_name = sqlc.narg(table_name)::text)
  AND (sqlc.narg(action)::text IS NULL OR a.action = sqlc.narg(action)::text)
  AND (sqlc.narg(record_id)::uuid IS NULL OR a.record_id = sqlc.narg(record_id)::uuid)
  AND (sqlc.narg(edited_by)::uuid IS NULL OR a.edited_by = sqlc.narg(edited_by)::uuid)
  AND (sqlc.narg(from_ts)::timestamptz IS NULL OR a.ts >= sqlc.narg(from_ts)::timestamptz)
  AND (sqlc.narg(to_ts)::timestamptz IS NULL OR a.ts < sqlc.narg(to_ts)::timestamptz)
ORDER BY a.ts DESC
LIMIT sqlc.arg(row_limit) OFFSET sqlc.arg(row_offset);

-- name: CountCompanyAuditHistory :one
SELECT count(*) FROM audit_log a
WHERE a.company_id = sqlc.arg(company_id)
  AND (sqlc.narg(table_name)::text IS NULL OR a.table_name = sqlc.narg(table_name)::text)
  AND (sqlc.narg(action)::text IS NULL OR a.action = sqlc.narg(action)::text)
  AND (sqlc.narg(record_id)::uuid IS NULL OR a.record_id = sqlc.narg(record_id)::uuid)
  AND (sqlc.narg(edited_by)::uuid IS NULL OR a.edited_by = sqlc.narg(edited_by)::uuid)
  AND (sqlc.narg(from_ts)::timestamptz IS NULL OR a.ts >= sqlc.narg(from_ts)::timestamptz)
  AND (sqlc.narg(to_ts)::timestamptz IS NULL OR a.ts < sqlc.narg(to_ts)::timestamptz);
