-- name: CreateMaintenanceSchedule :one
INSERT INTO maintenance_schedules (
  company_id, name, type, interval_value, interval_unit, reminder_before_value,
  alert_type, delivery_methods, notify_co_driver, notes, status
) VALUES (
  sqlc.arg('company_id'), sqlc.arg('name'), sqlc.narg('type'), sqlc.arg('interval_value'),
  sqlc.arg('interval_unit'), sqlc.arg('reminder_before_value'), sqlc.arg('alert_type'),
  sqlc.arg('delivery_methods'), sqlc.arg('notify_co_driver'), sqlc.narg('notes'), sqlc.arg('status')
)
RETURNING *;

-- name: GetMaintenanceSchedule :one
SELECT * FROM maintenance_schedules WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: ListMaintenanceSchedules :many
SELECT * FROM maintenance_schedules
WHERE company_id = sqlc.arg('company_id') AND deleted_at IS NULL
  AND (sqlc.narg('status')::text IS NULL OR status = sqlc.narg('status')::text)
  AND (sqlc.narg('q')::text IS NULL OR name ILIKE '%' || sqlc.narg('q')::text || '%')
ORDER BY name LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountMaintenanceSchedules :one
SELECT count(*) FROM maintenance_schedules
WHERE company_id = sqlc.arg('company_id') AND deleted_at IS NULL
  AND (sqlc.narg('status')::text IS NULL OR status = sqlc.narg('status')::text)
  AND (sqlc.narg('q')::text IS NULL OR name ILIKE '%' || sqlc.narg('q')::text || '%');

-- name: UpdateMaintenanceSchedule :one
UPDATE maintenance_schedules SET
  name                  = COALESCE(sqlc.narg('name')::text, name),
  type                  = COALESCE(sqlc.narg('type')::text, type),
  interval_value        = COALESCE(sqlc.narg('interval_value')::numeric, interval_value),
  interval_unit         = COALESCE(sqlc.narg('interval_unit')::text, interval_unit),
  reminder_before_value = COALESCE(sqlc.narg('reminder_before_value')::numeric, reminder_before_value),
  alert_type            = COALESCE(sqlc.narg('alert_type')::text, alert_type),
  delivery_methods      = COALESCE(sqlc.narg('delivery_methods')::text[], delivery_methods),
  notify_co_driver      = COALESCE(sqlc.narg('notify_co_driver')::bool, notify_co_driver),
  notes                 = COALESCE(sqlc.narg('notes')::text, notes),
  status                = COALESCE(sqlc.narg('status')::text, status)
WHERE company_id = sqlc.arg('company_id') AND id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteMaintenanceSchedule :exec
UPDATE maintenance_schedules SET deleted_at = now() WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: AttachUnitToSchedule :one
INSERT INTO maintenance_schedule_units (
  company_id, schedule_id, unit_id, last_service_value, last_service_at, next_due_value, next_due_at
) VALUES (
  sqlc.arg('company_id'), sqlc.arg('schedule_id'), sqlc.arg('unit_id'),
  sqlc.narg('last_service_value'), sqlc.narg('last_service_at'),
  sqlc.narg('next_due_value'), sqlc.narg('next_due_at')
)
RETURNING *;

-- name: GetScheduleUnit :one
SELECT * FROM maintenance_schedule_units WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: GetScheduleUnitDetail :one
SELECT su.*, u.unit_number, u.status AS unit_status,
       s.name AS schedule_name, s.type AS schedule_type, s.interval_value, s.interval_unit,
       s.reminder_before_value, s.alert_type, s.delivery_methods, s.notify_co_driver,
       ls.odometer_m, ls.engine_hours AS current_engine_hours
FROM maintenance_schedule_units su
JOIN units u ON u.id = su.unit_id
JOIN maintenance_schedules s ON s.id = su.schedule_id
LEFT JOIN unit_last_state ls ON ls.unit_id = su.unit_id
WHERE su.company_id = $1 AND su.id = $2 AND su.deleted_at IS NULL;

-- name: ListScheduleUnitsWithState :many
SELECT su.*, u.unit_number, u.status AS unit_status,
       s.name AS schedule_name, s.type AS schedule_type, s.interval_value, s.interval_unit,
       s.reminder_before_value, s.alert_type, s.delivery_methods, s.notify_co_driver,
       ls.odometer_m, ls.engine_hours AS current_engine_hours
FROM maintenance_schedule_units su
JOIN units u ON u.id = su.unit_id
JOIN maintenance_schedules s ON s.id = su.schedule_id
LEFT JOIN unit_last_state ls ON ls.unit_id = su.unit_id
WHERE su.company_id = sqlc.arg('company_id') AND su.deleted_at IS NULL
  AND (sqlc.narg('schedule_id')::uuid IS NULL OR su.schedule_id = sqlc.narg('schedule_id')::uuid)
  AND (sqlc.narg('unit_id')::uuid IS NULL OR su.unit_id = sqlc.narg('unit_id')::uuid)
  AND (sqlc.narg('status')::text IS NULL OR su.status = sqlc.narg('status')::text)
  AND (sqlc.arg('open_only')::bool = false OR su.status IN ('scheduled','due'))
ORDER BY su.next_due_at NULLS LAST, u.unit_number
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountScheduleUnitsWithState :one
SELECT count(*) FROM maintenance_schedule_units su
WHERE su.company_id = sqlc.arg('company_id') AND su.deleted_at IS NULL
  AND (sqlc.narg('schedule_id')::uuid IS NULL OR su.schedule_id = sqlc.narg('schedule_id')::uuid)
  AND (sqlc.narg('unit_id')::uuid IS NULL OR su.unit_id = sqlc.narg('unit_id')::uuid)
  AND (sqlc.narg('status')::text IS NULL OR su.status = sqlc.narg('status')::text)
  AND (sqlc.arg('open_only')::bool = false OR su.status IN ('scheduled','due'));

-- name: UpdateScheduleUnitProgress :one
UPDATE maintenance_schedule_units SET
  last_service_value = COALESCE(sqlc.narg('last_service_value')::numeric, last_service_value),
  next_due_value     = COALESCE(sqlc.narg('next_due_value')::numeric, next_due_value),
  next_due_at        = COALESCE(sqlc.narg('next_due_at')::timestamptz, next_due_at),
  status             = COALESCE(sqlc.narg('status')::text, status)
WHERE company_id = sqlc.arg('company_id') AND id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: CompleteScheduleUnit :one
-- Q42.1 — last_service_value becomes the reading at completion time and the
-- row goes back to `scheduled` with a fresh next_due_value.
UPDATE maintenance_schedule_units SET
  last_service_value = sqlc.narg('last_service_value'),
  last_service_at    = sqlc.narg('last_service_at'),
  next_due_value     = sqlc.narg('next_due_value'),
  next_due_at        = sqlc.narg('next_due_at'),
  status             = 'scheduled',
  reminder_sent_at   = NULL
WHERE company_id = sqlc.arg('company_id') AND id = sqlc.arg('id')
  AND deleted_at IS NULL AND status IN ('scheduled','due')
RETURNING *;

-- name: CancelScheduleUnit :one
UPDATE maintenance_schedule_units SET
  status           = 'cancelled',
  cancelled_reason = sqlc.narg('cancelled_reason')
WHERE company_id = sqlc.arg('company_id') AND id = sqlc.arg('id')
  AND deleted_at IS NULL AND status IN ('scheduled','due')
RETURNING *;

-- name: MarkScheduleUnitDue :execrows
UPDATE maintenance_schedule_units SET status = 'due'
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL AND status = 'scheduled';

-- name: MarkScheduleUnitReminderSent :execrows
-- Q37/Q38 — the reminder fires once; the guard makes a concurrent worker a no-op.
UPDATE maintenance_schedule_units SET reminder_sent_at = now()
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL AND reminder_sent_at IS NULL;

-- name: DetachUnitFromSchedule :exec
UPDATE maintenance_schedule_units SET deleted_at = now(), status = 'cancelled'
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: ListScheduleUnitsForReminder :many
SELECT su.*, u.unit_number, u.status AS unit_status,
       s.name AS schedule_name, s.type AS schedule_type, s.interval_value, s.interval_unit,
       s.reminder_before_value, s.alert_type, s.delivery_methods, s.notify_co_driver,
       ls.odometer_m, ls.engine_hours AS current_engine_hours
FROM maintenance_schedule_units su
JOIN units u ON u.id = su.unit_id
JOIN maintenance_schedules s ON s.id = su.schedule_id
LEFT JOIN unit_last_state ls ON ls.unit_id = su.unit_id
WHERE su.company_id = sqlc.arg('company_id') AND su.deleted_at IS NULL
  AND su.status IN ('scheduled','due')
  AND su.reminder_sent_at IS NULL
  AND s.status = 'active' AND s.deleted_at IS NULL
  AND u.deleted_at IS NULL
ORDER BY su.next_due_at NULLS LAST
LIMIT sqlc.arg('limit');

-- name: ListUnitDriversForNotify :many
SELECT a.driver_id, a.role, d.user_id
FROM unit_driver_assignments a
JOIN drivers d ON d.id = a.driver_id
WHERE a.company_id = $1 AND a.unit_id = $2 AND a.unassigned_at IS NULL AND d.deleted_at IS NULL;

-- name: GetMaintenanceUnit :one
SELECT id, unit_number, status FROM units
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: GetUnitCurrentReading :one
SELECT odometer_m, engine_hours FROM unit_last_state
WHERE company_id = $1 AND unit_id = $2;

-- name: CreateMaintenanceRecord :one
INSERT INTO maintenance_records (
  company_id, schedule_unit_id, unit_id, status, performed_at, invoice_no, vendor,
  cost, currency, odometer_m, engine_hours, invoice_key, cancelled_reason, notes
) VALUES (
  sqlc.arg('company_id'), sqlc.narg('schedule_unit_id'), sqlc.arg('unit_id'), sqlc.arg('status'),
  sqlc.arg('performed_at'), sqlc.narg('invoice_no'), sqlc.narg('vendor'), sqlc.narg('cost'),
  sqlc.arg('currency'), sqlc.narg('odometer_m'), sqlc.narg('engine_hours'),
  sqlc.narg('invoice_key'), sqlc.narg('cancelled_reason'), sqlc.narg('notes')
)
RETURNING *;

-- name: GetMaintenanceRecord :one
SELECT * FROM maintenance_records WHERE company_id = $1 AND id = $2;

-- name: ListMaintenanceRecords :many
SELECT r.*, u.unit_number
FROM maintenance_records r
JOIN units u ON u.id = r.unit_id
WHERE r.company_id = sqlc.arg('company_id')
  AND (sqlc.narg('unit_id')::uuid IS NULL OR r.unit_id = sqlc.narg('unit_id')::uuid)
  AND (sqlc.narg('status')::text IS NULL OR r.status = sqlc.narg('status')::text)
  AND (sqlc.narg('from')::timestamptz IS NULL OR r.performed_at >= sqlc.narg('from')::timestamptz)
  AND (sqlc.narg('to')::timestamptz IS NULL OR r.performed_at < sqlc.narg('to')::timestamptz)
ORDER BY r.performed_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountMaintenanceRecords :one
SELECT count(*) FROM maintenance_records r
WHERE r.company_id = sqlc.arg('company_id')
  AND (sqlc.narg('unit_id')::uuid IS NULL OR r.unit_id = sqlc.narg('unit_id')::uuid)
  AND (sqlc.narg('status')::text IS NULL OR r.status = sqlc.narg('status')::text)
  AND (sqlc.narg('from')::timestamptz IS NULL OR r.performed_at >= sqlc.narg('from')::timestamptz)
  AND (sqlc.narg('to')::timestamptz IS NULL OR r.performed_at < sqlc.narg('to')::timestamptz);
