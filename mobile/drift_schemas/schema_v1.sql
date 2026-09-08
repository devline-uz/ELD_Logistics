-- ONEBOOK ELD lokal sxemasi, schemaVersion = 1.
-- Generatsiya: test/core/db/schema_snapshot_test.dart. Qo'lda tahrirlanmaydi.

CREATE INDEX idx_chat_messages_created ON chat_messages (created_at);

CREATE INDEX idx_chat_outbox_status ON chat_outbox (status, created_at);

CREATE INDEX idx_duty_events_driver_day ON duty_events (driver_id, log_date);

CREATE INDEX idx_duty_events_sync ON duty_events (sync_state);

CREATE INDEX idx_duty_events_time ON duty_events (event_time);

CREATE INDEX idx_dvir_drafts_state ON dvir_drafts (state, updated_at);

CREATE INDEX idx_dvir_reports_created ON dvir_reports (created_at);

CREATE INDEX idx_files_queue_state ON files_queue (state, attempts);

CREATE INDEX idx_log_edits_status ON log_edit_requests (status, created_at);

CREATE INDEX idx_notifications_read ON notifications (read, created_at);

CREATE INDEX idx_outbox_kind_state ON outbox_items (kind, state);

CREATE INDEX idx_outbox_ready ON outbox_items (state, next_attempt_at, device_seq);

CREATE INDEX idx_outbox_reject_seen ON outbox_items (state, reject_seen);

CREATE INDEX idx_telemetry_sent_ts ON telemetry_buffer (sent, ts);

CREATE INDEX idx_unidentified_status ON unidentified_events (status, start_at);

CREATE TABLE "chat_messages" ("id" TEXT NOT NULL, "client_id" TEXT NULL, "conversation_id" TEXT NULL, "sender_id" TEXT NULL, "kind" TEXT NOT NULL, "text" TEXT NULL, "file_key" TEXT NULL, "lat" REAL NULL, "lng" REAL NULL, "status" TEXT NOT NULL DEFAULT 'sent', "created_at" TEXT NOT NULL, PRIMARY KEY ("id"));

CREATE TABLE "chat_outbox" ("client_id" TEXT NOT NULL, "conversation_id" TEXT NULL, "kind" TEXT NOT NULL, "text" TEXT NULL, "file_key" TEXT NULL, "lat" REAL NULL, "lng" REAL NULL, "status" TEXT NOT NULL DEFAULT 'queued', "created_at" TEXT NOT NULL, PRIMARY KEY ("client_id"));

CREATE TABLE "daily_logs" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "server_id" TEXT NULL, "log_date" TEXT NOT NULL, "driver_id" TEXT NOT NULL, "timezone" TEXT NOT NULL, "certification_status" TEXT NOT NULL DEFAULT 'uncertified', "signed_at" TEXT NULL, "distance_m" INTEGER NOT NULL DEFAULT 0, "totals" TEXT NOT NULL DEFAULT '{}', "ready" INTEGER NOT NULL DEFAULT 0 CHECK ("ready" IN (0, 1)), "updated_at" TEXT NOT NULL, UNIQUE ("driver_id", "log_date"));

CREATE TABLE "duty_events" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "client_event_id" TEXT NOT NULL UNIQUE, "server_id" TEXT NULL, "event_type" TEXT NOT NULL, "status" TEXT NULL, "special" TEXT NOT NULL DEFAULT 'none', "event_time" TEXT NOT NULL, "time_source" TEXT NOT NULL DEFAULT 'phone', "time_unverified" INTEGER NOT NULL DEFAULT 0 CHECK ("time_unverified" IN (0, 1)), "clock_skew_sec" INTEGER NOT NULL DEFAULT 0, "device_seq" INTEGER NOT NULL, "origin" TEXT NOT NULL DEFAULT 'driver', "lat" REAL NULL, "lng" REAL NULL, "gps_accuracy_m" REAL NULL, "location_text" TEXT NULL, "odometer_m" INTEGER NULL, "engine_hours" REAL NULL, "speed_kmh" REAL NULL, "notes" TEXT NULL, "unit_id" TEXT NULL, "eld_device_id" TEXT NULL, "driver_id" TEXT NULL, "trailer_ids" TEXT NOT NULL DEFAULT '[]', "shipping_doc_ids" TEXT NOT NULL DEFAULT '[]', "sync_state" TEXT NOT NULL DEFAULT 'pending', "superseded_by" TEXT NULL, "locked" INTEGER NOT NULL DEFAULT 0 CHECK ("locked" IN (0, 1)), "log_date" TEXT NULL, "created_at" TEXT NOT NULL);

CREATE TABLE "dvir_drafts" ("client_id" TEXT NOT NULL, "unit_id" TEXT NOT NULL, "type" TEXT NOT NULL, "defects" TEXT NOT NULL DEFAULT '{}', "trailer_ids" TEXT NOT NULL DEFAULT '[]', "notes" TEXT NULL, "driver_signature_key" TEXT NULL, "local_photo_paths" TEXT NOT NULL DEFAULT '[]', "state" TEXT NOT NULL DEFAULT 'draft', "created_at" TEXT NOT NULL, "updated_at" TEXT NOT NULL, PRIMARY KEY ("client_id"));

CREATE TABLE "dvir_reports" ("id" TEXT NOT NULL, "status" TEXT NOT NULL, "kind" TEXT NOT NULL, "type" TEXT NOT NULL, "unit_id" TEXT NOT NULL, "created_at" TEXT NOT NULL, "has_critical_defect" INTEGER NOT NULL DEFAULT 0 CHECK ("has_critical_defect" IN (0, 1)), "out_of_service" INTEGER NOT NULL DEFAULT 0 CHECK ("out_of_service" IN (0, 1)), "payload" TEXT NOT NULL DEFAULT '{}', PRIMARY KEY ("id"));

CREATE TABLE "files_queue" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "local_path" TEXT NOT NULL UNIQUE, "kind" TEXT NOT NULL, "content_type" TEXT NOT NULL, "size_bytes" INTEGER NOT NULL, "presigned_key" TEXT NULL, "upload_url" TEXT NULL, "expires_at" TEXT NULL, "state" TEXT NOT NULL DEFAULT 'pending', "attempts" INTEGER NOT NULL DEFAULT 0, "created_at" TEXT NOT NULL, "uploaded_at" TEXT NULL);

CREATE TABLE "hos_policy" ("version_id" TEXT NOT NULL, "effective_from" TEXT NOT NULL, "payload" TEXT NOT NULL, PRIMARY KEY ("version_id"));

CREATE TABLE "hos_state" ("driver_id" TEXT NOT NULL, "computed_at" TEXT NOT NULL, "counters" TEXT NOT NULL DEFAULT '{}', "recap" TEXT NOT NULL DEFAULT '{}', "policy_version_id" TEXT NULL, PRIMARY KEY ("driver_id"));

CREATE TABLE "kv_settings" ("key" TEXT NOT NULL, "value" TEXT NOT NULL, "updated_at" TEXT NOT NULL, PRIMARY KEY ("key"));

CREATE TABLE "log_edit_requests" ("id" TEXT NOT NULL, "daily_log_id" TEXT NULL, "log_date" TEXT NOT NULL, "changes" TEXT NOT NULL DEFAULT '{}', "source" TEXT NOT NULL, "status" TEXT NOT NULL, "created_at" TEXT NOT NULL, "local_decision" TEXT NULL, PRIMARY KEY ("id"));

CREATE TABLE "notifications" ("id" TEXT NOT NULL, "alert_type" TEXT NOT NULL, "title" TEXT NOT NULL, "body" TEXT NOT NULL, "entity_type" TEXT NULL, "entity_id" TEXT NULL, "read" INTEGER NOT NULL DEFAULT 0 CHECK ("read" IN (0, 1)), "created_at" TEXT NOT NULL, PRIMARY KEY ("id"));

CREATE TABLE "outbox_items" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "kind" TEXT NOT NULL, "payload" TEXT NOT NULL, "client_id" TEXT NOT NULL, "device_seq" INTEGER NOT NULL, "session_slot" INTEGER NOT NULL DEFAULT 0, "user_id" TEXT NULL, "created_at" TEXT NOT NULL, "attempts" INTEGER NOT NULL DEFAULT 0, "next_attempt_at" TEXT NOT NULL, "state" TEXT NOT NULL DEFAULT 'pending', "idempotency_key" TEXT NULL, "reject_reason" TEXT NULL, "reject_seen" INTEGER NOT NULL DEFAULT 0 CHECK ("reject_seen" IN (0, 1)), "superseded_by" TEXT NULL, "last_error" TEXT NULL, "updated_at" TEXT NOT NULL, UNIQUE ("kind", "client_id"));

CREATE TABLE "ref_defect_types" ("id" TEXT NOT NULL, "code" TEXT NOT NULL, "label" TEXT NOT NULL, "category" TEXT NULL, "applies_to" TEXT NOT NULL DEFAULT 'vehicle', "updated_at" TEXT NOT NULL, PRIMARY KEY ("id"));

CREATE TABLE "ref_quick_notes" ("id" TEXT NOT NULL, "text" TEXT NOT NULL, "category" TEXT NULL, "updated_at" TEXT NOT NULL, PRIMARY KEY ("id"));

CREATE TABLE "ref_trailers" ("id" TEXT NOT NULL, "number" TEXT NOT NULL, "unit_id" TEXT NULL, "updated_at" TEXT NOT NULL, PRIMARY KEY ("id"));

CREATE TABLE "sync_cursor" ("id" INTEGER NOT NULL DEFAULT 1, "next_since" TEXT NULL, "last_push_at" TEXT NULL, "last_pull_at" TEXT NULL, "last_error" TEXT NULL, "last_error_at" TEXT NULL, PRIMARY KEY ("id"));

CREATE TABLE "telemetry_buffer" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "unit_id" TEXT NOT NULL, "ts" TEXT NOT NULL, "lat" REAL NULL, "lng" REAL NULL, "speed_kmh" REAL NULL, "heading_deg" REAL NULL, "odometer_m" INTEGER NULL, "engine_hours" REAL NULL, "ignition" INTEGER NULL CHECK ("ignition" IN (0, 1)), "fuel_pct" REAL NULL, "coolant_temp_c" REAL NULL, "coolant_level_pct" REAL NULL, "oil_level_pct" REAL NULL, "battery_voltage" REAL NULL, "battery_pct" REAL NULL, "diagnostics" TEXT NULL, "disconnected" INTEGER NOT NULL DEFAULT 0 CHECK ("disconnected" IN (0, 1)), "duty_status" TEXT NULL, "driver_id" TEXT NULL, "sent" INTEGER NOT NULL DEFAULT 0 CHECK ("sent" IN (0, 1)), UNIQUE ("unit_id", "ts"));

CREATE TABLE "unidentified_events" ("id" TEXT NOT NULL, "unit_id" TEXT NOT NULL, "start_at" TEXT NOT NULL, "end_at" TEXT NULL, "distance_m" INTEGER NOT NULL DEFAULT 0, "status" TEXT NOT NULL, "dismissed_local" INTEGER NOT NULL DEFAULT 0 CHECK ("dismissed_local" IN (0, 1)), PRIMARY KEY ("id"));

