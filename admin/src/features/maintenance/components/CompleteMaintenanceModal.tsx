/**
 * `MARK MAINTENANCE AS COMPLETE` modali (5.10, §7.6).
 *
 * `POST /maintenance-schedule-units/{id}/complete` (`maintenance.complete`).
 * Maydonlar: `Invoice #` · `Vendor Name` · `Cost` · `Maintenance Date` ·
 * `Invoice` (fayl).
 *
 * **F111** — invoice fayli **PDF / JPG / PNG ≤ 10 MB**. Tekshiruv ikki
 * qatlamda: `FileUpload` `kind="invoice"` oq ro'yxati (MIME + hajm) va
 * presign javobidagi `max_bytes`. Dizayndagi «faqat PDF» yozuvi ishlatilmaydi.
 *
 * Backend xatolari: `409 MAINTENANCE_INVALID_STATE` (allaqachon yopilgan),
 * `422 MAINTENANCE_NO_READING` (telemetriya yo'q) — ikkalasi ham forma
 * tepasidagi alert'ga tushadi, forma ochiq qoladi (fe-screens §7.3).
 */
import { useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { zodResolver } from '@hookform/resolvers/zod';

import { useMaintenanceComplete } from '@/api/queries/maintenance';
import { presignFile } from '@/api/queries/files';
import type { MaintenanceComplete, MaintenanceScheduleUnit } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { useToast } from '@/components/feedback/toast-context';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FileUpload } from '@/components/form/FileUpload';
import { FormDatePicker } from '@/components/form/FormDatePicker';
import { FormInput } from '@/components/form/FormInput';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import { useResetFormOnOpen } from '@/hooks/useResetFormOnOpen';
import { isApiError } from '@/lib/errors';

import { createMaintenanceCompleteSchema, type MaintenanceCompleteFormValues } from '../schemas';

export interface CompleteMaintenanceModalProps {
  open: boolean;
  onClose: () => void;
  scheduleUnit?: MaintenanceScheduleUnit;
}

export function CompleteMaintenanceModal({
  open,
  onClose,
  scheduleUnit,
}: CompleteMaintenanceModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const complete = useMaintenanceComplete();
  const [formError, setFormError] = useState<string | undefined>(undefined);

  const schema = useMemo(() => createMaintenanceCompleteSchema(t), [t]);

  const form = useForm<MaintenanceCompleteFormValues>({
    resolver: zodResolver(schema),
    mode: 'onBlur',
    defaultValues: {
      invoice_no: '',
      vendor: '',
      cost: '',
      performed_at: new Date(),
      invoice_key: '',
    },
  });

  useResetFormOnOpen(
    form,
    open,
    () => ({
      invoice_no: '',
      vendor: '',
      cost: '',
      performed_at: new Date(),
      invoice_key: '',
    }),
    [scheduleUnit?.id],
    () => setFormError(undefined),
  );

  const onSubmit = form.handleSubmit(async (values) => {
    if (!scheduleUnit?.id) return;
    setFormError(undefined);

    const cost = values.cost.trim();
    const body: MaintenanceComplete = {
      invoice_no: values.invoice_no.trim() || undefined,
      vendor: values.vendor.trim() || undefined,
      cost: cost.length > 0 ? Number(cost) : undefined,
      performed_at: values.performed_at.toISOString(),
      invoice_key: values.invoice_key || undefined,
    };

    try {
      await complete.mutateAsync({ id: scheduleUnit.id, body });
      toast.show({
        variant: 'success',
        message: t('maintenance.toast.completed', { unit: scheduleUnit.unit_number ?? '' }),
      });
      onClose();
    } catch (error) {
      if (isApiError(error) && error.status === 409) {
        setFormError(t('maintenance.complete.errors.conflict'));
        return;
      }
      if (isApiError(error) && error.code === 'MAINTENANCE_NO_READING') {
        setFormError(t('maintenance.complete.errors.noReading'));
        return;
      }
      const { formMessage } = applyServerErrors(form, error);
      if (formMessage) setFormError(formMessage);
    }
  });

  return (
    <Modal
      open={open}
      onClose={onClose}
      size="lg"
      closeOnBackdrop={!form.formState.isDirty}
      title={t('maintenance.complete.title')}
      footer={
        <div className="flex justify-end gap-2">
          <Button variant="secondary" onClick={onClose} disabled={complete.isPending}>
            {t('common.actions.cancel')}
          </Button>
          <Button onClick={() => void onSubmit()} loading={complete.isPending}>
            {t('maintenance.complete.submit')}
          </Button>
        </div>
      }
    >
      <form
        noValidate
        onSubmit={(event) => {
          event.preventDefault();
          void onSubmit();
        }}
        className="flex flex-col gap-4"
      >
        {formError ? <Alert variant="error" message={formError} /> : null}

        <div className="grid grid-cols-2 gap-4">
          <FormInput
            control={form.control}
            name="invoice_no"
            label={t('maintenance.complete.fields.invoiceNo')}
            maxLength={64}
          />
          <FormInput
            control={form.control}
            name="vendor"
            label={t('maintenance.complete.fields.vendor')}
            maxLength={200}
          />
          <FormInput
            control={form.control}
            name="cost"
            type="number"
            label={t('maintenance.complete.fields.cost')}
          />
          <FormDatePicker
            control={form.control}
            name="performed_at"
            label={t('maintenance.complete.fields.performedAt')}
            required
          />
        </div>

        <FileUpload
          kind="invoice"
          label={t('maintenance.complete.fields.invoice')}
          description={t('maintenance.complete.invoiceHint')}
          onPresign={presignFile}
          onUploaded={(result) => form.setValue('invoice_key', result.key, { shouldDirty: true })}
          onError={(message) => {
            form.setValue('invoice_key', '', { shouldDirty: true });
            toast.show({ variant: 'error', message });
          }}
        />
      </form>
    </Modal>
  );
}

export default CompleteMaintenanceModal;
