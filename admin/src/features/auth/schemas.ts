/**
 * Auth forma sxemalari (0.11).
 *
 * Zod — birinchi qatlam validatsiya (fe-screens §2). Ikkinchi qatlam —
 * server javobi (`VALIDATION_ERROR.details[]`), `lib/errors.ts` orqali
 * maydonlarga bog'lanadi (`onError` har sahifada).
 *
 * Parol qoidasi (TZ §18.3): kamida 10 belgi, kamida bitta harf **va** bitta
 * raqam.
 */
import { z } from 'zod';

const PASSWORD_MIN_LENGTH = 10;

export const passwordSchema = z
  .string()
  .min(PASSWORD_MIN_LENGTH, { message: 'Must be at least 10 characters.' })
  .refine((value) => /[A-Za-z]/.test(value), { message: 'Must include at least one letter.' })
  .refine((value) => /\d/.test(value), { message: 'Must include at least one number.' });

export const loginSchema = z.object({
  identifier: z.string().min(1, { message: 'Enter your email or username.' }),
  password: z.string().min(1, { message: 'Enter your password.' }),
  remember: z.boolean(),
});
export type LoginFormValues = z.infer<typeof loginSchema>;

export const totpVerifySchema = z.object({
  code: z
    .string()
    .trim()
    .regex(/^\d{6}$/, { message: 'Enter the 6-digit code from your authenticator app.' }),
});
export type TotpVerifyFormValues = z.infer<typeof totpVerifySchema>;

export const forgotPasswordSchema = z.object({
  login: z.string().min(1, { message: 'Enter your email or username.' }),
});
export type ForgotPasswordFormValues = z.infer<typeof forgotPasswordSchema>;

export const resetPasswordSchema = z
  .object({
    password: passwordSchema,
    confirmPassword: z.string().min(1, { message: 'Confirm your new password.' }),
  })
  .refine((value) => value.password === value.confirmPassword, {
    message: 'Passwords do not match.',
    path: ['confirmPassword'],
  });
export type ResetPasswordFormValues = z.infer<typeof resetPasswordSchema>;

export const invitationAcceptSchema = z
  .object({
    password: passwordSchema,
    confirmPassword: z.string().min(1, { message: 'Confirm your new password.' }),
  })
  .refine((value) => value.password === value.confirmPassword, {
    message: 'Passwords do not match.',
    path: ['confirmPassword'],
  });
export type InvitationAcceptFormValues = z.infer<typeof invitationAcceptSchema>;
