-- +goose Up
-- defect_types: company_id NULL = tizim (default) katalogi.
-- +goose StatementBegin
CREATE TABLE defect_types (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id  uuid REFERENCES companies(id) ON DELETE RESTRICT,
  name        text NOT NULL,
  category    text NOT NULL CHECK (category IN ('truck','trailer')),
  is_critical boolean NOT NULL DEFAULT false,
  is_active   boolean NOT NULL DEFAULT true,
  sort_order  integer NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  deleted_at  timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX defect_types_company_name_uniq ON defect_types (company_id, category, lower(name)) WHERE deleted_at IS NULL AND company_id IS NOT NULL;
CREATE UNIQUE INDEX defect_types_system_name_uniq  ON defect_types (category, lower(name)) WHERE deleted_at IS NULL AND company_id IS NULL;
CREATE INDEX defect_types_company_idx ON defect_types (company_id) WHERE deleted_at IS NULL;
CREATE TRIGGER defect_types_set_updated_at BEFORE UPDATE ON defect_types FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE dvir_reports (
  id                       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id               uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  unit_id                  uuid NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
  driver_id                uuid NOT NULL REFERENCES drivers(id) ON DELETE RESTRICT,
  type                     text NOT NULL CHECK (type IN ('pre_trip','post_trip')),
  trailer_ids              uuid[] NOT NULL DEFAULT '{}',
  status                   text NOT NULL DEFAULT 'satisfactory' CHECK (status IN ('satisfactory','defects_found','defects_corrected','defects_not_corrected','repaired')),
  defects                  jsonb NOT NULL DEFAULT '[]'::jsonb,
  lat                      double precision,
  lng                      double precision,
  location_text            text,
  odometer_m               bigint,
  engine_hours             numeric(12,2),
  driver_signature_key     text,
  mechanic_id              uuid REFERENCES users(id) ON DELETE RESTRICT,
  mechanic_note            text,
  mechanic_signature_key   text,
  repaired_at              timestamptz,
  certified_by_driver_id   uuid REFERENCES drivers(id) ON DELETE RESTRICT,
  certified_at             timestamptz,
  source                   text NOT NULL DEFAULT 'app' CHECK (source IN ('app','paper_import')),
  performed_at             timestamptz NOT NULL DEFAULT now(),
  created_at               timestamptz NOT NULL DEFAULT now(),
  updated_at               timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX dvir_reports_company_time_idx ON dvir_reports (company_id, performed_at DESC);
CREATE INDEX dvir_reports_unit_time_idx    ON dvir_reports (unit_id, performed_at DESC);
CREATE INDEX dvir_reports_driver_time_idx  ON dvir_reports (driver_id, performed_at DESC);
CREATE INDEX dvir_reports_company_status_idx ON dvir_reports (company_id, status);
CREATE INDEX dvir_reports_pending_cert_idx ON dvir_reports (company_id, unit_id) WHERE certified_at IS NULL;
CREATE TRIGGER dvir_reports_set_updated_at BEFORE UPDATE ON dvir_reports FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE maintenance_schedules (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id            uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  name                  text NOT NULL,
  type                  text,
  interval_value        numeric(14,2) NOT NULL,
  interval_unit         text NOT NULL CHECK (interval_unit IN ('km','mi','days','engine_hours')),
  reminder_before_value numeric(14,2) NOT NULL DEFAULT 0,
  alert_type            text NOT NULL DEFAULT 'notification' CHECK (alert_type IN ('notification','email','sms','none')),
  delivery_methods      text[] NOT NULL DEFAULT '{}',
  notify_co_driver      boolean NOT NULL DEFAULT false,
  notes                 text,
  status                text NOT NULL DEFAULT 'active' CHECK (status IN ('active','inactive')),
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now(),
  deleted_at            timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX maintenance_schedules_company_name_uniq ON maintenance_schedules (company_id, lower(name)) WHERE deleted_at IS NULL;
CREATE INDEX maintenance_schedules_company_idx ON maintenance_schedules (company_id, status) WHERE deleted_at IS NULL;
CREATE TRIGGER maintenance_schedules_set_updated_at BEFORE UPDATE ON maintenance_schedules FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE maintenance_schedule_units (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id          uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  schedule_id         uuid NOT NULL REFERENCES maintenance_schedules(id) ON DELETE RESTRICT,
  unit_id             uuid NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
  last_service_value  numeric(14,2),
  next_due_value      numeric(14,2),
  next_due_at         timestamptz,
  reminder_sent_at    timestamptz,
  status              text NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled','due','completed','cancelled')),
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  deleted_at          timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX maintenance_schedule_units_uniq ON maintenance_schedule_units (schedule_id, unit_id) WHERE deleted_at IS NULL;
CREATE INDEX maintenance_schedule_units_company_status_idx ON maintenance_schedule_units (company_id, status);
CREATE INDEX maintenance_schedule_units_unit_idx ON maintenance_schedule_units (unit_id);
CREATE TRIGGER maintenance_schedule_units_set_updated_at BEFORE UPDATE ON maintenance_schedule_units FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE maintenance_records (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  schedule_unit_id  uuid REFERENCES maintenance_schedule_units(id) ON DELETE RESTRICT,
  unit_id           uuid NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
  status            text NOT NULL DEFAULT 'completed' CHECK (status IN ('completed','cancelled')),
  performed_at      timestamptz NOT NULL DEFAULT now(),
  invoice_no        text,
  vendor            text,
  cost              numeric(14,2),
  currency          text NOT NULL DEFAULT 'USD',
  odometer_m        bigint,
  engine_hours      numeric(12,2),
  invoice_key       text,
  dvir_pre_id       uuid REFERENCES dvir_reports(id) ON DELETE RESTRICT,
  dvir_post_id      uuid REFERENCES dvir_reports(id) ON DELETE RESTRICT,
  cancelled_reason  text,
  notes             text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX maintenance_records_company_time_idx ON maintenance_records (company_id, performed_at DESC);
CREATE INDEX maintenance_records_unit_time_idx    ON maintenance_records (unit_id, performed_at DESC);
CREATE INDEX maintenance_records_schedule_unit_idx ON maintenance_records (schedule_unit_id) WHERE schedule_unit_id IS NOT NULL;
CREATE TRIGGER maintenance_records_set_updated_at BEFORE UPDATE ON maintenance_records FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS maintenance_records;
DROP TABLE IF EXISTS maintenance_schedule_units;
DROP TABLE IF EXISTS maintenance_schedules;
DROP TABLE IF EXISTS dvir_reports;
DROP TABLE IF EXISTS defect_types;
-- +goose StatementEnd
