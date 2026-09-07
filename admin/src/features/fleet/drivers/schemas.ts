/**
 * Driver — Add/Edit forma sxemasi (2.4/2.5, fe-screens §2, TZ 7.3.5 F86/F87).
 *
 * D2 [MUST]: `Password` maydoni **yo'q** — admin panel hech qachon parol
 * o'rnatmaydi (faqat invitation/`Send password reset`). Shu sabab bu faylda
 * `z.string()` bilan parol maydoni butunlay mavjud emas — CI testi
 * (`no-password-field.test.ts`) buni majburlaydi.
 *
 * Username/License qoidalari — `fe-screens` §2 (TZ §18.3): `username`
 * 4–32, `[a-z0-9._]`; `Notes` ≤ 60.
 */
import { z } from 'zod';

const USERNAME_RE = /^[a-z0-9._]{4,32}$/;
const REQUIRED = { message: 'This field is required.' };
const EMAIL_OR_PHONE = { message: 'Enter an email or a phone number.' };

/** Har ikkala forma (Add/Edit) uchun umumiy maydonlar. */
const baseDriverFields = {
  first_name: z.string().trim().min(1, REQUIRED).max(60),
  last_name: z.string().trim().min(1, REQUIRED).max(60),
  email: z
    .string()
    .trim()
    .email({ message: 'Enter a valid email address.' })
    .optional()
    .or(z.literal('')),
  phone: z.string().trim().max(32).optional().or(z.literal('')),
  license_region: z.string().trim().max(16).optional().or(z.literal('')),
  default_unit_id: z.string().optional().or(z.literal('')),
  fleet_manager_id: z.string().optional().or(z.literal('')),
  branch_id: z.string().optional().or(z.literal('')),
  home_terminal: z.string().trim().max(120).optional().or(z.literal('')),
  city: z.string().trim().max(80).optional().or(z.literal('')),
  state: z.string().trim().max(32).optional().or(z.literal('')),
  zip: z.string().trim().max(16).optional().or(z.literal('')),
  address1: z.string().trim().max(120).optional().or(z.literal('')),
  address2: z.string().trim().max(120).optional().or(z.literal('')),
  notes: z
    .string()
    .trim()
    .max(60, { message: 'Notes must be 60 characters or fewer.' })
    .optional()
    .or(z.literal('')),
};

/** Add — `username`/`license_no` majburiy, kiritilgach o'zgarmas (F86/F87). */
export const driverCreateSchema = z
  .object({
    ...baseDriverFields,
    username: z.string().trim().regex(USERNAME_RE, {
      message: 'Username must be 4-32 characters: lowercase letters, digits, "." or "_".',
    }),
    license_no: z.string().trim().min(1, REQUIRED).max(40),
  })
  .refine((value) => Boolean(value.email) || Boolean(value.phone), {
    ...EMAIL_OR_PHONE,
    path: ['email'],
  });

/** Edit — `username` PATCH'da yuborilmaydi (backend `UserUpdate` da yo'q). */
export const driverUpdateSchema = z
  .object({
    ...baseDriverFields,
    license_no: z.string().trim().min(1, REQUIRED).max(40).optional().or(z.literal('')),
  })
  .refine((value) => Boolean(value.email) || Boolean(value.phone), {
    ...EMAIL_OR_PHONE,
    path: ['email'],
  });

export type DriverCreateFormValues = z.infer<typeof driverCreateSchema>;
export type DriverUpdateFormValues = z.infer<typeof driverUpdateSchema>;
