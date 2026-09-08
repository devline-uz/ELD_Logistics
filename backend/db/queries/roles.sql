-- name: CreateRole :one
INSERT INTO roles (company_id, name, description, scope, is_system)
VALUES ($1,$2,$3,$4,false) RETURNING *;

-- name: GetRole :one
SELECT * FROM roles
WHERE id = $1 AND (company_id = $2 OR company_id IS NULL) AND deleted_at IS NULL;

-- name: GetRoleByID :one
SELECT * FROM roles WHERE id = $1 AND deleted_at IS NULL;

-- name: ListRoles :many
-- Tizim shablonlari (company_id IS NULL) + kompaniya rollari.
-- user_count faqat joriy tenant foydalanuvchilari bo'yicha sanaladi.
SELECT
  r.*,
  (SELECT count(*) FROM users u
    WHERE u.role_id = r.id AND u.company_id = sqlc.arg(company_id)::uuid AND u.deleted_at IS NULL) AS user_count
FROM roles r
WHERE (r.company_id = sqlc.arg(company_id)::uuid OR r.company_id IS NULL)
  AND r.deleted_at IS NULL
  AND (sqlc.narg(scope)::text IS NULL OR r.scope = sqlc.narg(scope)::text)
  AND (sqlc.narg(is_system)::bool IS NULL OR r.is_system = sqlc.narg(is_system)::bool)
  AND (sqlc.narg(search)::text IS NULL OR r.name ILIKE '%' || sqlc.narg(search)::text || '%')
ORDER BY
  CASE WHEN sqlc.arg(sort_key)::text = 'name'       AND NOT sqlc.arg(sort_desc)::bool THEN lower(r.name)  END ASC  NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'name'       AND     sqlc.arg(sort_desc)::bool THEN lower(r.name)  END DESC NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'scope'      AND NOT sqlc.arg(sort_desc)::bool THEN r.scope        END ASC  NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'scope'      AND     sqlc.arg(sort_desc)::bool THEN r.scope        END DESC NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'created_at' AND NOT sqlc.arg(sort_desc)::bool THEN r.created_at   END ASC  NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'created_at' AND     sqlc.arg(sort_desc)::bool THEN r.created_at   END DESC NULLS LAST,
  r.is_system DESC, lower(r.name), r.id
LIMIT sqlc.arg(page_limit)::int OFFSET sqlc.arg(page_offset)::int;

-- name: CountRoles :one
SELECT count(*) FROM roles r
WHERE (r.company_id = sqlc.arg(company_id)::uuid OR r.company_id IS NULL)
  AND r.deleted_at IS NULL
  AND (sqlc.narg(scope)::text IS NULL OR r.scope = sqlc.narg(scope)::text)
  AND (sqlc.narg(is_system)::bool IS NULL OR r.is_system = sqlc.narg(is_system)::bool)
  AND (sqlc.narg(search)::text IS NULL OR r.name ILIKE '%' || sqlc.narg(search)::text || '%');

-- name: ListSystemRoleTemplates :many
SELECT * FROM roles WHERE company_id IS NULL AND is_system AND deleted_at IS NULL ORDER BY name;

-- name: UpdateRole :one
-- is_system = false: tizim rollari hech qachon tahrirlanmaydi (SYSTEM_ROLE_IMMUTABLE).
UPDATE roles SET
  name        = COALESCE(sqlc.narg(name)::text, name),
  description = COALESCE(sqlc.narg(description)::text, description),
  scope       = COALESCE(sqlc.narg(scope)::text, scope)
WHERE company_id = sqlc.arg(company_id)::uuid AND id = sqlc.arg(id)::uuid
  AND is_system = false AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteRole :exec
UPDATE roles SET deleted_at = now()
WHERE company_id = $1 AND id = $2 AND is_system = false AND deleted_at IS NULL;

-- name: ListRolePermissions :many
SELECT permission_key FROM role_permissions WHERE role_id = $1 ORDER BY permission_key;

-- name: ListPermissionsForRoles :many
SELECT role_id, permission_key FROM role_permissions WHERE role_id = ANY($1::uuid[]);

-- AddRolePermissions — DeleteRolePermissions bilan bitta tranzaksiyada chaqiriladi
-- (data-modifying CTE bir snapshot'da ishlagani uchun ular birlashtirilmaydi).
-- name: AddRolePermissions :exec
INSERT INTO role_permissions (role_id, permission_key)
SELECT $1, k FROM unnest($2::text[]) AS k
ON CONFLICT DO NOTHING;

-- name: DeleteRolePermissions :exec
DELETE FROM role_permissions WHERE role_id = $1;

-- name: CountUsersWithRole :one
SELECT count(*) FROM users WHERE company_id = $1 AND role_id = $2 AND deleted_at IS NULL;

-- name: GetRoleWithUserCount :one
SELECT
  r.*,
  (SELECT count(*) FROM users u
    WHERE u.role_id = r.id AND u.company_id = sqlc.arg(company_id)::uuid AND u.deleted_at IS NULL) AS user_count
FROM roles r
WHERE r.id = sqlc.arg(id)::uuid
  AND (r.company_id = sqlc.arg(company_id)::uuid OR r.company_id IS NULL)
  AND r.deleted_at IS NULL;

-- name: GetRoleByNameForCompany :one
-- Kompaniya roli ustunlik qiladi; topilmasa tizim shabloni (company_id IS NULL).
SELECT * FROM roles
WHERE lower(name) = lower(sqlc.arg(name)::text)
  AND (company_id = sqlc.arg(company_id)::uuid OR company_id IS NULL)
  AND deleted_at IS NULL
ORDER BY company_id NULLS LAST
LIMIT 1;
