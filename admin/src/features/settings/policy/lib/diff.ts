/**
 * HOS Policy — ikki siyosat hujjati orasidagi farq (8.4, F147).
 *
 * `Publish` tasdiq dialogida foydalanuvchiga **nima o'zgarishini** ko'rsatish
 * uchun: joriy amaldagi siyosat (`useHosPolicy().data.policy`) va yangi
 * qoralama (forma qiymatlari) taqqoslanadi. Sof funksiya — side-effect yo'q,
 * `undefined`/`null` maydonlar ham hisobga olinadi.
 */
import type { HosPolicyDoc } from '@/api/types';

export interface HosPolicyDiffEntry {
  /** `HosPolicyDoc` maydon nomi; ichma-ich maydonlar `warning_thresholds.drive` kabi. */
  field: string;
  oldValue: unknown;
  newValue: unknown;
}

/** `warning_thresholds` dan tashqari, taqqoslanadigan barcha skalyar maydonlar. */
const SCALAR_FIELDS = [
  'drive_limit_min',
  'shift_window_min',
  'break_required_after_drive_min',
  'break_duration_min',
  'daily_rest_min',
  'cycle_limit_min',
  'cycle_days',
  'cycle_restart_min',
  'sleeper_split_enabled',
  'sleeper_berth_available',
  'allow_pc',
  'allow_ym',
  'ym_max_speed_kmh',
  'motion_threshold_kmh',
  'short_haul_exception',
  'adverse_conditions_extension_min',
] as const satisfies readonly (keyof HosPolicyDoc)[];

const WARNING_THRESHOLD_FIELDS = ['break', 'cycle', 'drive', 'shift'] as const;

function sortedArray(value: readonly string[] | undefined): string[] {
  return [...(value ?? [])].sort();
}

function arraysEqual(a: readonly string[] | undefined, b: readonly string[] | undefined): boolean {
  const left = sortedArray(a);
  const right = sortedArray(b);
  return left.length === right.length && left.every((value, index) => value === right[index]);
}

/**
 * `before` va `after` orasidagi farqlarni ro'yxat qiladi. Tartib — forma
 * bo'yicha mantiqiy (drive/shift/break avval, keyin cycle, so'ng qolganlari).
 */
export function diffHosPolicy(
  before: HosPolicyDoc | undefined,
  after: HosPolicyDoc | undefined,
): HosPolicyDiffEntry[] {
  const a = before ?? {};
  const b = after ?? {};
  const entries: HosPolicyDiffEntry[] = [];

  for (const field of SCALAR_FIELDS) {
    if (a[field] !== b[field]) {
      entries.push({ field, oldValue: a[field], newValue: b[field] });
    }
  }

  if (!arraysEqual(a.break_qualifying_statuses, b.break_qualifying_statuses)) {
    entries.push({
      field: 'break_qualifying_statuses',
      oldValue: a.break_qualifying_statuses,
      newValue: b.break_qualifying_statuses,
    });
  }

  for (const key of WARNING_THRESHOLD_FIELDS) {
    const oldValue = a.warning_thresholds?.[key];
    const newValue = b.warning_thresholds?.[key];
    if (oldValue !== newValue) {
      entries.push({ field: `warning_thresholds.${key}`, oldValue, newValue });
    }
  }

  return entries;
}
