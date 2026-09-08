/**
 * Audit / company-history diff qiymatlarini maskalash (fe-security §5 — F206).
 *
 * Audit yozuvlari backenddan kelgan **ixtiyoriy** ustun nomi bilan keladi
 * (`field`), shu jumladan parol xeshi, token, TOTP siri yoki guvohnoma
 * raqami kabi maydonlar. UI hech qachon bunday qiymatni ochiq ko'rsatmaydi:
 * maydon nomi sezgir ro'yxatga mos kelsa — qiymat o'rniga `••••••`.
 *
 * Maskalash — ko'rsatish qatlamining oxirgi to'sig'i; backend ham bunday
 * qiymatlarni yubormasligi kutiladi, lekin frontend bunga tayanmaydi.
 */

/** Maskalangan qiymat belgisi — matn emas, shuning uchun i18n talab qilmaydi. */
export const MASKED_VALUE = '••••••';

const SENSITIVE_FIELD_PATTERN =
  /(pass(word|wd|phrase)?|secret|token|hash|salt|otp|totp|mfa|2fa|recovery_code|api[_-]?key|private[_-]?key|credential|ssn|social_security|licen[cs]e_?(no|number)|card_?number|cvv|\bpin\b)/i;

/** `field` nomi sezgir ma'lumotga ishora qiladimi. */
export function isSensitiveField(field: string | undefined | null): boolean {
  if (!field) return false;
  return SENSITIVE_FIELD_PATTERN.test(field);
}

/**
 * Sezgir maydon uchun qiymatni `••••••` bilan almashtiradi; boshqa
 * maydonlarda qiymat o'zgarishsiz qaytadi (bo'sh qiymat ham maskalanmaydi).
 */
export function maskSensitiveValue<T extends string | undefined | null>(
  field: string | undefined | null,
  value: T,
): string | T {
  if (value === undefined || value === null || value === '') return value;
  return isSensitiveField(field) ? MASKED_VALUE : value;
}
