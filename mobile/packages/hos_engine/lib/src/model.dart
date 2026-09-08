// Port of backend/internal/hos/types.go (Q4, Q57).
//
// JSON keys are the contract shared with `contracts/swagger.json`; they must
// never be renamed on one side only.
import 'package:meta/meta.dart';

/// Q4: duty statuses. DR is never selected manually, it is produced by motion.
enum DutyStatus {
  off('OFF'),
  sb('SB'),
  dr('DR'),
  on('ON');

  const DutyStatus(this.wire);

  /// The value used on the wire and in the golden vectors.
  final String wire;

  /// Go: `Status.Valid` — an unknown string is rejected, empty means "absent"
  /// and is represented by `null` in Dart.
  static DutyStatus? tryParse(String? s) {
    if (s == null || s.isEmpty) return null;
    for (final v in DutyStatus.values) {
      if (v.wire == s) return v;
    }
    return null;
  }

  /// Throws [HosException] for an unknown status (Go: `ErrUnknownStatus`).
  static DutyStatus? parse(String? s) {
    if (s == null || s.isEmpty) return null;
    final v = tryParse(s);
    if (v == null) {
      throw HosException('hos: unknown duty status: "$s"');
    }
    return v;
  }

  String toJson() => wire;
}

/// Q4.1/Q4.2: special modes layered on OFF (PC) and ON (YM).
enum Special {
  none('none'),
  pc('pc'),
  ym('ym');

  const Special(this.wire);

  final String wire;

  /// Go: `Special.Valid` — the empty string is valid and means [Special.none].
  /// Throws [HosException] for an unknown mode (Go: `ErrUnknownSpecial`).
  static Special parse(String? s) {
    if (s == null || s.isEmpty) return Special.none;
    for (final v in Special.values) {
      if (v.wire == s) return v;
    }
    throw HosException('hos: unknown special mode: "$s"');
  }

  String toJson() => wire;
}

/// Go: `EventType` constants. Only [statusChange] (and an absent type) moves the
/// duty state machine; the rest are positional/administrative (Q5.2).
abstract final class EventType {
  static const String statusChange = 'status_change';
  static const String intermediate = 'intermediate';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String powerUp = 'power_up';
  static const String powerDown = 'power_down';
  static const String certification = 'certification';
  static const String trailerChange = 'trailer_change';
  static const String docChange = 'doc_change';
}

/// One duty-status record. [time] is always UTC (TZ B§6.1 rule 7).
@immutable
class HosEvent {
  HosEvent({required DateTime time, this.status, this.special = Special.none, this.type})
    : time = time.toUtc();

  /// Engine/golden-vector shape: `{"time","status","special","type"}`.
  factory HosEvent.fromJson(Map<String, dynamic> json) => HosEvent(
    time: DateTime.parse(json['time'] as String),
    status: DutyStatus.parse(json['status'] as String?),
    special: Special.parse(json['special'] as String?),
    type: json['type'] as String?,
  );

  /// `duty_dto.DutyStatusEvent` / `sync_dto.EventPush` shape from
  /// `contracts/swagger.json`: `{"event_time","status","special","event_type"}`.
  factory HosEvent.fromDutyStatusEventJson(Map<String, dynamic> json) => HosEvent(
    time: DateTime.parse(json['event_time'] as String),
    status: DutyStatus.parse(json['status'] as String?),
    special: Special.parse(json['special'] as String?),
    type: json['event_type'] as String?,
  );

  final DateTime time;
  final DutyStatus? status;
  final Special special;
  final String? type;

  /// Go: `Event.affectsDuty`.
  bool get affectsDuty {
    if (status == null) return false;
    return type == null || type!.isEmpty || type == EventType.statusChange;
  }

  HosEvent copyWith({DateTime? time, DutyStatus? status, Special? special}) => HosEvent(
    time: time ?? this.time,
    status: status ?? this.status,
    special: special ?? this.special,
    type: type,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'time': time.toUtc().toIso8601String(),
    'status': status?.wire,
    'special': special.wire,
    if (type != null) 'type': type,
  };

  @override
  String toString() => 'HosEvent(${time.toIso8601String()}, ${status?.wire}, ${special.wire})';
}

/// Remaining times shown by the driver app (TZ A§4.1), in whole minutes.
///
/// Go stores `time.Duration`; the Dart port stores minutes because that is what
/// the golden vectors and `duty_dto.Counters` compare (truncating division,
/// identical to Go's `int(d / time.Minute)`).
@immutable
class HosCounters {
  const HosCounters({
    required this.breakLeftMin,
    required this.driveLeftMin,
    required this.shiftLeftMin,
    required this.cycleLeftMin,
    required this.drivingTimeLeftMin,
  });

  final int breakLeftMin;
  final int driveLeftMin;
  final int shiftLeftMin;
  final int cycleLeftMin;

  /// Q10.9: `min(DRIVE, SHIFT, CYCLE, BREAK)`.
  final int drivingTimeLeftMin;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'break_left_min': breakLeftMin,
    'drive_left_min': driveLeftMin,
    'shift_left_min': shiftLeftMin,
    'cycle_left_min': cycleLeftMin,
    'driving_time_left_min': drivingTimeLeftMin,
  };

  @override
  bool operator ==(Object other) =>
      other is HosCounters &&
      other.breakLeftMin == breakLeftMin &&
      other.driveLeftMin == driveLeftMin &&
      other.shiftLeftMin == shiftLeftMin &&
      other.cycleLeftMin == cycleLeftMin &&
      other.drivingTimeLeftMin == drivingTimeLeftMin;

  @override
  int get hashCode =>
      Object.hash(breakLeftMin, driveLeftMin, shiftLeftMin, cycleLeftMin, drivingTimeLeftMin);

  @override
  String toString() => 'HosCounters${toJson()}';
}

/// The four duty-line totals of one log day (Q10.2).
///
/// Go stores `time.Duration` and truncates to minutes only at the DTO boundary
/// (`minutesOf` in `internal/domain/duty/service.go`). The Dart port keeps the
/// same shape so that sums such as `on + drive` are truncated once, not twice.
@immutable
class DayTotals {
  const DayTotals({
    this.off = Duration.zero,
    this.sb = Duration.zero,
    this.drive = Duration.zero,
    this.on = Duration.zero,
  });

  /// Convenience constructor used by tests and by callers that already work in
  /// whole minutes.
  DayTotals.minutes({int offMin = 0, int sbMin = 0, int driveMin = 0, int onMin = 0})
    : off = Duration(minutes: offMin),
      sb = Duration(minutes: sbMin),
      drive = Duration(minutes: driveMin),
      on = Duration(minutes: onMin);

  final Duration off;
  final Duration sb;
  final Duration drive;
  final Duration on;

  int get offMin => off.inMinutes;
  int get sbMin => sb.inMinutes;
  int get driveMin => drive.inMinutes;
  int get onMin => on.inMinutes;

  /// Go: `DayTotals.Total` — length of the log day: 23h/25h on DST days.
  Duration get total => off + sb + drive + on;

  int get totalMin => total.inMinutes;

  /// ON+DR, the cycle contribution of the day (Q10.5, Q10.7).
  Duration get onDuty => on + drive;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'off_min': offMin,
    'sb_min': sbMin,
    'drive_min': driveMin,
    'on_min': onMin,
  };

  @override
  bool operator ==(Object other) =>
      other is DayTotals &&
      other.off == off &&
      other.sb == sb &&
      other.drive == drive &&
      other.on == on;

  @override
  int get hashCode => Object.hash(off, sb, drive, on);

  @override
  String toString() => 'DayTotals${toJson()}';
}

/// Violation types (Q57). The four computed by this engine come first; the
/// remaining ones are raised by the server from non-HOS state but share the
/// catalogue so that `logs_dto.Violation.type` values stay identical.
abstract final class ViolationType {
  static const String formMannerTrailer = 'form_manner_trailer';
  static const String formMannerDoc = 'form_manner_doc';
  static const String driveLimit = 'drive_limit';
  static const String shiftLimit = 'shift_limit';
  static const String breakRequired = 'break_required';
  static const String cycleLimit = 'cycle_limit';
  static const String uncertifiedLog = 'uncertified_log';
  static const String unidentifiedDriving = 'unidentified_driving';
  static const String eldMalfunction = 'eld_malfunction';
  static const String missingDvir = 'missing_dvir';

  /// All ten types of the catalogue, in `contracts/swagger.json` order.
  static const List<String> all = <String>[
    formMannerTrailer,
    formMannerDoc,
    driveLimit,
    shiftLimit,
    breakRequired,
    cycleLimit,
    uncertifiedLog,
    unidentifiedDriving,
    eldMalfunction,
    missingDvir,
  ];
}

/// Severity levels (Q57).
abstract final class Severity {
  static const String warning = 'warning';
  static const String violation = 'violation';
}

/// One warning/violation occurrence. Violations are never deleted, they are
/// closed with `resolved_at` at the storage layer (Q58).
@immutable
class HosViolation {
  const HosViolation({required this.type, required this.severity, this.occurredAt});

  final String type;
  final String severity;

  /// Go: `Violation.At`, JSON key `at`. Null for [formManner] results, which
  /// describe the day as a whole and carry no instant.
  final DateTime? occurredAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'severity': severity,
    'at': occurredAt?.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is HosViolation &&
      other.type == type &&
      other.severity == severity &&
      other.occurredAt == occurredAt;

  @override
  int get hashCode => Object.hash(type, severity, occurredAt);

  @override
  String toString() => '$type/$severity@${occurredAt?.toIso8601String()}';
}

/// Go: `ErrUnknownStatus` / `ErrUnknownSpecial`.
class HosException implements Exception {
  const HosException(this.message);

  final String message;

  @override
  String toString() => message;
}
