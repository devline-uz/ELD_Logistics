/// Server soat verdikti va skew darajalari (§7.2, M39).
library;

import 'package:sync_core/sync_core.dart';

/// Skew (farq) darajasi — §7.2 jadvali.
enum ClockSkewLevel {
  /// ≤ 2 daq — normal, `clock_skew_sec` faqat informativ.
  normal,

  /// > 2 daq — sariq banner.
  warning,

  /// > 10 daq — `T` (timing) malfunction banneri + `malfunction` eventi.
  malfunction;

  /// [skew] bo'yicha darajani aniqlaydi (ishorasi ahamiyatsiz).
  static ClockSkewLevel of(Duration skew) {
    final int seconds = skew.inSeconds.abs();
    if (seconds > 600) {
      return ClockSkewLevel.malfunction;
    }
    if (seconds > 120) {
      return ClockSkewLevel.warning;
    }
    return ClockSkewLevel.normal;
  }
}

/// `PushResponse.clock` — **kanonik** verdikt (M39).
///
/// Mobil o'z hisobini shu bilan almashtiradi; lokal hisob faqat oflayn ishlaydi.
class ClockVerdict {
  const ClockVerdict({
    required this.source,
    required this.clockSkewSec,
    required this.timeUnverified,
    this.warning,
    this.malfunctionCode,
  });

  /// `PushResponse.clock` (`sync_dto.ClockVerdict`) dan.
  factory ClockVerdict.fromJson(Map<String, Object?> json) => ClockVerdict(
    source: EventTimeSource.tryParse(json['source']?.toString()) ?? EventTimeSource.phone,
    clockSkewSec: json['clock_skew_sec'] is num ? (json['clock_skew_sec']! as num).toInt() : 0,
    timeUnverified: json['time_unverified'] == true,
    warning: json['warning'] == true ? 'clock_drift' : null,
    malfunctionCode: json['malfunction_code']?.toString(),
  );

  final EventTimeSource source;
  final int clockSkewSec;
  final bool timeUnverified;

  /// Server bergan ogohlantirish matni (bo'lsa) — logga yoziladi, UI ga emas.
  final String? warning;

  /// `T` — timing malfunction (§7.2).
  final String? malfunctionCode;

  ClockSkewLevel get level => ClockSkewLevel.of(Duration(seconds: clockSkewSec));

  bool get hasMalfunction => malfunctionCode != null && malfunctionCode!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is ClockVerdict &&
      other.source == source &&
      other.clockSkewSec == clockSkewSec &&
      other.timeUnverified == timeUnverified &&
      other.warning == warning &&
      other.malfunctionCode == malfunctionCode;

  @override
  int get hashCode => Object.hash(source, clockSkewSec, timeUnverified, warning, malfunctionCode);

  @override
  String toString() =>
      'ClockVerdict(${source.wire}, skew=${clockSkewSec}s, unverified=$timeUnverified)';
}

/// `TimeSource.reading()` natijasi — eventga yoziladigan vaqt to'plami.
class TimeReading {
  const TimeReading({
    required this.utc,
    required this.source,
    required this.unverified,
    required this.clockSkewSec,
  });

  /// Event vaqti (har doim UTC).
  final DateTime utc;

  final EventTimeSource source;

  /// `phone` manbasida va katta skew da `true` (M40).
  final bool unverified;

  final int clockSkewSec;

  ClockSkewLevel get level => ClockSkewLevel.of(Duration(seconds: clockSkewSec));

  @override
  String toString() => 'TimeReading($utc, ${source.wire}, skew=${clockSkewSec}s)';
}
