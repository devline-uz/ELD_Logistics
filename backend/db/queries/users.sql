-- name: CreateUser :one
INSERT INTO users (
  company_id, branch_id, first_name, last_name, email, phone,
  username, password_hash, role_id, status, invited_at
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
RETURNING *;

-- name: GetUser :one
SELECT * FROM users WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: GetUserByID :one
SELECT * FROM users WHERE id = $1 AND deleted_at IS NULL;

-- name: GetUserByUsername :one
-- company_id NULL -> super admin (company_id IS NULL) yozuvi qidiriladi.
SELECT * FROM users
WHERE lower(username) = lower(sqlc.arg(username)::text)
  AND ((sqlc.narg(company_id)::uuid IS NULL AND company_id IS NULL)
       OR company_id = sqlc.narg(company_id)::uuid)
  AND deleted_at IS NULL;

-- name: FindUsersByLogin :many
-- Login oldidan (autentifikatsiyasiz) username yoki email bo'yicha nomzodlar.
-- Bir nechta kompaniyada bir xil username bo'lsa, xizmat qatlami
-- `company_id` bilan aniqlashtiradi; aniqlanmasa INVALID_CREDENTIALS.
SELECT * FROM users
WHERE deleted_at IS NULL
  AND (lower(username) = lower(sqlc.arg(login)::text)
       OR lower(email) = lower(sqlc.arg(login)::text))
ORDER BY created_at
LIMIT 10;

-- name: GetUserByEmail :one
SELECT * FROM users
WHERE lower(email) = lower($1::text) AND company_id = $2 AND deleted_at IS NULL;

-- name: ListUsers :many
-- Ro'yxat: filtr + saralash oq ro'yxati (CASE -> string konkatenatsiyasi yo'q).
SELECT
  u.*,
  r.name      AS role_name,
  r.scope     AS role_scope,
  r.is_system AS role_is_system,
  b.name      AS branch_name
FROM users u
JOIN roles r ON r.id = u.role_id
LEFT JOIN branches b ON b.id = u.branch_id
WHERE u.company_id = sqlc.arg(company_id)::uuid
  AND u.deleted_at IS NULL
  AND (sqlc.narg(search)::text IS NULL
       OR (u.first_name || ' ' || u.last_name || ' ' || u.username || ' ' || coalesce(u.email, '') || ' ' || coalesce(u.phone, ''))
          ILIKE '%' || sqlc.narg(search)::text || '%')
  AND (sqlc.narg(status)::text IS NULL OR u.status = sqlc.narg(status)::text)
  AND (sqlc.narg(role_id)::uuid IS NULL OR u.role_id = sqlc.narg(role_id)::uuid)
  AND (sqlc.narg(branch_id)::uuid IS NULL OR u.branch_id = sqlc.narg(branch_id)::uuid)
ORDER BY
  CASE WHEN sqlc.arg(sort_key)::text = 'last_name'  AND NOT sqlc.arg(sort_desc)::bool THEN lower(u.last_name)  END ASC  NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'last_name'  AND     sqlc.arg(sort_desc)::bool THEN lower(u.last_name)  END DESC NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'first_name' AND NOT sqlc.arg(sort_desc)::bool THEN lower(u.first_name) END ASC  NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'first_name' AND     sqlc.arg(sort_desc)::bool THEN lower(u.first_name) END DESC NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'username'   AND NOT sqlc.arg(sort_desc)::bool THEN lower(u.username)   END ASC  NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'username'   AND     sqlc.arg(sort_desc)::bool THEN lower(u.username)   END DESC NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'email'      AND NOT sqlc.arg(sort_desc)::bool THEN lower(u.email)      END ASC  NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'email'      AND     sqlc.arg(sort_desc)::bool THEN lower(u.email)      END DESC NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'status'     AND NOT sqlc.arg(sort_desc)::bool THEN u.status            END ASC  NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'status'     AND     sqlc.arg(sort_desc)::bool THEN u.status            END DESC NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'created_at' AND NOT sqlc.arg(sort_desc)::bool THEN u.created_at        END ASC  NULLS LAST,
  CASE WHEN sqlc.arg(sort_key)::text = 'created_at' AND     sqlc.arg(sort_desc)::bool THEN u.created_at        END DESC NULLS LAST,
  lower(u.last_name), lower(u.first_name), u.id
LIMIT sqlc.arg(page_limit)::int OFFSET sqlc.arg(page_offset)::int;

-- name: CountUsers :one
SELECT count(*) FROM users u
WHERE u.company_id = sqlc.arg(company_id)::uuid
  AND u.deleted_at IS NULL
  AND (sqlc.narg(search)::text IS NULL
       OR (u.first_name || ' ' || u.last_name || ' ' || u.username || ' ' || coalesce(u.email, '') || ' ' || coalesce(u.phone, ''))
          ILIKE '%' || sqlc.narg(search)::text || '%')
  AND (sqlc.narg(status)::text IS NULL OR u.status = sqlc.narg(status)::text)
  AND (sqlc.narg(role_id)::uuid IS NULL OR u.role_id = sqlc.narg(role_id)::uuid)
  AND (sqlc.narg(branch_id)::uuid IS NULL OR u.branch_id = sqlc.narg(branch_id)::uuid);

-- name: GetUserDetail :one
-- Bitta foydalanuvchi + rol/filial nomlari. Cross-tenant -> qator yo'q -> 404.
SELECT
  u.*,
  r.name      AS role_name,
  r.scope     AS role_scope,
  r.is_system AS role_is_system,
  b.name      AS branch_name
FROM users u
JOIN roles r ON r.id = u.role_id
LEFT JOIN branches b ON b.id = u.branch_id
WHERE u.company_id = sqlc.arg(company_id)::uuid
  AND u.id = sqlc.arg(id)::uuid
  AND u.deleted_at IS NULL;

-- name: CountCompanyAdministrators :one
-- Q81: oxirgi Administrator o'chirilmaydi/deaktivatsiya qilinmaydi.
SELECT count(*) FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.company_id = sqlc.arg(company_id)::uuid
  AND u.deleted_at IS NULL
  AND u.status = 'active'
  AND r.is_system
  AND lower(r.name) = 'administrator'
  AND u.id <> sqlc.arg(exclude_user_id)::uuid;

-- name: SetUserStatus :one
-- Q1: active <-> inactive qaytariladigan o'tish.
UPDATE users SET
  status       = sqlc.arg(status)::text,
  activated_at = CASE WHEN sqlc.arg(status)::text = 'active' THEN COALESCE(activated_at, now()) ELSE activated_at END
WHERE company_id = sqlc.arg(company_id)::uuid AND id = sqlc.arg(id)::uuid AND deleted_at IS NULL
RETURNING *;

-- name: UpdateUser :one
UPDATE users SET
  first_name = COALESCE(sqlc.narg(first_name)::text, first_name),
  last_name  = COALESCE(sqlc.narg(last_name)::text, last_name),
  email      = COALESCE(sqlc.narg(email)::text, email),
  phone      = COALESCE(sqlc.narg(phone)::text, phone),
  username   = COALESCE(sqlc.narg(username)::text, username),
  role_id    = COALESCE(sqlc.narg(role_id)::uuid, role_id),
  branch_id  = CASE WHEN sqlc.arg(clear_branch)::bool THEN NULL
                    ELSE COALESCE(sqlc.narg(branch_id)::uuid, branch_id) END
WHERE company_id = sqlc.arg(company_id)::uuid AND id = sqlc.arg(id)::uuid AND deleted_at IS NULL
RETURNING *;

-- name: SetUserPassword :exec
UPDATE users SET password_hash = $2, status = 'active', activated_at = COALESCE(activated_at, now()),
                 failed_logins = 0, locked_until = NULL
WHERE id = $1 AND deleted_at IS NULL;

-- name: SetUserPin :exec
UPDATE users SET pin_hash = $2 WHERE id = $1 AND deleted_at IS NULL;

-- name: SetUserTotp :exec
UPDATE users SET totp_secret_enc = $2, totp_enabled = $3, recovery_codes = $4
WHERE id = $1 AND deleted_at IS NULL;

-- name: MarkUserLoginSuccess :exec
UPDATE users SET last_login_at = now(), failed_logins = 0, locked_until = NULL WHERE id = $1;

-- name: MarkUserLoginFailure :one
UPDATE users SET failed_logins = failed_logins + 1,
                 locked_until = CASE WHEN failed_logins + 1 >= $2::int THEN now() + ($3::int || ' minutes')::interval ELSE locked_until END
WHERE id = $1
RETURNING failed_logins, locked_until;

-- name: SoftDeleteUser :exec
UPDATE users SET deleted_at = now(), status = 'inactive'
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: ListUsersByRole :many
SELECT * FROM users WHERE company_id = $1 AND role_id = ANY($2::uuid[]) AND status = 'active' AND deleted_at IS NULL;

-- name: FindExistingUsernames :many
-- Import oldidan (all-or-nothing) mavjud username'larni bir so'rovda tekshirish.
SELECT lower(username)::text AS username FROM users
WHERE company_id = sqlc.arg(company_id)::uuid AND deleted_at IS NULL
  AND lower(username) = ANY(sqlc.arg(usernames)::text[]);

-- name: FindExistingEmails :many
SELECT lower(email)::text AS email FROM users
WHERE company_id = sqlc.arg(company_id)::uuid AND deleted_at IS NULL AND email IS NOT NULL
  AND lower(email) = ANY(sqlc.arg(emails)::text[]);
