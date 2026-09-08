/**
 * Inspection logs — "Email report" forma sxemasi (8.11, `docs/tz/
 * 07-9-chat-support-audit.md` §7.12). Cheklovlar swagger
 * `logs_dto.InspectionEmail` dan: `email` majburiy (≤ 255), `comment`
 * ixtiyoriy (≤ 500).
 */
import type { TFunction } from 'i18next';
import { z } from 'zod';

export function buildInspectionEmailSchema(t: TFunction) {
  return z.object({
    email: z
      .string()
      .trim()
      .min(1, t('inspection.emailModal.validation.emailRequired'))
      .max(255, t('inspection.emailModal.validation.emailMax'))
      .email(t('inspection.emailModal.validation.emailInvalid')),
    comment: z.string().trim().max(500, t('inspection.emailModal.validation.commentMax')),
  });
}

export type InspectionEmailFormValues = z.infer<ReturnType<typeof buildInspectionEmailSchema>>;

export const inspectionEmailDefaultValues: InspectionEmailFormValues = {
  email: '',
  comment: '',
};
