/**
 * Route Add/Edit forma sxemasi — §7.7.3, `RouteCreate`/`RouteUpdate` bilan
 * mos (`WaypointInput.text` majburiy, `lat`/`lng` ixtiyoriy — MVP'da
 * xaritadan nuqta tanlash yo'q, faqat manzil matni, D-Q1 kabi ochiq band
 * sifatida hisobotda qayd etilgan).
 *
 * Sxemalar `t` bilan quriladi — validatsiya matni ham i18n kalitidan keladi
 * (W6: kodda hardcode string yo'q, `dvir/lib/schemas.ts` bilan bir xil naqsh).
 */
import type { TFunction } from 'i18next';
import { z } from 'zod';

export const NOT_COMPLETED_REASONS = [
  'breakdown',
  'cancelled',
  'load_rejected',
  'road_closed',
  'driver_change',
  'other',
] as const;

export type NotCompletedReason = (typeof NOT_COMPLETED_REASONS)[number];

export function buildRouteFormSchema(t: TFunction) {
  return z.object({
    unit_id: z.string().min(1, t('routes.form.errors.unitRequired')),
    driver_id: z.string().min(1, t('routes.form.errors.driverRequired')),
    origin_text: z.string().trim().min(1, t('routes.form.errors.originRequired')).max(255),
    destination_text: z
      .string()
      .trim()
      .min(1, t('routes.form.errors.destinationRequired'))
      .max(255),
    geofence_m: z
      .number()
      .min(50, t('routes.form.errors.geofenceRange'))
      .max(20_000, t('routes.form.errors.geofenceRange'))
      .optional(),
    sequence: z.number().min(1).max(9999).optional(),
    note: z.string().trim().max(1000).optional().or(z.literal('')),
  });
}

export type RouteFormValues = z.infer<ReturnType<typeof buildRouteFormSchema>>;

export const routeFormDefaultValues: RouteFormValues = {
  unit_id: '',
  driver_id: '',
  origin_text: '',
  destination_text: '',
  geofence_m: 300,
  sequence: undefined,
  note: '',
};

export function buildNotCompletedSchema(t: TFunction) {
  return z
    .object({
      reason: z.enum(NOT_COMPLETED_REASONS),
      note: z.string().trim().max(1000).optional().or(z.literal('')),
    })
    .refine((value) => value.reason !== 'other' || Boolean(value.note?.trim()), {
      message: t('routes.notCompleted.noteRequired'),
      path: ['note'],
    });
}

export type NotCompletedFormValues = z.infer<ReturnType<typeof buildNotCompletedSchema>>;

export const notCompletedDefaultValues: NotCompletedFormValues = {
  reason: 'breakdown',
  note: '',
};
