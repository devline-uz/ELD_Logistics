/// `duty_events` va `telemetry_buffer` (§5.1).
library;

import 'package:drift/drift.dart';

import '../converters.dart';

@DataClassName('DutyEventRow')
@TableIndex(name: 'idx_duty_events_time', columns: <Symbol>{#eventTime})
@TableIndex(name: 'idx_duty_events_sync', columns: <Symbol>{#syncState})
@TableIndex(name: 'idx_duty_events_driver_day', columns: <Symbol>{#driverId, #logDate})
class DutyEvents extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// M19: idempotentlikning yagona kaliti, hech qachon o'zgarmaydi.
  TextColumn get clientEventId => text().unique()();

  TextColumn get serverId => text().nullable()();

  /// M32 enum: `status_change`, `intermediate`, `login`, … .
  TextColumn get eventType => text()();

  /// `OFF`/`SB`/`DR`/`ON` — `status_change` uchun.
  TextColumn get status => text().nullable()();

  /// `none`/`pc`/`ym`.
  TextColumn get special => text().withDefault(const Constant<String>('none'))();

  /// UTC. Kunga ajratish faqat Home Terminal TZ da (M42).
  DateTimeColumn get eventTime => dateTime()();

  /// `eld_rtc`/`server`/`phone` (§7.1).
  TextColumn get timeSource => text().withDefault(const Constant<String>('phone'))();

  BoolColumn get timeUnverified => boolean().withDefault(const Constant<bool>(false))();

  IntColumn get clockSkewSec => integer().withDefault(const Constant<int>(0))();

  IntColumn get deviceSeq => integer()();

  /// `auto`/`driver`/`manual_no_eld`/`assigned` (M40).
  TextColumn get origin => text().withDefault(const Constant<String>('driver'))();

  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  RealColumn get gpsAccuracyM => real().nullable()();
  TextColumn get locationText => text().nullable()();

  /// Metrlarda (§5.1 "masofa `_m`").
  IntColumn get odometerM => integer().nullable()();
  RealColumn get engineHours => real().nullable()();
  RealColumn get speedKmh => real().nullable()();

  TextColumn get notes => text().nullable()();
  TextColumn get unitId => text().nullable()();
  TextColumn get eldDeviceId => text().nullable()();
  TextColumn get driverId => text().nullable()();

  TextColumn get trailerIds =>
      text().map(const StringListConverter()).withDefault(const Constant<String>('[]'))();
  TextColumn get shippingDocIds =>
      text().map(const StringListConverter()).withDefault(const Constant<String>('[]'))();

  /// `pending`/`inflight`/`acked`/`rejected` — outbox natijasining ko'zgusi.
  TextColumn get syncState => text().withDefault(const Constant<String>('pending'))();

  TextColumn get supersededBy => text().nullable()();

  /// Kun sertifikatlangan bo'lsa `true` — yangi event faqat edit-request orqali.
  BoolColumn get locked => boolean().withDefault(const Constant<bool>(false))();

  /// Home Terminal TZ dagi kun (`YYYY-MM-DD`, M42).
  TextColumn get logDate => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('TelemetryRow')
@TableIndex(name: 'idx_telemetry_sent_ts', columns: <Symbol>{#sent, #ts})
class TelemetryBuffer extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get unitId => text()();

  /// UTC nuqta vaqti; `(unit_id, ts)` — dublikat kaliti (eld-sync #4).
  DateTimeColumn get ts => dateTime()();

  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  RealColumn get speedKmh => real().nullable()();
  RealColumn get headingDeg => real().nullable()();
  IntColumn get odometerM => integer().nullable()();
  RealColumn get engineHours => real().nullable()();
  BoolColumn get ignition => boolean().nullable()();
  RealColumn get fuelPct => real().nullable()();
  RealColumn get coolantTempC => real().nullable()();
  RealColumn get coolantLevelPct => real().nullable()();
  RealColumn get oilLevelPct => real().nullable()();
  RealColumn get batteryVoltage => real().nullable()();
  RealColumn get batteryPct => real().nullable()();

  TextColumn get diagnostics => text().map(const JsonMapConverter()).nullable()();

  /// ELD uzilgan paytda yozilgan nuqta.
  BoolColumn get disconnected => boolean().withDefault(const Constant<bool>(false))();

  TextColumn get dutyStatus => text().nullable()();
  TextColumn get driverId => text().nullable()();

  BoolColumn get sent => boolean().withDefault(const Constant<bool>(false))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{unitId, ts},
  ];
}
