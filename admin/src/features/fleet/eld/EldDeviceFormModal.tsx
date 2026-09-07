/**
 * ELD Device Add/Edit modal (2.6, §7.3.6, 🎨 — fe-screens §2/§3 patterni).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import { useEldDeviceCreate, useEldDeviceUpdate } from '@/api/queries/eldDevices';
import type { EldDevice } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { useToast } from '@/components/feedback/toast-context';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormCheckbox } from '@/components/form/FormCheckbox';
import { FormInput } from '@/components/form/FormInput';
import { FormSelect } from '@/components/form/FormSelect';
import { FormTextarea } from '@/components/form/FormTextarea';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import type { SelectOption } from '@/components/ui/Select';

import {
  CONNECTION_TYPES,
  DEVICE_STATUSES,
  eldDeviceFormDefaultValues,
  eldDeviceFormSchema,
  type EldDeviceFormValues,
} from './schemas';

export interface EldDeviceFormModalProps {
  open: boolean;
  onClose: () => void;
  device?: EldDevice;
}

function deviceToFormValues(device: EldDevice): EldDeviceFormValues {
  return {
    serial: device.serial ?? '',
    vendor: device.vendor ?? '',
    model: device.model ?? '',
    firmware: device.firmware ?? '',
    connection_type: device.connection_type,
    status: device.status ?? 'active',
    sim_present: Boolean(device.sim_present),
    notes: device.notes ?? '',
  };
}

export function EldDeviceFormModal({ open, onClose, device }: EldDeviceFormModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const isEdit = Boolean(device);
  const create = useEldDeviceCreate();
  const update = useEldDeviceUpdate();
  const pending = create.isPending || update.isPending;
  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);

  const form = useForm<EldDeviceFormValues>({
    resolver: zodResolver(eldDeviceFormSchema),
    defaultValues: device ? deviceToFormValues(device) : eldDeviceFormDefaultValues,
  });

  useEffect(() => {
    if (open) form.reset(device ? deviceToFormValues(device) : eldDeviceFormDefaultValues);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, device]);

  const connectionOptions: SelectOption[] = CONNECTION_TYPES.map((value) => ({
    value,
    label: t(`fleet.eldDevices.connectionTypes.${value}`),
  }));
  const statusOptions: SelectOption[] = DEVICE_STATUSES.map((value) => ({
    value,
    label: t(`fleet.eldDevices.statuses.${value}`),
  }));

  const onSubmit = form.handleSubmit(async (values) => {
    setFormMessage(undefined);
    const payload = {
      serial: values.serial.trim(),
      vendor: values.vendor.trim(),
      model: values.model?.trim() || undefined,
      firmware: values.firmware?.trim() || undefined,
      connection_type: values.connection_type,
      status: values.status,
      sim_present: values.sim_present,
      notes: values.notes?.trim() || undefined,
    };
    try {
      if (isEdit && device?.id) {
        await update.mutateAsync({ id: device.id, body: payload });
        toast.show({
          variant: 'success',
          message: t('fleet.eldDevices.toast.updated', { serial: values.serial }),
        });
      } else {
        await create.mutateAsync(payload);
        toast.show({
          variant: 'success',
          message: t('fleet.eldDevices.toast.created', { serial: values.serial }),
        });
      }
      onClose();
    } catch (error) {
      const result = applyServerErrors(form, error);
      if (result.formMessage) setFormMessage(result.formMessage);
    }
  });

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={isEdit ? t('fleet.eldDevices.form.editTitle') : t('fleet.eldDevices.form.addTitle')}
      closeOnBackdrop={!form.formState.isDirty}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={pending}>
            {t('common.actions.cancel')}
          </Button>
          <Button onClick={() => void onSubmit()} loading={pending}>
            {isEdit ? t('common.actions.saveChanges') : t('common.actions.create')}
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
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <FormInput
            name="serial"
            control={form.control}
            label={t('fleet.eldDevices.form.fields.serial')}
            required
          />
          <FormInput
            name="vendor"
            control={form.control}
            label={t('fleet.eldDevices.form.fields.vendor')}
            required
          />
          <FormInput
            name="model"
            control={form.control}
            label={t('fleet.eldDevices.form.fields.model')}
          />
          <FormInput
            name="firmware"
            control={form.control}
            label={t('fleet.eldDevices.form.fields.firmware')}
          />
          <FormSelect
            name="connection_type"
            control={form.control}
            label={t('fleet.eldDevices.form.fields.connectionType')}
            options={connectionOptions}
            clearable
          />
          <FormSelect
            name="status"
            control={form.control}
            label={t('fleet.eldDevices.form.fields.status')}
            options={statusOptions}
          />
        </div>
        <FormCheckbox
          name="sim_present"
          control={form.control}
          label={t('fleet.eldDevices.form.fields.simPresent')}
        />
        <FormTextarea
          name="notes"
          control={form.control}
          label={t('fleet.eldDevices.form.fields.notes')}
          maxLength={60}
          rows={2}
        />
      </form>
    </Modal>
  );
}

export default EldDeviceFormModal;
