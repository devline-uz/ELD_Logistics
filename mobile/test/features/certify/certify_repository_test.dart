@Timeout(Duration(seconds: 60))
/// #B-32: `certify` oynasi ham kun chegarasini Home Terminal TZ da sanaydi
/// (ilgari `DateTime(y, m, d)` — qurilma zonasi ishlatilardi).
library;

import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/daos/dvir_dao.dart';
import 'package:eld_mobile/core/db/daos/logs_dao.dart';
import 'package:eld_mobile/core/db/daos/settings_dao.dart';
import 'package:eld_mobile/core/sync/outbox_repository.dart';
import 'package:eld_mobile/core/time/day_boundary.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/certify/data/certify_repository_impl.dart';
import 'package:eld_mobile/features/certify/domain/certify_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/helpers/test_clock.dart';

void main() {
  setUpAll(initTimeZones);

  const String driverId = 'drv-1';
  const String tz = 'America/Chicago';

  late AppDatabase db;
  late TimeSource time;
  late Directory base;
  late DriftCertifyRepository repo;

  /// 2026-11-02 03:00Z = 2026-11-01 22:00 Chicago — DST kuzgi o'tishdan keyin,
  /// UTC da esa allaqachon 11-02.
  DateTime now() => DateTime.utc(2026, 11, 2, 3);

  setUp(() async {
    db = AppDatabase.memory();
    time = buildTestTimeSource(now()).time;
    base = await Directory.systemTemp.createTemp('certify_repo_test');
    repo = DriftCertifyRepository(
      db: db,
      logs: LogsDao(db),
      settings: SettingsDao(db),
      outbox: OutboxRepository(db: db, time: time),
      signatures: DriftSignatureStore(
        files: DvirDao(db),
        settings: SettingsDao(db),
        time: time,
        baseDirectory: () async => base,
      ),
      time: time,
      driverId: driverId,
      timeZone: tz,
    );
  });

  tearDown(() async {
    await time.dispose();
    await db.close();
    if (base.existsSync()) {
      base.deleteSync(recursive: true);
    }
  });

  test('oyna bugungi Home Terminal kunidan boshlanadi, DST kunini takrorlamaydi', () async {
    final List<CertifyDay> days = await repo.watchWindow(days: 4).first;
    final List<String> dates =
        days.map((CertifyDay d) => formatLogDate(d.date)).toList(growable: false)..sort();
    // Qurilma/UTC bo'yicha bugun 11-02 bo'lardi; 11-01 esa 25 soatlik kun —
    // `subtract(Duration(days: 1))` uni ikki marta berardi.
    expect(dates, <String>['2026-10-29', '2026-10-30', '2026-10-31', '2026-11-01']);
    expect(dayLength('2026-11-01', tz), const Duration(hours: 25));
  });

  test('kun holati `daily_logs` dan o\'qiladi', () async {
    await LogsDao(db).upsertLog(
      DailyLogsCompanion.insert(
        logDate: '2026-11-01',
        driverId: driverId,
        timezone: tz,
        updatedAt: now(),
        ready: const Value<bool>(true),
        certificationStatus: const Value<String>('certified'),
      ),
    );

    final CertifyDay day = await repo.watchDay(DateTime(2026, 11, 1)).first;
    expect(day.status, CertifyStatus.certified);
    expect(formatLogDate(day.date), '2026-11-01');
  });
}
