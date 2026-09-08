/// Kunlik loglar, HOS keshi/policy, log-edit va unidentified DAO'lari (§5.1).
library;

import 'package:drift/drift.dart';

import '../app_database.dart';

part 'logs_dao.g.dart';

@DriftAccessor(
  tables: <Type>[
    DailyLogs,
    HosStates,
    HosPolicies,
    LogEditRequests,
    UnidentifiedEvents,
    Violations,
  ],
)
class LogsDao extends DatabaseAccessor<AppDatabase> with _$LogsDaoMixin {
  LogsDao(super.db);

  // --- daily_logs ---------------------------------------------------------

  /// Sertifikatsiya oynasi (8 kun) uchun oxirgi kunlar, yangisi birinchi.
  Stream<List<DailyLogRow>> watchRecentLogs({required String driverId, int days = 14}) =>
      (select(dailyLogs)
            ..where((DailyLogs t) => t.driverId.equals(driverId))
            ..orderBy(<OrderClauseGenerator<DailyLogs>>[
              (DailyLogs t) => OrderingTerm.desc(t.logDate),
            ])
            ..limit(days))
          .watch();

  Stream<DailyLogRow?> watchLog({required String driverId, required String logDate}) =>
      (select(dailyLogs)
            ..where((DailyLogs t) => t.driverId.equals(driverId) & t.logDate.equals(logDate)))
          .watchSingleOrNull();

  Future<void> upsertLog(DailyLogsCompanion log) => into(dailyLogs).insert(
    log,
    onConflict: DoUpdate<$DailyLogsTable, DailyLogRow>(
      ($DailyLogsTable _) => log,
      target: <Column<Object>>[dailyLogs.driverId, dailyLogs.logDate],
    ),
  );

  Future<int> deleteLogsBefore(String logDate) =>
      (delete(dailyLogs)..where((DailyLogs t) => t.logDate.isSmallerThanValue(logDate))).go();

  // --- hos_state / hos_policy --------------------------------------------

  Stream<HosStateRow?> watchHosState(String driverId) =>
      (select(hosStates)..where((HosStates t) => t.driverId.equals(driverId))).watchSingleOrNull();

  Future<void> upsertHosState(HosStatesCompanion state) =>
      into(hosStates).insertOnConflictUpdate(state);

  /// M36: pull da **birinchi** qo'llanadi — hisoblagichlar policy'ga bog'liq.
  Future<void> upsertPolicy(HosPoliciesCompanion policy) =>
      into(hosPolicies).insertOnConflictUpdate(policy);

  Future<HosPolicyRow?> policyAt(DateTime at) =>
      (select(hosPolicies)
            ..where((HosPolicies t) => t.effectiveFrom.isSmallerOrEqualValue(at))
            ..orderBy(<OrderClauseGenerator<HosPolicies>>[
              (HosPolicies t) => OrderingTerm.desc(t.effectiveFrom),
            ])
            ..limit(1))
          .getSingleOrNull();

  // --- log_edit_requests --------------------------------------------------

  Stream<List<LogEditRequestRow>> watchPendingEdits() =>
      (select(logEditRequests)
            ..where((LogEditRequests t) => t.status.equals('pending'))
            ..orderBy(<OrderClauseGenerator<LogEditRequests>>[
              (LogEditRequests t) => OrderingTerm.desc(t.createdAt),
            ]))
          .watch();

  Future<void> upsertEditRequest(LogEditRequestsCompanion request) =>
      into(logEditRequests).insertOnConflictUpdate(request);

  Future<void> setLocalDecision({required String id, required String decision}) =>
      (update(logEditRequests)..where((LogEditRequests t) => t.id.equals(id))).write(
        LogEditRequestsCompanion(localDecision: Value<String>(decision)),
      );

  Future<int> deleteEditsBefore(DateTime before) =>
      (delete(logEditRequests)..where(
            (LogEditRequests t) =>
                t.status.isNotValue('pending') & t.createdAt.isSmallerThanValue(before),
          ))
          .go();

  // --- unidentified_events ------------------------------------------------

  Stream<List<UnidentifiedEventRow>> watchClaimable() =>
      (select(unidentifiedEvents)
            ..where(
              (UnidentifiedEvents t) => t.status.equals('pending') & t.dismissedLocal.equals(false),
            )
            ..orderBy(<OrderClauseGenerator<UnidentifiedEvents>>[
              (UnidentifiedEvents t) => OrderingTerm.desc(t.startAt),
            ]))
          .watch();

  Future<void> upsertUnidentified(UnidentifiedEventsCompanion event) =>
      into(unidentifiedEvents).insertOnConflictUpdate(event);

  Future<void> dismissUnidentified(String id) =>
      (update(unidentifiedEvents)..where((UnidentifiedEvents t) => t.id.equals(id))).write(
        const UnidentifiedEventsCompanion(dismissedLocal: Value<bool>(true)),
      );

  // --- violations (`GET /violations` keshi) --------------------------------

  /// Bitta kunning buzilishlari — `logs` moduli Log report'da shuni o'qiydi.
  Stream<List<ViolationRow>> watchViolations({required String logDate}) =>
      (select(violations)
            ..where((Violations t) => t.logDate.equals(logDate))
            ..orderBy(<OrderClauseGenerator<Violations>>[
              (Violations t) => OrderingTerm.asc(t.occurredAt),
            ]))
          .watch();

  /// Hal qilinmagan buzilishlar (Home dagi qizil karta va bannerlar uchun).
  Stream<List<ViolationRow>> watchOpenViolations() =>
      (select(violations)
            ..where((Violations t) => t.resolvedAt.isNull())
            ..orderBy(<OrderClauseGenerator<Violations>>[
              (Violations t) => OrderingTerm.desc(t.occurredAt),
            ]))
          .watch();

  Future<void> upsertViolation(ViolationsCompanion violation) =>
      into(violations).insertOnConflictUpdate(violation);

  /// Retention (§5.2): 14 kunlik oynadan eski yozuvlar tozalanadi.
  Future<int> deleteViolationsBefore(DateTime before) =>
      (delete(violations)..where((Violations t) => t.occurredAt.isSmallerThanValue(before))).go();
}
