/**
 * DVIR/Defect Types modulining backendga xos xato kodlari.
 *
 * `@/lib/errors` dagi `ERROR_CODES` — umumiy HTTP kodlari; `resolveErrorMessage`
 * noma'lum kod uchun `console.warn` chiqaradi (DoD: konsolda ogohlantirish
 * yo'q). Shu sabab modul kodlari shu yerda **oldindan** i18n kalitiga
 * bog'lanadi va faqat qolgan holatda umumiy `message` ishlatiladi.
 */
import { isApiError } from '@/lib/errors';

const MODULE_ERROR_KEYS: Record<string, string> = {
  DVIR_INVALID_TRANSITION: 'dvir.errors.invalidTransition',
  DEFECT_TYPE_SYSTEM_LOCKED: 'dvir.errors.systemLocked',
  UNIQUE_VIOLATION: 'dvir.errors.duplicateName',
};

/**
 * Modulga xos kod bo'lsa i18n kalitini, aks holda `undefined` qaytaradi —
 * chaqiruvchi o'z umumiy fallback matnini ko'rsatadi.
 */
export function dvirErrorMessageKey(error: unknown): string | undefined {
  if (!isApiError(error)) return undefined;
  return MODULE_ERROR_KEYS[error.code];
}
