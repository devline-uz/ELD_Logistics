-- +goose Up

-- Refresh token rotation: eski hash saqlanadi, shunda qayta ishlatish
-- aniqlanadi (TZ B§3.1 — reuse -> butun sessiya bekor + audit `token_reuse`).
-- +goose StatementBegin
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS prev_refresh_token_hash text;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS sessions_prev_refresh_hash_idx
  ON sessions (prev_refresh_token_hash) WHERE prev_refresh_token_hash IS NOT NULL;
-- +goose StatementEnd

-- Autentifikatsiyadan OLDINGI qidiruvlar (username, refresh hash, invitation
-- token) va platforma (super admin, company_id IS NULL) yozuvlari uchun
-- `app.company_id` hali ma'lum emas. `app.auth_stage` faqat
-- `db.Pool.WithAuthTx` ichida `SET LOCAL` bilan qo'yiladi va o'sha
-- tranzaksiyadan tashqarida hech qachon ko'rinmaydi.
-- +goose StatementBegin
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['users','sessions','invitations','companies','roles','role_permissions','audit_log'] LOOP
    EXECUTE format($f$
      CREATE POLICY auth_stage ON %I
        USING (NULLIF(current_setting('app.auth_stage', true), '') = 'on')
        WITH CHECK (NULLIF(current_setting('app.auth_stage', true), '') = 'on')
    $f$, t);
  END LOOP;
END;
$$;
-- +goose StatementEnd

-- Ilova versiyasi va feature flag'lar — GET /app/config manbasi.
-- +goose StatementBegin
INSERT INTO system_settings (key, value, description) VALUES
  ('min_supported_version', '"1.0.0"'::jsonb, 'Eng past qo''llab-quvvatlanadigan mobil ilova versiyasi'),
  ('latest_version',        '"1.0.0"'::jsonb, 'Do''kondagi oxirgi ilova versiyasi'),
  ('force_update',          'false'::jsonb,   'Majburiy yangilash bayrog''i'),
  ('feature_flags',         '{"chat":true,"dvir":true,"maintenance":true,"routes":true,"tracking":true,"two_factor":true}'::jsonb,
                            'Ilova feature flag''lari'),
  ('pin_max_attempts',      '5'::jsonb,       'PIN uchun ketma-ket urinishlar chegarasi'),
  ('login_ip_per_minute',   '5'::jsonb,       'Login: IP uchun daqiqadagi urinishlar'),
  ('login_account_per_hour','10'::jsonb,      'Login: akkaunt uchun soatdagi urinishlar')
ON CONFLICT (key) DO NOTHING;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['users','sessions','invitations','companies','roles','role_permissions','audit_log'] LOOP
    EXECUTE format('DROP POLICY IF EXISTS auth_stage ON %I', t);
  END LOOP;
END;
$$;
-- +goose StatementEnd

-- +goose StatementBegin
DROP INDEX IF EXISTS sessions_prev_refresh_hash_idx;
ALTER TABLE sessions DROP COLUMN IF EXISTS prev_refresh_token_hash;
DELETE FROM system_settings WHERE key IN
  ('min_supported_version','latest_version','force_update','feature_flags',
   'pin_max_attempts','login_ip_per_minute','login_account_per_hour');
-- +goose StatementEnd
