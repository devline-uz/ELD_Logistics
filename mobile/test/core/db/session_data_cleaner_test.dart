/// **S-M4:** boshqa `user_id` login qilganda lokal domen ma'lumoti qolmaydi,
/// **M17:** yuborilmagan navbat esa hech qachon o'chirilmaydi.
@Timeout(Duration(seconds: 60))
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/daos/settings_dao.dart';
import 'package:eld_mobile/core/db/session_data_cleaner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  late AppDatabase db;
  late SessionDataCleaner cleaner;

  setUp(() {
    db = AppDatabase.memory();
    cleaner = SessionDataCleaner(db);
  });

  tearDown(() => db.close());

  Future<void> setDriver(String id) => db.settingsDao.put(key: KvKeys.driverId, value: id, now: t0);

  /// `state` holatidagi navbat elementi + uning biznes ko'zgusi.
  Future<void> seedQueuedEvent(String clientId, {OutboxState state = OutboxState.pending}) async {
    await db
        .into(db.outboxItems)
        .insert(
          OutboxItemsCompanion.insert(
            kind: OutboxKind.event.wire,
            payload: '{}',
            clientId: clientId,
            deviceSeq: 1,
            createdAt: t0,
            nextAttemptAt: t0,
            updatedAt: t0,
            state: Value<String>(state.wire),
          ),
        );
    await db
        .into(db.dutyEvents)
        .insert(
          DutyEventsCompanion.insert(
            clientEventId: clientId,
            eventType: 'status_change',
            eventTime: t0,
            deviceSeq: 1,
            createdAt: t0,
            driverId: const Value<String?>('d-old'),
          ),
        );
  }

  Future<void> seedDomainRows() async {
    await db
        .into(db.chatMessages)
        .insert(
          ChatMessagesCompanion.insert(
            id: 'm1',
            conversationId: const Value<String?>('c1'),
            kind: 'text',
            body: const Value<String?>('salom'),
            createdAt: t0,
          ),
        );
    await db
        .into(db.notifications)
        .insert(
          NotificationsCompanion.insert(
            id: 'n1',
            alertType: 'hos',
            title: 'T',
            body: 'B',
            createdAt: t0,
          ),
        );
    await db
        .into(db.dvirReports)
        .insert(
          DvirReportsCompanion.insert(
            id: 'r1',
            status: 'open',
            kind: 'pre_trip',
            type: 'truck',
            unitId: 'u1',
            createdAt: t0,
            payload: const Value<Map<String, Object?>>(<String, Object?>{}),
          ),
        );
    await db
        .into(db.dailyLogs)
        .insert(
          DailyLogsCompanion.insert(
            logDate: '2026-09-06',
            driverId: 'd-old',
            timezone: 'America/Chicago',
            updatedAt: t0,
          ),
        );
    await db
        .into(db.filesQueue)
        .insert(
          FilesQueueCompanion.insert(
            localPath: '/tmp/a.png',
            kind: 'signature',
            contentType: 'image/png',
            sizeBytes: 10,
            createdAt: t0,
            state: const Value<String>('uploaded'),
          ),
        );
    await db
        .into(db.filesQueue)
        .insert(
          FilesQueueCompanion.insert(
            localPath: '/tmp/b.png',
            kind: 'dvir_photo',
            contentType: 'image/jpeg',
            sizeBytes: 20,
            createdAt: t0,
            state: const Value<String>('pending'),
          ),
        );
    await db
        .into(db.telemetryBuffer)
        .insert(
          TelemetryBufferCompanion.insert(unitId: 'u1', ts: t0, sent: const Value<bool>(true)),
        );
    await db
        .into(db.telemetryBuffer)
        .insert(
          TelemetryBufferCompanion.insert(unitId: 'u1', ts: t0.add(const Duration(minutes: 1))),
        );
  }

  test('boshqa haydovchi kirsa domen jadvallari tozalanadi', () async {
    await setDriver('d-old');
    await seedDomainRows();

    final SessionResetReport report = await cleaner.switchDriver(driverId: 'd-new');

    expect(report.wiped, isTrue);
    expect(report.deletedRows, greaterThan(0));
    expect(await db.select(db.chatMessages).get(), isEmpty);
    expect(await db.select(db.notifications).get(), isEmpty);
    expect(await db.select(db.dvirReports).get(), isEmpty);
    expect(await db.select(db.dailyLogs).get(), isEmpty);
  });

  test('bir xil haydovchi qayta kirsa hech narsa o\'chmaydi', () async {
    await setDriver('d-old');
    await seedDomainRows();

    final SessionResetReport report = await cleaner.switchDriver(driverId: 'd-old');

    expect(report.wiped, isFalse);
    expect(await db.select(db.chatMessages).get(), hasLength(1));
  });

  test('birinchi kirishda tozalash o\'tkazilmaydi', () async {
    final SessionResetReport report = await cleaner.switchDriver(driverId: 'd-new');
    expect(report.wiped, isFalse);
  });

  test('logout (driverId=null) ham tozalaydi', () async {
    await setDriver('d-old');
    await seedDomainRows();
    expect((await cleaner.switchDriver(driverId: null)).wiped, isTrue);
    expect(await db.select(db.chatMessages).get(), isEmpty);
  });

  test('M17: yuborilmagan navbat va uning ko\'zgusi saqlanadi', () async {
    await setDriver('d-old');
    await seedQueuedEvent('pending-1');
    await seedQueuedEvent('inflight-1', state: OutboxState.inflight);
    await seedQueuedEvent('acked-1', state: OutboxState.acked);

    final SessionResetReport report = await cleaner.switchDriver(driverId: 'd-new');

    expect(report.preservedOutboxItems, 2);
    // Navbatning o'zi butunligicha qoladi — hatto `acked` ham (retention job
    // uni 30 kundan keyin o'chiradi, M23).
    expect(await db.select(db.outboxItems).get(), hasLength(3));

    final List<String> events =
        (await db.select(db.dutyEvents).get()).map((DutyEventRow r) => r.clientEventId).toList()
          ..sort();
    expect(events, <String>['inflight-1', 'pending-1']);
  });

  test('yuklanmagan fayl va yuborilmagan telemetriya qoladi', () async {
    await setDriver('d-old');
    await seedDomainRows();

    await cleaner.switchDriver(driverId: 'd-new');

    final List<FileQueueRow> files = await db.select(db.filesQueue).get();
    expect(files.map((FileQueueRow f) => f.state), <String>['pending']);

    final List<TelemetryRow> telemetry = await db.select(db.telemetryBuffer).get();
    expect(telemetry.map((TelemetryRow t) => t.sent), <bool>[false]);
  });

  test('sessiya profili PII si va kursor tozalanadi', () async {
    await setDriver('d-old');
    await db.settingsDao.put(key: KvKeys.driverName, value: 'Ali Valiyev', now: t0);
    await db.settingsDao.put(key: KvKeys.themeMode, value: 'dark', now: t0);
    await db.settingsDao.put(key: KvKeys.deviceId, value: 'dev-1', now: t0);
    await db.settingsDao.setNextSince('cursor-1');

    await cleaner.switchDriver(driverId: 'd-new');

    expect(await db.settingsDao.get(KvKeys.driverName), isNull);
    expect(await db.settingsDao.get(KvKeys.driverId), isNull);
    // Qurilma va UI sozlamalari sessiyaga bog'liq emas — qoladi.
    expect(await db.settingsDao.get(KvKeys.deviceId), 'dev-1');
    expect(await db.settingsDao.get(KvKeys.themeMode), 'dark');

    final SyncCursorRow? cursor = await db.settingsDao.cursor();
    expect(cursor?.nextSince, isNull);
  });

  test('device_seq monotonligi tozalashdan keyin ham buzilmaydi (M20)', () async {
    await setDriver('d-old');
    final int before = await db.settingsDao.nextDeviceSeq(t0);

    await cleaner.switchDriver(driverId: 'd-new');

    expect(await db.settingsDao.nextDeviceSeq(t0), before + 1);
  });

  test('wipe() to\'g\'ridan-to\'g\'ri chaqirilsa ham hisobot beradi', () async {
    await seedDomainRows();
    final SessionResetReport report = await cleaner.wipe();
    expect(report.wiped, isTrue);
    expect(report.toString(), contains('wiped: true'));
  });
}
