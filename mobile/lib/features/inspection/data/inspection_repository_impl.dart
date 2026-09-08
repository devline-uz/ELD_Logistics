/// `InspectionRepository` implementatsiyasi: onlayn server, oflayn — lokal
/// Drift buferi (tz-mobile M-38: «14 kunlik bufer yetarli»).
library;

import 'package:hos_engine/hos_engine.dart' show DutyStatus;

import '../../../core/db/app_database.dart';
import '../../../core/db/daos/duty_events_dao.dart';
import '../../../core/db/daos/logs_dao.dart';
import '../../../core/db/daos/settings_dao.dart';
import '../../../core/error/api_error.dart';
import '../../../core/time/day_boundary.dart';
import '../../../core/time/time_source.dart';
import '../domain/inspection_models.dart';
import '../domain/inspection_repository.dart';
import 'inspection_api.dart';

/// Yo'l tekshiruvi oynasi: 7 kun + bugun.
const int kInspectionWindowDays = 8;

class ApiInspectionRepository implements InspectionRepository {
  const ApiInspectionRepository({
    required this._api,
    required this._logs,
    required this._events,
    required this._settings,
    required this._time,
  });

  final InspectionApi _api;
  final LogsDao _logs;
  final DutyEventsDao _events;
  final SettingsDao _settings;
  final TimeSource _time;

  @override
  Future<InspectionSession?> begin() async {
    try {
      return await _api.begin();
    } on ApiError catch (error) {
      // Oflayn: kiosk rejimi baribir ochiladi (lokal nusxa bilan).
      if (error.isOffline || error.isRetryable) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<InspectionReport> logs({DateTime? date}) async {
    final DateTime anchor = date ?? _time.now();
    try {
      final InspectionReport? report = await _api.logs(date: date);
      if (report != null) {
        return report;
      }
    } on ApiError catch (error) {
      if (!error.isOffline && !error.isRetryable) {
        rethrow;
      }
    }
    return _localReport(anchor);
  }

  @override
  Future<void> sendEmail(InspectionEmailRequest request) => _api.email(request);

  @override
  Future<InspectionTransferResult> transfer({DateTime? date, String? comment}) =>
      _api.transfer(date: date, comment: comment);

  // --- Oflayn manba -----------------------------------------------------------

  /// Lokal `daily_logs` + `duty_events` dan 7 kun + bugun yig'adi.
  Future<InspectionReport> _localReport(DateTime anchor) async {
    // Sessiya profili `kv_settings` da (`sync/pull` va login yozadi) —
    // oflayn Inspection Log Form `N/A` ko'rsatmasligi uchun shu yerdan
    // o'qiladi (§4.3, M97).
    final Map<String, String?> profile = await _sessionProfile();
    final String timezone = _valueOf(profile, KvKeys.homeTerminalTz) ?? kFallbackTimeZone;
    final List<DutyEventRow> recent = await _events.watchRecent(limit: 1).first;
    final String? driverId =
        _valueOf(profile, KvKeys.driverId) ?? (recent.isEmpty ? null : recent.first.driverId);

    // `recentLogDates` yangisini birinchi qaytaradi — inspektor jadvali
    // eskidan yangiga o'qiladi.
    final List<String> dates = recentLogDates(
      now: anchor,
      timeZoneName: timezone,
      days: kInspectionWindowDays,
    ).reversed.toList(growable: false);
    if (dates.isEmpty) {
      final DateTime today = anchor;
      return InspectionReport(
        from: today,
        to: today,
        days: const <InspectionDay>[],
        driverId: driverId,
        driverName: _valueOf(profile, KvKeys.driverName),
        carrierName: _valueOf(profile, KvKeys.carrierName),
        homeTerminalAddress: _valueOf(profile, KvKeys.homeTerminalAddress),
        timezone: timezone,
        source: InspectionSource.local,
        lastSyncedAt: await _lastSyncedAt(),
      );
    }

    final List<DailyLogRow> rows = driverId == null
        ? const <DailyLogRow>[]
        : await _logs.watchRecentLogs(driverId: driverId, days: kInspectionWindowDays).first;
    final Map<String, DailyLogRow> byDate = <String, DailyLogRow>{
      for (final DailyLogRow row in rows) row.logDate: row,
    };

    final DateTime windowStart = dayStartUtc(dates.first, timezone);
    final DateTime windowEnd = dayEndUtc(dates.last, timezone);
    final List<DutyEventRow> events = await _events.range(from: windowStart, to: windowEnd);

    final List<InspectionDay> days = <InspectionDay>[
      for (final String logDate in dates)
        _localDay(
          logDate: logDate,
          timezone: timezone,
          carrierName: _valueOf(profile, KvKeys.carrierName),
          homeTerminalAddress: _valueOf(profile, KvKeys.homeTerminalAddress),
          row: byDate[logDate],
          events: events
              .where((DutyEventRow e) => (e.logDate ?? logDateOf(e.eventTime, timezone)) == logDate)
              .toList(growable: false),
        ),
    ];

    return InspectionReport(
      from: _dateOf(dates.first),
      to: _dateOf(dates.last),
      days: days,
      driverId: driverId,
      driverName: _valueOf(profile, KvKeys.driverName),
      carrierName: _valueOf(profile, KvKeys.carrierName),
      homeTerminalAddress: _valueOf(profile, KvKeys.homeTerminalAddress),
      timezone: timezone,
      source: InspectionSource.local,
      lastSyncedAt: await _lastSyncedAt(),
    );
  }

  InspectionDay _localDay({
    required String logDate,
    required String timezone,
    required DailyLogRow? row,
    required List<DutyEventRow> events,
    String? carrierName,
    String? homeTerminalAddress,
  }) {
    final List<InspectionEvent> items = <InspectionEvent>[
      for (final DutyEventRow e in events)
        if (DutyStatus.tryParse(e.status) case final DutyStatus status)
          InspectionEvent(
            at: e.eventTime,
            status: status,
            locationText: e.locationText,
            odometerMeters: e.odometerM,
            note: e.notes,
          ),
    ]..sort((InspectionEvent a, InspectionEvent b) => a.at.compareTo(b.at));

    final Set<String> trailers = <String>{for (final DutyEventRow e in events) ...e.trailerIds};
    final Set<String> docs = <String>{for (final DutyEventRow e in events) ...e.shippingDocIds};
    final Set<String> units = <String>{
      for (final DutyEventRow e in events)
        if (e.unitId case final String unit) unit,
    };

    return InspectionDay(
      date: _dateOf(logDate),
      timezone: row?.timezone ?? timezone,
      certification: InspectionCertification.fromWire(row?.certificationStatus),
      distanceMeters: row?.distanceM ?? 0,
      form: InspectionLogForm(
        unitNumbers: units.toList(growable: false),
        trailerNumbers: trailers.toList(growable: false),
        shippingDocs: docs.toList(growable: false),
        carrierName: carrierName,
        homeTerminalAddress: homeTerminalAddress,
        distanceMeters: row?.distanceM,
      ),
      events: items,
      signedAt: row?.signedAt,
    );
  }

  /// `kv_settings` dagi sessiya profili (`carrier_name`,
  /// `home_terminal_address`, `driver_name`, `home_terminal_tz`, …).
  Future<Map<String, String?>> _sessionProfile() async {
    const List<String> keys = <String>[
      KvKeys.homeTerminalTz,
      KvKeys.driverId,
      KvKeys.driverName,
      KvKeys.carrierName,
      KvKeys.homeTerminalAddress,
    ];
    final List<String?> values = await Future.wait<String?>(
      keys.map((String key) => _settings.get(key)),
    );
    return <String, String?>{for (int i = 0; i < keys.length; i++) keys[i]: values[i]};
  }

  /// Bo'sh satr = «qiymat yo'q» (UI `N/A` ko'rsatadi).
  static String? _valueOf(Map<String, String?> values, String key) {
    final String? value = values[key];
    return value == null || value.isEmpty ? null : value;
  }

  Future<DateTime?> _lastSyncedAt() async => (await _settings.cursor())?.lastPullAt;

  DateTime _dateOf(String logDate) {
    final ({int day, int month, int year}) parts = parseLogDate(logDate);
    return DateTime.utc(parts.year, parts.month, parts.day);
  }
}
