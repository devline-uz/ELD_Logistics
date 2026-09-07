/**
 * Fleet modullari (drivers/users/trailers/documents) orasida takrorlangan
 * zod naqshlari — bosqich 2 ko'rigi (dublikat topilmasi). `screens` bo'yicha
 * majburiylik qoidalari `fe-screens` §2 / TZ §18.3 da.
 */
import { z } from 'zod';

/** `username`: 4-32, kichik lotin harf/raqam/`.`/`_` (TZ §18.3). */
export const USERNAME_RE = /^[a-z0-9._]{4,32}$/;
export const USERNAME_MESSAGE =
  'Username must be 4-32 characters: lowercase letters, digits, "." or "_".';

export const REQUIRED = { message: 'This field is required.' };

/**
 * Majburiy yoki ixtiyoriy `username` maydoni (Driver/User Add vs Edit).
 * Ikki overload — `required` literal `true`/`false` bilan chaqirilganda
 * to'g'ri (majburiy/ixtiyoriy) qaytish tipi aniqlansin.
 */
export function usernameField(required: true): z.ZodString;
export function usernameField(
  required: false,
): z.ZodUnion<[z.ZodOptional<z.ZodString>, z.ZodLiteral<''>]>;
export function usernameField(required: boolean) {
  const base = z.string().trim().regex(USERNAME_RE, { message: USERNAME_MESSAGE });
  return required ? base : base.optional().or(z.literal(''));
}

/** `Notes` — barcha fleet formalarida ≤ 60 belgi, ixtiyoriy. */
export const notesField = z
  .string()
  .trim()
  .max(60, { message: 'Notes must be 60 characters or fewer.' })
  .optional()
  .or(z.literal(''));

/**
 * Email yoki telefon kamida bittasi to'ldirilgan bo'lishi kerak (Driver
 * Add/Edit — F86, User Invite/Edit — §7.3.9). `.refine()` predikati sifatida
 * ishlatiladi, xato `email` maydoniga bog'lanadi.
 */
export function hasEmailOrPhone(value: { email?: string; phone?: string }): boolean {
  return Boolean(value.email) || Boolean(value.phone);
}

export const EMAIL_OR_PHONE_ISSUE = {
  message: 'Enter an email or a phone number.',
  path: ['email'] as [string],
};

/**
 * `Trailers`/`Shipping Documents` — sodda katalog forma sxemasi (🎨,
 * `docs/tz/07-3-fleet.md` §7.3.7/§7.3.8): `number` (majburiy) + `notes`
 * (≤ 60). Ikkala modul bayt-baytga bir xil sxemani saqlagan edi.
 */
export const catalogFormSchema = z.object({
  number: z.string().trim().min(1, 'Number is required.').max(32),
  notes: notesField,
});

export type CatalogFormValues = z.infer<typeof catalogFormSchema>;

export const catalogFormDefaultValues: CatalogFormValues = {
  number: '',
  notes: '',
};
