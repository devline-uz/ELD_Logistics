-- name: CreateLogEditRequest :one
INSERT INTO log_edit_requests (company_id, driver_id, daily_log_id, requested_by, changes, driver_note)
VALUES ($1,$2,$3,$4,$5,$6) RETURNING *;

-- name: GetLogEditRequest :one
SELECT * FROM log_edit_requests WHERE company_id = $1 AND id = $2;

-- name: ListLogEditRequests :many
SELECT r.*, u.first_name, u.last_name
FROM log_edit_requests r
JOIN drivers d ON d.id = r.driver_id
JOIN users   u ON u.id = d.user_id
WHERE r.company_id = $1
  AND ($2::text IS NULL OR r.status = $2::text)
  AND ($3::uuid IS NULL OR r.driver_id = $3::uuid)
ORDER BY r.created_at DESC
LIMIT $4 OFFSET $5;

-- name: CountLogEditRequests :one
SELECT count(*) FROM log_edit_requests r
WHERE r.company_id = $1
  AND ($2::text IS NULL OR r.status = $2::text)
  AND ($3::uuid IS NULL OR r.driver_id = $3::uuid);

-- name: ResolveLogEditRequest :one
UPDATE log_edit_requests SET status = $3, resolved_by = $4, resolved_at = now(), driver_note = COALESCE($5::text, driver_note)
WHERE company_id = $1 AND id = $2 AND status = 'pending'
RETURNING *;

-- name: CountPendingLogEditRequests :one
SELECT count(*) FROM log_edit_requests WHERE company_id = $1 AND status = 'pending';
