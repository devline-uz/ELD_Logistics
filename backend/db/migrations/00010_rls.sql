-- +goose Up
-- Ilova DB roli: NOLOGIN guruh roli. Haqiqiy login user (masalan `eld_app`)
-- shu rolga a'zo qilinadi va **superuser/BYPASSRLS BO'LMASLIGI SHART**.
-- +goose StatementBegin
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_role') THEN
    CREATE ROLE app_role NOLOGIN;
  END IF;
END;
$$;
-- +goose StatementEnd

-- Tenant jadvallari: company_id NOT NULL, faqat o'z kompaniyasi ko'rinadi.
-- +goose StatementBegin
DO $$
DECLARE
  t text;
  tenant_tables text[] := ARRAY[
    'hos_policy_versions','branches',
    'drivers','units','driver_pairs','signatures','eld_devices',
    'eld_device_assignments','unit_driver_assignments','trailers','shipping_documents',
    'daily_logs','duty_status_events','log_edit_requests','unidentified_events','violations',
    'telemetry','unit_last_state','trips','unit_region_distance_daily',
    'dvir_reports','maintenance_schedules','maintenance_schedule_units','maintenance_records',
    'routes','notifications','notification_settings',
    'support_tickets','ticket_messages','feedback','chat_messages','report_export_jobs'
  ];
BEGIN
  FOREACH t IN ARRAY tenant_tables LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', t);
    EXECUTE format($f$
      CREATE POLICY tenant_isolation ON %I
        USING (company_id = NULLIF(current_setting('app.company_id', true), '')::uuid)
        WITH CHECK (company_id = NULLIF(current_setting('app.company_id', true), '')::uuid)
    $f$, t);
  END LOOP;
END;
$$;
-- +goose StatementEnd

-- companies: o'z yozuvi (id bo'yicha).
-- +goose StatementBegin
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON companies
  USING (id = NULLIF(current_setting('app.company_id', true), '')::uuid)
  WITH CHECK (id = NULLIF(current_setting('app.company_id', true), '')::uuid);
-- +goose StatementEnd

-- users / sessions / invitations: super admin (company_id IS NULL) tenantga ko'rinmaydi.
-- +goose StatementBegin
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['users','sessions','invitations'] LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', t);
    EXECUTE format($f$
      CREATE POLICY tenant_isolation ON %I
        USING (company_id = NULLIF(current_setting('app.company_id', true), '')::uuid)
        WITH CHECK (company_id = NULLIF(current_setting('app.company_id', true), '')::uuid)
    $f$, t);
  END LOOP;
END;
$$;
-- +goose StatementEnd

-- roles / defect_types: company_id NULL = tizim shabloni -> hammaga O'QISH uchun ochiq,
-- lekin yozish faqat o'z company_id bilan.
-- +goose StatementBegin
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['roles','defect_types'] LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', t);
    EXECUTE format($f$
      CREATE POLICY tenant_isolation ON %I
        USING (company_id IS NULL OR company_id = NULLIF(current_setting('app.company_id', true), '')::uuid)
        WITH CHECK (company_id = NULLIF(current_setting('app.company_id', true), '')::uuid)
    $f$, t);
  END LOOP;
END;
$$;
-- +goose StatementEnd

-- role_permissions: company_id ustuni yo'q -> roles orqali.
-- +goose StatementBegin
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON role_permissions
  USING (EXISTS (SELECT 1 FROM roles r WHERE r.id = role_permissions.role_id))
  WITH CHECK (EXISTS (
    SELECT 1 FROM roles r
    WHERE r.id = role_permissions.role_id
      AND r.company_id = NULLIF(current_setting('app.company_id', true), '')::uuid));
-- +goose StatementEnd

-- audit_log: faqat o'z kompaniyasi; UPDATE/DELETE grant darajasida ham taqiqlanadi.
-- +goose StatementBegin
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON audit_log
  USING (company_id = NULLIF(current_setting('app.company_id', true), '')::uuid)
  WITH CHECK (company_id = NULLIF(current_setting('app.company_id', true), '')::uuid);
-- +goose StatementEnd

-- Grantlar.
-- +goose StatementBegin
GRANT USAGE ON SCHEMA public TO app_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO app_role;
-- +goose StatementEnd

-- audit_log — append-only (grant qatlami).
-- +goose StatementBegin
REVOKE UPDATE, DELETE, TRUNCATE ON audit_log FROM app_role;
-- +goose StatementEnd

-- Audit-muhim jadvallarda ilova DELETE qila olmaydi (faqat soft-delete/retention job).
-- +goose StatementBegin
REVOKE DELETE ON duty_status_events, daily_logs, violations, dvir_reports,
                 unidentified_events, log_edit_requests, telemetry, trips
  FROM app_role;
-- +goose StatementEnd

-- goose migratsiya jadvali ilovaga kerak emas.
-- +goose StatementBegin
DO $$
BEGIN
  IF to_regclass('public.goose_db_version') IS NOT NULL THEN
    EXECUTE 'REVOKE ALL ON goose_db_version FROM app_role';
  END IF;
END;
$$;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'companies','users','sessions','invitations','roles','role_permissions','defect_types','audit_log',
    'hos_policy_versions','branches','drivers','units','driver_pairs','signatures','eld_devices',
    'eld_device_assignments','unit_driver_assignments','trailers','shipping_documents',
    'daily_logs','duty_status_events','log_edit_requests','unidentified_events','violations',
    'telemetry','unit_last_state','trips','unit_region_distance_daily',
    'dvir_reports','maintenance_schedules','maintenance_schedule_units','maintenance_records',
    'routes','notifications','notification_settings',
    'support_tickets','ticket_messages','feedback','chat_messages','report_export_jobs'
  ] LOOP
    EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %I', t);
    EXECUTE format('ALTER TABLE %I NO FORCE ROW LEVEL SECURITY', t);
    EXECUTE format('ALTER TABLE %I DISABLE ROW LEVEL SECURITY', t);
  END LOOP;
END;
$$;
-- +goose StatementEnd
