-- Offline sync (internal/domain/sync) va duty status / HOS (internal/domain/duty)
-- query'lari. Har query'da `company_id` aniq predikat sifatida qoladi (RLS —
-- ikkinchi qatlam). Vaqtlar UTC, kunga ajratish Home Terminal TZ bo'yicha
-- Go tomonida (hos.StartOfDay) qilinadi.

-- ------------------------------------------------------------------ konteks

-- name: SyncGetDriverContext :one
-- Push/pull uchun haydovchi konteksti: kompaniya TZ'i (Q10.2 kun chegarasi),
-- quick_notes uchun settings va default unit.
SELECT d.id, d.company_id, d.user_id, d.branch_id, d.status, d.default_unit_id,
       d.home_terminal, c.timezone, c.settings
FROM drivers d
JOIN companies c ON c.id = d.company_id
WHERE d.company_id = @company_id AND d.id = @id AND d.deleted_at IS NULL;

-- name: SyncGetDriverByUserID :one
SELECT d.id, d.company_id, d.user_id, d.branch_id, d.status, d.default_unit_id,
       d.home_terminal, c.timezone, c.settings
FROM drivers d
JOIN companies c ON c.id = d.company_id
WHERE d.company_id = @company_id AND d.user_id = @user_id AND d.deleted_at IS NULL;

-- name: SyncGetUnitFlags :one
SELECT id, unit_number, sleeper_berth, status, out_of_service
FROM units
WHERE company_id = @company_id AND id = @id AND deleted_at IS NULL;

-- name: SyncGetHosPolicyAt :one
-- Q10.1: o'sha kunda amal qilgan versiya. Retroaktiv qayta hisob yo'q, shuning
-- uchun `effective_from <= @at` bo'yicha eng so'nggisi olinadi.
SELECT id, company_id, effective_from, policy
FROM hos_policy_versions
WHERE company_id = @company_id AND deleted_at IS NULL AND effective_from <= @at
ORDER BY effective_from DESC
LIMIT 1;

-- --------------------------------------------------------------- idempotency

-- name: SyncKnownClientEventIDs :many
-- `client_event_id` global UNIQUE, shuning uchun boshqa tenant'ning yozuvi ham
-- qaytadi: `same_company=false` bo'lsa yozuv qilinmaydi, javob `duplicate`
-- (cross-tenant ma'lumot chiqmaydi).
SELECT client_event_id, (company_id = @company_id) AS same_company
FROM duty_status_events
WHERE client_event_id = ANY(@client_event_ids::uuid[]);

-- name: SyncListCertifiedLogDates :many
-- Konflikt qoidasi 5: sertifikatlangan (locked) kunga push yozmaydi.
SELECT log_date
FROM daily_logs
WHERE company_id = @company_id AND driver_id = @driver_id
  AND log_date = ANY(@log_dates::date[])
  AND certification_status = 'certified';

-- name: SyncListEventsAtInstants :many
-- Konflikt qoidasi 1: o'sha vaqt oralig'idagi saqlangan duty status eventlar.
SELECT id, client_event_id, event_time, time_source, device_seq, received_at
FROM duty_status_events
WHERE company_id = @company_id AND driver_id = @driver_id
  AND event_type = 'duty_status'
  AND superseded_by IS NULL
  AND event_time >= @from_at AND event_time <= @to_at;

-- name: SyncSupersedeEvents :exec
UPDATE duty_status_events SET superseded_by = @superseded_by
WHERE company_id = @company_id AND id = ANY(@ids::uuid[]) AND superseded_by IS NULL;

-- -------------------------------------------------------------- duty / HOS

-- name: DutyListDriverEventsBetween :many
-- HOS hisobi uchun to'liq oyna (cycle_days + joriy kun). Pagination yo'q:
-- natija hos.Compute ga to'liq ketadi.
SELECT id, driver_id, unit_id, event_type, status, special, event_time,
       time_source, time_unverified, clock_skew_sec, origin, lat, lng,
       location_text, gps_accuracy_m, odometer_m, engine_hours, notes,
       trailer_ids, shipping_doc_ids, client_event_id, device_seq,
       received_at, superseded_by, locked, daily_log_id
FROM duty_status_events
WHERE company_id = @company_id AND driver_id = @driver_id
  AND event_time >= @from_at AND event_time < @to_at
  AND superseded_by IS NULL
ORDER BY event_time, device_seq NULLS LAST;

-- name: DutyCountDriverEventsBetween :one
SELECT count(*)
FROM duty_status_events
WHERE company_id = @company_id AND driver_id = @driver_id
  AND event_time >= @from_at AND event_time < @to_at
  AND superseded_by IS NULL;

-- name: DutyListDriverEventsPage :many
SELECT id, driver_id, unit_id, event_type, status, special, event_time,
       time_source, time_unverified, clock_skew_sec, origin, lat, lng,
       location_text, gps_accuracy_m, odometer_m, engine_hours, notes,
       trailer_ids, shipping_doc_ids, client_event_id, device_seq,
       received_at, superseded_by, locked, daily_log_id
FROM duty_status_events
WHERE company_id = @company_id AND driver_id = @driver_id
  AND event_time >= @from_at AND event_time < @to_at
  AND superseded_by IS NULL
ORDER BY event_time, device_seq NULLS LAST
LIMIT @lim OFFSET @off;

-- name: DutySetDailyLogTotals :exec
-- `totals` JSONB ni hos.DayTotalsFor natijasi bilan qayta yozadi (Q10.2).
UPDATE daily_logs
SET totals = @totals, unit_ids = @unit_ids
WHERE company_id = @company_id AND id = @id;

-- ------------------------------------------------------------------- pull

-- name: SyncListUnidentifiedForUnits :many
-- Haydovchi login qilgan unit(lar) uchun pending unidentified driving (A§10.4).
SELECT e.id, e.unit_id, u.unit_number, e.start_at, e.end_at, e.distance_m,
       e.track_key, e.status, e.updated_at
FROM unidentified_events e
JOIN units u ON u.id = e.unit_id
WHERE e.company_id = @company_id
  AND e.unit_id = ANY(@unit_ids::uuid[])
  AND e.status = 'pending'
  AND e.updated_at > @since
ORDER BY e.updated_at
LIMIT @lim;

-- name: SyncListChatSince :many
SELECT id, driver_id, sender_id, kind, text, file_key, lat, lng,
       sent_at, delivered_at, read_at, updated_at
FROM chat_messages
WHERE company_id = @company_id AND driver_id = @driver_id AND updated_at > @since
ORDER BY updated_at
LIMIT @lim;

-- name: SyncListDefectTypes :many
SELECT id, company_id, name, category, is_critical, is_active, sort_order, updated_at
FROM defect_types
WHERE (company_id = @company_id OR company_id IS NULL)
  AND deleted_at IS NULL AND is_active
ORDER BY category, sort_order, name;

-- name: SyncListEventsChangedSince :many
-- Server kanonik (konflikt qoidasi 2): admin tahriri/assignment natijasida
-- o'zgargan eventlar mobilga qaytariladi.
SELECT id, driver_id, unit_id, event_type, status, special, event_time,
       time_source, time_unverified, clock_skew_sec, origin, lat, lng,
       location_text, gps_accuracy_m, odometer_m, engine_hours, notes,
       trailer_ids, shipping_doc_ids, client_event_id, device_seq,
       received_at, superseded_by, locked, daily_log_id, updated_at
FROM duty_status_events
WHERE company_id = @company_id AND driver_id = @driver_id AND updated_at > @since
ORDER BY updated_at
LIMIT @lim;

-- name: SyncListDailyLogsChangedSince :many
SELECT id, driver_id, log_date, timezone, unit_ids, co_driver_id, distance_m,
       trailer_ids, shipping_doc_ids, totals, certification_status, signed_at,
       updated_at
FROM daily_logs
WHERE company_id = @company_id AND driver_id = @driver_id AND updated_at > @since
ORDER BY updated_at
LIMIT @lim;
