-- name: CreateViolation :one
INSERT INTO violations (
  company_id, driver_id, unit_id, daily_log_id, type, severity, occurred_at, details, policy_version_id
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
RETURNING *;

-- name: GetViolation :one
SELECT * FROM violations WHERE company_id = $1 AND id = $2;

-- name: ListViolations :many
SELECT v.*, u.first_name, u.last_name
FROM violations v
JOIN drivers d ON d.id = v.driver_id
JOIN users   u ON u.id = d.user_id
WHERE v.company_id = $1
  AND ($2::uuid IS NULL OR v.driver_id = $2::uuid)
  AND ($3::text IS NULL OR v.type = $3::text)
  AND ($4::text IS NULL OR v.severity = $4::text)
  AND ($5::timestamptz IS NULL OR v.occurred_at >= $5::timestamptz)
  AND ($6::timestamptz IS NULL OR v.occurred_at < $6::timestamptz)
ORDER BY v.occurred_at DESC
LIMIT $7 OFFSET $8;

-- name: CountViolations :one
SELECT count(*) FROM violations v
WHERE v.company_id = $1
  AND ($2::uuid IS NULL OR v.driver_id = $2::uuid)
  AND ($3::text IS NULL OR v.type = $3::text)
  AND ($4::text IS NULL OR v.severity = $4::text)
  AND ($5::timestamptz IS NULL OR v.occurred_at >= $5::timestamptz)
  AND ($6::timestamptz IS NULL OR v.occurred_at < $6::timestamptz);

-- name: ListViolationsByDailyLog :many
SELECT * FROM violations WHERE company_id = $1 AND daily_log_id = $2 ORDER BY occurred_at;

-- name: ResolveViolation :one
UPDATE violations SET resolved_at = now(), resolved_reason = $3
WHERE company_id = $1 AND id = $2 AND resolved_at IS NULL RETURNING *;

-- name: SummarizeViolationsByType :many
SELECT type, severity, count(*) AS total
FROM violations
WHERE company_id = $1 AND occurred_at >= $2 AND occurred_at < $3
GROUP BY type, severity
ORDER BY total DESC;
