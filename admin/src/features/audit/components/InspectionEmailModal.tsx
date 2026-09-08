/**
 * Inspection logs — "Email report" modali (8.11, §7.12). `POST
 * /inspection/email` — joriy filtrlangan haydovchi/sana oynasini PDF
 * sifatida ko'rsatilgan manzilga yuboradi (`202`, `inspection.email`).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import { useInspectionEmailSend } from '@/api/queries/inspection';
import { Alert } from '@/components/feedback/Alert';
import { useToast } from '@/components/feedback/toast-context';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormInput } from '@/components/form/FormInput';
import { FormTextarea } from '@/components/form/FormTextarea';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import { useResetFormOnOpen } from '@/hooks/useResetFormOnOpen';

import {
  buildInspectionEmailSchema,
  inspectionEmailDefaultValues,
  type InspectionEmailFormValues,
} from '../lib/inspectionEmailSchema';

export interface InspectionEmailModalProps {
  open: boolean;
  onClose: () => void;
  driverId: string;
  driverName: string;
  date?: string;
}

export function InspectionEmailModal({
  open,
  onClose,
  driverId,
  driverName,
  date,
}: InspectionEmailModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const schema = useMemo(() => buildInspectionEmailSchema(t), [t]);
  const mutation = useInspectionEmailSend();
  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);

  const form = useForm<InspectionEmailFormValues>({
    resolver: zodResolver(schema),
    defaultValues: inspectionEmailDefaultValues,
    mode: 'onBlur',
  });

  useResetFormOnOpen(
    form,
    open,
    () => inspectionEmailDefaultValues,
    [driverId],
    () => setFormMessage(undefined),
  );

  const submit = form.handleSubmit(async (values) => {
    setFormMessage(undefined);
    try {
      await mutation.mutateAsync({
        email: values.email,
        comment: values.comment || undefined,
        driver_id: driverId,
        date,
      });
      toast.show({
        variant: 'success',
        message: t('inspection.emailModal.toast.sent', { driverName, email: values.email }),
      });
      onClose();
    } catch (error) {
      const result = applyServerErrors(form, error);
      setFormMessage(result.formMessage ?? t('inspection.emailModal.errors.generic'));
    }
  });

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={t('inspection.emailModal.title')}
      closeOnBackdrop={!form.formState.isDirty}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={mutation.isPending}>
            {t('common.actions.cancel')}
          </Button>
          <Button onClick={() => void submit()} loading={mutation.isPending}>
            {t('inspection.emailModal.actions.send')}
          </Button>
        </>
      }
    >
      <form className="flex flex-col gap-4" onSubmit={(event) => event.preventDefault()}>
        {formMessage ? <Alert variant="error" message={formMessage} /> : null}

        <p className="text-body-sm text-neutral-500">
          {t('inspection.emailModal.description', { driverName })}
        </p>

        <FormInput
          name="email"
          control={form.control}
          type="text"
          label={t('inspection.emailModal.fields.email')}
          placeholder={t('inspection.emailModal.fields.emailPlaceholder')}
          required
          maxLength={255}
        />

        <FormTextarea
          name="comment"
          control={form.control}
          label={t('inspection.emailModal.fields.comment')}
          maxLength={500}
          rows={3}
        />
      </form>
    </Modal>
  );
}

export default InspectionEmailModal;
