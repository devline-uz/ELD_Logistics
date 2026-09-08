-- +goose Up

-- TZ D§3 — `POST /devices/push-token`: FCM/APNs tokenlar `device_id` bo'yicha
-- ro'yxatga olinadi. Token — maxfiy qiymat: hech qachon javobda yoki logda
-- qaytmaydi, faqat `internal/notify` push yuborishda o'qiydi.
-- +goose StatementBegin
CREATE TABLE device_push_tokens (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id   uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  user_id      uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  device_id    text NOT NULL,
  platform     text NOT NULL CHECK (platform IN ('android','ios','web')),
  token        text NOT NULL,
  app_version  text,
  last_seen_at timestamptz NOT NULL DEFAULT now(),
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now(),
  deleted_at   timestamptz
);
-- +goose StatementEnd

-- Bitta qurilma = bitta token. Qayta ro'yxatdan o'tish upsert bo'ladi, shuning
-- uchun (user_id, device_id) unikal.
-- +goose StatementBegin
CREATE UNIQUE INDEX device_push_tokens_user_device_uniq
  ON device_push_tokens (user_id, device_id) WHERE deleted_at IS NULL;
CREATE INDEX device_push_tokens_company_user_idx
  ON device_push_tokens (company_id, user_id) WHERE deleted_at IS NULL;
CREATE TRIGGER device_push_tokens_set_updated_at
  BEFORE UPDATE ON device_push_tokens FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- Bir xil token boshqa foydalanuvchida qolib ketmasin: qurilma egasi
-- o'zgarganda eski yozuv soft-delete qilinadi (query darajasida).
-- +goose StatementBegin
CREATE INDEX device_push_tokens_token_idx ON device_push_tokens (token) WHERE deleted_at IS NULL;
-- +goose StatementEnd

-- RLS — boshqa tenant tokenini o'qib bo'lmaydi.
-- +goose StatementBegin
ALTER TABLE device_push_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_push_tokens FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON device_push_tokens
  USING (company_id = NULLIF(current_setting('app.company_id', true), '')::uuid)
  WITH CHECK (company_id = NULLIF(current_setting('app.company_id', true), '')::uuid);
-- +goose StatementEnd

-- +goose StatementBegin
GRANT SELECT, INSERT, UPDATE, DELETE ON device_push_tokens TO app_role;
-- +goose StatementEnd

-- Chat: 1:1 thread bo'yicha o'qilmagan xabarlarni sanash issiq yo'l.
-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS chat_messages_unread_thread_idx
  ON chat_messages (company_id, driver_id, sender_id) WHERE read_at IS NULL;
-- +goose StatementEnd

-- Telegram — TZ Q89 [MAY] kanali. Chat id foydalanuvchi profilida saqlanadi.
-- +goose StatementBegin
ALTER TABLE users ADD COLUMN IF NOT EXISTS telegram_chat_id text;
-- +goose StatementEnd

-- Bildirishnoma sozlamalari: alert turi va kanal qiymatlari faqat TZ A§19
-- ro'yxatidan bo'lsin (DB — ikkinchi qatlam, birinchisi `internal/notify`).
-- +goose StatementBegin
ALTER TABLE notification_settings DROP CONSTRAINT IF EXISTS notification_settings_alert_type_check;
ALTER TABLE notification_settings ADD CONSTRAINT notification_settings_alert_type_check
  CHECK (alert_type IN (
    'hos_warning','hos_violation','route_assigned','route_completed',
    'dvir_defects','dvir_critical','log_edit_request','log_edit_resolved',
    'uncertified_log','unidentified_driving','eld_disconnected','eld_malfunction',
    'maintenance_upcoming','maintenance_overdue','chat_message','subscription_expiring'));
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE notification_settings DROP CONSTRAINT IF EXISTS notification_settings_channels_check;
ALTER TABLE notification_settings ADD CONSTRAINT notification_settings_channels_check
  CHECK (channels <@ ARRAY['push','email','sms','telegram','in_app']::text[]);
-- +goose StatementEnd

-- Bildirishnoma ro'yxati alert turi bo'yicha filtrlangan holda o'qiladi.
-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS notifications_user_type_idx
  ON notifications (company_id, user_id, alert_type, created_at DESC);
-- +goose StatementEnd

-- +goose Down

-- +goose StatementBegin
DROP INDEX IF EXISTS notifications_user_type_idx;
ALTER TABLE notification_settings DROP CONSTRAINT IF EXISTS notification_settings_channels_check;
ALTER TABLE notification_settings DROP CONSTRAINT IF EXISTS notification_settings_alert_type_check;
ALTER TABLE users DROP COLUMN IF EXISTS telegram_chat_id;
DROP INDEX IF EXISTS chat_messages_unread_thread_idx;
DROP TABLE IF EXISTS device_push_tokens;
-- +goose StatementEnd
