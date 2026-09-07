/**
 * Unit Add/Edit forma sxemasi (2.2, `docs/tz/07-3-fleet.md` §7.3.2).
 *
 * Majburiylik `tz.md` §18.1 bo'yicha (F82, §16): **Unit #, Make, Model,
 * License Plate, Fuel Type** majburiy; `ELD`, `VIN`, `Year`, `Plate Issue
 * Region`, `Branch`, `GVWR class`, `Notes` — ixtiyoriy. Dizayndagi `ELD *` /
 * `Fuel Type*` (ikkalasi ham majburiy edi) ustidan TZ ustun keladi.
 *
 * Zod — birinchi qatlam (fe-screens §2); server `VALIDATION_ERROR.details[]`
 * ikkinchi qatlam (`applyServerErrors`, forma komponentida).
 */
import { z } from 'zod';

/** Backend enum — `fleet.dto.UnitCreate.fuel_type` (swagger). */
export const FUEL_TYPES = ['diesel', 'petrol', 'cng', 'lpg', 'electric', 'hybrid'] as const;
export type FuelType = (typeof FUEL_TYPES)[number];

const MIN_YEAR = 1950;
const MAX_YEAR_OFFSET = 1;
const NOTES_MAX_LENGTH = 60;
const VIN_LENGTH = 17;

function currentMaxYear(): number {
  return new Date().getFullYear() + MAX_YEAR_OFFSET;
}

export const unitFormSchema = z.object({
  unit_number: z.string().trim().min(1, 'Unit # is required.').max(32),
  make: z.string().trim().min(1, 'Make is required.').max(64),
  model: z.string().trim().min(1, 'Model is required.').max(64),
  license_plate: z.string().trim().min(1, 'License plate is required.').max(32),
  plate_region: z.string().trim().max(32).optional(),
  fuel_type: z.enum(FUEL_TYPES, { message: 'Fuel type is required.' }),
  year: z
    .number()
    .int()
    .min(MIN_YEAR, `Year must be ${MIN_YEAR} or later.`)
    .max(currentMaxYear(), `Year cannot be later than ${currentMaxYear()}.`)
    .optional()
    .or(z.literal(undefined)),
  eld_device_id: z.string().optional(),
  vin: z
    .string()
    .trim()
    .optional()
    .refine((value) => !value || value.length === VIN_LENGTH, {
      message: `VIN must be ${VIN_LENGTH} characters.`,
    }),
  branch_id: z.string().optional(),
  gvwr_class: z.string().trim().max(32).optional(),
  sleeper_not_available: z.boolean(),
  notes: z
    .string()
    .trim()
    .max(NOTES_MAX_LENGTH, `Notes must be ${NOTES_MAX_LENGTH} characters or fewer.`)
    .optional(),
});

export type UnitFormValues = z.infer<typeof unitFormSchema>;

export const unitFormDefaultValues: UnitFormValues = {
  unit_number: '',
  make: '',
  model: '',
  license_plate: '',
  plate_region: '',
  fuel_type: 'diesel',
  year: undefined,
  eld_device_id: '',
  vin: '',
  branch_id: '',
  gvwr_class: '',
  sleeper_not_available: false,
  notes: '',
};

export const unitAssignDriverSchema = z.object({
  driver_id: z.string().min(1, 'Select a driver.'),
  role: z.enum(['primary', 'co']),
});
export type UnitAssignDriverFormValues = z.infer<typeof unitAssignDriverSchema>;
