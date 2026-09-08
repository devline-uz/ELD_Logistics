-- +goose Up
-- roles: company_id NULL = tizim shabloni (default rollar).
-- +goose StatementBegin
CREATE TABLE roles (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id  uuid REFERENCES companies(id) ON DELETE RESTRICT,
  name        text NOT NULL,
  description text,
  scope       text NOT NULL DEFAULT 'company' CHECK (scope IN ('company','branch','self')),
  is_system   boolean NOT NULL DEFAULT false,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  deleted_at  timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX roles_company_name_uniq ON roles (company_id, lower(name)) WHERE deleted_at IS NULL AND company_id IS NOT NULL;
CREATE UNIQUE INDEX roles_system_name_uniq  ON roles (lower(name)) WHERE deleted_at IS NULL AND company_id IS NULL;
CREATE INDEX roles_company_idx ON roles (company_id) WHERE deleted_at IS NULL;
CREATE TRIGGER roles_set_updated_at BEFORE UPDATE ON roles FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE role_permissions (
  role_id        uuid NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
  permission_key text NOT NULL,
  created_at     timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (role_id, permission_key)
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX role_permissions_key_idx ON role_permissions (permission_key);
-- +goose StatementEnd

-- users: company_id NULL = super admin.
-- +goose StatementBegin
CREATE TABLE users (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id      uuid REFERENCES companies(id) ON DELETE RESTRICT,
  branch_id       uuid REFERENCES branches(id) ON DELETE RESTRICT,
  first_name      text NOT NULL,
  last_name       text NOT NULL,
  email           text,
  phone           text,
  username        text NOT NULL,
  password_hash   text,
  role_id         uuid NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
  status          text NOT NULL DEFAULT 'invited' CHECK (status IN ('invited','active','inactive')),
  totp_secret_enc text,
  totp_enabled    boolean NOT NULL DEFAULT false,
  recovery_codes  text[] NOT NULL DEFAULT '{}',
  pin_hash        text,
  invited_at      timestamptz,
  activated_at    timestamptz,
  last_login_at   timestamptz,
  failed_logins   integer NOT NULL DEFAULT 0,
  locked_until    timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  deleted_at      timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX users_company_username_uniq ON users (company_id, lower(username)) WHERE deleted_at IS NULL AND company_id IS NOT NULL;
CREATE UNIQUE INDEX users_super_username_uniq   ON users (lower(username)) WHERE deleted_at IS NULL AND company_id IS NULL;
CREATE UNIQUE INDEX users_company_email_uniq    ON users (company_id, lower(email)) WHERE deleted_at IS NULL AND email IS NOT NULL;
CREATE INDEX users_company_idx ON users (company_id) WHERE deleted_at IS NULL;
CREATE INDEX users_role_idx    ON users (role_id);
CREATE INDEX users_branch_idx  ON users (branch_id) WHERE branch_id IS NOT NULL;
CREATE TRIGGER users_set_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE sessions (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id         uuid REFERENCES companies(id) ON DELETE RESTRICT,
  user_id            uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  device_id          text,
  device_type        text NOT NULL CHECK (device_type IN ('web','phone','tablet')),
  refresh_token_hash text NOT NULL,
  status             text NOT NULL DEFAULT 'active' CHECK (status IN ('active','paused','revoked')),
  revoked_reason     text,
  expires_at         timestamptz NOT NULL,
  last_seen_at       timestamptz,
  app_version        text,
  ip                 inet,
  user_agent         text,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX sessions_refresh_hash_uniq ON sessions (refresh_token_hash);
CREATE INDEX sessions_user_idx        ON sessions (user_id, status);
CREATE UNIQUE INDEX sessions_user_device_active_uniq ON sessions (user_id, device_type) WHERE status = 'active';
CREATE INDEX sessions_expires_idx     ON sessions (expires_at);
CREATE TRIGGER sessions_set_updated_at BEFORE UPDATE ON sessions FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE invitations (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE RESTRICT,
  user_id    uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  token_hash text NOT NULL,
  channel    text NOT NULL DEFAULT 'email' CHECK (channel IN ('email','sms','telegram')),
  purpose    text NOT NULL DEFAULT 'invitation' CHECK (purpose IN ('invitation','password_reset')),
  expires_at timestamptz NOT NULL,
  used_at    timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX invitations_token_hash_uniq ON invitations (token_hash);
CREATE INDEX invitations_user_idx ON invitations (user_id, used_at);
CREATE TRIGGER invitations_set_updated_at BEFORE UPDATE ON invitations FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS invitations;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS role_permissions;
DROP TABLE IF EXISTS roles;
-- +goose StatementEnd
