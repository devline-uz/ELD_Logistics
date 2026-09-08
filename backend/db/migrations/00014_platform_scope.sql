-- +goose Up

-- Platform (Super Admin) oynasi.
-- `companies` uchun RLS faqat `id = app.company_id` ni ochadi, shuning uchun
-- Super Admin barcha kompaniyalarni ko'ra/yarata olmaydi. `app.platform`
-- FAQAT `SET LOCAL` bilan, internal/domain/companies tranzaksiyasi ichida
-- qo'yiladi va o'sha tranzaksiyadan tashqarida hech qachon ko'rinmaydi
-- (00013 dagi `app.auth_stage` bilan bir xil naqsh).
-- +goose StatementBegin
DROP POLICY IF EXISTS platform_scope ON companies;
CREATE POLICY platform_scope ON companies
  USING (NULLIF(current_setting('app.platform', true), '') = 'on')
  WITH CHECK (NULLIF(current_setting('app.platform', true), '') = 'on');
-- +goose StatementEnd

-- regulation_profile — TZ A§1.4 `generic` profili (PK/UZ mijozlari uchun).
-- +goose StatementBegin
ALTER TABLE companies DROP CONSTRAINT IF EXISTS companies_regulation_profile_check;
ALTER TABLE companies ADD CONSTRAINT companies_regulation_profile_check
  CHECK (regulation_profile IN ('us_fmcsa','generic','canada','texas','california','alaska','hawaii'));
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE companies DROP CONSTRAINT IF EXISTS companies_regulation_profile_check;
ALTER TABLE companies ADD CONSTRAINT companies_regulation_profile_check
  CHECK (regulation_profile IN ('us_fmcsa','canada','texas','california','alaska','hawaii'));
DROP POLICY IF EXISTS platform_scope ON companies;
-- +goose StatementEnd
