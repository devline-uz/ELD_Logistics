// Port of backend/internal/hos/compute.go and the totals half of day.go.
//
// The state machine, the segment walk and the counter rendering are a literal
// translation: same ordering, same comparison operators, same clamping.
import 'package:timezone/timezone.dart' as tz;

import 'day.dart';
import 'model.dart';
import 'policy.dart';
import 'special.dart';
import 'split.dart';

/// Go: `segment` — one uninterrupted stretch of a single effective duty status.
class Segment {
  Segment({
    required this.start,
    required this.end,
    required this.status,
    required this.raw,
    required this.special,
  });

  final DateTime start;
  final DateTime end;

  /// Effective status (PC -> OFF, YM -> ON).
  final DutyStatus? status;
  final DutyStatus? raw;
  final Special special;

  Duration get dur => end.difference(start);

  bool get isRest => status == DutyStatus.off || status == DutyStatus.sb;

  bool get isDuty => status == DutyStatus.on || status == DutyStatus.dr;
}

/// Plain UTC [DateTime] with the same instant — `tz.TZDateTime` values are
/// normalised before they enter the segment math, exactly like Go's `.UTC()`.
DateTime utcOf(DateTime t) =>
    DateTime.fromMicrosecondsSinceEpoch(t.microsecondsSinceEpoch, isUtc: true);

/// Go: `sortedEvents` — validates, normalizes and sorts a **copy** of the
/// input. The caller's list is never modified; events may arrive out of order
/// (offline sync). The sort is stable, like Go's `sort.SliceStable`.
List<HosEvent> sortedEvents(List<HosEvent> events, HosPolicy p) {
  final out = <HosEvent>[];
  for (final e in events) {
    if (!e.affectsDuty) continue;
    final n = normalizeStatus(e.status, e.special, p);
    out.add(HosEvent(time: utcOf(e.time), status: n.status, special: n.special, type: e.type));
  }
  // Stable sort: Dart's List.sort is not stable, so the original index breaks
  // ties, which reproduces sort.SliceStable exactly.
  final idx = List<int>.generate(out.length, (i) => i, growable: false);
  idx.sort((a, b) {
    final c = out[a].time.compareTo(out[b].time);
    return c != 0 ? c : a.compareTo(b);
  });
  return List<HosEvent>.generate(idx.length, (i) => out[idx[i]], growable: false);
}

/// Go: `walkSegments` — turns the ordered events into segments ending at [end].
List<Segment> walkSegments(List<HosEvent> evs, DateTime end) {
  final segs = <Segment>[];
  for (var i = 0; i < evs.length; i++) {
    final e = evs[i];
    if (!e.time.isBefore(end)) break;
    var next = end;
    if (i + 1 < evs.length && evs[i + 1].time.isBefore(end)) {
      next = evs[i + 1].time;
    }
    if (!next.isAfter(e.time)) continue;
    segs.add(
      Segment(
        start: e.time,
        end: next,
        status: effectiveStatus(e.status, e.special),
        raw: e.status,
        special: e.special,
      ),
    );
  }
  return segs;
}

/// Go: `daySegments` — covers `[from, to)` completely. The status before the
/// first known event is assumed OFF, and the status open at `from` (or at `to`)
/// is carried on.
List<Segment> daySegments(List<HosEvent> evs, DateTime from, DateTime to) {
  DutyStatus? st = DutyStatus.off;
  var sp = Special.none;
  var i = 0;
  for (; i < evs.length && !evs[i].time.isAfter(from); i++) {
    st = evs[i].status;
    sp = evs[i].special;
  }
  final segs = <Segment>[];
  var curStart = from;
  var curStatus = effectiveStatus(st, sp);
  var curRaw = st;
  var curSpecial = sp;
  for (; i < evs.length && evs[i].time.isBefore(to); i++) {
    final e = evs[i];
    if (e.time.isAfter(curStart)) {
      segs.add(
        Segment(start: curStart, end: e.time, status: curStatus, raw: curRaw, special: curSpecial),
      );
    }
    curStart = e.time;
    curStatus = effectiveStatus(e.status, e.special);
    curRaw = e.status;
    curSpecial = e.special;
  }
  if (to.isAfter(curStart)) {
    segs.add(
      Segment(start: curStart, end: to, status: curStatus, raw: curRaw, special: curSpecial),
    );
  }
  return segs;
}

/// Go: `observer` — receives every segment together with the state as it was
/// *before* the segment is applied, which is what the violation detector needs.
typedef HosObserver = void Function(HosState st, Segment sg);

/// Go: `state` — the HOS state machine. It starts fully rested: with no history
/// the driver is assumed to have completed a daily rest.
class HosState {
  HosState(this.p, this.cycleFrom);

  final HosPolicy p;
  HosObserver? obs;

  Duration driveSinceRest = Duration.zero; // Q10.3: reset by daily rest
  Duration driveSinceBreak = Duration.zero; // Q10.4
  Duration breakRun = Duration.zero; // current run of qualifying statuses

  bool shiftActive = false;
  DateTime? shiftStart;
  Duration shiftPaused = Duration.zero; // Q10.6: split pauses the 14h window

  Duration cycleUsed = Duration.zero;
  DateTime cycleFrom;

  RestPeriod rest = const RestPeriod();
  bool restActive = false;
  Duration sbRun = Duration.zero;

  RestPeriod pendingLong = const RestPeriod();
  bool hasLong = false;
  RestPeriod pendingShort = const RestPeriod();
  bool hasShort = false;

  /// Go: `state.fullReset` — a daily rest (or a qualifying sleeper split pair):
  /// the shift window and both drive counters start over (Q10.3, Q10.6).
  void fullReset() {
    shiftActive = false;
    shiftPaused = Duration.zero;
    driveSinceRest = Duration.zero;
    driveSinceBreak = Duration.zero;
    hasLong = false;
    hasShort = false;
  }

  void advance(Segment sg) {
    final d = sg.dur;
    if (d <= Duration.zero) return;
    // A finished rest run is settled before the segment is observed, so that a
    // sleeper split pair (Q10.6) is already applied when violations are checked.
    if (sg.isDuty && restActive) closeRest();
    obs?.call(this, sg);
    // Q10.4: any continuous run of qualifying statuses of break_duration_min
    // clears the accumulated driving time.
    final s = sg.status;
    if (s != null && p.breakQualifies(s)) {
      breakRun += d;
      if (breakRun >= p.breakLen) driveSinceBreak = Duration.zero;
    } else {
      breakRun = Duration.zero;
    }

    if (sg.isRest) {
      applyRest(sg, d);
      return;
    }
    if (!shiftActive) {
      // Q10.3: the shift window opens at the first ON/DR after a daily rest.
      shiftActive = true;
      shiftStart = sg.start;
      shiftPaused = Duration.zero;
    }
    if (sg.status == DutyStatus.dr) {
      driveSinceRest += d;
      driveSinceBreak += d;
    }
    // Q10.5: ON+DR inside the cycle window.
    cycleUsed += overlapAfter(sg.start, sg.end, cycleFrom);
  }

  void applyRest(Segment sg, Duration d) {
    if (!restActive) {
      restActive = true;
      rest = RestPeriod(start: sg.start);
      sbRun = Duration.zero;
    }
    final prev = rest.total;
    rest = rest.copyWith(end: sg.end, total: prev + d);
    if (sg.status == DutyStatus.sb) {
      sbRun += d;
    } else {
      sbRun = Duration.zero;
    }
    if (sbRun > rest.longestSb) rest = rest.copyWith(longestSb: sbRun);
    // Q10.5: cycle restart on continuous OFF/SB.
    final r = p.restartLen;
    if (r != null && prev < r && rest.total >= r) cycleUsed = Duration.zero;
    // Q10.3: daily rest.
    if (prev < p.dailyRest && rest.total >= p.dailyRest) fullReset();
  }

  /// Go: `state.closeRest` — evaluates a finished rest run for sleeper split
  /// pairing (Q10.6).
  void closeRest() {
    final r = rest;
    restActive = false;
    rest = const RestPeriod();
    sbRun = Duration.zero;
    if (r.isDailyRest(p)) return; // already handled by applyRest
    final long = isSplitLong(r, p);
    if (long && shiftActive) {
      // Q10.6: the long part pauses the 14h window.
      shiftPaused += r.total;
    }
    if (long) {
      if (hasShort && splitPairQualifies(pendingShort, r, p)) {
        fullReset();
        return;
      }
      pendingLong = r;
      hasLong = true;
    } else if (isSplitShort(r, p)) {
      if (hasLong && splitPairQualifies(pendingLong, r, p)) {
        fullReset();
        return;
      }
      pendingShort = r;
      hasShort = true;
    }
  }

  /// Go: `state.counters` — renders the remaining times at instant [at].
  HosCounters counters(DateTime at) {
    final driveLeft = clampDur(p.driveLimit - driveSinceRest);
    final breakLeft = clampDur(p.breakAfter - driveSinceBreak);
    final cycleLeft = clampDur(p.cycleLimit - cycleUsed);
    var shiftLeft = p.shiftWindow;
    if (shiftActive) {
      shiftLeft = clampDur(p.shiftWindow - (at.difference(shiftStart!) - shiftPaused));
    }
    // Q10.9
    final driving = minDur(minDur(driveLeft, shiftLeft), minDur(cycleLeft, breakLeft));
    return HosCounters(
      breakLeftMin: breakLeft.inMinutes,
      driveLeftMin: driveLeft.inMinutes,
      shiftLeftMin: shiftLeft.inMinutes,
      cycleLeftMin: cycleLeft.inMinutes,
      drivingTimeLeftMin: driving.inMinutes,
    );
  }
}

/// Go: `Compute` — the BREAK/DRIVE/SHIFT/CYCLE counters at instant [now].
/// [location] is the home terminal timezone used for the cycle window
/// (Q10.2, Q10.5).
HosCounters computeCounters(
  List<HosEvent> events,
  HosPolicy policy,
  DateTime now,
  tz.Location location,
) {
  final p = policy.normalized();
  final evs = sortedEvents(events, p);
  final st = HosState(p, utcOf(cycleWindowStart(now, p, location)));
  final end = utcOf(now);
  for (final sg in walkSegments(evs, end)) {
    st.advance(sg);
  }
  return st.counters(end);
}

/// Go: `DayTotalsFor` / `DayTotalsWith` — sums the four duty lines of one log
/// day (Q10.2). PC time lands on the OFF line and YM time on the ON line
/// (Q4.1, Q4.2). A status still open at midnight continues into the next day.
DayTotals dayTotals(
  List<HosEvent> events,
  DateTime day,
  tz.Location location, {
  HosPolicy? policy,
}) {
  final p = (policy ?? defaultPolicy()).normalized();
  final evs = sortedEvents(events, p);
  final range = dayRange(day, location);
  var off = Duration.zero;
  var sb = Duration.zero;
  var drive = Duration.zero;
  var on = Duration.zero;
  for (final sg in daySegments(evs, utcOf(range.start), utcOf(range.end))) {
    final d = sg.dur;
    switch (sg.status) {
      case DutyStatus.off:
        off += d;
      case DutyStatus.sb:
        sb += d;
      case DutyStatus.dr:
        drive += d;
      case DutyStatus.on:
        on += d;
      case null:
        break;
    }
  }
  return DayTotals(off: off, sb: sb, drive: drive, on: on);
}

Duration clampDur(Duration d) => d < Duration.zero ? Duration.zero : d;

Duration minDur(Duration a, Duration b) => a < b ? a : b;

/// Go: `overlapAfter` — the part of `[start, end)` that lies at or after
/// [from].
Duration overlapAfter(DateTime start, DateTime end, DateTime from) {
  var s = start;
  if (s.isBefore(from)) s = from;
  if (!end.isAfter(s)) return Duration.zero;
  return end.difference(s);
}
