-- name: CreateEldDevice :one
INSERT INTO eld_devices (
  company_id, unit_id, vendor, model, serial, firmware,
  connection_type, sim_present, status, notes
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
RETURNING *;

-- name: GetEldDevice :one
SELECT * FROM eld_devices WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: GetEldDeviceBySerial :one
SELECT * FROM eld_devices WHERE company_id = $1 AND upper(serial) = upper($2::text) AND deleted_at IS NULL;

-- name: ListEldDevices :many
SELECT * FROM eld_devices
WHERE company_id = $1 AND deleted_at IS NULL
  AND ($2::text IS NULL OR (serial || ' ' || vendor || ' ' || COALESCE(model,'')) ILIKE '%' || $2::text || '%')
  AND ($3::text IS NULL OR status = $3::text)
  AND ($4::uuid IS NULL OR unit_id = $4::uuid)
ORDER BY serial
LIMIT $5 OFFSET $6;

-- name: CountEldDevices :one
SELECT count(*) FROM eld_devices
WHERE company_id = $1 AND deleted_at IS NULL
  AND ($2::text IS NULL OR (serial || ' ' || vendor || ' ' || COALESCE(model,'')) ILIKE '%' || $2::text || '%')
  AND ($3::text IS NULL OR status = $3::text)
  AND ($4::uuid IS NULL OR unit_id = $4::uuid);

-- name: UpdateEldDevice :one
UPDATE eld_devices SET
  vendor          = COALESCE($3::text, vendor),
  model           = COALESCE($4::text, model),
  serial          = COALESCE($5::text, serial),
  firmware        = COALESCE($6::text, firmware),
  connection_type = COALESCE($7::text, connection_type),
  sim_present     = COALESCE($8::bool, sim_present),
  status          = COALESCE($9::text, status),
  notes           = COALESCE($10::text, notes)
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteEldDevice :exec
UPDATE eld_devices SET deleted_at = now() WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: TouchEldDevice :exec
UPDATE eld_devices SET last_seen_at = now(), firmware = COALESCE($3::text, firmware), malfunction_codes = COALESCE($4::text[], malfunction_codes)
WHERE company_id = $1 AND id = $2;

-- name: AssignEldDeviceToUnit :one
WITH closed AS (
  UPDATE eld_device_assignments AS a SET to_at = now()
  WHERE a.company_id = $1 AND a.eld_device_id = $2 AND a.to_at IS NULL
  RETURNING a.id
), linked AS (
  UPDATE eld_devices AS d SET unit_id = $3
  WHERE d.company_id = $1 AND d.id = $2
  RETURNING d.id
)
INSERT INTO eld_device_assignments (company_id, eld_device_id, unit_id, from_at)
VALUES ($1,$2,$3, now())
RETURNING *;

-- name: UnassignEldDevice :exec
WITH closed AS (
  UPDATE eld_device_assignments AS a SET to_at = now()
  WHERE a.company_id = $1 AND a.eld_device_id = $2 AND a.to_at IS NULL
  RETURNING a.id
)
UPDATE eld_devices AS d SET unit_id = NULL
WHERE d.company_id = $1 AND d.id = $2;

-- name: ListEldDeviceAssignments :many
SELECT * FROM eld_device_assignments
WHERE company_id = $1 AND eld_device_id = $2
ORDER BY from_at DESC LIMIT $3 OFFSET $4;

-- name: GetUnitDiagnostics :one
SELECT d.id, d.serial, d.vendor, d.model, d.firmware, d.status,
       d.malfunction_codes, d.last_seen_at, d.sim_present, d.connection_type,
       s.ts AS last_telemetry_at, s.online_status, s.odometer_m, s.engine_hours
FROM eld_devices d
LEFT JOIN unit_last_state s ON s.unit_id = d.unit_id
WHERE d.company_id = $1 AND d.unit_id = $2 AND d.deleted_at IS NULL
ORDER BY d.last_seen_at DESC NULLS LAST
LIMIT 1;
