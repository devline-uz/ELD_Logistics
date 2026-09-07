/**
 * Role — Add/Edit forma sxemasi (2.9, TZ 7.3.10, F90/F91).
 *
 * `scope` faqat `company | branch` bo'lishi mumkin (`self` — faqat tizim
 * Driver roli, UI'da tanlanmaydi, F91). `permissions[]` — `GET /permissions`
 * ro'yxatidan tashqari qiymat yubormaydi (F94, UI cheklovi; backend ham
 * `FilterKnown` bilan tashlaydi).
 */
import { z } from 'zod';

const REQUIRED = { message: 'This field is required.' };

export const roleFormSchema = z.object({
  name: z.string().trim().min(1, REQUIRED).max(80),
  description: z.string().trim().max(200).optional().or(z.literal('')),
  scope: z.enum(['company', 'branch'], { message: 'Select a scope.' }),
  permissions: z.array(z.string()).min(1, { message: 'Select at least one permission.' }),
});

export type RoleFormValues = z.infer<typeof roleFormSchema>;
