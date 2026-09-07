/**
 * Assign to unit modal — `POST /eld-devices/{id}/assign-unit` (2.6, §7.3.6).
 * `unit_id` bo'sh qoldirilsa qurilma ajratiladi (detach).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import { useEldDeviceAssignUnit } from '@/api/queries/eldDevices';
import { useUnitsList } from '@/api/queries/units';
import type { EldDevice } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { useToast } from '@/components/feedback/toast-context';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormSelect } from '@/components/form/FormSelect';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import type { SelectOption } from '@/components/ui/Select';
import { useResetFormOnOpen } from '@/hooks/useResetFormOnOpen';

import { eldDeviceAssignUnitSchema, type EldDeviceAssignUnitFormValues } from '../schemas';

export interface EldDeviceAssignUnitModalProps {
  open: boolean;
  onClose: () => void;
  device: EldDevice | undefined;
}

export function EldDeviceAssignUnitModal({ open, onClose, device }: EldDeviceAssignUnitModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const units = useUnitsList({ status: 'active', per_page: 50 });
  const assignUnit = useEldDeviceAssignUnit();
  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);

  const form = useForm<EldDeviceAssignUnitFormValues>({
    resolver: zodResolver(eldDeviceAssignUnitSchema),
    defaultValues: { unit_id: device?.unit_id ?? '' },
  });

  useResetFormOnOpen(form, open, () => ({ unit_id: device?.unit_id ?? '' }), [device]);

  const unitOptions: SelectOption[] = useMemo(
    () =>
      (units.data?.data ?? []).map((unit) => ({
        value: unit.id ?? '',
        label: unit.unit_number ?? unit.id ?? '',
      })),
    [units.data],
  );

  const onSubmit = form.handleSubmit(async (values) => {
    if (!device?.id) return;
    setFormMessage(undefined);
    try {
      await assignUnit.mutateAsync({
        id: device.id,
        body: { unit_id: values.unit_id || undefined },
      });
      toast.show({ variant: 'success', message: t('fleet.eldDevices.assignUnit.toast.success') });
      onClose();
    } catch (error) {
      const result = applyServerErrors(form, error);
      setFormMessage(result.formMessage ?? undefined);
    }
  });

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={t('fleet.eldDevices.assignUnit.title')}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={assignUnit.isPending}>
            {t('common.actions.cancel')}
          </Button>
          <Button onClick={() => void onSubmit()} loading={assignUnit.isPending}>
            {t('fleet.eldDevices.assignUnit.submit')}
          </Button>
        </>
      }
    >
      <form
        className="flex flex-col gap-4"
        noValidate
        onSubmit={(event) => {
          event.preventDefault();
          void onSubmit();
        }}
      >
        {formMessage ? <Alert message={formMessage} /> : null}
        <FormSelect
          name="unit_id"
          control={form.control}
          label={t('fleet.eldDevices.assignUnit.fields.unit')}
          options={unitOptions}
          loading={units.isLoading}
          searchable
          clearable
          description={t('fleet.eldDevices.assignUnit.fields.unitHint')}
        />
      </form>
    </Modal>
  );
}

export default EldDeviceAssignUnitModal;
