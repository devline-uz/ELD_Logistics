-- name: CreateDriver :one
INSERT INTO drivers (
  company_id, user_id, branch_id, license_no_enc, license_region, home_terminal,
  city, state, zip, address1, address2, notes, fleet_manager_id, default_unit_id, status, activated_on
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
RETURNING *;

-- name: GetDriver :one
SELECT * FROM drivers WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: GetDriverByUserID :one
SELECT * FROM drivers WHERE company_id = $1 AND user_id = $2 AND deleted_at IS NULL;

-- name: ListDrivers :many
SELECT d.*, u.first_name, u.last_name, u.username, u.email, u.phone
FROM drivers d
JOIN users u ON u.id = d.user_id
WHERE d.company_id = $1 AND d.deleted_at IS NULL
  AND ($2::text IS NULL OR (u.first_name || ' ' || u.last_name || ' ' || u.username) ILIKE '%' || $2::text || '%')
  AND ($3::text IS NULL OR d.status = $3::text)
  AND ($4::uuid IS NULL OR d.branch_id = $4::uuid)
  AND ($5::uuid IS NULL OR d.fleet_manager_id = $5::uuid)
ORDER BY u.last_name, u.first_name
LIMIT $6 OFFSET $7;

-- name: CountDrivers :one
SELECT count(*)
FROM drivers d
JOIN users u ON u.id = d.user_id
WHERE d.company_id = $1 AND d.deleted_at IS NULL
  AND ($2::text IS NULL OR (u.first_name || ' ' || u.last_name || ' ' || u.username) ILIKE '%' || $2::text || '%')
  AND ($3::text IS NULL OR d.status = $3::text)
  AND ($4::uuid IS NULL OR d.branch_id = $4::uuid)
  AND ($5::uuid IS NULL OR d.fleet_manager_id = $5::uuid);

-- name: UpdateDriver :one
UPDATE drivers SET
  branch_id        = COALESCE($3::uuid, branch_id),
  license_no_enc   = COALESCE($4::text, license_no_enc),
  license_region   = COALESCE($5::text, license_region),
  home_terminal    = COALESCE($6::text, home_terminal),
  city             = COALESCE($7::text, city),
  state            = COALESCE($8::text, state),
  zip              = COALESCE($9::text, zip),
  address1         = COALESCE($10::text, address1),
  address2         = COALESCE($11::text, address2),
  notes            = COALESCE($12::text, notes),
  fleet_manager_id = COALESCE($13::uuid, fleet_manager_id),
  default_unit_id  = COALESCE($14::uuid, default_unit_id)
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL
RETURNING *;

-- name: SetDriverStatus :one
UPDATE drivers SET status = $3, activated_on = CASE WHEN $3 = 'active' THEN COALESCE(activated_on, now()) ELSE activated_on END
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL RETURNING *;

-- name: SetDriverAppVersion :exec
UPDATE drivers SET app_version = $3 WHERE company_id = $1 AND id = $2;

-- name: SoftDeleteDriver :exec
UPDATE drivers SET deleted_at = now(), status = 'inactive'
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: CreateDriverPair :one
INSERT INTO driver_pairs (company_id, driver_a_id, driver_b_id)
VALUES ($1, LEAST($2::uuid,$3::uuid), GREATEST($2::uuid,$3::uuid))
RETURNING *;

-- name: ListCoDrivers :many
SELECT d.*
FROM driver_pairs p
JOIN drivers d ON d.id = CASE WHEN p.driver_a_id = $2 THEN p.driver_b_id ELSE p.driver_a_id END
WHERE p.company_id = $1 AND p.deleted_at IS NULL AND d.deleted_at IS NULL
  AND (p.driver_a_id = $2 OR p.driver_b_id = $2);

-- name: DeleteDriverPair :exec
UPDATE driver_pairs SET deleted_at = now()
WHERE company_id = $1
  AND driver_a_id = LEAST($2::uuid,$3::uuid)
  AND driver_b_id = GREATEST($2::uuid,$3::uuid)
  AND deleted_at IS NULL;

-- name: CreateSignature :one
INSERT INTO signatures (company_id, user_id, image_key_enc, is_default)
VALUES ($1,$2,$3,$4) RETURNING *;

-- name: GetDefaultSignature :one
SELECT * FROM signatures
WHERE company_id = $1 AND user_id = $2 AND is_default AND deleted_at IS NULL;

-- name: ClearDefaultSignature :exec
UPDATE signatures SET is_default = false
WHERE company_id = $1 AND user_id = $2 AND is_default AND deleted_at IS NULL;

-- name: ListSignatures :many
SELECT * FROM signatures WHERE company_id = $1 AND user_id = $2 AND deleted_at IS NULL
ORDER BY created_at DESC;

-- ---------------------------------------------------------------------------
-- Driver Management (internal/domain/drivers). Barcha filtrlar `sqlc.narg` —
-- NULL = filtr yo'q; saralash kaliti oq ro'yxatdan keladi (konkatenatsiya yo'q).
-- ---------------------------------------------------------------------------

-- name: ListDriversPage :many
SELECT d.*,
       u.first_name, u.last_name, u.username, u.email, u.phone,
       u.status AS user_status, u.last_login_at,
       fm.first_name AS fleet_manager_first_name,
       fm.last_name  AS fleet_manager_last_name,
       un.unit_number AS default_unit_number,
       b.name AS branch_name
FROM drivers d
JOIN users u ON u.id = d.user_id
LEFT JOIN users fm ON fm.id = d.fleet_manager_id
LEFT JOIN units un ON un.id = d.default_unit_id
LEFT JOIN branches b ON b.id = d.branch_id
WHERE d.company_id = sqlc.arg(company_id)::uuid
  AND d.deleted_at IS NULL
  AND (sqlc.narg(search)::text IS NULL
       OR (u.first_name || ' ' || u.last_name || ' ' || u.username
           || ' ' || COALESCE(u.email,'') || ' ' || COALESCE(u.phone,''))
          ILIKE '%' || sqlc.narg(search)::text || '%')
  AND (sqlc.narg(status)::text IS NULL OR d.status = sqlc.narg(status)::text)
  AND (sqlc.narg(branch_id)::uuid IS NULL OR d.branch_id = sqlc.narg(branch_id)::uuid)
  AND (sqlc.narg(fleet_manager_id)::uuid IS NULL OR d.fleet_manager_id = sqlc.narg(fleet_manager_id)::uuid)
  AND (sqlc.arg(include_inactive)::bool OR d.status <> 'inactive')
ORDER BY
  CASE WHEN sqlc.arg(sort_key)::text = 'name.desc'       THEN u.last_name END DESC,
  CASE WHEN sqlc.arg(sort_key)::text = 'username.asc'    THEN u.username END ASC,
  CASE WHEN sqlc.arg(sort_key)::text = 'username.desc'   THEN u.username END DESC,
  CASE WHEN sqlc.arg(sort_key)::text = 'status.asc'      THEN d.status END ASC,
  CASE WHEN sqlc.arg(sort_key)::text = 'status.desc'     THEN d.status END DESC,
  CASE WHEN sqlc.arg(sort_key)::text = 'created_at.asc'  THEN d.created_at END ASC,
  CASE WHEN sqlc.arg(sort_key)::text = 'created_at.desc' THEN d.created_at END DESC,
  u.last_name, u.first_name
LIMIT sqlc.arg(lim) OFFSET sqlc.arg(off);

-- name: CountDriversPage :one
SELECT count(*)
FROM drivers d
JOIN users u ON u.id = d.user_id
WHERE d.company_id = sqlc.arg(company_id)::uuid
  AND d.deleted_at IS NULL
  AND (sqlc.narg(search)::text IS NULL
       OR (u.first_name || ' ' || u.last_name || ' ' || u.username
           || ' ' || COALESCE(u.email,'') || ' ' || COALESCE(u.phone,''))
          ILIKE '%' || sqlc.narg(search)::text || '%')
  AND (sqlc.narg(status)::text IS NULL OR d.status = sqlc.narg(status)::text)
  AND (sqlc.narg(branch_id)::uuid IS NULL OR d.branch_id = sqlc.narg(branch_id)::uuid)
  AND (sqlc.narg(fleet_manager_id)::uuid IS NULL OR d.fleet_manager_id = sqlc.narg(fleet_manager_id)::uuid)
  AND (sqlc.arg(include_inactive)::bool OR d.status <> 'inactive');

-- name: GetDriverDetail :one
SELECT d.*,
       u.first_name, u.last_name, u.username, u.email, u.phone,
       u.status AS user_status, u.last_login_at,
       fm.first_name AS fleet_manager_first_name,
       fm.last_name  AS fleet_manager_last_name,
       un.unit_number AS default_unit_number,
       b.name AS branch_name
FROM drivers d
JOIN users u ON u.id = d.user_id
LEFT JOIN users fm ON fm.id = d.fleet_manager_id
LEFT JOIN units un ON un.id = d.default_unit_id
LEFT JOIN branches b ON b.id = d.branch_id
WHERE d.company_id = sqlc.arg(company_id)::uuid AND d.id = sqlc.arg(id)::uuid AND d.deleted_at IS NULL;

-- name: ListDriversForExport :many
SELECT d.*,
       u.first_name, u.last_name, u.username, u.email, u.phone,
       u.status AS user_status, u.last_login_at,
       fm.first_name AS fleet_manager_first_name,
       fm.last_name  AS fleet_manager_last_name,
       un.unit_number AS default_unit_number,
       b.name AS branch_name
FROM drivers d
JOIN users u ON u.id = d.user_id
LEFT JOIN users fm ON fm.id = d.fleet_manager_id
LEFT JOIN units un ON un.id = d.default_unit_id
LEFT JOIN branches b ON b.id = d.branch_id
WHERE d.company_id = sqlc.arg(company_id)::uuid
  AND d.deleted_at IS NULL
  AND (sqlc.narg(status)::text IS NULL OR d.status = sqlc.narg(status)::text)
  AND (sqlc.narg(branch_id)::uuid IS NULL OR d.branch_id = sqlc.narg(branch_id)::uuid)
  AND (sqlc.arg(include_inactive)::bool OR d.status <> 'inactive')
ORDER BY u.last_name, u.first_name
LIMIT sqlc.arg(lim);

-- name: ListCoDriverDetails :many
SELECT d.*,
       u.first_name, u.last_name, u.username, u.email, u.phone,
       u.status AS user_status, u.last_login_at,
       p.id AS pair_id, p.created_at AS paired_at
FROM driver_pairs p
JOIN drivers d ON d.id = CASE WHEN p.driver_a_id = sqlc.arg(driver_id)::uuid THEN p.driver_b_id ELSE p.driver_a_id END
JOIN users u ON u.id = d.user_id
WHERE p.company_id = sqlc.arg(company_id)::uuid
  AND p.deleted_at IS NULL AND d.deleted_at IS NULL
  AND (p.driver_a_id = sqlc.arg(driver_id)::uuid OR p.driver_b_id = sqlc.arg(driver_id)::uuid)
ORDER BY u.last_name, u.first_name;

-- name: GetDriverPairAny :one
-- Soft-delete qilingan juftlikni ham qaytaradi (qayta tiklash uchun).
SELECT * FROM driver_pairs
WHERE company_id = sqlc.arg(company_id)::uuid
  AND driver_a_id = LEAST(sqlc.arg(driver_a)::uuid, sqlc.arg(driver_b)::uuid)
  AND driver_b_id = GREATEST(sqlc.arg(driver_a)::uuid, sqlc.arg(driver_b)::uuid);

-- name: RestoreDriverPair :one
UPDATE driver_pairs SET deleted_at = NULL
WHERE company_id = sqlc.arg(company_id)::uuid AND id = sqlc.arg(id)::uuid
RETURNING *;

-- name: ListDriverActivities :many
SELECT act.id, act.occurred_at, act.action, act.table_name, act.field,
       act.old_value, act.new_value, act.ip, act.user_agent, act.actor_id
FROM (
  SELECT a.id                AS id,
         a.ts                AS occurred_at,
         a.action            AS action,
         a.table_name        AS table_name,
         a.field             AS field,
         a.old_value         AS old_value,
         a.new_value         AS new_value,
         COALESCE(host(a.ip), '')::text AS ip,
         a.user_agent        AS user_agent,
         a.edited_by         AS actor_id
  FROM audit_log a
  WHERE a.company_id = sqlc.arg(company_id)::uuid
    AND ((a.table_name = 'drivers' AND a.record_id = sqlc.arg(driver_id)::uuid)
      OR (a.table_name = 'users'   AND a.record_id = sqlc.arg(user_id)::uuid)
      OR (a.edited_by = sqlc.arg(user_id)::uuid))
  UNION ALL
  SELECT s.id,
         COALESCE(s.last_seen_at, s.created_at),
         'session_' || s.status,
         'sessions',
         s.device_type,
         NULL::jsonb,
         NULL::jsonb,
         COALESCE(host(s.ip), '')::text,
         s.user_agent,
         s.user_id
  FROM sessions s
  WHERE s.company_id = sqlc.arg(company_id)::uuid AND s.user_id = sqlc.arg(user_id)::uuid
) act
ORDER BY act.occurred_at DESC
LIMIT sqlc.arg(lim) OFFSET sqlc.arg(off);

-- name: CountDriverActivities :one
SELECT ((
  SELECT count(*) FROM audit_log a
  WHERE a.company_id = sqlc.arg(company_id)::uuid
    AND ((a.table_name = 'drivers' AND a.record_id = sqlc.arg(driver_id)::uuid)
      OR (a.table_name = 'users'   AND a.record_id = sqlc.arg(user_id)::uuid)
      OR (a.edited_by = sqlc.arg(user_id)::uuid))
) + (
  SELECT count(*) FROM sessions s
  WHERE s.company_id = sqlc.arg(company_id)::uuid AND s.user_id = sqlc.arg(user_id)::uuid
))::bigint AS total;

-- name: SetDriverLicense :one
UPDATE drivers SET license_no_enc = sqlc.narg(license_no_enc)::text
WHERE company_id = sqlc.arg(company_id)::uuid AND id = sqlc.arg(id)::uuid AND deleted_at IS NULL
RETURNING *;

-- name: UpdateDriverPartial :one
-- PATCH /drivers/{id}: NULL argument = maydon o'zgarmaydi (COALESCE), shu bilan
-- bo'sh satr bilan tasodifiy o'chirib yuborish mumkin emas.
UPDATE drivers SET
  branch_id        = CASE WHEN sqlc.arg(clear_branch)::bool THEN NULL
                          ELSE COALESCE(sqlc.narg(branch_id)::uuid, branch_id) END,
  license_no_enc   = COALESCE(sqlc.narg(license_no_enc)::text, license_no_enc),
  license_region   = COALESCE(sqlc.narg(license_region)::text, license_region),
  home_terminal    = COALESCE(sqlc.narg(home_terminal)::text, home_terminal),
  city             = COALESCE(sqlc.narg(city)::text, city),
  state            = COALESCE(sqlc.narg(state)::text, state),
  zip              = COALESCE(sqlc.narg(zip)::text, zip),
  address1         = COALESCE(sqlc.narg(address1)::text, address1),
  address2         = COALESCE(sqlc.narg(address2)::text, address2),
  notes            = COALESCE(sqlc.narg(notes)::text, notes),
  fleet_manager_id = CASE WHEN sqlc.arg(clear_fleet_manager)::bool THEN NULL
                          ELSE COALESCE(sqlc.narg(fleet_manager_id)::uuid, fleet_manager_id) END,
  default_unit_id  = CASE WHEN sqlc.arg(clear_default_unit)::bool THEN NULL
                          ELSE COALESCE(sqlc.narg(default_unit_id)::uuid, default_unit_id) END
WHERE company_id = sqlc.arg(company_id)::uuid AND id = sqlc.arg(id)::uuid AND deleted_at IS NULL
RETURNING *;
