// Q10.6 — Go TestSplitSleeper ekvivalenti.
import 'package:hos_engine/hos_engine.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'helpers.dart';

HosPolicy _withSplit(HosPolicy p, {required bool enabled}) =>
    parsePolicy(<String, dynamic>{...p.toJson(), 'sleeper_split_enabled': enabled});

HosPolicy _withBerth(HosPolicy p, {required bool available}) =>
    parsePolicy(<String, dynamic>{...p.toJson(), 'sleeper_berth_available': available});

void main() {
  tzdata.initializeTimeZones();
  final p = defaultPolicy();

  const long7 = RestPeriod(total: Duration(hours: 7), longestSb: Duration(hours: 7));
  const long8 = RestPeriod(total: Duration(hours: 8), longestSb: Duration(hours: 8));
  const short3 = RestPeriod(total: Duration(hours: 3));
  const short2 = RestPeriod(total: Duration(hours: 2));
  const short1 = RestPeriod(total: Duration(hours: 1));
  const weak6 = RestPeriod(total: Duration(hours: 6), longestSb: Duration(hours: 6));

  group('splitPairQualifies', () {
    final cases = <String, ({RestPeriod a, RestPeriod b, HosPolicy p, bool w})>{
      '7/3': (a: long7, b: short3, p: p, w: true),
      '3/7 order does not matter': (a: short3, b: long7, p: p, w: true),
      '8/2': (a: long8, b: short2, p: p, w: true),
      '7/2 too short in total': (a: long7, b: short2, p: p, w: false),
      '6/3 sleeper part too short': (a: weak6, b: short3, p: p, w: false),
      '8/1 partner too short': (a: long8, b: short1, p: p, w: false),
      'disabled by policy': (a: long7, b: short3, p: _withSplit(p, enabled: false), w: false),
      'no sleeper berth': (a: long7, b: short3, p: _withBerth(p, available: false), w: false),
    };
    cases.forEach((name, c) {
      test(name, () => expect(splitPairQualifies(c.a, c.b, c.p), c.w));
    });
  });

  test('isSplitLong / isSplitShort', () {
    expect(isSplitLong(long7, p), isTrue);
    expect(isSplitLong(weak6, p), isFalse);
    expect(isSplitShort(short3, p), isTrue);
    expect(isSplitShort(short1, p), isFalse);
    // >= daily rest is no longer a "short" part.
    expect(isSplitShort(const RestPeriod(total: Duration(hours: 10)), p), isFalse);
    expect(isSplitLong(long7, _withSplit(p, enabled: false)), isFalse);
    expect(isSplitShort(short3, _withBerth(p, available: false)), isFalse);
    expect(splitEnabled(p), isTrue);
    expect(long7.isDailyRest(p), isFalse);
    expect(const RestPeriod(total: Duration(hours: 10)).isDailyRest(p), isTrue);
    expect(long7.toString(), contains('RestPeriod'));
    expect(long7.copyWith(total: const Duration(hours: 9)).total, const Duration(hours: 9));
  });

  test('a qualifying 7/3 pair resets DRIVE like a daily rest', () {
    final events = <HosEvent>[
      ev('2026-01-15T08:00:00Z', DutyStatus.dr),
      ev('2026-01-15T14:00:00Z', DutyStatus.sb),
      ev('2026-01-15T21:00:00Z', DutyStatus.dr),
      ev('2026-01-16T01:00:00Z', DutyStatus.off),
      ev('2026-01-16T04:00:00Z', DutyStatus.on),
    ];
    final c = computeCounters(events, defaultPolicy(), at('2026-01-16T05:00:00Z'), chicago);
    expect(c.driveLeftMin, 660);
    expect(c.shiftLeftMin, 780);
  });

  test('the same pattern with a 6h sleeper part does not qualify', () {
    final events = <HosEvent>[
      ev('2026-01-15T08:00:00Z', DutyStatus.dr),
      ev('2026-01-15T15:00:00Z', DutyStatus.sb),
      ev('2026-01-15T21:00:00Z', DutyStatus.dr),
      ev('2026-01-16T01:00:00Z', DutyStatus.off),
      ev('2026-01-16T04:00:00Z', DutyStatus.on),
    ];
    final c = computeCounters(events, defaultPolicy(), at('2026-01-16T05:00:00Z'), chicago);
    expect(c.driveLeftMin, isNot(660));
  });

  test('short part first, long part second also qualifies (3/7)', () {
    // 6h DR -> 3h OFF (short, pending) -> 2h DR -> 7h SB (long) -> pair resets.
    final events = <HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.dr),
      ev('2026-01-15T06:00:00Z', DutyStatus.off),
      ev('2026-01-15T09:00:00Z', DutyStatus.dr),
      ev('2026-01-15T11:00:00Z', DutyStatus.sb),
      ev('2026-01-15T18:00:00Z', DutyStatus.dr),
    ];
    final c = computeCounters(events, defaultPolicy(), at('2026-01-15T19:00:00Z'), utc);
    expect(c.driveLeftMin, 660 - 60, reason: 'DRIVE reset by the 3/7 pair');
    expect(c.shiftLeftMin, 840 - 60);
  });

  test('a long part alone only pauses the 14h window', () {
    // 2h DR -> 7h SB (long, no partner yet) -> DR: DRIVE keeps accumulating,
    // but the shift window is paused by the sleeper part.
    final events = <HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.dr),
      ev('2026-01-15T02:00:00Z', DutyStatus.sb),
      ev('2026-01-15T09:00:00Z', DutyStatus.dr),
    ];
    final c = computeCounters(events, defaultPolicy(), at('2026-01-15T10:00:00Z'), utc);
    expect(c.driveLeftMin, 660 - 180, reason: 'no pair yet');
    expect(c.shiftLeftMin, 840 - (600 - 420), reason: '7h SB pauses the window');
  });
}
