/**
 * HOS Policy — forma zod sxemasi (8.4, fe-screens §2).
 *
 * Barcha vaqt maydonlari **daqiqada** saqlanadi (forma darajasida) — `HH:MM`
 * ko'rinishi faqat `DurationField` UI qatlamida, `duration.ts` orqali.
 * Chegaralar backend tomonidan e'lon qilinmagan (swagger `HosPolicyDocInput`
 * faqat tur beradi, min/max yo'q) — quyidagi son chegaralari **frontend
 * himoyasi** sifatida MVP uchun tanlangan (izoh: hisobotda ochiq qaror
 * sifatida qayd etilgan, backend qattiqroq/yumshoqroq bo'lsa server xatosi
 * baribir maydonlarga bog'lanadi).
 */
import { z } from 'zod';

export const BREAK_QUALIFYING_STATUSES = ['OFF', 'SB', 'ON', 'DR'] as const;
export type BreakQualifyingStatus = (typeof BREAK_QUALIFYING_STATUSES)[number];

const minutesField = (max: number) =>
  z
    .number('settings.hos.form.errors.number')
    .int()
    .min(0, 'settings.hos.form.errors.min')
    .max(max, 'settings.hos.form.errors.max');

export const hosPolicyFormSchema = z.object({
  drive_limit_min: minutesField(1440),
  shift_window_min: minutesField(1440),
  break_required_after_drive_min: minutesField(1440),
  break_duration_min: minutesField(480),
  break_qualifying_statuses: z
    .array(z.enum(BREAK_QUALIFYING_STATUSES))
    .min(1, 'settings.hos.form.errors.breakStatusesRequired'),
  daily_rest_min: minutesField(1440),
  cycle_limit_min: minutesField(10080),
  cycle_days: z
    .number('settings.hos.form.errors.number')
    .int()
    .min(1, 'settings.hos.form.errors.min')
    .max(14, 'settings.hos.form.errors.max'),
  cycle_restart_min: minutesField(10080),
  sleeper_split_enabled: z.boolean(),
  sleeper_berth_available: z.boolean(),
  allow_pc: z.boolean(),
  allow_ym: z.boolean(),
  ym_max_speed_kmh: z
    .number('settings.hos.form.errors.number')
    .min(0, 'settings.hos.form.errors.min')
    .max(200, 'settings.hos.form.errors.max'),
  motion_threshold_kmh: z
    .number('settings.hos.form.errors.number')
    .min(0, 'settings.hos.form.errors.min')
    .max(80, 'settings.hos.form.errors.max'),
  warning_thresholds: z.object({
    break: minutesField(1440),
    cycle: minutesField(10080),
    drive: minutesField(1440),
    shift: minutesField(1440),
  }),
  short_haul_exception: z.boolean(),
  adverse_conditions_extension_min: minutesField(480),
});

export type HosPolicyFormValues = z.infer<typeof hosPolicyFormSchema>;
