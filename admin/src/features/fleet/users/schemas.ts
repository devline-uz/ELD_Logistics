/**
 * User (admin panel foydalanuvchisi) — Invite/Edit forma sxemasi (2.8, TZ
 * 7.3.9). D2 [MUST]: `Password` maydoni yo'q — faqat invitation/`Send
 * password reset`.
 */
import { z } from 'zod';

import { EMAIL_OR_PHONE_ISSUE, hasEmailOrPhone, REQUIRED, usernameField } from '@/lib/validation';

const baseUserFields = {
  first_name: z.string().trim().min(1, REQUIRED).max(60),
  last_name: z.string().trim().min(1, REQUIRED).max(60),
  email: z
    .string()
    .trim()
    .email({ message: 'Enter a valid email address.' })
    .optional()
    .or(z.literal('')),
  phone: z.string().trim().max(32).optional().or(z.literal('')),
  role_id: z.string().min(1, { message: 'Select a role.' }),
  branch_id: z.string().optional().or(z.literal('')),
};

/** Invite — `username` majburiy (`UserCreate.username: string`). */
export const userCreateSchema = z
  .object({
    ...baseUserFields,
    username: usernameField(true),
  })
  .refine(hasEmailOrPhone, EMAIL_OR_PHONE_ISSUE);

/** Edit — `username` ixtiyoriy o'zgartirish (`UserUpdate.username?: string`). */
export const userUpdateSchema = z
  .object({
    ...baseUserFields,
    username: usernameField(false),
  })
  .refine(hasEmailOrPhone, EMAIL_OR_PHONE_ISSUE);

export type UserCreateFormValues = z.infer<typeof userCreateSchema>;
export type UserUpdateFormValues = z.infer<typeof userUpdateSchema>;
