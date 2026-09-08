// Q10.1 — Go TestPolicyParsing ekvivalenti: qisman hujjat defaultlarni saqlaydi.
import 'package:hos_engine/hos_engine.dart';
import 'package:test/test.dart';

void main() {
  test('defaults are the FMCSA 70/8 set', () {
    final d = defaultPolicy();
    expect(d.driveLimitMin, 660);
    expect(d.shiftWindowMin, 840);
    expect(d.breakRequiredAfterDriveMin, 480);
    expect(d.breakDurationMin, 30);
    expect(d.breakQualifyingStatuses, <DutyStatus>[DutyStatus.off, DutyStatus.sb, DutyStatus.on]);
    expect(d.dailyRestMin, 600);
    expect(d.cycleLimitMin, 4200);
    expect(d.cycleDays, 8);
    expect(d.cycleRestartMin, 2040);
    expect(d.sleeperSplitEnabled, isTrue);
    expect(d.sleeperBerthAvailable, isTrue);
    expect(d.allowPc, isTrue);
    expect(d.allowYm, isTrue);
    expect(d.ymMaxSpeedKmh, 32);
    expect(d.motionThresholdKmh, 8);
    expect(d.shortHaulException, isFalse);
    expect(d.adverseConditionsExtensionMin, 120);
    expect(d.warningThresholds.driveMin, 30);
    expect(d.warningThresholds.shiftMin, 60);
    expect(d.warningThresholds.breakMin, 30);
    expect(d.warningThresholds.cycleMin, 120);
    expect(splitMinSleeperMin, 420);
    expect(splitMinPartnerMin, 120);
    expect(d.toString(), contains('HosPolicy'));
  });

  test('parsePolicy overrides on top of the defaults', () {
    final p = parsePolicy(<String, dynamic>{
      'drive_limit_min': 600,
      'cycle_restart_min': null,
      'warning_thresholds': <String, dynamic>{'drive': 15, 'shift': 30, 'break': 20, 'cycle': 60},
    });
    expect(p.driveLimitMin, 600);
    expect(p.cycleRestartMin, isNull, reason: 'null disables the restart');
    expect(p.cycleLimitMin, 4200, reason: 'missing keys keep the defaults');
    expect(p.cycleDays, 8);
    expect(p.warningThresholds.driveMin, 15);
    expect(p.warningThresholds.cycleMin, 60);
  });

  test('an absent cycle_restart_min keeps the 34h default', () {
    expect(parsePolicy(<String, dynamic>{'cycle_days': 7}).cycleRestartMin, 2040);
    expect(parsePolicy(null).cycleRestartMin, 2040);
    expect(parsePolicy(<String, dynamic>{}).cycleDays, 8);
  });

  test('60/7 policy', () {
    final p = parsePolicy(<String, dynamic>{'cycle_limit_min': 3600, 'cycle_days': 7});
    expect(p.cycleLimitMin, 3600);
    expect(p.cycleDays, 7);
    expect(p.cycleLimit, const Duration(minutes: 3600));
  });

  test('normalized() replaces unusable zero values, not booleans', () {
    final p = parsePolicy(<String, dynamic>{
      'drive_limit_min': 0,
      'shift_window_min': -1,
      'break_required_after_drive_min': 0,
      'break_duration_min': 0,
      'break_qualifying_statuses': <String>[],
      'daily_rest_min': 0,
      'cycle_limit_min': 0,
      'cycle_days': 0,
      'sleeper_split_enabled': false,
      'allow_pc': false,
    });
    expect(p.driveLimitMin, 660);
    expect(p.shiftWindowMin, 840);
    expect(p.breakRequiredAfterDriveMin, 480);
    expect(p.breakDurationMin, 30);
    expect(p.breakQualifyingStatuses.length, 3);
    expect(p.dailyRestMin, 600);
    expect(p.cycleLimitMin, 4200);
    expect(p.cycleDays, 8);
    expect(p.sleeperSplitEnabled, isFalse, reason: 'booleans stay as given');
    expect(p.allowPc, isFalse);
  });

  test('duration getters', () {
    final p = defaultPolicy();
    expect(p.driveLimit, const Duration(minutes: 660));
    expect(p.shiftWindow, const Duration(minutes: 840));
    expect(p.breakAfter, const Duration(minutes: 480));
    expect(p.breakLen, const Duration(minutes: 30));
    expect(p.dailyRest, const Duration(minutes: 600));
    expect(p.restartLen, const Duration(minutes: 2040));
  });

  test('round-trips through toJson', () {
    final p = parsePolicy(defaultPolicy().toJson());
    expect(p.toJson(), defaultPolicy().toJson());
    expect(p.toJson()['break_qualifying_statuses'], <String>['OFF', 'SB', 'ON']);
    expect(p.toJson()['cycle_restart_min'], 2040);
  });

  test('warning thresholds merge partially', () {
    final p = parsePolicy(<String, dynamic>{
      'warning_thresholds': <String, dynamic>{'drive': 10},
    });
    expect(p.warningThresholds.driveMin, 10);
    expect(p.warningThresholds.shiftMin, 60, reason: 'untouched key');
    expect(p.warningThresholds.toJson()['break'], 30);
    expect(
      p.warningThresholds ==
          const WarningThresholds(driveMin: 10, shiftMin: 60, breakMin: 30, cycleMin: 120),
      isTrue,
    );
    expect(
      p.warningThresholds.hashCode,
      const WarningThresholds(driveMin: 10, shiftMin: 60, breakMin: 30, cycleMin: 120).hashCode,
    );
  });

  test('wrong types in the document fall back to the defaults', () {
    final p = parsePolicy(<String, dynamic>{
      'drive_limit_min': 'nonsense',
      'allow_pc': 'yes',
      'ym_max_speed_kmh': null,
      'break_qualifying_statuses': 'OFF',
      'warning_thresholds': 5,
    });
    expect(p.driveLimitMin, 660);
    expect(p.allowPc, isTrue);
    expect(p.ymMaxSpeedKmh, 32);
    expect(p.breakQualifyingStatuses.length, 3);
    expect(p.warningThresholds.driveMin, 30);
  });
}
