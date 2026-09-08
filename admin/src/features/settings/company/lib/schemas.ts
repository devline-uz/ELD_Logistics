/**
 * Settings › Company forma sxemasi (8.2, `docs/tz/07-13-settings-admin.md`
 * §7.13.1). Cheklovlar swagger `company_dto.CompanyUpdate` dan: `name`
 * 2–160, `address`/`home_terminal_address` ≤ 512, `email` ≤ 254, `phone`
 * ≤ 32, `registration_no` ≤ 64, `timezone` ≤ 64.
 */
import type { TFunction } from 'i18next';
import { z } from 'zod';

export const REGION_VALUES = ['PK', 'UZ', 'US', 'other'] as const;
export const UNIT_SYSTEM_VALUES = ['metric', 'imperial'] as const;
export const REGULATION_PROFILE_VALUES = [
  'us_fmcsa',
  'generic',
  'canada',
  'texas',
  'california',
  'alaska',
  'hawaii',
] as const;
export const DISTANCE_REGIONS_SET_VALUES = [
  'us_states',
  'pk_provinces',
  'uz_regions',
  'none',
] as const;

export function buildCompanySchema(t: TFunction) {
  return z.object({
    name: z
      .string()
      .trim()
      .min(2, t('settings.company.validation.nameMin'))
      .max(160, t('settings.company.validation.nameMax')),
    address: z
      .string()
      .trim()
      .min(1, t('settings.company.validation.addressRequired'))
      .max(512, t('settings.company.validation.addressMax')),
    home_terminal_address: z
      .string()
      .trim()
      .min(1, t('settings.company.validation.homeTerminalRequired'))
      .max(512, t('settings.company.validation.homeTerminalMax')),
    timezone: z.string().trim().min(1, t('settings.company.validation.timezoneRequired')),
    email: z
      .string()
      .trim()
      .min(1, t('settings.company.validation.emailRequired'))
      .max(254, t('settings.company.validation.emailMax'))
      .email(t('settings.company.validation.emailInvalid')),
    phone: z
      .string()
      .trim()
      .min(1, t('settings.company.validation.phoneRequired'))
      .max(32, t('settings.company.validation.phoneMax')),
    registration_no: z.string().trim().max(64, t('settings.company.validation.registrationMax')),
    region: z.enum(REGION_VALUES),
    unit_system: z.enum(UNIT_SYSTEM_VALUES),
    regulation_profile: z.enum(REGULATION_PROFILE_VALUES),
    distance_regions_set: z.enum(DISTANCE_REGIONS_SET_VALUES),
    logo_key: z.string(),
  });
}

export type CompanyFormValues = z.infer<ReturnType<typeof buildCompanySchema>>;
