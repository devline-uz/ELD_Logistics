-- name: CreateRoute :one
INSERT INTO routes (
  company_id, unit_id, driver_id, sequence, origin_text, origin_lat, origin_lng,
  dest_text, dest_lat, dest_lng, geofence_m, created_by, note, polyline_key
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
RETURNING *;

-- name: GetRoute :one
SELECT * FROM routes WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: ListRoutes :many
SELECT r.*, u.unit_number, ur.first_name, ur.last_name,
       d.branch_id AS driver_branch_id, u.branch_id AS unit_branch_id
FROM routes r
JOIN units u ON u.id = r.unit_id
JOIN drivers d ON d.id = r.driver_id
JOIN users ur ON ur.id = d.user_id
WHERE r.company_id = @company_id AND r.deleted_at IS NULL
  AND (sqlc.narg('status')::text IS NULL OR r.status = sqlc.narg('status')::text)
  AND (sqlc.narg('driver_id')::uuid IS NULL OR r.driver_id = sqlc.narg('driver_id')::uuid)
  AND (sqlc.narg('unit_id')::uuid IS NULL OR r.unit_id = sqlc.narg('unit_id')::uuid)
  -- Branch scope (TZ A§16): the leg belongs to the branch of the driver it was
  -- assigned to. A NULL argument is a company scoped caller.
  AND (sqlc.narg('branch_id')::uuid IS NULL OR d.branch_id = sqlc.narg('branch_id')::uuid)
ORDER BY
  CASE WHEN @sort::text = 'created_at' AND @sort_order::text = 'asc'  THEN r.created_at END ASC  NULLS LAST,
  CASE WHEN @sort::text = 'created_at' AND @sort_order::text = 'desc' THEN r.created_at END DESC NULLS LAST,
  CASE WHEN @sort::text = 'sequence'   AND @sort_order::text = 'asc'  THEN r.sequence   END ASC  NULLS LAST,
  CASE WHEN @sort::text = 'sequence'   AND @sort_order::text = 'desc' THEN r.sequence   END DESC NULLS LAST,
  CASE WHEN @sort::text = 'status'     AND @sort_order::text = 'asc'  THEN r.status     END ASC  NULLS LAST,
  CASE WHEN @sort::text = 'status'     AND @sort_order::text = 'desc' THEN r.status     END DESC NULLS LAST,
  r.created_at DESC, r.sequence ASC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountRoutes :one
SELECT count(*) FROM routes r
JOIN drivers d ON d.id = r.driver_id
WHERE r.company_id = @company_id AND r.deleted_at IS NULL
  AND (sqlc.narg('status')::text IS NULL OR r.status = sqlc.narg('status')::text)
  AND (sqlc.narg('driver_id')::uuid IS NULL OR r.driver_id = sqlc.narg('driver_id')::uuid)
  AND (sqlc.narg('unit_id')::uuid IS NULL OR r.unit_id = sqlc.narg('unit_id')::uuid)
  AND (sqlc.narg('branch_id')::uuid IS NULL OR d.branch_id = sqlc.narg('branch_id')::uuid);

-- name: NextRouteSequence :one
SELECT (COALESCE(max(sequence), 0) + 1)::int AS next_sequence
FROM routes
WHERE company_id = @company_id AND unit_id = @unit_id
  AND deleted_at IS NULL AND status = 'ongoing';

-- name: ListDriverActiveRoutes :many
SELECT * FROM routes
WHERE company_id = $1 AND driver_id = $2 AND status = 'ongoing' AND deleted_at IS NULL
ORDER BY sequence;

-- name: UpdateRoute :one
UPDATE routes SET
  unit_id     = COALESCE(sqlc.narg('unit_id')::uuid, unit_id),
  driver_id   = COALESCE(sqlc.narg('driver_id')::uuid, driver_id),
  sequence    = COALESCE(sqlc.narg('sequence')::int, sequence),
  origin_text = COALESCE(sqlc.narg('origin_text')::text, origin_text),
  origin_lat  = COALESCE(sqlc.narg('origin_lat')::double precision, origin_lat),
  origin_lng  = COALESCE(sqlc.narg('origin_lng')::double precision, origin_lng),
  dest_text   = COALESCE(sqlc.narg('dest_text')::text, dest_text),
  dest_lat    = COALESCE(sqlc.narg('dest_lat')::double precision, dest_lat),
  dest_lng    = COALESCE(sqlc.narg('dest_lng')::double precision, dest_lng),
  geofence_m  = COALESCE(sqlc.narg('geofence_m')::int, geofence_m),
  note        = COALESCE(sqlc.narg('note')::text, note)
WHERE company_id = @company_id AND id = @id AND deleted_at IS NULL AND status = 'ongoing'
RETURNING *;

-- name: SetRouteStatus :one
UPDATE routes SET
  status               = $3,
  started_at           = CASE WHEN $3 = 'in_progress' THEN COALESCE(started_at, now()) ELSE started_at END,
  completed_at         = CASE WHEN $3 IN ('completed','not_completed') THEN now() ELSE completed_at END,
  not_completed_reason = COALESCE($4::text, not_completed_reason)
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteRoute :exec
UPDATE routes SET deleted_at = now() WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: GetRouteDetail :one
SELECT r.*, u.unit_number, ur.first_name, ur.last_name,
       d.branch_id AS driver_branch_id, u.branch_id AS unit_branch_id
FROM routes r
JOIN units u ON u.id = r.unit_id
JOIN drivers d ON d.id = r.driver_id
JOIN users ur ON ur.id = d.user_id
WHERE r.company_id = $1 AND r.id = $2 AND r.deleted_at IS NULL;

-- name: ListCurrentRoutesForGeofence :many
SELECT DISTINCT ON (r.unit_id)
  r.id, r.unit_id, r.driver_id, r.sequence, r.dest_lat, r.dest_lng,
  r.geofence_m, r.geofence_entered_at,
  s.lat AS unit_lat, s.lng AS unit_lng, s.ts AS unit_ts
FROM routes r
JOIN unit_last_state s ON s.unit_id = r.unit_id AND s.company_id = r.company_id
WHERE r.company_id = $1 AND r.deleted_at IS NULL AND r.status = 'ongoing'
  AND r.dest_lat IS NOT NULL AND r.dest_lng IS NOT NULL
  AND s.lat IS NOT NULL AND s.lng IS NOT NULL
ORDER BY r.unit_id, r.sequence, r.created_at;

-- name: SetRouteGeofenceEnteredAt :exec
UPDATE routes SET geofence_entered_at = $3
WHERE company_id = $1 AND id = $2 AND status = 'ongoing' AND deleted_at IS NULL;

-- name: CompleteRoute :one
UPDATE routes SET status = 'completed', completed_at = $3
WHERE company_id = $1 AND id = $2 AND status = 'ongoing' AND deleted_at IS NULL
RETURNING *;

-- name: SetRouteNotCompleted :one
UPDATE routes SET
  status               = 'not_completed',
  completed_at         = now(),
  not_completed_reason = $3,
  not_completed_note   = $4,
  not_completed_by     = $5
WHERE company_id = $1 AND id = $2 AND status = 'ongoing' AND deleted_at IS NULL
RETURNING *;
