@Timeout(Duration(seconds: 60))
/// Oflayn Inspection Log Form: `carrier_name` / `home_terminal_address`
/// `kv_settings` dan o'qiladi (ilgari doim `N/A` edi).
library;

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/daos/duty_events_dao.dart';
import 'package:eld_mobile/core/db/daos/logs_dao.dart';
import 'package:eld_mobile/core/db/daos/settings_dao.dart';
import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/time/day_boundary.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/inspection/data/inspection_api.dart';
import 'package:eld_mobile/features/inspection/data/inspection_repository_impl.dart';
import 'package:eld_mobile/features/inspection/domain/inspection_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/helpers/test_clock.dart';

/// Har doim oflayn — repozitoriy lokal buferga tushadi.
class _OfflineApi implements InspectionApi {
  @override
  Future<InspectionSession?> begin() async => null;

  @override
  Future<InspectionReport?> logs({String? driverId, DateTime? date}) =>
      throw const ApiError(code: ApiErrorCode.clientNetwork, message: 'offline');

  @override
  Future<void> email(InspectionEmailRequest request) async {}

  @override
  Future<InspectionTransferResult> transfer({
    String? driverId,
    DateTime? date,
    String? comment,
  }) async => const InspectionTransferResult(format: InspectionOutputFormat.csvPdfZip);
}

void main() {
  setUpAll(initTimeZones);

  final DateTime t0 = DateTime.utc(2026, 9, 7, 18);

  late AppDatabase db;
  late TimeSource time;
  late ApiInspectionRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    time = buildTestTimeSource(t0).time;
    repo = ApiInspectionRepository(
      api: _OfflineApi(),
      logs: LogsDao(db),
      events: DutyEventsDao(db),
      settings: SettingsDao(db),
      time: time,
    );
  });

  tearDown(() async {
    await time.dispose();
    await db.close();
  });

  Future<void> putKv(String key, String value) =>
      SettingsDao(db).put(key: key, value: value, now: t0);

  test('profil kalitlari yo\'q — maydonlar null (UI `N/A` ko\'rsatadi)', () async {
    final InspectionReport report = await repo.logs();
    expect(report.source, InspectionSource.local);
    expect(report.carrierName, isNull);
    expect(report.homeTerminalAddress, isNull);
  });

  test('kv_settings dagi carrier_name / home_terminal_address o\'qiladi', () async {
    await putKv(KvKeys.carrierName, 'ONEBOOK Logistics');
    await putKv(KvKeys.homeTerminalAddress, '5432 Lorem Ipsum, Chicago IL');
    await putKv(KvKeys.driverName, 'John Doe');
    await putKv(KvKeys.driverId, 'drv-1');
    await putKv(KvKeys.homeTerminalTz, 'America/Chicago');

    final InspectionReport report = await repo.logs();
    expect(report.carrierName, 'ONEBOOK Logistics');
    expect(report.homeTerminalAddress, '5432 Lorem Ipsum, Chicago IL');
    expect(report.driverName, 'John Doe');
    expect(report.driverId, 'drv-1');
    expect(report.timezone, 'America/Chicago');

    // Har kunning formasi ham to'ldiriladi (M97).
    expect(report.days, isNotEmpty);
    expect(report.days.first.form.carrierName, 'ONEBOOK Logistics');
    expect(report.days.first.form.homeTerminalAddress, '5432 Lorem Ipsum, Chicago IL');
  });

  test('bo\'sh satr «qiymat yo\'q» deb qaraladi', () async {
    await putKv(KvKeys.carrierName, '');
    final InspectionReport report = await repo.logs();
    expect(report.carrierName, isNull);
  });
}
