/// DAO `watch()` oqimlari va navbat operatsiyalari (§5.1, M28, M30).

library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/daos/outbox_dao.dart';
import 'package:eld_mobile/core/db/daos/settings_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);
  late AppDatabase db;

  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  Future<int> addItem({
    required String clientId,
    required int seq,
    OutboxKind kind = OutboxKind.event,
    OutboxState state = OutboxState.pending,
    DateTime? nextAttemptAt,
  }) => db
      .into(db.outboxItems)
      .insert(
        OutboxItemsCompanion.insert(
          kind: kind.wire,
          payload: '{}',
          clientId: clientId,
          deviceSeq: seq,
          createdAt: t0,
          nextAttemptAt: nextAttemptAt ?? t0,
          updatedAt: t0,
          state: Value<String>(state.wire),
        ),
      );

  group('OutboxDao', () {
    test('dueItems faqat vaqti kelgan pending elementlarni beradi', () async {
      await addItem(clientId: 'a', seq: 1);
      await addItem(clientId: 'b', seq: 2, state: OutboxState.inflight);
      await addItem(clientId: 'c', seq: 3, nextAttemptAt: t0.add(const Duration(minutes: 1)));
      final List<OutboxRecord> due = await db.outboxDao.dueRecords(now: t0);
      expect(due.map((OutboxRecord r) => r.clientId), <String>['a']);
    });

    test('watchStats turlari bo\'yicha navbatni beradi (M28)', () async {
      await addItem(clientId: 'a', seq: 1);
      await addItem(clientId: 'b', seq: 2, kind: OutboxKind.chat);
      await addItem(clientId: 'c', seq: 3, kind: OutboxKind.chat);
      await addItem(clientId: 'd', seq: 4, state: OutboxState.inflight);
      await addItem(clientId: 'e', seq: 5, state: OutboxState.rejected);

      final OutboxQueueStats stats = await db.outboxDao.watchStats().first;
      expect(stats.pendingByKind[OutboxKind.event], 1);
      expect(stats.pendingByKind[OutboxKind.chat], 2);
      expect(stats.pendingTotal, 3);
      expect(stats.inflight, 1);
      expect(stats.rejected, 1);
      expect(stats.unseenRejected, 1);
      expect(stats.hasConflicts, isTrue);
    });

    test('releaseInflight attempts ni oshiradi va kalitni saqlaydi (M33.6)', () async {
      final int id = await addItem(clientId: 'a', seq: 1);
      await db.outboxDao.markInflight(ids: <int>[id], idempotencyKey: 'k1', now: t0);
      await db.outboxDao.releaseInflight(
        ids: <int>[id],
        nextAttemptAt: t0.add(const Duration(seconds: 5)),
        now: t0,
        lastError: 'CLIENT_NETWORK',
      );
      final OutboxItemRow row = await (db.select(
        db.outboxItems,
      )..where(($OutboxItemsTable t) => t.id.equals(id))).getSingle();
      expect(row.state, OutboxState.pending.wire);
      expect(row.attempts, 1);
      expect(row.idempotencyKey, 'k1');
      expect(row.lastError, 'CLIENT_NETWORK');
      expect(row.nextAttemptAt, t0.add(const Duration(seconds: 5)));
    });

    test('resetIdempotencyKey kalitni tozalaydi (M33.7)', () async {
      final int id = await addItem(clientId: 'a', seq: 1);
      await db.outboxDao.markInflight(ids: <int>[id], idempotencyKey: 'k1', now: t0);
      await db.outboxDao.resetIdempotencyKey(ids: <int>[id], now: t0);
      final OutboxItemRow row = await (db.select(
        db.outboxItems,
      )..where(($OutboxItemsTable t) => t.id.equals(id))).getSingle();
      expect(row.idempotencyKey, isNull);
      expect(row.state, OutboxState.pending.wire);
    });

    test('bo\'sh id ro\'yxati bilan chaqiruvlar xatosiz o\'tadi', () async {
      await db.outboxDao.markInflight(ids: const <int>[], idempotencyKey: 'k', now: t0);
      await db.outboxDao.releaseInflight(ids: const <int>[], nextAttemptAt: t0, now: t0);
      await db.outboxDao.resetIdempotencyKey(ids: const <int>[], now: t0);
      await db.telemetryDao.markSent(const <int>[]);
      expect(await db.dvirDao.deleteFiles(const <int>[]), 0);
      expect(await db.telemetryDao.deleteOldest(0), 0);
    });

    test('watchConflicts rejected va superseded elementlarni beradi (M30)', () async {
      final int rejected = await addItem(clientId: 'a', seq: 1);
      final int superseded = await addItem(clientId: 'b', seq: 2);
      await db.outboxDao.applyOutcome(
        id: rejected,
        outcome: resolvePushResult(result: PushResultKind.rejected, reason: 'log_locked'),
        now: t0,
      );
      await db.outboxDao.applyOutcome(
        id: superseded,
        outcome: resolvePushResult(
          result: PushResultKind.rejected,
          reason: 'superseded',
          supersededBy: 'srv-1',
        ),
        now: t0,
      );

      final List<OutboxItemRow> conflicts = await db.outboxDao.watchConflicts().first;
      expect(conflicts, hasLength(2));
      expect(conflicts.every((OutboxItemRow r) => !r.rejectSeen), isTrue);

      await db.outboxDao.markConflictsSeen(t0);
      final List<OutboxItemRow> seen = await db.outboxDao.watchConflicts().first;
      expect(seen.every((OutboxItemRow r) => r.rejectSeen), isTrue);
    });

    test('requeue rad etilgan elementni navbatga qaytaradi', () async {
      final int id = await addItem(clientId: 'a', seq: 1);
      await db.outboxDao.applyOutcome(
        id: id,
        outcome: resolvePushResult(result: PushResultKind.rejected, reason: 'time_in_future'),
        now: t0,
      );
      await db.outboxDao.requeue(id: id, now: t0);
      final OutboxItemRow row = await (db.select(
        db.outboxItems,
      )..where(($OutboxItemsTable t) => t.id.equals(id))).getSingle();
      expect(row.state, OutboxState.pending.wire);
      expect(row.rejectReason, isNull);
      expect(row.attempts, 0);
    });
  });

  group('SettingsDao', () {
    test('nextDeviceSeq 1 dan boshlanadi va monoton o\'sadi (M20)', () async {
      expect(await db.settingsDao.currentDeviceSeq(), 0);
      expect(await db.settingsDao.nextDeviceSeq(t0), 1);
      expect(await db.settingsDao.nextDeviceSeq(t0), 2);
      expect(await db.settingsDao.nextDeviceSeq(t0), 3);
      expect(await db.settingsDao.currentDeviceSeq(), 3);
    });

    test('buzilgan device_seq qiymati CAST bilan tiklanadi', () async {
      // SQLite `CAST('oops' AS INTEGER)` = 0, shuning uchun navbat 1 dan davom
      // etadi — monotonlik buziladi, lekin ilova yiqilmaydi va yozuv yo'qolmaydi.
      await db.settingsDao.put(key: KvKeys.deviceSeq, value: 'oops', now: t0);
      expect(await db.settingsDao.nextDeviceSeq(t0), 1);
      expect(await db.settingsDao.nextDeviceSeq(t0), 2);
    });

    test('kv put/get/watch/remove', () async {
      await db.settingsDao.put(key: KvKeys.homeTerminalTz, value: 'America/Chicago', now: t0);
      expect(await db.settingsDao.get(KvKeys.homeTerminalTz), 'America/Chicago');
      expect(await db.settingsDao.watch(KvKeys.homeTerminalTz).first, 'America/Chicago');
      await db.settingsDao.remove(KvKeys.homeTerminalTz);
      expect(await db.settingsDao.get(KvKeys.homeTerminalTz), isNull);
    });

    test('kursor yangilanadi va xato tozalanadi (M28, M35)', () async {
      await db.settingsDao.setNextSince('c1');
      await db.settingsDao.markPush(t0);
      await db.settingsDao.markPull(t0);
      await db.settingsDao.markError(code: 'RATE_LIMITED', at: t0);
      SyncCursorRow cursor = (await db.settingsDao.cursor())!;
      expect(cursor.nextSince, 'c1');
      expect(cursor.lastPushAt, t0);
      expect(cursor.lastPullAt, t0);
      expect(cursor.lastError, 'RATE_LIMITED');

      await db.settingsDao.clearError();
      cursor = (await db.settingsDao.watchCursor().first)!;
      expect(cursor.lastError, isNull);
      expect(cursor.nextSince, 'c1');
    });
  });

  group('boshqa DAO oqimlari', () {
    test('duty events kun va oxirgilar oqimi', () async {
      for (int i = 0; i < 3; i++) {
        await db
            .into(db.dutyEvents)
            .insert(
              DutyEventsCompanion.insert(
                clientEventId: 'e$i',
                eventType: 'status_change',
                eventTime: t0.add(Duration(minutes: i)),
                deviceSeq: i + 1,
                createdAt: t0,
                driverId: const Value<String?>('d1'),
                logDate: const Value<String?>('2026-09-07'),
              ),
            );
      }
      final List<DutyEventRow> day = await db.dutyEventsDao
          .watchDay(driverId: 'd1', logDate: '2026-09-07')
          .first;
      expect(day.map((DutyEventRow e) => e.clientEventId), <String>['e0', 'e1', 'e2']);

      final List<DutyEventRow> recent = await db.dutyEventsDao.watchRecent(limit: 2).first;
      expect(recent.map((DutyEventRow e) => e.clientEventId), <String>['e2', 'e1']);

      final List<DutyEventRow> range = await db.dutyEventsDao.range(
        from: t0,
        to: t0.add(const Duration(minutes: 2)),
      );
      expect(range, hasLength(2));
    });

    test('notifications va chat oqimlari', () async {
      await db.chatDao.upsertNotification(
        NotificationsCompanion.insert(
          id: 'n1',
          alertType: 'violation',
          title: 'T',
          body: 'B',
          createdAt: t0,
        ),
      );
      expect(await db.chatDao.watchUnreadCount().first, 1);
      await db.chatDao.markRead('n1');
      expect(await db.chatDao.watchUnreadCount().first, 0);
      expect(await db.chatDao.watchNotifications().first, hasLength(1));

      await db.chatDao.enqueueMessage(
        ChatOutboxCompanion.insert(clientId: 'c1', kind: 'text', createdAt: t0),
      );
      await db.chatDao.setOutboxStatus(clientId: 'c1', status: 'sent');
      expect((await db.select(db.chatOutbox).get()).single.status, 'sent');

      await db.chatDao.upsertMessage(
        ChatMessagesCompanion.insert(
          id: 'm1',
          kind: 'text',
          createdAt: t0,
          conversationId: const Value<String?>('conv-1'),
        ),
      );
      expect(await db.chatDao.watchMessages(conversationId: 'conv-1').first, hasLength(1));
      expect(await db.chatDao.watchMessages().first, hasLength(1));
    });

    test('DVIR qoralamalari va kataloglar', () async {
      await db.dvirDao.upsertDraft(
        DvirDraftsCompanion.insert(
          clientId: 'd1',
          unitId: 'u1',
          type: 'pre_trip',
          createdAt: t0,
          updatedAt: t0,
        ),
      );
      expect(await db.dvirDao.watchDrafts().first, hasLength(1));
      expect((await db.dvirDao.draft('d1'))!.state, 'draft');
      await db.dvirDao.setDraftState(clientId: 'd1', state: 'sent', now: t0);
      expect(await db.dvirDao.watchDrafts().first, isEmpty);

      await db.dvirDao.upsertReport(
        DvirReportsCompanion.insert(
          id: 'r1',
          status: 'open',
          kind: 'driver',
          type: 'pre_trip',
          unitId: 'u1',
          createdAt: t0,
        ),
      );
      expect(await db.dvirDao.watchReports().first, hasLength(1));

      await db.refDao.replaceDefectTypes(<RefDefectTypesCompanion>[
        RefDefectTypesCompanion.insert(id: 'x', code: 'BRK', label: 'Brakes', updatedAt: t0),
      ]);
      await db.refDao.replaceTrailers(<RefTrailersCompanion>[
        RefTrailersCompanion.insert(id: 't1', number: '4402', updatedAt: t0),
      ]);
      expect(await db.refDao.watchDefectTypes(appliesTo: 'vehicle').first, hasLength(1));
      expect(await db.refDao.watchDefectTypes().first, hasLength(1));
      expect(await db.refDao.watchTrailers().first, hasLength(1));
    });

    test('log edit va unidentified oqimlari', () async {
      await db.logsDao.upsertEditRequest(
        LogEditRequestsCompanion.insert(
          id: 'le1',
          logDate: '2026-09-06',
          source: 'admin',
          status: 'pending',
          createdAt: t0,
        ),
      );
      expect(await db.logsDao.watchPendingEdits().first, hasLength(1));
      await db.logsDao.setLocalDecision(id: 'le1', decision: 'accepted');
      expect((await db.select(db.logEditRequests).get()).single.localDecision, 'accepted');

      await db.logsDao.upsertUnidentified(
        UnidentifiedEventsCompanion.insert(
          id: 'u1',
          unitId: 'unit-1',
          startAt: t0,
          status: 'pending',
        ),
      );
      expect(await db.logsDao.watchClaimable().first, hasLength(1));
      await db.logsDao.dismissUnidentified('u1');
      expect(await db.logsDao.watchClaimable().first, isEmpty);
    });

    test('HOS keshi va policy', () async {
      await db.logsDao.upsertHosState(HosStatesCompanion.insert(driverId: 'd1', computedAt: t0));
      expect((await db.logsDao.watchHosState('d1').first)!.driverId, 'd1');

      await db.logsDao.upsertPolicy(
        HosPoliciesCompanion.insert(
          versionId: 'p1',
          effectiveFrom: t0.subtract(const Duration(days: 1)),
          payload: '{}',
        ),
      );
      expect((await db.logsDao.policyAt(t0))!.versionId, 'p1');
      expect(await db.logsDao.policyAt(t0.subtract(const Duration(days: 5))), isNull);
    });

    test('telemetriya oqimi va toplu qo\'shish', () async {
      await db.telemetryDao.insertPoints(<TelemetryBufferCompanion>[
        for (int i = 0; i < 4; i++)
          TelemetryBufferCompanion.insert(
            unitId: 'u1',
            ts: t0.add(Duration(seconds: i)),
          ),
      ]);
      expect(await db.telemetryDao.watchUnsentCount().first, 4);
      final List<TelemetryRow> unsent = await db.telemetryDao.unsent(limit: 2);
      await db.telemetryDao.markSent(unsent.map((TelemetryRow r) => r.id).toList());
      expect(await db.telemetryDao.watchUnsentCount().first, 2);
    });

    test('daily logs oqimi', () async {
      for (int i = 5; i <= 7; i++) {
        await db.logsDao.upsertLog(
          DailyLogsCompanion.insert(
            logDate: '2026-09-0$i',
            driverId: 'd1',
            timezone: 'UTC',
            updatedAt: t0,
          ),
        );
      }
      final List<DailyLogRow> logs = await db.logsDao
          .watchRecentLogs(driverId: 'd1', days: 2)
          .first;
      expect(logs.map((DailyLogRow l) => l.logDate), <String>['2026-09-07', '2026-09-06']);
      expect(
        (await db.logsDao.watchLog(driverId: 'd1', logDate: '2026-09-05').first)!.timezone,
        'UTC',
      );
    });
  });
}
