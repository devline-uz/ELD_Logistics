-- Stage 4 (internal/domain/logs): daily log window, certification, the
-- propose/approve edit model, unidentified driving assignment, the canonical
-- violation catalogue and the roadside inspection window.
-- Vaqtlar UTC; kunga ajratish Home Terminal TZ bo'yicha Go tomonida.

-- ------------------------------------------------------------- daily logs

-- name: LogsListDriverDailyLogs :many
-- Q19: certification oynasi — [from, to] kunlari, eng yangisi birinchi.
SELECT l.*, u.first_name, u.last_name,
       cu.first_name AS co_driver_first_name,
       cu.last_name  AS co_driver_last_name
FROM daily_logs l
JOIN drivers d ON d.id = l.driver_id
JOIN users   u ON u.id = d.user_id
LEFT JOIN drivers cd ON cd.id = l.co_driver_id
LEFT JOIN users   cu ON cu.id = cd.user_id
WHERE l.company_id = @company_id AND l.driver_id = @driver_id
  AND l.log_date >= @from_date AND l.log_date <= @to_date
ORDER BY l.log_date DESC
LIMIT @lim OFFSET @off;

-- name: LogsCountDriverDailyLogs :one
SELECT count(*) FROM daily_logs
WHERE company_id = @company_id AND driver_id = @driver_id
  AND log_date >= @from_date AND log_date <= @to_date;

-- name: LogsGetDailyLog :one
SELECT l.*, u.first_name, u.last_name, d.branch_id, d.user_id,
       cu.first_name AS co_driver_first_name,
       cu.last_name  AS co_driver_last_name,
       c.name        AS company_name,
       c.home_terminal_address,
       c.regulation_profile
FROM daily_logs l
JOIN drivers   d ON d.id = l.driver_id
JOIN users     u ON u.id = d.user_id
JOIN companies c ON c.id = l.company_id
LEFT JOIN drivers cd ON cd.id = l.co_driver_id
LEFT JOIN users   cu ON cu.id = cd.user_id
WHERE l.company_id = @company_id AND l.id = @id;

-- name: LogsCertifyDailyLog :one
-- Q26.1: sertifikatsiya = imzo kaliti + signed_at/ip/device + `certification` event.
UPDATE daily_logs SET
  certification_status = 'certified',
  signed_at        = @signed_at,
  signature_key    = @signature_key,
  signed_device_id = sqlc.narg(signed_device_id)::text,
  signed_ip        = sqlc.narg(signed_ip)::text,
  signed_by        = @signed_by
WHERE company_id = @company_id AND id = @id
RETURNING *;

-- name: LogsMarkNeedsRecertify :exec
-- Q18: sertifikatlangan kun tahrirlansa qayta imzo talab qilinadi.
UPDATE daily_logs SET certification_status = 'needs_recertify'
WHERE company_id = @company_id AND id = @id AND certification_status = 'certified';

-- name: LogsSetDailyLogForm :one
-- Q16: Log Form maydonlari (distance telemetriyadan keladi, qo'lda emas).
UPDATE daily_logs SET
  trailer_ids      = @trailer_ids,
  shipping_doc_ids = @shipping_doc_ids,
  co_driver_id     = sqlc.narg(co_driver_id)::uuid
WHERE company_id = @company_id AND id = @id
RETURNING *;

-- name: LogsListUncertifiedOlderThan :many
-- Q19.1: 8 kundan eskirgan sertifikatlanmagan kunlar — admin alerti.
SELECT l.*, u.first_name, u.last_name
FROM daily_logs l
JOIN drivers d ON d.id = l.driver_id
JOIN users   u ON u.id = d.user_id
WHERE l.company_id = @company_id
  AND l.certification_status <> 'certified'
  AND l.log_date < @before_date
  AND (sqlc.narg(driver_id)::uuid IS NULL OR l.driver_id = sqlc.narg(driver_id)::uuid)
  AND (sqlc.narg(branch_id)::uuid IS NULL OR d.branch_id = sqlc.narg(branch_id)::uuid)
ORDER BY l.log_date DESC, u.last_name
LIMIT @lim OFFSET @off;

-- name: LogsCountUncertifiedOlderThan :one
SELECT count(*)
FROM daily_logs l
JOIN drivers d ON d.id = l.driver_id
WHERE l.company_id = @company_id
  AND l.certification_status <> 'certified'
  AND l.log_date < @before_date
  AND (sqlc.narg(driver_id)::uuid IS NULL OR l.driver_id = sqlc.narg(driver_id)::uuid)
  AND (sqlc.narg(branch_id)::uuid IS NULL OR d.branch_id = sqlc.narg(branch_id)::uuid);

-- name: LogsListUncertifiedInWindow :many
-- Q57 `uncertified_log`: oynadagi sertifikatlanmagan kunlar (1 kun warning,
-- >=2 kun violation) — nightly qayta hisob uchun.
SELECT id, driver_id, log_date, certification_status
FROM daily_logs
WHERE company_id = @company_id AND driver_id = @driver_id
  AND certification_status <> 'certified'
  AND log_date >= @from_date AND log_date <= @to_date
ORDER BY log_date;

-- ------------------------------------------------------------ log events

-- name: LogsListDayEvents :many
-- Kun eventlari; superseded qatorlar ham qaytadi, tarix ✎ belgisi uchun kerak (Q17.2).
SELECT e.*, un.unit_number
FROM duty_status_events e
LEFT JOIN units un ON un.id = e.unit_id
WHERE e.company_id = @company_id AND e.daily_log_id = @daily_log_id
ORDER BY e.event_time, e.device_seq NULLS LAST;

-- name: LogsListDriverEventsBetween :many
SELECT * FROM duty_status_events
WHERE company_id = @company_id AND driver_id = @driver_id
  AND event_time >= @from_at AND event_time < @to_at
  AND superseded_by IS NULL
ORDER BY event_time, device_seq NULLS LAST;

-- name: LogsGetEvent :one
SELECT * FROM duty_status_events WHERE company_id = @company_id AND id = @id;

-- name: LogsListEventsByIDs :many
SELECT * FROM duty_status_events
WHERE company_id = @company_id AND id = ANY(@ids::uuid[]);

-- name: LogsInsertEditEvent :one
-- Tahrir natijasi: yangi event `origin` bilan (`driver_edit` yoki `admin_edit`),
-- asl event `superseded_by` orqali saqlanadi (hech narsa o'chmaydi).
INSERT INTO duty_status_events (
  company_id, driver_id, unit_id, event_type, status, special,
  event_time, time_source, origin, notes, client_event_id, daily_log_id
) VALUES (
  @company_id, @driver_id, sqlc.narg(unit_id)::uuid, 'duty_status', @status, @special,
  @event_time, 'server', @origin, @notes, @client_event_id, @daily_log_id
)
RETURNING *;

-- name: LogsSupersedeEvents :exec
UPDATE duty_status_events SET superseded_by = @superseded_by
WHERE company_id = @company_id AND id = ANY(@ids::uuid[]) AND superseded_by IS NULL;

-- name: LogsLockDayEvents :exec
-- Q26.1: sertifikatlangan kun eventlari `locked` — faqat edit-request orqali.
UPDATE duty_status_events SET locked = @locked
WHERE company_id = @company_id AND daily_log_id = @daily_log_id;

-- name: LogsAssignEventsToDriver :exec
UPDATE duty_status_events SET driver_id = @driver_id, origin = 'assigned', daily_log_id = @daily_log_id
WHERE company_id = @company_id AND id = ANY(@ids::uuid[]) AND driver_id IS NULL;

-- name: LogsListUnassignedEventsInRange :many
SELECT * FROM duty_status_events
WHERE company_id = @company_id AND driver_id IS NULL AND unit_id = @unit_id
  AND event_time >= @from_at AND event_time <= @to_at
ORDER BY event_time;

-- ------------------------------------------------------ log edit requests

-- name: LogsCreateEditRequest :one
INSERT INTO log_edit_requests (
  company_id, driver_id, daily_log_id, requested_by, changes, source, unidentified_event_id
) VALUES (
  @company_id, @driver_id, @daily_log_id, @requested_by, @changes, @source,
  sqlc.narg(unidentified_event_id)::uuid
)
RETURNING *;

-- name: LogsGetEditRequest :one
SELECT r.*, u.first_name, u.last_name, d.user_id, d.branch_id, l.log_date, l.timezone
FROM log_edit_requests r
JOIN drivers    d ON d.id = r.driver_id
JOIN users      u ON u.id = d.user_id
JOIN daily_logs l ON l.id = r.daily_log_id
WHERE r.company_id = @company_id AND r.id = @id;

-- name: LogsListEditRequests :many
SELECT r.*, u.first_name, u.last_name, l.log_date, l.timezone
FROM log_edit_requests r
JOIN drivers    d ON d.id = r.driver_id
JOIN users      u ON u.id = d.user_id
JOIN daily_logs l ON l.id = r.daily_log_id
WHERE r.company_id = @company_id
  AND (sqlc.narg(status)::text IS NULL OR r.status = sqlc.narg(status)::text)
  AND (sqlc.narg(driver_id)::uuid IS NULL OR r.driver_id = sqlc.narg(driver_id)::uuid)
  AND (sqlc.narg(branch_id)::uuid IS NULL OR d.branch_id = sqlc.narg(branch_id)::uuid)
ORDER BY r.created_at DESC
LIMIT @lim OFFSET @off;

-- name: LogsCountEditRequests :one
SELECT count(*)
FROM log_edit_requests r
JOIN drivers d ON d.id = r.driver_id
WHERE r.company_id = @company_id
  AND (sqlc.narg(status)::text IS NULL OR r.status = sqlc.narg(status)::text)
  AND (sqlc.narg(driver_id)::uuid IS NULL OR r.driver_id = sqlc.narg(driver_id)::uuid)
  AND (sqlc.narg(branch_id)::uuid IS NULL OR d.branch_id = sqlc.narg(branch_id)::uuid);

-- name: LogsResolveEditRequest :one
UPDATE log_edit_requests
SET status = @status, resolved_by = @resolved_by, resolved_at = now(),
    driver_note = sqlc.narg(driver_note)::text
WHERE company_id = @company_id AND id = @id AND status = 'pending'
RETURNING *;

-- name: LogsListPendingEditRequestsForDriver :many
-- /sync/pull: haydovchining javobini kutayotgan takliflar.
SELECT r.id, r.daily_log_id, r.status, r.changes, r.source, r.created_at, r.updated_at,
       l.log_date, l.timezone
FROM log_edit_requests r
JOIN daily_logs l ON l.id = r.daily_log_id
WHERE r.company_id = @company_id AND r.driver_id = @driver_id
  AND r.status = 'pending' AND r.updated_at > @since
ORDER BY r.updated_at
LIMIT @lim;

-- --------------------------------------------------- unidentified driving

-- name: LogsGetUnidentifiedEvent :one
SELECT e.*, u.unit_number
FROM unidentified_events e
JOIN units u ON u.id = e.unit_id
WHERE e.company_id = @company_id AND e.id = @id;

-- name: LogsProposeUnidentifiedEvent :one
-- §10.4: admin tayinlashi taklif — haydovchi tasdig'igacha `proposed`.
UPDATE unidentified_events
SET status = 'proposed', assigned_driver_id = @assigned_driver_id,
    edit_request_id = @edit_request_id, resolved_by = @resolved_by
WHERE company_id = @company_id AND id = @id AND status = 'pending'
RETURNING *;

-- name: LogsClaimUnidentifiedEvent :one
-- §10.4: haydovchining o'zi qabul qilsa darhol `assigned`.
UPDATE unidentified_events
SET status = 'assigned', assigned_driver_id = @assigned_driver_id, resolved_at = now()
WHERE company_id = @company_id AND id = @id AND status IN ('pending','proposed')
RETURNING *;

-- name: LogsAnnotateUnidentifiedEvent :one
UPDATE unidentified_events
SET status = 'annotated', annotation = @annotation, resolved_by = @resolved_by, resolved_at = now()
WHERE company_id = @company_id AND id = @id AND status IN ('pending','proposed')
RETURNING *;

-- name: LogsResetUnidentifiedEvent :exec
-- Taklif rad etilsa blok yana `pending` bo'ladi.
UPDATE unidentified_events
SET status = 'pending', assigned_driver_id = NULL, edit_request_id = NULL, resolved_by = NULL
WHERE company_id = @company_id AND id = @id AND status = 'proposed';

-- name: LogsListStaleUnidentifiedEvents :many
-- Q57 `unidentified_driving`: 8 kundan ortiq tayinlanmagan bloklar.
SELECT * FROM unidentified_events
WHERE company_id = @company_id AND status = 'pending' AND start_at < @before
ORDER BY start_at;

-- ------------------------------------------------------------ violations

-- name: LogsUpsertDayViolation :one
-- Q58: violation o'chmaydi. Bir kun + bir tur uchun bitta ochiq qator; qayta
-- hisobda severity/vaqt yangilanadi, yopilganlari tarixda qoladi.
INSERT INTO violations (
  company_id, driver_id, unit_id, daily_log_id, type, severity, occurred_at, details, policy_version_id
) VALUES (
  @company_id, @driver_id, sqlc.narg(unit_id)::uuid, @daily_log_id, @type, @severity,
  @occurred_at, @details, sqlc.narg(policy_version_id)::uuid
)
ON CONFLICT (daily_log_id, type) WHERE daily_log_id IS NOT NULL AND resolved_at IS NULL
DO UPDATE SET severity = EXCLUDED.severity, occurred_at = EXCLUDED.occurred_at,
              details = EXCLUDED.details, policy_version_id = EXCLUDED.policy_version_id
RETURNING *;

-- name: LogsUpsertUnidentifiedViolation :one
INSERT INTO violations (
  company_id, driver_id, unit_id, unidentified_event_id, type, severity, occurred_at, details
) VALUES (
  @company_id, sqlc.narg(driver_id)::uuid, sqlc.narg(unit_id)::uuid, @unidentified_event_id,
  'unidentified_driving', 'violation', @occurred_at, @details
)
ON CONFLICT (unidentified_event_id) WHERE unidentified_event_id IS NOT NULL AND resolved_at IS NULL
DO UPDATE SET occurred_at = EXCLUDED.occurred_at, details = EXCLUDED.details
RETURNING *;

-- name: LogsListOpenViolationsForLog :many
SELECT * FROM violations
WHERE company_id = @company_id AND daily_log_id = @daily_log_id AND resolved_at IS NULL
ORDER BY occurred_at;

-- name: LogsResolveDayViolations :exec
-- Yopilish qoidalari (Q58): sabab bilan yopiladi, qator saqlanadi.
UPDATE violations
SET resolved_at = now(), resolved_reason = @resolved_reason,
    resolved_by = sqlc.narg(resolved_by)::uuid
WHERE company_id = @company_id AND daily_log_id = @daily_log_id
  AND resolved_at IS NULL AND type = ANY(@types::text[]);

-- name: LogsResolveUnidentifiedViolation :exec
UPDATE violations
SET resolved_at = now(), resolved_reason = @resolved_reason,
    resolved_by = sqlc.narg(resolved_by)::uuid
WHERE company_id = @company_id AND unidentified_event_id = @unidentified_event_id
  AND resolved_at IS NULL;

-- name: LogsListViolations :many
SELECT v.*, u.first_name, u.last_name, l.log_date
FROM violations v
LEFT JOIN drivers d ON d.id = v.driver_id
LEFT JOIN users   u ON u.id = d.user_id
LEFT JOIN daily_logs l ON l.id = v.daily_log_id
WHERE v.company_id = @company_id
  AND (sqlc.narg(driver_id)::uuid IS NULL OR v.driver_id = sqlc.narg(driver_id)::uuid)
  AND (sqlc.narg(branch_id)::uuid IS NULL OR d.branch_id = sqlc.narg(branch_id)::uuid)
  AND (sqlc.narg(type)::text IS NULL OR v.type = sqlc.narg(type)::text)
  AND (sqlc.narg(severity)::text IS NULL OR v.severity = sqlc.narg(severity)::text)
  AND (sqlc.narg(resolved)::bool IS NULL
       OR (sqlc.narg(resolved)::bool AND v.resolved_at IS NOT NULL)
       OR (NOT sqlc.narg(resolved)::bool AND v.resolved_at IS NULL))
  AND (sqlc.narg(from_at)::timestamptz IS NULL OR v.occurred_at >= sqlc.narg(from_at)::timestamptz)
  AND (sqlc.narg(to_at)::timestamptz IS NULL OR v.occurred_at < sqlc.narg(to_at)::timestamptz)
ORDER BY v.occurred_at DESC
LIMIT @lim OFFSET @off;

-- name: LogsCountViolations :one
SELECT count(*)
FROM violations v
LEFT JOIN drivers d ON d.id = v.driver_id
WHERE v.company_id = @company_id
  AND (sqlc.narg(driver_id)::uuid IS NULL OR v.driver_id = sqlc.narg(driver_id)::uuid)
  AND (sqlc.narg(branch_id)::uuid IS NULL OR d.branch_id = sqlc.narg(branch_id)::uuid)
  AND (sqlc.narg(type)::text IS NULL OR v.type = sqlc.narg(type)::text)
  AND (sqlc.narg(severity)::text IS NULL OR v.severity = sqlc.narg(severity)::text)
  AND (sqlc.narg(resolved)::bool IS NULL
       OR (sqlc.narg(resolved)::bool AND v.resolved_at IS NOT NULL)
       OR (NOT sqlc.narg(resolved)::bool AND v.resolved_at IS NULL))
  AND (sqlc.narg(from_at)::timestamptz IS NULL OR v.occurred_at >= sqlc.narg(from_at)::timestamptz)
  AND (sqlc.narg(to_at)::timestamptz IS NULL OR v.occurred_at < sqlc.narg(to_at)::timestamptz);

-- name: LogsGetViolation :one
SELECT v.*, u.first_name, u.last_name, d.branch_id, l.log_date
FROM violations v
LEFT JOIN drivers d ON d.id = v.driver_id
LEFT JOIN users   u ON u.id = d.user_id
LEFT JOIN daily_logs l ON l.id = v.daily_log_id
WHERE v.company_id = @company_id AND v.id = @id;

-- ------------------------------------------------------------ inspection

-- name: LogsGetDriverForUser :one
SELECT d.id, d.company_id, d.user_id, d.branch_id, d.status, d.default_unit_id,
       d.home_terminal, u.first_name, u.last_name, u.email,
       c.timezone, c.name AS company_name, c.home_terminal_address, c.regulation_profile
FROM drivers d
JOIN users     u ON u.id = d.user_id
JOIN companies c ON c.id = d.company_id
WHERE d.company_id = @company_id AND d.id = @id AND d.deleted_at IS NULL;

-- name: LogsListUnitNumbersByIDs :many
SELECT id, unit_number, vin, license_plate FROM units
WHERE company_id = @company_id AND id = ANY(@ids::uuid[]);

-- name: LogsListTrailerNumbersByIDs :many
SELECT id, number FROM trailers
WHERE company_id = @company_id AND id = ANY(@ids::uuid[]) AND deleted_at IS NULL;

-- name: LogsListShippingDocNumbersByIDs :many
SELECT id, number FROM shipping_documents
WHERE company_id = @company_id AND id = ANY(@ids::uuid[]) AND deleted_at IS NULL;

-- name: LogsGetDefaultSignature :one
SELECT id, image_key_enc FROM signatures
WHERE company_id = @company_id AND user_id = @user_id AND is_default AND deleted_at IS NULL
LIMIT 1;

-- name: LogsGetSignature :one
SELECT id, image_key_enc FROM signatures
WHERE company_id = @company_id AND id = @id AND user_id = @user_id AND deleted_at IS NULL;
