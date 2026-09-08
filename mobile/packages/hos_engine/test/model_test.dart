// Modellar va JSON kalitlari — contracts/swagger.json bilan 1:1.
import 'package:hos_engine/hos_engine.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('DutyStatus wire values', () {
    expect(DutyStatus.values.map((e) => e.wire).toList(), <String>['OFF', 'SB', 'DR', 'ON']);
    expect(DutyStatus.parse('DR'), DutyStatus.dr);
    expect(DutyStatus.parse(''), isNull);
    expect(DutyStatus.parse(null), isNull);
    expect(DutyStatus.tryParse('XX'), isNull);
    expect(DutyStatus.off.toJson(), 'OFF');
    expect(() => DutyStatus.parse('XX'), throwsA(isA<HosException>()));
  });

  test('Special wire values; empty means none', () {
    expect(Special.values.map((e) => e.wire).toList(), <String>['none', 'pc', 'ym']);
    expect(Special.parse(''), Special.none);
    expect(Special.parse(null), Special.none);
    expect(Special.parse('ym'), Special.ym);
    expect(Special.pc.toJson(), 'pc');
    expect(() => Special.parse('teleport'), throwsA(isA<HosException>()));
  });

  test('unknown status / special are rejected at the JSON boundary', () {
    expect(
      () => HosEvent.fromJson(<String, dynamic>{'time': '2026-01-15T12:00:00Z', 'status': 'XX'}),
      throwsA(isA<HosException>()),
    );
    expect(
      () => HosEvent.fromJson(<String, dynamic>{
        'time': '2026-01-15T12:00:00Z',
        'status': 'ON',
        'special': 'teleport',
      }),
      throwsA(isA<HosException>()),
    );
    expect(const HosException('boom').toString(), 'boom');
  });

  test('HosEvent JSON — engine shape and swagger DTO shape', () {
    final e = HosEvent.fromJson(<String, dynamic>{
      'time': '2026-01-15T12:00:00Z',
      'status': 'DR',
      'special': 'none',
      'type': 'status_change',
    });
    expect(e.time.isUtc, isTrue);
    expect(e.status, DutyStatus.dr);
    expect(e.special, Special.none);
    expect(e.type, EventType.statusChange);
    expect(e.affectsDuty, isTrue);
    expect(e.toJson()['time'], '2026-01-15T12:00:00.000Z');
    expect(e.toJson()['status'], 'DR');
    expect(e.toString(), contains('DR'));

    final dto = HosEvent.fromDutyStatusEventJson(<String, dynamic>{
      'event_time': '2026-01-15T12:00:00Z',
      'status': 'ON',
      'special': 'ym',
      'event_type': 'status_change',
    });
    expect(dto.status, DutyStatus.on);
    expect(dto.special, Special.ym);

    expect(e.copyWith(status: DutyStatus.on).status, DutyStatus.on);
    expect(e.copyWith().time, e.time);
  });

  test('only status_change (or an absent type) moves the state machine', () {
    for (final t in <String>[
      EventType.intermediate,
      EventType.login,
      EventType.logout,
      EventType.powerUp,
      EventType.powerDown,
      EventType.certification,
      EventType.trailerChange,
      EventType.docChange,
    ]) {
      expect(
        HosEvent(time: at('2026-01-15T12:00:00Z'), status: DutyStatus.dr, type: t).affectsDuty,
        isFalse,
        reason: t,
      );
    }
    expect(HosEvent(time: at('2026-01-15T12:00:00Z'), status: DutyStatus.dr).affectsDuty, isTrue);
    expect(
      HosEvent(time: at('2026-01-15T12:00:00Z'), status: DutyStatus.dr, type: '').affectsDuty,
      isTrue,
    );
    expect(HosEvent(time: at('2026-01-15T12:00:00Z')).affectsDuty, isFalse);
  });

  test('non duty-status events are ignored by the engine', () {
    final events = <HosEvent>[
      HosEvent(time: at('2026-01-15T00:00:00Z'), status: DutyStatus.dr),
      HosEvent(
        time: at('2026-01-15T01:00:00Z'),
        status: DutyStatus.off,
        type: EventType.intermediate,
      ),
      HosEvent(time: at('2026-01-15T04:00:00Z'), status: DutyStatus.off),
    ];
    expect(dayTotals(events, at('2026-01-15T00:00:00Z'), utc).driveMin, 240);
  });

  test('HosCounters JSON keys match duty_dto.Counters', () {
    const c = HosCounters(
      breakLeftMin: 180,
      driveLeftMin: 420,
      shiftLeftMin: 540,
      cycleLeftMin: 3600,
      drivingTimeLeftMin: 180,
    );
    expect(c.toJson().keys.toSet(), <String>{
      'break_left_min',
      'drive_left_min',
      'shift_left_min',
      'cycle_left_min',
      'driving_time_left_min',
    });
    expect(c == c, isTrue);
    expect(c.hashCode, c.hashCode);
    expect(c.toString(), contains('HosCounters'));
    expect(
      c ==
          const HosCounters(
            breakLeftMin: 0,
            driveLeftMin: 0,
            shiftLeftMin: 0,
            cycleLeftMin: 0,
            drivingTimeLeftMin: 0,
          ),
      isFalse,
    );
  });

  test('DayTotals keeps Durations and truncates once', () {
    final t = DayTotals.minutes(offMin: 600, sbMin: 0, driveMin: 480, onMin: 360);
    expect(t.toJson(), <String, dynamic>{
      'off_min': 600,
      'sb_min': 0,
      'drive_min': 480,
      'on_min': 360,
    });
    expect(t.totalMin, 1440);
    expect(t.onDuty, const Duration(minutes: 840));
    expect(t == DayTotals.minutes(offMin: 600, driveMin: 480, onMin: 360), isTrue);
    expect(t.hashCode, DayTotals.minutes(offMin: 600, driveMin: 480, onMin: 360).hashCode);
    expect(t.toString(), contains('DayTotals'));
    expect(const DayTotals().totalMin, 0);
    // Two 30 s lines truncate to 0 each, but their sum is a whole minute.
    const half = Duration(seconds: 30);
    const s = DayTotals(on: half, drive: half);
    expect(s.onMin, 0);
    expect(s.driveMin, 0);
    expect(s.onDuty.inMinutes, 1, reason: 'Go truncates the sum, not the parts');
  });

  test('HosViolation JSON keys', () {
    final v = HosViolation(
      type: ViolationType.driveLimit,
      severity: Severity.violation,
      occurredAt: at('2026-01-15T12:00:00Z'),
    );
    expect(v.toJson().keys.toSet(), <String>{'type', 'severity', 'at'});
    expect(v.toJson()['at'], '2026-01-15T12:00:00.000Z');
    expect(v == v, isTrue);
    expect(v.hashCode, v.hashCode);
    expect(v.toString(), contains('drive_limit'));
    expect(
      v == const HosViolation(type: ViolationType.driveLimit, severity: Severity.warning),
      isFalse,
    );
  });
}
