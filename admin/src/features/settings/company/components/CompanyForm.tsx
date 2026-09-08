/**
 * Settings › Company forma (8.2, §7.13.1).
 *
 * **F145 [MUST]**: `unit_system`/`regulation_profile` o'zgarganda saqlashdan
 * oldin tasdiq dialogi ko'rsatiladi — bu o'zgarish butun panel bo'ylab sana/
 * birlik formatlarini almashtiradi. Tasdiqdan keyin haqiqiy saqlash sodir
 * bo'ladi; sahifa (`CompanySettingsPage`) muvaffaqiyatli javobni company
 * store'ga yozib qayta formatlashni ishga tushiradi.
 *
 * Logo — mavjud presign oqimi (`FileUpload` + `presignFile`); bu komponent
 * faqat `logo_key`ni forma qiymatiga yozadi, yuklashning o'zi domen bilmaydi.
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import { presignFile } from '@/api/queries/files';
import type { Company } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FileUpload } from '@/components/form/FileUpload';
import { FormInput } from '@/components/form/FormInput';
import { FormSelect } from '@/components/form/FormSelect';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { useDateFormat } from '@/hooks/useDateFormat';
import { resolveStorageUrl } from '@/lib/storage';

import { TIMEZONE_OPTIONS } from '../lib/timezones';
import {
  buildCompanySchema,
  DISTANCE_REGIONS_SET_VALUES,
  REGION_VALUES,
  REGULATION_PROFILE_VALUES,
  UNIT_SYSTEM_VALUES,
  type CompanyFormValues,
} from '../lib/schemas';

export interface CompanyFormProps {
  company: Company;
  canEdit: boolean;
  isPending: boolean;
  onSubmit: (values: CompanyFormValues) => Promise<unknown>;
}

function toFormValues(company: Company): CompanyFormValues {
  return {
    name: company.name ?? '',
    address: company.address ?? '',
    home_terminal_address: company.home_terminal_address ?? '',
    timezone: company.timezone ?? '',
    email: company.email ?? '',
    phone: company.phone ?? '',
    registration_no: company.registration_no ?? '',
    region: (company.region as CompanyFormValues['region']) ?? 'US',
    unit_system: (company.unit_system as CompanyFormValues['unit_system']) ?? 'imperial',
    regulation_profile:
      (company.regulation_profile as CompanyFormValues['regulation_profile']) ?? 'generic',
    distance_regions_set:
      (company.settings?.distance_regions_set as CompanyFormValues['distance_regions_set']) ??
      'none',
    logo_key: company.logo_key ?? '',
  };
}

export function CompanyForm({ company, canEdit, isPending, onSubmit }: CompanyFormProps) {
  const { t } = useTranslation();
  const dateFormat = useDateFormat();
  const schema = useMemo(() => buildCompanySchema(t), [t]);
  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);
  const [pendingValues, setPendingValues] = useState<CompanyFormValues | undefined>(undefined);

  const form = useForm<CompanyFormValues>({
    resolver: zodResolver(schema),
    defaultValues: toFormValues(company),
    mode: 'onBlur',
  });

  const registrationLabel =
    form.watch('regulation_profile') === 'us_fmcsa'
      ? t('settings.company.fields.registrationNoUsDot')
      : t('settings.company.fields.registrationNo');

  const commit = async (values: CompanyFormValues) => {
    setFormMessage(undefined);
    try {
      await onSubmit(values);
      form.reset(values);
    } catch (error) {
      const result = applyServerErrors(form, error);
      setFormMessage(result.formMessage ?? t('settings.company.toast.failed'));
    }
  };

  const submit = form.handleSubmit((values) => {
    const original = toFormValues(company);
    const changesFormatting =
      values.unit_system !== original.unit_system ||
      values.regulation_profile !== original.regulation_profile;

    if (changesFormatting) {
      setPendingValues(values);
      return;
    }
    void commit(values);
  });

  return (
    <form
      className="flex flex-col gap-4"
      onSubmit={(event) => {
        event.preventDefault();
        void submit();
      }}
    >
      {formMessage ? <Alert variant="error" message={formMessage} /> : null}

      <Card title={t('settings.company.sections.profile')}>
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
          <FormInput
            name="name"
            control={form.control}
            label={t('settings.company.fields.name')}
            required
            disabled={!canEdit}
            maxLength={160}
          />
          <FormInput
            name="registration_no"
            control={form.control}
            label={registrationLabel}
            disabled={!canEdit}
            maxLength={64}
          />
          <FormInput
            name="email"
            control={form.control}
            label={t('settings.company.fields.email')}
            type="email"
            required
            disabled={!canEdit}
            maxLength={254}
          />
          <FormInput
            name="phone"
            control={form.control}
            label={t('settings.company.fields.phone')}
            type="tel"
            required
            disabled={!canEdit}
            maxLength={32}
          />
          <div className="md:col-span-2">
            <FormInput
              name="address"
              control={form.control}
              label={t('settings.company.fields.address')}
              required
              disabled={!canEdit}
              maxLength={512}
            />
          </div>
          <div className="md:col-span-2">
            <FormInput
              name="home_terminal_address"
              control={form.control}
              label={t('settings.company.fields.homeTerminalAddress')}
              required
              disabled={!canEdit}
              maxLength={512}
            />
          </div>
        </div>
      </Card>

      <Card title={t('settings.company.sections.localization')}>
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
          <FormSelect
            name="timezone"
            control={form.control}
            label={t('settings.company.fields.timezone')}
            required
            disabled={!canEdit}
            searchable
            options={TIMEZONE_OPTIONS}
          />
          <FormSelect
            name="region"
            control={form.control}
            label={t('settings.company.fields.region')}
            required
            disabled={!canEdit}
            options={REGION_VALUES.map((value) => ({
              value,
              label: t(`settings.company.enums.region.${value}`),
            }))}
          />
          <FormSelect
            name="unit_system"
            control={form.control}
            label={t('settings.company.fields.unitSystem')}
            required
            disabled={!canEdit}
            description={t('settings.company.fields.unitSystemHint')}
            options={UNIT_SYSTEM_VALUES.map((value) => ({
              value,
              label: t(`settings.company.enums.unitSystem.${value}`),
            }))}
          />
          <FormSelect
            name="regulation_profile"
            control={form.control}
            label={t('settings.company.fields.regulationProfile')}
            required
            disabled={!canEdit}
            description={t('settings.company.fields.regulationProfileHint')}
            options={REGULATION_PROFILE_VALUES.map((value) => ({
              value,
              label: t(`settings.company.enums.regulationProfile.${value}`),
            }))}
          />
          <FormSelect
            name="distance_regions_set"
            control={form.control}
            label={t('settings.company.fields.distanceRegions')}
            disabled={!canEdit}
            options={DISTANCE_REGIONS_SET_VALUES.map((value) => ({
              value,
              label: t(`settings.company.enums.distanceRegionsSet.${value}`),
            }))}
          />
        </div>
      </Card>

      <Card title={t('settings.company.sections.logo')}>
        <div className="flex flex-col gap-3 sm:flex-row sm:items-start">
          {company.logo_key ? (
            <img
              src={resolveStorageUrl(company.logo_key)}
              alt={t('settings.company.fields.logoPreviewAlt')}
              className="h-16 w-16 rounded-md border border-stroke object-contain"
            />
          ) : null}
          <FileUpload
            kind="logo"
            label={t('settings.company.fields.logo')}
            description={t('settings.company.fields.logoHint')}
            disabled={!canEdit}
            onPresign={presignFile}
            onUploaded={(result) => form.setValue('logo_key', result.key, { shouldDirty: true })}
            onError={(message) => setFormMessage(message)}
            className="w-full max-w-sm"
          />
        </div>
      </Card>

      <Card title={t('settings.company.sections.subscription')}>
        <dl className="grid grid-cols-1 gap-4 md:grid-cols-3">
          <div>
            <dt className="text-body-sm text-neutral-500">{t('settings.company.fields.plan')}</dt>
            <dd className="text-body text-neutral-900">{company.plan || t('common.na')}</dd>
          </div>
          <div>
            <dt className="text-body-sm text-neutral-500">
              {t('settings.company.fields.subscriptionStatus')}
            </dt>
            <dd className="text-body text-neutral-900">
              {company.subscription_status ? (
                <Badge tone={company.subscription_status === 'active' ? 'success' : 'warning'}>
                  {t(`settings.company.enums.subscriptionStatus.${company.subscription_status}`)}
                </Badge>
              ) : (
                t('common.na')
              )}
            </dd>
          </div>
          <div>
            <dt className="text-body-sm text-neutral-500">
              {t('settings.company.fields.subscriptionEndAt')}
            </dt>
            <dd className="text-body text-neutral-900">
              {dateFormat.formatDate(company.subscription_end_at)}
            </dd>
          </div>
        </dl>
        <p className="mt-3 text-body-sm text-neutral-500">
          {t('settings.company.sections.subscriptionHint')}
        </p>
      </Card>

      {canEdit ? (
        <div className="flex justify-end">
          <Button type="submit" loading={isPending} disabled={!form.formState.isDirty}>
            {t('common.actions.saveChanges')}
          </Button>
        </div>
      ) : null}

      <ConfirmDialog
        open={Boolean(pendingValues)}
        onClose={() => setPendingValues(undefined)}
        onConfirm={() => {
          const values = pendingValues;
          setPendingValues(undefined);
          if (values) void commit(values);
        }}
        title={t('settings.company.formatConfirm.title')}
        description={t('settings.company.formatConfirm.description')}
        loading={isPending}
      />
    </form>
  );
}

export default CompanyForm;
