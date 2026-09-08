-- +goose Up

-- ---------------------------------------------------------------- DVIR state machine (TZ §7.2)
-- draft -> submitted_no_defects
-- draft -> submitted_defects_found -> repaired -> certified
-- Q30.1 fallback: closed_no_certification.

-- +goose StatementBegin
ALTER TABLE dvir_reports ADD COLUMN IF NOT EXISTS certification_signature_key text;
ALTER TABLE dvir_reports ADD COLUMN IF NOT EXISTS closed_at timestamptz;
ALTER TABLE dvir_reports ADD COLUMN IF NOT EXISTS closed_reason text;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE dvir_reports DROP CONSTRAINT IF EXISTS dvir_reports_status_check;
-- +goose StatementEnd

-- +goose StatementBegin
UPDATE dvir_reports SET status = CASE status
  WHEN 'satisfactory'          THEN 'submitted_no_defects'
  WHEN 'defects_found'         THEN 'submitted_defects_found'
  WHEN 'defects_not_corrected' THEN 'submitted_defects_found'
  WHEN 'defects_corrected'     THEN 'repaired'
  ELSE status
END
WHERE status IN ('satisfactory','defects_found','defects_not_corrected','defects_corrected');
-- +goose StatementEnd

-- +goose StatementBegin
UPDATE dvir_reports SET status = 'certified' WHERE certified_at IS NOT NULL AND status = 'repaired';
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE dvir_reports ALTER COLUMN status SET DEFAULT 'submitted_no_defects';
ALTER TABLE dvir_reports ADD CONSTRAINT dvir_reports_status_check
  CHECK (status IN ('draft','submitted_no_defects','submitted_defects_found','repaired','certified','closed_no_certification'));
-- +goose StatementEnd

-- +goose StatementBegin
DROP INDEX IF EXISTS dvir_reports_pending_cert_idx;
CREATE INDEX dvir_reports_pending_cert_idx ON dvir_reports (company_id, unit_id, performed_at)
  WHERE status IN ('submitted_defects_found','repaired');
-- +goose StatementEnd

-- ---------------------------------------------------------------- Maintenance (Q33, Q42.1)
-- +goose StatementBegin
ALTER TABLE maintenance_schedule_units ADD COLUMN IF NOT EXISTS last_service_at timestamptz;
ALTER TABLE maintenance_schedule_units ADD COLUMN IF NOT EXISTS cancelled_reason text;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS maintenance_schedule_units_reminder_idx
  ON maintenance_schedule_units (company_id) WHERE reminder_sent_at IS NULL AND deleted_at IS NULL;
-- +goose StatementEnd

-- +goose Down

-- +goose StatementBegin
DROP INDEX IF EXISTS maintenance_schedule_units_reminder_idx;
ALTER TABLE maintenance_schedule_units DROP COLUMN IF EXISTS cancelled_reason;
ALTER TABLE maintenance_schedule_units DROP COLUMN IF EXISTS last_service_at;
-- +goose StatementEnd

-- +goose StatementBegin
DROP INDEX IF EXISTS dvir_reports_pending_cert_idx;
ALTER TABLE dvir_reports DROP CONSTRAINT IF EXISTS dvir_reports_status_check;
UPDATE dvir_reports SET status = CASE status
  WHEN 'submitted_no_defects'      THEN 'satisfactory'
  WHEN 'submitted_defects_found'   THEN 'defects_found'
  WHEN 'certified'                 THEN 'defects_corrected'
  WHEN 'draft'                     THEN 'satisfactory'
  WHEN 'closed_no_certification'   THEN 'defects_found'
  ELSE status
END;
ALTER TABLE dvir_reports ALTER COLUMN status SET DEFAULT 'satisfactory';
ALTER TABLE dvir_reports ADD CONSTRAINT dvir_reports_status_check
  CHECK (status IN ('satisfactory','defects_found','defects_corrected','defects_not_corrected','repaired'));
CREATE INDEX dvir_reports_pending_cert_idx ON dvir_reports (company_id, unit_id) WHERE certified_at IS NULL;
ALTER TABLE dvir_reports DROP COLUMN IF EXISTS closed_reason;
ALTER TABLE dvir_reports DROP COLUMN IF EXISTS closed_at;
ALTER TABLE dvir_reports DROP COLUMN IF EXISTS certification_signature_key;
-- +goose StatementEnd
