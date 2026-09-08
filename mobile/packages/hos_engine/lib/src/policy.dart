// Port of the Policy half of backend/internal/hos/types.go (Q10.1, A§4.2).
import 'package:meta/meta.dart';

import 'model.dart';

/// Split pairing constants (Q10.6): 7/3 and 8/2 combinations.
const int splitMinSleeperMin = 420; // long part must be >= 7h of SB
const int splitMinPartnerMin = 120; // short part must be >= 2h of OFF/SB

/// The "remaining minutes" levels for warnings (Q57.1).
@immutable
class WarningThresholds {
  const WarningThresholds({
    required this.driveMin,
    required this.shiftMin,
    required this.breakMin,
    required this.cycleMin,
  });

  final int driveMin;
  final int shiftMin;
  final int breakMin;
  final int cycleMin;

  /// Go's `json.Unmarshal` into a non-pointer struct keeps the fields that the
  /// document does not mention, so this merges on top of `this`.
  WarningThresholds merge(Map<String, dynamic> json) => WarningThresholds(
    driveMin: _int(json, 'drive', driveMin),
    shiftMin: _int(json, 'shift', shiftMin),
    breakMin: _int(json, 'break', breakMin),
    cycleMin: _int(json, 'cycle', cycleMin),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'drive': driveMin,
    'shift': shiftMin,
    'break': breakMin,
    'cycle': cycleMin,
  };

  @override
  bool operator ==(Object other) =>
      other is WarningThresholds &&
      other.driveMin == driveMin &&
      other.shiftMin == shiftMin &&
      other.breakMin == breakMin &&
      other.cycleMin == cycleMin;

  @override
  int get hashCode => Object.hash(driveMin, shiftMin, breakMin, cycleMin);
}

/// One `hos_policy_versions.policy` document. All durations are minutes.
///
/// JSON keys match `company_dto.HosPolicyDoc` in `contracts/swagger.json`.
@immutable
class HosPolicy {
  const HosPolicy({
    required this.driveLimitMin,
    required this.shiftWindowMin,
    required this.breakRequiredAfterDriveMin,
    required this.breakDurationMin,
    required this.breakQualifyingStatuses,
    required this.dailyRestMin,
    required this.cycleLimitMin,
    required this.cycleDays,
    required this.cycleRestartMin,
    required this.sleeperSplitEnabled,
    required this.sleeperBerthAvailable,
    required this.allowPc,
    required this.allowYm,
    required this.ymMaxSpeedKmh,
    required this.motionThresholdKmh,
    required this.shortHaulException,
    required this.adverseConditionsExtensionMin,
    required this.warningThresholds,
  });

  final int driveLimitMin;
  final int shiftWindowMin;
  final int breakRequiredAfterDriveMin;
  final int breakDurationMin;
  final List<DutyStatus> breakQualifyingStatuses;
  final int dailyRestMin;
  final int cycleLimitMin;
  final int cycleDays;

  /// Null when the policy has no restart provision (Q10.5).
  final int? cycleRestartMin;
  final bool sleeperSplitEnabled;
  final bool sleeperBerthAvailable;
  final bool allowPc;
  final bool allowYm;
  final double ymMaxSpeedKmh;
  final double motionThresholdKmh;
  final bool shortHaulException;
  final int adverseConditionsExtensionMin;
  final WarningThresholds warningThresholds;

  /// Go: `Policy.normalized` — unusable zero values fall back to the defaults.
  /// Booleans and `cycle_restart_min` are deliberately left untouched.
  HosPolicy normalized() {
    const d = _defaults;
    return HosPolicy(
      driveLimitMin: driveLimitMin <= 0 ? d.driveLimitMin : driveLimitMin,
      shiftWindowMin: shiftWindowMin <= 0 ? d.shiftWindowMin : shiftWindowMin,
      breakRequiredAfterDriveMin: breakRequiredAfterDriveMin <= 0
          ? d.breakRequiredAfterDriveMin
          : breakRequiredAfterDriveMin,
      breakDurationMin: breakDurationMin <= 0 ? d.breakDurationMin : breakDurationMin,
      breakQualifyingStatuses: breakQualifyingStatuses.isEmpty
          ? d.breakQualifyingStatuses
          : breakQualifyingStatuses,
      dailyRestMin: dailyRestMin <= 0 ? d.dailyRestMin : dailyRestMin,
      cycleLimitMin: cycleLimitMin <= 0 ? d.cycleLimitMin : cycleLimitMin,
      cycleDays: cycleDays <= 0 ? d.cycleDays : cycleDays,
      cycleRestartMin: cycleRestartMin,
      sleeperSplitEnabled: sleeperSplitEnabled,
      sleeperBerthAvailable: sleeperBerthAvailable,
      allowPc: allowPc,
      allowYm: allowYm,
      ymMaxSpeedKmh: ymMaxSpeedKmh,
      motionThresholdKmh: motionThresholdKmh,
      shortHaulException: shortHaulException,
      adverseConditionsExtensionMin: adverseConditionsExtensionMin,
      warningThresholds: warningThresholds,
    );
  }

  /// Q10.4: does the effective status count toward a break?
  bool breakQualifies(DutyStatus s) => breakQualifyingStatuses.contains(s);

  Duration get driveLimit => Duration(minutes: driveLimitMin);
  Duration get shiftWindow => Duration(minutes: shiftWindowMin);
  Duration get breakAfter => Duration(minutes: breakRequiredAfterDriveMin);
  Duration get breakLen => Duration(minutes: breakDurationMin);
  Duration get dailyRest => Duration(minutes: dailyRestMin);
  Duration get cycleLimit => Duration(minutes: cycleLimitMin);

  /// Go: `Policy.restartLen` — null when the 34h restart is disabled.
  Duration? get restartLen {
    final r = cycleRestartMin;
    if (r == null || r <= 0) return null;
    return Duration(minutes: r);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'drive_limit_min': driveLimitMin,
    'shift_window_min': shiftWindowMin,
    'break_required_after_drive_min': breakRequiredAfterDriveMin,
    'break_duration_min': breakDurationMin,
    'break_qualifying_statuses': breakQualifyingStatuses.map((s) => s.wire).toList(growable: false),
    'daily_rest_min': dailyRestMin,
    'cycle_limit_min': cycleLimitMin,
    'cycle_days': cycleDays,
    'cycle_restart_min': cycleRestartMin,
    'sleeper_split_enabled': sleeperSplitEnabled,
    'sleeper_berth_available': sleeperBerthAvailable,
    'allow_pc': allowPc,
    'allow_ym': allowYm,
    'ym_max_speed_kmh': ymMaxSpeedKmh,
    'motion_threshold_kmh': motionThresholdKmh,
    'short_haul_exception': shortHaulException,
    'adverse_conditions_extension_min': adverseConditionsExtensionMin,
    'warning_thresholds': warningThresholds.toJson(),
  };

  @override
  String toString() => 'HosPolicy${toJson()}';
}

const HosPolicy _defaults = HosPolicy(
  driveLimitMin: 660,
  shiftWindowMin: 840,
  breakRequiredAfterDriveMin: 480,
  breakDurationMin: 30,
  breakQualifyingStatuses: <DutyStatus>[DutyStatus.off, DutyStatus.sb, DutyStatus.on],
  dailyRestMin: 600,
  cycleLimitMin: 4200,
  cycleDays: 8,
  cycleRestartMin: 2040,
  sleeperSplitEnabled: true,
  sleeperBerthAvailable: true,
  allowPc: true,
  allowYm: true,
  ymMaxSpeedKmh: 32,
  motionThresholdKmh: 8,
  shortHaulException: false,
  adverseConditionsExtensionMin: 120,
  warningThresholds: WarningThresholds(driveMin: 30, shiftMin: 60, breakMin: 30, cycleMin: 120),
);

/// Go: `DefaultPolicy` — the FMCSA 70/8 defaults (TZ A§4.2).
HosPolicy defaultPolicy() => _defaults;

/// Go: `ParsePolicy` — decodes a `hos_policy_versions.policy` JSONB document on
/// top of the defaults, so partial documents keep the default values (Q10.1).
///
/// An explicit `"cycle_restart_min": null` disables the 34h restart, exactly
/// like Go unmarshalling `null` into a `*int` field.
HosPolicy parsePolicy(Map<String, dynamic>? json) {
  const d = _defaults;
  if (json == null || json.isEmpty) return d;
  return HosPolicy(
    driveLimitMin: _int(json, 'drive_limit_min', d.driveLimitMin),
    shiftWindowMin: _int(json, 'shift_window_min', d.shiftWindowMin),
    breakRequiredAfterDriveMin: _int(
      json,
      'break_required_after_drive_min',
      d.breakRequiredAfterDriveMin,
    ),
    breakDurationMin: _int(json, 'break_duration_min', d.breakDurationMin),
    breakQualifyingStatuses: _statuses(json, d.breakQualifyingStatuses),
    dailyRestMin: _int(json, 'daily_rest_min', d.dailyRestMin),
    cycleLimitMin: _int(json, 'cycle_limit_min', d.cycleLimitMin),
    cycleDays: _int(json, 'cycle_days', d.cycleDays),
    cycleRestartMin: json.containsKey('cycle_restart_min')
        ? (json['cycle_restart_min'] as num?)?.toInt()
        : d.cycleRestartMin,
    sleeperSplitEnabled: _bool(json, 'sleeper_split_enabled', d.sleeperSplitEnabled),
    sleeperBerthAvailable: _bool(json, 'sleeper_berth_available', d.sleeperBerthAvailable),
    allowPc: _bool(json, 'allow_pc', d.allowPc),
    allowYm: _bool(json, 'allow_ym', d.allowYm),
    ymMaxSpeedKmh: _double(json, 'ym_max_speed_kmh', d.ymMaxSpeedKmh),
    motionThresholdKmh: _double(json, 'motion_threshold_kmh', d.motionThresholdKmh),
    shortHaulException: _bool(json, 'short_haul_exception', d.shortHaulException),
    adverseConditionsExtensionMin: _int(
      json,
      'adverse_conditions_extension_min',
      d.adverseConditionsExtensionMin,
    ),
    warningThresholds: json['warning_thresholds'] is Map
        ? d.warningThresholds.merge((json['warning_thresholds'] as Map).cast<String, dynamic>())
        : d.warningThresholds,
  ).normalized();
}

int _int(Map<String, dynamic> json, String key, int fallback) {
  final v = json[key];
  return v is num ? v.toInt() : fallback;
}

double _double(Map<String, dynamic> json, String key, double fallback) {
  final v = json[key];
  return v is num ? v.toDouble() : fallback;
}

bool _bool(Map<String, dynamic> json, String key, bool fallback) {
  final v = json[key];
  return v is bool ? v : fallback;
}

List<DutyStatus> _statuses(Map<String, dynamic> json, List<DutyStatus> back) {
  final v = json['break_qualifying_statuses'];
  if (v is! List) return back;
  final out = <DutyStatus>[];
  for (final e in v) {
    final s = DutyStatus.parse(e as String?);
    if (s != null) out.add(s);
  }
  return List<DutyStatus>.unmodifiable(out);
}
