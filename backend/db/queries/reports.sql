-- name: CreateReportExportJob :one
INSERT INTO report_export_jobs (company_id, requested_by, type, format, params, status)
VALUES ($1,$2,$3,$4,$5,'queued') RETURNING *;

-- name: GetReportExportJob :one
SELECT * FROM report_export_jobs WHERE company_id = $1 AND id = $2;

-- name: ListReportExportJobs :many
SELECT * FROM report_export_jobs
WHERE company_id = @company_id
  AND (sqlc.narg('status')::text IS NULL OR status = sqlc.narg('status')::text)
  AND (sqlc.narg('requested_by')::uuid IS NULL OR requested_by = sqlc.narg('requested_by')::uuid)
  AND (sqlc.narg('type')::text IS NULL OR type = sqlc.narg('type')::text)
ORDER BY created_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountReportExportJobs :one
SELECT count(*) FROM report_export_jobs
WHERE company_id = @company_id
  AND (sqlc.narg('status')::text IS NULL OR status = sqlc.narg('status')::text)
  AND (sqlc.narg('requested_by')::uuid IS NULL OR requested_by = sqlc.narg('requested_by')::uuid)
  AND (sqlc.narg('type')::text IS NULL OR type = sqlc.narg('type')::text);

-- name: SetReportExportJobStatus :one
UPDATE report_export_jobs SET status = $3, file_key = COALESCE($4::text, file_key),
       error = COALESCE($5::text, error), expires_at = COALESCE($6::timestamptz, expires_at)
WHERE company_id = $1 AND id = $2
RETURNING *;

-- name: StartReportExportJob :one
UPDATE report_export_jobs SET status = 'running', started_at = now(), error = NULL
WHERE company_id = $1 AND id = $2 AND status IN ('queued','running')
RETURNING *;

-- name: FinishReportExportJob :one
UPDATE report_export_jobs SET
  status       = 'done',
  format       = $3,
  file_key     = $4,
  file_name    = $5,
  file_size_b  = $6,
  content_type = $7,
  expires_at   = $8,
  finished_at  = now(),
  error        = NULL
WHERE company_id = $1 AND id = $2
RETURNING *;

-- name: FailReportExportJob :one
UPDATE report_export_jobs SET status = 'failed', error = $3, finished_at = now()
WHERE company_id = $1 AND id = $2
RETURNING *;

-- name: DeleteExpiredReportExportJobs :exec
DELETE FROM report_export_jobs WHERE expires_at IS NOT NULL AND expires_at < now();

-- name: ReportDriverActivity :many
SELECT
  l.driver_id,
  u.first_name,
  u.last_name,
  count(*)::bigint                                        AS log_days,
  COALESCE(sum(l.distance_m), 0)::bigint                  AS distance_m,
  COALESCE(sum((l.totals->>'dr')::bigint), 0)::bigint     AS driving_sec,
  COALESCE(sum((l.totals->>'on')::bigint), 0)::bigint     AS on_duty_sec,
  COALESCE(sum((l.totals->>'sb')::bigint), 0)::bigint     AS sleeper_sec,
  COALESCE(sum((l.totals->>'off')::bigint), 0)::bigint    AS off_duty_sec,
  count(*) FILTER (WHERE l.certification_status = 'certified')::bigint AS certified_days
FROM daily_logs l
JOIN drivers d ON d.id = l.driver_id
JOIN users   u ON u.id = d.user_id
WHERE l.company_id = $1 AND l.log_date >= $2 AND l.log_date <= $3
  AND ($4::uuid[] IS NULL OR l.driver_id = ANY($4::uuid[]))
GROUP BY l.driver_id, u.first_name, u.last_name
ORDER BY u.last_name, u.first_name
LIMIT $5 OFFSET $6;

-- name: ReportDistanceByRegion :many
SELECT r.region_code, rg.name AS region_name, rg.country,
       sum(r.distance_m)::bigint AS distance_m
FROM unit_region_distance_daily r
JOIN regions rg ON rg.code = r.region_code
JOIN units u ON u.id = r.unit_id AND u.company_id = r.company_id
WHERE r.company_id = @company_id AND r.date >= @from_date AND r.date <= @to_date
  AND (sqlc.narg('unit_ids')::uuid[] IS NULL OR r.unit_id = ANY(sqlc.narg('unit_ids')::uuid[]))
  AND (sqlc.narg('branch_id')::uuid IS NULL OR u.branch_id = sqlc.narg('branch_id')::uuid)
GROUP BY r.region_code, rg.name, rg.country
ORDER BY distance_m DESC;

-- name: DashboardSummary :one
SELECT
  (SELECT count(*) FROM units u
     WHERE u.company_id = $1 AND u.deleted_at IS NULL AND u.status = 'active')::bigint          AS active_units,
  (SELECT count(*) FROM drivers dr
     WHERE dr.company_id = $1 AND dr.deleted_at IS NULL AND dr.status = 'active')::bigint       AS active_drivers,
  (SELECT count(*) FROM unit_last_state ls
     WHERE ls.company_id = $1 AND ls.online_status = 'online')::bigint                          AS online_units,
  (SELECT count(*) FROM violations v
     WHERE v.company_id = $1 AND v.occurred_at >= $2 AND v.resolved_at IS NULL)::bigint         AS open_violations,
  (SELECT count(*) FROM log_edit_requests ler
     WHERE ler.company_id = $1 AND ler.status = 'pending')::bigint                              AS pending_log_edits,
  (SELECT count(*) FROM unidentified_events ue
     WHERE ue.company_id = $1 AND ue.status = 'pending')::bigint                                AS pending_unidentified,
  (SELECT count(*) FROM daily_logs dl
     WHERE dl.company_id = $1 AND dl.certification_status <> 'certified'
       AND dl.log_date >= (CURRENT_DATE - 8) AND dl.log_date < CURRENT_DATE)::bigint            AS uncertified_logs,
  (SELECT count(*) FROM dvir_reports dv
     WHERE dv.company_id = $1 AND dv.certified_at IS NULL
       AND dv.status IN ('submitted_defects_found','repaired'))::bigint                          AS open_dvir,
  (SELECT count(*) FROM maintenance_schedule_units msu
     WHERE msu.company_id = $1 AND msu.deleted_at IS NULL AND msu.status = 'due')::bigint       AS maintenance_due;

-- name: ReportActivityUnits :many
SELECT u.id AS unit_id, u.unit_number,
       COALESCE(min(t.odometer_m), 0)::bigint AS start_odometer_m,
       COALESCE(max(t.odometer_m), 0)::bigint AS end_odometer_m,
       count(t.ts)::bigint                    AS samples
FROM units u
LEFT JOIN telemetry t
  ON t.unit_id = u.id AND t.company_id = u.company_id
 AND t.ts >= @from_ts AND t.ts < @to_ts AND t.odometer_m IS NOT NULL
WHERE u.company_id = @company_id AND u.deleted_at IS NULL
  AND (sqlc.narg('unit_ids')::uuid[] IS NULL OR u.id = ANY(sqlc.narg('unit_ids')::uuid[]))
  -- Branch scope (TZ A§16): a unit report is partitioned by units.branch_id.
  AND (sqlc.narg('branch_id')::uuid IS NULL OR u.branch_id = sqlc.narg('branch_id')::uuid)
GROUP BY u.id, u.unit_number
ORDER BY u.unit_number
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountReportActivityUnits :one
SELECT count(*) FROM units u
WHERE u.company_id = @company_id AND u.deleted_at IS NULL
  AND (sqlc.narg('unit_ids')::uuid[] IS NULL OR u.id = ANY(sqlc.narg('unit_ids')::uuid[]))
  AND (sqlc.narg('branch_id')::uuid IS NULL OR u.branch_id = sqlc.narg('branch_id')::uuid);

-- name: ReportActivityDrivers :many
SELECT d.id AS driver_id, us.first_name, us.last_name,
       COALESCE(min(t.odometer_m), 0)::bigint AS start_odometer_m,
       COALESCE(max(t.odometer_m), 0)::bigint AS end_odometer_m,
       count(t.ts)::bigint                    AS samples
FROM drivers d
JOIN users us ON us.id = d.user_id
LEFT JOIN telemetry t
  ON t.driver_id = d.id AND t.company_id = d.company_id
 AND t.ts >= @from_ts AND t.ts < @to_ts AND t.odometer_m IS NOT NULL
WHERE d.company_id = @company_id AND d.deleted_at IS NULL
  AND (sqlc.narg('driver_ids')::uuid[] IS NULL OR d.id = ANY(sqlc.narg('driver_ids')::uuid[]))
  -- Branch scope (TZ A§16): a driver report is partitioned by drivers.branch_id.
  AND (sqlc.narg('branch_id')::uuid IS NULL OR d.branch_id = sqlc.narg('branch_id')::uuid)
GROUP BY d.id, us.first_name, us.last_name
ORDER BY us.last_name, us.first_name
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountReportActivityDrivers :one
SELECT count(*) FROM drivers d
WHERE d.company_id = @company_id AND d.deleted_at IS NULL
  AND (sqlc.narg('driver_ids')::uuid[] IS NULL OR d.id = ANY(sqlc.narg('driver_ids')::uuid[]))
  AND (sqlc.narg('branch_id')::uuid IS NULL OR d.branch_id = sqlc.narg('branch_id')::uuid);

-- name: ReportDistanceByRegionUnits :many
SELECT r.unit_id, u.unit_number, r.region_code, rg.name AS region_name, rg.country,
       sum(r.distance_m)::bigint AS distance_m
FROM unit_region_distance_daily r
JOIN regions rg ON rg.code = r.region_code
JOIN units u ON u.id = r.unit_id
WHERE r.company_id = @company_id AND r.date >= @from_date AND r.date <= @to_date
  AND (sqlc.narg('unit_ids')::uuid[] IS NULL OR r.unit_id = ANY(sqlc.narg('unit_ids')::uuid[]))
  AND (sqlc.narg('branch_id')::uuid IS NULL OR u.branch_id = sqlc.narg('branch_id')::uuid)
GROUP BY r.unit_id, u.unit_number, r.region_code, rg.name, rg.country
ORDER BY u.unit_number, r.region_code;

-- name: ReportHosSummary :many
SELECT l.id AS daily_log_id, l.driver_id, us.first_name, us.last_name, l.log_date,
       l.timezone,
       COALESCE((l.totals->>'dr')::bigint, 0)::bigint  AS driving_sec,
       COALESCE((l.totals->>'on')::bigint, 0)::bigint  AS on_duty_sec,
       COALESCE((l.totals->>'sb')::bigint, 0)::bigint  AS sleeper_sec,
       COALESCE((l.totals->>'off')::bigint, 0)::bigint AS off_duty_sec,
       l.distance_m,
       l.certification_status,
       (SELECT count(*) FROM violations v WHERE v.daily_log_id = l.id)::bigint AS violations
FROM daily_logs l
JOIN drivers d ON d.id = l.driver_id
JOIN users us ON us.id = d.user_id
WHERE l.company_id = @company_id AND l.log_date >= @from_date AND l.log_date <= @to_date
  AND (sqlc.narg('driver_ids')::uuid[] IS NULL OR l.driver_id = ANY(sqlc.narg('driver_ids')::uuid[]))
  AND (sqlc.narg('branch_id')::uuid IS NULL OR d.branch_id = sqlc.narg('branch_id')::uuid)
ORDER BY us.last_name, us.first_name, l.log_date
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountReportHosSummary :one
SELECT count(*) FROM daily_logs l
JOIN drivers d ON d.id = l.driver_id
WHERE l.company_id = @company_id AND l.log_date >= @from_date AND l.log_date <= @to_date
  AND (sqlc.narg('driver_ids')::uuid[] IS NULL OR l.driver_id = ANY(sqlc.narg('driver_ids')::uuid[]))
  AND (sqlc.narg('branch_id')::uuid IS NULL OR d.branch_id = sqlc.narg('branch_id')::uuid);
