/**
 * HOS Policy — `HosPolicyDoc` (backend, ba'zi maydonlar `undefined` bo'lishi
 * mumkin) ↔ `HosPolicyFormValues` (forma, hammasi to'ldirilgan) aylantirish.
 * `FMCSA 70/8` preset — yetishmayotgan maydonlar uchun default (8.4).
 */
import type { HosPolicyDoc } from '@/api/types';

import { HOS_POLICY_PRESETS, type HosPolicyDocInput } from './presets';
import type { HosPolicyFormValues } from './schema';

const DEFAULTS: HosPolicyDocInput = HOS_POLICY_PRESETS.fmcsa_70_8;

export function hosPolicyDocToFormValues(doc: HosPolicyDoc | undefined): HosPolicyFormValues {
  const source = doc ?? {};
  return {
    drive_limit_min: source.drive_limit_min ?? DEFAULTS.drive_limit_min ?? 0,
    shift_window_min: source.shift_window_min ?? DEFAULTS.shift_window_min ?? 0,
    break_required_after_drive_min:
      source.break_required_after_drive_min ?? DEFAULTS.break_required_after_drive_min ?? 0,
    break_duration_min: source.break_duration_min ?? DEFAULTS.break_duration_min ?? 0,
    break_qualifying_statuses: [
      ...(source.break_qualifying_statuses ?? DEFAULTS.break_qualifying_statuses ?? []),
    ] as HosPolicyFormValues['break_qualifying_statuses'],
    daily_rest_min: source.daily_rest_min ?? DEFAULTS.daily_rest_min ?? 0,
    cycle_limit_min: source.cycle_limit_min ?? DEFAULTS.cycle_limit_min ?? 0,
    cycle_days: source.cycle_days ?? DEFAULTS.cycle_days ?? 1,
    cycle_restart_min: source.cycle_restart_min ?? DEFAULTS.cycle_restart_min ?? 0,
    sleeper_split_enabled: source.sleeper_split_enabled ?? DEFAULTS.sleeper_split_enabled ?? false,
    sleeper_berth_available:
      source.sleeper_berth_available ?? DEFAULTS.sleeper_berth_available ?? false,
    allow_pc: source.allow_pc ?? DEFAULTS.allow_pc ?? false,
    allow_ym: source.allow_ym ?? DEFAULTS.allow_ym ?? false,
    ym_max_speed_kmh: source.ym_max_speed_kmh ?? DEFAULTS.ym_max_speed_kmh ?? 0,
    motion_threshold_kmh: source.motion_threshold_kmh ?? DEFAULTS.motion_threshold_kmh ?? 0,
    warning_thresholds: {
      break: source.warning_thresholds?.break ?? DEFAULTS.warning_thresholds?.break ?? 0,
      cycle: source.warning_thresholds?.cycle ?? DEFAULTS.warning_thresholds?.cycle ?? 0,
      drive: source.warning_thresholds?.drive ?? DEFAULTS.warning_thresholds?.drive ?? 0,
      shift: source.warning_thresholds?.shift ?? DEFAULTS.warning_thresholds?.shift ?? 0,
    },
    short_haul_exception: source.short_haul_exception ?? DEFAULTS.short_haul_exception ?? false,
    adverse_conditions_extension_min:
      source.adverse_conditions_extension_min ?? DEFAULTS.adverse_conditions_extension_min ?? 0,
  };
}

export function formValuesToHosPolicyDocInput(values: HosPolicyFormValues): HosPolicyDocInput {
  return { ...values };
}
