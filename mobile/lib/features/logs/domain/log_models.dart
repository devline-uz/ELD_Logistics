/// Logs moduli domen modellari (tz-mobile §11.4, M-22…M-25).
///
/// `presentation` faqat shu tiplarni ko'radi (M5): Drift qatorlari ham,
/// `eld_api` modellari ham bu yerdan o'tmaydi.
library;

import 'package:hos_engine/hos_engine.dart' show DutyStatus;

import '../../../core/time/day_boundary.dart';
import 'day_timeline.dart';

/// `Log Report` sub-tablari (M-22/23/24).
enum LogTab {
  main('main'),
  logs('logs'),
  dvir('dvir');

  const LogTab(this.wire);

  final String wire;

  static LogTab fromWire(String? wire) {
    for (final LogTab tab in LogTab.values) {
      if (tab.wire == wire) {
        return tab;
      }
    }
    return LogTab.main;
  }
}

/// Maxsus rejim (M65): `none`/`pc`/`ym`.
enum SpecialMode {
  none('none'),
  pc('pc'),
  ym('ym');

  const SpecialMode(this.wire);

  final String wire;

  static SpecialMode fromWire(String? wire) {
    for (final SpecialMode mode in SpecialMode.values) {
      if (mode.wire == wire) {
        return mode;
      }
    }
    return SpecialMode.none;
  }
}

/// Event manbai (M-25 `Origin` badge, M40).
enum LogEventOrigin {
  auto('auto'),
  driver('driver'),
  adminEdit('admin_edit'),
  assigned('assigned'),
  manualNoEld('manual_no_eld');

  const LogEventOrigin(this.wire);

  final String wire;

  static LogEventOrigin fromWire(String? wire) {
    for (final LogEventOrigin origin in LogEventOrigin.values) {
      if (origin.wire == wire) {
        return origin;
      }
    }
    return LogEventOrigin.driver;
  }
}

/// Kunning sertifikatsiya holati (§12.1).
enum DayCertification {
  uncertified('uncertified'),
  certified('certified'),
  needsRecertify('recertify_required'),
  pendingSync('pending_sync');

  const DayCertification(this.wire);

  final String wire;

  static DayCertification fromWire(String? wire) {
    for (final DayCertification value in DayCertification.values) {
      if (value.wire == wire) {
        return value;
      }
    }
    return DayCertification.uncertified;
  }
}

/// Ogohlantirish/buzilish satri (§8.4, M48).
///
/// **#B-05:** manba — lokal `violations` jadvali (`GET /violations` keshi).
/// `daily_logs.totals` da `warnings`/`violations` maydonlari **yo'q va hech
/// qachon bo'lmaydi** (`logs_dto.DayTotals` = `{off_min, sb_min, drive_min,
/// on_min}`), shuning uchun ular o'qilmaydi.
enum LogAlertLevel {
  warning('warning'),
  violation('violation');

  const LogAlertLevel(this.wire);

  /// `violations.severity` qiymati (Go `hos.Severity` bilan bir xil).
  final String wire;

  /// Noma'lum/bo'sh `severity` — eng qattiq daraja (M48: server kanonik).
  static LogAlertLevel fromWire(String? wire) =>
      wire == LogAlertLevel.warning.wire ? LogAlertLevel.warning : LogAlertLevel.violation;
}

class LogAlert {
  const LogAlert({required this.level, required this.type, this.occurredAt});

  final LogAlertLevel level;

  /// `hos_engine` dagi `ViolationType` kodi (`drive_limit`, …). Matn
  /// `presentation` da lokalizatsiya qilinadi (`core/hos/violation_labels`).
  final String type;

  final DateTime? occurredAt;

  @override
  bool operator ==(Object other) =>
      other is LogAlert &&
      other.level == level &&
      other.type == type &&
      other.occurredAt == occurredAt;

  @override
  int get hashCode => Object.hash(level, type, occurredAt);
}

/// Bitta log event (M-23 jadval satri va M-25 tafsiloti).
class LogEventView {
  const LogEventView({
    required this.clientEventId,
    required this.status,
    required this.start,
    this.end,
    this.special = SpecialMode.none,
    this.origin = LogEventOrigin.driver,
    this.location,
    this.document,
    this.trailers = const <String>[],
    this.notes,
    this.odometerM,
    this.engineHours,
    this.edited = false,
    this.originalSummary,
    this.locked = false,
    this.pendingSync = false,
  });

  final String clientEventId;

  /// `null` — status bo'lmagan event (`intermediate`, `power_on` va h.k.).
  final DutyStatus? status;

  final DateTime start;

  /// Keyingi event vaqti; oxirgi event uchun `null` (davom etmoqda).
  final DateTime? end;

  final SpecialMode special;
  final LogEventOrigin origin;
  final String? location;
  final String? document;
  final List<String> trailers;
  final String? notes;
  final int? odometerM;
  final double? engineHours;

  /// M137: `✎` belgisi.
  final bool edited;

  /// M137: asl qiymat qisqacha tavsifi (`DR 13:00–15:00`).
  final String? originalSummary;

  /// `locked=true` — kun sertifikatlangan, tahrirlash faqat edit-request bilan.
  final bool locked;

  /// Outbox'da turgan (hali `acked` emas) event.
  final bool pendingSync;

  Duration? get duration => end?.difference(start);

  /// M-23 `Action` ustuni: `✎` yoki `🔒`.
  bool get isEditable => !locked && status != null;
}

/// Kun sarlavhasidagi haydovchi ma'lumoti (M-22 `Driver Information`).
class DriverDayInfo {
  const DriverDayInfo({this.driverName, this.unitNumber, this.homeTerminal});

  final String? driverName;
  final String? unitNumber;

  /// M97: kanonik `Home Terminal`.
  final String? homeTerminal;
}

/// `M-22`/`M-23` uchun bitta kunning to'liq ko'rinishi.
class LogDayView {
  const LogDayView({
    required this.date,
    required this.certification,
    this.timeZone = kFallbackTimeZone,
    this.ready = false,
    this.events = const <LogEventView>[],
    this.spans = const <DaySpan>[],
    this.totals = const <DutyStatus, Duration>{},
    this.alerts = const <LogAlert>[],
    this.shippingDocuments = const <String>[],
    this.trailerNumbers = const <String>[],
    this.notes,
    this.driver = const DriverDayInfo(),
    this.available = true,
  });

  /// Home Terminal TZ dagi **kalendar sanasi** (vaqt qismi 00:00).
  ///
  /// Bu instant emas — ko'rsatish va tanlov uchun. Oraliq hisoblari
  /// [startUtc]/[endUtc] dan foydalanadi (#B-32, M42).
  final DateTime date;

  /// Kun chegarasi hisoblanadigan IANA zonasi (**qurilma zonasi emas**).
  final String timeZone;

  final DayCertification certification;

  /// Serverning `DailyLogSummary.ready` maydoni (M125).
  final bool ready;

  final List<LogEventView> events;

  /// Grid oraliqlari — [totals] aynan shulardan hisoblanadi, shuning uchun
  /// chiziq va raqamlar hech qachon farq qilmaydi (M98).
  final List<DaySpan> spans;

  final Map<DutyStatus, Duration> totals;
  final List<LogAlert> alerts;
  final List<String> shippingDocuments;
  final List<String> trailerNumbers;
  final String? notes;
  final DriverDayInfo driver;

  /// `false` — 14 kundan eski kun lokalda yo'q (oflayn xatti-harakati).
  final bool available;

  Duration totalOf(DutyStatus code) => totals[code] ?? Duration.zero;

  /// `YYYY-MM-DD`.
  String get logDate => formatLogDate(date);

  /// Kun boshining **absolyut** vaqti (Home Terminal TZ 00:00 → UTC).
  DateTime get startUtc => dayStartUtc(logDate, timeZone);

  /// Kun oxiri (keyingi kun boshi) — DST kunlarida 23/25 soat.
  DateTime get endUtc => dayEndUtc(logDate, timeZone);

  bool get isEmpty => events.isEmpty;
}

/// Sana tasmasi bandi (M96).
class LogDayRef {
  const LogDayRef({required this.date, required this.certification, this.hasViolation = false});

  final DateTime date;
  final DayCertification certification;
  final bool hasViolation;

  bool get certified =>
      certification == DayCertification.certified || certification == DayCertification.pendingSync;
}

/// `DVIR` tabi satri (M-24).
class DvirListItem {
  const DvirListItem({
    required this.id,
    required this.createdAt,
    required this.type,
    this.trailerNumber,
  });

  final String id;
  final DateTime createdAt;

  /// `pre_trip`/`post_trip`.
  final String type;
  final String? trailerNumber;
}
