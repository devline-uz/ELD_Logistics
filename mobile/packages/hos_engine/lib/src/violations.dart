// Port of backend/internal/hos/violations.go (Q10.3, Q10.4, Q10.5, Q57).
import 'package:timezone/timezone.dart' as tz;

import 'compute.dart';
import 'day.dart';
import 'model.dart';
import 'policy.dart';

/// Go: `violationOrder` — keeps the output deterministic across
/// implementations.
const List<String> violationOrder = <String>[
  ViolationType.driveLimit,
  ViolationType.shiftLimit,
  ViolationType.breakRequired,
  ViolationType.cycleLimit,
];

/// Go: `collector` — records at most one entry per type per log day; a
/// violation always supersedes the warning of the same type (Q57).
class _Collector {
  _Collector(this.p, this.dayStart, this.dayEnd);

  final HosPolicy p;
  final DateTime dayStart;
  final DateTime dayEnd;
  final Map<String, HosViolation> found = <String, HosViolation>{};

  void add(String type, String severity, DateTime at) {
    if (at.isBefore(dayStart) || !at.isBefore(dayEnd)) return;
    final prev = found[type];
    if (prev != null && (prev.severity == Severity.violation || severity == prev.severity)) {
      return;
    }
    found[type] = HosViolation(type: type, severity: severity, occurredAt: utcOf(at));
  }

  List<HosViolation> result() {
    final out = <HosViolation>[];
    for (final type in violationOrder) {
      final v = found[type];
      if (v != null) out.add(v);
    }
    return out;
  }

  /// Go: `collector.track` — records the warning/violation crossings of one
  /// accumulator counter.
  void track(
    String type,
    Duration acc,
    Duration d,
    DateTime start,
    Duration limit,
    Duration warn, {
    required bool canViolate,
  }) {
    if (canViolate) {
      final at = exceedAt(acc, d, start, limit);
      if (at != null) add(type, Severity.violation, at);
    }
    final at = reachAt(acc, d, start, limit - warn);
    if (at != null) add(type, Severity.warning, at);
  }

  /// Go: `collector.observe` — inspects one segment before it is applied.
  void observe(HosState st, Segment sg) {
    if (!sg.isDuty) return;
    final d = sg.dur;
    final driving = sg.status == DutyStatus.dr;
    final th = p.warningThresholds;

    if (driving) {
      // Q10.4 + drive_limit: DR beyond 11h / DR beyond 8h without a break.
      track(
        ViolationType.driveLimit,
        st.driveSinceRest,
        d,
        sg.start,
        p.driveLimit,
        Duration(minutes: th.driveMin),
        canViolate: true,
      );
      track(
        ViolationType.breakRequired,
        st.driveSinceBreak,
        d,
        sg.start,
        p.breakAfter,
        Duration(minutes: th.breakMin),
        canViolate: true,
      );
    }
    // Q10.5: the cycle grows on ON and DR, but only driving over the cycle is
    // a violation.
    final clipped = overlapRange(sg.start, sg.end, st.cycleFrom);
    if (clipped != null) {
      track(
        ViolationType.cycleLimit,
        st.cycleUsed,
        clipped.end.difference(clipped.start),
        clipped.start,
        p.cycleLimit,
        Duration(minutes: th.cycleMin),
        canViolate: driving,
      );
    }
    // Q10.3: the 14h window is wall clock from the shift start; the segment
    // that opens the shift is observed before the state knows about it.
    var shiftStart = sg.start;
    var paused = Duration.zero;
    if (st.shiftActive) {
      shiftStart = st.shiftStart!;
      paused = st.shiftPaused;
    }
    final windowEnd = shiftStart.add(p.shiftWindow + paused);
    if (driving && sg.end.isAfter(windowEnd)) {
      add(ViolationType.shiftLimit, Severity.violation, laterOf(sg.start, windowEnd));
    }
    final warnAt = windowEnd.subtract(Duration(minutes: th.shiftMin));
    if (!sg.end.isBefore(warnAt)) {
      add(ViolationType.shiftLimit, Severity.warning, laterOf(sg.start, warnAt));
    }
  }
}

/// Go: `exceedAt` — the instant an accumulator that starts at [acc] and grows
/// for [d] passes strictly beyond [target] inside the segment starting at
/// [start]. Null when it never does.
DateTime? exceedAt(Duration acc, Duration d, DateTime start, Duration target) {
  var t = target;
  if (t < Duration.zero) t = Duration.zero;
  if (acc + d <= t) return null;
  if (acc >= t) return start;
  return start.add(t - acc);
}

/// Go: `reachAt` — the instant the accumulator reaches [target] (non strict).
DateTime? reachAt(Duration acc, Duration d, DateTime start, Duration target) {
  var t = target;
  if (t < Duration.zero) t = Duration.zero;
  if (acc + d < t) return null;
  if (acc >= t) return start;
  return start.add(t - acc);
}

DateTime laterOf(DateTime a, DateTime b) => a.isAfter(b) ? a : b;

/// Go: `overlapRange` — clips `[start, end)` to the part at or after [from].
({DateTime start, DateTime end})? overlapRange(DateTime start, DateTime end, DateTime from) {
  var s = start;
  if (s.isBefore(from)) s = from;
  if (!end.isAfter(s)) return null;
  return (start: s, end: end);
}

/// Go: `Violations` — evaluates one log day in the home terminal timezone
/// (Q10.2, Q57).
///
/// The whole history is replayed so that counters carry over from previous
/// days; a status left open at the end of the day is projected to midnight.
List<HosViolation> violations(
  List<HosEvent> events,
  HosPolicy policy,
  DateTime day,
  tz.Location location,
) {
  final p = policy.normalized();
  final evs = sortedEvents(events, p);
  final range = dayRange(day, location);
  final dayStart = utcOf(range.start);
  final dayEnd = utcOf(range.end);
  final c = _Collector(p, dayStart, dayEnd);
  final st = HosState(p, utcOf(cycleWindowStart(range.start, p, location)));
  st.obs = c.observe;
  for (final sg in walkSegments(evs, dayEnd)) {
    st.advance(sg);
  }
  return c.result();
}

/// Go: `FormManner` — the form & manner state of a log day (Q57): a missing
/// trailer or shipping document is a warning while the day is open and becomes
/// a violation once the day has been certified.
List<HosViolation> formManner({
  required bool hasTrailer,
  required bool hasDoc,
  required bool certified,
}) {
  final severity = certified ? Severity.violation : Severity.warning;
  final out = <HosViolation>[];
  if (!hasTrailer) {
    out.add(HosViolation(type: ViolationType.formMannerTrailer, severity: severity));
  }
  if (!hasDoc) {
    out.add(HosViolation(type: ViolationType.formMannerDoc, severity: severity));
  }
  return out;
}
