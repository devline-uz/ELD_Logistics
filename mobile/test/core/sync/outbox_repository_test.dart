/// Outbox atomikligi (M24), `device_seq` monotonligi (M20) va 1000 eventli yuk.

library;

import 'dart:math';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/sync/outbox_repository.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

import '../helpers/test_clock.dart';

void main() {
  late AppDatabase db;
  late TimeSource time;
  late FakeWallClock clock;
  late OutboxRepository outbox;

  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  setUp(() {
    db = AppDatabase.memory();
    final ({FakeWallClock clock, TimeSource time}) built = buildTestTimeSource(t0);
    time = built.time;
    clock = built.clock;
    time.syncFromServer(t0);
    outbox = OutboxRepository(db: db, time: time, random: Random(42));
  });

  tearDown(() => db.close());

  test('newClientId UUID v4 formatini beradi (M19)', () {
    final String id = outbox.newClientId();
    expect(isUuidV4(id), isTrue);
    expect(outbox.newClientId(), isNot(id));
  });

  test('M24: duty event va outbox yozuvi bitta tranzaksiyada', () async {
    final EnqueuedEvent event = await outbox.enqueueDutyEvent(
      eventType: SyncEventType.statusChange,
      status: 'ON',
      driverId: 'd1',
      logDate: '2026-09-07',
    );

    final List<DutyEventRow> events = await db.select(db.dutyEvents).get();
    final List<OutboxItemRow> items = await db.select(db.outboxItems).get();
    expect(events, hasLength(1));
    expect(items, hasLength(1));
    expect(events.single.clientEventId, event.clientEventId);
    expect(items.single.clientId, event.clientEventId);
    expect(items.single.kind, OutboxKind.event.wire);
    expect(items.single.deviceSeq, events.single.deviceSeq);
    expect(items.single.state, OutboxState.pending.wire);
  });

  test('M24: validatsiya yiqilsa na event, na outbox yoziladi', () async {
    await expectLater(
      outbox.enqueueDutyEvent(eventType: SyncEventType.statusChange, notes: 'x' * 501),
      throwsA(isA<OutboxValidationException>()),
    );
    expect(await db.select(db.dutyEvents).get(), isEmpty);
    expect(await db.select(db.outboxItems).get(), isEmpty);
    // device_seq ham qaytarilgan bo'lishi kerak (tranzaksiya rollback).
    expect(await db.settingsDao.currentDeviceSeq(), 0);
  });

  test('M41: kelajakdagi vaqt server oynasiga qisiladi', () async {
    final EnqueuedEvent event = await outbox.enqueueDutyEvent(
      eventType: SyncEventType.statusChange,
      eventTime: t0.add(const Duration(hours: 3)),
    );
    expect(event.eventTime, t0.add(const Duration(minutes: 5)));
  });

  test('M20: 1000 event → device_seq 1..1000, tartib buzilmaydi', () async {
    final List<int> seqs = <int>[];
    for (int i = 0; i < 1000; i++) {
      clock.advance(const Duration(milliseconds: 10));
      final EnqueuedEvent event = await outbox.enqueueDutyEvent(
        eventType: SyncEventType.statusChange,
        status: i.isEven ? 'ON' : 'OFF',
        driverId: 'd1',
      );
      seqs.add(event.deviceSeq);
    }

    expect(seqs, List<int>.generate(1000, (int i) => i + 1));
    expect(seqs.toSet(), hasLength(1000));

    // Navbatdan o'qilganda ham tartib device_seq bo'yicha o'sadi (M25).
    final List<OutboxRecord> due = await db.outboxDao.dueRecords(now: time.now(), limit: 2000);
    expect(due, hasLength(1000));
    for (int i = 1; i < due.length; i++) {
      expect(due[i].deviceSeq, greaterThan(due[i - 1].deviceSeq));
    }
    expect(await db.settingsDao.currentDeviceSeq(), 1000);
    expect(await db.dutyEventsDao.countAll(), 1000);
  });

  test('M20: parallel yozuvlar ham yagona device_seq oladi', () async {
    final List<Future<EnqueuedEvent>> futures = <Future<EnqueuedEvent>>[
      for (int i = 0; i < 50; i++)
        outbox.enqueueDutyEvent(eventType: SyncEventType.statusChange, status: 'ON'),
    ];
    final List<EnqueuedEvent> events = await Future.wait(futures);
    final Set<int> seqs = events.map((EnqueuedEvent e) => e.deviceSeq).toSet();
    expect(seqs, hasLength(50));
    expect(seqs.reduce(max), 50);
  });

  test('enqueue: biznes yozuvi callback bilan bitta tranzaksiyada', () async {
    final DateTime now = time.now();
    final int id = await outbox.enqueue(
      kind: OutboxKind.dvir,
      payload: <String, Object?>{'type': 'pre_trip'},
      writeBusinessRow: (String clientId, int deviceSeq) => db.dvirDao.upsertDraft(
        DvirDraftsCompanion.insert(
          clientId: clientId,
          unitId: 'u1',
          type: 'pre_trip',
          createdAt: now,
          updatedAt: now,
          state: const Value<String>('queued'),
        ),
      ),
    );

    expect(id, greaterThan(0));
    final List<DvirDraftRow> drafts = await db.select(db.dvirDrafts).get();
    final List<OutboxItemRow> items = await db.select(db.outboxItems).get();
    expect(drafts, hasLength(1));
    expect(items.single.clientId, drafts.single.clientId);
    expect(items.single.kind, OutboxKind.dvir.wire);
  });

  test('enqueue: biznes yozuvi yiqilsa outbox ham yozilmaydi (M24)', () async {
    await expectLater(
      outbox.enqueue(
        kind: OutboxKind.chat,
        payload: <String, Object?>{'text': 'hi'},
        writeBusinessRow: (_, _) => Future<void>.error(StateError('boom')),
      ),
      throwsA(isA<StateError>()),
    );
    expect(await db.select(db.outboxItems).get(), isEmpty);
  });

  test('applyPushOutcomes: accepted/rejected/superseded ko\'zguga yoziladi', () async {
    final EnqueuedEvent accepted = await outbox.enqueueDutyEvent(
      eventType: SyncEventType.statusChange,
      status: 'ON',
    );
    final EnqueuedEvent rejected = await outbox.enqueueDutyEvent(
      eventType: SyncEventType.statusChange,
      status: 'OFF',
    );
    final EnqueuedEvent superseded = await outbox.enqueueDutyEvent(
      eventType: SyncEventType.statusChange,
      status: 'SB',
    );

    await outbox.applyPushOutcomes(<String, PushOutcome>{
      accepted.clientEventId: resolvePushResult(result: PushResultKind.accepted),
      rejected.clientEventId: resolvePushResult(
        result: PushResultKind.rejected,
        reason: 'log_locked',
      ),
      superseded.clientEventId: resolvePushResult(
        result: PushResultKind.rejected,
        reason: 'superseded',
        supersededBy: 'srv-9',
      ),
    });

    final Map<String, OutboxItemRow> items = <String, OutboxItemRow>{
      for (final OutboxItemRow row in await db.select(db.outboxItems).get()) row.clientId: row,
    };
    expect(items[accepted.clientEventId]!.state, OutboxState.acked.wire);
    expect(items[accepted.clientEventId]!.rejectSeen, isTrue);
    expect(items[rejected.clientEventId]!.state, OutboxState.rejected.wire);
    expect(items[rejected.clientEventId]!.rejectReason, 'log_locked');
    expect(items[rejected.clientEventId]!.rejectSeen, isFalse);
    // M29: superseded — xato emas, lekin M-55 da ko'rinadi.
    expect(items[superseded.clientEventId]!.state, OutboxState.acked.wire);
    expect(items[superseded.clientEventId]!.supersededBy, 'srv-9');
    expect(items[superseded.clientEventId]!.rejectSeen, isFalse);

    final Map<String, DutyEventRow> events = <String, DutyEventRow>{
      for (final DutyEventRow row in await db.select(db.dutyEvents).get()) row.clientEventId: row,
    };
    expect(events[accepted.clientEventId]!.syncState, 'acked');
    expect(events[rejected.clientEventId]!.syncState, 'rejected');
    expect(events[superseded.clientEventId]!.supersededBy, 'srv-9');
  });
}
