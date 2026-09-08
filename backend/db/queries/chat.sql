-- name: CreateChatMessage :one
INSERT INTO chat_messages (company_id, driver_id, sender_id, kind, text, file_key, lat, lng, sent_at)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8, COALESCE(sqlc.narg('sent_at')::timestamptz, now()))
RETURNING *;

-- name: GetChatMessage :one
SELECT * FROM chat_messages WHERE company_id = $1 AND id = $2;

-- Kursor pagination: `before` — oxirgi ko'rilgan xabarning sent_at qiymati.
-- name: ListChatMessages :many
SELECT * FROM chat_messages
WHERE company_id = sqlc.arg('company_id')
  AND driver_id = sqlc.arg('driver_id')
  AND (sqlc.narg('before')::timestamptz IS NULL OR sent_at < sqlc.narg('before')::timestamptz)
ORDER BY sent_at DESC, id DESC
LIMIT sqlc.arg('row_limit');

-- name: CountChatMessages :one
SELECT count(*) FROM chat_messages WHERE company_id = $1 AND driver_id = $2;

-- Admin tomoni: har bir faol haydovchi bitta thread, xabari bo'lmasa ham
-- ro'yxatda turadi. Oxirgi xabar alohida query bilan olinadi, chunki LEFT JOIN
-- ustunlarining nullability'sini sqlc to'g'ri chiqara olmaydi.
-- name: ListChatThreads :many
SELECT
  d.id AS driver_id,
  d.status AS driver_status,
  d.branch_id,
  u.id AS driver_user_id,
  u.first_name,
  u.last_name,
  (SELECT count(*) FROM chat_messages m
     WHERE m.company_id = d.company_id AND m.driver_id = d.id
       AND m.sender_id = u.id AND m.read_at IS NULL)::bigint AS unread_count
FROM drivers d
JOIN users u ON u.id = d.user_id
WHERE d.company_id = sqlc.arg('company_id')
  AND d.deleted_at IS NULL
  AND (sqlc.narg('branch_id')::uuid IS NULL OR d.branch_id = sqlc.narg('branch_id')::uuid)
  AND (sqlc.narg('driver_id')::uuid IS NULL OR d.id = sqlc.narg('driver_id')::uuid)
  AND (sqlc.arg('include_empty')::bool
       OR EXISTS (SELECT 1 FROM chat_messages m
                  WHERE m.company_id = d.company_id AND m.driver_id = d.id))
ORDER BY COALESCE((SELECT max(m.sent_at) FROM chat_messages m
                   WHERE m.company_id = d.company_id AND m.driver_id = d.id),
                  'epoch'::timestamptz) DESC, u.last_name, u.first_name
LIMIT sqlc.arg('row_limit') OFFSET sqlc.arg('row_offset');

-- name: CountChatThreads :one
SELECT count(*) FROM drivers d
WHERE d.company_id = sqlc.arg('company_id')
  AND d.deleted_at IS NULL
  AND (sqlc.narg('branch_id')::uuid IS NULL OR d.branch_id = sqlc.narg('branch_id')::uuid)
  AND (sqlc.narg('driver_id')::uuid IS NULL OR d.id = sqlc.narg('driver_id')::uuid)
  AND (sqlc.arg('include_empty')::bool
       OR EXISTS (SELECT 1 FROM chat_messages m
                  WHERE m.company_id = d.company_id AND m.driver_id = d.id));

-- Bir sahifadagi thread'larning oxirgi xabari.
-- name: ListChatLastMessages :many
SELECT DISTINCT ON (m.driver_id)
  m.driver_id, m.id, m.kind, m.text, m.file_key, m.sender_id,
  m.sent_at, m.delivered_at, m.read_at
FROM chat_messages m
WHERE m.company_id = $1 AND m.driver_id = ANY($2::uuid[])
ORDER BY m.driver_id, m.sent_at DESC, m.id DESC;

-- name: MarkChatMessageRead :execrows
UPDATE chat_messages SET read_at = now(), delivered_at = COALESCE(delivered_at, now())
WHERE company_id = $1 AND id = $2 AND sender_id <> $3 AND read_at IS NULL;

-- name: MarkThreadRead :execrows
UPDATE chat_messages SET read_at = now(), delivered_at = COALESCE(delivered_at, now())
WHERE company_id = $1 AND driver_id = $2 AND sender_id <> $3 AND read_at IS NULL;

-- name: MarkChatMessageDelivered :exec
UPDATE chat_messages SET delivered_at = now() WHERE company_id = $1 AND id = $2 AND delivered_at IS NULL;

-- name: CountUnreadChatForDriver :one
SELECT count(*) FROM chat_messages
WHERE company_id = $1 AND driver_id = $2 AND sender_id <> $3 AND read_at IS NULL;

-- Retention — TZ §15.4: chat 1 yil saqlanadi.
-- name: DeleteOldChatMessages :execrows
DELETE FROM chat_messages WHERE company_id = $1 AND sent_at < $2;

-- Chatni bloklash uchun haydovchining joriy duty statusi (Q10 — `DR` bo'lsa
-- yozish taqiqlanadi).
-- name: ChatDriverCurrentDutyStatus :one
SELECT e.status FROM duty_status_events e
WHERE e.company_id = $1 AND e.driver_id = $2
  AND e.event_type = 'duty_status' AND e.superseded_by IS NULL
ORDER BY e.event_time DESC LIMIT 1;

-- name: ChatGetDriver :one
SELECT d.id, d.company_id, d.user_id, d.branch_id, d.status,
       u.first_name, u.last_name
FROM drivers d
JOIN users u ON u.id = d.user_id
WHERE d.company_id = $1 AND d.id = $2 AND d.deleted_at IS NULL;

-- name: ChatGetDriverByUser :one
SELECT d.id, d.company_id, d.user_id, d.branch_id, d.status,
       u.first_name, u.last_name
FROM drivers d
JOIN users u ON u.id = d.user_id
WHERE d.company_id = $1 AND d.user_id = $2 AND d.deleted_at IS NULL;
