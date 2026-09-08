/// Chaos: tarmoq uzilishi + ilova o'ldirilishi → **0 event yo'qotish** (NFR, M23).
///
/// Jarayon haqiqatan o'ldirilmaydi; ekvivalenti — bazani yopmasdan/yopib fayl
/// ustidan **yangi** `AppDatabase` ochish (WAL bilan bir xil holat).

library;

import 'dart:io';
import 'dart:math';

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/connection.dart';
import 'package:eld_mobile/core/sync/outbox_repository.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

import '../helpers/test_clock.dart';

void main() {
  late Directory dir;
  late String path;
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('eld_chaos');
    path = '${dir.path}/eld_local.sqlite';
  });

  tearDown(() => dir.deleteSync(recursive: true));

  ({AppDatabase db, OutboxRepository outbox, TimeSource time}) open(
    FakeWallClock clock, {
    int seed = 7,
  }) {
    final AppDatabase db = AppDatabase(openFileConnection(path));
    final TimeSource time = TimeSource(wallClock: clock.call, monotonic: FakeStopwatch(clock, t0))
      ..syncFromServer(clock());
    return (db: db, outbox: OutboxRepository(db: db, time: time, random: Random(seed)), time: time);
  }

  test('ilova o\'ldirilib qayta ochilganda outbox to\'liq saqlanadi', () async {
    final FakeWallClock clock = FakeWallClock(t0);

    // --- 1-sessiya: 250 event navbatga tushadi, tarmoq yo'q ---
    final ({AppDatabase db, OutboxRepository outbox, TimeSource time}) first = open(clock);
    final List<String> ids = <String>[];
    for (int i = 0; i < 250; i++) {
      clock.advance(const Duration(seconds: 1));
      final EnqueuedEvent event = await first.outbox.enqueueDutyEvent(
        eventType: SyncEventType.statusChange,
        status: i.isEven ? 'ON' : 'OFF',
        driverId: 'd1',
      );
      ids.add(event.clientEventId);
    }
    // Batch yuborildi, javob kelmadi: elementlar `inflight` da qoldi.
    final List<OutboxRecord> due = await first.db.outboxDao.dueRecords(now: clock());
    await first.db.outboxDao.markInflight(
      ids: due.take(100).map((OutboxRecord r) => r.id).toList(),
      idempotencyKey: 'idem-1',
      now: clock(),
    );

    // --- «Ilova o'ldirildi»: close() chaqirilmaydi ---
    await first.db.close();

    // --- 2-sessiya ---
    final ({AppDatabase db, OutboxRepository outbox, TimeSource time}) second = open(
      clock,
      seed: 99,
    );
    addTearDown(second.db.close);

    final List<OutboxItemRow> items = await second.db.select(second.db.outboxItems).get();
    final List<DutyEventRow> events = await second.db.select(second.db.dutyEvents).get();

    expect(items, hasLength(250), reason: 'birorta ham navbat yozuvi yo\'qolmadi');
    expect(events, hasLength(250), reason: 'birorta ham event yo\'qolmadi');
    expect(items.map((OutboxItemRow i) => i.clientId).toSet(), ids.toSet());
    expect(await second.db.settingsDao.currentDeviceSeq(), 250);

    // M33.6: `inflight` elementlarning kaliti saqlangan.
    final List<OutboxItemRow> stuck = items
        .where((OutboxItemRow i) => i.state == OutboxState.inflight.wire)
        .toList();
    expect(stuck, hasLength(100));
    expect(stuck.every((OutboxItemRow i) => i.idempotencyKey == 'idem-1'), isTrue);

    // Ishga tushishda `inflight` → `pending`, kalit o'zgarmaydi.
    expect(await second.outbox.recoverAfterRestart(), 100);
    final List<OutboxItemRow> recovered = await second.db.select(second.db.outboxItems).get();
    expect(recovered.every((OutboxItemRow i) => i.state == OutboxState.pending.wire), isTrue);
    expect(recovered.where((OutboxItemRow i) => i.idempotencyKey == 'idem-1'), hasLength(100));

    // device_seq monotonligi restartdan keyin ham davom etadi (M20).
    clock.advance(const Duration(seconds: 1));
    final EnqueuedEvent next = await second.outbox.enqueueDutyEvent(
      eventType: SyncEventType.statusChange,
      status: 'ON',
    );
    expect(next.deviceSeq, 251);

    final List<OutboxRecord> ordered = await second.db.outboxDao.dueRecords(
      now: clock(),
      limit: 1000,
    );
    expect(ordered, hasLength(251));
    for (int i = 1; i < ordered.length; i++) {
      expect(ordered[i].deviceSeq, greaterThan(ordered[i - 1].deviceSeq));
    }
  });

  test('yarim yozilgan tranzaksiya restartdan keyin ko\'rinmaydi (M24)', () async {
    final FakeWallClock clock = FakeWallClock(t0);
    final ({AppDatabase db, OutboxRepository outbox, TimeSource time}) first = open(clock);

    await first.outbox.enqueueDutyEvent(eventType: SyncEventType.statusChange, status: 'ON');
    // Ikkinchisi validatsiyada yiqiladi — tranzaksiya rollback bo'ladi.
    await expectLater(
      first.outbox.enqueueDutyEvent(eventType: SyncEventType.statusChange, notes: 'x' * 900),
      throwsA(isA<OutboxValidationException>()),
    );
    await first.db.close();

    final ({AppDatabase db, OutboxRepository outbox, TimeSource time}) second = open(
      clock,
      seed: 99,
    );
    addTearDown(second.db.close);
    expect(await second.db.select(second.db.outboxItems).get(), hasLength(1));
    expect(await second.db.select(second.db.dutyEvents).get(), hasLength(1));
    expect(await second.db.settingsDao.currentDeviceSeq(), 1);
  });
}
