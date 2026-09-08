/// HOS ko'rsatkichlarining domen kesimi (tz-mobile §8, M4 bosqichi).
///
/// `hos_engine` — sof Dart paket; vaqt **parametr** sifatida keladi
/// (`DateTime.now()` bu qatlamda taqiq).
library;

import 'package:hos_engine/hos_engine.dart';
import 'package:timezone/timezone.dart' as tz;

import 'duty_status_models.dart';

/// Bitta hisoblash natijasi — Home, `M-12` va `M-15` shundan chizadi.
class HosSnapshot {
  const HosSnapshot({
    required this.counters,
    required this.totals,
    required this.violations,
    required this.policy,
    required this.computedAt,
  });

  /// Bo'sh (hali hisoblanmagan) kesim.
  factory HosSnapshot.empty(DateTime at) => HosSnapshot(
    counters: const HosCounters(
      breakLeftMin: 0,
      driveLeftMin: 0,
      shiftLeftMin: 0,
      cycleLeftMin: 0,
      drivingTimeLeftMin: 0,
    ),
    totals: const DayTotals(
      off: Duration.zero,
      sb: Duration.zero,
      drive: Duration.zero,
      on: Duration.zero,
    ),
    violations: const <HosViolation>[],
    policy: defaultPolicy(),
    computedAt: at,
  );

  final HosCounters counters;
  final DayTotals totals;
  final List<HosViolation> violations;
  final HosPolicy policy;
  final DateTime computedAt;

  Duration get breakLeft => Duration(minutes: counters.breakLeftMin);
  Duration get driveLeft => Duration(minutes: counters.driveLeftMin);
  Duration get shiftLeft => Duration(minutes: counters.shiftLeftMin);
  Duration get cycleLeft => Duration(minutes: counters.cycleLeftMin);

  /// `M-15`: `min(DRIVE, SHIFT, CYCLE, BREAK)` (Q10.9).
  Duration get drivingTimeLeft => Duration(minutes: counters.drivingTimeLeftMin);

  Duration get breakTotal => Duration(minutes: policy.breakRequiredAfterDriveMin);
  Duration get driveTotal => Duration(minutes: policy.driveLimitMin);
  Duration get shiftTotal => Duration(minutes: policy.shiftWindowMin);
  Duration get cycleTotal => Duration(minutes: policy.cycleLimitMin);

  bool get hasViolation => violations.any((HosViolation v) => v.severity == Severity.violation);
}

/// Duty eventlar va policy'dan HOS kesimini hisoblaydi.
///
/// [now] — `TimeSource` dan; [location] — Home Terminal zonasi (M42).
HosSnapshot computeHosSnapshot({
  required List<HosEvent> events,
  required HosPolicy policy,
  required DateTime now,
  required tz.Location location,
}) => HosSnapshot(
  counters: computeCounters(events, policy, now, location),
  totals: dayTotals(events, now, location, policy: policy),
  violations: violations(events, policy, now, location),
  policy: policy,
  computedAt: now,
);

/// Grid uchun bir kunlik segmentlar (`M-09` log bloki).
class DutyDaySegment {
  const DutyDaySegment({
    required this.status,
    required this.special,
    required this.start,
    required this.end,
  });

  final DutyStatusValue status;
  final DutySpecial special;

  /// Kun boshidan hisoblangan siljish.
  final Duration start;
  final Duration end;
}

/// `[from, to)` oralig'ini to'liq qoplaydigan segmentlar.
List<DutyDaySegment> dutyDaySegments({
  required List<HosEvent> events,
  required HosPolicy policy,
  required DateTime dayStartUtc,
  required DateTime dayEndUtc,
}) {
  final List<HosEvent> ordered = sortedEvents(events, policy);
  return <DutyDaySegment>[
    for (final Segment segment in daySegments(ordered, dayStartUtc.toUtc(), dayEndUtc.toUtc()))
      DutyDaySegment(
        status: DutyStatusValue.tryParse(segment.raw?.wire) ?? DutyStatusValue.off,
        special: DutySpecial.parse(segment.special.wire),
        start: segment.start.toUtc().difference(dayStartUtc.toUtc()),
        end: segment.end.toUtc().difference(dayStartUtc.toUtc()),
      ),
  ];
}
