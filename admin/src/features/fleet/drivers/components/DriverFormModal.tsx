/**
 * Driver — Add/Edit modal (2.4/2.5, TZ 7.3.5, fe-screens §2/§3).
 *
 * D2/F86 [MUST]: hech qanday `type="password"` maydon yo'q — parol faqat
 * `Send password reset` orqali (`DriverListPage`/`DriverDetailPage`).
 * F87: `license_no` Edit'da bo'sh boshlanadi — bo'sh qoldirilsa backend
 * joriy qiymatni saqlaydi; to'ldirilsa yangilanadi (`license_no_masked`
 * hech qachon formaga qaytarilmaydi — u ochiq qiymatni bilmaydi).
 */
import { useEffect, useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useTranslation } from 'react-i18next';

import { useUnitsList } from '@/api/queries/units';
import { useUsersList } from '@/api/queries/users';
import type { Driver, DriverCreate, DriverUpdate } from '@/api/types';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormInput } from '@/components/form/FormInput';
import { FormSelect } from '@/components/form/FormSelect';
import { FormTextarea } from '@/components/form/FormTextarea';
import { Alert } from '@/components/feedback/Alert';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';

import {
  driverCreateSchema,
  driverUpdateSchema,
  type DriverCreateFormValues,
  type DriverUpdateFormValues,
} from '../schemas';

export interface DriverFormModalProps {
  open: boolean;
  onClose: () => void;
  /** Berilsa — Edit rejimi, aks holda Add. */
  driver?: Driver;
  onSubmitCreate: (body: DriverCreate) => Promise<unknown>;
  onSubmitUpdate: (body: DriverUpdate) => Promise<unknown>;
  submitting?: boolean;
}

function toCreateBody(values: DriverCreateFormValues): DriverCreate {
  return {
    first_name: values.first_name,
    last_name: values.last_name,
    username: values.username,
    license_no: values.license_no,
    email: values.email || undefined,
    phone: values.phone || undefined,
    license_region: values.license_region || undefined,
    default_unit_id: values.default_unit_id || undefined,
    fleet_manager_id: values.fleet_manager_id || undefined,
    branch_id: values.branch_id || undefined,
    home_terminal: values.home_terminal || undefined,
    city: values.city || undefined,
    state: values.state || undefined,
    zip: values.zip || undefined,
    address1: values.address1 || undefined,
    address2: values.address2 || undefined,
    notes: values.notes || undefined,
  };
}

function toUpdateBody(values: DriverUpdateFormValues): DriverUpdate {
  return {
    first_name: values.first_name,
    last_name: values.last_name,
    email: values.email || undefined,
    phone: values.phone || undefined,
    license_no: values.license_no || undefined,
    license_region: values.license_region || undefined,
    default_unit_id: values.default_unit_id || undefined,
    fleet_manager_id: values.fleet_manager_id || undefined,
    branch_id: values.branch_id || undefined,
    home_terminal: values.home_terminal || undefined,
    city: values.city || undefined,
    state: values.state || undefined,
    zip: values.zip || undefined,
    address1: values.address1 || undefined,
    address2: values.address2 || undefined,
    notes: values.notes || undefined,
  };
}

export function DriverFormModal({
  open,
  onClose,
  driver,
  onSubmitCreate,
  onSubmitUpdate,
  submitting = false,
}: DriverFormModalProps) {
  const { t } = useTranslation();
  const isEdit = Boolean(driver);
  const [formError, setFormError] = useState<string | undefined>();
  const [discardConfirmOpen, setDiscardConfirmOpen] = useState(false);

  const unitsQuery = useUnitsList({ status: 'active', per_page: 50 });
  const managersQuery = useUsersList({ per_page: 50 });

  const unitOptions = useMemo(
    () =>
      (unitsQuery.data?.data ?? []).map((unit) => ({
        value: unit.id ?? '',
        label: unit.unit_number ?? unit.id ?? '',
      })),
    [unitsQuery.data],
  );

  const managerOptions = useMemo(
    () =>
      (managersQuery.data?.data ?? []).map((user) => ({
        value: user.id ?? '',
        label: user.full_name ?? `${user.first_name ?? ''} ${user.last_name ?? ''}`.trim(),
      })),
    [managersQuery.data],
  );

  const defaultValues: DriverCreateFormValues | DriverUpdateFormValues = useMemo(
    () => ({
      first_name: driver?.first_name ?? '',
      last_name: driver?.last_name ?? '',
      username: driver?.username ?? '',
      email: driver?.email ?? '',
      phone: driver?.phone ?? '',
      license_no: '',
      license_region: driver?.license_region ?? '',
      default_unit_id: driver?.default_unit_id ?? '',
      fleet_manager_id: driver?.fleet_manager_id ?? '',
      branch_id: driver?.branch_id ?? '',
      home_terminal: driver?.home_terminal ?? '',
      city: driver?.city ?? '',
      state: driver?.state ?? '',
      zip: driver?.zip ?? '',
      address1: driver?.address1 ?? '',
      address2: driver?.address2 ?? '',
      notes: driver?.notes ?? '',
    }),
    [driver],
  );

  const form = useForm<DriverCreateFormValues | DriverUpdateFormValues>({
    resolver: zodResolver(isEdit ? driverUpdateSchema : driverCreateSchema),
    mode: 'onBlur',
    defaultValues,
  });

  useEffect(() => {
    if (open) {
      form.reset(defaultValues);
      setFormError(undefined);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, driver?.id]);

  const handleClose = () => {
    if (form.formState.isDirty) {
      setDiscardConfirmOpen(true);
      return;
    }
    onClose();
  };

  const onSubmit = form.handleSubmit(async (values) => {
    setFormError(undefined);
    try {
      if (isEdit) {
        await onSubmitUpdate(toUpdateBody(values));
      } else {
        await onSubmitCreate(toCreateBody(values as DriverCreateFormValues));
      }
      onClose();
    } catch (error) {
      const result = applyServerErrors(form, error);
      if (result.formMessage) setFormError(result.formMessage);
    }
  });

  return (
    <>
      <Modal
        open={open}
        onClose={handleClose}
        size="lg"
        title={isEdit ? t('fleetDrivers.form.editTitle') : t('fleetDrivers.form.addTitle')}
        footer={
          <>
            <Button variant="secondary" onClick={handleClose} disabled={submitting}>
              {t('common.actions.cancel')}
            </Button>
            <Button onClick={() => void onSubmit()} loading={submitting} disabled={submitting}>
              {isEdit ? t('common.actions.saveChanges') : t('common.actions.add')}
            </Button>
          </>
        }
      >
        <form className="flex flex-col gap-4" onSubmit={(event) => void onSubmit(event)} noValidate>
          {formError ? <Alert variant="error" message={formError} /> : null}

          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <FormInput
              name="first_name"
              control={form.control}
              label={t('fleetDrivers.form.firstName')}
              required
            />
            <FormInput
              name="last_name"
              control={form.control}
              label={t('fleetDrivers.form.lastName')}
              required
            />
            {isEdit ? (
              <FormInput
                name="username"
                control={form.control}
                label={t('fleetDrivers.form.username')}
                disabled
              />
            ) : (
              <FormInput
                name="username"
                control={form.control}
                label={t('fleetDrivers.form.username')}
                required
                description={t('fleetDrivers.form.usernameHint')}
              />
            )}
            <FormInput
              name="email"
              control={form.control}
              type="email"
              label={t('fleetDrivers.form.email')}
              required={!isEdit}
              description={t('fleetDrivers.form.emailOrPhoneHint')}
            />
            <FormInput name="phone" control={form.control} label={t('fleetDrivers.form.phone')} />
            <FormInput
              name="license_no"
              control={form.control}
              label={t('fleetDrivers.form.licenseNo')}
              required={!isEdit}
              description={isEdit ? t('fleetDrivers.form.licenseNoEditHint') : undefined}
            />
            <FormInput
              name="license_region"
              control={form.control}
              label={t('fleetDrivers.form.licenseRegion')}
            />
            <FormSelect
              name="default_unit_id"
              control={form.control}
              label={t('fleetDrivers.form.defaultUnit')}
              options={unitOptions}
              clearable
              searchable
              loading={unitsQuery.isLoading}
            />
            <FormSelect
              name="fleet_manager_id"
              control={form.control}
              label={t('fleetDrivers.form.fleetManager')}
              options={managerOptions}
              clearable
              searchable
              loading={managersQuery.isLoading}
            />
            <FormInput
              name="home_terminal"
              control={form.control}
              label={t('fleetDrivers.form.homeTerminal')}
            />
            <FormInput name="city" control={form.control} label={t('fleetDrivers.form.city')} />
            <FormInput name="state" control={form.control} label={t('fleetDrivers.form.state')} />
            <FormInput name="zip" control={form.control} label={t('fleetDrivers.form.zip')} />
            <FormInput
              name="address1"
              control={form.control}
              label={t('fleetDrivers.form.address1')}
            />
            <FormInput
              name="address2"
              control={form.control}
              label={t('fleetDrivers.form.address2')}
            />
          </div>

          <FormTextarea
            name="notes"
            control={form.control}
            label={t('fleetDrivers.form.notes')}
            maxLength={60}
            rows={2}
          />
        </form>
      </Modal>

      <ConfirmDialog
        open={discardConfirmOpen}
        onClose={() => setDiscardConfirmOpen(false)}
        onConfirm={() => {
          setDiscardConfirmOpen(false);
          onClose();
        }}
        title={t('ui.form.discard.title')}
        description={t('ui.form.discard.description')}
        confirmLabel={t('ui.form.discard.confirm')}
      />
    </>
  );
}

export default DriverFormModal;
