/// Chaos, ikki sessiya versiyasi: tarmoq uzilishi + ilova o'ldirilishi →
/// **0 event yo'qotish**, ikkala slot ham (NFR, M23, B-120, B-121).
///
/// Jarayon haqiqatan o'ldirilmaydi; ekvivalenti — bazani yopib fayl ustidan
/// **yangi** `AppDatabase` ochish.
@Timeout(Duration(seconds: 60))
library;

import 'dart:io';
import 'dart:math';

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/connection.dart';
import 'package:eld_mobile/core/security/active_slot.dart';
import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:eld_mobile/core/sync/mock_sync_transport.dart';
import 'package:eld_mobile/core/sync/outbox_repository.dart';
import 'package:eld_mobile/core/sync/sync_engine.dart';
import 'package:eld_mobile/core/sync/sync_transport.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

import '../helpers/test_clock.dart';

typedef _Session = ({
  AppDatabase db,
  OutboxRepository outbox,
  TimeSource time,
  ActiveSlotHolder holder,
});

void main() {
  late Directory dir;
  late String path;
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('eld_chaos_dual');
    path = '${dir.path}/eld_local.sqlite';
  });

  tearDown(() => dir.deleteSync(recursive: true));

  _Session open(FakeWallClock clock, {int seed = 7}) {
    final AppDatabase db = AppDatabase(openFileConnection(path));
    final TimeSource time = TimeSource(wallClock: clock.call, monotonic: FakeStopwatch(clock, t0))
      ..syncFromServer(clock());
    final ActiveSlotHolder holder = ActiveSlotHolder();
    return (
      db: db,
      outbox: OutboxRepository(db: db, time: time, activeSlot: holder, random: Random(seed)),
      time: time,
      holder: holder,
    );
  }

  test('ikki slotning navbati o\'ldirishdan keyin ham to\'liq saqlanadi', () async {
    final FakeWallClock clock = FakeWallClock(t0);
    final _Session first = open(clock);

    // 500 event: navbatma-navbat primary va co-driver yozadi.
    final Set<String> primaryIds = <String>{};
    final Set<String> coIds = <String>{};
    for (int i = 0; i < 500; i++) {
      final DriverSlot slot = i.isEven ? DriverSlot.primary : DriverSlot.coDriver;
      first.holder.value = slot;
      clock.advance(const Duration(seconds: 1));
      final EnqueuedEvent event = await first.outbox.enqueueDutyEvent(
        eventType: SyncEventType.statusChange,
        status: i.isEven ? 'ON' : 'OFF',
        driverId: slot == DriverSlot.primary ? 'd-primary' : 'd-co',
      );
      (slot == DriverSlot.primary ? primaryIds : coIds).add(event.clientEventId);
    }

    // Faqat co-driver batchi yuborildi, javob kelmadi — `inflight` da qoldi.
    final List<OutboxRecord> coDue = await first.db.outboxDao.dueRecords(
      now: clock(),
      limit: 1000,
      slots: <int>{kCoDriverSlot},
    );
    expect(coDue, hasLength(250));
    expect(coDue.every((OutboxRecord r) => r.sessionSlot == kCoDriverSlot), isTrue);
    await first.db.outboxDao.markInflight(
      ids: coDue.map((OutboxRecord r) => r.id).toList(),
      idempotencyKey: 'idem-co',
      now: clock(),
    );

    // --- «Ilova o'ldirildi» ---
    await first.db.close();
    await first.time.dispose();

    // --- Qayta ishga tushish ---
    final _Session second = open(clock, seed: 99);
    addTearDown(second.db.close);
    addTearDown(second.time.dispose);

    final List<OutboxItemRow> items = await second.db.select(second.db.outboxItems).get();
    expect(items, hasLength(500), reason: 'birorta ham navbat yozuvi yo\'qolmadi');
    expect(await second.db.select(second.db.dutyEvents).get(), hasLength(500));

    // Slot taqsimoti saqlangan — B-121 yozgan qiymat diskda ham to'g'ri.
    final Map<int, int> bySlot = <int, int>{};
    for (final OutboxItemRow row in items) {
      bySlot[row.sessionSlot] = (bySlot[row.sessionSlot] ?? 0) + 1;
    }
    expect(bySlot, <int, int>{kPrimarySlot: 250, kCoDriverSlot: 250});

    // M33.6: co-driver batchining kaliti saqlangan.
    final List<OutboxItemRow> stuck = items
        .where((OutboxItemRow i) => i.state == OutboxState.inflight.wire)
        .toList();
    expect(stuck, hasLength(250));
    expect(stuck.every((OutboxItemRow i) => i.sessionSlot == kCoDriverSlot), isTrue);
    expect(stuck.every((OutboxItemRow i) => i.idempotencyKey == 'idem-co'), isTrue);

    expect(await second.outbox.recoverAfterRestart(), 250);
    final List<OutboxItemRow> recovered = await second.db.select(second.db.outboxItems).get();
    expect(recovered.every((OutboxItemRow i) => i.state == OutboxState.pending.wire), isTrue);
    expect(recovered.where((OutboxItemRow i) => i.idempotencyKey == 'idem-co'), hasLength(250));

    // device_seq qurilma bo'yicha yagona va monoton (M20/B-122).
    expect(await second.db.settingsDao.currentDeviceSeq(), 500);
    final List<OutboxRecord> ordered = await second.db.outboxDao.dueRecords(
      now: clock(),
      limit: 2000,
    );
    expect(ordered, hasLength(500));
    for (int i = 1; i < ordered.length; i++) {
      expect(ordered[i].deviceSeq, greaterThan(ordered[i - 1].deviceSeq));
    }
  });

  test('tarmoq uzilib qayta paydo bo\'lganda ikkala slot ham yuboriladi', () async {
    final FakeWallClock clock = FakeWallClock(t0);
    final _Session session = open(clock);
    addTearDown(session.db.close);
    addTearDown(session.time.dispose);

    for (final DriverSlot slot in DriverSlot.values) {
      session.holder.value = slot;
      clock.advance(const Duration(seconds: 1));
      await session.outbox.enqueueDutyEvent(eventType: SyncEventType.statusChange, status: 'ON');
    }

    final MockSyncTransport transport = MockSyncTransport(serverTime: t0);
    SyncEngine engine() => SyncEngine(
      db: session.db,
      outbox: session.outbox,
      transport: transport,
      time: session.time,
      slotTokens: (DriverSlot _) async => true,
    );
    const SyncContext context = SyncContext(deviceId: 'dev-1', appVersion: '1.0.0');

    // 1) Tarmoq yo'q — hech narsa yo'qolmaydi.
    transport.failWith = const SyncTransportException(code: 'CLIENT_NETWORK');
    final SyncCycleResult offline = await engine().runCycle(context);
    expect(offline.ok, isFalse);
    expect(await session.db.outboxDao.pendingCountBySlot(), <int, int>{
      kPrimarySlot: 1,
      kCoDriverSlot: 1,
    });

    // Tarmoq umuman yo'q — birinchi guruhdan keyin sikl to'xtaydi.
    expect(transport.pushes, hasLength(1));
    transport.pushes.clear();

    // 2) Tarmoq qaytdi — har slot o'z so'roviga tushadi.
    transport.failWith = null;
    clock.advance(const Duration(minutes: 1));
    final SyncCycleResult online = await engine().runCycle(context);

    expect(online.ok, isTrue);
    expect(transport.pushes, hasLength(2));
    expect(transport.pushes.map((PushRequest r) => r.slot).toSet(), DriverSlot.values.toSet());
    expect(await session.db.outboxDao.pendingCountBySlot(), isEmpty);
  });
}
