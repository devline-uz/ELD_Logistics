/**
 * Super Admin — Company Add/Edit modali (9.15, §7.14). `POST /companies` /
 * `PATCH /companies/{id}`. Nom to'qnashuvida `409 UNIQUE_VIOLATION` —
 * `adminCompanyErrorMessageKey` orqali umumiy alert'ga chiqadi (backend
 * `details[]` bermaydi — maydonga bog'lanmaydi).
 *
 * Administrator taklifi (email/first_name/last_name) faqat yaratishda
 * ko'rinadi — `PATCH /companies/{id}` bunday maydonlarni qabul qilmaydi.
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import type { AdminCompany, AdminCompanyCreate, AdminCompanyUpdate } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormInput } from '@/components/form/FormInput';
import { FormSelect } from '@/components/form/FormSelect';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import { useResetFormOnOpen } from '@/hooks/useResetFormOnOpen';

import { adminCompanyErrorMessageKey } from '../lib/errors';
import {
  buildCompanySchema,
  buildCreateCompanySchema,
  companyFormDefaultValues,
  REGION_VALUES,
  REGULATION_PROFILE_VALUES,
  UNIT_SYSTEM_VALUES,
  type CompanyFormValues,
} from '../lib/schemas';

export interface CompanyFormModalProps {
  open: boolean;
  onClose: () => void;
  /** Tahrirlanayotgan kompaniya; `undefined` — yaratish rejimi. */
  company?: AdminCompany;
  onCreate: (body: AdminCompanyCreate) => Promise<unknown>;
  onUpdate: (id: string, body: AdminCompanyUpdate) => Promise<unknown>;
  isPending: boolean;
  onSuccess: (isEdit: boolean, name: string) => void;
}

function toFormValues(company: AdminCompany): CompanyFormValues {
  return {
    ...companyFormDefaultValues,
    name: company.name ?? '',
    region: (company.region as CompanyFormValues['region']) ?? 'US',
    regulation_profile:
      (company.regulation_profile as CompanyFormValues['regulation_profile']) ?? 'us_fmcsa',
    unit_system: (company.unit_system as CompanyFormValues['unit_system']) ?? 'imperial',
    timezone: company.timezone ?? '',
    address: company.address ?? '',
    home_terminal_address: company.home_terminal_address ?? '',
    email: company.email ?? '',
    phone: company.phone ?? '',
    registration_no: company.registration_no ?? '',
    plan: company.plan ?? '',
  };
}

function toCreateBody(values: CompanyFormValues): AdminCompanyCreate {
  return {
    name: values.name.trim(),
    region: values.region,
    regulation_profile: values.regulation_profile,
    unit_system: values.unit_system,
    timezone: values.timezone.trim(),
    ...(values.address.trim() ? { address: values.address.trim() } : {}),
    ...(values.home_terminal_address.trim()
      ? { home_terminal_address: values.home_terminal_address.trim() }
      : {}),
    ...(values.email.trim() ? { email: values.email.trim() } : {}),
    ...(values.phone.trim() ? { phone: values.phone.trim() } : {}),
    ...(values.registration_no.trim() ? { registration_no: values.registration_no.trim() } : {}),
    ...(values.plan.trim() ? { plan: values.plan.trim() } : {}),
    administrator: {
      email: values.administrator_email.trim(),
      first_name: values.administrator_first_name.trim(),
      last_name: values.administrator_last_name.trim(),
    },
  };
}

function toUpdateBody(values: CompanyFormValues): AdminCompanyUpdate {
  return {
    name: values.name.trim(),
    region: values.region,
    regulation_profile: values.regulation_profile,
    unit_system: values.unit_system,
    timezone: values.timezone.trim(),
    address: values.address.trim(),
    home_terminal_address: values.home_terminal_address.trim(),
    email: values.email.trim(),
    phone: values.phone.trim(),
    registration_no: values.registration_no.trim(),
    plan: values.plan.trim(),
  };
}

export function CompanyFormModal({
  open,
  onClose,
  company,
  onCreate,
  onUpdate,
  isPending,
  onSuccess,
}: CompanyFormModalProps) {
  const { t } = useTranslation();
  const isEdit = Boolean(company);
  const schema = useMemo(
    () => (isEdit ? buildCompanySchema(t) : buildCreateCompanySchema(t)),
    [t, isEdit],
  );
  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);

  const form = useForm<CompanyFormValues>({
    resolver: zodResolver(schema),
    defaultValues: company ? toFormValues(company) : companyFormDefaultValues,
    mode: 'onBlur',
  });

  useResetFormOnOpen(
    form,
    open,
    () => (company ? toFormValues(company) : companyFormDefaultValues),
    [company],
    () => setFormMessage(undefined),
  );

  const submit = form.handleSubmit(async (values) => {
    setFormMessage(undefined);
    try {
      if (isEdit && company?.id) {
        await onUpdate(company.id, toUpdateBody(values));
      } else {
        await onCreate(toCreateBody(values));
      }
      onSuccess(isEdit, values.name.trim());
      onClose();
    } catch (error) {
      const result = applyServerErrors(form, error);
      const moduleKey = adminCompanyErrorMessageKey(error);
      setFormMessage(
        moduleKey
          ? t(moduleKey)
          : (result.formMessage ?? t('superadmin.companies.toast.saveFailed')),
      );
    }
  });

  return (
    <Modal
      open={open}
      onClose={onClose}
      size="lg"
      title={
        isEdit ? t('superadmin.companies.form.editTitle') : t('superadmin.companies.form.addTitle')
      }
      closeOnBackdrop={!form.formState.isDirty}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={isPending}>
            {t('common.actions.cancel')}
          </Button>
          <Button onClick={() => void submit()} loading={isPending}>
            {isEdit ? t('common.actions.saveChanges') : t('common.actions.create')}
          </Button>
        </>
      }
    >
      <form className="flex flex-col gap-4" onSubmit={(event) => event.preventDefault()}>
        {formMessage ? <Alert variant="error" message={formMessage} /> : null}

        <FormInput
          name="name"
          control={form.control}
          label={t('superadmin.companies.form.name')}
          required
          maxLength={160}
        />

        <div className="grid grid-cols-3 gap-4">
          <FormSelect
            name="region"
            control={form.control}
            label={t('superadmin.companies.form.region')}
            required
            options={REGION_VALUES.map((value) => ({
              value,
              label: t(`superadmin.companies.region.${value}`),
            }))}
          />
          <FormSelect
            name="unit_system"
            control={form.control}
            label={t('superadmin.companies.form.unitSystem')}
            required
            options={UNIT_SYSTEM_VALUES.map((value) => ({
              value,
              label: t(`superadmin.companies.unitSystem.${value}`),
            }))}
          />
          <FormSelect
            name="regulation_profile"
            control={form.control}
            label={t('superadmin.companies.form.regulationProfile')}
            required
            options={REGULATION_PROFILE_VALUES.map((value) => ({
              value,
              label: t(`superadmin.companies.regulationProfile.${value}`),
            }))}
          />
        </div>

        <FormInput
          name="timezone"
          control={form.control}
          label={t('superadmin.companies.form.timezone')}
          required
          placeholder={t('superadmin.companies.form.timezonePlaceholder')}
          maxLength={64}
        />

        <div className="grid grid-cols-2 gap-4">
          <FormInput
            name="address"
            control={form.control}
            label={t('superadmin.companies.form.address')}
            maxLength={512}
          />
          <FormInput
            name="home_terminal_address"
            control={form.control}
            label={t('superadmin.companies.form.homeTerminalAddress')}
            maxLength={512}
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <FormInput
            name="email"
            control={form.control}
            type="email"
            label={t('superadmin.companies.form.email')}
            maxLength={254}
          />
          <FormInput
            name="phone"
            control={form.control}
            label={t('superadmin.companies.form.phone')}
            maxLength={32}
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <FormInput
            name="registration_no"
            control={form.control}
            label={t('superadmin.companies.form.registrationNo')}
            maxLength={64}
          />
          <FormInput
            name="plan"
            control={form.control}
            label={t('superadmin.companies.form.plan')}
            maxLength={64}
          />
        </div>

        {isEdit ? null : (
          <fieldset className="flex flex-col gap-4 rounded-lg border border-[var(--color-stroke)] p-4">
            <legend className="px-1 text-sm font-medium text-neutral-700">
              {t('superadmin.companies.form.administratorSection')}
            </legend>
            <p className="text-xs text-neutral-500">
              {t('superadmin.companies.form.administratorHint')}
            </p>
            <div className="grid grid-cols-2 gap-4">
              <FormInput
                name="administrator_first_name"
                control={form.control}
                label={t('superadmin.companies.form.administratorFirstName')}
                required
                maxLength={80}
              />
              <FormInput
                name="administrator_last_name"
                control={form.control}
                label={t('superadmin.companies.form.administratorLastName')}
                required
                maxLength={80}
              />
            </div>
            <FormInput
              name="administrator_email"
              control={form.control}
              type="email"
              label={t('superadmin.companies.form.administratorEmail')}
              required
              maxLength={254}
            />
          </fieldset>
        )}
      </form>
    </Modal>
  );
}

export default CompanyFormModal;
