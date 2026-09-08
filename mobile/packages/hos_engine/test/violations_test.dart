// Q57 — violations() va formManner(). 10 turdagi katalog, warning/violation
// darajalari, tartib va kunlik deduplikatsiya.
import 'package:hos_engine/hos_engine.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'helpers.dart';

List<String> _pairs(List<HosViolation> v) => v.map((e) => '${e.type}/${e.severity}').toList();

void main() {
  tzdata.initializeTimeZones();
  final p = defaultPolicy();

  test('catalogue has the ten types of contracts/swagger.json', () {
    expect(ViolationType.all.length, 10);
    expect(ViolationType.all, <String>[
      'form_manner_trailer',
      'form_manner_doc',
      'drive_limit',
      'shift_limit',
      'break_required',
      'cycle_limit',
      'uncertified_log',
      'unidentified_driving',
      'eld_malfunction',
      'missing_dvir',
    ]);
    expect(Severity.warning, 'warning');
    expect(Severity.violation, 'violation');
    // The engine itself computes exactly four of them, in a fixed order.
    expect(violationOrder, <String>[
      ViolationType.driveLimit,
      ViolationType.shiftLimit,
      ViolationType.breakRequired,
      ViolationType.cycleLimit,
    ]);
  });

  test('form & manner (Q57)', () {
    expect(formManner(hasTrailer: true, hasDoc: true, certified: true), isEmpty);
    final open = formManner(hasTrailer: false, hasDoc: false, certified: false);
    expect(_pairs(open), <String>['form_manner_trailer/warning', 'form_manner_doc/warning']);
    expect(open.first.occurredAt, isNull);
    final certified = formManner(hasTrailer: true, hasDoc: false, certified: true);
    expect(_pairs(certified), <String>['form_manner_doc/violation']);
    expect(certified.first.toJson()['at'], isNull);
  });

  test('drive_limit: warning then violation, violation wins', () {
    final day = at('2026-01-15T00:00:00Z');
    // 10h35m driving crosses the 30 min warning threshold only.
    final warn = <HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.dr),
      ev('2026-01-15T10:35:00Z', DutyStatus.off),
    ];
    expect(_pairs(violations(warn, p, day, utc)), contains('drive_limit/warning'));

    // 12h driving passes 11h -> violation replaces the warning.
    final bad = <HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.dr),
      ev('2026-01-15T12:00:00Z', DutyStatus.off),
    ];
    final got = violations(bad, p, day, utc);
    expect(got.where((v) => v.type == ViolationType.driveLimit).length, 1);
    expect(_pairs(got), contains('drive_limit/violation'));
    expect(
      got.firstWhere((v) => v.type == ViolationType.driveLimit).occurredAt,
      at('2026-01-15T11:00:00Z'),
    );
  });

  test('break_required fires after 8h of driving without a break', () {
    final day = at('2026-01-15T00:00:00Z');
    final events = <HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.dr),
      ev('2026-01-15T09:00:00Z', DutyStatus.off),
    ];
    expect(_pairs(violations(events, p, day, utc)), contains('break_required/violation'));
    // A 30 min qualifying break clears the accumulator.
    final withBreak = <HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.dr),
      ev('2026-01-15T07:00:00Z', DutyStatus.off),
      ev('2026-01-15T07:30:00Z', DutyStatus.dr),
      ev('2026-01-15T09:30:00Z', DutyStatus.off),
    ];
    expect(_pairs(violations(withBreak, p, day, utc)), isNot(contains('break_required/violation')));
  });

  test('ON duty qualifies as a break by default but not under a strict policy', () {
    final day = at('2026-01-15T00:00:00Z');
    final events = <HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.dr),
      ev('2026-01-15T07:00:00Z', DutyStatus.on),
      ev('2026-01-15T07:30:00Z', DutyStatus.dr),
      ev('2026-01-15T09:30:00Z', DutyStatus.off),
    ];
    expect(_pairs(violations(events, p, day, utc)), isNot(contains('break_required/violation')));
    final strict = parsePolicy(<String, dynamic>{
      'break_qualifying_statuses': <String>['OFF', 'SB'],
    });
    expect(strict.breakQualifies(DutyStatus.on), isFalse);
    expect(_pairs(violations(events, strict, day, utc)), contains('break_required/violation'));
  });

  test('shift_limit is wall clock from the first ON/DR after a daily rest', () {
    final day = at('2026-01-15T00:00:00Z');
    final events = <HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.on),
      ev('2026-01-15T01:00:00Z', DutyStatus.dr),
      ev('2026-01-15T06:00:00Z', DutyStatus.off),
      ev('2026-01-15T12:00:00Z', DutyStatus.dr),
      ev('2026-01-15T16:00:00Z', DutyStatus.off),
    ];
    final got = violations(events, p, day, utc);
    expect(_pairs(got), contains('shift_limit/violation'));
    // 14h window opened at 00:00 -> breach at 14:00.
    expect(
      got.firstWhere((v) => v.type == ViolationType.shiftLimit).occurredAt,
      at('2026-01-15T14:00:00Z'),
    );
  });

  test('violations outside the requested log day are dropped', () {
    // The breach happens on the 15th; asking for the 16th returns nothing.
    final events = <HosEvent>[
      ev('2026-01-15T00:00:00Z', DutyStatus.dr),
      ev('2026-01-15T12:00:00Z', DutyStatus.off),
    ];
    expect(violations(events, p, at('2026-01-16T00:00:00Z'), utc), isEmpty);
  });

  test('an empty day is clean', () {
    expect(violations(const <HosEvent>[], p, at('2026-01-15T00:00:00Z'), utc), isEmpty);
  });

  test('exceedAt / reachAt boundary behaviour', () {
    final start = at('2026-01-15T00:00:00Z');
    const hour = Duration(hours: 1);
    // exceedAt is strict, reachAt is not.
    expect(exceedAt(Duration.zero, hour, start, hour), isNull);
    expect(reachAt(Duration.zero, hour, start, hour), start.add(hour));
    expect(exceedAt(hour, hour, start, hour), start);
    expect(exceedAt(Duration.zero, hour, start, const Duration(minutes: -5)), start);
    expect(reachAt(Duration.zero, hour, start, const Duration(minutes: -5)), start);
    expect(reachAt(Duration.zero, Duration.zero, start, hour), isNull);
  });

  test('overlapRange / laterOf', () {
    final a = at('2026-01-15T00:00:00Z');
    final b = at('2026-01-15T05:00:00Z');
    expect(overlapRange(a, b, a)!.start, a);
    expect(overlapRange(a, b, at('2026-01-15T02:00:00Z'))!.start, at('2026-01-15T02:00:00Z'));
    expect(overlapRange(a, b, b), isNull);
    expect(laterOf(a, b), b);
    expect(laterOf(b, a), b);
  });

  test('cycle_limit warning and violation', () {
    // 8 days x 9h ON = 4320 min > 4200 limit; the last day drives over it.
    final events = <HosEvent>[];
    for (var d = 8; d <= 15; d++) {
      final dd = d.toString().padLeft(2, '0');
      events
        ..add(ev('2026-01-${dd}T06:00:00Z', DutyStatus.dr))
        ..add(ev('2026-01-${dd}T15:00:00Z', DutyStatus.off));
    }
    final got = violations(events, p, at('2026-01-15T12:00:00Z'), utc);
    expect(_pairs(got), contains('cycle_limit/violation'));
  });
}
