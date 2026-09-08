-- Fleet domain (units + eld_devices + trailers + shipping_documents).
-- Nullable filtrlar sqlc.narg() bilan yoziladi, saralash esa oq ro'yxatdan
-- kelgan (sort, order) juftligi ustidan CASE bilan — SQL hech qachon
-- konkatenatsiya qilinmaydi.

-- name: FleetListUnits :many
SELECT u.*,
       s.odometer_m       AS odometer_m,
       s.ts               AS telemetry_at,
       d.id               AS eld_device_id,
       d.serial           AS eld_device_serial,
       b.name             AS branch_name
FROM units u
LEFT JOIN unit_last_state s ON s.unit_id = u.id
LEFT JOIN branches b ON b.id = u.branch_id
LEFT JOIN eld_devices d ON d.unit_id = u.id AND d.deleted_at IS NULL
WHERE u.company_id = @company_id AND u.deleted_at IS NULL
  AND (sqlc.narg('search')::text IS NULL
       OR (u.unit_number || ' ' || COALESCE(u.vin,'') || ' ' || COALESCE(u.license_plate,''))
          ILIKE '%' || sqlc.narg('search')::text || '%')
  AND (sqlc.narg('status')::text IS NULL OR u.status = sqlc.narg('status')::text)
  AND (sqlc.narg('branch_id')::uuid IS NULL OR u.branch_id = sqlc.narg('branch_id')::uuid)
  AND (sqlc.narg('out_of_service')::bool IS NULL OR u.out_of_service = sqlc.narg('out_of_service')::bool)
  AND (@include_inactive::bool OR u.status = 'active')
ORDER BY
  CASE WHEN @sort::text = 'unit_number' AND @sort_order::text = 'asc'  THEN u.unit_number END ASC  NULLS LAST,
  CASE WHEN @sort::text = 'unit_number' AND @sort_order::text = 'desc' THEN u.unit_number END DESC NULLS LAST,
  CASE WHEN @sort::text = 'status'      AND @sort_order::text = 'asc'  THEN u.status      END ASC  NULLS LAST,
  CASE WHEN @sort::text = 'status'      AND @sort_order::text = 'desc' THEN u.status      END DESC NULLS LAST,
  CASE WHEN @sort::text = 'make'        AND @sort_order::text = 'asc'  THEN u.make        END ASC  NULLS LAST,
  CASE WHEN @sort::text = 'make'        AND @sort_order::text = 'desc' THEN u.make        END DESC NULLS LAST,
  CASE WHEN @sort::text = 'year'        AND @sort_order::text = 'asc'  THEN u.year        END ASC  NULLS LAST,
  CASE WHEN @sort::text = 'year'        AND @sort_order::text = 'desc' THEN u.year        END DESC NULLS LAST,
  CASE WHEN @sort::text = 'created_at'  AND @sort_order::text = 'asc'  THEN u.created_at  END ASC  NULLS LAST,
  CASE WHEN @sort::text = 'created_at'  AND @sort_order::text = 'desc' THEN u.created_at  END DESC NULLS LAST,
  u.unit_number ASC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: FleetCountUnits :one
SELECT count(*) FROM units u
WHERE u.company_id = @company_id AND u.deleted_at IS NULL
  AND (sqlc.narg('search')::text IS NULL
       OR (u.unit_number || ' ' || COALESCE(u.vin,'') || ' ' || COALESCE(u.license_plate,''))
          ILIKE '%' || sqlc.narg('search')::text || '%')
  AND (sqlc.narg('status')::text IS NULL OR u.status = sqlc.narg('status')::text)
  AND (sqlc.narg('branch_id')::uuid IS NULL OR u.branch_id = sqlc.narg('branch_id')::uuid)
  AND (sqlc.narg('out_of_service')::bool IS NULL OR u.out_of_service = sqlc.narg('out_of_service')::bool)
  AND (@include_inactive::bool OR u.status = 'active');

-- name: FleetGetUnit :one
SELECT u.*,
       s.odometer_m       AS odometer_m,
       s.ts               AS telemetry_at,
       d.id               AS eld_device_id,
       d.serial           AS eld_device_serial,
       b.name             AS branch_name
FROM units u
LEFT JOIN unit_last_state s ON s.unit_id = u.id
LEFT JOIN branches b ON b.id = u.branch_id
LEFT JOIN eld_devices d ON d.unit_id = u.id AND d.deleted_at IS NULL
WHERE u.company_id = @company_id AND u.id = @id AND u.deleted_at IS NULL;

-- name: FleetUpdateUnit :one
UPDATE units SET
  branch_id      = COALESCE(sqlc.narg('branch_id')::uuid, branch_id),
  unit_number    = COALESCE(sqlc.narg('unit_number')::text, unit_number),
  make           = COALESCE(sqlc.narg('make')::text, make),
  model          = COALESCE(sqlc.narg('model')::text, model),
  year           = COALESCE(sqlc.narg('year')::int, year),
  vin            = COALESCE(sqlc.narg('vin')::text, vin),
  license_plate  = COALESCE(sqlc.narg('license_plate')::text, license_plate),
  plate_region   = COALESCE(sqlc.narg('plate_region')::text, plate_region),
  fuel_type      = COALESCE(sqlc.narg('fuel_type')::text, fuel_type),
  sleeper_berth  = COALESCE(sqlc.narg('sleeper_berth')::bool, sleeper_berth),
  gvwr_class     = COALESCE(sqlc.narg('gvwr_class')::text, gvwr_class),
  notes          = COALESCE(sqlc.narg('notes')::text, notes),
  out_of_service = COALESCE(sqlc.narg('out_of_service')::bool, out_of_service)
WHERE company_id = @company_id AND id = @id AND deleted_at IS NULL
RETURNING *;

-- name: FleetGetUnitDiagnostics :one
SELECT
  u.id                AS unit_id,
  u.unit_number       AS unit_number,
  d.id                AS device_id,
  d.serial            AS device_serial,
  d.vendor            AS device_vendor,
  d.model             AS device_model,
  d.firmware          AS device_firmware,
  d.connection_type   AS connection_type,
  d.sim_present       AS sim_present,
  d.status            AS device_status,
  d.malfunction_codes AS malfunction_codes,
  d.last_seen_at      AS last_seen_at,
  s.online_status     AS online_status,
  t.ts                AS telemetry_at,
  t.odometer_m        AS odometer_m,
  t.engine_hours      AS engine_hours,
  t.fuel_pct          AS fuel_pct,
  t.coolant_temp_c    AS coolant_temp_c,
  t.coolant_level_pct AS coolant_level_pct,
  t.oil_level_pct     AS oil_level_pct,
  t.battery_pct       AS battery_pct,
  t.battery_voltage_v AS battery_voltage_v
FROM units u
LEFT JOIN unit_last_state s ON s.unit_id = u.id
LEFT JOIN eld_devices d ON d.unit_id = u.id AND d.deleted_at IS NULL
LEFT JOIN telemetry t ON t.company_id = u.company_id AND t.unit_id = u.id
  AND t.ts = (SELECT max(x.ts) FROM telemetry x WHERE x.company_id = u.company_id AND x.unit_id = u.id)
WHERE u.company_id = @company_id AND u.id = @id AND u.deleted_at IS NULL;

-- name: FleetListUnitAudit :many
SELECT a.id, a.table_name, a.record_id, a.field, a.old_value, a.new_value,
       a.action, a.edited_by, a.ts, us.first_name, us.last_name, us.username
FROM audit_log a
LEFT JOIN users us ON us.id = a.edited_by
WHERE a.company_id = @company_id::uuid
  AND a.table_name = 'units'
  AND a.record_id = @record_id::uuid
  AND (sqlc.narg('from_ts')::timestamptz IS NULL OR a.ts >= sqlc.narg('from_ts')::timestamptz)
  AND (sqlc.narg('to_ts')::timestamptz   IS NULL OR a.ts <  sqlc.narg('to_ts')::timestamptz)
ORDER BY a.ts DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: FleetCountUnitAudit :one
SELECT count(*) FROM audit_log a
WHERE a.company_id = @company_id::uuid
  AND a.table_name = 'units'
  AND a.record_id = @record_id::uuid
  AND (sqlc.narg('from_ts')::timestamptz IS NULL OR a.ts >= sqlc.narg('from_ts')::timestamptz)
  AND (sqlc.narg('to_ts')::timestamptz   IS NULL OR a.ts <  sqlc.narg('to_ts')::timestamptz);

-- name: FleetListUnitAssignments :many
SELECT a.id, a.unit_id, a.driver_id, a.role, a.assigned_at, a.unassigned_at,
       us.first_name, us.last_name, us.username
FROM unit_driver_assignments a
JOIN drivers dr ON dr.id = a.driver_id
JOIN users us ON us.id = dr.user_id
WHERE a.company_id = @company_id AND a.unit_id = @unit_id
  AND (sqlc.narg('from_ts')::timestamptz IS NULL OR a.assigned_at >= sqlc.narg('from_ts')::timestamptz)
  AND (sqlc.narg('to_ts')::timestamptz   IS NULL OR a.assigned_at <  sqlc.narg('to_ts')::timestamptz)
ORDER BY a.assigned_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: FleetCloseUnitRoleAssignment :exec
UPDATE unit_driver_assignments SET unassigned_at = now()
WHERE company_id = @company_id AND unit_id = @unit_id AND role = @role AND unassigned_at IS NULL;

-- name: FleetCloseDriverAssignments :exec
UPDATE unit_driver_assignments SET unassigned_at = now()
WHERE company_id = @company_id AND driver_id = @driver_id AND unassigned_at IS NULL;

-- name: FleetGetDriverBrief :one
SELECT d.id, d.company_id, d.user_id, d.branch_id, d.status, us.first_name, us.last_name, us.username
FROM drivers d
JOIN users us ON us.id = d.user_id
WHERE d.company_id = @company_id AND d.id = @id AND d.deleted_at IS NULL;

-- name: FleetGetBranch :one
SELECT id, company_id, name FROM branches
WHERE company_id = @company_id AND id = @id AND deleted_at IS NULL;

-- name: FleetListEldDevices :many
SELECT d.*, u.unit_number AS unit_number
FROM eld_devices d
LEFT JOIN units u ON u.id = d.unit_id AND u.deleted_at IS NULL
WHERE d.company_id = @company_id AND d.deleted_at IS NULL
  AND (sqlc.narg('search')::text IS NULL
       OR (d.serial || ' ' || d.vendor || ' ' || COALESCE(d.model,''))
          ILIKE '%' || sqlc.narg('search')::text || '%')
  AND (sqlc.narg('status')::text IS NULL OR d.status = sqlc.narg('status')::text)
  AND (sqlc.narg('unit_id')::uuid IS NULL OR d.unit_id = sqlc.narg('unit_id')::uuid)
  AND (sqlc.narg('connection_type')::text IS NULL OR d.connection_type = sqlc.narg('connection_type')::text)
ORDER BY
  CASE WHEN @sort::text = 'serial'     AND @sort_order::text = 'asc'  THEN d.serial     END ASC  NULLS LAST,
  CASE WHEN @sort::text = 'serial'     AND @sort_order::text = 'desc' THEN d.serial     END DESC NULLS LAST,
  CASE WHEN @sort::text = 'vendor'     AND @sort_order::text = 'asc'  THEN d.vendor     END ASC  NULLS LAST,
  CASE WHEN @sort::text = 'vendor'     AND @sort_order::text = 'desc' THEN d.vendor     END DESC NULLS LAST,
  CASE WHEN @sort::text = 'status'     AND @sort_order::text = 'asc'  THEN d.status     END ASC  NULLS LAST,
  CASE WHEN @sort::text = 'status'     AND @sort_order::text = 'desc' THEN d.status     END DESC NULLS LAST,
  CASE WHEN @sort::text = 'created_at' AND @sort_order::text = 'asc'  THEN d.created_at END ASC  NULLS LAST,
  CASE WHEN @sort::text = 'created_at' AND @sort_order::text = 'desc' THEN d.created_at END DESC NULLS LAST,
  d.serial ASC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: FleetCountEldDevices :one
SELECT count(*) FROM eld_devices d
WHERE d.company_id = @company_id AND d.deleted_at IS NULL
  AND (sqlc.narg('search')::text IS NULL
       OR (d.serial || ' ' || d.vendor || ' ' || COALESCE(d.model,''))
          ILIKE '%' || sqlc.narg('search')::text || '%')
  AND (sqlc.narg('status')::text IS NULL OR d.status = sqlc.narg('status')::text)
  AND (sqlc.narg('unit_id')::uuid IS NULL OR d.unit_id = sqlc.narg('unit_id')::uuid)
  AND (sqlc.narg('connection_type')::text IS NULL OR d.connection_type = sqlc.narg('connection_type')::text);

-- name: FleetGetEldDevice :one
SELECT d.*, u.unit_number AS unit_number
FROM eld_devices d
LEFT JOIN units u ON u.id = d.unit_id AND u.deleted_at IS NULL
WHERE d.company_id = @company_id AND d.id = @id AND d.deleted_at IS NULL;

-- name: FleetUpdateEldDevice :one
UPDATE eld_devices SET
  vendor          = COALESCE(sqlc.narg('vendor')::text, vendor),
  model           = COALESCE(sqlc.narg('model')::text, model),
  serial          = COALESCE(sqlc.narg('serial')::text, serial),
  firmware        = COALESCE(sqlc.narg('firmware')::text, firmware),
  connection_type = COALESCE(sqlc.narg('connection_type')::text, connection_type),
  sim_present     = COALESCE(sqlc.narg('sim_present')::bool, sim_present),
  status          = COALESCE(sqlc.narg('status')::text, status),
  notes           = COALESCE(sqlc.narg('notes')::text, notes)
WHERE company_id = @company_id AND id = @id AND deleted_at IS NULL
RETURNING *;

-- name: FleetActiveDeviceForUnit :one
SELECT d.id, d.serial FROM eld_devices d
WHERE d.company_id = @company_id AND d.unit_id = @unit_id::uuid AND d.deleted_at IS NULL
LIMIT 1;

-- name: FleetUpdateTrailer :one
UPDATE trailers SET
  number = COALESCE(sqlc.narg('number')::text, number),
  notes  = COALESCE(sqlc.narg('notes')::text, notes)
WHERE company_id = @company_id AND id = @id AND deleted_at IS NULL
RETURNING *;

-- name: FleetUpdateShippingDocument :one
UPDATE shipping_documents SET
  number = COALESCE(sqlc.narg('number')::text, number),
  notes  = COALESCE(sqlc.narg('notes')::text, notes)
WHERE company_id = @company_id AND id = @id AND deleted_at IS NULL
RETURNING *;

-- name: FleetCountUnitAssignments :one
SELECT count(*) FROM unit_driver_assignments a
WHERE a.company_id = @company_id AND a.unit_id = @unit_id
  AND (sqlc.narg('from_ts')::timestamptz IS NULL OR a.assigned_at >= sqlc.narg('from_ts')::timestamptz)
  AND (sqlc.narg('to_ts')::timestamptz   IS NULL OR a.assigned_at <  sqlc.narg('to_ts')::timestamptz);
