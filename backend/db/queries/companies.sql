-- name: CreateCompany :one
INSERT INTO companies (
  name, address, home_terminal_address, timezone, email, phone,
  registration_no, region, unit_system, regulation_profile, plan
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
RETURNING *;

-- name: GetCompany :one
SELECT * FROM companies WHERE id = $1 AND deleted_at IS NULL;

-- name: ListCompanies :many
-- Super Admin ro'yxati: nom bo'yicha qidiruv + obuna holati + region filtri.
-- Saralash oq ro'yxati: name | created_at | subscription_end_at.
SELECT * FROM companies
WHERE deleted_at IS NULL
  AND (sqlc.narg(search)::text IS NULL OR name ILIKE '%' || sqlc.narg(search)::text || '%')
  AND (sqlc.narg(status)::text IS NULL OR subscription_status = sqlc.narg(status)::text)
  AND (sqlc.narg(region)::text IS NULL OR region = sqlc.narg(region)::text)
ORDER BY
  CASE WHEN sqlc.arg(sort_by)::text = 'name'                AND sqlc.arg(sort_dir)::text = 'asc'  THEN lower(name) END ASC,
  CASE WHEN sqlc.arg(sort_by)::text = 'name'                AND sqlc.arg(sort_dir)::text = 'desc' THEN lower(name) END DESC,
  CASE WHEN sqlc.arg(sort_by)::text = 'created_at'          AND sqlc.arg(sort_dir)::text = 'asc'  THEN created_at END ASC,
  CASE WHEN sqlc.arg(sort_by)::text = 'created_at'          AND sqlc.arg(sort_dir)::text = 'desc' THEN created_at END DESC,
  CASE WHEN sqlc.arg(sort_by)::text = 'subscription_end_at' AND sqlc.arg(sort_dir)::text = 'asc'  THEN subscription_end_at END ASC,
  CASE WHEN sqlc.arg(sort_by)::text = 'subscription_end_at' AND sqlc.arg(sort_dir)::text = 'desc' THEN subscription_end_at END DESC,
  lower(name) ASC
LIMIT sqlc.arg(row_limit) OFFSET sqlc.arg(row_offset);

-- name: CountCompanies :one
SELECT count(*) FROM companies
WHERE deleted_at IS NULL
  AND (sqlc.narg(search)::text IS NULL OR name ILIKE '%' || sqlc.narg(search)::text || '%')
  AND (sqlc.narg(status)::text IS NULL OR subscription_status = sqlc.narg(status)::text)
  AND (sqlc.narg(region)::text IS NULL OR region = sqlc.narg(region)::text);

-- name: UpdateCompany :one
-- Qisman yangilash: berilmagan maydon NULL bo'lib keladi va tegilmaydi.
UPDATE companies SET
  name                  = COALESCE(sqlc.narg(name)::text, name),
  address               = COALESCE(sqlc.narg(address)::text, address),
  home_terminal_address = COALESCE(sqlc.narg(home_terminal_address)::text, home_terminal_address),
  timezone              = COALESCE(sqlc.narg(timezone)::text, timezone),
  email                 = COALESCE(sqlc.narg(email)::text, email),
  phone                 = COALESCE(sqlc.narg(phone)::text, phone),
  registration_no       = COALESCE(sqlc.narg(registration_no)::text, registration_no),
  logo_key              = COALESCE(sqlc.narg(logo_key)::text, logo_key),
  region                = COALESCE(sqlc.narg(region)::text, region),
  unit_system           = COALESCE(sqlc.narg(unit_system)::text, unit_system),
  regulation_profile    = COALESCE(sqlc.narg(regulation_profile)::text, regulation_profile),
  plan                  = COALESCE(sqlc.narg(plan)::text, plan),
  settings              = settings || COALESCE(sqlc.narg(settings)::jsonb, '{}'::jsonb)
WHERE id = sqlc.arg(id) AND deleted_at IS NULL
RETURNING *;

-- name: UpdateCompanySettings :one
UPDATE companies SET settings = settings || $2::jsonb
WHERE id = $1 AND deleted_at IS NULL RETURNING *;

-- name: UpdateCompanySubscription :one
UPDATE companies SET
  subscription_status = COALESCE(sqlc.narg(subscription_status)::text, subscription_status),
  subscription_end_at = CASE WHEN sqlc.arg(clear_end_at)::boolean THEN NULL
                             ELSE COALESCE(sqlc.narg(subscription_end_at)::timestamptz, subscription_end_at) END,
  plan                = COALESCE(sqlc.narg(plan)::text, plan)
WHERE id = sqlc.arg(id) AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteCompany :exec
UPDATE companies SET deleted_at = now() WHERE id = $1 AND deleted_at IS NULL;

-- name: CreateBranch :one
INSERT INTO branches (company_id, name, address, timezone)
VALUES ($1,$2,$3,$4) RETURNING *;

-- name: GetBranch :one
SELECT * FROM branches WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: ListBranches :many
-- Saralash oq ro'yxati: name | created_at.
SELECT * FROM branches
WHERE company_id = sqlc.arg(company_id) AND deleted_at IS NULL
  AND (sqlc.narg(search)::text IS NULL OR name ILIKE '%' || sqlc.narg(search)::text || '%')
ORDER BY
  CASE WHEN sqlc.arg(sort_by)::text = 'name'       AND sqlc.arg(sort_dir)::text = 'asc'  THEN lower(name) END ASC,
  CASE WHEN sqlc.arg(sort_by)::text = 'name'       AND sqlc.arg(sort_dir)::text = 'desc' THEN lower(name) END DESC,
  CASE WHEN sqlc.arg(sort_by)::text = 'created_at' AND sqlc.arg(sort_dir)::text = 'asc'  THEN created_at END ASC,
  CASE WHEN sqlc.arg(sort_by)::text = 'created_at' AND sqlc.arg(sort_dir)::text = 'desc' THEN created_at END DESC,
  lower(name) ASC
LIMIT sqlc.arg(row_limit) OFFSET sqlc.arg(row_offset);

-- name: CountBranches :one
SELECT count(*) FROM branches
WHERE company_id = sqlc.arg(company_id) AND deleted_at IS NULL
  AND (sqlc.narg(search)::text IS NULL OR name ILIKE '%' || sqlc.narg(search)::text || '%');

-- name: UpdateBranch :one
UPDATE branches SET
  name     = COALESCE(sqlc.narg(name)::text, name),
  address  = COALESCE(sqlc.narg(address)::text, address),
  timezone = COALESCE(sqlc.narg(timezone)::text, timezone)
WHERE company_id = sqlc.arg(company_id) AND id = sqlc.arg(id) AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteBranch :exec
UPDATE branches SET deleted_at = now() WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: CreateHosPolicyVersion :one
-- effective_from NULL bo'lsa DB soati ishlatiladi: ilova va DB soati orasidagi
-- farq tufayli yangi versiya "kelajakda" qolib ketmasin (Q10.1).
INSERT INTO hos_policy_versions (company_id, effective_from, policy, created_by)
VALUES (
  sqlc.arg(company_id),
  COALESCE(sqlc.narg(effective_from)::timestamptz, now()),
  sqlc.arg(policy),
  sqlc.narg(created_by)
) RETURNING *;

-- name: GetActiveHosPolicy :one
SELECT * FROM hos_policy_versions
WHERE company_id = $1 AND deleted_at IS NULL AND effective_from <= now()
ORDER BY effective_from DESC LIMIT 1;

-- name: ListHosPolicyVersions :many
SELECT * FROM hos_policy_versions
WHERE company_id = $1 AND deleted_at IS NULL
ORDER BY effective_from DESC LIMIT $2 OFFSET $3;

-- name: CountHosPolicyVersions :one
SELECT count(*) FROM hos_policy_versions WHERE company_id = $1 AND deleted_at IS NULL;

-- name: GetSystemSetting :one
SELECT * FROM system_settings WHERE key = $1;

-- name: ListSystemSettings :many
SELECT * FROM system_settings ORDER BY key;

-- name: UpsertSystemSetting :one
INSERT INTO system_settings (key, value, description) VALUES ($1,$2,$3)
ON CONFLICT (key) DO UPDATE
SET value = EXCLUDED.value,
    description = COALESCE(EXCLUDED.description, system_settings.description)
RETURNING *;
