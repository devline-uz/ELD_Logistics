-- +goose NO TRANSACTION
-- Continuous aggregate CREATE MATERIALIZED VIEW ... WITH (timescaledb.continuous)
-- tranzaksiya ichida bajarilmaydi -> butun migratsiya NO TRANSACTION.

-- +goose Up
-- +goose StatementBegin
CREATE TABLE telemetry (
  ts               timestamptz NOT NULL,
  company_id       uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  unit_id          uuid NOT NULL,
  eld_device_id    uuid,
  driver_id        uuid,
  lat              double precision,
  lng              double precision,
  speed_kmh        double precision,
  heading          double precision,
  odometer_m       bigint,
  engine_hours     numeric(12,2),
  fuel_pct         double precision,
  coolant_temp_c   double precision,
  coolant_level_pct double precision,
  oil_level_pct    double precision,
  battery_pct      double precision,
  ignition         boolean,
  source           text NOT NULL DEFAULT 'eld' CHECK (source IN ('eld','phone','simulator')),
  created_at       timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (unit_id, ts)
);
-- +goose StatementEnd

-- +goose StatementBegin
SELECT create_hypertable('telemetry', 'ts', chunk_time_interval => INTERVAL '1 day');
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX telemetry_unit_ts_idx    ON telemetry (unit_id, ts DESC);
-- +goose StatementEnd
-- +goose StatementBegin
CREATE INDEX telemetry_company_ts_idx ON telemetry (company_id, ts DESC);
-- +goose StatementEnd
-- +goose StatementBegin
CREATE INDEX telemetry_driver_ts_idx  ON telemetry (driver_id, ts DESC) WHERE driver_id IS NOT NULL;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE MATERIALIZED VIEW telemetry_1min
WITH (timescaledb.continuous) AS
SELECT
  time_bucket(INTERVAL '1 minute', ts) AS bucket,
  company_id,
  unit_id,
  avg(speed_kmh)          AS avg_speed_kmh,
  max(speed_kmh)          AS max_speed_kmh,
  last(lat, ts)           AS last_lat,
  last(lng, ts)           AS last_lng,
  last(heading, ts)       AS last_heading,
  max(odometer_m)         AS max_odometer_m,
  max(engine_hours)       AS max_engine_hours,
  last(fuel_pct, ts)      AS last_fuel_pct,
  count(*)                AS sample_count
FROM telemetry
GROUP BY bucket, company_id, unit_id
WITH NO DATA;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE MATERIALIZED VIEW telemetry_5min
WITH (timescaledb.continuous) AS
SELECT
  time_bucket(INTERVAL '5 minutes', ts) AS bucket,
  company_id,
  unit_id,
  avg(speed_kmh)          AS avg_speed_kmh,
  max(speed_kmh)          AS max_speed_kmh,
  last(lat, ts)           AS last_lat,
  last(lng, ts)           AS last_lng,
  last(heading, ts)       AS last_heading,
  max(odometer_m)         AS max_odometer_m,
  max(engine_hours)       AS max_engine_hours,
  last(fuel_pct, ts)      AS last_fuel_pct,
  count(*)                AS sample_count
FROM telemetry
GROUP BY bucket, company_id, unit_id
WITH NO DATA;
-- +goose StatementEnd

-- +goose StatementBegin
SELECT add_continuous_aggregate_policy('telemetry_1min',
  start_offset => INTERVAL '3 hours',
  end_offset   => INTERVAL '1 minute',
  schedule_interval => INTERVAL '1 minute');
-- +goose StatementEnd

-- +goose StatementBegin
SELECT add_continuous_aggregate_policy('telemetry_5min',
  start_offset => INTERVAL '1 day',
  end_offset   => INTERVAL '5 minutes',
  schedule_interval => INTERVAL '5 minutes');
-- +goose StatementEnd

-- Eslatma: continuous aggregate — VIEW, RLS unga to'g'ridan-to'g'ri qo'llanmaydi.
-- Ilova har cagg query'sida `company_id = $1` shartini MAJBURIY qo'yadi (db/queries/telemetry.sql).

-- +goose StatementBegin
CREATE TABLE unit_last_state (
  unit_id       uuid PRIMARY KEY REFERENCES units(id) ON DELETE RESTRICT,
  company_id    uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  ts            timestamptz,
  lat           double precision,
  lng           double precision,
  speed_kmh     double precision,
  heading       double precision,
  odometer_m    bigint,
  engine_hours  numeric(12,2),
  duty_status   text CHECK (duty_status IS NULL OR duty_status IN ('OFF','SB','DR','ON')),
  driver_id     uuid REFERENCES drivers(id) ON DELETE RESTRICT,
  online_status text NOT NULL DEFAULT 'offline' CHECK (online_status IN ('online','idle','offline')),
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX unit_last_state_company_idx ON unit_last_state (company_id, online_status);
-- +goose StatementEnd
-- +goose StatementBegin
CREATE TRIGGER unit_last_state_set_updated_at BEFORE UPDATE ON unit_last_state FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE trips (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id   uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  unit_id      uuid NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
  driver_id    uuid REFERENCES drivers(id) ON DELETE RESTRICT,
  start_at     timestamptz NOT NULL,
  end_at       timestamptz,
  start_lat    double precision,
  start_lng    double precision,
  end_lat      double precision,
  end_lng      double precision,
  distance_m   bigint NOT NULL DEFAULT 0,
  duration_sec integer,
  max_speed_kmh double precision,
  polyline_key text,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX trips_unit_start_idx    ON trips (unit_id, start_at DESC);
-- +goose StatementEnd
-- +goose StatementBegin
CREATE INDEX trips_company_start_idx ON trips (company_id, start_at DESC);
-- +goose StatementEnd
-- +goose StatementBegin
CREATE INDEX trips_driver_start_idx  ON trips (driver_id, start_at DESC) WHERE driver_id IS NOT NULL;
-- +goose StatementEnd
-- +goose StatementBegin
CREATE TRIGGER trips_set_updated_at BEFORE UPDATE ON trips FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- regions — global ma'lumotnoma (shtat/provinsiya chegaralari), tenantsiz, RLS yo'q.
-- +goose StatementBegin
CREATE TABLE regions (
  code       text PRIMARY KEY,
  name       text NOT NULL,
  country    text NOT NULL,
  geom       geometry(MultiPolygon, 4326),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX regions_geom_gix ON regions USING GIST (geom);
-- +goose StatementEnd
-- +goose StatementBegin
CREATE INDEX regions_country_idx ON regions (country);
-- +goose StatementEnd
-- +goose StatementBegin
CREATE TRIGGER regions_set_updated_at BEFORE UPDATE ON regions FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE unit_region_distance_daily (
  unit_id     uuid NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
  region_code text NOT NULL REFERENCES regions(code) ON DELETE RESTRICT,
  date        date NOT NULL,
  company_id  uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  distance_m  bigint NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (unit_id, region_code, date)
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX unit_region_distance_daily_company_date_idx ON unit_region_distance_daily (company_id, date);
-- +goose StatementEnd
-- +goose StatementBegin
CREATE TRIGGER unit_region_distance_daily_set_updated_at BEFORE UPDATE ON unit_region_distance_daily FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS unit_region_distance_daily;
-- +goose StatementEnd
-- +goose StatementBegin
DROP TABLE IF EXISTS regions;
-- +goose StatementEnd
-- +goose StatementBegin
DROP TABLE IF EXISTS trips;
-- +goose StatementEnd
-- +goose StatementBegin
DROP TABLE IF EXISTS unit_last_state;
-- +goose StatementEnd
-- +goose StatementBegin
DROP MATERIALIZED VIEW IF EXISTS telemetry_5min;
-- +goose StatementEnd
-- +goose StatementBegin
DROP MATERIALIZED VIEW IF EXISTS telemetry_1min;
-- +goose StatementEnd
-- +goose StatementBegin
DROP TABLE IF EXISTS telemetry;
-- +goose StatementEnd
