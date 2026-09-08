/**
 * Branches moduliga xos backend xato kodlari (8.3, §7.13.2).
 *
 * `@/lib/errors` dagi `resolveErrorMessage` noma'lum kod uchun `console.warn`
 * chiqaradi (DoD: konsolda ogohlantirish yo'q) — shu sabab modulga xos
 * kodlar shu yerda oldindan i18n kalitiga bog'lanadi (`dvir/lib/errors.ts`
 * bilan bir xil naqsh).
 */
import { isApiError } from '@/lib/errors';

const MODULE_ERROR_KEYS: Record<string, string> = {
  RESOURCE_IN_USE: 'settings.branches.errors.inUse',
};

export function branchErrorMessageKey(error: unknown): string | undefined {
  if (!isApiError(error)) return undefined;
  return MODULE_ERROR_KEYS[error.code];
}
