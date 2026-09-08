/**
 * Settings › Company — `/settings/company` (8.2, `docs/tz/07-13-settings-admin.md`
 * §7.13.1). `GET/PATCH /company` (`company.read`/`company.update`).
 *
 * **F145 [MUST]**: `unit_system`/`regulation_profile` o'zgarganda tasdiqdan
 * keyin saqlanadi (`CompanyForm` ichida) va muvaffaqiyatli javob shu yerda
 * company store'ga yoziladi — `lib/format.ts`/`lib/units.ts` butun panel
 * bo'ylab darhol qayta formatlanadi (alohida `GET /me` so'rovisiz, chunki
 * `PATCH /company` javobi allaqachon yangilangan hujjatni qaytaradi).
 */
import { useTranslation } from 'react-i18next';

import { toCompanyContext } from '@/app/bootstrap';
import { useCompany, useCompanyUpdate } from '@/api/queries/company';
import type { CompanyUpdate } from '@/api/types';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { useToast } from '@/components/feedback/toast-context';
import { PERM, usePermission } from '@/lib/permissions';
import { companyState } from '@/store/company-store';

import { CompanyForm } from '../company/components/CompanyForm';
import type { CompanyFormValues } from '../company/lib/schemas';

function toPayload(
  values: CompanyFormValues,
  existingSettings: CompanyUpdate['settings'],
): CompanyUpdate {
  return {
    name: values.name.trim(),
    address: values.address.trim(),
    home_terminal_address: values.home_terminal_address.trim(),
    timezone: values.timezone,
    email: values.email.trim(),
    phone: values.phone.trim(),
    registration_no: values.registration_no.trim(),
    region: values.region,
    unit_system: values.unit_system,
    regulation_profile: values.regulation_profile,
    // `settings` PATCH'da **butun hujjatni** almashtiradi (swagger) — mavjud
    // `fuel_types`/`quick_notes` shu yerda saqlanadi, faqat `distance_regions_set`
    // yangilanadi.
    settings: { ...existingSettings, distance_regions_set: values.distance_regions_set },
    ...(values.logo_key ? { logo_key: values.logo_key } : {}),
  };
}

export function CompanySettingsPage() {
  const { t } = useTranslation();
  const toast = useToast();
  const can = usePermission();
  const company = useCompany();
  const update = useCompanyUpdate();

  if (company.isLoading) {
    return (
      <div className="flex flex-col gap-4">
        <h1 className="text-h3 font-bold text-neutral-900">{t('settings.company.title')}</h1>
        <Skeleton variant="card" count={3} />
      </div>
    );
  }

  if (company.isError || !company.data?.id) {
    return (
      <div className="flex flex-col gap-4">
        <h1 className="text-h3 font-bold text-neutral-900">{t('settings.company.title')}</h1>
        <ErrorState message={company.error?.message} onRetry={() => void company.refetch()} />
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-4">
      <h1 className="text-h3 font-bold text-neutral-900">{t('settings.company.title')}</h1>

      <CompanyForm
        company={company.data}
        canEdit={can(PERM.companyUpdate)}
        isPending={update.isPending}
        onSubmit={async (values) => {
          const updated = await update.mutateAsync(toPayload(values, company.data?.settings));
          if (updated) {
            companyState().setCompany(toCompanyContext(updated));
          }
          toast.show({
            variant: 'success',
            message: t('settings.company.toast.saved'),
          });
        }}
      />
    </div>
  );
}

export default CompanySettingsPage;
