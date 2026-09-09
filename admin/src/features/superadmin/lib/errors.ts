/**
 * Super Admin — `/companies*` moduliga xos backend xato kodlari (9.15, §7.14).
 *
 * `@/lib/errors` dagi `resolveErrorMessage` noma'lum kod uchun `console.warn`
 * chiqaradi (DoD: konsolda ogohlantirish yo'q) — shu sabab modulga xos kodlar
 * shu yerda oldindan i18n kalitiga bog'lanadi (`branches/lib/errors.ts`
 * bilan bir xil naqsh).
 */
import { isApiError } from '@/lib/errors';

const MODULE_ERROR_KEYS: Record<string, string> = {
  UNIQUE_VIOLATION: 'superadmin.companies.errors.nameTaken',
  IDEMPOTENCY_CONFLICT: 'superadmin.companies.errors.idempotencyConflict',
};

export function adminCompanyErrorMessageKey(error: unknown): string | undefined {
  if (!isApiError(error)) return undefined;
  return MODULE_ERROR_KEYS[error.code];
}
