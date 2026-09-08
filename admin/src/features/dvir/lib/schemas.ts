/**
 * DVIR moduli zod sxemalari (fe-screens §2) — cheklovlar swagger'dan:
 * `DvirRepair.mechanic_note` ≤ 2000, `vendor` ≤ 200, `invoice_no` ≤ 64,
 * `cost` ≥ 0; `DefectTypeCreate.name` ≤ 120, `sort_order` 0…10000.
 *
 * Sxemalar `t` bilan quriladi — validatsiya matni ham i18n kalitidan keladi
 * (W6: kodda hardcode string yo'q).
 */
import type { TFunction } from 'i18next';
import { z } from 'zod';

export function buildDvirRepairSchema(t: TFunction) {
  return z.object({
    mechanic_note: z
      .string()
      .trim()
      .min(1, t('dvir.validation.mechanicNoteRequired'))
      .max(2000, t('dvir.validation.mechanicNoteMax')),
    vendor: z.string().trim().max(200, t('dvir.validation.vendorMax')),
    invoice_no: z.string().trim().max(64, t('dvir.validation.invoiceNoMax')),
    cost: z.string().trim(),
    // Kalit `FileUpload` (presign) natijasidan `setValue` bilan to'ldiriladi;
    // swagger'da `mechanic_signature_key` — **majburiy** maydon.
    mechanic_signature_key: z.string().min(1, t('dvir.validation.signatureRequired')),
  });
}

export type DvirRepairFormValues = z.infer<ReturnType<typeof buildDvirRepairSchema>>;

export const dvirRepairDefaultValues: DvirRepairFormValues = {
  mechanic_note: '',
  vendor: '',
  invoice_no: '',
  cost: '',
  mechanic_signature_key: '',
};

export function buildDefectTypeSchema(t: TFunction) {
  return z.object({
    name: z
      .string()
      .trim()
      .min(1, t('dvir.validation.nameRequired'))
      .max(120, t('dvir.validation.nameMax')),
    category: z.enum(['truck', 'trailer']),
    is_critical: z.boolean(),
    is_active: z.boolean(),
    // `<input type="number">` matn qaytaradi — qiymat forma ichida satr
    // bo'lib qoladi va yuborishdan oldin songa aylantiriladi (tip xavfsiz).
    sort_order: z.string().refine((value) => {
      if (value.trim() === '') return true;
      const parsed = Number(value);
      return Number.isInteger(parsed) && parsed >= 0 && parsed <= 10000;
    }, t('dvir.validation.sortOrderRange')),
  });
}

export type DefectTypeFormValues = z.infer<ReturnType<typeof buildDefectTypeSchema>>;

export const defectTypeDefaultValues: DefectTypeFormValues = {
  name: '',
  category: 'truck',
  is_critical: false,
  is_active: true,
  sort_order: '0',
};
