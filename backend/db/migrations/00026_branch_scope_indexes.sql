-- +goose Up
-- 9-bosqich: `branch` scope (TZ A§16) filtrlarini indekslash.
--
-- routes, reports va activity query'lari endi `drivers.branch_id` /
-- `units.branch_id` bo'yicha cheklanadi. Bu ustunlarda indeks yo'q edi —
-- filial menejerining har bir ro'yxati butun tenant bo'ylab seq scan berardi.
-- Indekslar qisman: branch_id NULL bo'lgan qatorlar filial scope'iga umuman
-- ko'rinmaydi, shuning uchun ularni indekslashning ma'nosi yo'q.

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS drivers_company_branch_idx
  ON drivers (company_id, branch_id)
  WHERE deleted_at IS NULL AND branch_id IS NOT NULL;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS units_company_branch_idx
  ON units (company_id, branch_id)
  WHERE deleted_at IS NULL AND branch_id IS NOT NULL;
-- +goose StatementEnd

-- audit_log ko'rinishidagi `LEFT JOIN users u ON u.id = a.edited_by AND
-- u.company_id = a.company_id` uchun: aktyorni tenant ichida hal qilish.
-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS users_id_company_idx
  ON users (id, company_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS users_id_company_idx;
-- +goose StatementEnd

-- +goose StatementBegin
DROP INDEX IF EXISTS units_company_branch_idx;
-- +goose StatementEnd

-- +goose StatementBegin
DROP INDEX IF EXISTS drivers_company_branch_idx;
-- +goose StatementEnd
