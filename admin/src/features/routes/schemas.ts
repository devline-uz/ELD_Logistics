/**
 * Route Add/Edit forma sxemasi — §7.7.3, `RouteCreate`/`RouteUpdate` bilan
 * mos (`WaypointInput.text` majburiy, `lat`/`lng` ixtiyoriy — MVP'da
 * xaritadan nuqta tanlash yo'q, faqat manzil matni, D-Q1 kabi ochiq band
 * sifatida hisobotda qayd etilgan).
 */
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

export const routeFormSchema = z.object({
  unit_id: z.string().min(1, 'Select a unit.'),
  driver_id: z.string().min(1, 'Select a driver.'),
  origin_text: z.string().trim().min(1, 'Enter the origin address.').max(255),
  destination_text: z.string().trim().min(1, 'Enter the destination address.').max(255),
  geofence_m: z.number().min(50).max(20_000).optional(),
  sequence: z.number().min(1).max(9999).optional(),
  note: z.string().trim().max(1000).optional().or(z.literal('')),
});

export type RouteFormValues = z.infer<typeof routeFormSchema>;

export const routeFormDefaultValues: RouteFormValues = {
  unit_id: '',
  driver_id: '',
  origin_text: '',
  destination_text: '',
  geofence_m: 300,
  sequence: undefined,
  note: '',
};

export const notCompletedSchema = z
  .object({
    reason: z.enum(NOT_COMPLETED_REASONS),
    note: z.string().trim().max(1000).optional().or(z.literal('')),
  })
  .refine((value) => value.reason !== 'other' || Boolean(value.note?.trim()), {
    message: 'A note is required when the reason is "Other".',
    path: ['note'],
  });

export type NotCompletedFormValues = z.infer<typeof notCompletedSchema>;

export const notCompletedDefaultValues: NotCompletedFormValues = {
  reason: 'breakdown',
  note: '',
};
