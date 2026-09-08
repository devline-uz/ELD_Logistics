-- +goose Up

-- Q66-Q68: the trip planner has three states, not five. `planned` and
-- `in_progress` collapse into `ongoing`, which is what a route gets on
-- creation; the driver never has to start it by hand.
-- +goose StatementBegin
ALTER TABLE routes DROP CONSTRAINT IF EXISTS routes_status_check;
-- +goose StatementEnd

-- +goose StatementBegin
UPDATE routes SET status = 'ongoing' WHERE status IN ('planned','in_progress');
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE routes
  ADD CONSTRAINT routes_status_check
  CHECK (status IN ('ongoing','completed','not_completed','cancelled'));
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE routes ALTER COLUMN status SET DEFAULT 'ongoing';
-- +goose StatementEnd

-- Q66: the destination geofence defaults to 300 m.
-- +goose StatementBegin
ALTER TABLE routes ALTER COLUMN geofence_m SET DEFAULT 300;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE routes
  ADD COLUMN IF NOT EXISTS not_completed_note text,
  ADD COLUMN IF NOT EXISTS not_completed_by   uuid REFERENCES users(id) ON DELETE RESTRICT,
  -- geofence_entered_at is when the unit was first seen inside the destination
  -- geofence. The sweep completes the route once it has stayed there for two
  -- minutes (Q66); a sample outside the circle clears it again.
  ADD COLUMN IF NOT EXISTS geofence_entered_at timestamptz;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE routes
  ADD CONSTRAINT routes_not_completed_reason_check
  CHECK (not_completed_reason IS NULL OR not_completed_reason IN
    ('breakdown','cancelled','load_rejected','road_closed','driver_change','other'));
-- +goose StatementEnd

-- Q68: only one route per unit may be the current one, so the sweep has a
-- deterministic (unit, sequence) ordering to work from.
-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS routes_unit_sequence_idx
  ON routes (company_id, unit_id, sequence)
  WHERE deleted_at IS NULL AND status = 'ongoing';
-- +goose StatementEnd

-- Q75: the regulator export ships a PDF and a CSV inside one archive.
-- +goose StatementBegin
ALTER TABLE report_export_jobs DROP CONSTRAINT IF EXISTS report_export_jobs_format_check;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE report_export_jobs
  ADD CONSTRAINT report_export_jobs_format_check
  CHECK (format IN ('xlsx','csv','pdf','zip'));
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE report_export_jobs
  ADD COLUMN IF NOT EXISTS file_name    text,
  ADD COLUMN IF NOT EXISTS file_size_b  bigint,
  ADD COLUMN IF NOT EXISTS content_type text,
  ADD COLUMN IF NOT EXISTS started_at   timestamptz,
  ADD COLUMN IF NOT EXISTS finished_at  timestamptz;
-- +goose StatementEnd

-- +goose Down

-- +goose StatementBegin
ALTER TABLE report_export_jobs
  DROP COLUMN IF EXISTS file_name,
  DROP COLUMN IF EXISTS file_size_b,
  DROP COLUMN IF EXISTS content_type,
  DROP COLUMN IF EXISTS started_at,
  DROP COLUMN IF EXISTS finished_at;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE report_export_jobs DROP CONSTRAINT IF EXISTS report_export_jobs_format_check;
ALTER TABLE report_export_jobs
  ADD CONSTRAINT report_export_jobs_format_check CHECK (format IN ('xlsx','csv','pdf'));
-- +goose StatementEnd

-- +goose StatementBegin
DROP INDEX IF EXISTS routes_unit_sequence_idx;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE routes DROP CONSTRAINT IF EXISTS routes_not_completed_reason_check;
ALTER TABLE routes
  DROP COLUMN IF EXISTS not_completed_note,
  DROP COLUMN IF EXISTS not_completed_by,
  DROP COLUMN IF EXISTS geofence_entered_at;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE routes ALTER COLUMN geofence_m SET DEFAULT 200;
ALTER TABLE routes ALTER COLUMN status SET DEFAULT 'planned';
ALTER TABLE routes DROP CONSTRAINT IF EXISTS routes_status_check;
UPDATE routes SET status = 'planned' WHERE status = 'ongoing';
ALTER TABLE routes
  ADD CONSTRAINT routes_status_check
  CHECK (status IN ('planned','in_progress','completed','not_completed','cancelled'));
-- +goose StatementEnd
