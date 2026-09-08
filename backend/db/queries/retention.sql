-- Retention sweeps (TZ B§15, 00011_retention.sql). Timescale hypertable'lar
-- o'z policy'si bilan tozalanadi; bu yerda faqat oddiy jadvallar.
-- Har so'rov bitta tenant'ni tozalaydi: fan-out `internal/jobs/retention.go`.

-- name: RetentionDeleteNotifications :execrows
DELETE FROM notifications WHERE company_id = $1 AND created_at < $2;

-- name: RetentionDeleteSessions :execrows
DELETE FROM sessions WHERE company_id = $1 AND expires_at < $2;

-- Eksport fayllari 24 soatdan keyin o'chadi: `file_key` tozalanadi va obyekt
-- kalitlari qaytariladi, job ularni obyekt-omboridan o'chiradi.
-- name: RetentionExpireReportExports :many
WITH expired AS (
  SELECT j.id, j.file_key
  FROM report_export_jobs j
  WHERE j.company_id = $1 AND j.file_key IS NOT NULL
    AND COALESCE(j.expires_at, j.created_at + INTERVAL '24 hours') < $2
  FOR UPDATE
), cleared AS (
  UPDATE report_export_jobs j SET file_key = NULL
  FROM expired e WHERE j.id = e.id
  RETURNING j.id
)
SELECT e.id, e.file_key::text AS file_key FROM expired e;
