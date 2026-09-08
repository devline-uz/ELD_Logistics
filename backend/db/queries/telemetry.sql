-- name: InsertTelemetry :exec
INSERT INTO telemetry (
  ts, company_id, unit_id, eld_device_id, driver_id, lat, lng, speed_kmh, heading,
  odometer_m, engine_hours, fuel_pct, coolant_temp_c, coolant_level_pct,
  oil_level_pct, battery_pct, ignition, source
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)
ON CONFLICT (unit_id, ts) DO NOTHING;

-- name: ListTelemetry :many
SELECT * FROM telemetry
WHERE company_id = $1 AND unit_id = $2 AND ts >= $3 AND ts < $4
ORDER BY ts
LIMIT $5 OFFSET $6;

-- name: CountTelemetry :one
SELECT count(*) FROM telemetry
WHERE company_id = $1 AND unit_id = $2 AND ts >= $3 AND ts < $4;

-- name: GetLatestTelemetry :one
SELECT * FROM telemetry
WHERE company_id = $1 AND unit_id = $2
ORDER BY ts DESC LIMIT 1;

-- name: ListTelemetry1Min :many
SELECT bucket, unit_id, avg_speed_kmh, max_speed_kmh, last_lat, last_lng,
       last_heading, max_odometer_m, max_engine_hours, last_fuel_pct, sample_count
FROM telemetry_1min
WHERE company_id = $1 AND unit_id = $2 AND bucket >= $3 AND bucket < $4
ORDER BY bucket;

-- name: ListTelemetry5Min :many
SELECT bucket, unit_id, avg_speed_kmh, max_speed_kmh, last_lat, last_lng,
       last_heading, max_odometer_m, max_engine_hours, last_fuel_pct, sample_count
FROM telemetry_5min
WHERE company_id = $1 AND unit_id = $2 AND bucket >= $3 AND bucket < $4
ORDER BY bucket;

-- name: UpsertUnitLastState :one
INSERT INTO unit_last_state (
  unit_id, company_id, ts, lat, lng, speed_kmh, heading, odometer_m,
  engine_hours, duty_status, driver_id, online_status
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
ON CONFLICT (unit_id) DO UPDATE SET
  ts            = EXCLUDED.ts,
  lat           = EXCLUDED.lat,
  lng           = EXCLUDED.lng,
  speed_kmh     = EXCLUDED.speed_kmh,
  heading       = EXCLUDED.heading,
  odometer_m    = COALESCE(EXCLUDED.odometer_m, unit_last_state.odometer_m),
  engine_hours  = COALESCE(EXCLUDED.engine_hours, unit_last_state.engine_hours),
  duty_status   = COALESCE(EXCLUDED.duty_status, unit_last_state.duty_status),
  driver_id     = COALESCE(EXCLUDED.driver_id, unit_last_state.driver_id),
  online_status = EXCLUDED.online_status
WHERE unit_last_state.ts IS NULL OR EXCLUDED.ts >= unit_last_state.ts
RETURNING *;

-- name: GetUnitLastState :one
SELECT * FROM unit_last_state WHERE company_id = $1 AND unit_id = $2;

-- name: ListLiveUnits :many
SELECT s.*, u.unit_number, u.status AS unit_status, u.out_of_service,
       ur.first_name, ur.last_name
FROM unit_last_state s
JOIN units u ON u.id = s.unit_id
LEFT JOIN drivers d ON d.id = s.driver_id
LEFT JOIN users  ur ON ur.id = d.user_id
WHERE s.company_id = $1 AND u.deleted_at IS NULL
  AND ($2::uuid[] IS NULL OR s.unit_id = ANY($2::uuid[]))
  AND ($3::text IS NULL OR s.online_status = $3::text)
ORDER BY u.unit_number;

-- name: MarkStaleUnitsOffline :execrows
UPDATE unit_last_state SET online_status = 'offline'
WHERE company_id = $1 AND online_status <> 'offline' AND (ts IS NULL OR ts < now() - ($2::int || ' minutes')::interval);

-- name: UpsertRegionDistanceDaily :exec
INSERT INTO unit_region_distance_daily (unit_id, region_code, date, company_id, distance_m)
VALUES ($1,$2,$3,$4,$5)
ON CONFLICT (unit_id, region_code, date) DO UPDATE
SET distance_m = unit_region_distance_daily.distance_m + EXCLUDED.distance_m;

-- name: ListRegionDistance :many
SELECT region_code, sum(distance_m)::bigint AS distance_m
FROM unit_region_distance_daily
WHERE company_id = $1 AND date >= $2 AND date <= $3
  AND ($4::uuid[] IS NULL OR unit_id = ANY($4::uuid[]))
GROUP BY region_code
ORDER BY region_code;

-- name: ListRegionDistanceByUnit :many
SELECT unit_id, region_code, sum(distance_m)::bigint AS distance_m
FROM unit_region_distance_daily
WHERE company_id = $1 AND date >= $2 AND date <= $3
GROUP BY unit_id, region_code
ORDER BY unit_id, region_code;

-- name: FindRegionByPoint :one
-- Tie-break: bir nuqta ikki poligonga tushishi mumkin (exclave/enclave yoki
-- chegara aniqligi xatosi bo'lgan manba GeoJSON). Eng kichik maydonli hudud
-- ustun qo'yiladi — enclave/kichik ma'muriy birlik har doim uni o'rab turgan
-- kattaroq hududdan aniqroq javob beradi (masalan shahar okrugi viloyat
-- ichida). ST_Area geography'ga cast qilinadi, chunki geom SRID 4326 (daraja),
-- to'g'ridan-to'g'ri ST_Area natijasi masofa hisobiga yaramaydi — bu yerda
-- faqat nisbiy taqqoslash uchun ishlatiladi, shuning uchun cast shart emas,
-- lekin aniqlik uchun geography orqali olinadi.
SELECT code, name, country FROM regions
WHERE geom IS NOT NULL
  AND ST_Contains(geom, ST_SetSRID(ST_MakePoint(@lng::double precision, @lat::double precision), 4326))
ORDER BY ST_Area(geom::geography) ASC
LIMIT 1;

-- name: ListRegions :many
SELECT code, name, country FROM regions
WHERE ($1::text IS NULL OR country = $1::text)
ORDER BY country, code;

-- name: ListUnitIDsWithTelemetry :many
SELECT DISTINCT unit_id FROM telemetry
WHERE company_id = @company_id AND ts >= @from_ts AND ts < @to_ts;

-- name: ListUnitTrack :many
SELECT ts, lat, lng, odometer_m FROM telemetry
WHERE company_id = @company_id AND unit_id = @unit_id AND ts >= @from_ts AND ts < @to_ts
  AND lat IS NOT NULL AND lng IS NOT NULL
ORDER BY ts;

-- name: DeleteRegionDistanceDay :exec
DELETE FROM unit_region_distance_daily
WHERE company_id = $1 AND unit_id = $2 AND date = $3;
