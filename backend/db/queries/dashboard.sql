-- TZ A§20 — Dashboard KPI kartalari. Kun/hafta chegaralari Company TZ da
-- hisoblanib, UTC instant sifatida uzatiladi (backend hech qachon UI uchun
-- konvertatsiya qilmaydi).

-- name: DashboardKPI :one
-- branch_id (nullable): a branch scoped principal narrows every card to the
-- units/drivers of its branch (TZ branch scope). NULL means company-wide.
WITH current_status AS (
  SELECT d.id AS driver_id, (
    SELECT e.status FROM duty_status_events e
    WHERE e.company_id = d.company_id AND e.driver_id = d.id
      AND e.event_type = 'duty_status' AND e.superseded_by IS NULL
    ORDER BY e.event_time DESC, e.id DESC
    LIMIT 1
  ) AS status
  FROM drivers d
  WHERE d.company_id = sqlc.arg('company_id')
    AND d.deleted_at IS NULL AND d.status = 'active'
    AND (sqlc.narg('branch_id')::uuid IS NULL OR d.branch_id = sqlc.narg('branch_id')::uuid)
)
SELECT
  -- Active Units: bugun (Company TZ) telemetriya bergan unitlar.
  (SELECT count(*) FROM unit_last_state ls
     JOIN units u ON u.id = ls.unit_id AND u.deleted_at IS NULL
     WHERE ls.company_id = sqlc.arg('company_id')
       AND ls.ts >= sqlc.arg('day_start')::timestamptz
       AND (sqlc.narg('branch_id')::uuid IS NULL OR u.branch_id = sqlc.narg('branch_id')::uuid))::bigint AS active_units,
  -- Drivers On Duty: hozir ON yoki DR.
  (SELECT count(*) FROM current_status
     WHERE status IN ('ON','DR'))::bigint                                AS drivers_on_duty,
  -- Violations: joriy ISO hafta (Du–Ya).
  (SELECT count(*) FROM violations v
     JOIN drivers d ON d.id = v.driver_id
     WHERE v.company_id = sqlc.arg('company_id')
       AND v.occurred_at >= sqlc.arg('week_start')::timestamptz
       AND v.occurred_at <  sqlc.arg('week_end')::timestamptz
       AND (sqlc.narg('branch_id')::uuid IS NULL OR d.branch_id = sqlc.narg('branch_id')::uuid))::bigint AS violations,
  -- Disconnected ELD: hozirgi holat (§10.1).
  (SELECT count(*) FROM unit_last_state ls
     JOIN units u ON u.id = ls.unit_id AND u.deleted_at IS NULL
     WHERE ls.company_id = sqlc.arg('company_id')
       AND ls.online_status = 'disconnected'
       AND (sqlc.narg('branch_id')::uuid IS NULL OR u.branch_id = sqlc.narg('branch_id')::uuid))::bigint AS disconnected_eld,
  -- Malfunction — eld_devices dan hosil qilinadi, saqlanmaydi.
  (SELECT count(*) FROM eld_devices ed
     LEFT JOIN units u ON u.id = ed.unit_id
     WHERE ed.company_id = sqlc.arg('company_id') AND ed.deleted_at IS NULL
       AND (ed.status = 'malfunction' OR cardinality(ed.malfunction_codes) > 0)
       AND (sqlc.narg('branch_id')::uuid IS NULL OR u.branch_id = sqlc.narg('branch_id')::uuid))::bigint AS malfunction_eld,
  -- Uncertified Logs: ≥ 2 kun sertifikatlanmagan.
  (SELECT count(*) FROM daily_logs dl
     JOIN drivers d ON d.id = dl.driver_id
     WHERE dl.company_id = sqlc.arg('company_id')
       AND dl.certification_status <> 'certified'
       AND dl.log_date <= sqlc.arg('uncertified_before')::date
       AND (sqlc.narg('branch_id')::uuid IS NULL OR d.branch_id = sqlc.narg('branch_id')::uuid))::bigint AS uncertified_logs,
  -- Unassigned driving: kutayotgan unidentified event'lar.
  (SELECT count(*) FROM unidentified_events ue
     JOIN units u ON u.id = ue.unit_id
     WHERE ue.company_id = sqlc.arg('company_id')
       AND ue.status = 'pending'
       AND (sqlc.narg('branch_id')::uuid IS NULL OR u.branch_id = sqlc.narg('branch_id')::uuid))::bigint AS unassigned_driving,
  -- Status bloki.
  (SELECT count(*) FROM current_status WHERE status = 'OFF')::bigint     AS status_off,
  (SELECT count(*) FROM current_status WHERE status = 'SB')::bigint      AS status_sb,
  (SELECT count(*) FROM current_status WHERE status = 'DR')::bigint      AS status_dr,
  (SELECT count(*) FROM current_status WHERE status = 'ON')::bigint      AS status_on,
  (SELECT count(*) FROM drivers d
     WHERE d.company_id = sqlc.arg('company_id')
       AND d.deleted_at IS NULL AND d.status = 'active'
       AND (sqlc.narg('branch_id')::uuid IS NULL OR d.branch_id = sqlc.narg('branch_id')::uuid))::bigint AS active_drivers,
  (SELECT count(*) FROM log_edit_requests ler
     JOIN drivers d ON d.id = ler.driver_id
     WHERE ler.company_id = sqlc.arg('company_id')
       AND ler.status = 'pending'
       AND (sqlc.narg('branch_id')::uuid IS NULL OR d.branch_id = sqlc.narg('branch_id')::uuid))::bigint AS pending_log_edits;

-- name: DashboardTodayRoutes :many
SELECT
  r.id, r.status, r.sequence, r.origin_text, r.dest_text,
  r.started_at, r.completed_at, r.created_at,
  r.unit_id, un.unit_number,
  r.driver_id, u.first_name, u.last_name
FROM routes r
JOIN units un ON un.id = r.unit_id
JOIN drivers d ON d.id = r.driver_id
JOIN users u   ON u.id = d.user_id
WHERE r.company_id = sqlc.arg('company_id')
  AND r.deleted_at IS NULL
  AND (sqlc.narg('branch_id')::uuid IS NULL OR d.branch_id = sqlc.narg('branch_id')::uuid)
  AND (
    (r.created_at   >= sqlc.arg('day_start')::timestamptz AND r.created_at   < sqlc.arg('day_end')::timestamptz)
    OR (r.started_at   >= sqlc.arg('day_start')::timestamptz AND r.started_at   < sqlc.arg('day_end')::timestamptz)
    OR (r.completed_at >= sqlc.arg('day_start')::timestamptz AND r.completed_at < sqlc.arg('day_end')::timestamptz)
    -- A route that is still running is listed whenever it started. The
    -- predicate names the terminal states so it survives a status rename.
    OR r.status NOT IN ('completed', 'not_completed', 'cancelled')
  )
ORDER BY r.sequence, r.created_at DESC
LIMIT sqlc.arg('row_limit');

-- name: DashboardCompanyTimezone :one
SELECT timezone FROM companies WHERE id = $1 AND deleted_at IS NULL;

-- Chat/tracking WS obunasi uchun unit egaligi tekshiruvi.
-- name: CountUnitsOwned :one
SELECT count(*) FROM units
WHERE company_id = $1 AND id = ANY($2::uuid[]) AND deleted_at IS NULL;
