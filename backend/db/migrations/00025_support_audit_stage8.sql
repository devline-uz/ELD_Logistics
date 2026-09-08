-- +goose Up
-- 8-bosqich: support tiket holatlari (TZ A§15 Q77 — `new → in_progress → resolved`),
-- `support.update_status` permission kaliti va retention sweep indekslari.

-- Tiket holati `open` emas, `new` bilan boshlanadi.
-- +goose StatementBegin
ALTER TABLE support_tickets DROP CONSTRAINT IF EXISTS support_tickets_status_check;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE support_tickets
  ADD CONSTRAINT support_tickets_status_check
  CHECK (status IN ('new','in_progress','resolved','closed'));
-- +goose StatementEnd

-- +goose StatementBegin
UPDATE support_tickets SET status = 'new' WHERE status = 'open';
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE support_tickets ALTER COLUMN status SET DEFAULT 'new';
-- +goose StatementEnd

-- `support.update_status` — tiket holatini almashtirish alohida kalit
-- (TZ A§16: `support.update` matn tahriri emas, holat o'tishi audit-muhim).
-- Manba-haqiqat `internal/auth/permissions.go`; bu yerda GET /permissions uchun.
-- +goose StatementBegin
UPDATE system_settings
SET value = value || to_jsonb(ARRAY['support.update_status'])
WHERE key = 'permission_keys'
  AND NOT (value @> '["support.update_status"]'::jsonb);
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO role_permissions (role_id, permission_key)
SELECT rp.role_id, 'support.update_status'
FROM role_permissions rp
WHERE rp.permission_key = 'support.update'
ON CONFLICT DO NOTHING;
-- +goose StatementEnd

-- Retention sweep'lari uchun indekslar (internal/jobs/retention.go).
-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS notifications_company_created_idx ON notifications (company_id, created_at);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS sessions_company_expires_idx ON sessions (company_id, expires_at);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS report_export_jobs_file_expiry_idx
  ON report_export_jobs (company_id, expires_at) WHERE file_key IS NOT NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS report_export_jobs_file_expiry_idx;
DROP INDEX IF EXISTS sessions_company_expires_idx;
DROP INDEX IF EXISTS notifications_company_created_idx;
-- +goose StatementEnd

-- +goose StatementBegin
DELETE FROM role_permissions WHERE permission_key = 'support.update_status';
-- +goose StatementEnd

-- +goose StatementBegin
UPDATE system_settings
SET value = (SELECT jsonb_agg(k) FROM jsonb_array_elements_text(value) AS k
             WHERE k <> 'support.update_status')
WHERE key = 'permission_keys';
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE support_tickets ALTER COLUMN status SET DEFAULT 'open';
-- +goose StatementEnd

-- +goose StatementBegin
UPDATE support_tickets SET status = 'open' WHERE status = 'new';
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE support_tickets DROP CONSTRAINT IF EXISTS support_tickets_status_check;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE support_tickets
  ADD CONSTRAINT support_tickets_status_check
  CHECK (status IN ('open','in_progress','resolved','closed'));
-- +goose StatementEnd
