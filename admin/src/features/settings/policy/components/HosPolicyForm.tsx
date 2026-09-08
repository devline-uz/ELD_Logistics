/**
 * HOS Policy — 18 maydonli forma (8.4, §7.13.3). 15 MUST + `short_haul_exception`/
 * `adverse_conditions_extension_min` [MAY] + backend'dagi qo'shimcha
 * `sleeper_berth_available` (TZ'ning 15 parametr ro'yxatida yo'q — D45,
 * `docs/tz/16-17-registry-open-questions.md`; forma uni ko'rsatadi, chunki
 * backend haqiqat manbai va `POST /company/hos-policy` uni qabul qiladi).
 */
import { Controller, type Control, type FieldErrors } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import { Checkbox } from '@/components/ui/Checkbox';
import { Input } from '@/components/ui/Input';
import { Switch } from '@/components/ui/Switch';
import { useUnitSystem } from '@/hooks/useUnitSystem';
import { convertSpeed } from '@/lib/units';

import { BREAK_QUALIFYING_STATUSES } from '../lib/schema';
import type { HosPolicyFormValues } from '../lib/schema';
import { DurationField } from './DurationField';

export interface HosPolicyFormProps {
  control: Control<HosPolicyFormValues>;
  errors: FieldErrors<HosPolicyFormValues>;
  disabled?: boolean;
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="flex flex-col gap-4 rounded-lg border border-stroke bg-surface p-4">
      <h3 className="text-body-lg font-semibold text-neutral-900">{title}</h3>
      <div className="flex flex-wrap gap-6">{children}</div>
    </section>
  );
}

export function HosPolicyForm({ control, errors, disabled }: HosPolicyFormProps) {
  const { t } = useTranslation();
  const { unitSystem } = useUnitSystem();
  const speedLabel =
    unitSystem === 'imperial' ? t('settings.hos.units.mph') : t('settings.hos.units.kmh');

  const errAt = (key: string): string | undefined => {
    const parts = key.split('.');
    let node: unknown = errors;
    for (const part of parts) {
      if (typeof node !== 'object' || node === null) return undefined;
      node = (node as Record<string, unknown>)[part];
    }
    const message =
      typeof node === 'object' && node !== null && 'message' in node
        ? (node as { message?: unknown }).message
        : undefined;
    return typeof message === 'string' ? t(message) : undefined;
  };

  return (
    <div className="flex flex-col gap-4">
      <Section title={t('settings.hos.form.sections.driving')}>
        <Controller
          control={control}
          name="drive_limit_min"
          render={({ field }) => (
            <DurationField
              label={t('settings.hos.fields.driveLimit')}
              value={field.value}
              onChange={field.onChange}
              error={errAt('drive_limit_min')}
              disabled={disabled}
              required
            />
          )}
        />
        <Controller
          control={control}
          name="shift_window_min"
          render={({ field }) => (
            <DurationField
              label={t('settings.hos.fields.shiftWindow')}
              value={field.value}
              onChange={field.onChange}
              error={errAt('shift_window_min')}
              disabled={disabled}
              required
            />
          )}
        />
        <Controller
          control={control}
          name="daily_rest_min"
          render={({ field }) => (
            <DurationField
              label={t('settings.hos.fields.dailyRest')}
              value={field.value}
              onChange={field.onChange}
              error={errAt('daily_rest_min')}
              disabled={disabled}
              required
            />
          )}
        />
      </Section>

      <Section title={t('settings.hos.form.sections.breaks')}>
        <Controller
          control={control}
          name="break_required_after_drive_min"
          render={({ field }) => (
            <DurationField
              label={t('settings.hos.fields.breakRequiredAfter')}
              value={field.value}
              onChange={field.onChange}
              error={errAt('break_required_after_drive_min')}
              disabled={disabled}
              required
            />
          )}
        />
        <Controller
          control={control}
          name="break_duration_min"
          render={({ field }) => (
            <DurationField
              label={t('settings.hos.fields.breakDuration')}
              value={field.value}
              onChange={field.onChange}
              error={errAt('break_duration_min')}
              disabled={disabled}
              required
            />
          )}
        />
        <Controller
          control={control}
          name="break_qualifying_statuses"
          render={({ field }) => (
            <fieldset className="flex flex-col gap-2">
              <legend className="text-body-sm font-medium text-neutral-700">
                {t('settings.hos.fields.breakQualifyingStatuses')}
                <span aria-hidden="true" className="ml-0.5 text-error-dark">
                  *
                </span>
              </legend>
              <div className="flex flex-wrap gap-3">
                {BREAK_QUALIFYING_STATUSES.map((status) => (
                  <Checkbox
                    key={status}
                    label={t(`enums.duty_status.${status}`)}
                    disabled={disabled}
                    checked={field.value.includes(status)}
                    onChange={(event) => {
                      const next = event.target.checked
                        ? [...field.value, status]
                        : field.value.filter((item) => item !== status);
                      field.onChange(next);
                    }}
                  />
                ))}
              </div>
              {errAt('break_qualifying_statuses') ? (
                <p role="alert" className="text-body-sm text-error-dark">
                  {errAt('break_qualifying_statuses')}
                </p>
              ) : null}
            </fieldset>
          )}
        />
      </Section>

      <Section title={t('settings.hos.form.sections.cycle')}>
        <Controller
          control={control}
          name="cycle_limit_min"
          render={({ field }) => (
            <DurationField
              label={t('settings.hos.fields.cycleLimit')}
              value={field.value}
              onChange={field.onChange}
              error={errAt('cycle_limit_min')}
              disabled={disabled}
              required
            />
          )}
        />
        <Controller
          control={control}
          name="cycle_days"
          render={({ field }) => (
            <Input
              type="number"
              min={1}
              max={14}
              label={t('settings.hos.fields.cycleDays')}
              value={field.value}
              onChange={(event) => field.onChange(Number(event.target.value))}
              error={errAt('cycle_days')}
              disabled={disabled}
              required
              containerClassName="w-32"
            />
          )}
        />
        <Controller
          control={control}
          name="cycle_restart_min"
          render={({ field }) => (
            <DurationField
              label={t('settings.hos.fields.cycleRestart')}
              value={field.value}
              onChange={field.onChange}
              error={errAt('cycle_restart_min')}
              disabled={disabled}
              required
            />
          )}
        />
      </Section>

      <Section title={t('settings.hos.form.sections.personalUse')}>
        <Controller
          control={control}
          name="allow_pc"
          render={({ field }) => (
            <Switch
              label={t('settings.hos.fields.allowPc')}
              description={t('settings.hos.fields.allowPcHint')}
              checked={field.value}
              onChange={(event) => field.onChange(event.target.checked)}
              disabled={disabled}
            />
          )}
        />
        <Controller
          control={control}
          name="allow_ym"
          render={({ field }) => (
            <Switch
              label={t('settings.hos.fields.allowYm')}
              description={t('settings.hos.fields.allowYmHint')}
              checked={field.value}
              onChange={(event) => field.onChange(event.target.checked)}
              disabled={disabled}
            />
          )}
        />
        <Controller
          control={control}
          name="ym_max_speed_kmh"
          render={({ field }) => (
            <Input
              type="number"
              min={0}
              label={t('settings.hos.fields.ymMaxSpeed')}
              suffix={speedLabel}
              value={Math.round(convertSpeed(field.value, unitSystem))}
              onChange={(event) => {
                const entered = Number(event.target.value);
                const kmh = unitSystem === 'imperial' ? entered * 1.609344 : entered;
                field.onChange(Number.isFinite(kmh) ? kmh : 0);
              }}
              error={errAt('ym_max_speed_kmh')}
              disabled={disabled}
              containerClassName="w-40"
            />
          )}
        />
        <Controller
          control={control}
          name="motion_threshold_kmh"
          render={({ field }) => (
            <Input
              type="number"
              min={0}
              label={t('settings.hos.fields.motionThreshold')}
              suffix={speedLabel}
              value={Math.round(convertSpeed(field.value, unitSystem))}
              onChange={(event) => {
                const entered = Number(event.target.value);
                const kmh = unitSystem === 'imperial' ? entered * 1.609344 : entered;
                field.onChange(Number.isFinite(kmh) ? kmh : 0);
              }}
              error={errAt('motion_threshold_kmh')}
              disabled={disabled}
              containerClassName="w-40"
            />
          )}
        />
      </Section>

      <Section title={t('settings.hos.form.sections.sleeper')}>
        <Controller
          control={control}
          name="sleeper_split_enabled"
          render={({ field }) => (
            <Switch
              label={t('settings.hos.fields.sleeperSplitEnabled')}
              checked={field.value}
              onChange={(event) => field.onChange(event.target.checked)}
              disabled={disabled}
            />
          )}
        />
        <Controller
          control={control}
          name="sleeper_berth_available"
          render={({ field }) => (
            <Switch
              label={t('settings.hos.fields.sleeperBerthAvailable')}
              checked={field.value}
              onChange={(event) => field.onChange(event.target.checked)}
              disabled={disabled}
            />
          )}
        />
      </Section>

      <Section title={t('settings.hos.form.sections.warnings')}>
        <Controller
          control={control}
          name="warning_thresholds.drive"
          render={({ field }) => (
            <DurationField
              label={t('settings.hos.fields.warningDrive')}
              value={field.value}
              onChange={field.onChange}
              error={errAt('warning_thresholds.drive')}
              disabled={disabled}
            />
          )}
        />
        <Controller
          control={control}
          name="warning_thresholds.shift"
          render={({ field }) => (
            <DurationField
              label={t('settings.hos.fields.warningShift')}
              value={field.value}
              onChange={field.onChange}
              error={errAt('warning_thresholds.shift')}
              disabled={disabled}
            />
          )}
        />
        <Controller
          control={control}
          name="warning_thresholds.break"
          render={({ field }) => (
            <DurationField
              label={t('settings.hos.fields.warningBreak')}
              value={field.value}
              onChange={field.onChange}
              error={errAt('warning_thresholds.break')}
              disabled={disabled}
            />
          )}
        />
        <Controller
          control={control}
          name="warning_thresholds.cycle"
          render={({ field }) => (
            <DurationField
              label={t('settings.hos.fields.warningCycle')}
              value={field.value}
              onChange={field.onChange}
              error={errAt('warning_thresholds.cycle')}
              disabled={disabled}
            />
          )}
        />
      </Section>

      <Section title={t('settings.hos.form.sections.exceptions')}>
        <Controller
          control={control}
          name="short_haul_exception"
          render={({ field }) => (
            <Switch
              label={t('settings.hos.fields.shortHaulException')}
              checked={field.value}
              onChange={(event) => field.onChange(event.target.checked)}
              disabled={disabled}
            />
          )}
        />
        <Controller
          control={control}
          name="adverse_conditions_extension_min"
          render={({ field }) => (
            <DurationField
              label={t('settings.hos.fields.adverseConditionsExtension')}
              value={field.value}
              onChange={field.onChange}
              error={errAt('adverse_conditions_extension_min')}
              disabled={disabled}
            />
          )}
        />
      </Section>
    </div>
  );
}

export default HosPolicyForm;
