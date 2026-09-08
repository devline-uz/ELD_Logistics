-- +goose Up

-- 1) role_permissions RLS — company_id predikati endi aniq yozilgan.
-- Avvalgi policy `EXISTS (SELECT 1 FROM roles r WHERE r.id = role_id)` edi:
-- ajratish amalda `roles` ning o'z RLS'iga bog'liq bo'lib qolgan. Agar kimdir
-- `roles` policy'sini o'zgartirsa yoki subquery boshqa kontekstda planlansa,
-- izolyatsiya jimgina yo'qoladi. Endi predikat ikkala tomonda ham (USING va
-- WITH CHECK) o'zida turadi.
-- `company_id IS NULL` — tizim rollari (`is_system`), ular hamma tenant uchun
-- o'qishga ochiq, lekin ularga permission YOZISH mumkin emas: WITH CHECK
-- faqat o'z kompaniyasining rolini qabul qiladi.
-- +goose StatementBegin
DROP POLICY IF EXISTS tenant_isolation ON role_permissions;
-- +goose StatementEnd
-- +goose StatementBegin
CREATE POLICY tenant_isolation ON role_permissions
  USING (EXISTS (
    SELECT 1 FROM roles r
    WHERE r.id = role_permissions.role_id
      AND (r.company_id IS NULL
           OR r.company_id = NULLIF(current_setting('app.company_id', true), '')::uuid)))
  WITH CHECK (EXISTS (
    SELECT 1 FROM roles r
    WHERE r.id = role_permissions.role_id
      AND r.company_id = NULLIF(current_setting('app.company_id', true), '')::uuid));
-- +goose StatementEnd

-- 2) `license_reveal` — ochiq litsenziya raqamini ko'rish audit hodisasi
-- (internal/audit.ActionLicenseReveal, TZ B§3.4). 00018 dagi to'plam saqlanadi.
-- +goose StatementBegin
ALTER TABLE audit_log DROP CONSTRAINT IF EXISTS audit_log_action_check;
-- +goose StatementEnd
-- +goose StatementBegin
ALTER TABLE audit_log ADD CONSTRAINT audit_log_action_check CHECK (action IN (
  'insert','update','soft_delete','login','logout','failed_login','export',
  'permission_change','log_edit_request','hos_policy_change','token_reuse',
  'cross_tenant_attempt','certify','assign','approve','reject',
  'create','delete','restore',
  'password_change','password_reset','2fa_enabled','2fa_verified',
  'session_revoked','session_replaced','session_paused','session_resumed',
  'pin_set','pin_verified','pin_failed','account_locked','invitation_accepted',
  'invitation_sent','import','activate','deactivate',
  'subscription_change',
  -- 00020
  'license_reveal'
));
-- +goose StatementEnd

-- 3) `drivers.license.view` — ochiq litsenziya raqami uchun alohida kalit.
-- Manba-haqiqat `internal/auth/permissions.go`; bu yerda GET /permissions uchun.
-- +goose StatementBegin
UPDATE system_settings
SET value = value || to_jsonb(ARRAY['drivers.license.view'])
WHERE key = 'permission_keys'
  AND NOT (value @> '["drivers.license.view"]'::jsonb);
-- +goose StatementEnd

-- Mavjud xatti-harakatni saqlash: shu paytgacha endpoint `drivers.update`
-- bilan qo'riqlangan edi, shuning uchun aynan o'sha rollar kalitni oladi.
-- +goose StatementBegin
INSERT INTO role_permissions (role_id, permission_key)
SELECT rp.role_id, 'drivers.license.view'
FROM role_permissions rp
WHERE rp.permission_key = 'drivers.update'
ON CONFLICT DO NOTHING;
-- +goose StatementEnd

-- +goose Down

-- +goose StatementBegin
DELETE FROM role_permissions WHERE permission_key = 'drivers.license.view';
-- +goose StatementEnd
-- +goose StatementBegin
UPDATE system_settings
SET value = (SELECT jsonb_agg(k) FROM jsonb_array_elements_text(value) AS k
             WHERE k <> 'drivers.license.view')
WHERE key = 'permission_keys';
-- +goose StatementEnd
-- +goose StatementBegin
ALTER TABLE audit_log DROP CONSTRAINT IF EXISTS audit_log_action_check;
-- +goose StatementEnd
-- +goose StatementBegin
ALTER TABLE audit_log ADD CONSTRAINT audit_log_action_check CHECK (action IN (
  'insert','update','soft_delete','login','logout','failed_login','export',
  'permission_change','log_edit_request','hos_policy_change','token_reuse',
  'cross_tenant_attempt','certify','assign','approve','reject',
  'create','delete','restore',
  'password_change','password_reset','2fa_enabled','2fa_verified',
  'session_revoked','session_replaced','session_paused','session_resumed',
  'pin_set','pin_verified','pin_failed','account_locked','invitation_accepted',
  'invitation_sent','import','activate','deactivate',
  'subscription_change'
));
-- +goose StatementEnd
-- +goose StatementBegin
DROP POLICY IF EXISTS tenant_isolation ON role_permissions;
-- +goose StatementEnd
-- +goose StatementBegin
CREATE POLICY tenant_isolation ON role_permissions
  USING (EXISTS (SELECT 1 FROM roles r WHERE r.id = role_permissions.role_id))
  WITH CHECK (EXISTS (
    SELECT 1 FROM roles r
    WHERE r.id = role_permissions.role_id
      AND r.company_id = NULLIF(current_setting('app.company_id', true), '')::uuid));
-- +goose StatementEnd
