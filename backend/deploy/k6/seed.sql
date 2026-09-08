-- seed.sql — realistic-scale fixture for the k6 NFR run (TZ B§21, 9-bosqich
-- 3-qism item 3). Idempotent: running it twice is a no-op once the fixed
-- company id below exists.
--
--   docker exec -i eld-test-pg psql -U postgres -d eld_test < deploy/k6/seed.sql
--
-- Seeds one company with a realistic row count for every list endpoint k6
-- hits (deploy/k6/smoke.js LIST_ENDPOINTS) plus daily_logs for the
-- /reports/uncertified-logs report scenario. It intentionally does NOT seed
-- telemetry / unit_region_distance_daily (TimescaleDB hypertable + PostGIS
-- regions): /reports/activity and /reports/distance-by-region are therefore
-- measured against a near-empty dataset in this pass — see the task report.
--
-- Login: username "k6admin", password "Load-Test-Passw0rd!". The role is
-- "Sub Admin", not "Administrator": internal/auth.TOTPRequiredForRole forces
-- a restricted, permission-less totp_setup token on Administrator/Super Admin
-- logins that have not enrolled in 2FA, which would 403 every list call. Sub
-- Admin holds every permission_keys entry except the five admin_excl ones
-- (00012_seed.sql) — company.update/hos_policy.update/roles.*/users.delete —
-- none of which the k6 scripts exercise, and is not TOTP-gated. The password
-- hash below is a real Argon2id hash of that password
-- (internal/auth.HashPassword), not a fixture placeholder: k6 logs in through
-- the real /auth/login endpoint, so a fixture's "$argon2id$test$fixture"
-- string would not verify.
DO $$
DECLARE
  v_company_id  uuid := '11111111-1111-1111-1111-111111111111';
  v_branch_id   uuid;
  v_login_role  uuid;
  v_driver_role uuid;
  v_admin_hash  text := '$argon2id$v=19$m=65536,t=3,p=4$MI28VVsvOIdx6sU9B7bg5Q$57cvZtdWHADkw3mmHm4w5DyMVgbfsxP8qTVq73rUhPY';
  v_units       int := 3000;
  v_trailers    int := 1500;
  v_docs        int := 1500;
  v_office      int := 300;
  v_drivers     int := 1200;
  v_dvir        int := 3000;
  v_violations  int := 3000;
  v_notif       int := 3000;
  v_routes      int := 1000;
  v_tickets     int := 1000;
  v_schedules   int := 300;
  v_log_days    int := 10;
BEGIN
  IF EXISTS (SELECT 1 FROM companies WHERE id = v_company_id) THEN
    RAISE NOTICE 'k6 load company already seeded (%), skipping', v_company_id;
    RETURN;
  END IF;

  SELECT id INTO v_login_role  FROM roles WHERE company_id IS NULL AND is_system AND name = 'Sub Admin';
  SELECT id INTO v_driver_role FROM roles WHERE company_id IS NULL AND is_system AND name = 'Driver';

  INSERT INTO companies (id, name, timezone)
  VALUES (v_company_id, 'K6 Load Test Co', 'America/Chicago');

  INSERT INTO branches (id, company_id, name, timezone)
  VALUES (gen_random_uuid(), v_company_id, 'Main Terminal', 'America/Chicago')
  RETURNING id INTO v_branch_id;

  INSERT INTO users (id, company_id, branch_id, first_name, last_name, email, username, password_hash, role_id, status)
  VALUES (gen_random_uuid(), v_company_id, v_branch_id, 'K6', 'Admin', 'k6admin@example.test', 'k6admin', v_admin_hash, v_login_role, 'active');

  -- Office staff (also list-page fodder for GET /users). Sub Admin, same
  -- reasoning as k6admin above: office1..officeN are the pool list_p95.js
  -- logs in as to spread load across distinct per-user rate limit buckets
  -- (see the Q-note on RATE_LIMITED in the task report) — an Administrator
  -- role here would hand every one of them a permission-less totp_setup
  -- token instead of a usable session.
  INSERT INTO users (id, company_id, branch_id, first_name, last_name, email, username, password_hash, role_id, status)
  SELECT gen_random_uuid(), v_company_id, v_branch_id, 'Office', 'User' || i,
         'office' || i || '@example.test', 'office' || i, v_admin_hash, v_login_role, 'active'
  FROM generate_series(1, v_office) i;

  -- Units.
  INSERT INTO units (id, company_id, branch_id, unit_number, make, model, year, vin, license_plate, plate_region, fuel_type, status)
  SELECT gen_random_uuid(), v_company_id, v_branch_id, 'K6-UNIT-' || i, 'Freightliner', 'Cascadia', 2022,
         'VIN' || lpad(i::text, 14, '0'), 'PLT' || i, 'TX', 'Diesel', 'active'
  FROM generate_series(1, v_units) i;

  -- Trailers / shipping documents.
  INSERT INTO trailers (id, company_id, number)
  SELECT gen_random_uuid(), v_company_id, 'TRL-' || i FROM generate_series(1, v_trailers) i;

  INSERT INTO shipping_documents (id, company_id, number)
  SELECT gen_random_uuid(), v_company_id, 'BOL-' || i FROM generate_series(1, v_docs) i;

  -- One ELD device per unit.
  INSERT INTO eld_devices (id, company_id, unit_id, vendor, serial, status)
  SELECT gen_random_uuid(), v_company_id, id, 'ONEBOOK', 'SN-' || row_number() OVER (), 'active'
  FROM units WHERE company_id = v_company_id;

  -- Drivers, each with its own user (Driver system role).
  WITH new_users AS (
    INSERT INTO users (id, company_id, branch_id, first_name, last_name, email, username, password_hash, role_id, status)
    SELECT gen_random_uuid(), v_company_id, v_branch_id, 'Driver', 'User' || i,
           'driver' || i || '@example.test', 'driver' || i, v_admin_hash, v_driver_role, 'active'
    FROM generate_series(1, v_drivers) i
    RETURNING id
  )
  INSERT INTO drivers (id, company_id, user_id, branch_id, status)
  SELECT gen_random_uuid(), v_company_id, id, v_branch_id, 'active' FROM new_users;

  -- DVIR reports, violations, routes, support tickets: pick a unit/driver by
  -- array index instead of ORDER BY random(), which would re-sort per row.
  WITH u AS (SELECT array_agg(id) ids FROM units WHERE company_id = v_company_id),
       d AS (SELECT array_agg(id) ids FROM drivers WHERE company_id = v_company_id)
  INSERT INTO dvir_reports (id, company_id, unit_id, driver_id, type, status, performed_at)
  SELECT gen_random_uuid(), v_company_id,
         u.ids[1 + (gs.i % array_length(u.ids, 1))],
         d.ids[1 + (gs.i % array_length(d.ids, 1))],
         CASE WHEN gs.i % 2 = 0 THEN 'pre_trip' ELSE 'post_trip' END,
         'submitted_no_defects', now() - (gs.i || ' minutes')::interval
  FROM generate_series(1, v_dvir) gs(i), u, d;

  WITH u AS (SELECT array_agg(id) ids FROM units WHERE company_id = v_company_id),
       d AS (SELECT array_agg(id) ids FROM drivers WHERE company_id = v_company_id)
  INSERT INTO violations (id, company_id, driver_id, unit_id, type, severity, occurred_at)
  SELECT gen_random_uuid(), v_company_id,
         d.ids[1 + (gs.i % array_length(d.ids, 1))],
         u.ids[1 + (gs.i % array_length(u.ids, 1))],
         'drive_limit', 'warning', now() - (gs.i || ' minutes')::interval
  FROM generate_series(1, v_violations) gs(i), u, d;

  WITH usr AS (SELECT array_agg(id) ids FROM users WHERE company_id = v_company_id)
  INSERT INTO notifications (id, company_id, user_id, alert_type, title, body)
  SELECT gen_random_uuid(), v_company_id,
         usr.ids[1 + (gs.i % array_length(usr.ids, 1))],
         'general', 'Load test notification ' || gs.i, 'k6 seed row'
  FROM generate_series(1, v_notif) gs(i), usr;

  WITH u AS (SELECT array_agg(id) ids FROM units WHERE company_id = v_company_id),
       d AS (SELECT array_agg(id) ids FROM drivers WHERE company_id = v_company_id)
  INSERT INTO routes (id, company_id, unit_id, driver_id, sequence, origin_text, dest_text, status)
  SELECT gen_random_uuid(), v_company_id,
         u.ids[1 + (gs.i % array_length(u.ids, 1))],
         d.ids[1 + (gs.i % array_length(d.ids, 1))],
         1, 'Dallas, TX', 'Houston, TX', 'ongoing'
  FROM generate_series(1, v_routes) gs(i), u, d;

  WITH d AS (SELECT array_agg(id) ids FROM drivers WHERE company_id = v_company_id)
  INSERT INTO support_tickets (id, company_id, driver_id, subject, status)
  SELECT gen_random_uuid(), v_company_id,
         d.ids[1 + (gs.i % array_length(d.ids, 1))],
         'Load test ticket ' || gs.i, 'new'
  FROM generate_series(1, v_tickets) gs(i), d;

  INSERT INTO maintenance_schedules (id, company_id, name, type, interval_value, interval_unit)
  SELECT gen_random_uuid(), v_company_id, 'Oil change ' || i, 'preventive', 5000, 'mi'
  FROM generate_series(1, v_schedules) i;

  -- daily_logs: the source of GET /reports/uncertified-logs. One row per
  -- driver per day for the last v_log_days days, half left uncertified.
  INSERT INTO daily_logs (id, company_id, driver_id, log_date, certification_status)
  SELECT gen_random_uuid(), v_company_id, dr.id, (current_date - day),
         CASE WHEN (day + hashtext(dr.id::text)) % 2 = 0 THEN 'certified' ELSE 'uncertified' END
  FROM drivers dr
  CROSS JOIN generate_series(0, v_log_days - 1) day
  WHERE dr.company_id = v_company_id;

  RAISE NOTICE 'k6 load company % seeded: % units, % drivers, % office users, % dvir, % violations, % notifications, % routes, % tickets, % daily_logs',
    v_company_id, v_units, v_drivers, v_office, v_dvir, v_violations, v_notif, v_routes, v_tickets, (v_drivers * v_log_days);
END $$;
