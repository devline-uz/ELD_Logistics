/// Log tahrirlash (taklif/tasdiq) domen modellari — tz-mobile §13, M-26/M-27.
library;

/// So'rov manbai (`source` badge).
enum LogEditSource {
  adminEdit('admin'),
  unidentifiedAssign('unidentified');

  const LogEditSource(this.wire);

  final String wire;

  static LogEditSource fromWire(String? wire) =>
      wire == unidentifiedAssign.wire ? unidentifiedAssign : adminEdit;
}

/// Haydovchining lokal qarori (hali push qilinmagan bo'lishi mumkin, M135).
enum LogEditDecision {
  none('none'),
  approved('approved'),
  rejected('rejected');

  const LogEditDecision(this.wire);

  final String wire;

  static LogEditDecision fromWire(String? wire) {
    for (final LogEditDecision value in LogEditDecision.values) {
      if (value.wire == wire) {
        return value;
      }
    }
    return LogEditDecision.none;
  }
}

/// Bitta taklif qilingan o'zgarish (`LogEditChange`).
class LogEditChange {
  const LogEditChange({
    required this.from,
    required this.to,
    required this.proposedStatus,
    this.proposedSpecial = 'none',
    this.currentStatus,
    this.currentSpecial = 'none',
    this.note,
    this.eventType = 'status_change',
    this.currentOrigin,
  });

  final DateTime from;
  final DateTime to;

  /// Taklif qilingan status (`OFF`/`SB`/`DR`/`ON`).
  final String proposedStatus;
  final String proposedSpecial;

  /// Asl (joriy) status — yonma-yon ko'rsatiladi.
  final String? currentStatus;
  final String currentSpecial;

  /// Admin sababi.
  final String? note;

  /// `status_change`, `intermediate`, `power_on`, `malfunction`, …
  final String eventType;

  /// Asl eventning manbai (`auto` bo'lsa M133 kuchga kiradi).
  final String? currentOrigin;
}

/// `M-26`/`M-27` uchun so'rov.
class LogEditRequestView {
  const LogEditRequestView({
    required this.id,
    required this.logDate,
    required this.createdAt,
    required this.source,
    this.requestedBy,
    this.changes = const <LogEditChange>[],
    this.decision = LogEditDecision.none,
    this.pendingSync = false,
  });

  final String id;

  /// `YYYY-MM-DD`.
  final String logDate;
  final DateTime createdAt;
  final LogEditSource source;
  final String? requestedBy;
  final List<LogEditChange> changes;

  /// Lokal qaror (outbox'da turgan bo'lishi mumkin).
  final LogEditDecision decision;
  final bool pendingSync;

  int get changeCount => changes.length;
}
