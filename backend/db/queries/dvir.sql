-- name: CreateDvirReport :one
INSERT INTO dvir_reports (
  company_id, unit_id, driver_id, type, trailer_ids, status, defects,
  lat, lng, location_text, odometer_m, engine_hours, driver_signature_key,
  source, performed_at
) VALUES (
  sqlc.arg('company_id'), sqlc.arg('unit_id'), sqlc.arg('driver_id'), sqlc.arg('type'),
  sqlc.arg('trailer_ids'), sqlc.arg('status'), sqlc.arg('defects'),
  sqlc.narg('lat'), sqlc.narg('lng'), sqlc.narg('location_text'),
  sqlc.narg('odometer_m'), sqlc.narg('engine_hours'), sqlc.narg('driver_signature_key'),
  sqlc.arg('source'), sqlc.arg('performed_at')
)
RETURNING *;

-- name: GetDvirReport :one
SELECT * FROM dvir_reports WHERE company_id = $1 AND id = $2;

-- name: GetDvirReportDetail :one
SELECT r.*, un.unit_number, un.out_of_service, u.first_name, u.last_name
FROM dvir_reports r
JOIN units un ON un.id = r.unit_id
JOIN drivers d ON d.id = r.driver_id
JOIN users   u ON u.id = d.user_id
WHERE r.company_id = $1 AND r.id = $2;

-- name: ListDvirReports :many
SELECT r.*, un.unit_number, un.out_of_service, u.first_name, u.last_name
FROM dvir_reports r
JOIN units un ON un.id = r.unit_id
JOIN drivers d ON d.id = r.driver_id
JOIN users   u ON u.id = d.user_id
WHERE r.company_id = sqlc.arg('company_id')
  AND (sqlc.narg('unit_id')::uuid IS NULL OR r.unit_id = sqlc.narg('unit_id')::uuid)
  AND (sqlc.narg('driver_id')::uuid IS NULL OR r.driver_id = sqlc.narg('driver_id')::uuid)
  AND (sqlc.narg('branch_id')::uuid IS NULL OR un.branch_id = sqlc.narg('branch_id')::uuid)
  AND (sqlc.narg('status')::text IS NULL OR r.status = sqlc.narg('status')::text)
  AND (sqlc.narg('type')::text IS NULL OR r.type = sqlc.narg('type')::text)
  AND (sqlc.narg('from')::timestamptz IS NULL OR r.performed_at >= sqlc.narg('from')::timestamptz)
  AND (sqlc.narg('to')::timestamptz IS NULL OR r.performed_at < sqlc.narg('to')::timestamptz)
ORDER BY r.performed_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountDvirReports :one
SELECT count(*) FROM dvir_reports r
JOIN units un ON un.id = r.unit_id
WHERE r.company_id = sqlc.arg('company_id')
  AND (sqlc.narg('unit_id')::uuid IS NULL OR r.unit_id = sqlc.narg('unit_id')::uuid)
  AND (sqlc.narg('driver_id')::uuid IS NULL OR r.driver_id = sqlc.narg('driver_id')::uuid)
  AND (sqlc.narg('branch_id')::uuid IS NULL OR un.branch_id = sqlc.narg('branch_id')::uuid)
  AND (sqlc.narg('status')::text IS NULL OR r.status = sqlc.narg('status')::text)
  AND (sqlc.narg('type')::text IS NULL OR r.type = sqlc.narg('type')::text)
  AND (sqlc.narg('from')::timestamptz IS NULL OR r.performed_at >= sqlc.narg('from')::timestamptz)
  AND (sqlc.narg('to')::timestamptz IS NULL OR r.performed_at < sqlc.narg('to')::timestamptz);

-- name: ListDvirPendingCertification :many
SELECT r.*, un.unit_number, un.out_of_service, u.first_name, u.last_name
FROM dvir_reports r
JOIN units un ON un.id = r.unit_id
JOIN drivers d ON d.id = r.driver_id
JOIN users   u ON u.id = d.user_id
WHERE r.company_id = sqlc.arg('company_id')
  AND r.status IN ('submitted_defects_found','repaired')
  AND (sqlc.narg('unit_id')::uuid IS NULL OR r.unit_id = sqlc.narg('unit_id')::uuid)
ORDER BY r.performed_at DESC
LIMIT sqlc.arg('limit');

-- name: RepairDvirReport :one
UPDATE dvir_reports SET
  status                 = 'repaired',
  mechanic_id            = sqlc.narg('mechanic_id'),
  mechanic_note          = sqlc.narg('mechanic_note'),
  mechanic_signature_key = sqlc.narg('mechanic_signature_key'),
  repaired_at            = now()
WHERE company_id = sqlc.arg('company_id') AND id = sqlc.arg('id')
  AND status = 'submitted_defects_found'
RETURNING *;

-- name: CertifyDvirReport :one
UPDATE dvir_reports SET
  status                      = 'certified',
  certified_by_driver_id      = sqlc.arg('certified_by_driver_id'),
  certification_signature_key = sqlc.narg('certification_signature_key'),
  certified_at                = now()
WHERE company_id = sqlc.arg('company_id') AND id = sqlc.arg('id') AND status = 'repaired'
RETURNING *;

-- name: CloseDvirNoCertification :one
UPDATE dvir_reports SET
  status        = 'closed_no_certification',
  closed_at     = now(),
  closed_reason = sqlc.narg('closed_reason')
WHERE company_id = sqlc.arg('company_id') AND id = sqlc.arg('id')
  AND status IN ('submitted_defects_found','repaired')
RETURNING *;

-- name: GetLastDvirForUnit :one
SELECT * FROM dvir_reports
WHERE company_id = sqlc.arg('company_id') AND unit_id = sqlc.arg('unit_id')
  AND (sqlc.narg('type')::text IS NULL OR type = sqlc.narg('type')::text)
ORDER BY performed_at DESC LIMIT 1;

-- name: CountDvirForUnitAfter :one
SELECT count(*) FROM dvir_reports
WHERE company_id = $1 AND unit_id = $2 AND performed_at > sqlc.arg('after')::timestamptz;

-- name: ListDvirCertificationOverdue :many
-- Q30.1 — reports still waiting for the "Previous defects repaired?" signature
-- past the grace window, or whose unit is no longer active.
SELECT r.*, un.status AS unit_status
FROM dvir_reports r
JOIN units un ON un.id = r.unit_id
WHERE r.company_id = sqlc.arg('company_id')
  AND r.status IN ('submitted_defects_found','repaired')
  AND (
        r.performed_at < now() - (sqlc.arg('grace_days')::int || ' days')::interval
     OR un.status <> 'active'
     OR un.deleted_at IS NOT NULL
  )
ORDER BY r.performed_at
LIMIT sqlc.arg('limit');

-- name: SetUnitOutOfService :one
UPDATE units SET out_of_service = sqlc.arg('out_of_service')
WHERE company_id = sqlc.arg('company_id') AND id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING id, unit_number, out_of_service, status;

-- name: GetDvirUnit :one
SELECT id, unit_number, status, out_of_service, branch_id
FROM units WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: ListDvirTrailers :many
SELECT id, number FROM trailers
WHERE company_id = $1 AND id = ANY(sqlc.arg('ids')::uuid[]) AND deleted_at IS NULL;

-- name: GetDvirDriverByUser :one
SELECT d.id, d.user_id, d.status, d.branch_id
FROM drivers d
WHERE d.company_id = $1 AND d.user_id = $2 AND d.deleted_at IS NULL;

-- name: CreateDefectType :one
INSERT INTO defect_types (company_id, name, category, is_critical, is_active, sort_order)
VALUES ($1,$2,$3,$4,$5,$6) RETURNING *;

-- name: GetDefectType :one
SELECT * FROM defect_types
WHERE id = $1 AND (company_id = $2 OR company_id IS NULL) AND deleted_at IS NULL;

-- name: ListDefectTypes :many
SELECT * FROM defect_types
WHERE (company_id = sqlc.arg('company_id') OR company_id IS NULL) AND deleted_at IS NULL
  AND (sqlc.narg('category')::text IS NULL OR category = sqlc.narg('category')::text)
  AND (sqlc.narg('is_active')::bool IS NULL OR is_active = sqlc.narg('is_active')::bool)
  AND (sqlc.narg('is_critical')::bool IS NULL OR is_critical = sqlc.narg('is_critical')::bool)
ORDER BY category, sort_order, name
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountDefectTypes :one
SELECT count(*) FROM defect_types
WHERE (company_id = sqlc.arg('company_id') OR company_id IS NULL) AND deleted_at IS NULL
  AND (sqlc.narg('category')::text IS NULL OR category = sqlc.narg('category')::text)
  AND (sqlc.narg('is_active')::bool IS NULL OR is_active = sqlc.narg('is_active')::bool)
  AND (sqlc.narg('is_critical')::bool IS NULL OR is_critical = sqlc.narg('is_critical')::bool);

-- name: ListDefectTypesByIDs :many
SELECT * FROM defect_types
WHERE id = ANY(sqlc.arg('ids')::uuid[])
  AND (company_id = sqlc.arg('company_id') OR company_id IS NULL) AND deleted_at IS NULL;

-- name: UpdateDefectType :one
UPDATE defect_types SET
  name        = COALESCE(sqlc.narg('name')::text, name),
  category    = COALESCE(sqlc.narg('category')::text, category),
  is_critical = COALESCE(sqlc.narg('is_critical')::bool, is_critical),
  is_active   = COALESCE(sqlc.narg('is_active')::bool, is_active),
  sort_order  = COALESCE(sqlc.narg('sort_order')::int, sort_order)
WHERE company_id = sqlc.arg('company_id') AND id = sqlc.arg('id') AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteDefectType :exec
UPDATE defect_types SET deleted_at = now() WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;
