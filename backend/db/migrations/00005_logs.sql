-- +goose Up
-- +goose StatementBegin
CREATE TABLE daily_logs (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id           uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  driver_id            uuid NOT NULL REFERENCES drivers(id) ON DELETE RESTRICT,
  log_date             date NOT NULL,
  timezone             text NOT NULL DEFAULT 'America/Chicago',
  unit_ids             uuid[] NOT NULL DEFAULT '{}',
  co_driver_id         uuid REFERENCES drivers(id) ON DELETE RESTRICT,
  distance_m           bigint NOT NULL DEFAULT 0,
  trailer_ids          uuid[] NOT NULL DEFAULT '{}',
  shipping_doc_ids     uuid[] NOT NULL DEFAULT '{}',
  totals               jsonb NOT NULL DEFAULT '{"off":0,"sb":0,"dr":0,"on":0}'::jsonb,
  certification_status text NOT NULL DEFAULT 'uncertified' CHECK (certification_status IN ('uncertified','certified','needs_recertify')),
  signed_at            timestamptz,
  signature_key        text,
  signed_device_id     text,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX daily_logs_driver_date_uniq ON daily_logs (driver_id, log_date);
CREATE INDEX daily_logs_company_date_idx ON daily_logs (company_id, log_date DESC);
CREATE INDEX daily_logs_company_cert_idx ON daily_logs (company_id, certification_status);
CREATE TRIGGER daily_logs_set_updated_at BEFORE UPDATE ON daily_logs FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- duty_status_events — driver_id NULL = unidentified.
-- +goose StatementBegin
CREATE TABLE duty_status_events (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id       uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  driver_id        uuid REFERENCES drivers(id) ON DELETE RESTRICT,
  unit_id          uuid REFERENCES units(id) ON DELETE RESTRICT,
  eld_device_id    uuid REFERENCES eld_devices(id) ON DELETE RESTRICT,
  event_type       text NOT NULL CHECK (event_type IN (
                     'duty_status','intermediate','login','logout','power_on','power_off',
                     'engine_on','engine_off','malfunction','diagnostic','certification','yard_moves','personal_use')),
  status           text CHECK (status IS NULL OR status IN ('OFF','SB','DR','ON')),
  special          text NOT NULL DEFAULT 'none' CHECK (special IN ('none','pc','ym')),
  event_time       timestamptz NOT NULL,
  time_source      text NOT NULL DEFAULT 'server' CHECK (time_source IN ('eld_rtc','server','phone')),
  time_unverified  boolean NOT NULL DEFAULT false,
  clock_skew_sec   integer NOT NULL DEFAULT 0,
  origin           text NOT NULL DEFAULT 'auto' CHECK (origin IN ('auto','driver','driver_edit','admin_edit','assigned')),
  lat              double precision,
  lng              double precision,
  location_text    text,
  gps_accuracy_m   integer,
  odometer_m       bigint,
  engine_hours     numeric(12,2),
  notes            text,
  trailer_ids      uuid[] NOT NULL DEFAULT '{}',
  shipping_doc_ids uuid[] NOT NULL DEFAULT '{}',
  client_event_id  uuid NOT NULL,
  device_seq       bigint,
  received_at      timestamptz NOT NULL DEFAULT now(),
  superseded_by    uuid REFERENCES duty_status_events(id) ON DELETE RESTRICT,
  locked           boolean NOT NULL DEFAULT false,
  daily_log_id     uuid REFERENCES daily_logs(id) ON DELETE RESTRICT,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX duty_status_events_client_event_uniq ON duty_status_events (client_event_id);
CREATE INDEX duty_status_events_driver_time_idx  ON duty_status_events (driver_id, event_time);
CREATE INDEX duty_status_events_unit_time_idx    ON duty_status_events (unit_id, event_time);
CREATE INDEX duty_status_events_company_time_idx ON duty_status_events (company_id, event_time);
CREATE INDEX duty_status_events_daily_log_idx    ON duty_status_events (daily_log_id) WHERE daily_log_id IS NOT NULL;
CREATE INDEX duty_status_events_unidentified_idx ON duty_status_events (company_id, event_time) WHERE driver_id IS NULL;
CREATE TRIGGER duty_status_events_set_updated_at BEFORE UPDATE ON duty_status_events FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE log_edit_requests (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id   uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  driver_id    uuid NOT NULL REFERENCES drivers(id) ON DELETE RESTRICT,
  daily_log_id uuid NOT NULL REFERENCES daily_logs(id) ON DELETE RESTRICT,
  requested_by uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  status       text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
  changes      jsonb NOT NULL DEFAULT '[]'::jsonb,
  driver_note  text,
  resolved_by  uuid REFERENCES users(id) ON DELETE RESTRICT,
  resolved_at  timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX log_edit_requests_company_status_idx ON log_edit_requests (company_id, status, created_at DESC);
CREATE INDEX log_edit_requests_driver_idx    ON log_edit_requests (driver_id, created_at DESC);
CREATE INDEX log_edit_requests_daily_log_idx ON log_edit_requests (daily_log_id);
CREATE TRIGGER log_edit_requests_set_updated_at BEFORE UPDATE ON log_edit_requests FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE unidentified_events (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id         uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  unit_id            uuid NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
  eld_device_id      uuid REFERENCES eld_devices(id) ON DELETE RESTRICT,
  start_at           timestamptz NOT NULL,
  end_at             timestamptz,
  distance_m         bigint NOT NULL DEFAULT 0,
  track_key          text,
  status             text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','assigned','annotated')),
  assigned_driver_id uuid REFERENCES drivers(id) ON DELETE RESTRICT,
  annotation         text,
  resolved_by        uuid REFERENCES users(id) ON DELETE RESTRICT,
  resolved_at        timestamptz,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX unidentified_events_company_status_idx ON unidentified_events (company_id, status, start_at DESC);
CREATE INDEX unidentified_events_unit_idx ON unidentified_events (unit_id, start_at DESC);
CREATE TRIGGER unidentified_events_set_updated_at BEFORE UPDATE ON unidentified_events FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE violations (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  driver_id         uuid NOT NULL REFERENCES drivers(id) ON DELETE RESTRICT,
  unit_id           uuid REFERENCES units(id) ON DELETE RESTRICT,
  daily_log_id      uuid REFERENCES daily_logs(id) ON DELETE RESTRICT,
  type              text NOT NULL CHECK (type IN (
                      'driving_11h','duty_14h','cycle_60h','cycle_70h','break_30m',
                      'sb_split','restart_34h','form_manner','missing_certification','unassigned_driving')),
  severity          text NOT NULL DEFAULT 'warning' CHECK (severity IN ('info','warning','critical')),
  occurred_at       timestamptz NOT NULL,
  details           jsonb NOT NULL DEFAULT '{}'::jsonb,
  policy_version_id uuid REFERENCES hos_policy_versions(id) ON DELETE RESTRICT,
  resolved_at       timestamptz,
  resolved_reason   text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX violations_company_driver_time_idx ON violations (company_id, driver_id, occurred_at DESC);
CREATE INDEX violations_company_type_idx ON violations (company_id, type, occurred_at DESC);
CREATE INDEX violations_daily_log_idx ON violations (daily_log_id) WHERE daily_log_id IS NOT NULL;
CREATE TRIGGER violations_set_updated_at BEFORE UPDATE ON violations FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS violations;
DROP TABLE IF EXISTS unidentified_events;
DROP TABLE IF EXISTS log_edit_requests;
DROP TABLE IF EXISTS duty_status_events;
DROP TABLE IF EXISTS daily_logs;
-- +goose StatementEnd
