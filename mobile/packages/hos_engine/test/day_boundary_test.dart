// Q10.2 — Go TestDayBoundaryTZ ekvivalenti. Kun chegarasi Home Terminal TZ da,
// DST kunlari 23h/25h.
import 'package:hos_engine/hos_engine.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'helpers.dart';

void main() {
  tzdata.initializeTimeZones();

  group('dayRange', () {
    final cases = <String, ({tz.Location loc, DateTime day, String start, int len})>{
      'chicago winter': (
        loc: chicago,
        day: at('2026-01-15T12:00:00Z'),
        start: '2026-01-15T06:00:00Z',
        len: 1440,
      ),
      'chicago dst start': (
        loc: chicago,
        day: at('2026-03-08T12:00:00Z'),
        start: '2026-03-08T06:00:00Z',
        len: 1380,
      ),
      'chicago dst end': (
        loc: chicago,
        day: at('2026-11-01T12:00:00Z'),
        start: '2026-11-01T05:00:00Z',
        len: 1500,
      ),
      'karachi': (
        loc: karachi,
        day: at('2026-09-06T11:00:00Z'),
        start: '2026-09-05T19:00:00Z',
        len: 1440,
      ),
    };
    cases.forEach((name, c) {
      test(name, () {
        final r = dayRange(c.day, c.loc);
        expect(utcOf(r.start), at(c.start));
        expect(utcOf(r.end).difference(utcOf(r.start)).inMinutes, c.len, reason: 'log day length');
      });
    });
  });

  test('the same UTC events land on different log days per terminal TZ', () {
    final events = <HosEvent>[
      ev('2026-09-06T02:00:00Z', DutyStatus.on),
      ev('2026-09-06T03:00:00Z', DutyStatus.dr),
      ev('2026-09-06T11:00:00Z', DutyStatus.off),
    ];
    final day = at('2026-09-06T11:00:00Z');
    expect(dayTotals(events, day, karachi).driveMin, 480);
    expect(dayTotals(events, day, chicago).driveMin, 360);
  });

  test('dayKey and startOfDay are local-calendar based', () {
    expect(dayKey(at('2026-09-06T02:00:00Z'), chicago), '2026-09-05');
    expect(dayKey(at('2026-09-06T02:00:00Z'), karachi), '2026-09-06');
    final s = startOfDay(at('2026-11-01T12:00:00Z'), chicago);
    expect(s.hour, 0);
    expect(s.minute, 0);
    // 25h day: adding one calendar day is not adding 24h.
    expect(addDays(s, 1).difference(s).inHours, 25);
  });

  test('a DST day still adds up to its real length', () {
    for (final day in <String>['2026-03-08T12:00:00Z', '2026-11-01T12:00:00Z']) {
      final events = <HosEvent>[ev('2026-03-01T00:00:00Z', DutyStatus.off)];
      final t = dayTotals(events, at(day), chicago);
      final r = dayRange(at(day), chicago);
      expect(t.total, utcOf(r.end).difference(utcOf(r.start)));
      expect(t.totalMin, t.offMin);
    }
  });

  test('utc location behaves like Go time.UTC', () {
    expect(dayKey(at('2026-01-15T23:59:00Z'), utc), '2026-01-15');
    expect(utcOf(startOfDay(at('2026-01-15T23:59:00Z'), utc)), at('2026-01-15T00:00:00Z'));
  });
}
