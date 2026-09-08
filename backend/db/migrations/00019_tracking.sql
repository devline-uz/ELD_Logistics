-- +goose Up

-- §10.1 — admin tomonidagi ELD holatlari: Online / Offline / Disconnected / Malfunction.
-- `disconnected` — qurilma "ELD ↔ telefon uzildi" deb xabar bergan holat; u
-- telemetriya yo'qligidan (offline) farq qiladi, shuning uchun alohida saqlanadi.
-- `malfunction` saqlanmaydi: u eld_devices.status / malfunction_codes dan
-- o'qish paytida hosil qilinadi, aks holda ikkita manba bir-biriga ziddiyat qiladi.
-- +goose StatementBegin
ALTER TABLE unit_last_state DROP CONSTRAINT IF EXISTS unit_last_state_online_status_check;
-- +goose StatementEnd
-- +goose StatementBegin
ALTER TABLE unit_last_state ADD CONSTRAINT unit_last_state_online_status_check
  CHECK (online_status IN ('online','idle','offline','disconnected'));
-- +goose StatementEnd

-- Ochiq trip / ochiq unidentified event izlash ingestion'ning issiq yo'li.
-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS trips_open_unit_idx
  ON trips (company_id, unit_id) WHERE end_at IS NULL;
-- +goose StatementEnd
-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS unidentified_events_open_unit_idx
  ON unidentified_events (company_id, unit_id) WHERE end_at IS NULL;
-- +goose StatementEnd

-- TZ A§16 Q82 — Tracking guruhining aniq permission kalitlari (D§3 jadvali).
-- Manba-haqiqat `internal/auth/permissions.go`; bu yerda GET /permissions uchun.
-- +goose StatementBegin
UPDATE system_settings
SET value = value || to_jsonb(ARRAY['tracking.view_live','tracking.view_history'])
WHERE key = 'permission_keys'
  AND NOT (value @> '["tracking.view_live"]'::jsonb);
-- +goose StatementEnd

-- Kalitlarni mavjud default rollarga ber: `tracking.read` bo'lgan rol jonli
-- xaritani, `tracking.history` bo'lgan rol trip tarixini ko'radi.
-- +goose StatementBegin
INSERT INTO role_permissions (role_id, permission_key)
SELECT rp.role_id, 'tracking.view_live'
FROM role_permissions rp
WHERE rp.permission_key = 'tracking.read'
ON CONFLICT DO NOTHING;
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO role_permissions (role_id, permission_key)
SELECT rp.role_id, 'tracking.view_history'
FROM role_permissions rp
WHERE rp.permission_key = 'tracking.history'
ON CONFLICT DO NOTHING;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM role_permissions WHERE permission_key IN ('tracking.view_live','tracking.view_history');
-- +goose StatementEnd
-- +goose StatementBegin
UPDATE system_settings
SET value = (SELECT jsonb_agg(k) FROM jsonb_array_elements_text(value) AS k
             WHERE k NOT IN ('tracking.view_live','tracking.view_history'))
WHERE key = 'permission_keys';
-- +goose StatementEnd
-- +goose StatementBegin
DROP INDEX IF EXISTS unidentified_events_open_unit_idx;
-- +goose StatementEnd
-- +goose StatementBegin
DROP INDEX IF EXISTS trips_open_unit_idx;
-- +goose StatementEnd
-- +goose StatementBegin
ALTER TABLE unit_last_state DROP CONSTRAINT IF EXISTS unit_last_state_online_status_check;
-- +goose StatementEnd
-- +goose StatementBegin
ALTER TABLE unit_last_state ADD CONSTRAINT unit_last_state_online_status_check
  CHECK (online_status IN ('online','idle','offline'));
-- +goose StatementEnd
