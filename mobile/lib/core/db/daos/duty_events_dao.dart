/// `duty_events` DAO — lokal ko'zgu va pull qo'llash (§5.1, M31, M37).
library;

import 'package:drift/drift.dart';

import '../app_database.dart';

part 'duty_events_dao.g.dart';

@DriftAccessor(tables: <Type>[DutyEvents])
class DutyEventsDao extends DatabaseAccessor<AppDatabase> with _$DutyEventsDaoMixin {
  DutyEventsDao(super.db);

  /// Kun eventlari (Home Terminal TZ kuni bo'yicha), vaqt o'sish tartibida.
  Stream<List<DutyEventRow>> watchDay({required String driverId, required String logDate}) =>
      (select(dutyEvents)
            ..where((DutyEvents t) => t.driverId.equals(driverId) & t.logDate.equals(logDate))
            ..orderBy(<OrderClauseGenerator<DutyEvents>>[
              (DutyEvents t) => OrderingTerm.asc(t.eventTime),
              (DutyEvents t) => OrderingTerm.asc(t.deviceSeq),
            ]))
          .watch();

  /// Oxirgi [limit] event — `Home` ekranidagi status tarixi uchun.
  Stream<List<DutyEventRow>> watchRecent({int limit = 50}) =>
      (select(dutyEvents)
            ..orderBy(<OrderClauseGenerator<DutyEvents>>[
              (DutyEvents t) => OrderingTerm.desc(t.eventTime),
            ])
            ..limit(limit))
          .watch();

  /// Berilgan oraliqdagi eventlar — HOS qayta hisoblash uchun.
  Future<List<DutyEventRow>> range({required DateTime from, required DateTime to}) =>
      (select(dutyEvents)
            ..where(
              (DutyEvents t) =>
                  t.eventTime.isBiggerOrEqualValue(from) & t.eventTime.isSmallerThanValue(to),
            )
            ..orderBy(<OrderClauseGenerator<DutyEvents>>[
              (DutyEvents t) => OrderingTerm.asc(t.eventTime),
              (DutyEvents t) => OrderingTerm.asc(t.deviceSeq),
            ]))
          .get();

  Future<DutyEventRow?> byClientEventId(String clientEventId) => (select(
    dutyEvents,
  )..where((DutyEvents t) => t.clientEventId.equals(clientEventId))).getSingleOrNull();

  /// M37: server versiyasi lokal yozuvni **almashtiradi**; topilmasa qo'shiladi.
  ///
  /// `client_event_id` UNIQUE bo'lgani uchun bitta upsert yetarli.
  Future<void> upsertFromServer(DutyEventsCompanion event) => into(dutyEvents).insert(
    event,
    onConflict: DoUpdate<$DutyEventsTable, DutyEventRow>(
      ($DutyEventsTable _) => event,
      target: <Column<Object>>[dutyEvents.clientEventId],
    ),
  );

  /// Push natijasini ko'zguga yozadi.
  Future<void> markSyncState({
    required String clientEventId,
    required String syncState,
    String? serverId,
    String? supersededBy,
    bool? locked,
  }) => (update(dutyEvents)..where((DutyEvents t) => t.clientEventId.equals(clientEventId))).write(
    DutyEventsCompanion(
      syncState: Value<String>(syncState),
      serverId: serverId == null ? const Value<String?>.absent() : Value<String?>(serverId),
      supersededBy: supersededBy == null
          ? const Value<String?>.absent()
          : Value<String?>(supersededBy),
      locked: locked == null ? const Value<bool>.absent() : Value<bool>(locked),
    ),
  );

  /// M23: faqat `acked` **va** [before] dan eski eventlar o'chadi.
  Future<int> deleteAcked({required DateTime before}) =>
      (delete(dutyEvents)..where(
            (DutyEvents t) => t.syncState.equals('acked') & t.eventTime.isSmallerThanValue(before),
          ))
          .go();

  Future<int> countAll() async {
    final Expression<int> count = dutyEvents.id.count();
    final TypedResult row = await (selectOnly(
      dutyEvents,
    )..addColumns(<Expression<Object>>[count])).getSingle();
    return row.read(count) ?? 0;
  }
}
