-- +goose Up
-- audit_log — append-only. company_id NULL = super-admin / tizim harakati.
-- +goose StatementBegin
CREATE TABLE audit_log (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE RESTRICT,
  table_name text NOT NULL,
  record_id  uuid,
  field      text,
  old_value  jsonb,
  new_value  jsonb,
  action     text NOT NULL CHECK (action IN (
               'insert','update','soft_delete','login','logout','failed_login','export',
               'permission_change','log_edit_request','hos_policy_change','token_reuse',
               'cross_tenant_attempt','certify','assign','approve','reject')),
  edited_by  uuid REFERENCES users(id) ON DELETE RESTRICT,
  ip         inet,
  user_agent text,
  ts         timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX audit_log_company_table_record_ts_idx ON audit_log (company_id, table_name, record_id, ts DESC);
CREATE INDEX audit_log_company_ts_idx ON audit_log (company_id, ts DESC);
CREATE INDEX audit_log_edited_by_idx  ON audit_log (edited_by, ts DESC) WHERE edited_by IS NOT NULL;
CREATE INDEX audit_log_action_idx     ON audit_log (action, ts DESC);
-- +goose StatementEnd

-- Append-only himoya: hech kim (superuser ham) UPDATE/DELETE qila olmaydi.
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION audit_log_append_only() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'audit_log is append-only: % is not allowed', TG_OP
    USING ERRCODE = 'insufficient_privilege';
END;
$$;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TRIGGER audit_log_no_update_delete
  BEFORE UPDATE OR DELETE ON audit_log
  FOR EACH ROW EXECUTE FUNCTION audit_log_append_only();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TRIGGER audit_log_no_truncate
  BEFORE TRUNCATE ON audit_log
  FOR EACH STATEMENT EXECUTE FUNCTION audit_log_append_only();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TRIGGER IF EXISTS audit_log_no_truncate ON audit_log;
DROP TRIGGER IF EXISTS audit_log_no_update_delete ON audit_log;
DROP FUNCTION IF EXISTS audit_log_append_only();
DROP TABLE IF EXISTS audit_log;
-- +goose StatementEnd
