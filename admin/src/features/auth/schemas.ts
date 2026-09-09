/**
 * Auth forma sxemalari (0.11).
 *
 * Zod — birinchi qatlam validatsiya (fe-screens §2). Ikkinchi qatlam —
 * server javobi (`VALIDATION_ERROR.details[]`), `lib/errors.ts` orqali
 * maydonlarga bog'lanadi (`onError` har sahifada).
 *
 * Sxemalar `t` qabul qiladigan fabrikalar (`buildDvirRepairSchema` /
 * `buildPasswordChangeSchema` bilan bir xil naqsh, TD5) — validatsiya
 * matnlari `auth.validation.*` kalitlaridan keladi, kodda hardcode string
 * yo'q (W6).
 *
 * Parol qoidasi (TZ §18.3): kamida 10 belgi, kamida bitta harf **va** bitta
 * raqam.
 */
import type { TFunction } from 'i18next';
import { z } from 'zod';

const PASSWORD_MIN_LENGTH = 10;

export function buildPasswordSchema(t: TFunction) {
  return z
    .string()
    .min(PASSWORD_MIN_LENGTH, t('auth.validation.passwordMin'))
    .refine((value) => /[A-Za-z]/.test(value), t('auth.validation.passwordLetter'))
    .refine((value) => /\d/.test(value), t('auth.validation.passwordNumber'));
}

export function buildLoginSchema(t: TFunction) {
  return z.object({
    identifier: z.string().min(1, t('auth.validation.identifierRequired')),
    password: z.string().min(1, t('auth.validation.passwordRequired')),
    remember: z.boolean(),
  });
}
export type LoginFormValues = z.infer<ReturnType<typeof buildLoginSchema>>;

export function buildTotpVerifySchema(t: TFunction) {
  return z.object({
    code: z
      .string()
      .trim()
      .regex(/^\d{6}$/, t('auth.validation.totpCode')),
  });
}
export type TotpVerifyFormValues = z.infer<ReturnType<typeof buildTotpVerifySchema>>;

export function buildForgotPasswordSchema(t: TFunction) {
  return z.object({
    login: z.string().min(1, t('auth.validation.identifierRequired')),
  });
}
export type ForgotPasswordFormValues = z.infer<ReturnType<typeof buildForgotPasswordSchema>>;

function buildPasswordPairSchema(t: TFunction) {
  return z
    .object({
      password: buildPasswordSchema(t),
      confirmPassword: z.string().min(1, t('auth.validation.confirmRequired')),
    })
    .refine((value) => value.password === value.confirmPassword, {
      message: t('auth.validation.mismatch'),
      path: ['confirmPassword'],
    });
}

export function buildResetPasswordSchema(t: TFunction) {
  return buildPasswordPairSchema(t);
}
export type ResetPasswordFormValues = z.infer<ReturnType<typeof buildResetPasswordSchema>>;

export function buildInvitationAcceptSchema(t: TFunction) {
  return buildPasswordPairSchema(t);
}
export type InvitationAcceptFormValues = z.infer<ReturnType<typeof buildInvitationAcceptSchema>>;
