/**
 * HOS Policy — presetlar (8.4, F146: «Preset tugmalari: `FMCSA 70/8` ·
 * `FMCSA 60/7`»).
 *
 * Qiymatlar ixtiro qilinmagan — `admin/openapi/swagger.json` dagi
 * `HosPolicyDoc`/`WarningThresholds` misol (`@example`) qiymatlaridan
 * olingan (bular backend defaultiga mos, komapaniya hali siyosat
 * saqlamagan bo'lsa shu bilan javob beradi — `hosPolicy.ts` izohi). Faqat
 * `cycle_limit_min`/`cycle_days` FMCSA 49 CFR §395.3(b) bo'yicha 70/8 va
 * 60/7 variantlariga moslab ikkiga bo'lingan.
 */
import type { HosPolicyCreate } from '@/api/types';

/**
 * Swagger `HosPolicyDocInput` — `types.ts` da qulay alias sifatida
 * eksport qilinmagan (faqat `HosPolicyDoc`/`HosPolicyCreate` bor,
 * `api/**` — o'zgartirilmaydi), shu sababli `HosPolicyCreate.policy` dan
 * o'zi olinadi.
 */
export type HosPolicyDocInput = NonNullable<HosPolicyCreate['policy']>;

export const HOS_POLICY_PRESET_KEYS = ['fmcsa_70_8', 'fmcsa_60_7'] as const;
export type HosPolicyPresetKey = (typeof HOS_POLICY_PRESET_KEYS)[number];

const BASE: Omit<HosPolicyDocInput, 'cycle_limit_min' | 'cycle_days'> = {
  drive_limit_min: 660,
  shift_window_min: 840,
  break_required_after_drive_min: 480,
  break_duration_min: 30,
  break_qualifying_statuses: ['OFF', 'SB', 'ON'],
  daily_rest_min: 600,
  cycle_restart_min: 2040,
  sleeper_split_enabled: true,
  sleeper_berth_available: true,
  allow_pc: true,
  allow_ym: true,
  ym_max_speed_kmh: 32,
  motion_threshold_kmh: 8,
  warning_thresholds: { break: 30, cycle: 120, drive: 30, shift: 60 },
  short_haul_exception: false,
  adverse_conditions_extension_min: 120,
};

export const HOS_POLICY_PRESETS: Record<HosPolicyPresetKey, HosPolicyDocInput> = {
  fmcsa_70_8: { ...BASE, cycle_limit_min: 4200, cycle_days: 8 },
  fmcsa_60_7: { ...BASE, cycle_limit_min: 3600, cycle_days: 7 },
};
