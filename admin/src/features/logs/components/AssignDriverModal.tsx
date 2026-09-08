/**
 * Unassigned Driving — "Assign to driver" modali (7.4.5).
 *
 * `POST /unidentified-events/{id}/assign` haydovchiga **taklif** yuboradi
 * (`tz.md` §10.4) — bu ham F100 ruhida: haydovchi keyin o'zi tasdiqlaydi
 * (natija `LogEditRequest`, `source: 'unidentified_assign'`).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useMemo } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { z } from 'zod';

import { useDriversList } from '@/api/queries/drivers';
import { useUnidentifiedAssign } from '@/api/queries/unidentified';
import type { TrackingUnidentifiedEvent } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { useToast } from '@/components/feedback/toast-context';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormSelect } from '@/components/form/FormSelect';
import { FormTextarea } from '@/components/form/FormTextarea';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import type { SelectOption } from '@/components/ui/Select';
import { formatPersonName } from '@/lib/format';

const assignSchema = z.object({
  driver_id: z.string().min(1, 'required'),
  note: z.string().trim().min(3, 'min 3 characters').max(500, 'max 500 characters'),
});

type AssignFormValues = z.infer<typeof assignSchema>;

export interface AssignDriverModalProps {
  open: boolean;
  onClose: () => void;
  event: TrackingUnidentifiedEvent | undefined;
  onAssigned: () => void;
}

export function AssignDriverModal({ open, onClose, event, onAssigned }: AssignDriverModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const drivers = useDriversList({ per_page: 50 });
  const assign = useUnidentifiedAssign();

  const driverOptions: SelectOption[] = useMemo(
    () =>
      (drivers.data?.data ?? []).map((driver) => ({
        value: driver.id ?? '',
        label: formatPersonName(driver, driver.id ?? ''),
      })),
    [drivers.data],
  );

  const form = useForm<AssignFormValues>({
    resolver: zodResolver(assignSchema),
    defaultValues: { driver_id: '', note: '' },
  });

  const onSubmit = form.handleSubmit(async (values) => {
    if (!event?.id) return;
    try {
      await assign.mutateAsync({ id: event.id, body: values });
      toast.show({
        variant: 'success',
        message: t('logs.unassigned.toast.assigned', { unitNumber: event.unit_number }),
      });
      form.reset({ driver_id: '', note: '' });
      onAssigned();
    } catch (error) {
      applyServerErrors(form, error);
    }
  });

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={t('logs.unassigned.assignModal.title')}
      closeOnBackdrop={!form.formState.isDirty}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={assign.isPending}>
            {t('common.actions.cancel')}
          </Button>
          <Button onClick={() => void onSubmit()} loading={assign.isPending}>
            {t('logs.unassigned.assignModal.submit')}
          </Button>
        </>
      }
    >
      <form
        className="flex flex-col gap-4"
        noValidate
        onSubmit={(e) => {
          e.preventDefault();
          void onSubmit();
        }}
      >
        <Alert variant="info" message={t('logs.unassigned.assignModal.notice')} />
        <FormSelect
          name="driver_id"
          control={form.control}
          label={t('logs.unassigned.assignModal.fields.driver')}
          options={driverOptions}
          searchable
          required
          loading={drivers.isLoading}
        />
        <FormTextarea
          name="note"
          control={form.control}
          label={t('logs.unassigned.assignModal.fields.note')}
          required
          maxLength={500}
          rows={3}
        />
      </form>
    </Modal>
  );
}
