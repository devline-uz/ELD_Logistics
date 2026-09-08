/**
 * Duty-status va ELD ulanish holati uchun **yagona** semantik rang xaritasi
 * (fe-design-system §1).
 *
 * Ilgari bu xaritalar to'rt joyda takrorlangan edi (`features/tracking`,
 * `features/dashboard`, `features/logs` × 2) va ikki nusxada qiymatlari ham
 * farq qilardi (`SB`/`ON` almashib ketgan). Modullar orasida import
 * taqiqlangani uchun (ESLint `no-restricted-imports`) kanonik nusxa shu
 * yerda — `src/lib/` da turadi.
 */
import type { BadgeTone } from '@/components/ui/Badge';
import type { StatusChipTone } from '@/components/ui/StatusChip';

/** `OFF | SB | DR | ON` → `StatusChip` toni. */
export const DUTY_STATUS_TONE: Record<string, StatusChipTone> = {
  OFF: 'neutral',
  SB: 'info',
  DR: 'success',
  ON: 'warning',
};

/** `online | idle | offline | disconnected | malfunction` → `Badge` toni. */
export const ONLINE_STATUS_TONE: Record<string, BadgeTone> = {
  online: 'success',
  idle: 'warning',
  offline: 'neutral',
  disconnected: 'error',
  malfunction: 'error',
};

/** Noma'lum qiymat uchun xavfsiz `neutral` bilan o'qish. */
export function dutyStatusTone(status: string | null | undefined): StatusChipTone {
  return DUTY_STATUS_TONE[status ?? 'OFF'] ?? 'neutral';
}

export function onlineStatusTone(status: string | null | undefined): BadgeTone {
  return ONLINE_STATUS_TONE[status ?? 'offline'] ?? 'neutral';
}
