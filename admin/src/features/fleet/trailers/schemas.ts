/**
 * Trailer Add/Edit forma sxemasi (2.7, `docs/tz/07-3-fleet.md` §7.3.7, 🎨).
 * Sodda CRUD — `number` (majburiy) + `notes` (≤ 60).
 */
import { z } from 'zod';

export const catalogFormSchema = z.object({
  number: z.string().trim().min(1, 'Number is required.').max(32),
  notes: z.string().trim().max(60, 'Notes must be 60 characters or fewer.').optional(),
});

export type CatalogFormValues = z.infer<typeof catalogFormSchema>;

export const catalogFormDefaultValues: CatalogFormValues = {
  number: '',
  notes: '',
};
