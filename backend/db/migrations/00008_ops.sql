-- +goose Up
-- +goose StatementBegin
CREATE TABLE routes (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id           uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  unit_id              uuid NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
  driver_id            uuid NOT NULL REFERENCES drivers(id) ON DELETE RESTRICT,
  sequence             integer NOT NULL DEFAULT 1,
  origin_text          text,
  origin_lat           double precision,
  origin_lng           double precision,
  dest_text            text,
  dest_lat             double precision,
  dest_lng             double precision,
  geofence_m           integer NOT NULL DEFAULT 200,
  status               text NOT NULL DEFAULT 'planned' CHECK (status IN ('planned','in_progress','completed','not_completed','cancelled')),
  created_by           uuid REFERENCES users(id) ON DELETE RESTRICT,
  started_at           timestamptz,
  completed_at         timestamptz,
  not_completed_reason text,
  note                 text,
  polyline_key         text,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now(),
  deleted_at           timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX routes_company_status_idx ON routes (company_id, status, created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX routes_driver_idx ON routes (driver_id, sequence) WHERE deleted_at IS NULL;
CREATE INDEX routes_unit_idx   ON routes (unit_id) WHERE deleted_at IS NULL;
CREATE TRIGGER routes_set_updated_at BEFORE UPDATE ON routes FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE notifications (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id   uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  user_id      uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  alert_type   text NOT NULL,
  title        text NOT NULL,
  body         text,
  entity_type  text,
  entity_id    uuid,
  channels     text[] NOT NULL DEFAULT '{}',
  sent_at      timestamptz,
  delivered_at timestamptz,
  read_at      timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX notifications_user_created_idx ON notifications (user_id, created_at DESC);
CREATE INDEX notifications_user_unread_idx  ON notifications (user_id) WHERE read_at IS NULL;
CREATE INDEX notifications_company_idx      ON notifications (company_id, created_at DESC);
CREATE TRIGGER notifications_set_updated_at BEFORE UPDATE ON notifications FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE notification_settings (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id      uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  alert_type      text NOT NULL,
  channels        text[] NOT NULL DEFAULT '{}',
  recipient_roles uuid[] NOT NULL DEFAULT '{}',
  enabled         boolean NOT NULL DEFAULT true,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX notification_settings_company_type_uniq ON notification_settings (company_id, alert_type);
CREATE TRIGGER notification_settings_set_updated_at BEFORE UPDATE ON notification_settings FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE support_tickets (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id  uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  driver_id   uuid REFERENCES drivers(id) ON DELETE RESTRICT,
  created_by  uuid REFERENCES users(id) ON DELETE RESTRICT,
  subject     text NOT NULL,
  description text,
  contact_on  text,
  status      text NOT NULL DEFAULT 'open' CHECK (status IN ('open','in_progress','resolved','closed')),
  attachments text[] NOT NULL DEFAULT '{}',
  resolved_at timestamptz,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  deleted_at  timestamptz
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX support_tickets_company_status_idx ON support_tickets (company_id, status, created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX support_tickets_driver_idx ON support_tickets (driver_id, created_at DESC);
CREATE TRIGGER support_tickets_set_updated_at BEFORE UPDATE ON support_tickets FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE ticket_messages (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id  uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  ticket_id   uuid NOT NULL REFERENCES support_tickets(id) ON DELETE RESTRICT,
  sender_id   uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  text        text NOT NULL,
  attachments text[] NOT NULL DEFAULT '{}',
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX ticket_messages_ticket_idx ON ticket_messages (ticket_id, created_at);
CREATE INDEX ticket_messages_company_idx ON ticket_messages (company_id);
CREATE TRIGGER ticket_messages_set_updated_at BEFORE UPDATE ON ticket_messages FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE feedback (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id   uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  driver_id    uuid REFERENCES drivers(id) ON DELETE RESTRICT,
  app_rating   smallint CHECK (app_rating IS NULL OR app_rating BETWEEN 1 AND 5),
  text         text,
  submitted_at timestamptz NOT NULL DEFAULT now(),
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX feedback_company_idx ON feedback (company_id, submitted_at DESC);
CREATE TRIGGER feedback_set_updated_at BEFORE UPDATE ON feedback FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE chat_messages (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id   uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  driver_id    uuid NOT NULL REFERENCES drivers(id) ON DELETE RESTRICT,
  sender_id    uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  kind         text NOT NULL DEFAULT 'text' CHECK (kind IN ('text','image','file','location')),
  text         text,
  file_key     text,
  lat          double precision,
  lng          double precision,
  sent_at      timestamptz NOT NULL DEFAULT now(),
  delivered_at timestamptz,
  read_at      timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX chat_messages_thread_idx ON chat_messages (company_id, driver_id, sent_at DESC);
CREATE INDEX chat_messages_unread_idx ON chat_messages (driver_id) WHERE read_at IS NULL;
CREATE TRIGGER chat_messages_set_updated_at BEFORE UPDATE ON chat_messages FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE report_export_jobs (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id   uuid NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
  requested_by uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  type         text NOT NULL,
  format       text NOT NULL DEFAULT 'xlsx' CHECK (format IN ('xlsx','csv','pdf')),
  params       jsonb NOT NULL DEFAULT '{}'::jsonb,
  status       text NOT NULL DEFAULT 'queued' CHECK (status IN ('queued','running','done','failed')),
  error        text,
  file_key     text,
  expires_at   timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX report_export_jobs_company_idx ON report_export_jobs (company_id, created_at DESC);
CREATE INDEX report_export_jobs_status_idx  ON report_export_jobs (status) WHERE status IN ('queued','running');
CREATE TRIGGER report_export_jobs_set_updated_at BEFORE UPDATE ON report_export_jobs FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS report_export_jobs;
DROP TABLE IF EXISTS chat_messages;
DROP TABLE IF EXISTS feedback;
DROP TABLE IF EXISTS ticket_messages;
DROP TABLE IF EXISTS support_tickets;
DROP TABLE IF EXISTS notification_settings;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS routes;
-- +goose StatementEnd
