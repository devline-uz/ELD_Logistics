/// `LogsRepository` ning oflayn-first implementatsiyasi (M5).
///
/// O'qish — faqat lokal Drift (`sync/pull` to'ldiradi); yozish — outbox
/// (M24/M136). Tarmoqqa to'g'ridan-to'g'ri murojaat yo'q: `Log Report`
/// oxirgi 14 kun uchun **doim** oflayn ishlaydi.
library;

import 'dart:async';

import 'package:hos_engine/hos_engine.dart' show DutyStatus;
import 'package:sync_core/sync_core.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/daos/duty_events_dao.dart';
import '../../../core/db/daos/dvir_dao.dart';
import '../../../core/db/daos/logs_dao.dart';
import '../../../core/db/daos/ref_dao.dart';
import '../../../core/sync/outbox_repository.dart';
import '../../../core/time/day_boundary.dart';
import '../../../core/time/time_source.dart';
import '../../../core/util/stream_combine.dart';
import '../domain/day_timeline.dart';
import '../domain/log_models.dart';
import '../domain/logs_repository.dart';

/// `YYYY-MM-DD` (Home Terminal TZ kuni, M42).
///
/// Yagona implementatsiya `core/time/day_boundary.dart` da — bu yerda faqat
/// modul ichidagi qisqa nom (nol tolerantli formatlash uchun `padLeft(4)` ham
/// shu yerdan keladi).
String logDateKey(DateTime date) => formatLogDate(date);

/// Oflayn to'liq mavjud oyna (§11.4 «oxirgi 14 kun to'liq lokal»).
const int kLocalLogWindowDays = 14;

class DriftLogsRepository implements LogsRepository {
  DriftLogsRepository({
    required this._logs,
    required this._events,
    required this._dvir,
    required this._ref,
    required this._outbox,
    required this._time,
    required this._driverId,
    this._timeZone = kFallbackTimeZone,
    this._driver = const DriverDayInfo(),
  });

  final LogsDao _logs;
  final DutyEventsDao _events;
  final DvirDao _dvir;
  final RefDao _ref;
  final OutboxRepository _outbox;
  final TimeSource _time;
  final String _driverId;

  /// Home Terminal IANA zonasi — kun chegarasi **faqat** shundan (M42, #B-32).
  final String _timeZone;

  final DriverDayInfo _driver;

  @override
  Stream<List<LogDayRef>> watchStrip({int days = 8}) {
    // Kalendar arifmetikasi Home Terminal TZ da: `subtract(Duration(days:1))`
    // DST kunida 23/25 soatga tushib, kunni siljitib yuboradi (#B-32).
    final List<String> keys = recentLogDates(
      now: _time.now(),
      timeZoneName: _timeZone,
      days: days,
    ).reversed.toList(growable: false);

    return combineLatest2<List<DailyLogRow>, List<ViolationRow>, List<LogDayRef>>(
      _logs.watchRecentLogs(driverId: _driverId, days: kLocalLogWindowDays),
      _logs.watchOpenViolations(),
      (List<DailyLogRow> rows, List<ViolationRow> violations) {
        final Map<String, DailyLogRow> byDate = <String, DailyLogRow>{
          for (final DailyLogRow row in rows) row.logDate: row,
        };
        final Set<String> violated = <String>{
          for (final ViolationRow v in violations)
            if (v.severity != LogAlertLevel.warning.wire)
              v.logDate ?? logDateOf(v.occurredAt, _timeZone),
        };
        return <LogDayRef>[
          for (final String key in keys)
            LogDayRef(
              date: calendarDateOf(key),
              certification: DayCertification.fromWire(byDate[key]?.certificationStatus),
              hasViolation: violated.contains(key),
            ),
        ];
      },
    );
  }

  @override
  Stream<LogDayView> watchDay(DateTime date) {
    // [date] — allaqachon Home Terminal kalendar sanasi (marshrut/tasmadan),
    // shuning uchun bu yerda zona konvertatsiyasi **qilinmaydi**, faqat vaqt
    // qismi kesiladi.
    final DateTime day = normalizeCalendarDate(date);
    final String key = logDateKey(day);
    final String oldest = recentLogDates(
      now: _time.now(),
      timeZoneName: _timeZone,
      days: kLocalLogWindowDays,
    ).last;
    final bool available = key.compareTo(oldest) >= 0;

    return combineLatest4<
      DailyLogRow?,
      List<DutyEventRow>,
      List<RefTrailerRow>,
      List<ViolationRow>,
      LogDayView
    >(
      _logs.watchLog(driverId: _driverId, logDate: key),
      _events.watchDay(driverId: _driverId, logDate: key),
      _ref.watchTrailers(),
      _logs.watchViolations(logDate: key),
      (
        DailyLogRow? row,
        List<DutyEventRow> rows,
        List<RefTrailerRow> trailers,
        List<ViolationRow> violations,
      ) => _buildDay(
        day: day,
        row: row,
        rows: rows,
        trailers: trailers,
        violations: violations,
        available: available,
      ),
    );
  }

  @override
  Stream<List<DvirListItem>> watchDvir({int limit = 50}) =>
      combineLatest2<List<DvirReportRow>, List<RefTrailerRow>, List<DvirListItem>>(
        _dvir.watchReports(limit: limit),
        _ref.watchTrailers(),
        (List<DvirReportRow> rows, List<RefTrailerRow> trailers) {
          final Map<String, String> numbers = <String, String>{
            for (final RefTrailerRow t in trailers) t.id: t.number,
          };
          return <DvirListItem>[
            for (final DvirReportRow row in rows)
              DvirListItem(
                id: row.id,
                createdAt: row.createdAt,
                type: row.type,
                trailerNumber: _trailerOf(row, numbers),
              ),
          ];
        },
      );

  @override
  Future<void> submitDriverEdit(DriverLogEdit edit) async {
    final List<DutyEventRow> dayRows = await _events
        .watchDay(driverId: _driverId, logDate: edit.logDate)
        .first;
    final bool locked = dayRows.any((DutyEventRow r) => r.locked);
    final bool overlapsAutoDriving = dayRows.any(
      (DutyEventRow r) =>
          r.status == DutyStatus.dr.wire &&
          r.origin == 'auto' &&
          r.eventTime.isBefore(edit.to) &&
          r.eventTime.add(const Duration(minutes: 1)).isAfter(edit.from),
    );

    final List<DriverEditIssue> issues = validateDriverEdit(
      edit,
      dayLocked: locked,
      overlapsAutoDriving: overlapsAutoDriving,
    );
    if (issues.isNotEmpty) {
      throw DriverEditRejected(issues);
    }

    await _outbox.enqueueDutyEvent(
      eventType: SyncEventType.statusChange,
      status: edit.status.wire,
      special: edit.special.wire,
      origin: EventOrigin.driver,
      eventTime: edit.from,
      driverId: _driverId,
      unitId: edit.unitId,
      notes: edit.note,
      logDate: edit.logDate,
    );
  }

  // --- qurish -------------------------------------------------------------

  LogDayView _buildDay({
    required DateTime day,
    required DailyLogRow? row,
    required List<DutyEventRow> rows,
    required List<RefTrailerRow> trailers,
    required List<ViolationRow> violations,
    required bool available,
  }) {
    final Map<String, String> numbers = <String, String>{
      for (final RefTrailerRow t in trailers) t.id: t.number,
    };

    final List<LogEventView> events = <LogEventView>[
      for (final DutyEventRow r in rows) _toEvent(r, numbers),
    ];
    // Oraliqlar **absolyut** kun boshidan hisoblanadi (#B-32): eventlar UTC,
    // kun chegarasi esa Home Terminal TZ da.
    final String key = logDateKey(day);
    final List<DaySpan> spans = buildDaySpans(
      dayStart: dayStartUtc(key, _timeZone),
      events: events,
      until: _time.now(),
    );
    final Map<DutyStatus, Duration> totals = totalsFromSpans(spans);

    final Set<String> docs = <String>{};
    final Set<String> trailerNumbers = <String>{};
    String? notes;
    for (final DutyEventRow r in rows) {
      docs.addAll(r.shippingDocIds);
      trailerNumbers.addAll(r.trailerIds.map((String id) => numbers[id] ?? id));
      if ((r.notes ?? '').trim().isNotEmpty) {
        notes = r.notes;
      }
    }

    return LogDayView(
      date: day,
      certification: DayCertification.fromWire(row?.certificationStatus),
      timeZone: _timeZone,
      ready: row?.ready ?? false,
      events: events,
      spans: spans,
      totals: totals,
      alerts: _alertsOf(violations),
      shippingDocuments: docs.toList(growable: false),
      trailerNumbers: trailerNumbers.toList(growable: false),
      notes: notes,
      driver: _driver,
      available: available,
    );
  }

  LogEventView _toEvent(DutyEventRow r, Map<String, String> numbers) => LogEventView(
    clientEventId: r.clientEventId,
    status: DutyStatus.tryParse(r.status),
    start: r.eventTime,
    special: SpecialMode.fromWire(r.special),
    origin: LogEventOrigin.fromWire(r.origin),
    location: r.locationText,
    document: r.shippingDocIds.isEmpty ? null : r.shippingDocIds.first,
    trailers: <String>[for (final String id in r.trailerIds) numbers[id] ?? id],
    notes: r.notes,
    odometerM: r.odometerM,
    engineHours: r.engineHours,
    edited: r.supersededBy != null || r.origin == LogEventOrigin.adminEdit.wire,
    locked: r.locked,
    pendingSync: r.syncState == 'pending' || r.syncState == 'inflight',
  );

  String? _trailerOf(DvirReportRow row, Map<String, String> numbers) {
    final Object? raw = row.payload['trailer_id'] ?? row.payload['trailer_number'];
    if (raw is String && raw.isNotEmpty) {
      return numbers[raw] ?? raw;
    }
    return null;
  }

  /// Kunning ogohlantirish/buzilishlari — **`violations` jadvalidan** (#B-05).
  ///
  /// `daily_logs.totals` da bu maydonlar yo'q; mijoz violation yaratmaydi
  /// (M48), faqat serverdan kelganini ko'rsatadi.
  List<LogAlert> _alertsOf(List<ViolationRow> rows) => <LogAlert>[
    for (final ViolationRow row in rows)
      LogAlert(
        level: LogAlertLevel.fromWire(row.severity),
        type: row.type,
        occurredAt: row.occurredAt,
      ),
  ];
}
