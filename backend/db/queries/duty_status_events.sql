-- name: CreateDutyStatusEvent :one
INSERT INTO duty_status_events (
  company_id, driver_id, unit_id, eld_device_id, event_type, status, special,
  event_time, time_source, time_unverified, clock_skew_sec, origin,
  lat, lng, location_text, gps_accuracy_m, odometer_m, engine_hours, notes,
  trailer_ids, shipping_doc_ids, client_event_id, device_seq, daily_log_id
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24)
RETURNING *;

-- name: UpsertDutyStatusEvent :one
INSERT INTO duty_status_events (
  company_id, driver_id, unit_id, eld_device_id, event_type, status, special,
  event_time, time_source, time_unverified, clock_skew_sec, origin,
  lat, lng, location_text, gps_accuracy_m, odometer_m, engine_hours, notes,
  trailer_ids, shipping_doc_ids, client_event_id, device_seq, daily_log_id
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24)
ON CONFLICT (client_event_id) DO UPDATE SET received_at = duty_status_events.received_at
RETURNING *;

-- name: GetDutyStatusEvent :one
SELECT * FROM duty_status_events WHERE company_id = $1 AND id = $2;

-- name: GetDutyStatusEventByClientID :one
SELECT * FROM duty_status_events WHERE company_id = $1 AND client_event_id = $2;

-- name: ListDriverDutyStatusEvents :many
SELECT * FROM duty_status_events
WHERE company_id = $1 AND driver_id = $2
  AND event_time >= $3 AND event_time < $4
  AND superseded_by IS NULL
ORDER BY event_time, device_seq NULLS LAST
LIMIT $5 OFFSET $6;

-- name: CountDriverDutyStatusEvents :one
SELECT count(*) FROM duty_status_events
WHERE company_id = $1 AND driver_id = $2
  AND event_time >= $3 AND event_time < $4 AND superseded_by IS NULL;

-- name: ListUnitDutyStatusEvents :many
SELECT * FROM duty_status_events
WHERE company_id = $1 AND unit_id = $2
  AND event_time >= $3 AND event_time < $4 AND superseded_by IS NULL
ORDER BY event_time
LIMIT $5 OFFSET $6;

-- name: ListEventsByDailyLog :many
SELECT * FROM duty_status_events
WHERE company_id = $1 AND daily_log_id = $2 AND superseded_by IS NULL
ORDER BY event_time;

-- name: GetLastDutyStatusEvent :one
SELECT * FROM duty_status_events
WHERE company_id = $1 AND driver_id = $2 AND event_type = 'duty_status' AND superseded_by IS NULL
ORDER BY event_time DESC LIMIT 1;

-- name: ListUnassignedDutyStatusEvents :many
SELECT * FROM duty_status_events
WHERE company_id = $1 AND driver_id IS NULL AND unit_id = $2
  AND event_time >= $3 AND event_time < $4
ORDER BY event_time;

-- name: SupersedeDutyStatusEvent :exec
UPDATE duty_status_events SET superseded_by = $3
WHERE company_id = $1 AND id = $2 AND superseded_by IS NULL;

-- name: AssignEventsToDriver :exec
UPDATE duty_status_events SET driver_id = $3, origin = 'assigned'
WHERE company_id = $1 AND id = ANY($2::uuid[]) AND driver_id IS NULL;

-- name: LinkEventsToDailyLog :exec
UPDATE duty_status_events SET daily_log_id = $3
WHERE company_id = $1 AND id = ANY($2::uuid[]);

-- name: LockEventsForDailyLog :exec
UPDATE duty_status_events SET locked = true
WHERE company_id = $1 AND daily_log_id = $2;

-- name: ListEventsChangedSince :many
SELECT * FROM duty_status_events
WHERE company_id = $1 AND driver_id = $2 AND updated_at > $3
ORDER BY updated_at LIMIT $4;
