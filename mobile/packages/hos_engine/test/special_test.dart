// Q4.1, Q4.2, Q4.3, Q5 — Go TestSpecialModes ekvivalenti.
import 'package:hos_engine/hos_engine.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'helpers.dart';

void main() {
  tzdata.initializeTimeZones();
  final p = defaultPolicy();

  test('auto DR starts at motion_threshold_kmh', () {
    expect(shouldStartDriving(8, p), isTrue);
    expect(shouldStartDriving(7.9, p), isFalse);
  });

  test('yard move ends above ym_max_speed_kmh', () {
    expect(shouldExitYardMove(32.1, p), isTrue);
    expect(shouldExitYardMove(32, p), isFalse);
  });

  test('PC never counts as driving', () {
    expect(effectiveStatus(DutyStatus.off, Special.pc), DutyStatus.off);
    expect(countsAsDriving(DutyStatus.off, Special.pc), isFalse);
    // Even a DR record under PC is OFF (Q4.1).
    expect(effectiveStatus(DutyStatus.dr, Special.pc), DutyStatus.off);
    expect(countsAsOnDuty(DutyStatus.dr, Special.pc), isFalse);
  });

  test('YM counts as on duty, not driving', () {
    expect(effectiveStatus(DutyStatus.on, Special.ym), DutyStatus.on);
    expect(countsAsDriving(DutyStatus.on, Special.ym), isFalse);
    expect(countsAsOnDuty(DutyStatus.on, Special.ym), isTrue);
  });

  test('special modes follow allow_pc / allow_ym', () {
    expect(specialAllowed(Special.pc, p), isTrue);
    expect(specialAllowed(Special.none, p), isTrue);
    final noPc = parsePolicy(<String, dynamic>{'allow_pc': false});
    expect(specialAllowed(Special.pc, noPc), isFalse);
    final noYm = parsePolicy(<String, dynamic>{'allow_ym': false});
    expect(specialAllowed(Special.ym, noYm), isFalse);
    // A disallowed mode falls back to the plain status.
    final n = normalizeStatus(DutyStatus.off, Special.pc, noPc);
    expect(n.special, Special.none);
    expect(n.status, DutyStatus.off);
  });

  test('Q4.3 — without a sleeper berth SB is treated as OFF', () {
    final noBerth = parsePolicy(<String, dynamic>{'sleeper_berth_available': false});
    final n = normalizeStatus(DutyStatus.sb, Special.none, noBerth);
    expect(n.status, DutyStatus.off);
    expect(normalizeStatus(DutyStatus.sb, Special.none, p).status, DutyStatus.sb);
  });

  test('PC time lands on the OFF line, YM on the ON line', () {
    final events = <HosEvent>[
      ev('2026-01-15T12:00:00Z', DutyStatus.off, special: Special.pc),
      ev('2026-01-15T14:00:00Z', DutyStatus.on, special: Special.ym),
      ev('2026-01-15T15:00:00Z', DutyStatus.off),
    ];
    final t = dayTotals(events, at('2026-01-15T18:00:00Z'), utc);
    expect(t.driveMin, 0);
    expect(t.onMin, 60);
    // 00:00-12:00 implicit OFF + PC 2h + 15:00-24:00 OFF.
    expect(t.offMin, 720 + 120 + 540);
    expect(t.sbMin, 0);
  });

  test('YM consumes SHIFT but not DRIVE', () {
    final events = <HosEvent>[ev('2026-01-15T12:00:00Z', DutyStatus.on, special: Special.ym)];
    final c = computeCounters(events, p, at('2026-01-15T16:00:00Z'), utc);
    expect(c.driveLeftMin, 660);
    expect(c.shiftLeftMin, 840 - 240);
  });
}
