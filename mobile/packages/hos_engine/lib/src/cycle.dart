// Port of backend/internal/hos/cycle.go (Q10.5, Q10.7).
import 'package:meta/meta.dart';
import 'package:timezone/timezone.dart' as tz;

import 'compute.dart';
import 'day.dart';
import 'model.dart';
import 'policy.dart';

/// Go: `CycleUsedAt` — the ON+DR total inside the cycle window at instant [at].
/// A continuous OFF/SB of `cycle_restart_min` resets it to zero (Q10.5).
Duration cycleUsedAt(List<HosEvent> events, HosPolicy policy, DateTime at, tz.Location location) {
  final p = policy.normalized();
  final evs = sortedEvents(events, p);
  return _cycleUsedBetween(evs, p, utcOf(cycleWindowStart(at, p, location)), utcOf(at));
}

/// Go: `cycleUsedBetween` — replays the events up to [until] with an explicit
/// window start.
Duration _cycleUsedBetween(List<HosEvent> evs, HosPolicy p, DateTime cycleFrom, DateTime until) {
  final st = HosState(p, cycleFrom);
  for (final sg in walkSegments(evs, utcOf(until))) {
    st.advance(sg);
  }
  return st.cycleUsed;
}

/// Go: `LastRestartEnd` — the end of the last completed cycle restart before
/// [at] (continuous OFF/SB of `cycle_restart_min`). Null when there is none or
/// when the policy disables restarts (Q10.5).
DateTime? lastRestartEnd(
  List<HosEvent> events,
  HosPolicy policy,
  DateTime at,
  tz.Location location,
) {
  final p = policy.normalized();
  final restart = p.restartLen;
  if (restart == null) return null;
  final evs = sortedEvents(events, p);
  DateTime? runStart;
  var running = false;
  DateTime? found;
  for (final sg in walkSegments(evs, utcOf(at))) {
    if (sg.isRest) {
      if (!running) {
        running = true;
        runStart = sg.start;
      }
      if (sg.end.difference(runStart!) >= restart) found = sg.end;
      continue;
    }
    running = false;
  }
  return found;
}

/// One row of the cycle recap table (Q10.7). JSON keys match
/// `duty_dto.RecapDay` in `contracts/swagger.json`.
@immutable
class RecapDay {
  const RecapDay({
    required this.date,
    required this.onDutyMin,
    required this.availableMin,
    required this.gainedNextMin,
  });

  /// The log day, `YYYY-MM-DD` in the home terminal timezone.
  final String date;

  /// ON+DR logged that day.
  final int onDutyMin;

  /// `cycle_limit` minus what was used at the end of that day.
  final int availableMin;

  /// Hours coming back the next day.
  final int gainedNextMin;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'date': date,
    'on_duty_min': onDutyMin,
    'available_min': availableMin,
    'gained_next_min': gainedNextMin,
  };

  @override
  bool operator ==(Object other) =>
      other is RecapDay &&
      other.date == date &&
      other.onDutyMin == onDutyMin &&
      other.availableMin == availableMin &&
      other.gainedNextMin == gainedNextMin;

  @override
  int get hashCode => Object.hash(date, onDutyMin, availableMin, gainedNextMin);

  @override
  String toString() => 'RecapDay${toJson()}';
}

/// Go: `Recap` — `cycle_days` rows ending on [day], oldest first (Q10.7).
///
/// `available[d] = cycle_limit - sum(ON+DR of the cycle window ending on d)`;
/// `gained_next[d]` = ON+DR of the day that drops out of the window tomorrow,
/// i.e. the day `(cycle_days - 1)` days before `d`.
List<RecapDay> recap(List<HosEvent> events, HosPolicy policy, DateTime day, tz.Location location) {
  final p = policy.normalized();
  final evs = sortedEvents(events, p);
  final last = startOfDay(day, location);
  final rows = <RecapDay>[];
  for (var i = p.cycleDays - 1; i >= 0; i--) {
    final d = addDays(last, -i);
    final end = dayRange(d, location).end;
    final totals = dayTotals(events, d, location, policy: p);
    final used = _cycleUsedBetween(evs, p, utcOf(cycleWindowStart(d, p, location)), utcOf(end));
    final dropped = dayTotals(events, addDays(d, -(p.cycleDays - 1)), location, policy: p);
    rows.add(
      RecapDay(
        date: dayKey(d, location),
        onDutyMin: totals.onDuty.inMinutes,
        availableMin: clampDur(p.cycleLimit - used).inMinutes,
        gainedNextMin: dropped.onDuty.inMinutes,
      ),
    );
  }
  return rows;
}
