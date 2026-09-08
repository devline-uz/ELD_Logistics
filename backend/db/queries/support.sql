-- Support tickets, ticket thread messages and driver feedback (TZ A§15).
-- Driver `self` scope is expressed with the optional `self_user_id` argument:
-- when it is set only the rows the caller owns (created them, or is the driver
-- they were filed for) are visible.

-- name: CreateSupportTicket :one
INSERT INTO support_tickets (company_id, driver_id, created_by, subject, description, contact_on, status, attachments)
VALUES (
  sqlc.arg(company_id),
  sqlc.narg(driver_id),
  sqlc.narg(created_by),
  sqlc.arg(subject),
  sqlc.narg(description),
  sqlc.narg(contact_on),
  sqlc.arg(status),
  sqlc.arg(attachments)::text[]
)
RETURNING *;

-- name: SupportGetTicket :one
SELECT
  t.*,
  cu.first_name AS creator_first_name,
  cu.last_name  AS creator_last_name,
  du.first_name AS driver_first_name,
  du.last_name  AS driver_last_name,
  d.user_id     AS driver_user_id,
  (SELECT count(*) FROM ticket_messages m WHERE m.ticket_id = t.id)::bigint AS message_count
FROM support_tickets t
LEFT JOIN users   cu ON cu.id = t.created_by
LEFT JOIN drivers d  ON d.id  = t.driver_id
LEFT JOIN users   du ON du.id = d.user_id
WHERE t.company_id = sqlc.arg(company_id)
  AND t.id = sqlc.arg(id)
  AND t.deleted_at IS NULL;

-- name: SupportListTickets :many
SELECT
  t.*,
  cu.first_name AS creator_first_name,
  cu.last_name  AS creator_last_name,
  du.first_name AS driver_first_name,
  du.last_name  AS driver_last_name,
  d.user_id     AS driver_user_id,
  (SELECT count(*) FROM ticket_messages m WHERE m.ticket_id = t.id)::bigint AS message_count
FROM support_tickets t
LEFT JOIN users   cu ON cu.id = t.created_by
LEFT JOIN drivers d  ON d.id  = t.driver_id
LEFT JOIN users   du ON du.id = d.user_id
WHERE t.company_id = sqlc.arg(company_id)
  AND t.deleted_at IS NULL
  AND (sqlc.narg(status)::text IS NULL OR t.status = sqlc.narg(status)::text)
  AND (sqlc.narg(driver_id)::uuid IS NULL OR t.driver_id = sqlc.narg(driver_id)::uuid)
  AND (sqlc.narg(search)::text IS NULL OR t.subject ILIKE '%' || sqlc.narg(search)::text || '%')
  AND (sqlc.narg(from_ts)::timestamptz IS NULL OR t.created_at >= sqlc.narg(from_ts)::timestamptz)
  AND (sqlc.narg(to_ts)::timestamptz IS NULL OR t.created_at < sqlc.narg(to_ts)::timestamptz)
  AND (sqlc.narg(self_user_id)::uuid IS NULL
       OR t.created_by = sqlc.narg(self_user_id)::uuid
       OR d.user_id    = sqlc.narg(self_user_id)::uuid)
ORDER BY
  CASE WHEN sqlc.arg(sort_by)::text = 'status'     AND sqlc.arg(sort_dir)::text = 'asc'  THEN t.status     END ASC,
  CASE WHEN sqlc.arg(sort_by)::text = 'status'     AND sqlc.arg(sort_dir)::text = 'desc' THEN t.status     END DESC,
  CASE WHEN sqlc.arg(sort_by)::text = 'subject'    AND sqlc.arg(sort_dir)::text = 'asc'  THEN t.subject    END ASC,
  CASE WHEN sqlc.arg(sort_by)::text = 'subject'    AND sqlc.arg(sort_dir)::text = 'desc' THEN t.subject    END DESC,
  CASE WHEN sqlc.arg(sort_by)::text = 'created_at' AND sqlc.arg(sort_dir)::text = 'asc'  THEN t.created_at END ASC,
  t.created_at DESC
LIMIT sqlc.arg(row_limit) OFFSET sqlc.arg(row_offset);

-- name: SupportCountTickets :one
SELECT count(*)
FROM support_tickets t
LEFT JOIN drivers d ON d.id = t.driver_id
WHERE t.company_id = sqlc.arg(company_id)
  AND t.deleted_at IS NULL
  AND (sqlc.narg(status)::text IS NULL OR t.status = sqlc.narg(status)::text)
  AND (sqlc.narg(driver_id)::uuid IS NULL OR t.driver_id = sqlc.narg(driver_id)::uuid)
  AND (sqlc.narg(search)::text IS NULL OR t.subject ILIKE '%' || sqlc.narg(search)::text || '%')
  AND (sqlc.narg(from_ts)::timestamptz IS NULL OR t.created_at >= sqlc.narg(from_ts)::timestamptz)
  AND (sqlc.narg(to_ts)::timestamptz IS NULL OR t.created_at < sqlc.narg(to_ts)::timestamptz)
  AND (sqlc.narg(self_user_id)::uuid IS NULL
       OR t.created_by = sqlc.narg(self_user_id)::uuid
       OR d.user_id    = sqlc.narg(self_user_id)::uuid);

-- name: SetSupportTicketStatus :one
UPDATE support_tickets SET status = sqlc.arg(status),
  resolved_at = CASE WHEN sqlc.arg(status)::text IN ('resolved','closed') THEN now() ELSE NULL END
WHERE company_id = sqlc.arg(company_id) AND id = sqlc.arg(id) AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteSupportTicket :exec
UPDATE support_tickets SET deleted_at = now() WHERE company_id = $1 AND id = $2 AND deleted_at IS NULL;

-- name: CreateTicketMessage :one
INSERT INTO ticket_messages (company_id, ticket_id, sender_id, text, attachments)
VALUES ($1,$2,$3,$4,$5::text[]) RETURNING *;

-- name: SupportListTicketMessages :many
SELECT m.*, u.first_name, u.last_name
FROM ticket_messages m
JOIN users u ON u.id = m.sender_id
WHERE m.company_id = $1 AND m.ticket_id = $2
ORDER BY m.created_at
LIMIT $3 OFFSET $4;

-- name: SupportCountTicketMessages :one
SELECT count(*) FROM ticket_messages WHERE company_id = $1 AND ticket_id = $2;

-- name: SupportGetTicketMessage :one
SELECT m.*, u.first_name, u.last_name
FROM ticket_messages m
JOIN users u ON u.id = m.sender_id
WHERE m.company_id = $1 AND m.id = $2;

-- name: CreateFeedback :one
INSERT INTO feedback (company_id, driver_id, app_rating, text)
VALUES (sqlc.arg(company_id), sqlc.narg(driver_id), sqlc.narg(app_rating), sqlc.narg(text))
RETURNING *;

-- name: SupportListFeedback :many
SELECT f.*, u.first_name, u.last_name
FROM feedback f
LEFT JOIN drivers d ON d.id = f.driver_id
LEFT JOIN users   u ON u.id = d.user_id
WHERE f.company_id = sqlc.arg(company_id)
  AND (sqlc.narg(driver_id)::uuid IS NULL OR f.driver_id = sqlc.narg(driver_id)::uuid)
  AND (sqlc.narg(min_rating)::smallint IS NULL OR f.app_rating >= sqlc.narg(min_rating)::smallint)
  AND (sqlc.narg(from_ts)::timestamptz IS NULL OR f.submitted_at >= sqlc.narg(from_ts)::timestamptz)
  AND (sqlc.narg(to_ts)::timestamptz IS NULL OR f.submitted_at < sqlc.narg(to_ts)::timestamptz)
ORDER BY
  CASE WHEN sqlc.arg(sort_by)::text = 'app_rating'   AND sqlc.arg(sort_dir)::text = 'asc'  THEN f.app_rating   END ASC,
  CASE WHEN sqlc.arg(sort_by)::text = 'app_rating'   AND sqlc.arg(sort_dir)::text = 'desc' THEN f.app_rating   END DESC,
  CASE WHEN sqlc.arg(sort_by)::text = 'submitted_at' AND sqlc.arg(sort_dir)::text = 'asc'  THEN f.submitted_at END ASC,
  f.submitted_at DESC
LIMIT sqlc.arg(row_limit) OFFSET sqlc.arg(row_offset);

-- name: SupportCountFeedback :one
SELECT count(*) FROM feedback f
WHERE f.company_id = sqlc.arg(company_id)
  AND (sqlc.narg(driver_id)::uuid IS NULL OR f.driver_id = sqlc.narg(driver_id)::uuid)
  AND (sqlc.narg(min_rating)::smallint IS NULL OR f.app_rating >= sqlc.narg(min_rating)::smallint)
  AND (sqlc.narg(from_ts)::timestamptz IS NULL OR f.submitted_at >= sqlc.narg(from_ts)::timestamptz)
  AND (sqlc.narg(to_ts)::timestamptz IS NULL OR f.submitted_at < sqlc.narg(to_ts)::timestamptz);

-- name: SupportGetDriverByUserID :one
SELECT id FROM drivers WHERE company_id = $1 AND user_id = $2 AND deleted_at IS NULL;
