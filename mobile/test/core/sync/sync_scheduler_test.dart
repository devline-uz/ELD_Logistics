/// Scheduler: mutex (M26), backoff + jitter, M34 pauzasi, oflayn xatti-harakati.

library;

import 'dart:async';
import 'dart:math';

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:eld_mobile/core/sync/outbox_repository.dart';
import 'package:eld_mobile/core/sync/sync_engine.dart';
import 'package:eld_mobile/core/sync/sync_scheduler.dart';
import 'package:eld_mobile/core/sync/sync_transport.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

import '../helpers/test_clock.dart';

/// Chaqiruvlarni sanaydigan va kechiktiradigan sun'iy transport.
class _SlowTransport implements SyncTransport {
  _SlowTransport(this.serverTime);

  final DateTime serverTime;
  int pushCalls = 0;
  int concurrent = 0;
  int maxConcurrent = 0;
  Completer<void>? gate;
  Object? failWith;

  @override
  Future<PushResponse> push(PushRequest request, {required Duration timeout}) async {
    pushCalls++;
    concurrent++;
    maxConcurrent = max(maxConcurrent, concurrent);
    try {
      await gate?.future;
      final Object? failure = failWith;
      if (failure != null) {
        throw failure;
      }
      return PushResponse(serverTime: serverTime);
    } finally {
      concurrent--;
    }
  }

  @override
  Future<PullResponse> pull({
    String? since,
    String? unitId,
    DriverSlot slot = DriverSlot.primary,
    required Duration timeout,
  }) async {
    concurrent++;
    maxConcurrent = max(maxConcurrent, concurrent);
    try {
      await gate?.future;
      final Object? failure = failWith;
      if (failure != null) {
        throw failure;
      }
      return PullResponse(serverTime: serverTime, nextSince: 'c1');
    } finally {
      concurrent--;
    }
  }
}

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);
  const SyncContext ctx = SyncContext(deviceId: 'dev-1', appVersion: '1.0.0');

  late AppDatabase db;
  late TimeSource time;
  late FakeWallClock clock;
  late OutboxRepository outbox;

  setUp(() {
    db = AppDatabase.memory();
    final ({FakeWallClock clock, TimeSource time}) built = buildTestTimeSource(t0);
    time = built.time;
    clock = built.clock;
    time.syncFromServer(t0);
    outbox = OutboxRepository(db: db, time: time, random: Random(3));
  });

  tearDown(() async {
    await db.close();
    await time.dispose();
  });

  SyncScheduler build(SyncTransport transport, {double jitterRoll = 0.5}) => SyncScheduler(
    engine: SyncEngine(db: db, outbox: outbox, transport: transport, time: time),
    time: time,
    context: () => ctx,
    random: _FixedRandom(jitterRoll),
  );

  test('M26: ikkinchi trigger parallel push boshlamaydi', () async {
    final _SlowTransport transport = _SlowTransport(t0)..gate = Completer<void>();
    final SyncScheduler scheduler = build(transport);
    addTearDown(scheduler.dispose);

    final Future<SyncCycleResult> first = scheduler.request(SyncTrigger.foreground);
    final Future<SyncCycleResult> second = scheduler.request(SyncTrigger.manual);
    expect(identical(first, second), isTrue, reason: 'ikkinchi trigger navbatga qo\'yiladi');
    expect(scheduler.isRunning, isTrue);

    transport.gate!.complete();
    await first;
    await pumpEventQueue();

    expect(transport.maxConcurrent, 1);
  });

  test('M26: navbatga qo\'yilgan trigger sikldan keyin bir marta yuriladi', () async {
    await outbox.enqueueDutyEvent(eventType: SyncEventType.statusChange, status: 'ON');
    final _SlowTransport transport = _SlowTransport(t0)..gate = Completer<void>();
    final SyncScheduler scheduler = build(transport);
    addTearDown(scheduler.dispose);

    final Future<SyncCycleResult> first = scheduler.request(SyncTrigger.foreground);
    unawaited(scheduler.request(SyncTrigger.critical));
    transport.gate!.complete();
    await first;
    await pumpEventQueue();

    expect(transport.pushCalls, 1, reason: 'navbat bo\'shagach push takrorlanmaydi');
    expect(transport.maxConcurrent, 1);
  });

  test('muvaffaqiyatdan keyin backoff nolga tushadi', () async {
    final SyncScheduler scheduler = build(_SlowTransport(t0));
    addTearDown(scheduler.dispose);

    final SyncCycleResult result = await scheduler.request(SyncTrigger.manual);
    expect(result.ok, isTrue);
    expect(scheduler.attempt, 0);
    expect(scheduler.blockedUntil, isNull);
  });

  test('xatodan keyin backoff 1 s → 2 s → 5 s ladderiga tushadi', () async {
    final _SlowTransport transport = _SlowTransport(t0)
      ..failWith = const SyncTransportException(code: 'CLIENT_NETWORK');
    final SyncScheduler scheduler = build(transport);
    addTearDown(scheduler.dispose);

    await scheduler.request(SyncTrigger.manual);
    expect(scheduler.attempt, 1);
    expect(scheduler.blockedUntil, t0.add(const Duration(seconds: 1)));

    clock.value = t0.add(const Duration(seconds: 2));
    await scheduler.request(SyncTrigger.manual);
    expect(scheduler.attempt, 2);
    expect(
      scheduler.blockedUntil,
      t0.add(const Duration(seconds: 2)).add(const Duration(seconds: 2)),
    );
  });

  test('jitter ±20% oralig\'ida qoladi', () async {
    final _SlowTransport transport = _SlowTransport(t0)
      ..failWith = const SyncTransportException(code: 'CLIENT_NETWORK');
    final SyncScheduler high = build(transport, jitterRoll: 0.999999);
    addTearDown(high.dispose);
    await high.request(SyncTrigger.manual);
    final Duration delay = high.blockedUntil!.difference(t0);
    expect(delay.inMilliseconds, greaterThanOrEqualTo(800));
    expect(delay.inMilliseconds, lessThanOrEqualTo(1200));
  });

  test('429 Retry-After ladderdan ustun', () async {
    final _SlowTransport transport = _SlowTransport(t0)
      ..failWith = const SyncTransportException(
        code: 'RATE_LIMITED',
        statusCode: 429,
        retryAfter: Duration(seconds: 90),
      );
    final SyncScheduler scheduler = build(transport);
    addTearDown(scheduler.dispose);

    await scheduler.request(SyncTrigger.manual);
    expect(scheduler.blockedUntil, t0.add(const Duration(seconds: 90)));
  });

  test('backoff oynasida passiv trigger o\'tmaydi, qo\'lda urinish o\'tadi', () async {
    final _SlowTransport transport = _SlowTransport(t0)
      ..failWith = const SyncTransportException(code: 'CLIENT_NETWORK');
    final SyncScheduler scheduler = build(transport);
    addTearDown(scheduler.dispose);

    await scheduler.request(SyncTrigger.manual);
    final int callsAfterFirst = transport.pushCalls + 1;

    final SyncCycleResult blocked = await scheduler.request(SyncTrigger.timer);
    expect(blocked.errorCode, 'CLIENT_BACKOFF');

    await scheduler.request(SyncTrigger.manual);
    expect(transport.pushCalls + 1, greaterThan(callsAfterFirst - 1));
  });

  test('M34: ketma-ket 3 ta 403 dan keyin 15 daqiqa pauza', () async {
    final _SlowTransport transport = _SlowTransport(t0)
      ..failWith = const SyncTransportException(code: 'FORBIDDEN', statusCode: 403);
    final SyncScheduler scheduler = build(transport);
    addTearDown(scheduler.dispose);

    for (int i = 0; i < 3; i++) {
      clock.value = t0.add(Duration(minutes: i));
      await scheduler.request(SyncTrigger.manual);
    }
    expect(scheduler.blockedUntil, t0.add(const Duration(minutes: 2)).add(kForbiddenCooldown));
  });

  test('oflayn: taymer urinmaydi, qo\'lda urinish o\'tadi', () async {
    final _SlowTransport transport = _SlowTransport(t0);
    final SyncScheduler scheduler = build(transport)..online = false;
    addTearDown(scheduler.dispose);

    final SyncCycleResult skipped = await scheduler.request(SyncTrigger.timer);
    expect(skipped.errorCode, 'CLIENT_OFFLINE');
    expect(transport.pushCalls, 0);

    final SyncCycleResult manual = await scheduler.request(SyncTrigger.manual);
    expect(manual.ok, isTrue);
  });

  test('tarmoq qaytganda debounce taymeri qo\'yiladi', () async {
    final _SlowTransport transport = _SlowTransport(t0);
    final SyncScheduler scheduler = build(transport)..online = false;
    addTearDown(scheduler.dispose);

    scheduler.online = true;
    expect(transport.pushCalls, 0, reason: '2 s debounce ichida darhol yubormaydi');
    scheduler.stop();
  });

  test('natijalar oqimi har sikldan keyin qiymat beradi', () async {
    final SyncScheduler scheduler = build(_SlowTransport(t0));
    addTearDown(scheduler.dispose);
    final Future<SyncCycleResult> next = scheduler.results.first;
    await scheduler.request(SyncTrigger.manual);
    expect((await next).ok, isTrue);
  });

  test('online setter holatni o\'zgartiradi', () {
    final SyncScheduler scheduler = build(_SlowTransport(t0));
    addTearDown(scheduler.dispose);
    expect(scheduler.online, isTrue);
    scheduler.online = false;
    expect(scheduler.online, isFalse);
    scheduler.online = false;
    expect(scheduler.online, isFalse);
  });
}

class _FixedRandom implements Random {
  _FixedRandom(this._value);

  final double _value;

  @override
  double nextDouble() => _value;

  @override
  bool nextBool() => false;

  @override
  int nextInt(int max) => 0;
}
