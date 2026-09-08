/**
 * HOS Policy — `/settings/hos` (8.4, §7.13.3).
 *
 * `GET /company/hos-policy` (`hos_policy.read`) — joriy amaldagi siyosat;
 * `POST /company/hos-policy` (`hos_policy.update`) — **yangi versiya**
 * chop etadi, eskisi o'zgarmaydi (F147). Saqlash tugmasi shuning uchun
 * "Publish" deb ataladi va har doim tasdiq dialogi orqali o'tadi — dialogda
 * `diffHosPolicy` bilan hisoblangan o'zgarishlar ro'yxati ko'rsatiladi.
 */
import { useEffect, useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useTranslation } from 'react-i18next';

import { useHosPolicy, useHosPolicyPublish, useHosPolicyVersions } from '@/api/queries/hosPolicy';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { useToast } from '@/components/feedback/toast-context';
import { Alert } from '@/components/feedback/Alert';
import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { Button } from '@/components/ui/Button';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { useDateFormat } from '@/hooks/useDateFormat';
import { isApiError } from '@/lib/errors';
import { PERM, usePermission } from '@/lib/permissions';

import { HosPolicyForm } from '../policy/components/HosPolicyForm';
import { HosPolicyPublishDialog } from '../policy/components/HosPolicyPublishDialog';
import { HosPolicyVersionHistory } from '../policy/components/HosPolicyVersionHistory';
import { diffHosPolicy } from '../policy/lib/diff';
import { formValuesToHosPolicyDocInput, hosPolicyDocToFormValues } from '../policy/lib/mapping';
import { HOS_POLICY_PRESETS } from '../policy/lib/presets';
import { hosPolicyFormSchema, type HosPolicyFormValues } from '../policy/lib/schema';

export function HosPolicyPage() {
  const { t } = useTranslation();
  const toast = useToast();
  const can = usePermission();
  const { formatDateTime } = useDateFormat();

  const policyQuery = useHosPolicy();
  const versionsQuery = useHosPolicyVersions({ per_page: 25 });
  const publish = useHosPolicyPublish();

  const [publishOpen, setPublishOpen] = useState(false);

  const canUpdate = can(PERM.hosPolicyUpdate);

  const form = useForm<HosPolicyFormValues>({
    resolver: zodResolver(hosPolicyFormSchema),
    defaultValues: hosPolicyDocToFormValues(undefined),
    mode: 'onBlur',
  });

  useEffect(() => {
    if (policyQuery.data) {
      form.reset(hosPolicyDocToFormValues(policyQuery.data.policy));
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps -- faqat GET javobi kelganda reset qilinadi
  }, [policyQuery.data]);

  const currentDoc = policyQuery.data?.policy;
  const draftValues = form.watch();
  const draftDoc = useMemo(() => formValuesToHosPolicyDocInput(draftValues), [draftValues]);
  const diffEntries = useMemo(() => diffHosPolicy(currentDoc, draftDoc), [currentDoc, draftDoc]);

  const applyPreset = (key: keyof typeof HOS_POLICY_PRESETS) => {
    form.reset(hosPolicyDocToFormValues(HOS_POLICY_PRESETS[key]), { keepDefaultValues: false });
  };

  const openPublishDialog = form.handleSubmit(() => setPublishOpen(true));

  const confirmPublish = async () => {
    try {
      const policy = formValuesToHosPolicyDocInput(form.getValues());
      const result = await publish.mutateAsync({ policy });
      setPublishOpen(false);
      toast.show({
        variant: 'success',
        message: t('settings.hos.toast.published'),
      });
      if (result?.policy) {
        form.reset(hosPolicyDocToFormValues(result.policy));
      }
    } catch (error) {
      toast.show({
        variant: 'error',
        message: isApiError(error) ? error.message : t('errors.unknown'),
      });
    }
  };

  if (policyQuery.isLoading) {
    return (
      <div className="flex flex-col gap-4 p-6">
        <Skeleton variant="text" className="h-8 w-64" />
        <Skeleton variant="card" count={3} />
      </div>
    );
  }

  if (policyQuery.isError) {
    return (
      <ErrorState message={policyQuery.error?.message} onRetry={() => void policyQuery.refetch()} />
    );
  }

  return (
    <div className="flex flex-col gap-6 p-6">
      <Breadcrumb
        items={[
          { label: t('settings.hos.breadcrumb.settings') },
          { label: t('settings.hos.title') },
        ]}
      />

      <div className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-h3 font-bold text-neutral-900">{t('settings.hos.title')}</h1>
          <p className="text-body text-neutral-500">{t('settings.hos.description')}</p>
        </div>
        <PermissionGate permission={PERM.hosPolicyUpdate}>
          <div className="flex gap-2">
            <Button variant="secondary" onClick={() => applyPreset('fmcsa_70_8')}>
              {t('settings.hos.presets.fmcsa70_8')}
            </Button>
            <Button variant="secondary" onClick={() => applyPreset('fmcsa_60_7')}>
              {t('settings.hos.presets.fmcsa60_7')}
            </Button>
            <Button onClick={() => void openPublishDialog()}>
              {t('settings.hos.publish.action')}
            </Button>
          </div>
        </PermissionGate>
      </div>

      {!canUpdate ? <Alert variant="info" message={t('settings.hos.readOnlyNotice')} /> : null}

      <HosPolicyForm control={form.control} errors={form.formState.errors} disabled={!canUpdate} />

      <section className="flex flex-col gap-3 rounded-lg border border-stroke bg-surface p-4">
        <h2 className="text-body-lg font-semibold text-neutral-900">
          {t('settings.hos.history.title')}
        </h2>
        <HosPolicyVersionHistory
          entries={versionsQuery.data?.data ?? []}
          isLoading={versionsQuery.isLoading}
          isError={versionsQuery.isError}
          errorMessage={versionsQuery.error?.message}
          onRetry={() => void versionsQuery.refetch()}
        />
      </section>

      <HosPolicyPublishDialog
        open={publishOpen}
        onClose={() => setPublishOpen(false)}
        onConfirm={() => void confirmPublish()}
        diffEntries={diffEntries}
        effectiveFromLabel={formatDateTime(new Date())}
        loading={publish.isPending}
      />
    </div>
  );
}

export default HosPolicyPage;
