-- name: CreateDailyLog :one
INSERT INTO daily_logs (
  company_id, driver_id, log_date, timezone, unit_ids, co_driver_id,
  distance_m, trailer_ids, shipping_doc_ids, totals, certification_status
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
RETURNING *;

-- name: GetOrCreateDailyLog :one
INSERT INTO daily_logs (company_id, driver_id, log_date, timezone)
VALUES ($1,$2,$3,$4)
ON CONFLICT (driver_id, log_date) DO UPDATE SET updated_at = now()
RETURNING *;

-- name: GetDailyLog :one
SELECT * FROM daily_logs WHERE company_id = $1 AND id = $2;

-- name: GetDailyLogByDate :one
SELECT * FROM daily_logs WHERE company_id = $1 AND driver_id = $2 AND log_date = $3;

-- name: ListDriverDailyLogs :many
SELECT * FROM daily_logs
WHERE company_id = $1 AND driver_id = $2 AND log_date >= $3 AND log_date <= $4
ORDER BY log_date DESC LIMIT $5 OFFSET $6;

-- name: CountDriverDailyLogs :one
SELECT count(*) FROM daily_logs
WHERE company_id = $1 AND driver_id = $2 AND log_date >= $3 AND log_date <= $4;

-- name: ListDailyLogs :many
SELECT l.*, u.first_name, u.last_name
FROM daily_logs l
JOIN drivers d ON d.id = l.driver_id
JOIN users   u ON u.id = d.user_id
WHERE l.company_id = $1
  AND l.log_date >= $2 AND l.log_date <= $3
  AND ($4::uuid IS NULL OR l.driver_id = $4::uuid)
  AND ($5::text IS NULL OR l.certification_status = $5::text)
ORDER BY l.log_date DESC, u.last_name
LIMIT $6 OFFSET $7;

-- name: CountDailyLogs :one
SELECT count(*) FROM daily_logs l
WHERE l.company_id = $1
  AND l.log_date >= $2 AND l.log_date <= $3
  AND ($4::uuid IS NULL OR l.driver_id = $4::uuid)
  AND ($5::text IS NULL OR l.certification_status = $5::text);

-- name: ListUncertifiedLogs :many
SELECT l.*, u.first_name, u.last_name
FROM daily_logs l
JOIN drivers d ON d.id = l.driver_id
JOIN users   u ON u.id = d.user_id
WHERE l.company_id = $1
  AND l.certification_status <> 'certified'
  AND l.log_date >= (CURRENT_DATE - ($2::int))
  AND l.log_date < CURRENT_DATE
ORDER BY l.log_date DESC
LIMIT $3 OFFSET $4;

-- name: UpdateDailyLogTotals :one
UPDATE daily_logs SET
  totals           = $3,
  distance_m       = $4,
  unit_ids         = $5,
  trailer_ids      = $6,
  shipping_doc_ids = $7,
  co_driver_id     = $8
WHERE company_id = $1 AND id = $2
RETURNING *;

-- name: CertifyDailyLog :one
UPDATE daily_logs SET
  certification_status = 'certified',
  signed_at = now(),
  signature_key = $3,
  signed_device_id = $4
WHERE company_id = $1 AND id = $2
RETURNING *;

-- name: MarkDailyLogNeedsRecertify :exec
UPDATE daily_logs SET certification_status = 'needs_recertify'
WHERE company_id = $1 AND id = $2 AND certification_status = 'certified';

-- name: ListDailyLogsChangedSince :many
SELECT * FROM daily_logs
WHERE company_id = $1 AND driver_id = $2 AND updated_at > $3
ORDER BY updated_at LIMIT $4;
