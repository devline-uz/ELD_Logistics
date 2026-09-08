/**
 * Settings › Branches forma sxemasi (8.3, §7.13.2). Cheklovlar swagger
 * `company_dto.BranchCreate`/`BranchUpdate` dan: `name` 2–160 (majburiy),
 * `address` ≤ 512, `timezone` ≤ 64.
 */
import type { TFunction } from 'i18next';
import { z } from 'zod';

export function buildBranchSchema(t: TFunction) {
  return z.object({
    name: z
      .string()
      .trim()
      .min(2, t('settings.branches.validation.nameMin'))
      .max(160, t('settings.branches.validation.nameMax')),
    address: z.string().trim().max(512, t('settings.branches.validation.addressMax')),
    timezone: z.string().trim(),
  });
}

export type BranchFormValues = z.infer<ReturnType<typeof buildBranchSchema>>;

export const branchDefaultValues: BranchFormValues = { name: '', address: '', timezone: '' };
