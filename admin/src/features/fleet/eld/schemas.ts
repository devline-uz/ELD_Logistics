/**
 * ELD Device Add/Edit forma sxemasi (2.6, `docs/tz/07-3-fleet.md` §7.3.6, 🎨).
 * Dizayn yo'q — standart ro'yxat/forma patterni (fe-screens §6).
 */
import { z } from 'zod';

export const CONNECTION_TYPES = ['bluetooth', 'wifi', 'cellular', 'usb'] as const;
export const DEVICE_STATUSES = ['active', 'inactive', 'malfunction'] as const;

export const eldDeviceFormSchema = z.object({
  serial: z.string().trim().min(1, 'Serial is required.').max(64),
  vendor: z.string().trim().min(1, 'Vendor is required.').max(64),
  model: z.string().trim().max(64).optional(),
  firmware: z.string().trim().max(32).optional(),
  connection_type: z.enum(CONNECTION_TYPES).optional(),
  status: z.enum(DEVICE_STATUSES).optional(),
  sim_present: z.boolean(),
  notes: z.string().trim().max(60, 'Notes must be 60 characters or fewer.').optional(),
});

export type EldDeviceFormValues = z.infer<typeof eldDeviceFormSchema>;

export const eldDeviceFormDefaultValues: EldDeviceFormValues = {
  serial: '',
  vendor: '',
  model: '',
  firmware: '',
  connection_type: undefined,
  status: 'active',
  sim_present: false,
  notes: '',
};

export const eldDeviceAssignUnitSchema = z.object({
  unit_id: z.string().optional(),
});
export type EldDeviceAssignUnitFormValues = z.infer<typeof eldDeviceAssignUnitSchema>;
