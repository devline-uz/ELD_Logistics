-- +goose NO TRANSACTION
-- Timescale retention policy'lari job yaratadi -> tranzaksiyasiz bajariladi.

-- +goose Up
-- Xom telemetriya: 90 kun.
-- +goose StatementBegin
SELECT add_retention_policy('telemetry', drop_after => INTERVAL '90 days');
-- +goose StatementEnd

-- Agregatlar: 3 yil.
-- +goose StatementBegin
SELECT add_retention_policy('telemetry_1min', drop_after => INTERVAL '3 years');
-- +goose StatementEnd

-- +goose StatementBegin
SELECT add_retention_policy('telemetry_5min', drop_after => INTERVAL '3 years');
-- +goose StatementEnd

-- Eslatma: TimescaleDB columnstore (compression) RLS yoqilgan jadvalda ishlamaydi
-- ("columnstore cannot be used on table with row security"), shuning uchun `telemetry`
-- siqilmaydi — tenant izolyatsiyasi ustunroq. 90 kunlik retention yetarli.

-- Timescale bo'lmagan jadvallar uchun retention `internal/jobs` da (asynq cron):
--   chat_messages            1 yil
--   daily_logs / duty_status_events / dvir_reports / violations / audit_log   3 yil
--   unit_region_distance_daily  5 yil
--   report_export_jobs       expires_at bo'yicha tozalanadi
-- Ular uchun kerakli indekslar 00005/00008/00009 da yaratilgan.

-- +goose Down
-- +goose StatementBegin
SELECT remove_retention_policy('telemetry_5min', if_exists => true);
-- +goose StatementEnd
-- +goose StatementBegin
SELECT remove_retention_policy('telemetry_1min', if_exists => true);
-- +goose StatementEnd
-- +goose StatementBegin
SELECT remove_retention_policy('telemetry', if_exists => true);
-- +goose StatementEnd
