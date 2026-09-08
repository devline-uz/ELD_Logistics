-- name: CreateNotification :one
INSERT INTO notifications (company_id, user_id, alert_type, title, body, entity_type, entity_id, channels, sent_at)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
RETURNING *;

-- name: GetNotification :one
SELECT * FROM notifications WHERE company_id = $1 AND id = $2;

-- name: ListNotifications :many
SELECT * FROM notifications
WHERE company_id = sqlc.arg('company_id')
  AND user_id = sqlc.arg('user_id')
  AND (sqlc.narg('unread')::bool IS NULL
       OR (sqlc.narg('unread')::bool IS TRUE  AND read_at IS NULL)
       OR (sqlc.narg('unread')::bool IS FALSE AND read_at IS NOT NULL))
  AND (sqlc.narg('alert_type')::text IS NULL OR alert_type = sqlc.narg('alert_type')::text)
ORDER BY created_at DESC, id DESC
LIMIT sqlc.arg('row_limit') OFFSET sqlc.arg('row_offset');

-- name: CountNotifications :one
SELECT count(*) FROM notifications
WHERE company_id = sqlc.arg('company_id')
  AND user_id = sqlc.arg('user_id')
  AND (sqlc.narg('unread')::bool IS NULL
       OR (sqlc.narg('unread')::bool IS TRUE  AND read_at IS NULL)
       OR (sqlc.narg('unread')::bool IS FALSE AND read_at IS NOT NULL))
  AND (sqlc.narg('alert_type')::text IS NULL OR alert_type = sqlc.narg('alert_type')::text);

-- name: CountUnreadNotifications :one
SELECT count(*) FROM notifications WHERE company_id = $1 AND user_id = $2 AND read_at IS NULL;

-- name: MarkNotificationRead :execrows
UPDATE notifications SET read_at = now()
WHERE company_id = $1 AND user_id = $2 AND id = $3 AND read_at IS NULL;

-- name: MarkAllNotificationsRead :execrows
UPDATE notifications SET read_at = now() WHERE company_id = $1 AND user_id = $2 AND read_at IS NULL;

-- name: MarkNotificationDelivered :exec
UPDATE notifications SET delivered_at = now() WHERE company_id = $1 AND id = $2 AND delivered_at IS NULL;

-- name: UpsertNotificationSetting :one
INSERT INTO notification_settings (company_id, alert_type, channels, recipient_roles, enabled)
VALUES ($1,$2,$3,$4,$5)
ON CONFLICT (company_id, alert_type) DO UPDATE SET
  channels        = EXCLUDED.channels,
  recipient_roles = EXCLUDED.recipient_roles,
  enabled         = EXCLUDED.enabled
RETURNING *;

-- name: ListNotificationSettings :many
SELECT * FROM notification_settings WHERE company_id = $1 ORDER BY alert_type;

-- name: GetNotificationSetting :one
SELECT * FROM notification_settings WHERE company_id = $1 AND alert_type = $2;

-- Qabul qiluvchilar: faqat faol foydalanuvchilar. Telefon/email — PII, javobga
-- chiqmaydi, faqat `internal/notify` provayderlariga uzatiladi.
-- name: NotifyRecipientsByUsers :many
SELECT u.id, u.email, u.phone, u.telegram_chat_id
FROM users u
WHERE u.company_id = $1 AND u.deleted_at IS NULL AND u.status = 'active'
  AND u.id = ANY($2::uuid[]);

-- name: NotifyRecipientsByRoles :many
SELECT u.id, u.email, u.phone, u.telegram_chat_id
FROM users u
WHERE u.company_id = $1 AND u.deleted_at IS NULL AND u.status = 'active'
  AND u.role_id = ANY($2::uuid[]);

-- name: UpsertDevicePushToken :one
INSERT INTO device_push_tokens (company_id, user_id, device_id, platform, token, app_version, last_seen_at)
VALUES ($1,$2,$3,$4,$5,$6, now())
ON CONFLICT (user_id, device_id) WHERE deleted_at IS NULL DO UPDATE SET
  platform     = EXCLUDED.platform,
  token        = EXCLUDED.token,
  app_version  = EXCLUDED.app_version,
  last_seen_at = now()
RETURNING *;

-- Bir xil token boshqa foydalanuvchida qolib ketmasin (qurilma egasi o'zgardi).
-- name: RevokeDevicePushTokenElsewhere :exec
UPDATE device_push_tokens SET deleted_at = now()
WHERE token = $1 AND deleted_at IS NULL AND NOT (user_id = $2 AND device_id = $3);

-- name: ListPushTokensForUsers :many
SELECT user_id, device_id, platform, token FROM device_push_tokens
WHERE company_id = $1 AND user_id = ANY($2::uuid[]) AND deleted_at IS NULL
ORDER BY user_id, last_seen_at DESC;

-- name: DeleteDevicePushToken :execrows
UPDATE device_push_tokens SET deleted_at = now()
WHERE company_id = $1 AND user_id = $2 AND device_id = $3 AND deleted_at IS NULL;

-- Retention: 90 kundan eski o'qilgan bildirishnomalar tozalanadi.
-- name: DeleteOldNotifications :execrows
DELETE FROM notifications
WHERE company_id = $1 AND created_at < $2 AND read_at IS NOT NULL;
