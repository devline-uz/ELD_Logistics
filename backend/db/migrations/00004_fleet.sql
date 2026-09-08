-- +goose Up
-- +goose StatementBegin
CREATE TABLE drivers (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id       uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  user_id          uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  branch_id        uuid REFERENCES branches(id) ON DELETE RESTRICT,
  license_no_enc   text,
  license_region   text,
  home_terminal    text,
  city             text,
  state            text,
  zip              text,
  address1         text,
  address2         text,
  notes            text,
  fleet_manager_id uuid REFERENCES users(id) ON DELETE RESTRICT,
  default_unit_id  uuid,
  status           text NOT NULL DEFAULT 'active' CHECK (status IN ('invited','active','inactive')),
  app_version      text,
  activated_on     timestamptz,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),
  deleted_at       timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX drivers_user_uniq ON drivers (user_id) WHERE deleted_at IS NULL;
CREATE INDEX drivers_company_idx ON drivers (company_id) WHERE deleted_at IS NULL;
CREATE INDEX drivers_company_status_idx ON drivers (company_id, status) WHERE deleted_at IS NULL;
CREATE INDEX drivers_fleet_manager_idx ON drivers (fleet_manager_id) WHERE fleet_manager_id IS NOT NULL;
CREATE TRIGGER drivers_set_updated_at BEFORE UPDATE ON drivers FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE units (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id    uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  branch_id     uuid REFERENCES branches(id) ON DELETE RESTRICT,
  unit_number   text NOT NULL,
  make          text,
  model         text,
  year          integer CHECK (year IS NULL OR (year BETWEEN 1900 AND 2100)),
  vin           text,
  license_plate text,
  plate_region  text,
  fuel_type     text,
  sleeper_berth boolean NOT NULL DEFAULT false,
  gvwr_class    text,
  status        text NOT NULL DEFAULT 'active' CHECK (status IN ('active','inactive')),
  out_of_service boolean NOT NULL DEFAULT false,
  notes         text,
  activated_on  timestamptz,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  deleted_at    timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX units_company_number_uniq ON units (company_id, lower(unit_number)) WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX units_company_vin_uniq    ON units (company_id, upper(vin)) WHERE deleted_at IS NULL AND vin IS NOT NULL;
CREATE INDEX units_company_idx ON units (company_id) WHERE deleted_at IS NULL;
CREATE INDEX units_company_status_idx ON units (company_id, status) WHERE deleted_at IS NULL;
CREATE TRIGGER units_set_updated_at BEFORE UPDATE ON units FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE drivers ADD CONSTRAINT drivers_default_unit_fk FOREIGN KEY (default_unit_id) REFERENCES units(id) ON DELETE RESTRICT;
-- +goose StatementEnd

-- driver_pairs — co-driver, simmetrik juftlik (kanonik: driver_a_id < driver_b_id).
-- +goose StatementBegin
CREATE TABLE driver_pairs (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id  uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  driver_a_id uuid NOT NULL REFERENCES drivers(id) ON DELETE RESTRICT,
  driver_b_id uuid NOT NULL REFERENCES drivers(id) ON DELETE RESTRICT,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  deleted_at  timestamptz,
  CONSTRAINT driver_pairs_canonical_ck CHECK (driver_a_id < driver_b_id)
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX driver_pairs_uniq ON driver_pairs (driver_a_id, driver_b_id) WHERE deleted_at IS NULL;
CREATE INDEX driver_pairs_company_idx ON driver_pairs (company_id) WHERE deleted_at IS NULL;
CREATE INDEX driver_pairs_b_idx ON driver_pairs (driver_b_id);
CREATE TRIGGER driver_pairs_set_updated_at BEFORE UPDATE ON driver_pairs FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE signatures (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id    uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  user_id       uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  image_key_enc text NOT NULL,
  is_default    boolean NOT NULL DEFAULT false,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  deleted_at    timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX signatures_user_idx ON signatures (user_id) WHERE deleted_at IS NULL;
CREATE INDEX signatures_company_idx ON signatures (company_id) WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX signatures_user_default_uniq ON signatures (user_id) WHERE is_default AND deleted_at IS NULL;
CREATE TRIGGER signatures_set_updated_at BEFORE UPDATE ON signatures FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE eld_devices (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id       uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  unit_id          uuid REFERENCES units(id) ON DELETE RESTRICT,
  vendor           text NOT NULL,
  model            text,
  serial           text NOT NULL,
  firmware         text,
  connection_type  text CHECK (connection_type IS NULL OR connection_type IN ('bluetooth','wifi','cellular','usb')),
  sim_present      boolean NOT NULL DEFAULT false,
  last_seen_at     timestamptz,
  malfunction_codes text[] NOT NULL DEFAULT '{}',
  status           text NOT NULL DEFAULT 'active' CHECK (status IN ('active','inactive','malfunction')),
  notes            text,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),
  deleted_at       timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX eld_devices_company_serial_uniq ON eld_devices (company_id, upper(serial)) WHERE deleted_at IS NULL;
CREATE INDEX eld_devices_company_idx ON eld_devices (company_id) WHERE deleted_at IS NULL;
CREATE INDEX eld_devices_unit_idx ON eld_devices (unit_id) WHERE unit_id IS NOT NULL AND deleted_at IS NULL;
CREATE TRIGGER eld_devices_set_updated_at BEFORE UPDATE ON eld_devices FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE eld_device_assignments (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id    uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  eld_device_id uuid NOT NULL REFERENCES eld_devices(id) ON DELETE RESTRICT,
  unit_id       uuid NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
  from_at       timestamptz NOT NULL DEFAULT now(),
  to_at         timestamptz,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX eld_device_assignments_device_idx ON eld_device_assignments (eld_device_id, from_at DESC);
CREATE INDEX eld_device_assignments_unit_idx   ON eld_device_assignments (unit_id, from_at DESC);
CREATE INDEX eld_device_assignments_company_idx ON eld_device_assignments (company_id);
CREATE UNIQUE INDEX eld_device_assignments_open_uniq ON eld_device_assignments (eld_device_id) WHERE to_at IS NULL;
CREATE TRIGGER eld_device_assignments_set_updated_at BEFORE UPDATE ON eld_device_assignments FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE unit_driver_assignments (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id    uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  unit_id       uuid NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
  driver_id     uuid NOT NULL REFERENCES drivers(id) ON DELETE RESTRICT,
  role          text NOT NULL DEFAULT 'primary' CHECK (role IN ('primary','co')),
  assigned_at   timestamptz NOT NULL DEFAULT now(),
  unassigned_at timestamptz,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX unit_driver_assignments_unit_idx   ON unit_driver_assignments (unit_id, assigned_at DESC);
CREATE INDEX unit_driver_assignments_driver_idx ON unit_driver_assignments (driver_id, assigned_at DESC);
CREATE INDEX unit_driver_assignments_company_idx ON unit_driver_assignments (company_id);
CREATE UNIQUE INDEX unit_driver_assignments_open_uniq ON unit_driver_assignments (unit_id, role) WHERE unassigned_at IS NULL;
CREATE TRIGGER unit_driver_assignments_set_updated_at BEFORE UPDATE ON unit_driver_assignments FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE trailers (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  number     text NOT NULL,
  notes      text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX trailers_company_number_uniq ON trailers (company_id, lower(number)) WHERE deleted_at IS NULL;
CREATE INDEX trailers_company_idx ON trailers (company_id) WHERE deleted_at IS NULL;
CREATE TRIGGER trailers_set_updated_at BEFORE UPDATE ON trailers FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE shipping_documents (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  number     text NOT NULL,
  notes      text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX shipping_documents_company_number_uniq ON shipping_documents (company_id, lower(number)) WHERE deleted_at IS NULL;
CREATE INDEX shipping_documents_company_idx ON shipping_documents (company_id) WHERE deleted_at IS NULL;
CREATE TRIGGER shipping_documents_set_updated_at BEFORE UPDATE ON shipping_documents FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS shipping_documents;
DROP TABLE IF EXISTS trailers;
DROP TABLE IF EXISTS unit_driver_assignments;
DROP TABLE IF EXISTS eld_device_assignments;
DROP TABLE IF EXISTS eld_devices;
DROP TABLE IF EXISTS signatures;
DROP TABLE IF EXISTS driver_pairs;
ALTER TABLE drivers DROP CONSTRAINT IF EXISTS drivers_default_unit_fk;
DROP TABLE IF EXISTS units;
DROP TABLE IF EXISTS drivers;
-- +goose StatementEnd
