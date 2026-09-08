/**
 * Unit Add/Edit modal (2.2, `docs/tz/07-3-fleet.md` §7.3.2, fe-screens §2/§3).
 *
 * Marshrutga bog'lanmaydi (`?modal=add` / `?modal=edit&id=` — chaqiruvchi
 * `UnitListPage` boshqaradi). ELD ro'yxati `GET /eld-devices?status=active`
 * dan (`useEldDevicesList`).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import { useBranchesList } from '@/api/queries/branches';
import { useEldDevicesList } from '@/api/queries/eldDevices';
import { useUnitCreate, useUnitUpdate } from '@/api/queries/units';
import type { Unit, UnitCreate, UnitUpdate } from '@/api/types';
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
import { useResetFormOnOpen } from '@/hooks/useResetFormOnOpen';
import { useIsCompanyScope } from '@/hooks/useScope';

import { FUEL_TYPES, unitFormDefaultValues, unitFormSchema, type UnitFormValues } from '../schemas';

export interface UnitFormModalProps {
  open: boolean;
  onClose: () => void;
  /** Berilsa — Edit rejimi (`PATCH`); bo'lmasa — Add (`POST`). */
  unit?: Unit;
}

function unitToFormValues(unit: Unit): UnitFormValues {
  return {
    unit_number: unit.unit_number ?? '',
    make: unit.make ?? '',
    model: unit.model ?? '',
    license_plate: unit.license_plate ?? '',
    plate_region: unit.plate_region ?? '',
    fuel_type: (unit.fuel_type as UnitFormValues['fuel_type']) ?? 'diesel',
    year: unit.year,
    eld_device_id: unit.eld_device_id ?? '',
    vin: unit.vin ?? '',
    branch_id: unit.branch_id ?? '',
    gvwr_class: unit.gvwr_class ?? '',
    sleeper_not_available: unit.sleeper_berth === false,
    notes: unit.notes ?? '',
  };
}

function toPayload(values: UnitFormValues): UnitCreate & UnitUpdate {
  return {
    unit_number: values.unit_number.trim(),
    make: values.make.trim(),
    model: values.model.trim(),
    license_plate: values.license_plate.trim(),
    plate_region: values.plate_region?.trim() || undefined,
    fuel_type: values.fuel_type,
    year: values.year,
    eld_device_id: values.eld_device_id || undefined,
    vin: values.vin?.trim() || undefined,
    branch_id: values.branch_id || undefined,
    gvwr_class: values.gvwr_class?.trim() || undefined,
    sleeper_berth: values.sleeper_not_available ? false : undefined,
    notes: values.notes?.trim() || undefined,
  };
}

export function UnitFormModal({ open, onClose, unit }: UnitFormModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const isEdit = Boolean(unit);

  const eldDevices = useEldDevicesList({ status: 'active', per_page: 50 });
  const isCompanyScope = useIsCompanyScope();
  const branches = useBranchesList({ per_page: 50 }, { enabled: isCompanyScope });
  const create = useUnitCreate();
  const update = useUnitUpdate();
  const pending = create.isPending || update.isPending;

  const form = useForm<UnitFormValues>({
    resolver: zodResolver(unitFormSchema),
    defaultValues: unit ? unitToFormValues(unit) : unitFormDefaultValues,
    mode: 'onBlur',
  });

  useResetFormOnOpen(form, open, () => (unit ? unitToFormValues(unit) : unitFormDefaultValues), [
    unit,
  ]);

  const fuelOptions: SelectOption[] = useMemo(
    () =>
      FUEL_TYPES.map((value) => ({
        value,
        label: t(`fleet.units.fuelTypes.${value}`),
      })),
    [t],
  );

  const eldOptions: SelectOption[] = useMemo(
    () =>
      (eldDevices.data?.data ?? []).map((device) => ({
        value: device.id ?? '',
        label: device.serial ?? device.id ?? '',
      })),
    [eldDevices.data],
  );

  const branchOptions: SelectOption[] = useMemo(
    () =>
      (branches.data?.data ?? []).map((branch) => ({
        value: branch.id ?? '',
        label: branch.name ?? branch.id ?? '',
      })),
    [branches.data],
  );

  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);

  const onSubmit = form.handleSubmit(async (values) => {
    setFormMessage(undefined);
    const payload = toPayload(values);
    try {
      if (isEdit && unit?.id) {
        await update.mutateAsync({ id: unit.id, body: payload });
        toast.show({
          variant: 'success',
          message: t('fleet.units.toast.updated', { unitNumber: values.unit_number }),
        });
      } else {
        await create.mutateAsync(payload);
        toast.show({
          variant: 'success',
          message: t('fleet.units.toast.created', { unitNumber: values.unit_number }),
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
      size="lg"
      title={isEdit ? t('fleet.units.form.editTitle') : t('fleet.units.form.addTitle')}
      closeOnBackdrop={!form.formState.isDirty}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={pending}>
            {t('common.actions.cancel')}
          </Button>
          <Button
            onClick={() => {
              void onSubmit();
            }}
            loading={pending}
            aria-busy={pending}
          >
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
            name="unit_number"
            control={form.control}
            label={t('fleet.units.form.fields.unitNumber')}
            required
          />
          <FormSelect
            name="fuel_type"
            control={form.control}
            label={t('fleet.units.form.fields.fuelType')}
            options={fuelOptions}
            required
          />
          <FormInput
            name="make"
            control={form.control}
            label={t('fleet.units.form.fields.make')}
            required
          />
          <FormInput
            name="model"
            control={form.control}
            label={t('fleet.units.form.fields.model')}
            required
          />
          <FormInput
            name="license_plate"
            control={form.control}
            label={t('fleet.units.form.fields.licensePlate')}
            required
          />
          <FormInput
            name="plate_region"
            control={form.control}
            label={t('fleet.units.form.fields.plateRegion')}
          />
          <FormInput
            name="year"
            control={form.control}
            type="number"
            label={t('fleet.units.form.fields.year')}
          />
          <FormSelect
            name="eld_device_id"
            control={form.control}
            label={t('fleet.units.form.fields.eld')}
            options={eldOptions}
            loading={eldDevices.isLoading}
            clearable
            searchable
          />
          <FormInput
            name="vin"
            control={form.control}
            label={t('fleet.units.form.fields.vin')}
            description={t('fleet.units.form.fields.vinHint')}
            maxLength={17}
          />
          <FormInput
            name="gvwr_class"
            control={form.control}
            label={t('fleet.units.form.fields.gvwrClass')}
          />
          {isCompanyScope ? (
            <FormSelect
              name="branch_id"
              control={form.control}
              label={t('common.fields.branch')}
              options={branchOptions}
              loading={branches.isLoading}
              clearable
              searchable
            />
          ) : null}
        </div>

        <FormCheckbox
          name="sleeper_not_available"
          control={form.control}
          label={t('fleet.units.form.fields.sleeperNotAvailable')}
          description={t('fleet.units.form.fields.sleeperNotAvailableHint')}
        />

        <FormTextarea
          name="notes"
          control={form.control}
          label={t('fleet.units.form.fields.notes')}
          maxLength={60}
          rows={2}
        />
      </form>
    </Modal>
  );
}

export default UnitFormModal;
