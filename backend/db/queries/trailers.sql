-- name: CreateTrailer :one
INSERT INTO trailers (company_id, number, notes) VALUES ($1,$2,$3) RETURNING *;

-- name: GetTrailer :one
SELECT * FROM trailers WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: ListTrailers :many
SELECT * FROM trailers
WHERE company_id = $1 AND deleted_at IS NULL
  AND ($2::text IS NULL OR number ILIKE '%' || $2::text || '%')
ORDER BY number LIMIT $3 OFFSET $4;

-- name: CountTrailers :one
SELECT count(*) FROM trailers
WHERE company_id = $1 AND deleted_at IS NULL
  AND ($2::text IS NULL OR number ILIKE '%' || $2::text || '%');

-- name: ListTrailersByIDs :many
SELECT * FROM trailers WHERE company_id = $1 AND id = ANY($2::uuid[]) AND deleted_at IS NULL;

-- name: UpdateTrailer :one
UPDATE trailers SET number = COALESCE($3::text, number), notes = COALESCE($4::text, notes)
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL RETURNING *;

-- name: SoftDeleteTrailer :exec
UPDATE trailers SET deleted_at = now() WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;
