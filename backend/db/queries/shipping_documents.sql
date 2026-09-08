-- name: CreateShippingDocument :one
INSERT INTO shipping_documents (company_id, number, notes) VALUES ($1,$2,$3) RETURNING *;

-- name: GetShippingDocument :one
SELECT * FROM shipping_documents WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: ListShippingDocuments :many
SELECT * FROM shipping_documents
WHERE company_id = $1 AND deleted_at IS NULL
  AND ($2::text IS NULL OR number ILIKE '%' || $2::text || '%')
ORDER BY number LIMIT $3 OFFSET $4;

-- name: CountShippingDocuments :one
SELECT count(*) FROM shipping_documents
WHERE company_id = $1 AND deleted_at IS NULL
  AND ($2::text IS NULL OR number ILIKE '%' || $2::text || '%');

-- name: ListShippingDocumentsByIDs :many
SELECT * FROM shipping_documents WHERE company_id = $1 AND id = ANY($2::uuid[]) AND deleted_at IS NULL;

-- name: UpdateShippingDocument :one
UPDATE shipping_documents SET number = COALESCE($3::text, number), notes = COALESCE($4::text, notes)
WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL RETURNING *;

-- name: SoftDeleteShippingDocument :exec
UPDATE shipping_documents SET deleted_at = now() WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;
