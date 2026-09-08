-- +goose Up
-- Final API freeze cleanup (v1): drop permission keys that no handler ever
-- enforces (found by the permission-matrix audit, tasks.md final pass).
--
-- `tracking.read` / `tracking.history` — the tracking module actually checks
-- `tracking.view_live` / `tracking.view_history` (internal/domain/tracking/
-- http.go); these two were seeded but never wired to a route.
-- `trips.read` — no /trips endpoint exists; unit/trip history lives under
-- `routes.*` and `tracking.view_history`.
-- `support.update` — superseded by `support.update_status`
-- (00025_support_audit_stage8.sql already copied every grant across), and no
-- endpoint ever checked the older key.
--
-- `company.history.view` is the opposite case (seeded, real, but unused) — it
-- stays, and this migration instead points GET /company/history at it
-- (was checking `audit.view`, a broader permission).

-- Drop unused grants first so the catalog array and role_permissions stay
-- consistent for GET /permissions.
-- +goose StatementBegin
DELETE FROM role_permissions
WHERE permission_key IN ('tracking.read', 'tracking.history', 'trips.read', 'support.update');
-- +goose StatementEnd

-- Give every role that could read the audit trail before also the narrower
-- company-history key, so nobody loses access when the handler switches over.
-- +goose StatementBegin
INSERT INTO role_permissions (role_id, permission_key)
SELECT rp.role_id, 'company.history.view'
FROM role_permissions rp
WHERE rp.permission_key = 'audit.view'
ON CONFLICT DO NOTHING;
-- +goose StatementEnd

-- +goose StatementBegin
UPDATE system_settings
SET value = (
  SELECT to_jsonb(array_agg(elem ORDER BY ord))
  FROM jsonb_array_elements_text(value) WITH ORDINALITY AS t(elem, ord)
  WHERE elem NOT IN ('tracking.read', 'tracking.history', 'trips.read', 'support.update')
)
WHERE key = 'permission_keys';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
UPDATE system_settings
SET value = value || to_jsonb(ARRAY['tracking.read', 'tracking.history', 'trips.read', 'support.update'])
WHERE key = 'permission_keys';
-- +goose StatementEnd
