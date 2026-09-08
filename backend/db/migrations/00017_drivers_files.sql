-- +goose Up

-- ---------------------------------------------------------------- audit_log
-- `internal/audit.Entry` `Reason` maydonini va `audit.Action` konstantalarini
-- yozadi; 00009 dagi ustunlar/CHECK ular bilan mos emas edi.
-- +goose StatementBegin
ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS reason text;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE audit_log DROP CONSTRAINT IF EXISTS audit_log_action_check;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE audit_log ADD CONSTRAINT audit_log_action_check CHECK (action IN (
  -- 00009 dagi asl to'plam (buzilmaydi)
  'insert','update','soft_delete','login','logout','failed_login','export',
  'permission_change','log_edit_request','hos_policy_change','token_reuse',
  'cross_tenant_attempt','certify','assign','approve','reject',
  -- internal/audit.Action konstantalari
  'create','delete','restore',
  'password_change','password_reset','2fa_enabled','2fa_verified',
  'session_revoked','session_replaced','session_paused','session_resumed',
  'pin_set','pin_verified','pin_failed','account_locked','invitation_accepted',
  'invitation_sent','import','activate','deactivate'
));
-- +goose StatementEnd

-- ---------------------------------------------------------------- permission
-- `drivers.reset_password` — haydovchiga invitation'ni qayta yuborish.
-- +goose StatementBegin
UPDATE system_settings
SET value = value || to_jsonb(ARRAY['drivers.reset_password'])
WHERE key = 'permission_keys'
  AND NOT (value ? 'drivers.reset_password');
-- +goose StatementEnd

-- Haydovchi yarata oladigan har bir rol invitation'ni qayta yubora oladi.
-- +goose StatementBegin
INSERT INTO role_permissions (role_id, permission_key)
SELECT rp.role_id, 'drivers.reset_password'
FROM role_permissions rp
WHERE rp.permission_key = 'drivers.create'
ON CONFLICT DO NOTHING;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM role_permissions WHERE permission_key = 'drivers.reset_password';
-- +goose StatementEnd

-- +goose StatementBegin
UPDATE system_settings
SET value = (SELECT to_jsonb(array_agg(k))
             FROM jsonb_array_elements_text(value) AS k
             WHERE k <> 'drivers.reset_password')
WHERE key = 'permission_keys';
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE audit_log DROP CONSTRAINT IF EXISTS audit_log_action_check;
ALTER TABLE audit_log DROP COLUMN IF EXISTS reason;
-- +goose StatementEnd
