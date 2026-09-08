-- name: CreateSession :one
INSERT INTO sessions (
  company_id, user_id, device_id, device_type, refresh_token_hash,
  expires_at, app_version, ip, user_agent, last_seen_at
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9, now())
RETURNING *;

-- name: GetSessionByRefreshHash :one
SELECT * FROM sessions WHERE refresh_token_hash = $1;

-- name: GetSessionByAnyRefreshHash :one
-- `is_current` false bo'lsa — token allaqachon almashtirilgan, ya'ni reuse.
SELECT sessions.*, (sessions.refresh_token_hash = sqlc.arg(token_hash)::text) AS is_current
FROM sessions
WHERE sessions.refresh_token_hash = sqlc.arg(token_hash)::text
   OR sessions.prev_refresh_token_hash = sqlc.arg(token_hash)::text;

-- name: GetSession :one
SELECT * FROM sessions WHERE id = $1;

-- name: ListSessionsByUser :many
SELECT * FROM sessions WHERE user_id = $1 AND status <> 'revoked' ORDER BY last_seen_at DESC NULLS LAST;

-- name: ListActiveSessions :many
SELECT * FROM sessions
WHERE company_id = $1 AND status = 'active' AND expires_at > now()
ORDER BY last_seen_at DESC NULLS LAST
LIMIT $2 OFFSET $3;

-- name: CountActiveSessions :one
SELECT count(*) FROM sessions WHERE company_id = $1 AND status = 'active' AND expires_at > now();

-- name: RotateSessionToken :one
-- Rotation: yangi hash o'rnatiladi, eskisi `prev_refresh_token_hash` da
-- qoladi -> qayta ishlatish aniqlanadi (TZ B§3.1).
UPDATE sessions
SET refresh_token_hash      = $2,
    prev_refresh_token_hash = refresh_token_hash,
    expires_at              = $3,
    last_seen_at            = now(),
    app_version             = COALESCE(sqlc.narg(app_version)::text, app_version)
WHERE id = $1 AND status = 'active'
RETURNING *;

-- name: RevokeSession :exec
UPDATE sessions SET status = 'revoked', revoked_reason = $2 WHERE id = $1;

-- name: PauseSession :exec
UPDATE sessions SET status = 'paused' WHERE id = $1 AND status = 'active';

-- name: ResumeSession :exec
UPDATE sessions SET status = 'active', last_seen_at = now() WHERE id = $1 AND status = 'paused';

-- name: RevokeUserDeviceSessions :exec
UPDATE sessions SET status = 'revoked', revoked_reason = $3
WHERE user_id = $1 AND device_type = $2 AND status = 'active';

-- name: RevokeUserDeviceSessionsReturning :many
-- Yangi login o'sha device_type dagi eski sessiyani (active yoki paused)
-- bekor qiladi -> javobda `replaced_session: true` (TZ A§20).
UPDATE sessions SET status = 'revoked', revoked_reason = $3
WHERE user_id = $1 AND device_type = $2 AND status <> 'revoked'
RETURNING id;

-- name: RevokeAllUserSessionsReturning :many
UPDATE sessions SET status = 'revoked', revoked_reason = $2
WHERE user_id = $1 AND status <> 'revoked'
RETURNING id;

-- name: RevokeAllUserSessions :exec
UPDATE sessions SET status = 'revoked', revoked_reason = $2 WHERE user_id = $1 AND status <> 'revoked';

-- name: TouchSession :exec
UPDATE sessions SET last_seen_at = now() WHERE id = $1;

-- name: DeleteExpiredSessions :exec
DELETE FROM sessions WHERE expires_at < now() - INTERVAL '30 days';

-- name: CreateInvitation :one
INSERT INTO invitations (company_id, user_id, token_hash, channel, purpose, expires_at)
VALUES ($1,$2,$3,$4,$5,$6) RETURNING *;

-- name: GetInvitationByTokenHash :one
SELECT * FROM invitations WHERE token_hash = $1 AND used_at IS NULL AND expires_at > now();

-- name: GetInvitationAnyByTokenHash :one
SELECT * FROM invitations WHERE token_hash = $1;

-- name: MarkInvitationUsed :exec
UPDATE invitations SET used_at = now() WHERE id = $1 AND used_at IS NULL;

-- name: InvalidateUserInvitations :exec
UPDATE invitations SET used_at = now() WHERE user_id = $1 AND purpose = $2 AND used_at IS NULL;

-- name: RevokeSessionsByRoleReturning :many
-- Rol yoki uning permissionlari o'zgarsa, o'sha roldagi barcha foydalanuvchilar
-- sessiyalari bekor qilinadi (TZ B§3.1 — permission o'zgarishi).
UPDATE sessions s SET status = 'revoked', revoked_reason = sqlc.narg(reason)::text
FROM users u
WHERE s.user_id = u.id
  AND u.company_id = sqlc.arg(company_id)::uuid
  AND u.role_id = sqlc.arg(role_id)::uuid
  AND s.status <> 'revoked'
RETURNING s.id;
