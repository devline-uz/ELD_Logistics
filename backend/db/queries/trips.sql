-- name: CreateTrip :one
INSERT INTO trips (
  company_id, unit_id, driver_id, start_at, end_at, start_lat, start_lng,
  end_lat, end_lng, distance_m, duration_sec, max_speed_kmh, polyline_key
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
RETURNING *;

-- name: GetTrip :one
SELECT * FROM trips WHERE company_id = $1 AND id = $2;

-- name: ListUnitTrips :many
SELECT * FROM trips
WHERE company_id = $1 AND unit_id = $2 AND start_at >= $3 AND start_at < $4
ORDER BY start_at
LIMIT $5 OFFSET $6;

-- name: CountUnitTrips :one
SELECT count(*) FROM trips
WHERE company_id = $1 AND unit_id = $2 AND start_at >= $3 AND start_at < $4;

-- name: ListDriverTrips :many
SELECT * FROM trips
WHERE company_id = $1 AND driver_id = $2 AND start_at >= $3 AND start_at < $4
ORDER BY start_at
LIMIT $5 OFFSET $6;

-- name: GetOpenTrip :one
SELECT * FROM trips WHERE company_id = $1 AND unit_id = $2 AND end_at IS NULL
ORDER BY start_at DESC LIMIT 1;

-- name: CloseTrip :one
UPDATE trips SET end_at = $3, end_lat = $4, end_lng = $5, distance_m = $6,
                 duration_sec = $7, max_speed_kmh = $8, polyline_key = COALESCE($9::text, polyline_key)
WHERE company_id = $1 AND id = $2 AND end_at IS NULL
RETURNING *;

-- name: SumTripDistance :one
SELECT COALESCE(sum(distance_m), 0)::bigint AS distance_m
FROM trips
WHERE company_id = $1 AND unit_id = $2 AND start_at >= $3 AND start_at < $4;
