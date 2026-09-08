/// Drift sxemasi, indekslar va migratsiya karkasi (§5.1, M21, M22).

library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/daos/settings_dao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  test('schemaVersion 2 (forward-only, P10/M21)', () {
    expect(db.schemaVersion, 2);
    expect(kSchemaVersion, 2);
  });

  test('§5.1 jadvallarining hammasi yaratiladi', () async {
    final List<QueryRow> rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final Set<String> names = rows.map((QueryRow r) => r.read<String>('name')).toSet();

    for (final String expected in <String>[
      'outbox_items',
      'duty_events',
      'telemetry_buffer',
      'daily_logs',
      'hos_state',
      'hos_policy',
      'dvir_drafts',
      'dvir_reports',
      'files_queue',
      'chat_outbox',
      'chat_messages',
      'notifications',
      'log_edit_requests',
      'unidentified_events',
      'ref_defect_types',
      'ref_quick_notes',
      'ref_trailers',
      'sync_cursor',
      'kv_settings',
    ]) {
      expect(names, contains(expected), reason: '$expected jadvali yo\'q');
    }
  });

  test('majburiy indekslar mavjud', () async {
    final List<QueryRow> rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .get();
    final Set<String> names = rows.map((QueryRow r) => r.read<String>('name')).toSet();

    for (final String expected in <String>[
      'idx_outbox_ready',
      'idx_outbox_kind_state',
      'idx_outbox_reject_seen',
      'idx_duty_events_time',
      'idx_duty_events_sync',
      'idx_telemetry_sent_ts',
      'idx_chat_messages_created',
      'idx_notifications_read',
      'idx_files_queue_state',
    ]) {
      expect(names, contains(expected), reason: '$expected indeksi yo\'q');
    }
  });

  test('duty_events.client_event_id UNIQUE (M19)', () async {
    final DateTime now = DateTime.utc(2026, 9, 7);
    Future<void> insert() => db
        .into(db.dutyEvents)
        .insert(
          DutyEventsCompanion.insert(
            clientEventId: 'dup',
            eventType: 'status_change',
            eventTime: now,
            deviceSeq: 1,
            createdAt: now,
          ),
        );
    await insert();
    await expectLater(insert(), throwsA(isA<Exception>()));
  });

  test('telemetry_buffer (unit_id, ts) dublikati jimgina tashlanadi', () async {
    final DateTime ts = DateTime.utc(2026, 9, 7, 10);
    Future<void> insert() =>
        db.telemetryDao.insertPoint(TelemetryBufferCompanion.insert(unitId: 'u1', ts: ts));
    await insert();
    await insert();
    expect(await db.telemetryDao.countAll(), 1);
  });

  test('daily_logs (driver_id, log_date) UNIQUE — upsert almashtiradi', () async {
    final DateTime now = DateTime.utc(2026, 9, 7);
    await db.logsDao.upsertLog(
      DailyLogsCompanion.insert(
        logDate: '2026-09-07',
        driverId: 'd1',
        timezone: 'America/Chicago',
        updatedAt: now,
        distanceM: const Value<int>(10),
      ),
    );
    await db.logsDao.upsertLog(
      DailyLogsCompanion.insert(
        logDate: '2026-09-07',
        driverId: 'd1',
        timezone: 'America/Chicago',
        updatedAt: now,
        distanceM: const Value<int>(99),
      ),
    );
    final List<DailyLogRow> rows = await db.select(db.dailyLogs).get();
    expect(rows, hasLength(1));
    expect(rows.single.distanceM, 99);
  });

  test('sync_cursor yagona qatori ochilishda yaratiladi', () async {
    final SyncCursorRow? cursor = await db.settingsDao.cursor();
    expect(cursor, isNotNull);
    expect(cursor!.id, kSyncCursorId);
    expect(cursor.nextSince, isNull);
  });

  test('foreign_keys pragma yoqilgan', () async {
    final QueryRow row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.data.values.first, anyOf(1, true));
  });

  test('databaseSizeBytes musbat qiymat qaytaradi', () async {
    expect(await db.databaseSizeBytes(), greaterThan(0));
  });
}
