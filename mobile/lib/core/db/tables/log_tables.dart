/// Kunlik loglar, HOS keshi/policy, log-edit va unidentified jadvallari (§5.1).
library;

import 'package:drift/drift.dart';

import '../converters.dart';

@DataClassName('DailyLogRow')
class DailyLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get serverId => text().nullable()();

  /// Home Terminal TZ dagi kun, `YYYY-MM-DD` (M42).
  TextColumn get logDate => text().withLength(min: 10, max: 10)();

  TextColumn get driverId => text()();

  /// IANA nomi (`America/Chicago`) — kun chegarasi shu bilan hisoblanadi.
  TextColumn get timezone => text()();

  /// `uncertified`/`certified`/`recertify_required`.
  TextColumn get certificationStatus => text().withDefault(const Constant<String>('uncertified'))();

  DateTimeColumn get signedAt => dateTime().nullable()();

  IntColumn get distanceM => integer().withDefault(const Constant<int>(0))();

  /// Status bo'yicha jamlar (soniya) — JSON.
  TextColumn get totals =>
      text().map(const JsonMapConverter()).withDefault(const Constant<String>('{}'))();

  /// Sertifikatsiyaga tayyor (server hisoblaydi).
  BoolColumn get ready => boolean().withDefault(const Constant<bool>(false))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{driverId, logDate},
  ];
}

@DataClassName('HosStateRow')
class HosStates extends Table {
  @override
  String get tableName => 'hos_state';

  TextColumn get driverId => text()();

  DateTimeColumn get computedAt => dateTime()();

  TextColumn get counters =>
      text().map(const JsonMapConverter()).withDefault(const Constant<String>('{}'))();

  TextColumn get recap =>
      text().map(const JsonMapConverter()).withDefault(const Constant<String>('{}'))();

  TextColumn get policyVersionId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{driverId};
}

@DataClassName('HosPolicyRow')
class HosPolicies extends Table {
  @override
  String get tableName => 'hos_policy';

  TextColumn get versionId => text()();

  DateTimeColumn get effectiveFrom => dateTime()();

  /// `hos_engine` `Policy` JSON — pull da almashtiriladi (M36, birinchi qadam).
  TextColumn get payload => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{versionId};
}

@DataClassName('LogEditRequestRow')
@TableIndex(name: 'idx_log_edits_status', columns: <Symbol>{#status, #createdAt})
class LogEditRequests extends Table {
  TextColumn get id => text()();

  TextColumn get dailyLogId => text().nullable()();

  TextColumn get logDate => text().withLength(min: 10, max: 10)();

  /// So'ralgan o'zgarishlar (event diff) — JSON.
  TextColumn get changes =>
      text().map(const JsonMapConverter()).withDefault(const Constant<String>('{}'))();

  /// `driver`/`admin`.
  TextColumn get source => text()();

  /// `pending`/`approved`/`rejected`.
  TextColumn get status => text()();

  DateTimeColumn get createdAt => dateTime()();

  /// Haydovchining lokal qarori (hali push qilinmagan bo'lishi mumkin).
  TextColumn get localDecision => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('UnidentifiedEventRow')
@TableIndex(name: 'idx_unidentified_status', columns: <Symbol>{#status, #startAt})
class UnidentifiedEvents extends Table {
  TextColumn get id => text()();

  TextColumn get unitId => text()();

  DateTimeColumn get startAt => dateTime()();

  DateTimeColumn get endAt => dateTime().nullable()();

  IntColumn get distanceM => integer().withDefault(const Constant<int>(0))();

  /// `pending`/`claimed`/`assigned`/`annotated`.
  TextColumn get status => text()();

  /// Haydovchi ro'yxatdan yashirgan (server holati o'zgarmaydi).
  BoolColumn get dismissedLocal => boolean().withDefault(const Constant<bool>(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// HOS buzilishlari keshi (`GET /violations`, TZ A§12).
///
/// `logs_dto.DayTotals` da `violations` maydoni **yo'q** va bo'lmaydi —
/// buzilishlar alohida endpoint'dan keladi va shu jadvalda 14 kun turadi
/// (oflayn Log report va Inspection ekranlari uchun).
@DataClassName('ViolationRow')
@TableIndex(name: 'idx_violations_occurred', columns: <Symbol>{#occurredAt})
@TableIndex(name: 'idx_violations_log_date', columns: <Symbol>{#logDate})
class Violations extends Table {
  /// Server `id` si (UUID) — mijoz buzilish yaratmaydi.
  TextColumn get id => text()();

  /// `drive_limit`, `shift_window`, `break_required`, `cycle_limit`, … .
  TextColumn get type => text()();

  /// `warning` / `violation`.
  TextColumn get severity => text().withDefault(const Constant<String>('violation'))();

  DateTimeColumn get occurredAt => dateTime()();

  /// Home Terminal TZ dagi kun, `YYYY-MM-DD` (kun bo'yicha guruhlash uchun).
  TextColumn get logDate => text().nullable()();

  TextColumn get dailyLogId => text().nullable()();

  TextColumn get driverId => text().nullable()();

  TextColumn get unitId => text().nullable()();

  TextColumn get policyVersionId => text().nullable()();

  /// `{limit_min, remaining_min, days_uncertified, note}` — JSON.
  TextColumn get details =>
      text().map(const JsonMapConverter()).withDefault(const Constant<String>('{}'))();

  DateTimeColumn get resolvedAt => dateTime().nullable()();

  TextColumn get resolvedReason => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
