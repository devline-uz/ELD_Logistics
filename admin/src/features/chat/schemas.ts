/**
 * Chat kompozitor validatsiyasi (fe-screens §2, TZ §15.4).
 *
 * Matn ≤ 2000 belgi. `Textarea`ning `maxLength` atributi kiritishning o'zini
 * cheklaydi — bu sxema himoya qatlami sifatida (masalan qo'yib yuborilgan
 * joylashtirilgan matn) va kelajakdagi server xatosini bog'lash uchun.
 */
import { z } from 'zod';

export const CHAT_MESSAGE_MAX_LENGTH = 2000;

export const chatMessageTextSchema = z
  .string()
  .trim()
  .max(CHAT_MESSAGE_MAX_LENGTH, { message: 'chat.composer.errors.tooLong' });

export function isChatMessageTextValid(value: string): boolean {
  return chatMessageTextSchema.safeParse(value).success;
}
