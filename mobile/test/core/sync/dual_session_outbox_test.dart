/// Ikki sessiya (co-driver) rejimida outbox — **B-120** va **B-121**.
///
/// Kafolat: har haydovchining navbati **faqat o'z tokeni** bilan ketadi,
/// faol bo'lmagan slotning navbati yo'qolmaydi, `device_seq` tartibi
/// buzilmaydi.
@Timeout(Duration(seconds: 60))
library;

import 'dart:math';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/security/active_slot.dart';
import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:eld_mobile/core/sync/mock_sync_transport.dart';
import 'package:eld_mobile/core/sync/outbox_repository.dart';
import 'package:eld_mobile/core/sync/session_slot.dart';
import 'package:eld_mobile/core/sync/sync_engine.dart';
import 'package:eld_mobile/core/sync/sync_transport.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

import '../helpers/test_clock.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  late AppDatabase db;
  late TimeSource time;
  late FakeWallClock clock;
  late ActiveSlotHolder holder;
  late OutboxRepository outbox;
  late MockSyncTransport transport;

  /// Tokeni bor slotlar — testda qo'lda boshqariladi.
  late Set<DriverSlot> tokens;

  SyncEngine buildEngine({bool gated = true}) => SyncEngine(
    db: db,
    outbox: outbox,
    transport: transport,
    time: time,
    slotTokens: gated ? (DriverSlot slot) async => tokens.contains(slot) : null,
  );

  SyncContext contextFor(DriverSlot slot) =>
      SyncContext(deviceId: 'dev-1', appVersion: '1.0.0', unitId: 'u1', activeSlot: slot);

  setUp(() {
    db = AppDatabase.memory();
    final ({FakeWallClock clock, TimeSource time}) built = buildTestTimeSource(t0);
    time = built.time;
    clock = built.clock;
    time.syncFromServer(t0);
    holder = ActiveSlotHolder();
    outbox = OutboxRepository(db: db, time: time, activeSlot: holder, random: Random(7));
    transport = MockSyncTransport(serverTime: t0);
    tokens = <DriverSlot>{DriverSlot.primary, DriverSlot.coDriver};
  });

  tearDown(() async {
    await db.close();
    await time.dispose();
  });

  /// Faol slotni almashtirib bitta duty event yozadi.
  Future<EnqueuedEvent> enqueueAs(DriverSlot slot, {String? driverId}) async {
    holder.value = slot;
    clock.advance(const Duration(seconds: 1));
    return outbox.enqueueDutyEvent(
      eventType: SyncEventType.statusChange,
      status: 'ON',
      driverId: driverId,
    );
  }

  Future<List<int>> slotsInQueue() async {
    final List<OutboxItemRow> rows = await db.select(db.outboxItems).get();
    return rows.map((OutboxItemRow r) => r.sessionSlot).toList(growable: false);
  }

  // --- B-121 ---------------------------------------------------------------

  group('B-121: session_slot faol slotdan olinadi', () {
    test('primary yozuvi 0, co-driver yozuvi 1 slotga tushadi', () async {
      await enqueueAs(DriverSlot.primary, driverId: 'd-primary');
      await enqueueAs(DriverSlot.coDriver, driverId: 'd-co');

      expect(await slotsInQueue(), <int>[kPrimarySlot, kCoDriverSlot]);
    });

    test('`enqueue` (dvir/chat/certify) ham faol slotni oladi', () async {
      holder.value = DriverSlot.coDriver;
      await outbox.enqueue(
        kind: OutboxKind.dvir,
        payload: const <String, Object?>{'unit_id': 'u1'},
        userId: 'd-co',
      );
      expect(await slotsInQueue(), <int>[kCoDriverSlot]);
    });

    test('aniq berilgan sessionSlot faol slotdan ustun turadi', () async {
      holder.value = DriverSlot.coDriver;
      await outbox.enqueue(
        kind: OutboxKind.chat,
        payload: const <String, Object?>{'body': 'hi'},
        sessionSlot: kPrimarySlot,
      );
      expect(await slotsInQueue(), <int>[kPrimarySlot]);
    });

    test('holder berilmasa standart slot — primary (regressiyani oldini olish)', () async {
      final OutboxRepository plain = OutboxRepository(db: db, time: time, random: Random(1));
      await plain.enqueue(kind: OutboxKind.feedback, payload: const <String, Object?>{'x': 1});
      expect(await slotsInQueue(), <int>[kPrimarySlot]);
      expect(plain.activeSlot, DriverSlot.primary);
    });
  });

  // --- B-120 ---------------------------------------------------------------

  group('B-120: har slot o\'z tokeni bilan yuboriladi', () {
    test('ikki slotdagi yozuv ikkita alohida so\'rovga bo\'linadi', () async {
      final EnqueuedEvent primary = await enqueueAs(DriverSlot.primary, driverId: 'd-primary');
      final EnqueuedEvent co = await enqueueAs(DriverSlot.coDriver, driverId: 'd-co');

      await buildEngine().runCycle(contextFor(DriverSlot.primary));

      expect(transport.pushes, hasLength(2));
      final PushRequest first = transport.pushes[0];
      final PushRequest second = transport.pushes[1];

      // Faol slot birinchi ketadi.
      expect(first.slot, DriverSlot.primary);
      expect(second.slot, DriverSlot.coDriver);

      // Hech bir so'rovda ikkinchi haydovchining eventi yo'q.
      expect(first.events.single['client_event_id'], primary.clientEventId);
      expect(second.events.single['client_event_id'], co.clientEventId);

      // Har batchning `Idempotency-Key` i alohida (M33.3).
      expect(first.idempotencyKey, isNot(second.idempotencyKey));
    });

    test('faol slot co-driver bo\'lsa uning navbati birinchi ketadi', () async {
      await enqueueAs(DriverSlot.primary);
      await enqueueAs(DriverSlot.coDriver);

      await buildEngine().runCycle(contextFor(DriverSlot.coDriver));

      expect(transport.pushes.map((PushRequest r) => r.slot), <DriverSlot>[
        DriverSlot.coDriver,
        DriverSlot.primary,
      ]);
    });

    test('tokeni yo\'q slot yuborilmaydi, navbati esa saqlanadi (M17)', () async {
      await enqueueAs(DriverSlot.primary);
      final EnqueuedEvent co = await enqueueAs(DriverSlot.coDriver);
      tokens = <DriverSlot>{DriverSlot.primary};

      final SyncCycleResult result = await buildEngine().runCycle(contextFor(DriverSlot.primary));

      expect(result.ok, isTrue);
      expect(transport.pushes, hasLength(1));
      expect(transport.pushes.single.slot, DriverSlot.primary);

      final Map<int, int> pending = await db.outboxDao.pendingCountBySlot();
      expect(pending[kCoDriverSlot], 1);

      final OutboxItemRow row = await (db.select(
        db.outboxItems,
      )..where(($OutboxItemsTable t) => t.clientId.equals(co.clientEventId))).getSingle();
      expect(OutboxState.fromWire(row.state), OutboxState.pending);
      expect(row.attempts, 0, reason: 'urinish hisoblanmasin — so\'rov umuman ketmadi');
    });

    test('token paydo bo\'lgach kutayotgan co-driver navbati yuboriladi', () async {
      final EnqueuedEvent co = await enqueueAs(DriverSlot.coDriver);
      tokens = <DriverSlot>{DriverSlot.primary};
      await buildEngine().runCycle(contextFor(DriverSlot.primary));
      expect(transport.pushes, isEmpty);

      tokens = <DriverSlot>{DriverSlot.primary, DriverSlot.coDriver};
      // Mock pull `server_time` ni t0 ga qaytaradi — navbat yana «due»
      // bo'lishi uchun soatni suramiz.
      clock.advance(const Duration(minutes: 1));
      await buildEngine().runCycle(contextFor(DriverSlot.primary));

      expect(transport.pushes, hasLength(1));
      expect(transport.pushes.single.slot, DriverSlot.coDriver);
      expect(transport.pushes.single.events.single['client_event_id'], co.clientEventId);
    });

    test('faol bo\'lmagan slot pauzada bo\'lsa ham navbati ketadi', () async {
      await enqueueAs(DriverSlot.coDriver);
      // Faol — primary, co-driver `paused`, lekin refresh tokeni bor.
      await buildEngine().runCycle(contextFor(DriverSlot.primary));

      expect(transport.pushes.single.slot, DriverSlot.coDriver);
    });

    test('telemetriya faol slot sessiyasidan ketadi', () async {
      await db
          .into(db.telemetryBuffer)
          .insert(
            TelemetryBufferCompanion.insert(
              unitId: 'u1',
              ts: t0,
              lat: const Value<double?>(41.0),
              lng: const Value<double?>(69.0),
            ),
          );

      await buildEngine().runCycle(contextFor(DriverSlot.coDriver));

      expect(transport.pushes, hasLength(1));
      expect(transport.pushes.single.slot, DriverSlot.coDriver);
      expect(transport.pushes.single.telemetry, hasLength(1));
    });

    test('pull faol slot nomidan qilinadi', () async {
      await buildEngine().runCycle(contextFor(DriverSlot.coDriver));
      expect(transport.pullSlots, isNotEmpty);
      expect(transport.pullSlots.every((DriverSlot s) => s == DriverSlot.coDriver), isTrue);
    });

    test('bir slotdagi 401 ikkinchi slotni bloklamaydi', () async {
      await enqueueAs(DriverSlot.primary);
      await enqueueAs(DriverSlot.coDriver);

      final _PerSlotTransport failing = _PerSlotTransport(
        inner: transport,
        failFor: DriverSlot.primary,
        error: const SyncTransportException(code: 'UNAUTHORIZED', statusCode: 401),
      );
      final SyncEngine engine = SyncEngine(
        db: db,
        outbox: outbox,
        transport: failing,
        time: time,
        slotTokens: (DriverSlot slot) async => tokens.contains(slot),
      );

      final SyncCycleResult result = await engine.runCycle(contextFor(DriverSlot.primary));

      // Sikl xato bilan tugaydi (scheduler backoff qiladi), lekin co-driver
      // batchi baribir yuborilgan.
      expect(result.ok, isFalse);
      expect(result.errorCode, 'UNAUTHORIZED');
      expect(transport.pushes.map((PushRequest r) => r.slot), contains(DriverSlot.coDriver));
    });

    test('tarmoq umuman yo\'q bo\'lsa ikkinchi slot urinilmaydi', () async {
      await enqueueAs(DriverSlot.primary);
      await enqueueAs(DriverSlot.coDriver);

      final _PerSlotTransport offline = _PerSlotTransport(
        inner: transport,
        failFor: DriverSlot.primary,
        error: const SyncTransportException(code: 'CLIENT_NETWORK'),
      );
      final SyncEngine engine = SyncEngine(
        db: db,
        outbox: outbox,
        transport: offline,
        time: time,
        slotTokens: (DriverSlot slot) async => tokens.contains(slot),
      );

      final SyncCycleResult result = await engine.runCycle(contextFor(DriverSlot.primary));

      expect(result.ok, isFalse);
      expect(transport.pushes, isEmpty);
      // 0 yo'qotish: ikkala element ham navbatda.
      final Map<int, int> pending = await db.outboxDao.pendingCountBySlot();
      expect(pending[kPrimarySlot], 1);
      expect(pending[kCoDriverSlot], 1);
    });
  });

  // --- M20/M25 -------------------------------------------------------------

  group('M20/M25: device_seq ikki slotda ham monoton', () {
    test('1000 event ikki slotga taqsimlanadi, tartib buzilmaydi', () async {
      final List<int> expectedPrimary = <int>[];
      final List<int> expectedCo = <int>[];
      for (int i = 0; i < 1000; i++) {
        final DriverSlot slot = i.isEven ? DriverSlot.primary : DriverSlot.coDriver;
        final EnqueuedEvent event = await enqueueAs(slot);
        (slot == DriverSlot.primary ? expectedPrimary : expectedCo).add(event.deviceSeq);
      }

      // Qurilma bo'yicha yagona hisoblagich (B-122): 1…1000, takrorsiz.
      final Set<int> all = <int>{...expectedPrimary, ...expectedCo};
      expect(all, hasLength(1000));
      expect(all.reduce(min), 1);
      expect(all.reduce(max), 1000);

      final List<OutboxRecord> due = await db.outboxDao.dueRecords(now: time.now(), limit: 2000);
      final List<SlotBatch> groups = selectBatchesBySlot(
        candidates: due,
        now: time.now(),
        limits: const BatchLimits(events: 1000),
      );
      expect(groups, hasLength(2));
      for (final SlotBatch group in groups) {
        final List<int> seqs = group.batch.items
            .map((OutboxRecord i) => i.deviceSeq)
            .toList(growable: false);
        expect(seqs, orderedEquals(<int>[...seqs]..sort()));
        expect(seqs, seqs.toSet().toList()..sort());
      }
      expect(
        groups
            .firstWhere((SlotBatch g) => g.sessionSlot == kPrimarySlot)
            .batch
            .items
            .map((OutboxRecord i) => i.deviceSeq),
        expectedPrimary,
      );
      expect(
        groups
            .firstWhere((SlotBatch g) => g.sessionSlot == kCoDriverSlot)
            .batch
            .items
            .map((OutboxRecord i) => i.deviceSeq),
        expectedCo,
      );
    });
  });

  // --- DAO -----------------------------------------------------------------

  group('OutboxDao slot filtri', () {
    test('dueRecords faqat ruxsat etilgan slotlarni qaytaradi', () async {
      await enqueueAs(DriverSlot.primary);
      await enqueueAs(DriverSlot.coDriver);

      final List<OutboxRecord> onlyPrimary = await db.outboxDao.dueRecords(
        now: time.now(),
        slots: <int>{kPrimarySlot},
      );
      expect(onlyPrimary, hasLength(1));
      expect(onlyPrimary.single.sessionSlot, kPrimarySlot);

      final List<OutboxRecord> both = await db.outboxDao.dueRecords(now: time.now());
      expect(both, hasLength(2));
    });

    test('pendingCountBySlot navbat kesimini beradi', () async {
      await enqueueAs(DriverSlot.coDriver);
      await enqueueAs(DriverSlot.coDriver);
      await enqueueAs(DriverSlot.primary);
      expect(await db.outboxDao.pendingCountBySlot(), <int, int>{
        kPrimarySlot: 1,
        kCoDriverSlot: 2,
      });
    });
  });

  group('session_slot ↔ DriverSlot ko\'prigi', () {
    test('ikki yo\'nalishda ham barqaror', () {
      expect(slotColumn(DriverSlot.primary), kPrimarySlot);
      expect(slotColumn(DriverSlot.coDriver), kCoDriverSlot);
      expect(slotFromColumn(kPrimarySlot), DriverSlot.primary);
      expect(slotFromColumn(kCoDriverSlot), DriverSlot.coDriver);
      // Noma'lum qiymat fail-safe tarzda primary ga tushadi.
      expect(slotFromColumn(42), DriverSlot.primary);
    });

    test('resolveAllowedSlots zond natijasini ustun qiymatlarga o\'giradi', () async {
      expect(
        await resolveAllowedSlots((DriverSlot slot) async => slot == DriverSlot.coDriver),
        <int>{kCoDriverSlot},
      );
      expect(await resolveAllowedSlots((DriverSlot _) async => false), isEmpty);
    });
  });
}

/// Belgilangan slot uchun xato beradigan, qolganini ichki mock'ka uzatadigan
/// transport.
class _PerSlotTransport implements SyncTransport {
  _PerSlotTransport({required this.inner, required this.failFor, required this.error});

  final MockSyncTransport inner;
  final DriverSlot failFor;
  final Object error;

  @override
  Future<PushResponse> push(PushRequest request, {required Duration timeout}) {
    if (request.slot == failFor) {
      throw error;
    }
    return inner.push(request, timeout: timeout);
  }

  @override
  Future<PullResponse> pull({
    String? since,
    String? unitId,
    DriverSlot slot = DriverSlot.primary,
    required Duration timeout,
  }) => inner.pull(since: since, unitId: unitId, slot: slot, timeout: timeout);
}
