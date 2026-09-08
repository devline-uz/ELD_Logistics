-- +goose Up

-- `subscription_change` — Super Admin obuna holatini o'zgartirganda yoziladi
-- (internal/domain/companies, TZ A§15). 00017 dagi to'plam saqlanadi.
-- +goose StatementBegin
ALTER TABLE audit_log DROP CONSTRAINT IF EXISTS audit_log_action_check;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE audit_log ADD CONSTRAINT audit_log_action_check CHECK (action IN (
  -- 00009 dagi asl to'plam
  'insert','update','soft_delete','login','logout','failed_login','export',
  'permission_change','log_edit_request','hos_policy_change','token_reuse',
  'cross_tenant_attempt','certify','assign','approve','reject',
  -- internal/audit.Action konstantalari (00017)
  'create','delete','restore',
  'password_change','password_reset','2fa_enabled','2fa_verified',
  'session_revoked','session_replaced','session_paused','session_resumed',
  'pin_set','pin_verified','pin_failed','account_locked','invitation_accepted',
  'invitation_sent','import','activate','deactivate',
  -- 00018
  'subscription_change'
));
-- +goose StatementEnd

-- +goose Down
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
  'invitation_sent','import','activate','deactivate'
));
-- +goose StatementEnd
