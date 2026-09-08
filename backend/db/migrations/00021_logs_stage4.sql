-- Stage 4 (internal/domain/logs): certification metadata, the propose/approve
-- edit model and the canonical violation catalogue.
-- +goose Up

-- Q26.1: the certification records who signed, from where and on which device.
-- +goose StatementBegin
ALTER TABLE daily_logs ADD COLUMN IF NOT EXISTS signed_ip text;
ALTER TABLE daily_logs ADD COLUMN IF NOT EXISTS signed_by uuid REFERENCES users(id) ON DELETE RESTRICT;
-- +goose StatementEnd

-- TZ §5.3 / §10.4: an edit request either carries an admin proposal or the
-- assignment of an unidentified driving block awaiting the driver's answer.
-- +goose StatementBegin
ALTER TABLE log_edit_requests ADD COLUMN IF NOT EXISTS source text NOT NULL DEFAULT 'admin_edit';
ALTER TABLE log_edit_requests DROP CONSTRAINT IF EXISTS log_edit_requests_source_check;
ALTER TABLE log_edit_requests ADD CONSTRAINT log_edit_requests_source_check
  CHECK (source IN ('admin_edit','unidentified_assign'));
ALTER TABLE log_edit_requests ADD COLUMN IF NOT EXISTS unidentified_event_id uuid
  REFERENCES unidentified_events(id) ON DELETE RESTRICT;
CREATE INDEX IF NOT EXISTS log_edit_requests_unidentified_idx
  ON log_edit_requests (unidentified_event_id) WHERE unidentified_event_id IS NOT NULL;
-- +goose StatementEnd

-- §10.4: an admin assignment is a proposal until the driver approves it, so the
-- block sits in `proposed` and only reaches `assigned` on approval.
-- +goose StatementBegin
ALTER TABLE unidentified_events ADD COLUMN IF NOT EXISTS edit_request_id uuid
  REFERENCES log_edit_requests(id) ON DELETE RESTRICT;
ALTER TABLE unidentified_events DROP CONSTRAINT IF EXISTS unidentified_events_status_check;
ALTER TABLE unidentified_events ADD CONSTRAINT unidentified_events_status_check
  CHECK (status IN ('pending','proposed','assigned','annotated'));
-- +goose StatementEnd

-- Q57: the violation catalogue is the HOS engine's, so internal/hos types map
-- one to one onto the stored rows. Severity is the two level warning/violation.
-- +goose StatementBegin
UPDATE violations SET type = CASE type
  WHEN 'driving_11h'           THEN 'drive_limit'
  WHEN 'duty_14h'              THEN 'shift_limit'
  WHEN 'break_30m'             THEN 'break_required'
  WHEN 'cycle_60h'             THEN 'cycle_limit'
  WHEN 'cycle_70h'             THEN 'cycle_limit'
  WHEN 'sb_split'              THEN 'shift_limit'
  WHEN 'restart_34h'           THEN 'cycle_limit'
  WHEN 'form_manner'           THEN 'form_manner_trailer'
  WHEN 'missing_certification' THEN 'uncertified_log'
  WHEN 'unassigned_driving'    THEN 'unidentified_driving'
  ELSE type
END;
UPDATE violations SET severity = CASE severity
  WHEN 'info'     THEN 'warning'
  WHEN 'critical' THEN 'violation'
  ELSE severity
END;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE violations DROP CONSTRAINT IF EXISTS violations_type_check;
ALTER TABLE violations ADD CONSTRAINT violations_type_check CHECK (type IN (
  'form_manner_trailer','form_manner_doc','drive_limit','shift_limit','break_required',
  'cycle_limit','uncertified_log','unidentified_driving','eld_malfunction','missing_dvir'));
ALTER TABLE violations DROP CONSTRAINT IF EXISTS violations_severity_check;
ALTER TABLE violations ADD CONSTRAINT violations_severity_check
  CHECK (severity IN ('warning','violation'));
-- +goose StatementEnd

-- The violation is never deleted (Q58); a recomputation of the same log day
-- updates the open row instead of piling duplicates up.
-- +goose StatementBegin
ALTER TABLE violations ADD COLUMN IF NOT EXISTS unidentified_event_id uuid
  REFERENCES unidentified_events(id) ON DELETE RESTRICT;
ALTER TABLE violations ADD COLUMN IF NOT EXISTS resolved_by uuid REFERENCES users(id) ON DELETE RESTRICT;
-- An `unidentified_driving` violation has no driver by definition (§10.4).
ALTER TABLE violations ALTER COLUMN driver_id DROP NOT NULL;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX IF NOT EXISTS violations_open_day_type_uniq
  ON violations (daily_log_id, type)
  WHERE daily_log_id IS NOT NULL AND resolved_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS violations_open_unidentified_uniq
  ON violations (unidentified_event_id)
  WHERE unidentified_event_id IS NOT NULL AND resolved_at IS NULL;
CREATE INDEX IF NOT EXISTS violations_company_open_idx
  ON violations (company_id, occurred_at DESC) WHERE resolved_at IS NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS violations_company_open_idx;
DROP INDEX IF EXISTS violations_open_unidentified_uniq;
DROP INDEX IF EXISTS violations_open_day_type_uniq;
ALTER TABLE violations ALTER COLUMN driver_id SET NOT NULL;
ALTER TABLE violations DROP COLUMN IF EXISTS resolved_by;
ALTER TABLE violations DROP COLUMN IF EXISTS unidentified_event_id;
ALTER TABLE violations DROP CONSTRAINT IF EXISTS violations_severity_check;
ALTER TABLE violations DROP CONSTRAINT IF EXISTS violations_type_check;
ALTER TABLE unidentified_events DROP CONSTRAINT IF EXISTS unidentified_events_status_check;
ALTER TABLE unidentified_events DROP COLUMN IF EXISTS edit_request_id;
DROP INDEX IF EXISTS log_edit_requests_unidentified_idx;
ALTER TABLE log_edit_requests DROP COLUMN IF EXISTS unidentified_event_id;
ALTER TABLE log_edit_requests DROP CONSTRAINT IF EXISTS log_edit_requests_source_check;
ALTER TABLE log_edit_requests DROP COLUMN IF EXISTS source;
ALTER TABLE daily_logs DROP COLUMN IF EXISTS signed_by;
ALTER TABLE daily_logs DROP COLUMN IF EXISTS signed_ip;
-- +goose StatementEnd
