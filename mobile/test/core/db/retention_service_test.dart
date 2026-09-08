/// Retention job va 100 MB byudjet (§5.2, M23).

library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/retention_service.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

import '../helpers/test_clock.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  late AppDatabase db;
  late TimeSource time;
  late List<String> deleted;
  late RetentionService retention;

  setUp(() {
    db = AppDatabase.memory();
    time = buildTestTimeSource(t0).time..syncFromServer(t0);
    deleted = <String>[];
    retention = RetentionService(
      db: db,
      time: time,
      deleteFile: (String path) async => deleted.add(path),
    );
  });

  tearDown(() async {
    await db.close();
    await time.dispose();
  });

  Future<void> addEvent({required String id, required DateTime at, required String syncState}) => db
      .into(db.dutyEvents)
      .insert(
        DutyEventsCompanion.insert(
          clientEventId: id,
          eventType: 'status_change',
          eventTime: at,
          deviceSeq: 1,
          createdAt: at,
          syncState: Value<String>(syncState),
        ),
      );

  test('M23: faqat acked va 30 kundan eski eventlar o\'chadi', () async {
    await addEvent(id: 'old-acked', at: t0.subtract(const Duration(days: 31)), syncState: 'acked');
    await addEvent(
      id: 'old-pending',
      at: t0.subtract(const Duration(days: 400)),
      syncState: 'pending',
    );
    await addEvent(id: 'new-acked', at: t0.subtract(const Duration(days: 5)), syncState: 'acked');
    await addEvent(
      id: 'old-rejected',
      at: t0.subtract(const Duration(days: 90)),
      syncState: 'rejected',
    );

    final RetentionReport report = await retention.run();
    expect(report.deletedEvents, 1);

    final Set<String> left = (await db.select(db.dutyEvents).get())
        .map((DutyEventRow e) => e.clientEventId)
        .toSet();
    expect(left, <String>{'old-pending', 'new-acked', 'old-rejected'});
  });

  test('telemetriya: sent=true va 48 soatdan eski o\'chadi', () async {
    await db.telemetryDao.insertPoint(
      TelemetryBufferCompanion.insert(
        unitId: 'u1',
        ts: t0.subtract(const Duration(days: 3)),
        sent: const Value<bool>(true),
      ),
    );
    await db.telemetryDao.insertPoint(
      TelemetryBufferCompanion.insert(
        unitId: 'u1',
        ts: t0.subtract(const Duration(days: 3, hours: 1)),
      ),
    );
    await db.telemetryDao.insertPoint(
      TelemetryBufferCompanion.insert(
        unitId: 'u1',
        ts: t0.subtract(const Duration(hours: 1)),
        sent: const Value<bool>(true),
      ),
    );

    final RetentionReport report = await retention.run();
    expect(report.deletedTelemetry, 1);
    expect(await db.telemetryDao.countAll(), 2);
  });

  test('chat LRU: 30 kundan eski va oxirgi 500 tadan tashqaridagilar', () async {
    for (int i = 0; i < 5; i++) {
      await db.chatDao.upsertMessage(
        ChatMessagesCompanion.insert(
          id: 'm$i',
          kind: 'text',
          createdAt: t0.subtract(Duration(days: 40 + i)),
        ),
      );
    }
    final RetentionService small = RetentionService(
      db: db,
      time: time,
      policy: const RetentionPolicy(chatMaxMessages: 2),
      deleteFile: (String path) async {},
    );
    final RetentionReport report = await small.run();
    expect(report.deletedChatMessages, 3);
    expect((await db.select(db.chatMessages).get()), hasLength(2));
  });

  test('yuklangan fayllar 7 kundan keyin diskdan ham o\'chadi', () async {
    await db.dvirDao.enqueueFile(
      FilesQueueCompanion.insert(
        localPath: '/tmp/a.jpg',
        kind: 'dvir_photo',
        contentType: 'image/jpeg',
        sizeBytes: 100,
        createdAt: t0.subtract(const Duration(days: 20)),
        state: const Value<String>('uploaded'),
        uploadedAt: Value<DateTime?>(t0.subtract(const Duration(days: 8))),
      ),
    );
    await db.dvirDao.enqueueFile(
      FilesQueueCompanion.insert(
        localPath: '/tmp/b.jpg',
        kind: 'dvir_photo',
        contentType: 'image/jpeg',
        sizeBytes: 100,
        createdAt: t0,
        state: const Value<String>('pending'),
      ),
    );

    final RetentionReport report = await retention.run();
    expect(report.deletedFiles, 1);
    expect(deleted, <String>['/tmp/a.jpg']);
    expect((await db.select(db.filesQueue).get()).single.localPath, '/tmp/b.jpg');
  });

  test('byudjet oshsa eng eski telemetriya 10% o\'chadi, eventlar tegilmaydi', () async {
    for (int i = 0; i < 20; i++) {
      await db.telemetryDao.insertPoint(
        TelemetryBufferCompanion.insert(
          unitId: 'u1',
          ts: t0.add(Duration(seconds: i)),
        ),
      );
    }
    await addEvent(id: 'keep', at: t0, syncState: 'acked');

    final RetentionService tight = RetentionService(
      db: db,
      time: time,
      budget: const StorageBudget(maxBytes: 200, softLimitBytes: 100),
      deleteFile: (String path) async {},
    );
    final RetentionReport report = await tight.run();

    expect(report.deletedTrimmedTelemetry, 2);
    expect(await db.telemetryDao.countAll(), 18);
    expect(await db.dutyEventsDao.countAll(), 1, reason: 'M23: eventlarga tegilmaydi');

    // Eng eskilari o'chgan.
    final List<TelemetryRow> left = await db.select(db.telemetryBuffer).get();
    expect(left.first.ts, t0.add(const Duration(seconds: 2)));
  });

  test('checkBudget joriy holatni qaytaradi', () async {
    final BudgetVerdict verdict = await retention.checkBudget();
    expect(verdict.overSoftLimit, isFalse);
    expect(verdict.telemetryRowsToDrop, 0);
  });

  test('hisobot maydonlari to\'ldiriladi', () async {
    final RetentionReport report = await retention.run();
    expect(report.sizeBytesBefore, greaterThan(0));
    expect(report.sizeBytesAfter, greaterThan(0));
    expect(report.deletedTotal, 0);
  });
}
