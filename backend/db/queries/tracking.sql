-- Telemetriya ingestion (internal/domain/telemetry) va Tracking (internal/domain/tracking)
-- query'lari. Continuous aggregate'larga RLS qo'llanmaydi, shuning uchun har
-- query'da `company_id = @company_id` sharti MAJBURIY (xom jadvallarda ham
-- aniq predikat qoldirilgan: RLS ikkinchi qatlam).

-- ------------------------------------------------------------------ ingestion

-- name: TelemetryGetUnitBrief :one
SELECT u.id, u.company_id, u.branch_id, u.unit_number, u.status
FROM units u
WHERE u.company_id = @company_id AND u.id = @id AND u.deleted_at IS NULL;

-- name: TelemetryActiveDeviceForUnit :one
SELECT id, serial, vendor, status, malfunction_codes, firmware
FROM eld_devices
WHERE company_id = @company_id AND unit_id = @unit_id AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT 1;

-- name: TelemetrySetDeviceHealth :one
UPDATE eld_devices SET
  last_seen_at      = @last_seen_at,
  status            = COALESCE(sqlc.narg('status')::text, status),
  malfunction_codes = COALESCE(sqlc.narg('malfunction_codes')::text[], malfunction_codes),
  firmware          = COALESCE(sqlc.narg('firmware')::text, firmware)
WHERE company_id = @company_id AND id = @id AND deleted_at IS NULL
RETURNING *;

-- name: TelemetryOpenTrip :one
SELECT * FROM trips
WHERE company_id = @company_id AND unit_id = @unit_id AND end_at IS NULL
ORDER BY start_at DESC
LIMIT 1;

-- name: TelemetryAccrueTrip :one
UPDATE trips SET
  distance_m    = distance_m + @distance_m,
  max_speed_kmh = GREATEST(COALESCE(max_speed_kmh, 0), COALESCE(sqlc.narg('max_speed_kmh')::double precision, 0))
WHERE company_id = @company_id AND id = @id AND end_at IS NULL
RETURNING *;

-- name: TelemetryCloseTrip :one
UPDATE trips SET
  end_at        = @end_at,
  end_lat       = sqlc.narg('end_lat')::double precision,
  end_lng       = sqlc.narg('end_lng')::double precision,
  distance_m    = distance_m + @distance_m,
  duration_sec  = sqlc.narg('duration_sec')::integer,
  max_speed_kmh = GREATEST(COALESCE(max_speed_kmh, 0), COALESCE(sqlc.narg('max_speed_kmh')::double precision, 0)),
  polyline_key  = COALESCE(sqlc.narg('polyline_key')::text, polyline_key)
WHERE company_id = @company_id AND id = @id AND end_at IS NULL
RETURNING *;

-- name: TelemetryOpenUnidentifiedEvent :one
SELECT * FROM unidentified_events
WHERE company_id = @company_id AND unit_id = @unit_id AND end_at IS NULL AND status = 'pending'
ORDER BY start_at DESC
LIMIT 1;

-- name: TelemetryAccrueUnidentifiedEvent :one
UPDATE unidentified_events SET distance_m = distance_m + @distance_m
WHERE company_id = @company_id AND id = @id AND end_at IS NULL
RETURNING *;

-- name: TelemetryCloseUnidentifiedEvent :one
UPDATE unidentified_events SET
  end_at     = @end_at,
  distance_m = distance_m + @distance_m,
  track_key  = COALESCE(sqlc.narg('track_key')::text, track_key)
WHERE company_id = @company_id AND id = @id AND end_at IS NULL
RETURNING *;

-- ------------------------------------------------------------------- tracking

-- name: TrackingListLiveUnits :many
SELECT s.unit_id, s.ts, s.lat, s.lng, s.speed_kmh, s.heading, s.odometer_m,
       s.engine_hours, s.duty_status, s.driver_id, s.online_status, s.updated_at,
       u.unit_number, u.branch_id, u.out_of_service, u.status AS unit_status,
       b.name AS branch_name,
       ur.first_name, ur.last_name,
       d.id AS eld_device_id, d.serial AS eld_device_serial,
       d.status AS eld_device_status, d.malfunction_codes,
       d.last_seen_at AS eld_last_seen_at
FROM units u
JOIN unit_last_state s ON s.unit_id = u.id AND s.company_id = @company_id
LEFT JOIN branches b   ON b.id = u.branch_id
LEFT JOIN drivers dr   ON dr.id = s.driver_id
LEFT JOIN users ur     ON ur.id = dr.user_id
LEFT JOIN eld_devices d ON d.unit_id = u.id AND d.deleted_at IS NULL
WHERE u.company_id = @company_id AND u.deleted_at IS NULL
  AND (sqlc.narg('unit_ids')::uuid[] IS NULL OR u.id = ANY(sqlc.narg('unit_ids')::uuid[]))
  AND (sqlc.narg('branch_id')::uuid IS NULL OR u.branch_id = sqlc.narg('branch_id')::uuid)
  AND (sqlc.narg('online_status')::text IS NULL OR s.online_status = sqlc.narg('online_status')::text)
  AND (@include_inactive::bool OR u.status = 'active')
ORDER BY u.unit_number
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: TrackingCountLiveUnits :one
SELECT count(*) FROM units u
JOIN unit_last_state s ON s.unit_id = u.id AND s.company_id = @company_id
WHERE u.company_id = @company_id AND u.deleted_at IS NULL
  AND (sqlc.narg('unit_ids')::uuid[] IS NULL OR u.id = ANY(sqlc.narg('unit_ids')::uuid[]))
  AND (sqlc.narg('branch_id')::uuid IS NULL OR u.branch_id = sqlc.narg('branch_id')::uuid)
  AND (sqlc.narg('online_status')::text IS NULL OR s.online_status = sqlc.narg('online_status')::text)
  AND (@include_inactive::bool OR u.status = 'active');

-- name: TrackingGetUnitBrief :one
SELECT u.id, u.unit_number, u.branch_id
FROM units u
WHERE u.company_id = @company_id AND u.id = @id AND u.deleted_at IS NULL;

-- name: TrackingListUnitTrips :many
SELECT t.*, u.unit_number, u.branch_id, ur.first_name, ur.last_name
FROM trips t
JOIN units u        ON u.id = t.unit_id
LEFT JOIN drivers dr ON dr.id = t.driver_id
LEFT JOIN users ur   ON ur.id = dr.user_id
WHERE t.company_id = @company_id AND t.unit_id = @unit_id
  AND t.start_at >= @from_at AND t.start_at < @to_at
ORDER BY t.start_at
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: TrackingCountUnitTrips :one
SELECT count(*) FROM trips t
WHERE t.company_id = @company_id AND t.unit_id = @unit_id
  AND t.start_at >= @from_at AND t.start_at < @to_at;

-- name: TrackingGetTrip :one
SELECT t.*, u.unit_number, u.branch_id, ur.first_name, ur.last_name
FROM trips t
JOIN units u        ON u.id = t.unit_id
LEFT JOIN drivers dr ON dr.id = t.driver_id
LEFT JOIN users ur   ON ur.id = dr.user_id
WHERE t.company_id = @company_id AND t.id = @id;

-- name: TrackingListTripPoints :many
SELECT ts, lat, lng, speed_kmh
FROM telemetry
WHERE company_id = @company_id AND unit_id = @unit_id
  AND ts >= @from_at AND ts <= @to_at
  AND lat IS NOT NULL AND lng IS NOT NULL
ORDER BY ts
LIMIT sqlc.arg('limit');

-- name: TrackingGetCompanyTimezone :one
SELECT timezone FROM companies WHERE id = @id AND deleted_at IS NULL;

-- name: TrackingListUnidentifiedEvents :many
SELECT e.*, u.unit_number, u.branch_id
FROM unidentified_events e
JOIN units u ON u.id = e.unit_id
WHERE e.company_id = @company_id
  AND (sqlc.narg('status')::text IS NULL OR e.status = sqlc.narg('status')::text)
  AND (sqlc.narg('unit_id')::uuid IS NULL OR e.unit_id = sqlc.narg('unit_id')::uuid)
  AND (sqlc.narg('branch_id')::uuid IS NULL OR u.branch_id = sqlc.narg('branch_id')::uuid)
  AND (sqlc.narg('from_at')::timestamptz IS NULL OR e.start_at >= sqlc.narg('from_at')::timestamptz)
  AND (sqlc.narg('to_at')::timestamptz IS NULL OR e.start_at < sqlc.narg('to_at')::timestamptz)
ORDER BY e.start_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: TrackingCountUnidentifiedEvents :one
SELECT count(*) FROM unidentified_events e
JOIN units u ON u.id = e.unit_id
WHERE e.company_id = @company_id
  AND (sqlc.narg('status')::text IS NULL OR e.status = sqlc.narg('status')::text)
  AND (sqlc.narg('unit_id')::uuid IS NULL OR e.unit_id = sqlc.narg('unit_id')::uuid)
  AND (sqlc.narg('branch_id')::uuid IS NULL OR u.branch_id = sqlc.narg('branch_id')::uuid)
  AND (sqlc.narg('from_at')::timestamptz IS NULL OR e.start_at >= sqlc.narg('from_at')::timestamptz)
  AND (sqlc.narg('to_at')::timestamptz IS NULL OR e.start_at < sqlc.narg('to_at')::timestamptz);
