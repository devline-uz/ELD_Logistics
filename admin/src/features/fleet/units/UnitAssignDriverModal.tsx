/**
 * Assign Driver modal — `POST /units/{id}/assign-driver` (2.2, §7.3.2).
 * Haydovchilar ro'yxati `GET /drivers?status=active` dan.
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useEffect, useMemo } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import { useDriversList } from '@/api/queries/drivers';
import { useUnitAssignDriver } from '@/api/queries/units';
import { useToast } from '@/components/feedback/toast-context';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormSelect } from '@/components/form/FormSelect';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import type { SelectOption } from '@/components/ui/Select';
import { isApiError } from '@/lib/errors';

import { unitAssignDriverSchema, type UnitAssignDriverFormValues } from './schemas';

export interface UnitAssignDriverModalProps {
  open: boolean;
  onClose: () => void;
  unitId: string | undefined;
}

export function UnitAssignDriverModal({ open, onClose, unitId }: UnitAssignDriverModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const drivers = useDriversList({ status: 'active', per_page: 50 });
  const assignDriver = useUnitAssignDriver();

  const form = useForm<UnitAssignDriverFormValues>({
    resolver: zodResolver(unitAssignDriverSchema),
    defaultValues: { driver_id: '', role: 'primary' },
  });

  useEffect(() => {
    if (open) form.reset({ driver_id: '', role: 'primary' });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open]);

  const driverOptions: SelectOption[] = useMemo(
    () =>
      (drivers.data?.data ?? []).map((driver) => ({
        value: driver.id ?? '',
        label:
          [driver.first_name, driver.last_name].filter(Boolean).join(' ') ||
          driver.username ||
          (driver.id ?? ''),
      })),
    [drivers.data],
  );

  const roleOptions: SelectOption[] = [
    { value: 'primary', label: t('fleet.units.assignDriver.roles.primary') },
    { value: 'co', label: t('fleet.units.assignDriver.roles.co') },
  ];

  const onSubmit = form.handleSubmit(async (values) => {
    if (!unitId) return;
    try {
      await assignDriver.mutateAsync({ id: unitId, body: values });
      toast.show({ variant: 'success', message: t('fleet.units.assignDriver.toast.success') });
      onClose();
    } catch (error) {
      const result = applyServerErrors(form, error);
      if (result.formMessage) {
        toast.show({
          variant: 'error',
          message: isApiError(error) && error.status === 409 ? error.message : result.formMessage,
        });
      }
    }
  });

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={t('fleet.units.assignDriver.title')}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={assignDriver.isPending}>
            {t('common.actions.cancel')}
          </Button>
          <Button
            onClick={() => {
              void onSubmit();
            }}
            loading={assignDriver.isPending}
          >
            {t('fleet.units.assignDriver.submit')}
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
        <FormSelect
          name="driver_id"
          control={form.control}
          label={t('fleet.units.assignDriver.fields.driver')}
          options={driverOptions}
          loading={drivers.isLoading}
          searchable
          required
        />
        <FormSelect
          name="role"
          control={form.control}
          label={t('fleet.units.assignDriver.fields.role')}
          options={roleOptions}
          required
        />
      </form>
    </Modal>
  );
}

export default UnitAssignDriverModal;
