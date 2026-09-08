// Holat mashinasi, segmentlar va hisoblagichlar — Go compute.go bilan bir xil
// semantika. Golden vektorlar qamramagan chegaraviy yo'llar.
import 'package:hos_engine/hos_engine.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'helpers.dart';

void main() {
  tzdata.initializeTimeZones();
  final p = defaultPolicy();

  test('no history means fully rested', () {
    final c = computeCounters(const <HosEvent>[], p, at('2026-01-15T12:00:00Z'), chicago);
    expect(c.breakLeftMin, 480);
    expect(c.driveLeftMin, 660);
    expect(c.shiftLeftMin, 840);
    expect(c.cycleLeftMin, 4200);
    expect(c.drivingTimeLeftMin, 480);
  });

  test('drivingTimeLeft is min(DRIVE, SHIFT, CYCLE, BREAK) — Q10.9', () {
    // 8h ON then 4h DR: BREAK is untouched by ON, SHIFT is the binding limit.
    final events = <HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.on),
      ev('2026-01-15T08:00:00Z', DutyStatus.dr),
    ];
    final c = computeCounters(events, p, at('2026-01-15T12:00:00Z'), utc);
    expect(c.shiftLeftMin, 840 - 720);
    expect(c.driveLeftMin, 660 - 240);
    expect(c.breakLeftMin, 480 - 240);
    expect(c.cycleLeftMin, 4200 - 720);
    expect(c.drivingTimeLeftMin, 120);
  });

  test('counters never go below zero', () {
    final events = <HosEvent>[ev('2026-01-15T00:00:00Z', DutyStatus.dr)];
    final c = computeCounters(events, p, at('2026-01-16T00:00:00Z'), utc);
    expect(c.driveLeftMin, 0);
    expect(c.shiftLeftMin, 0);
    expect(c.breakLeftMin, 0);
    expect(c.drivingTimeLeftMin, 0);
  });

  test('Q10.3 — OFF/SB does not extend the 14h window', () {
    final events = <HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.on),
      ev('2026-01-15T01:00:00Z', DutyStatus.off), // 5h break, < daily rest
      ev('2026-01-15T06:00:00Z', DutyStatus.on),
    ];
    final c = computeCounters(events, p, at('2026-01-15T10:00:00Z'), utc);
    // Wall clock since 00:00 = 10h, the 5h off does not pause the window.
    expect(c.shiftLeftMin, 840 - 600);
  });

  test('a 10h daily rest resets SHIFT, DRIVE and BREAK', () {
    final events = <HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.dr),
      ev('2026-01-15T09:00:00Z', DutyStatus.off),
      ev('2026-01-15T19:00:00Z', DutyStatus.dr),
    ];
    final c = computeCounters(events, p, at('2026-01-15T20:00:00Z'), utc);
    expect(c.driveLeftMin, 660 - 60);
    expect(c.breakLeftMin, 480 - 60);
    expect(c.shiftLeftMin, 840 - 60);
  });

  test('Q10.4 — the break run must be continuous', () {
    // 20 min OFF, 1 min DR, 20 min OFF: never 30 min in a row.
    final events = <HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.dr),
      ev('2026-01-15T04:00:00Z', DutyStatus.off),
      ev('2026-01-15T04:20:00Z', DutyStatus.dr),
      ev('2026-01-15T04:21:00Z', DutyStatus.off),
      ev('2026-01-15T04:41:00Z', DutyStatus.dr),
    ];
    final c = computeCounters(events, p, at('2026-01-15T05:00:00Z'), utc);
    expect(c.breakLeftMin, 480 - (240 + 1 + 19));
  });

  test('sortedEvents copies, filters and stably sorts', () {
    final events = <HosEvent>[
      ev('2026-01-15T20:00:00Z', DutyStatus.off),
      ev('2026-01-15T12:00:00Z', DutyStatus.dr),
      HosEvent(
        time: at('2026-01-15T12:00:00Z'),
        status: DutyStatus.on,
        type: EventType.intermediate,
      ),
      ev('2026-01-14T22:00:00Z', DutyStatus.off),
      HosEvent(time: at('2026-01-15T13:00:00Z')),
    ];
    final sorted = sortedEvents(events, p);
    expect(sorted.length, 3, reason: 'non duty events are dropped');
    expect(sorted.map((e) => e.time).toList(), <DateTime>[
      at('2026-01-14T22:00:00Z'),
      at('2026-01-15T12:00:00Z'),
      at('2026-01-15T20:00:00Z'),
    ]);
    expect(events.length, 5, reason: 'the caller list is untouched');
  });

  test('equal timestamps keep the original order (stable sort)', () {
    final events = <HosEvent>[
      ev('2026-01-15T12:00:00Z', DutyStatus.on),
      ev('2026-01-15T12:00:00Z', DutyStatus.dr),
      ev('2026-01-15T12:00:00Z', DutyStatus.sb),
    ];
    expect(sortedEvents(events, p).map((e) => e.status).toList(), <DutyStatus>[
      DutyStatus.on,
      DutyStatus.dr,
      DutyStatus.sb,
    ]);
  });

  test('out of order events after an offline sync (Go TestOutOfOrder...)', () {
    final events = <HosEvent>[
      ev('2026-01-15T20:00:00Z', DutyStatus.off),
      ev('2026-01-15T12:00:00Z', DutyStatus.dr),
      ev('2026-01-14T22:00:00Z', DutyStatus.off),
    ];
    final snapshot = List<HosEvent>.of(events);
    final c = computeCounters(events, p, at('2026-01-15T20:00:00Z'), chicago);
    expect(c.driveLeftMin, 180);
    for (var i = 0; i < events.length; i++) {
      expect(identical(events[i], snapshot[i]), isTrue);
    }
  });

  test('walkSegments stops at end and drops empty spans', () {
    final evs = sortedEvents(<HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.dr),
      ev('2026-01-15T00:00:00Z', DutyStatus.on), // zero length -> dropped
      ev('2026-01-15T02:00:00Z', DutyStatus.off),
      ev('2026-01-15T09:00:00Z', DutyStatus.dr), // after `end` -> ignored
    ], p);
    final segs = walkSegments(evs, at('2026-01-15T05:00:00Z'));
    expect(segs.length, 2);
    expect(segs[0].status, DutyStatus.on);
    expect(segs[0].dur, const Duration(hours: 2));
    expect(segs[0].isDuty, isTrue);
    expect(segs[0].isRest, isFalse);
    expect(segs[1].status, DutyStatus.off);
    expect(segs[1].end, at('2026-01-15T05:00:00Z'));
    expect(segs[1].raw, DutyStatus.off);
    expect(segs[1].special, Special.none);
  });

  test('daySegments carries the open status over midnight', () {
    final evs = sortedEvents(<HosEvent>[ev('2026-01-14T22:00:00Z', DutyStatus.dr)], p);
    final segs = daySegments(evs, at('2026-01-15T00:00:00Z'), at('2026-01-16T00:00:00Z'));
    expect(segs.length, 1);
    expect(segs.single.status, DutyStatus.dr);
    expect(segs.single.dur, const Duration(hours: 24));
  });

  test('daySegments assumes OFF before the first known event', () {
    final segs = daySegments(
      const <HosEvent>[],
      at('2026-01-15T00:00:00Z'),
      at('2026-01-16T00:00:00Z'),
    );
    expect(segs.single.status, DutyStatus.off);
  });

  test('HosState can be driven directly with an observer', () {
    final st = HosState(p, at('2026-01-15T00:00:00Z'));
    final seen = <String>[];
    st.obs = (state, sg) => seen.add(sg.status!.wire);
    final evs = sortedEvents(<HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.dr),
      ev('2026-01-15T02:00:00Z', DutyStatus.off),
    ], p);
    for (final sg in walkSegments(evs, at('2026-01-15T04:00:00Z'))) {
      st.advance(sg);
    }
    expect(seen, <String>['DR', 'OFF']);
    expect(st.driveSinceRest, const Duration(hours: 2));
    expect(st.cycleUsed, const Duration(hours: 2));
    expect(st.restActive, isTrue);
    expect(st.counters(at('2026-01-15T04:00:00Z')).driveLeftMin, 660 - 120);
  });

  test('helpers: clampDur, minDur, overlapAfter, utcOf', () {
    expect(clampDur(const Duration(minutes: -5)), Duration.zero);
    expect(clampDur(const Duration(minutes: 5)), const Duration(minutes: 5));
    expect(
      minDur(const Duration(minutes: 1), const Duration(minutes: 2)),
      const Duration(minutes: 1),
    );
    expect(
      minDur(const Duration(minutes: 3), const Duration(minutes: 2)),
      const Duration(minutes: 2),
    );
    final a = at('2026-01-15T00:00:00Z');
    final b = at('2026-01-15T05:00:00Z');
    expect(overlapAfter(a, b, a), const Duration(hours: 5));
    expect(overlapAfter(a, b, at('2026-01-15T03:00:00Z')), const Duration(hours: 2));
    expect(overlapAfter(a, b, b), Duration.zero);
    expect(utcOf(a).isUtc, isTrue);
  });

  test('cycleUsedAt only counts the rolling window', () {
    final events = <HosEvent>[
      // 9 days ago, outside the 8 day window.
      ev('2026-01-06T00:00:00Z', DutyStatus.on),
      ev('2026-01-06T05:00:00Z', DutyStatus.off),
      ev('2026-01-15T00:00:00Z', DutyStatus.on),
      ev('2026-01-15T03:00:00Z', DutyStatus.off),
    ];
    expect(cycleUsedAt(events, p, at('2026-01-15T12:00:00Z'), utc).inMinutes, 180);
  });

  test('a status open at `now` is projected to `now`', () {
    final events = <HosEvent>[ev('2026-01-15T00:00:00Z', DutyStatus.dr)];
    final c = computeCounters(events, p, at('2026-01-15T03:00:00Z'), utc);
    expect(c.driveLeftMin, 660 - 180);
  });
}
