// Port of backend/internal/hos/day.go (Q10.2) — the log day is always the home
// terminal 00:00-24:00 window, events are stored in UTC.
import 'package:timezone/timezone.dart' as tz;

import 'policy.dart';

/// Go: `StartOfDay` — local midnight of [t]'s calendar day in [location].
///
/// The result is built from calendar fields, never by subtracting a
/// [Duration], so DST days keep their real 23h/25h length.
tz.TZDateTime startOfDay(DateTime t, tz.Location location) {
  final lt = tz.TZDateTime.from(t, location);
  return tz.TZDateTime(location, lt.year, lt.month, lt.day);
}

/// Go: `DayRange` — `[start, end)` of the log day containing [day]. On DST days
/// the range is 23h or 25h long, which is intentional (Q10.2).
({tz.TZDateTime start, tz.TZDateTime end}) dayRange(DateTime day, tz.Location location) {
  final start = startOfDay(day, location);
  return (start: start, end: addDays(start, 1));
}

/// Go: `t.AddDate(0, 0, days)` on a local midnight — calendar arithmetic in
/// [location], not a [Duration] shift.
tz.TZDateTime addDays(tz.TZDateTime t, int days) => tz.TZDateTime(
  t.location,
  t.year,
  t.month,
  t.day + days,
  t.hour,
  t.minute,
  t.second,
  t.millisecond,
  t.microsecond,
);

/// Go: `DayKey` — the log day formatted as `YYYY-MM-DD` in [location].
String dayKey(DateTime day, tz.Location location) {
  final d = startOfDay(day, location);
  final m = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-$m-$dd';
}

/// Go: `CycleWindowStart` — local midnight of the first day of the rolling
/// cycle window that ends on [at]'s log day: `cycle_days` days including today
/// (Q10.5).
tz.TZDateTime cycleWindowStart(DateTime at, HosPolicy policy, tz.Location location) {
  final p = policy.normalized();
  return addDays(startOfDay(at, location), -(p.cycleDays - 1));
}
