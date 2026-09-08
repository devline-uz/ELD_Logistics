-- +goose Up
-- +goose StatementBegin
-- TZ §10.5 — diagnostika panelida akkumulyator kuchlanishi (volt) ko'rsatiladi.
-- Birliklar xom holda saqlanadi: masofa metrda, tezlik km/h, kuchlanish voltda.
ALTER TABLE telemetry ADD COLUMN IF NOT EXISTS battery_voltage_v double precision;
-- +goose StatementEnd

-- +goose StatementBegin
-- Q3.1 / §10.1 — bir unitda bir vaqtda faqat bitta faol ELD qurilmasi bo'ladi.
CREATE UNIQUE INDEX IF NOT EXISTS eld_devices_unit_active_uniq
  ON eld_devices (unit_id)
  WHERE unit_id IS NOT NULL AND deleted_at IS NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS eld_devices_unit_active_uniq;
ALTER TABLE telemetry DROP COLUMN IF EXISTS battery_voltage_v;
-- +goose StatementEnd
