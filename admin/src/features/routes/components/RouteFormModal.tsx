/**
 * Route Add/Edit modal — §7.7.3. D21: tugma nomi **`Create route`**
 * (`Run Trip` emas). Faqat `ongoing` route tahrirlanadi (backend 200/409).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import { useDriversList } from '@/api/queries/drivers';
import { useRouteCreate, useRouteUpdate } from '@/api/queries/routes';
import { useUnitsList } from '@/api/queries/units';
import type { Route, RouteCreate, RouteUpdate } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { useToast } from '@/components/feedback/toast-context';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormInput } from '@/components/form/FormInput';
import { FormSelect } from '@/components/form/FormSelect';
import { FormTextarea } from '@/components/form/FormTextarea';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import type { SelectOption } from '@/components/ui/Select';
import { useResetFormOnOpen } from '@/hooks/useResetFormOnOpen';

import { routeFormDefaultValues, routeFormSchema, type RouteFormValues } from '../schemas';

export interface RouteFormModalProps {
  open: boolean;
  onClose: () => void;
  route?: Route;
}

function routeToFormValues(route: Route): RouteFormValues {
  return {
    unit_id: route.unit_id ?? '',
    driver_id: route.driver_id ?? '',
    origin_text: route.origin?.text ?? '',
    destination_text: route.destination?.text ?? '',
    geofence_m: route.geofence_m ?? 300,
    sequence: route.sequence,
    note: route.note ?? '',
  };
}

function toPayload(values: RouteFormValues): RouteCreate & RouteUpdate {
  return {
    unit_id: values.unit_id,
    driver_id: values.driver_id,
    origin: { text: values.origin_text.trim() },
    destination: { text: values.destination_text.trim() },
    geofence_m: values.geofence_m,
    sequence: values.sequence,
    note: values.note?.trim() || undefined,
  };
}

export function RouteFormModal({ open, onClose, route }: RouteFormModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const isEdit = Boolean(route);

  const units = useUnitsList({ per_page: 50, status: 'active' });
  const drivers = useDriversList({ per_page: 50, status: 'active' });
  const create = useRouteCreate();
  const update = useRouteUpdate();
  const pending = create.isPending || update.isPending;

  const form = useForm<RouteFormValues>({
    resolver: zodResolver(routeFormSchema),
    defaultValues: route ? routeToFormValues(route) : routeFormDefaultValues,
    mode: 'onBlur',
  });

  useResetFormOnOpen(
    form,
    open,
    () => (route ? routeToFormValues(route) : routeFormDefaultValues),
    [route],
  );

  const unitOptions: SelectOption[] = useMemo(
    () => (units.data?.data ?? []).map((unit) => ({ value: unit.id ?? '', label: unit.unit_number ?? unit.id ?? '' })),
    [units.data],
  );

  const driverOptions: SelectOption[] = useMemo(
    () =>
      (drivers.data?.data ?? []).map((driver) => ({
        value: driver.id ?? '',
        label: `${driver.first_name ?? ''} ${driver.last_name ?? ''}`.trim() || (driver.id ?? ''),
      })),
    [drivers.data],
  );

  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);

  const onSubmit = form.handleSubmit(async (values) => {
    setFormMessage(undefined);
    const payload = toPayload(values);
    try {
      if (isEdit && route?.id) {
        await update.mutateAsync({ id: route.id, body: payload });
        toast.show({ variant: 'success', message: t('routes.list.toast.updated') });
      } else {
        await create.mutateAsync(payload);
        toast.show({ variant: 'success', message: t('routes.list.toast.created') });
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
      title={isEdit ? t('routes.form.editTitle') : t('routes.form.addTitle')}
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
            {isEdit ? t('common.actions.saveChanges') : t('routes.list.actions.create')}
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
          <FormSelect
            name="unit_id"
            control={form.control}
            label={t('routes.form.fields.unit')}
            options={unitOptions}
            searchable
            required
          />
          <FormSelect
            name="driver_id"
            control={form.control}
            label={t('routes.form.fields.driver')}
            options={driverOptions}
            searchable
            required
          />
          <FormInput
            name="origin_text"
            control={form.control}
            label={t('routes.form.fields.originText')}
            required
          />
          <FormInput
            name="destination_text"
            control={form.control}
            label={t('routes.form.fields.destinationText')}
            required
          />
          <FormInput
            name="geofence_m"
            control={form.control}
            type="number"
            label={t('routes.form.fields.geofenceM')}
          />
          <FormInput
            name="sequence"
            control={form.control}
            type="number"
            label={t('routes.form.fields.sequence')}
          />
        </div>

        <FormTextarea
          name="note"
          control={form.control}
          label={t('routes.form.fields.note')}
          maxLength={1000}
          rows={3}
        />
      </form>
    </Modal>
  );
}

export default RouteFormModal;
