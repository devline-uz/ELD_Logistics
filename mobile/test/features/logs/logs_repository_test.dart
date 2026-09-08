@Timeout(Duration(seconds: 60))
/// `DriftLogsRepository`: #B-05 (`violations` jadvali) va #B-32 (Home Terminal
/// TZ dagi kun chegarasi) uchun repozitoriya darajasidagi testlar.
library;

import 'package:drift/drift.dart' show Value;
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/daos/duty_events_dao.dart';
import 'package:eld_mobile/core/db/daos/dvir_dao.dart';
import 'package:eld_mobile/core/db/daos/logs_dao.dart';
import 'package:eld_mobile/core/db/daos/ref_dao.dart';
import 'package:eld_mobile/core/sync/outbox_repository.dart';
import 'package:eld_mobile/core/time/day_boundary.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/logs/data/logs_repository_impl.dart';
import 'package:eld_mobile/features/logs/domain/log_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hos_engine/hos_engine.dart' show DutyStatus, ViolationType;

import '../../core/helpers/test_clock.dart';

void main() {
  setUpAll(initTimeZones);

  const String driverId = 'drv-1';
  const String tz = 'America/Chicago';

  late AppDatabase db;
  late TimeSource time;
  late DriftLogsRepository repo;

  /// `now` — 2026-09-08 03:00Z = 2026-09-07 22:00 Chicago: qurilma TZ (UTC)
  /// bo'yicha bugun 09-08, Home Terminal bo'yicha esa hamon 09-07.
  DateTime now() => DateTime.utc(2026, 9, 8, 3);

  setUp(() {
    db = AppDatabase.memory();
    time = buildTestTimeSource(now()).time;
    repo = DriftLogsRepository(
      logs: LogsDao(db),
      events: DutyEventsDao(db),
      dvir: DvirDao(db),
      ref: RefDao(db),
      outbox: OutboxRepository(db: db, time: time),
      time: time,
      driverId: driverId,
      timeZone: tz,
    );
  });

  tearDown(() async {
    await time.dispose();
    await db.close();
  });

  Future<void> putLog(String logDate, {Map<String, Object?> totals = const <String, Object?>{}}) =>
      LogsDao(db).upsertLog(
        DailyLogsCompanion.insert(
          logDate: logDate,
          driverId: driverId,
          timezone: tz,
          updatedAt: now(),
          ready: const Value<bool>(true),
          totals: Value<Map<String, Object?>>(totals),
        ),
      );

  Future<void> putViolation({
    required String id,
    required String type,
    required String severity,
    required String logDate,
    required DateTime at,
  }) => LogsDao(db).upsertViolation(
    ViolationsCompanion.insert(
      id: id,
      type: type,
      severity: Value<String>(severity),
      occurredAt: at,
      logDate: Value<String>(logDate),
      updatedAt: now(),
    ),
  );

  Future<void> putEvent({
    required String id,
    required DutyStatus status,
    required DateTime at,
    required String logDate,
    int seq = 1,
  }) => DutyEventsDao(db).upsertFromServer(
    DutyEventsCompanion.insert(
      clientEventId: id,
      eventType: 'status_change',
      status: Value<String>(status.wire),
      eventTime: at,
      deviceSeq: seq,
      createdAt: now(),
      driverId: const Value<String>(driverId),
      logDate: Value<String>(logDate),
    ),
  );

  group('#B-05 — ogohlantirish/buzilishlar `violations` jadvalidan', () {
    test('`daily_logs.totals` dagi warnings/violations E\'TIBORGA OLINMAYDI', () async {
      // Kontraktda bunday maydonlar yo'q; ilgari kod aynan shulardan o'qirdi.
      await putLog(
        '2026-09-07',
        totals: <String, Object?>{
          'warnings': <Object?>['Trailer is not set'],
          'violations': <Object?>['11-hour driving limit'],
          'drive_min': 660,
        },
      );

      final LogDayView day = await repo.watchDay(DateTime(2026, 9, 7)).first;
      expect(day.alerts, isEmpty);
    });

    test('jadvaldagi yozuvlar type + severity bilan chiqadi', () async {
      await putLog('2026-09-07');
      await putViolation(
        id: 'v1',
        type: ViolationType.formMannerTrailer,
        severity: 'warning',
        logDate: '2026-09-07',
        at: DateTime.utc(2026, 9, 7, 14),
      );
      await putViolation(
        id: 'v2',
        type: ViolationType.driveLimit,
        severity: 'violation',
        logDate: '2026-09-07',
        at: DateTime.utc(2026, 9, 7, 18),
      );
      // Boshqa kun — chiqmasligi kerak.
      await putViolation(
        id: 'v3',
        type: ViolationType.cycleLimit,
        severity: 'violation',
        logDate: '2026-09-06',
        at: DateTime.utc(2026, 9, 6, 18),
      );

      final LogDayView day = await repo.watchDay(DateTime(2026, 9, 7)).first;
      expect(day.alerts.map((LogAlert a) => a.type), <String>[
        ViolationType.formMannerTrailer,
        ViolationType.driveLimit,
      ]);
      expect(day.alerts.map((LogAlert a) => a.level), <LogAlertLevel>[
        LogAlertLevel.warning,
        LogAlertLevel.violation,
      ]);
    });

    test('sana tasmasida `hasViolation` faqat violation uchun yonadi', () async {
      await putViolation(
        id: 'v1',
        type: ViolationType.formMannerTrailer,
        severity: 'warning',
        logDate: '2026-09-06',
        at: DateTime.utc(2026, 9, 6, 14),
      );
      await putViolation(
        id: 'v2',
        type: ViolationType.driveLimit,
        severity: 'violation',
        logDate: '2026-09-07',
        at: DateTime.utc(2026, 9, 7, 14),
      );

      final List<LogDayRef> strip = await repo.watchStrip(days: 3).first;
      final Map<String, bool> byDate = <String, bool>{
        for (final LogDayRef d in strip) formatLogDate(d.date): d.hasViolation,
      };
      expect(byDate['2026-09-07'], isTrue);
      expect(byDate['2026-09-06'], isFalse);
    });
  });

  group('#B-32 — kun chegarasi Home Terminal TZ da', () {
    test('tasma bugungi kunni Home Terminal TZ da tugatadi', () async {
      final List<LogDayRef> strip = await repo.watchStrip(days: 3).first;
      // Qurilma/UTC bo'yicha bugun 2026-09-08 bo'lardi.
      expect(strip.map((LogDayRef d) => formatLogDate(d.date)).toList(), <String>[
        '2026-09-05',
        '2026-09-06',
        '2026-09-07',
      ]);
    });

    test('kun oralig\'i lokal 00:00 dan boshlanadi, qurilma 00:00 dan emas', () async {
      await putLog('2026-09-07');
      // 2026-09-07 05:30Z = 2026-09-07 00:30 Chicago — kun ICHIDA.
      await putEvent(
        id: 'e1',
        status: DutyStatus.on,
        at: DateTime.utc(2026, 9, 7, 5, 30),
        logDate: '2026-09-07',
      );
      await putEvent(
        id: 'e2',
        status: DutyStatus.off,
        at: DateTime.utc(2026, 9, 7, 7, 30),
        logDate: '2026-09-07',
        seq: 2,
      );

      final LogDayView day = await repo.watchDay(DateTime(2026, 9, 7)).first;
      expect(day.timeZone, tz);
      expect(day.startUtc, DateTime.utc(2026, 9, 7, 5));
      expect(day.endUtc, DateTime.utc(2026, 9, 8, 5));
      // Birinchi oraliq kun boshidan 30 daqiqadan keyin boshlanadi.
      expect(day.spans.first.start, const Duration(minutes: 30));
      expect(day.totalOf(DutyStatus.on), const Duration(hours: 2));
    });

    test('DST kuz kuni 25 soat (`dst_fall_back_25h_day`)', () async {
      final LogDayView day = await repo.watchDay(DateTime(2026, 11, 1)).first;
      expect(day.endUtc.difference(day.startUtc), const Duration(hours: 25));
    });

    test('14 kunlik oyna chegarasi Home Terminal kunlari bilan sanaladi', () async {
      final LogDayView inside = await repo.watchDay(DateTime(2026, 8, 25)).first;
      final LogDayView outside = await repo.watchDay(DateTime(2026, 8, 24)).first;
      expect(inside.available, isTrue);
      expect(outside.available, isFalse);
    });
  });
}
