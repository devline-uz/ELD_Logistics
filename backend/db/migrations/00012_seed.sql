-- +goose Up

-- ---------------------------------------------------------------- system_settings
-- +goose StatementBegin
INSERT INTO system_settings (key, value, description) VALUES
  ('certification_window_days', '8'::jsonb,        'Sertifikatsiya oynasi (kun) — TZ A§16'),
  ('log_retention_years',       '3'::jsonb,        'Log/DVIR/violations/audit saqlash muddati (yil)'),
  ('telemetry_retention_days',  '90'::jsonb,       'Xom telemetriya saqlash muddati (kun)'),
  ('chat_retention_days',       '365'::jsonb,      'chat_messages saqlash muddati (kun)'),
  ('region_distance_retention_years', '5'::jsonb,  'unit_region_distance_daily saqlash muddati (yil)'),
  ('access_token_ttl_min',      '15'::jsonb,       'Access JWT muddati (daqiqa)'),
  ('refresh_ttl_days_driver',   '30'::jsonb,       'Driver refresh muddati (kun, sliding)'),
  ('refresh_ttl_days_admin',    '7'::jsonb,        'Admin refresh muddati (kun)'),
  ('invitation_ttl_hours',      '72'::jsonb,       'Invitation havolasi muddati (soat)'),
  ('subscription_grace_days',   '7'::jsonb,        'Obuna tugagach grace davri (kun)'),
  ('lockout_minutes',           '15'::jsonb,       'Brute-force lockout (daqiqa)'),
  ('max_failed_logins',         '10'::jsonb,       'Soatiga maksimal muvaffaqiyatsiz login')
ON CONFLICT (key) DO NOTHING;
-- +goose StatementEnd

-- ---------------------------------------------------------------- permission kalitlari (TZ A§16 Q82)
-- Manba-haqiqat — `internal/auth/permissions.go` const bloki; bu yerda `GET /permissions`
-- uchun ro'yxat saqlanadi.
-- +goose StatementBegin
INSERT INTO system_settings (key, value, description)
VALUES ('permission_keys', to_jsonb(ARRAY[
  'company.read','company.update','company.history.view',
  'branches.read','branches.create','branches.update','branches.delete',
  'hos_policy.read','hos_policy.update',
  'notification_settings.read','notification_settings.update',
  'users.read','users.create','users.update','users.delete','users.invite','users.reset_password',
  'roles.read','roles.create','roles.update','roles.delete','permissions.read',
  'units.read','units.create','units.update','units.delete','units.activate','units.deactivate',
  'units.assign_driver','units.import','units.export','units.diagnostics',
  'drivers.read','drivers.create','drivers.update','drivers.delete','drivers.activate','drivers.deactivate',
  'drivers.import','drivers.export','drivers.manage_co_drivers',
  'eld_devices.read','eld_devices.create','eld_devices.update','eld_devices.delete','eld_devices.assign_unit',
  'trailers.read','trailers.create','trailers.update','trailers.delete',
  'shipping_documents.read','shipping_documents.create','shipping_documents.update','shipping_documents.delete',
  'logs.read','logs.certify','logs.propose_edit','logs.approve_edit','logs.reject_edit','logs.add_event','logs.export',
  'logs.assign_unidentified','logs.annotate_unidentified','logs.claim_unidentified',
  'inspection.view','inspection.email','inspection.transfer',
  'violations.read',
  'tracking.read','tracking.history','trips.read',
  'routes.read','routes.create','routes.update','routes.delete','routes.complete',
  'dvir.read','dvir.create','dvir.repair','dvir.certify','dvir.export',
  'defect_types.read','defect_types.create','defect_types.update',
  'maintenance.read','maintenance.create','maintenance.update','maintenance.delete','maintenance.complete','maintenance.cancel',
  'reports.read','reports.export',
  'dashboard.read',
  'notifications.read',
  'chat.read','chat.send',
  'support.read','support.create','support.update',
  'feedback.read','feedback.create',
  'files.upload',
  'audit.view'
]), 'RBAC permission kalitlari to''liq ro''yxati (GET /permissions)')
ON CONFLICT (key) DO NOTHING;
-- +goose StatementEnd

-- ---------------------------------------------------------------- default rollar (company_id NULL = tizim shabloni)
-- +goose StatementBegin
INSERT INTO roles (company_id, name, description, scope, is_system) VALUES
  (NULL, 'Administrator',   'Kompaniyaning to''liq huquqli administratori', 'company', true),
  (NULL, 'Sub Admin',       'Cheklangan administrator',                    'company', true),
  (NULL, 'Fleet Manager',   'Avtopark va haydovchilar boshqaruvi',         'company', true),
  (NULL, 'Dispatcher',      'Reyslar, kuzatuv, aloqa',                     'company', true),
  (NULL, 'Service Manager', 'DVIR va texnik xizmat',                       'company', true),
  (NULL, 'Safety Manager',  'HOS loglari, buzilishlar, audit',             'company', true),
  (NULL, 'Data Analyst',    'Faqat o''qish + hisobot eksporti',            'company', true),
  (NULL, 'Driver',          'Mobil ilova haydovchisi',                     'self',    true)
ON CONFLICT DO NOTHING;
-- +goose StatementEnd

-- +goose StatementBegin
DO $$
DECLARE
  all_keys text[];
  admin_excl text[] := ARRAY['company.update','hos_policy.update','roles.create','roles.update','roles.delete','users.delete'];
  fleet text[] := ARRAY[
    'company.read','branches.read','dashboard.read','notifications.read','files.upload','permissions.read',
    'units.read','units.create','units.update','units.delete','units.activate','units.deactivate','units.assign_driver','units.import','units.export','units.diagnostics',
    'drivers.read','drivers.create','drivers.update','drivers.delete','drivers.activate','drivers.deactivate','drivers.import','drivers.export','drivers.manage_co_drivers',
    'eld_devices.read','eld_devices.create','eld_devices.update','eld_devices.delete','eld_devices.assign_unit',
    'trailers.read','trailers.create','trailers.update','trailers.delete',
    'shipping_documents.read','shipping_documents.create','shipping_documents.update','shipping_documents.delete',
    'logs.read','logs.approve_edit','logs.reject_edit','logs.add_event','logs.export','logs.assign_unidentified','logs.annotate_unidentified',
    'violations.read','tracking.read','tracking.history','trips.read',
    'routes.read','routes.create','routes.update','routes.delete','routes.complete',
    'dvir.read','dvir.export','defect_types.read',
    'maintenance.read','maintenance.create','maintenance.update','maintenance.delete','maintenance.complete','maintenance.cancel',
    'reports.read','reports.export','chat.read','chat.send','support.read','support.create','feedback.read'];
  dispatcher text[] := ARRAY[
    'company.read','branches.read','dashboard.read','notifications.read','files.upload',
    'units.read','drivers.read','eld_devices.read','trailers.read','shipping_documents.read',
    'logs.read','violations.read','tracking.read','tracking.history','trips.read',
    'routes.read','routes.create','routes.update','routes.delete','routes.complete',
    'dvir.read','maintenance.read','reports.read','chat.read','chat.send','support.read','support.create'];
  service text[] := ARRAY[
    'company.read','branches.read','dashboard.read','notifications.read','files.upload',
    'units.read','units.update','units.diagnostics','drivers.read','eld_devices.read','eld_devices.update','trailers.read',
    'dvir.read','dvir.repair','dvir.export','defect_types.read','defect_types.create','defect_types.update',
    'maintenance.read','maintenance.create','maintenance.update','maintenance.delete','maintenance.complete','maintenance.cancel',
    'reports.read','reports.export','chat.read','chat.send','support.read','support.create'];
  safety text[] := ARRAY[
    'company.read','company.history.view','branches.read','dashboard.read','notifications.read','files.upload',
    'hos_policy.read','units.read','drivers.read','eld_devices.read','trailers.read','shipping_documents.read',
    'logs.read','logs.approve_edit','logs.reject_edit','logs.add_event','logs.export',
    'logs.assign_unidentified','logs.annotate_unidentified',
    'inspection.view','inspection.email','inspection.transfer',
    'violations.read','tracking.read','tracking.history','trips.read','routes.read',
    'dvir.read','dvir.export','maintenance.read','reports.read','reports.export','audit.view','chat.read','chat.send'];
  analyst text[] := ARRAY[
    'company.read','branches.read','dashboard.read','notifications.read',
    'units.read','drivers.read','eld_devices.read','trailers.read','shipping_documents.read',
    'logs.read','violations.read','tracking.read','tracking.history','trips.read','routes.read',
    'dvir.read','defect_types.read','maintenance.read','reports.read','reports.export','feedback.read'];
  driver text[] := ARRAY[
    'company.read','notifications.read','files.upload',
    'units.read','trailers.read','shipping_documents.read','drivers.read',
    'logs.read','logs.certify','logs.propose_edit','logs.claim_unidentified',
    'inspection.view','inspection.email','inspection.transfer',
    'violations.read','routes.read','routes.complete',
    'dvir.read','dvir.create','dvir.certify','defect_types.read',
    'chat.read','chat.send','support.read','support.create','feedback.create'];
BEGIN
  SELECT array_agg(k) INTO all_keys
  FROM jsonb_array_elements_text((SELECT value FROM system_settings WHERE key = 'permission_keys')) AS k;

  INSERT INTO role_permissions (role_id, permission_key)
  SELECT r.id, k
  FROM roles r
  CROSS JOIN LATERAL unnest(
    CASE r.name
      WHEN 'Administrator'   THEN all_keys
      WHEN 'Sub Admin'       THEN ARRAY(SELECT unnest(all_keys) EXCEPT SELECT unnest(admin_excl))
      WHEN 'Fleet Manager'   THEN fleet
      WHEN 'Dispatcher'      THEN dispatcher
      WHEN 'Service Manager' THEN service
      WHEN 'Safety Manager'  THEN safety
      WHEN 'Data Analyst'    THEN analyst
      WHEN 'Driver'          THEN driver
    END
  ) AS k
  WHERE r.company_id IS NULL AND r.is_system
  ON CONFLICT DO NOTHING;
END;
$$;
-- +goose StatementEnd

-- ---------------------------------------------------------------- default defect_types (company_id NULL)
-- +goose StatementBegin
INSERT INTO defect_types (company_id, name, category, is_critical, sort_order)
SELECT NULL, v.name, v.category, v.is_critical, v.sort_order
FROM (VALUES
  -- ---- truck / tractor (FMCSA 49 CFR 396.11)
  ('Air Compressor',                      'truck',   false,  1),
  ('Air Lines',                           'truck',   true,   2),
  ('Battery',                             'truck',   false,  3),
  ('Belts and Hoses',                     'truck',   false,  4),
  ('Body',                                'truck',   false,  5),
  ('Brake Accessories',                   'truck',   true,   6),
  ('Brakes (Parking)',                    'truck',   true,   7),
  ('Brakes (Service)',                    'truck',   true,   8),
  ('Clutch',                              'truck',   false,  9),
  ('Coupling Devices',                    'truck',   true,  10),
  ('Defroster / Heater',                  'truck',   false, 11),
  ('Drive Line',                          'truck',   false, 12),
  ('Driver Seat / Seat Belt',             'truck',   true,  13),
  ('Engine',                              'truck',   false, 14),
  ('Exhaust',                             'truck',   true,  15),
  ('Fifth Wheel',                         'truck',   true,  16),
  ('Fluid Levels',                        'truck',   false, 17),
  ('Frame and Assembly',                  'truck',   true,  18),
  ('Front Axle',                          'truck',   true,  19),
  ('Fuel Tanks',                          'truck',   true,  20),
  ('Horn',                                'truck',   false, 21),
  ('Lights (Head / Stop)',                'truck',   true,  22),
  ('Lights (Tail / Dash)',                'truck',   true,  23),
  ('Lights (Turn Indicators)',            'truck',   true,  24),
  ('Lights (Clearance / Marker)',         'truck',   true,  25),
  ('Mirrors',                             'truck',   true,  26),
  ('Muffler',                             'truck',   false, 27),
  ('Oil Pressure',                        'truck',   false, 28),
  ('On-Board Recorder / ELD',             'truck',   true,  29),
  ('Radiator',                            'truck',   false, 30),
  ('Rear End',                            'truck',   false, 31),
  ('Reflectors / Reflective Tape',        'truck',   false, 32),
  ('Safety Equipment (Fire Extinguisher)','truck',   true,  33),
  ('Safety Equipment (Flags / Flares / Triangles)', 'truck', true, 34),
  ('Safety Equipment (Spare Bulbs / Fuses)','truck', false, 35),
  ('Starter',                             'truck',   false, 36),
  ('Steering',                            'truck',   true,  37),
  ('Suspension System',                   'truck',   true,  38),
  ('Tarpaulin',                           'truck',   false, 39),
  ('Tires',                               'truck',   true,  40),
  ('Transmission',                        'truck',   false, 41),
  ('Wheels and Rims',                     'truck',   true,  42),
  ('Windows',                             'truck',   false, 43),
  ('Windshield Wipers',                   'truck',   true,  44),
  ('Other (Truck)',                       'truck',   false, 45),
  -- ---- trailer
  ('Brake Connections',                   'trailer', true,  51),
  ('Brakes',                              'trailer', true,  52),
  ('Coupling Devices',                    'trailer', true,  53),
  ('Coupling (King) Pin',                 'trailer', true,  54),
  ('Doors',                               'trailer', false, 55),
  ('Hitch',                               'trailer', true,  56),
  ('Landing Gear',                        'trailer', true,  57),
  ('Lights - All',                        'trailer', true,  58),
  ('Reflectors / Reflective Tape',        'trailer', false, 59),
  ('Roof',                                'trailer', false, 60),
  ('Springs',                             'trailer', true,  61),
  ('Suspension System',                   'trailer', true,  62),
  ('Tarpaulin',                           'trailer', false, 63),
  ('Tires',                               'trailer', true,  64),
  ('Wheels and Rims',                     'trailer', true,  65),
  ('Other (Trailer)',                     'trailer', false, 66)
) AS v(name, category, is_critical, sort_order)
ON CONFLICT DO NOTHING;
-- +goose StatementEnd

-- ---------------------------------------------------------------- companies.settings default (quick_notes, fuel_types)
-- +goose StatementBegin
ALTER TABLE companies ALTER COLUMN settings SET DEFAULT '{
  "quick_notes": [
    "Pre-trip inspection","Post-trip inspection","Fueling","Loading","Unloading",
    "Rest break","Waiting at shipper","Waiting at receiver","Traffic delay",
    "Weather delay","Adverse driving conditions","Personal conveyance","Yard move",
    "Scale / weigh station","Vehicle repair","Break down","Detention"
  ],
  "fuel_types": [
    "Diesel","Gasoline","Biodiesel","CNG","LNG","Propane","Electric","Hybrid"
  ],
  "distance_regions_set": "us_ca_ifta"
}'::jsonb;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE companies ALTER COLUMN settings SET DEFAULT '{}'::jsonb;
DELETE FROM defect_types WHERE company_id IS NULL;
DELETE FROM role_permissions WHERE role_id IN (SELECT id FROM roles WHERE company_id IS NULL AND is_system);
DELETE FROM roles WHERE company_id IS NULL AND is_system;
DELETE FROM system_settings;
-- +goose StatementEnd
