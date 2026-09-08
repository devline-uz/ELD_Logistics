/**
 * Settings › Profile & Security — forma sxemalari (Bosqich 8.6, fe-screens §2).
 *
 * Sxemalar `t` qabul qiladigan fabrikalar (`buildBranchSchema` /
 * `buildCompanySchema` bilan bir xil naqsh) — validatsiya matnlari
 * `locales/en/settings-profile.json` da, kodda hardcode string yo'q (W6).
 *
 * Parol qoidasi (TZ §18.3): kamida 10 belgi, kamida bitta harf **va** bitta
 * raqam — `features/auth/schemas.ts` dagi qoida bilan bir xil, lekin
 * `features/a → features/b` importi taqiqlangani uchun (fe-conventions §2)
 * bu yerda mustaqil nusxada saqlanadi.
 */
import type { TFunction } from 'i18next';
import { z } from 'zod';

const PASSWORD_MIN_LENGTH = 10;

const buildPasswordRule = (t: TFunction) =>
  z
    .string()
    .min(PASSWORD_MIN_LENGTH, t('settings.security.validation.passwordMin'))
    .refine((value) => /[A-Za-z]/.test(value), t('settings.security.validation.passwordLetter'))
    .refine((value) => /\d/.test(value), t('settings.security.validation.passwordDigit'));

/**
 * `currentPassword` — D41 (`docs/tz/16-17-registry-open-questions.md`):
 * backendda joriy parol bilan bevosita almashtirish endpointi yo'q, shuning
 * uchun bu qiymat hech qayerga yuborilmaydi — faqat foydalanuvchi hozirgi
 * parolini bilishini tasdiqlaydigan mijoz tomoni bosqichi (F151 talabi).
 */
export function buildPasswordChangeSchema(t: TFunction) {
  return z
    .object({
      currentPassword: z.string().min(1, t('settings.security.validation.currentRequired')),
      newPassword: buildPasswordRule(t),
      confirmPassword: z.string().min(1, t('settings.security.validation.confirmRequired')),
    })
    .refine((value) => value.newPassword === value.confirmPassword, {
      message: t('settings.security.validation.mismatch'),
      path: ['confirmPassword'],
    })
    .refine((value) => value.newPassword !== value.currentPassword, {
      message: t('settings.security.validation.sameAsCurrent'),
      path: ['newPassword'],
    });
}
export type PasswordChangeFormValues = z.infer<ReturnType<typeof buildPasswordChangeSchema>>;

export function buildTotpCodeSchema(t: TFunction) {
  return z.object({
    code: z
      .string()
      .trim()
      .regex(/^\d{6}$/, t('settings.security.validation.totpCode')),
  });
}
export type TotpCodeFormValues = z.infer<ReturnType<typeof buildTotpCodeSchema>>;
