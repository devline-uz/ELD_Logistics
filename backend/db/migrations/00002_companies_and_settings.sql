-- +goose Up
-- +goose StatementBegin
CREATE TABLE companies (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name                text NOT NULL,
  address             text,
  home_terminal_address text,
  timezone            text NOT NULL DEFAULT 'America/Chicago',
  email               text,
  phone               text,
  registration_no     text,
  logo_key            text,
  region              text,
  unit_system         text NOT NULL DEFAULT 'imperial' CHECK (unit_system IN ('imperial','metric')),
  regulation_profile  text NOT NULL DEFAULT 'us_fmcsa' CHECK (regulation_profile IN ('us_fmcsa','canada','texas','california','alaska','hawaii')),
  subscription_status text NOT NULL DEFAULT 'trial' CHECK (subscription_status IN ('trial','active','grace','readonly')),
  subscription_end_at timestamptz,
  plan                text,
  settings            jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  deleted_at          timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX companies_name_uniq ON companies (lower(name)) WHERE deleted_at IS NULL;
CREATE INDEX companies_subscription_status_idx ON companies (subscription_status) WHERE deleted_at IS NULL;
CREATE TRIGGER companies_set_updated_at BEFORE UPDATE ON companies FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE hos_policy_versions (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id     uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  effective_from timestamptz NOT NULL DEFAULT now(),
  policy         jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_by     uuid,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now(),
  deleted_at     timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX hos_policy_versions_company_idx ON hos_policy_versions (company_id, effective_from DESC);
CREATE TRIGGER hos_policy_versions_set_updated_at BEFORE UPDATE ON hos_policy_versions FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE branches (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  name       text NOT NULL,
  address    text,
  timezone   text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX branches_company_name_uniq ON branches (company_id, lower(name)) WHERE deleted_at IS NULL;
CREATE INDEX branches_company_idx ON branches (company_id) WHERE deleted_at IS NULL;
CREATE TRIGGER branches_set_updated_at BEFORE UPDATE ON branches FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- system_settings — global (tenantsiz) konfiguratsiya, RLS yo'q.
-- +goose StatementBegin
CREATE TABLE system_settings (
  key         text PRIMARY KEY,
  value       jsonb NOT NULL,
  description text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TRIGGER system_settings_set_updated_at BEFORE UPDATE ON system_settings FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS system_settings;
DROP TABLE IF EXISTS branches;
DROP TABLE IF EXISTS hos_policy_versions;
DROP TABLE IF EXISTS companies;
-- +goose StatementEnd
