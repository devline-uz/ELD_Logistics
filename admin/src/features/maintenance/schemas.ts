/**
 * Maintenance formalari — zod sxemalari (5.7, 5.10; fe-screens §2).
 *
 * Maydon nomlari **API konverti bilan bir xil** (`name`, `interval_value`,
 * `alert_type`, …) — shunda `applyServerErrors` server
 * `VALIDATION_ERROR.details[].field` ni to'g'ridan-to'g'ri maydonga bog'laydi.
 * Faqat UI'ga xos maydonlar boshqacha nomlanadi (`mode`, `unit_ids`,
 * `interval_unit_choice`, `last_service_values`).
 *
 * Sonlar forma ichida **matn** sifatida saqlanadi (`Input` `string` qaytaradi);
 * songa aylantirish faqat yuborishdan oldin, bitta joyda bo'ladi.
 *
 * Xato matnlari — i18n kalitlaridan (W6), shuning uchun sxemalar `t` ni
 * qabul qiluvchi fabrikalar sifatida yozilgan (`create*Schema(t)`).
 */
import { z } from 'zod';

import { NOTES_MAX_LENGTH } from './constants';

/** `useTranslation().t` ning shu yerda kerak bo'lgan minimal shakli. */
export type Translate = (key: string) => string;

/** Bo'sh bo'lmagan, musbat (yoki `allowZero` bilan nomanfiy) son matni. */
function numericString(t: Translate, options: { allowZero?: boolean } = {}) {
  return z
    .string()
    .trim()
    .refine((value) => value.length > 0, {
      message: t('maintenance.form.errors.intervalRequired'),
    })
    .refine(
      (value) => {
        const parsed = Number(value);
        if (!Number.isFinite(parsed)) return false;
        return options.allowZero ? parsed >= 0 : parsed > 0;
      },
      { message: t('maintenance.form.errors.intervalPositive') },
    );
}

/** Ixtiyoriy nomanfiy son matni (`Last service value`). */
function optionalNonNegative(t: Translate) {
  return z
    .string()
    .trim()
    .refine(
      (value) => value.length === 0 || (Number.isFinite(Number(value)) && Number(value) >= 0),
      { message: t('maintenance.form.errors.reminderNegative') },
    );
}

/** `Add / Edit` — `MAINTENANCE DETAILS` formasi (5.7). */
export function createMaintenanceScheduleSchema(t: Translate) {
  return z
    .object({
      type: z.string().trim().min(1, t('maintenance.form.errors.typeRequired')).max(64),
      mode: z.enum(['single', 'multiple']),
      unit_id: z.string().trim(),
      unit_ids: z.array(z.string().trim()),
      /** `unit_id → last service value` (matn); bo'sh bo'lsa backend telemetriyadan oladi. */
      last_service_values: z.record(z.string(), optionalNonNegative(t)),
      interval_value: numericString(t),
      interval_unit_choice: z.enum(['distance', 'days', 'engine_hours']),
      reminder_before_value: numericString(t, { allowZero: true }),
      name: z.string().trim().min(1, t('maintenance.form.errors.nameRequired')).max(160),
      alert_type: z.enum(['notification', 'email', 'sms', 'none']),
      delivery_methods: z
        .array(z.enum(['push', 'email', 'sms', 'in_app']))
        .min(1, t('maintenance.form.errors.deliveryRequired')),
      notify_co_driver: z.boolean(),
      notes: z.string().max(NOTES_MAX_LENGTH, t('maintenance.form.errors.notesMax')),
      status: z.enum(['active', 'inactive']),
    })
    .superRefine((values, ctx) => {
      if (values.mode === 'single' && values.unit_id.length === 0) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['unit_id'],
          message: t('maintenance.form.errors.unitRequired'),
        });
      }
      if (values.mode === 'multiple' && values.unit_ids.length === 0) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['unit_ids'],
          message: t('maintenance.form.errors.unitsRequired'),
        });
      }
    });
}

export type MaintenanceScheduleFormValues = z.infer<
  ReturnType<typeof createMaintenanceScheduleSchema>
>;

/** Bo'sh forma — `Add` uchun boshlang'ich qiymatlar. */
export const maintenanceScheduleFormDefaults: MaintenanceScheduleFormValues = {
  type: 'oil_change',
  mode: 'single',
  unit_id: '',
  unit_ids: [],
  last_service_values: {},
  interval_value: '',
  interval_unit_choice: 'distance',
  reminder_before_value: '0',
  name: '',
  alert_type: 'notification',
  delivery_methods: ['push'],
  notify_co_driver: false,
  notes: '',
  status: 'active',
};

/** `MARK MAINTENANCE AS COMPLETE` (5.10, F111 — invoice PDF/JPG/PNG ≤ 10 MB). */
export function createMaintenanceCompleteSchema(t: Translate) {
  return z.object({
    invoice_no: z.string().trim().max(64, t('maintenance.complete.errors.invoiceNoMax')),
    vendor: z.string().trim().max(200, t('maintenance.complete.errors.vendorMax')),
    cost: z
      .string()
      .trim()
      .refine(
        (value) => value.length === 0 || (Number.isFinite(Number(value)) && Number(value) >= 0),
        { message: t('maintenance.complete.errors.costNegative') },
      ),
    performed_at: z.date({ message: t('maintenance.complete.errors.dateRequired') }),
    /** `POST /files/presign` qaytargan kalit — fayl ixtiyoriy. */
    invoice_key: z.string(),
  });
}

export type MaintenanceCompleteFormValues = z.infer<
  ReturnType<typeof createMaintenanceCompleteSchema>
>;
