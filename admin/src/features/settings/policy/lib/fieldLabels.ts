/**
 * `HosPolicyDoc` maydon nomi → `settings.hos.fields.*` i18n kaliti. Diff
 * dialogida va versiyalar tarixida bir xil yorliqlarni ishlatish uchun
 * `HosPolicyForm` bilan sinxron saqlanadi (8.4).
 */
export const HOS_POLICY_FIELD_LABEL_KEYS: Record<string, string> = {
  drive_limit_min: 'settings.hos.fields.driveLimit',
  shift_window_min: 'settings.hos.fields.shiftWindow',
  daily_rest_min: 'settings.hos.fields.dailyRest',
  break_required_after_drive_min: 'settings.hos.fields.breakRequiredAfter',
  break_duration_min: 'settings.hos.fields.breakDuration',
  break_qualifying_statuses: 'settings.hos.fields.breakQualifyingStatuses',
  cycle_limit_min: 'settings.hos.fields.cycleLimit',
  cycle_days: 'settings.hos.fields.cycleDays',
  cycle_restart_min: 'settings.hos.fields.cycleRestart',
  allow_pc: 'settings.hos.fields.allowPc',
  allow_ym: 'settings.hos.fields.allowYm',
  ym_max_speed_kmh: 'settings.hos.fields.ymMaxSpeed',
  motion_threshold_kmh: 'settings.hos.fields.motionThreshold',
  sleeper_split_enabled: 'settings.hos.fields.sleeperSplitEnabled',
  sleeper_berth_available: 'settings.hos.fields.sleeperBerthAvailable',
  short_haul_exception: 'settings.hos.fields.shortHaulException',
  adverse_conditions_extension_min: 'settings.hos.fields.adverseConditionsExtension',
  'warning_thresholds.drive': 'settings.hos.fields.warningDrive',
  'warning_thresholds.shift': 'settings.hos.fields.warningShift',
  'warning_thresholds.break': 'settings.hos.fields.warningBreak',
  'warning_thresholds.cycle': 'settings.hos.fields.warningCycle',
};

/** Noma'lum maydon nomi bo'lsa — o'zini qaytaradi (kelajakdagi backend maydonlari uchun himoya). */
export function hosPolicyFieldLabelKey(field: string): string {
  return HOS_POLICY_FIELD_LABEL_KEYS[field] ?? field;
}
