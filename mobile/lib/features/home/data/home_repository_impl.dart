/// `HomeRepository` ning Drift implementatsiyasi — hammasi lokal bazadan
/// (tz-mobile 1235: «Lokal Drift (darhol) → keyin `sync/pull` yangilaydi»).
library;

import '../../../core/db/app_database.dart';
import '../../../core/db/daos/logs_dao.dart';
import '../../../core/db/daos/settings_dao.dart';
import '../../../core/time/day_boundary.dart';
import '../../duty_status/data/duty_status_repository_impl.dart';
import '../../duty_status/domain/duty_status_models.dart';
import '../../duty_status/domain/duty_status_repository.dart';
import '../../duty_status/domain/hos_snapshot.dart';
import '../domain/home_models.dart';
import '../domain/home_repository.dart';

/// `daily_logs.certification_status` ning sertifikatlangan qiymati.
const String kCertifiedStatus = 'certified';

class DriftHomeRepository implements HomeRepository {
  DriftHomeRepository({
    required LogsDao logs,
    required SettingsDao settings,
    required DutyStatusRepository duty,
  }) : this._(logs, settings, duty);

  const DriftHomeRepository._(this._logs, this._settings, this._duty);

  final LogsDao _logs;
  final SettingsDao _settings;
  final DutyStatusRepository _duty;

  @override
  Stream<List<CertifyDay>> watchCertifyDays({int days = 8}) =>
      Stream<String?>.fromFuture(_settings.get(DutyKvKeys.driverId)).asyncExpand((
        String? driverId,
      ) {
        if (driverId == null || driverId.isEmpty) {
          return Stream<List<CertifyDay>>.value(const <CertifyDay>[]);
        }
        return _logs
            .watchRecentLogs(driverId: driverId, days: days)
            .map(
              (List<DailyLogRow> rows) => <CertifyDay>[
                for (final DailyLogRow row in rows.take(days))
                  CertifyDay(
                    date: _dateOf(row.logDate),
                    certified: row.certificationStatus == kCertifiedStatus,
                  ),
              ],
            );
      });

  @override
  Stream<int> watchPendingEditCount() =>
      _logs.watchPendingEdits().map((List<LogEditRequestRow> rows) => rows.length);

  @override
  Stream<int> watchUnidentifiedCount() =>
      _logs.watchClaimable().map((List<UnidentifiedEventRow> rows) => rows.length);

  @override
  Future<List<DutyDaySegment>> todaySegments({required DateTime now}) async {
    final DutyStatusContext context = await _duty.context();
    final String tzName = context.driver.homeTerminalTz;
    final String today = logDateOf(now, tzName);
    final DateTime start = dayStartUtc(today, tzName);
    final DateTime end = dayEndUtc(today, tzName);
    return dutyDaySegments(
      events: await _duty.dayEvents(dayStartUtc: start, dayEndUtc: end),
      policy: context.policy,
      dayStartUtc: start,
      dayEndUtc: now.toUtc().isBefore(end) ? now.toUtc() : end,
    );
  }

  static DateTime _dateOf(String logDate) {
    final ({int year, int month, int day}) parts = parseLogDate(logDate);
    return DateTime(parts.year, parts.month, parts.day);
  }
}
