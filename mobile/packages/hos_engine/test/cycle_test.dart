// Q10.5 / Q10.7 — Go TestCycleRestart va TestRecap ekvivalenti.
import 'package:hos_engine/hos_engine.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'helpers.dart';

void main() {
  tzdata.initializeTimeZones();

  final events = <HosEvent>[
    ev('2026-01-12T12:00:00Z', DutyStatus.dr),
    ev('2026-01-12T20:00:00Z', DutyStatus.off),
    ev('2026-01-14T06:00:00Z', DutyStatus.on),
    ev('2026-01-14T08:00:00Z', DutyStatus.off),
  ];
  final now = at('2026-01-14T08:00:00Z');

  test('34h restart zeroes the cycle', () {
    final used = cycleUsedAt(events, defaultPolicy(), now, chicago);
    expect(used.inMinutes, 120);
    expect(lastRestartEnd(events, defaultPolicy(), now, chicago), at('2026-01-14T06:00:00Z'));
  });

  test('cycle_restart_min = null disables the restart', () {
    final p = parsePolicy(<String, dynamic>{'cycle_restart_min': null});
    expect(p.cycleRestartMin, isNull);
    expect(p.restartLen, isNull);
    expect(cycleUsedAt(events, p, now, chicago).inMinutes, 600);
    expect(lastRestartEnd(events, p, now, chicago), isNull);
  });

  test('cycle_restart_min = 0 disables the restart too', () {
    final p = parsePolicy(<String, dynamic>{'cycle_restart_min': 0});
    expect(p.restartLen, isNull);
    expect(lastRestartEnd(events, p, now, chicago), isNull);
  });

  test('cycleWindowStart covers cycle_days including today', () {
    final start = cycleWindowStart(now, defaultPolicy(), chicago);
    expect(dayKey(start, chicago), '2026-01-07');
  });

  test('recap rows (Q10.7)', () {
    final list = <HosEvent>[];
    for (var d = 8; d <= 15; d++) {
      final dd = d.toString().padLeft(2, '0');
      list
        ..add(ev('2026-01-${dd}T13:00:00Z', DutyStatus.on))
        ..add(ev('2026-01-${dd}T23:00:00Z', DutyStatus.off));
    }
    final rows = recap(list, defaultPolicy(), at('2026-01-15T23:00:00Z'), chicago);
    expect(rows.length, 8);
    expect(rows.first.date, '2026-01-08');
    expect(rows.last.date, '2026-01-15');
    expect(rows[7].onDutyMin, 600);
    expect(rows[0].availableMin, 3600);
    expect(rows[4].availableMin, 1200);
    expect(rows[7].availableMin, 0);
    expect(rows[7].gainedNextMin, 600);
    expect(rows[0].gainedNextMin, 0);
    expect(rows[0].toJson()['date'], '2026-01-08');
    expect(rows[0] == rows[0], isTrue);
    expect(rows[0].hashCode, rows[0].hashCode);
    expect(rows[0].toString(), contains('RecapDay'));
  });

  test('recap on an empty history is all-available', () {
    final rows = recap(const <HosEvent>[], defaultPolicy(), at('2026-01-15T23:00:00Z'), chicago);
    expect(rows.every((r) => r.availableMin == 4200), isTrue);
    expect(rows.every((r) => r.onDutyMin == 0), isTrue);
  });
}
