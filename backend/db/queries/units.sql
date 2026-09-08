-- name: CreateUnit :one
INSERT INTO units (
  company_id, branch_id, unit_number, make, model, year, vin, license_plate,
  plate_region, fuel_type, sleeper_berth, gvwr_class, status, notes, activated_on
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)
RETURNING *;

-- name: GetUnit :one
SELECT * FROM units WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: GetUnitByNumber :one
SELECT * FROM units WHERE company_id = $1 AND lower(unit_number) = lower($2::text) AND deleted_at IS NULL;

-- name: ListUnits :many
SELECT * FROM units
WHERE company_id = $1 AND deleted_at IS NULL
  AND ($2::text IS NULL OR (unit_number || ' ' || COALESCE(vin,'') || ' ' || COALESCE(license_plate,'')) ILIKE '%' || $2::text || '%')
  AND ($3::text IS NULL OR status = $3::text)
  AND ($4::uuid IS NULL OR branch_id = $4::uuid)
  AND ($5::bool IS NULL OR out_of_service = $5::bool)
ORDER BY unit_number
LIMIT $6 OFFSET $7;

-- name: CountUnits :one
SELECT count(*) FROM units
WHERE company_id = $1 AND deleted_at IS NULL
  AND ($2::text IS NULL OR (unit_number || ' ' || COALESCE(vin,'') || ' ' || COALESCE(license_plate,'')) ILIKE '%' || $2::text || '%')
  AND ($3::text IS NULL OR status = $3::text)
  AND ($4::uuid IS NULL OR branch_id = $4::uuid)
  AND ($5::bool IS NULL OR out_of_service = $5::bool);

-- name: UpdateUnit :one
UPDATE units SET
  branch_id      = COALESCE($3::uuid, branch_id),
  unit_number    = COALESCE($4::text, unit_number),
  make           = COALESCE($5::text, make),
  model          = COALESCE($6::text, model),
  year           = COALESCE($7::int, year),
  vin            = COALESCE($8::text, vin),
  license_plate  = COALESCE($9::text, license_plate),
  plate_region   = COALESCE($10::text, plate_region),
  fuel_type      = COALESCE($11::text, fuel_type),
  sleeper_berth  = COALESCE($12::bool, sleeper_berth),
  gvwr_class     = COALESCE($13::text, gvwr_class),
  notes          = COALESCE($14::text, notes),
  out_of_service = COALESCE($15::bool, out_of_service)
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL
RETURNING *;

-- name: SetUnitStatus :one
UPDATE units SET status = $3, activated_on = CASE WHEN $3 = 'active' THEN COALESCE(activated_on, now()) ELSE activated_on END
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL RETURNING *;

-- name: SoftDeleteUnit :exec
UPDATE units SET deleted_at = now(), status = 'inactive'
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: AssignDriverToUnit :one
INSERT INTO unit_driver_assignments (company_id, unit_id, driver_id, role)
VALUES ($1,$2,$3,$4) RETURNING *;

-- name: UnassignDriverFromUnit :exec
UPDATE unit_driver_assignments SET unassigned_at = now()
WHERE company_id = $1 AND unit_id = $2 AND driver_id = $3 AND unassigned_at IS NULL;

-- name: ListActiveUnitDrivers :many
SELECT a.*, d.user_id, u.first_name, u.last_name
FROM unit_driver_assignments a
JOIN drivers d ON d.id = a.driver_id
JOIN users u ON u.id = d.user_id
WHERE a.company_id = $1 AND a.unit_id = $2 AND a.unassigned_at IS NULL;

-- name: ListUnitAssignmentHistory :many
SELECT * FROM unit_driver_assignments
WHERE company_id = $1 AND unit_id = $2 AND assigned_at >= $3 AND assigned_at < $4
ORDER BY assigned_at DESC LIMIT $5 OFFSET $6;

-- name: GetActiveUnitForDriver :one
SELECT u.* FROM unit_driver_assignments a
JOIN units u ON u.id = a.unit_id
WHERE a.company_id = $1 AND a.driver_id = $2 AND a.unassigned_at IS NULL AND u.deleted_at IS NULL
ORDER BY a.assigned_at DESC LIMIT 1;

-- name: ListUnitsForExport :many
SELECT u.*, b.name AS branch_name
FROM units u
LEFT JOIN branches b ON b.id = u.branch_id
WHERE u.company_id = sqlc.arg(company_id)::uuid
  AND u.deleted_at IS NULL
  AND (sqlc.narg(status)::text IS NULL OR u.status = sqlc.narg(status)::text)
  AND (sqlc.narg(branch_id)::uuid IS NULL OR u.branch_id = sqlc.narg(branch_id)::uuid)
  AND (sqlc.arg(include_inactive)::bool OR u.status <> 'inactive')
ORDER BY u.unit_number
LIMIT sqlc.arg(lim);

-- name: FindExistingUnitNumbers :many
SELECT lower(unit_number)::text AS unit_number FROM units
WHERE company_id = sqlc.arg(company_id)::uuid AND deleted_at IS NULL
  AND lower(unit_number) = ANY(sqlc.arg(unit_numbers)::text[]);

-- name: FindExistingVINs :many
SELECT upper(vin)::text AS vin FROM units
WHERE company_id = sqlc.arg(company_id)::uuid AND deleted_at IS NULL AND vin IS NOT NULL
  AND upper(vin) = ANY(sqlc.arg(vins)::text[]);
