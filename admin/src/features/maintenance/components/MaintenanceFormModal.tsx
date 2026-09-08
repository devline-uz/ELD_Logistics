/**
 * `MAINTENANCE DETAILS` — Add / Edit modali (5.7, 5.8; §7.6).
 *
 * - **Ikki rejim**: `Single Unit` / `Multiple Units` (backendda alohida maydon
 *   yo'q — farq faqat `units[]` uzunligida). Ko'p rejimda `Select All` va har
 *   unit uchun `Last service value` maydoni.
 * - **Birlik konvertatsiyasi (5.8)**: masofa maydonlari (`Maintenance
 *   Frequency`, `Set Reminder`, `Last service value`) foydalanuvchi tizimida
 *   ko'rsatiladi va kiritiladi; yorliq (`km`/`mi`) har maydonda doim ko'rinadi.
 *   Konvertatsiya `intervalUnits.ts` orqali (`parseDistance`/`convertDistance`),
 *   ikki tomonlama.
 * - Imlo §16 C1/C3 bo'yicha to'g'rilangan: `MAINTENANCE DETAILS`, `Grease`.
 */
import { useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { zodResolver } from '@hookform/resolvers/zod';

import {
  useMaintenanceScheduleCreate,
  useMaintenanceScheduleUpdate,
} from '@/api/queries/maintenance';
import type {
  MaintenanceSchedule,
  MaintenanceScheduleCreate,
  MaintenanceScheduleUnit,
  MaintenanceScheduleUnitInput,
} from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { useToast } from '@/components/feedback/toast-context';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormCheckbox } from '@/components/form/FormCheckbox';
import { FormInput } from '@/components/form/FormInput';
import { FormSelect } from '@/components/form/FormSelect';
import { FormTextarea } from '@/components/form/FormTextarea';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import { MultiSelect } from '@/components/ui/MultiSelect';
import { Radio } from '@/components/ui/Radio';
import { useResetFormOnOpen } from '@/hooks/useResetFormOnOpen';
import { useUnitSystem } from '@/hooks/useUnitSystem';

import {
  MAINTENANCE_ALERT_TYPES,
  MAINTENANCE_DELIVERY_METHODS,
  MAINTENANCE_TYPES,
  NOTES_MAX_LENGTH,
  SCHEDULE_STATUSES,
} from '../constants';
import { choiceOf, intervalUnitLabel, toApiInterval, toUserIntervalValue } from '../intervalUnits';
import {
  createMaintenanceScheduleSchema,
  maintenanceScheduleFormDefaults,
  type MaintenanceScheduleFormValues,
} from '../schemas';
import { useUnitLookup } from '../useUnitLookup';

export interface MaintenanceFormModalProps {
  open: boolean;
  onClose: () => void;
  /** Tahrirlash rejimi — mavjud reja. */
  schedule?: MaintenanceSchedule;
  /** Rejaga biriktirilgan unit qatorlari (tahrirlashda oldindan to'ldirish uchun). */
  scheduleUnits?: MaintenanceScheduleUnit[];
}

/** Formadagi matnni songa aylantiradi; bo'sh matn → `undefined`. */
function toOptionalNumber(value: string | undefined): number | undefined {
  const trimmed = (value ?? '').trim();
  if (trimmed.length === 0) return undefined;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? parsed : undefined;
}

export function MaintenanceFormModal({
  open,
  onClose,
  schedule,
  scheduleUnits,
}: MaintenanceFormModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const { unitSystem } = useUnitSystem();
  const { units } = useUnitLookup();
  const create = useMaintenanceScheduleCreate();
  const update = useMaintenanceScheduleUpdate();
  const [formError, setFormError] = useState<string | undefined>(undefined);

  const isEdit = Boolean(schedule?.id);
  const schema = useMemo(() => createMaintenanceScheduleSchema(t), [t]);

  const form = useForm<MaintenanceScheduleFormValues>({
    resolver: zodResolver(schema),
    mode: 'onBlur',
    defaultValues: maintenanceScheduleFormDefaults,
  });

  /**
   * Saqlangan qiymatlarni **foydalanuvchi tizimiga** o'tkazib formani
   * to'ldiradi (5.8 — ko'rsatish tomoni).
   */
  useResetFormOnOpen(
    form,
    open,
    () => {
      if (!schedule) return maintenanceScheduleFormDefaults;

      const storedUnit = schedule.interval_unit;
      const attached = scheduleUnits ?? [];
      const lastServiceValues: Record<string, string> = {};
      for (const row of attached) {
        if (!row.unit_id) continue;
        const converted = toUserIntervalValue(row.last_service_value, storedUnit, unitSystem);
        lastServiceValues[row.unit_id] = converted === null ? '' : String(converted);
      }

      const intervalValue = toUserIntervalValue(schedule.interval_value, storedUnit, unitSystem);
      const reminderValue = toUserIntervalValue(
        schedule.reminder_before_value,
        storedUnit,
        unitSystem,
      );

      return {
        ...maintenanceScheduleFormDefaults,
        type: schedule.type ?? maintenanceScheduleFormDefaults.type,
        mode: attached.length > 1 ? ('multiple' as const) : ('single' as const),
        unit_id: attached.length === 1 ? (attached[0]?.unit_id ?? '') : '',
        unit_ids: attached.length > 1 ? attached.map((row) => row.unit_id ?? '') : [],
        last_service_values: lastServiceValues,
        interval_value: intervalValue === null ? '' : String(intervalValue),
        interval_unit_choice: choiceOf(storedUnit),
        reminder_before_value: reminderValue === null ? '0' : String(reminderValue),
        name: schedule.name ?? '',
        alert_type: schedule.alert_type ?? 'notification',
        delivery_methods: (schedule.delivery_methods ??
          []) as MaintenanceScheduleFormValues['delivery_methods'],
        notify_co_driver: Boolean(schedule.notify_co_driver),
        notes: schedule.notes ?? '',
        status: schedule.status ?? 'active',
      } satisfies MaintenanceScheduleFormValues;
    },
    [schedule?.id, scheduleUnits, unitSystem],
    () => setFormError(undefined),
  );

  const mode = form.watch('mode');
  const choice = form.watch('interval_unit_choice');
  const selectedUnitIds = form.watch('unit_ids');
  const singleUnitId = form.watch('unit_id');

  /** Kiritish yonidagi birlik yorlig'i — **doim ko'rinadi** (fe-design-system §11). */
  const unitLabel = t(`enums.maintenance_interval_unit.${intervalUnitLabel(choice, unitSystem)}`);
  const unitSuffix = intervalUnitLabel(choice, unitSystem);

  const typeOptions = useMemo(
    () => MAINTENANCE_TYPES.map((v) => ({ value: v, label: t(`enums.maintenance_type.${v}`) })),
    [t],
  );
  const alertTypeOptions = useMemo(
    () =>
      MAINTENANCE_ALERT_TYPES.map((v) => ({
        value: v,
        label: t(`enums.maintenance_alert_type.${v}`),
      })),
    [t],
  );
  const deliveryOptions = useMemo(
    () =>
      MAINTENANCE_DELIVERY_METHODS.map((v) => ({
        value: v,
        label: t(`enums.maintenance_delivery_method.${v}`),
      })),
    [t],
  );
  const statusOptions = useMemo(
    () =>
      SCHEDULE_STATUSES.map((v) => ({
        value: v,
        label: t(`enums.maintenance_schedule_status.${v}`),
      })),
    [t],
  );
  const intervalChoiceOptions = useMemo(
    () => [
      {
        value: 'distance' as const,
        label: t(`enums.maintenance_interval_unit.${intervalUnitLabel('distance', unitSystem)}`),
      },
      { value: 'days' as const, label: t('enums.maintenance_interval_unit.days') },
      { value: 'engine_hours' as const, label: t('enums.maintenance_interval_unit.engine_hours') },
    ],
    [t, unitSystem],
  );
  const unitOptions = useMemo(
    () =>
      units
        .filter((unit): unit is typeof unit & { id: string } => Boolean(unit.id))
        .map((unit) => ({ value: unit.id, label: unit.unit_number ?? unit.id })),
    [units],
  );

  const selectedUnits = useMemo(
    () => unitOptions.filter((option) => selectedUnitIds.includes(option.value)),
    [unitOptions, selectedUnitIds],
  );

  const onSubmit = form.handleSubmit(async (values) => {
    setFormError(undefined);

    const interval = toApiInterval(
      Number(values.interval_value),
      values.interval_unit_choice,
      unitSystem,
    );

    const chosenIds = values.mode === 'single' ? [values.unit_id] : values.unit_ids;
    const unitsPayload: MaintenanceScheduleUnitInput[] = chosenIds
      .filter((id) => id.length > 0)
      .map((id) => {
        const raw = toOptionalNumber(values.last_service_values[id]);
        return raw === undefined ? { unit_id: id } : { unit_id: id, last_service_value: raw };
      });

    const body: MaintenanceScheduleCreate = {
      name: values.name.trim(),
      type: values.type,
      status: values.status,
      interval_unit: interval.interval_unit,
      interval_value: interval.interval_value,
      reminder_before_value: Number(values.reminder_before_value),
      alert_type: values.alert_type,
      delivery_methods: [...values.delivery_methods],
      notify_co_driver: values.notify_co_driver,
      notes: values.notes.trim() || undefined,
      units: unitsPayload,
    };

    try {
      if (isEdit && schedule?.id) {
        await update.mutateAsync({ id: schedule.id, body });
      } else {
        await create.mutateAsync(body);
      }
      toast.show({
        variant: 'success',
        message: t(isEdit ? 'maintenance.toast.updated' : 'maintenance.toast.created', {
          name: body.name,
        }),
      });
      onClose();
    } catch (error) {
      const { formMessage } = applyServerErrors(form, error);
      if (formMessage) setFormError(formMessage);
    }
  });

  const isPending = create.isPending || update.isPending;

  return (
    <Modal
      open={open}
      onClose={onClose}
      size="xl"
      closeOnBackdrop={!form.formState.isDirty}
      title={t(isEdit ? 'maintenance.form.editTitle' : 'maintenance.form.addTitle')}
      footer={
        <div className="flex justify-end gap-2">
          <Button variant="secondary" onClick={onClose} disabled={isPending}>
            {t('common.actions.cancel')}
          </Button>
          <Button onClick={() => void onSubmit()} loading={isPending}>
            {t(isEdit ? 'common.actions.saveChanges' : 'common.actions.create')}
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
        <h3 className="text-body-sm font-medium uppercase tracking-wide text-neutral-500">
          {t('maintenance.form.sectionTitle')}
        </h3>

        {/* Alert bloki — reja qanday ishlashini tushuntiradi (5.7). */}
        <Alert variant="info" message={t('maintenance.form.alert')} />

        {formError ? <Alert variant="error" message={formError} /> : null}

        <div className="grid grid-cols-2 gap-4">
          <FormSelect
            control={form.control}
            name="type"
            label={t('maintenance.form.fields.type')}
            required
            options={typeOptions}
          />
          <FormInput
            control={form.control}
            name="name"
            label={t('maintenance.form.fields.name')}
            required
            maxLength={160}
          />
        </div>

        {/* Rejim — Single / Multiple (5.7). */}
        <fieldset className="flex flex-col gap-2">
          <legend className="pb-1 text-body-sm font-medium text-neutral-700">
            {t('maintenance.form.fields.mode')}
          </legend>
          <div className="flex gap-6">
            <Radio
              name="mode"
              value="single"
              checked={mode === 'single'}
              onChange={() => form.setValue('mode', 'single', { shouldDirty: true })}
              label={t('maintenance.form.modes.single')}
            />
            <Radio
              name="mode"
              value="multiple"
              checked={mode === 'multiple'}
              onChange={() => form.setValue('mode', 'multiple', { shouldDirty: true })}
              label={t('maintenance.form.modes.multiple')}
            />
          </div>
        </fieldset>

        {mode === 'single' ? (
          <FormSelect
            control={form.control}
            name="unit_id"
            label={t('maintenance.form.fields.unit')}
            required
            searchable
            placeholder={t('maintenance.form.unitPlaceholder')}
            options={unitOptions}
          />
        ) : (
          <MultiSelect
            label={t('maintenance.form.fields.units')}
            required
            selectAll
            searchable
            placeholder={t('maintenance.form.unitsPlaceholder')}
            options={unitOptions}
            values={selectedUnitIds}
            onChange={(next) => form.setValue('unit_ids', next, { shouldDirty: true })}
            error={form.formState.errors.unit_ids?.message}
          />
        )}

        {/* Har tanlangan unit uchun `Last service value` (§7.6, ko'p rejim). */}
        {mode === 'multiple' && selectedUnits.length > 0 ? (
          <div className="flex flex-col gap-3 rounded-md border border-stroke p-3">
            <p className="text-body-sm text-neutral-500">
              {t('maintenance.form.unitsSelected', { count: selectedUnits.length })}
            </p>
            {selectedUnits.map((unit) => (
              <FormInput
                key={unit.value}
                control={form.control}
                name={`last_service_values.${unit.value}`}
                type="number"
                label={`${unit.label} — ${t('maintenance.form.fields.lastServiceValue')}`}
                suffix={choice === 'distance' ? unitSuffix : undefined}
                description={t('maintenance.form.hints.lastServiceValue')}
              />
            ))}
          </div>
        ) : null}

        {mode === 'single' && singleUnitId ? (
          <FormInput
            control={form.control}
            name={`last_service_values.${singleUnitId}`}
            type="number"
            label={t('maintenance.form.fields.lastServiceValue')}
            suffix={choice === 'distance' ? unitSuffix : undefined}
            description={t('maintenance.form.hints.lastServiceValue')}
          />
        ) : null}

        <div className="grid grid-cols-3 gap-4">
          <FormInput
            control={form.control}
            name="interval_value"
            type="number"
            label={t('maintenance.form.fields.intervalValue')}
            required
            suffix={choice === 'distance' ? unitSuffix : undefined}
          />
          <FormSelect
            control={form.control}
            name="interval_unit_choice"
            label={t('maintenance.form.fields.intervalUnit')}
            required
            options={intervalChoiceOptions}
          />
          <FormInput
            control={form.control}
            name="reminder_before_value"
            type="number"
            label={t('maintenance.form.fields.reminderBefore')}
            required
            suffix={choice === 'distance' ? unitSuffix : undefined}
          />
        </div>

        <p className="text-body-sm text-neutral-500">
          {t('maintenance.form.hints.distanceUnit', { unit: unitLabel })}
        </p>

        <div className="grid grid-cols-2 gap-4">
          <FormSelect
            control={form.control}
            name="alert_type"
            label={t('maintenance.form.fields.alertType')}
            required
            options={alertTypeOptions}
          />
          <MultiSelect
            label={t('maintenance.form.fields.deliveryMethods')}
            required
            options={deliveryOptions}
            values={form.watch('delivery_methods')}
            onChange={(next) => form.setValue('delivery_methods', next, { shouldDirty: true })}
            error={form.formState.errors.delivery_methods?.message}
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <FormSelect
            control={form.control}
            name="status"
            label={t('maintenance.form.fields.status')}
            options={statusOptions}
          />
          <FormCheckbox
            control={form.control}
            name="notify_co_driver"
            label={t('maintenance.form.fields.notifyCoDriver')}
          />
        </div>

        <FormTextarea
          control={form.control}
          name="notes"
          label={t('maintenance.form.fields.notes')}
          maxLength={NOTES_MAX_LENGTH}
          rows={3}
        />
      </form>
    </Modal>
  );
}

export default MaintenanceFormModal;
