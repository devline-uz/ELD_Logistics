-- name: CreateUnidentifiedEvent :one
INSERT INTO unidentified_events (company_id, unit_id, eld_device_id, start_at, end_at, distance_m, track_key)
VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *;

-- name: GetUnidentifiedEvent :one
SELECT * FROM unidentified_events WHERE company_id = $1 AND id = $2;

-- name: ListUnidentifiedEvents :many
SELECT e.*, u.unit_number
FROM unidentified_events e
JOIN units u ON u.id = e.unit_id
WHERE e.company_id = $1
  AND ($2::text IS NULL OR e.status = $2::text)
  AND ($3::uuid IS NULL OR e.unit_id = $3::uuid)
  AND ($4::timestamptz IS NULL OR e.start_at >= $4::timestamptz)
  AND ($5::timestamptz IS NULL OR e.start_at < $5::timestamptz)
ORDER BY e.start_at DESC
LIMIT $6 OFFSET $7;

-- name: CountUnidentifiedEvents :one
SELECT count(*) FROM unidentified_events e
WHERE e.company_id = $1
  AND ($2::text IS NULL OR e.status = $2::text)
  AND ($3::uuid IS NULL OR e.unit_id = $3::uuid)
  AND ($4::timestamptz IS NULL OR e.start_at >= $4::timestamptz)
  AND ($5::timestamptz IS NULL OR e.start_at < $5::timestamptz);

-- name: AssignUnidentifiedEvent :one
UPDATE unidentified_events
SET status = 'assigned', assigned_driver_id = $3, resolved_by = $4, resolved_at = now()
WHERE company_id = $1 AND id = $2 AND status = 'pending'
RETURNING *;

-- name: AnnotateUnidentifiedEvent :one
UPDATE unidentified_events
SET status = 'annotated', annotation = $3, resolved_by = $4, resolved_at = now()
WHERE company_id = $1 AND id = $2 AND status = 'pending'
RETURNING *;

-- name: CountPendingUnidentifiedEvents :one
SELECT count(*) FROM unidentified_events WHERE company_id = $1 AND status = 'pending';
