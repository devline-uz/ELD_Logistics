/// Sync sikli: tartib (M38), idempotentlik (M33), pull drenaji (M35/M36).

library;

import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:eld_mobile/core/sync/mock_sync_transport.dart';
import 'package:eld_mobile/core/sync/outbox_repository.dart';
import 'package:eld_mobile/core/sync/sync_engine.dart';
import 'package:eld_mobile/core/sync/sync_transport.dart';
import 'package:eld_mobile/core/time/clock_verdict.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

import '../helpers/test_clock.dart';

const SyncContext ctx = SyncContext(deviceId: 'dev-1', appVersion: '1.0.0', unitId: 'u1');

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  late AppDatabase db;
  late TimeSource time;
  late FakeWallClock clock;
  late OutboxRepository outbox;
  late MockSyncTransport transport;
  late SyncEngine engine;

  setUp(() {
    db = AppDatabase.memory();
    final ({FakeWallClock clock, TimeSource time}) built = buildTestTimeSource(t0);
    time = built.time;
    clock = built.clock;
    time.syncFromServer(t0);
    outbox = OutboxRepository(db: db, time: time, random: Random(1));
    transport = MockSyncTransport(serverTime: t0);
    engine = SyncEngine(db: db, outbox: outbox, transport: transport, time: time);
  });

  tearDown(() async {
    await db.close();
    await time.dispose();
  });

  Future<List<String>> enqueue(int count) async {
    final List<String> ids = <String>[];
    for (int i = 0; i < count; i++) {
      clock.advance(const Duration(seconds: 1));
      ids.add(
        (await outbox.enqueueDutyEvent(
          eventType: SyncEventType.statusChange,
          status: 'ON',
        )).clientEventId,
      );
    }
    return ids;
  }

  test('bo\'sh navbatda ham pull bajariladi va kursor yoziladi', () async {
    final SyncCycleResult result = await engine.runCycle(ctx);
    expect(result.ok, isTrue);
    expect(result.pushedItems, 0);
    expect(result.pulledBatches, 1);
    expect(transport.pushes, isEmpty);
    final SyncCursorRow? cursor = await db.settingsDao.cursor();
    expect(cursor!.nextSince, isNotNull);
    expect(cursor.lastPullAt, isNotNull);
  });

  test('M25: batch device_seq bo\'yicha o\'sish tartibida yuboriladi', () async {
    await enqueue(5);
    await engine.runCycle(ctx);

    expect(transport.pushes, hasLength(1));
    final List<Object?> seqs = transport.pushes.single.events
        .map((Map<String, Object?> e) => e['device_seq'])
        .toList();
    expect(seqs, <int>[1, 2, 3, 4, 5]);
  });

  test('accepted natijalar navbatni bo\'shatadi', () async {
    await enqueue(3);
    final SyncCycleResult result = await engine.runCycle(ctx);
    expect(result.acceptedItems, greaterThanOrEqualTo(3));

    final List<OutboxItemRow> items = await db.select(db.outboxItems).get();
    expect(items.every((OutboxItemRow i) => i.state == OutboxState.acked.wire), isTrue);
    expect(await db.outboxDao.dueRecords(now: time.now()), isEmpty);
  });

  test('M25: rejected element navbatni bloklamaydi', () async {
    final List<String> ids = await enqueue(3);
    transport.verdictFor = (String id) => id == ids[1]
        ? PushItemResult(clientId: id, result: 'rejected', reason: 'log_locked')
        : PushItemResult(clientId: id, result: 'accepted');

    final SyncCycleResult result = await engine.runCycle(ctx);
    expect(result.rejectedItems, 1);

    final Map<String, OutboxItemRow> items = <String, OutboxItemRow>{
      for (final OutboxItemRow row in await db.select(db.outboxItems).get()) row.clientId: row,
    };
    expect(items[ids[0]]!.state, OutboxState.acked.wire);
    expect(items[ids[1]]!.state, OutboxState.rejected.wire);
    expect(items[ids[2]]!.state, OutboxState.acked.wire);
  });

  test('M33.6: timeout dan keyin aynan o\'sha Idempotency-Key ketadi', () async {
    await enqueue(2);
    transport.failWith = const SyncTransportException(code: 'CLIENT_NETWORK');

    final SyncCycleResult failed = await engine.runCycle(ctx);
    expect(failed.ok, isFalse);
    final String firstKey = transport.pushes.single.idempotencyKey;

    final List<OutboxItemRow> stuck = await db.select(db.outboxItems).get();
    expect(stuck.every((OutboxItemRow i) => i.idempotencyKey == firstKey), isTrue);
    // M33.6: tarmoq xatosidan keyin element `inflight` da osilib qolmaydi.
    expect(
      stuck.every((OutboxItemRow i) => i.state == OutboxState.pending.wire),
      isTrue,
      reason: 'inflight osilib qolsa navbat bloklanadi',
    );
    expect(stuck.every((OutboxItemRow i) => i.attempts == 1), isTrue);

    // Ilova o'ldirilgan bo'lsa ham natija bir xil.
    await outbox.recoverAfterRestart();
    transport.failWith = null;
    await engine.runCycle(ctx);
    expect(transport.pushes, hasLength(2));
    expect(transport.pushes[1].idempotencyKey, firstKey);
  });

  test('M33.7: 409 IDEMPOTENCY_CONFLICT da yangi kalit bilan qayta yuboriladi', () async {
    await enqueue(2);
    int calls = 0;
    final MockSyncTransport conflicting = MockSyncTransport(serverTime: t0);
    final SyncEngine local = SyncEngine(
      db: db,
      outbox: outbox,
      transport: _ConflictOnceTransport(conflicting, () => calls++),
      time: time,
    );

    final SyncCycleResult result = await local.runCycle(ctx);
    expect(result.ok, isTrue);
    expect(calls, 2);
    expect(conflicting.pushes, hasLength(1));
  });

  test('M39: PushResponse.clock kanonik verdikt sifatida qo\'llanadi', () async {
    await enqueue(1);
    transport.clock = const ClockVerdict(
      source: EventTimeSource.eldRtc,
      clockSkewSec: 700,
      timeUnverified: true,
      malfunctionCode: 'T',
    );
    await engine.runCycle(ctx);
    expect(time.verdict!.malfunctionCode, 'T');
    expect(time.reading().level, ClockSkewLevel.malfunction);
  });

  test('telemetriya buferdan yuboriladi va sent=true bo\'ladi', () async {
    for (int i = 0; i < 3; i++) {
      await db.telemetryDao.insertPoint(
        TelemetryBufferCompanion.insert(
          unitId: 'u1',
          ts: t0.add(Duration(seconds: i)),
          speedKmh: const Value<double?>(62),
        ),
      );
    }
    await engine.runCycle(ctx);
    expect(transport.pushes.single.telemetry, hasLength(3));
    expect(await db.telemetryDao.unsent(), isEmpty);
  });

  test('M35: truncated bo\'lsa drenaj sikli davom etadi', () async {
    transport.pullQueue.addAll(<PullResponse>[
      PullResponse(serverTime: t0, nextSince: 'c1', truncated: true),
      PullResponse(serverTime: t0, nextSince: 'c2', truncated: true),
      PullResponse(serverTime: t0, nextSince: 'c3'),
    ]);
    final SyncCycleResult result = await engine.runCycle(ctx);
    expect(result.pulledBatches, 3);
    expect(transport.pullCursors, <String?>[null, 'c1', 'c2']);
    expect((await db.settingsDao.cursor())!.nextSince, 'c3');
  });

  test('M35: drenaj 20 iteratsiyada to\'xtaydi', () async {
    for (int i = 0; i < 30; i++) {
      transport.pullQueue.add(PullResponse(serverTime: t0, nextSince: 'c$i', truncated: true));
    }
    final SyncCycleResult result = await engine.runCycle(ctx);
    expect(result.pulledBatches, kMaxPullIterations);
  });

  test('M36/M37: pull server versiyasini qo\'llaydi va kursorni oxirida yozadi', () async {
    transport.pullQueue.add(
      PullResponse(
        serverTime: t0,
        nextSince: 'cursor-1',
        hosPolicy: const <String, Object?>{
          'version_id': 'p1',
          'effective_from': '2026-01-01T00:00:00Z',
          'payload': '{"cycle":70}',
        },
        quickNotes: const <Map<String, Object?>>[
          <String, Object?>{'id': 'q1', 'text': 'Pickup'},
        ],
        events: const <Map<String, Object?>>[
          <String, Object?>{
            'client_event_id': 'srv-event-1',
            'id': 'server-1',
            'event_type': 'status_change',
            'status': 'DR',
            'event_time': '2026-09-07T11:00:00Z',
            'device_seq': 4,
            'locked': true,
          },
        ],
        dailyLogs: const <Map<String, Object?>>[
          <String, Object?>{
            'log_date': '2026-09-07',
            'driver_id': 'd1',
            'timezone': 'America/Chicago',
            'certification_status': 'certified',
            'distance_m': 1200,
          },
        ],
        unidentifiedEvents: const <Map<String, Object?>>[
          <String, Object?>{
            'id': 'u-1',
            'unit_id': 'u1',
            'start_at': '2026-09-07T09:00:00Z',
            'status': 'pending',
          },
        ],
      ),
    );

    await engine.runCycle(ctx);

    final DutyEventRow? event = await db.dutyEventsDao.byClientEventId('srv-event-1');
    expect(event, isNotNull);
    expect(event!.serverId, 'server-1');
    expect(event.locked, isTrue);
    expect(event.syncState, 'acked');
    expect(await db.logsDao.policyAt(t0), isNotNull);
    expect((await db.select(db.refQuickNotes).get()).single.label, 'Pickup');
    expect((await db.select(db.dailyLogs).get()).single.certificationStatus, 'certified');
    expect((await db.select(db.unidentifiedEvents).get()), hasLength(1));
    expect((await db.settingsDao.cursor())!.nextSince, 'cursor-1');
  });

  test('transport xatosi sync_cursor.last_error ga yoziladi', () async {
    transport.failWith = const SyncTransportException(
      code: 'RATE_LIMITED',
      statusCode: 429,
      retryAfter: Duration(seconds: 30),
    );
    final SyncCycleResult result = await engine.runCycle(ctx);
    expect(result.ok, isFalse);
    expect(result.errorCode, 'RATE_LIMITED');
    expect(result.retryAfter, const Duration(seconds: 30));
    expect((await db.settingsDao.cursor())!.lastError, 'RATE_LIMITED');
  });

  test('403 natijasi forbidden bayrog\'ini ko\'taradi (M34)', () async {
    transport.failWith = const SyncTransportException(code: 'ACCOUNT_INACTIVE', statusCode: 403);
    final SyncCycleResult result = await engine.runCycle(ctx);
    expect(result.forbidden, isTrue);
  });

  test('timeout CLIENT_TIMEOUT sifatida qayd etiladi', () async {
    transport.failWith = TimeoutException('push');
    final SyncCycleResult result = await engine.runCycle(ctx);
    expect(result.errorCode, 'CLIENT_TIMEOUT');
  });

  test('timeout dan keyin ham element pending ga qaytadi (0 event yo\'qotish)', () async {
    await enqueue(3);
    transport.failWith = TimeoutException('push');
    await engine.runCycle(ctx);

    final List<OutboxItemRow> rows = await db.select(db.outboxItems).get();
    expect(rows, hasLength(3));
    expect(rows.every((OutboxItemRow i) => i.state == OutboxState.pending.wire), isTrue);
    expect(rows.every((OutboxItemRow i) => i.lastError == 'CLIENT_TIMEOUT'), isTrue);
    expect(rows.every((OutboxItemRow i) => i.idempotencyKey != null), isTrue);
  });

  test('deferQueue backoff kechikishini next_attempt_at ga yozadi', () async {
    await enqueue(2);
    final DateTime until = t0.add(const Duration(minutes: 5));
    await engine.deferQueue(until);
    expect((await db.outboxDao.dueItems(now: t0.add(const Duration(minutes: 1)))), isEmpty);

    await engine.releaseQueueNow();
    expect(await db.outboxDao.dueItems(now: time.now()), hasLength(2));
  });

  test('haydash rejimida push timeouti 15 s', () {
    expect(
      const SyncContext(deviceId: 'd', appVersion: '1', driving: true).pushTimeout,
      kPushTimeoutDriving,
    );
    expect(const SyncContext(deviceId: 'd', appVersion: '1').pushTimeout, kPushTimeout);
    expect(const SyncContext(deviceId: 'd', appVersion: '1', metered: true).limits.telemetry, 1000);
  });
}

/// Birinchi urinishda `409`, keyin muvaffaqiyat — M33.7 stsenariysi.
class _ConflictOnceTransport implements SyncTransport {
  _ConflictOnceTransport(this._inner, this._onCall);

  final MockSyncTransport _inner;
  final void Function() _onCall;
  bool _thrown = false;

  @override
  Future<PushResponse> push(PushRequest request, {required Duration timeout}) async {
    _onCall();
    if (!_thrown) {
      _thrown = true;
      throw const SyncTransportException(code: 'IDEMPOTENCY_CONFLICT', statusCode: 409);
    }
    return _inner.push(request, timeout: timeout);
  }

  @override
  Future<PullResponse> pull({
    String? since,
    String? unitId,
    DriverSlot slot = DriverSlot.primary,
    required Duration timeout,
  }) => _inner.pull(since: since, unitId: unitId, slot: slot, timeout: timeout);
}
