/**
 * Super Admin — Company Add/Edit va Subscription forma sxemalari (9.15,
 * §7.14). Cheklovlar swagger `companies_dto.CompanyCreate`/`CompanyUpdate`/
 * `SubscriptionUpdate`/`AdministratorInvite` dan.
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
export const SUBSCRIPTION_STATUS_VALUES = ['trial', 'active', 'grace', 'readonly'] as const;

export function buildCompanySchema(t: TFunction) {
  return z.object({
    name: z
      .string()
      .trim()
      .min(2, t('superadmin.companies.form.validation.nameMin'))
      .max(160, t('superadmin.companies.form.validation.nameMax')),
    region: z.enum(REGION_VALUES),
    regulation_profile: z.enum(REGULATION_PROFILE_VALUES),
    unit_system: z.enum(UNIT_SYSTEM_VALUES),
    timezone: z
      .string()
      .trim()
      .min(1, t('superadmin.companies.form.validation.timezoneRequired'))
      .max(64, t('superadmin.companies.form.validation.timezoneMax')),
    address: z.string().trim().max(512, t('superadmin.companies.form.validation.addressMax')),
    home_terminal_address: z
      .string()
      .trim()
      .max(512, t('superadmin.companies.form.validation.addressMax')),
    email: z
      .string()
      .trim()
      .max(254, t('superadmin.companies.form.validation.emailMax'))
      .refine((value) => value === '' || z.string().email().safeParse(value).success, {
        message: t('superadmin.companies.form.validation.emailInvalid'),
      }),
    phone: z.string().trim().max(32, t('superadmin.companies.form.validation.phoneMax')),
    registration_no: z
      .string()
      .trim()
      .max(64, t('superadmin.companies.form.validation.registrationMax')),
    plan: z.string().trim().max(64, t('superadmin.companies.form.validation.planMax')),
    // Faqat yaratishda: Administrator taklifi (72 soat, tashqi kanal orqali
    // yetkaziladi — token javobda qaytarilmaydi).
    administrator_first_name: z
      .string()
      .trim()
      .max(80, t('superadmin.companies.form.validation.nameMax')),
    administrator_last_name: z
      .string()
      .trim()
      .max(80, t('superadmin.companies.form.validation.nameMax')),
    administrator_email: z
      .string()
      .trim()
      .max(254, t('superadmin.companies.form.validation.emailMax')),
  });
}

export type CompanyFormValues = z.infer<ReturnType<typeof buildCompanySchema>>;

export const companyFormDefaultValues: CompanyFormValues = {
  name: '',
  region: 'US',
  regulation_profile: 'us_fmcsa',
  unit_system: 'imperial',
  timezone: '',
  address: '',
  home_terminal_address: '',
  email: '',
  phone: '',
  registration_no: '',
  plan: '',
  administrator_first_name: '',
  administrator_last_name: '',
  administrator_email: '',
};

/**
 * Yaratishda majburiy maydonlar zod darajasida emas — forma xatolari
 * `CompanyFormModal`da rejimga (create/edit) qarab qo'shiladi, chunki
 * Administrator maydonlari faqat yaratishda kerak (`isEdit` bo'lsa
 * ko'rinmaydi ham).
 */
export function buildCreateCompanySchema(t: TFunction) {
  return buildCompanySchema(t).extend({
    administrator_first_name: z
      .string()
      .trim()
      .min(1, t('superadmin.companies.form.validation.administratorFirstNameRequired'))
      .max(80, t('superadmin.companies.form.validation.nameMax')),
    administrator_last_name: z
      .string()
      .trim()
      .min(1, t('superadmin.companies.form.validation.administratorLastNameRequired'))
      .max(80, t('superadmin.companies.form.validation.nameMax')),
    administrator_email: z
      .string()
      .trim()
      .min(1, t('superadmin.companies.form.validation.administratorEmailRequired'))
      .max(254, t('superadmin.companies.form.validation.emailMax'))
      .email(t('superadmin.companies.form.validation.emailInvalid')),
  });
}

export function buildSubscriptionSchema(t: TFunction) {
  return z.object({
    subscription_status: z.enum(SUBSCRIPTION_STATUS_VALUES),
    plan: z.string().trim().max(64, t('superadmin.companies.form.validation.planMax')),
    subscription_end_at: z.date().nullable(),
    clear_end_at: z.boolean(),
  });
}

export type SubscriptionFormValues = z.infer<ReturnType<typeof buildSubscriptionSchema>>;

export const subscriptionFormDefaultValues: SubscriptionFormValues = {
  subscription_status: 'trial',
  plan: '',
  subscription_end_at: null,
  clear_end_at: false,
};
