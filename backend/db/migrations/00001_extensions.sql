-- +goose Up
-- +goose StatementBegin
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE EXTENSION IF NOT EXISTS postgis;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE EXTENSION IF NOT EXISTS timescaledb;
-- +goose StatementEnd

-- Tenant izolyatsiyasi: har tranzaksiya boshida ilova
--   SET LOCAL app.company_id = '<uuid>'
-- qiladi. RLS policy'lari shu GUC ni o'qiydi:
--   company_id = NULLIF(current_setting('app.company_id', true), '')::uuid
-- Agar GUC o'rnatilmagan yoki bo'sh bo'lsa -> policy hech qanday qator qaytarmaydi.
-- Super-admin query'lari alohida "system" pool (BYPASSRLS roli) orqali boradi.
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION current_company_id() RETURNS uuid
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.company_id', true), '')::uuid;
$$;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP FUNCTION IF EXISTS current_company_id();
DROP FUNCTION IF EXISTS set_updated_at();
-- +goose StatementEnd
