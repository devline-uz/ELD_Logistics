/**
 * Reports ekranlarining umumiy filtr yordamchilari (Bosqich 6.11 ko'rigi —
 * dublikat topilmasi). Sana oralig'i URL filtrlarida `YYYY-MM-DD` qatori
 * sifatida saqlanadi; oldin bu almashtirish `ActivityReportPage` va
 * `DvirReportPage`da alohida-alohida yozilgan edi (`DvirReportPage`dagi
 * nusxa `toISOString()` ishlatib manfiy UTC ofsetida bir kunga adashardi).
 *
 * Chorak/yil tanlovi ham `DistanceByRegionPage` va
 * `DistanceReportGenerateModal` orasida takrorlangan edi.
 */
import type { SelectOption } from '@/components/ui/Select';
import { toDateParam } from '@/lib/format';

/** Mahalliy kalendar sanasi → `YYYY-MM-DD` URL filtri (`null` → `undefined`). */
export function toDateFilter(date: Date | null | undefined): string | undefined {
  return date ? toDateParam(date) : undefined;
}

/** `YYYY-MM-DD` URL filtri → mahalliy `Date` (noto'g'ri qiymat → `null`). */
export function fromDateFilter(value: string | undefined): Date | null {
  if (!value) return null;
  const date = new Date(`${value.slice(0, 10)}T00:00:00`);
  return Number.isNaN(date.getTime()) ? null : date;
}

/** Joriy chorak (1–4). */
export function currentQuarter(): number {
  return Math.floor(new Date().getMonth() / 3) + 1;
}

export const QUARTER_OPTIONS: SelectOption<string>[] = ['1', '2', '3', '4'].map((value) => ({
  value,
  label: value,
}));

/** Oxirgi `count` yil (joriy yildan orqaga) — IFTA/Distance filtrlari uchun. */
export function buildYearOptions(count = 6): SelectOption<string>[] {
  const currentYear = new Date().getFullYear();
  return Array.from({ length: count }, (_, index) => String(currentYear - index)).map((value) => ({
    value,
    label: value,
  }));
}
