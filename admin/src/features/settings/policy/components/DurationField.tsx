/**
 * `HH:MM` kirish maydoni — HOS Policy vaqt parametrlari uchun (8.4, F146).
 *
 * `components/ui/TimePicker` dan ataylab foydalanilmaydi: u kun ichidagi
 * vaqt uchun mo'ljallangan va soatni 0–23 bilan cheklaydi, HOS parametrlari
 * esa (masalan 8 kunlik sikl — 70 soat) bu chegaradan oshadi.
 */
import { useId } from 'react';
import { useTranslation } from 'react-i18next';

import { hmToMinutes, minutesToHm } from '../lib/duration';

export interface DurationFieldProps {
  label: string;
  /** Daqiqada — sof qiymat, `HH:MM` ga aylantirish shu komponent ichida. */
  value: number;
  onChange: (minutesValue: number) => void;
  error?: string;
  hint?: string;
  required?: boolean;
  disabled?: boolean;
  id?: string;
}

export function DurationField({
  label,
  value,
  onChange,
  error,
  hint,
  required,
  disabled,
  id,
}: DurationFieldProps) {
  const { t } = useTranslation();
  const generatedId = useId();
  const fieldId = id ?? generatedId;
  const errorId = `${fieldId}-error`;
  const hintId = `${fieldId}-hint`;
  const { hours, minutes } = minutesToHm(value);

  const describedBy =
    [error ? errorId : null, !error && hint ? hintId : null].filter(Boolean).join(' ') || undefined;

  const handleHoursChange = (raw: string) => {
    const parsed = raw === '' ? 0 : Number(raw.replace(/\D/g, ''));
    onChange(hmToMinutes({ hours: Number.isFinite(parsed) ? parsed : 0, minutes }));
  };

  const handleMinutesChange = (raw: string) => {
    const digits = raw.replace(/\D/g, '').slice(0, 2);
    const parsed = digits === '' ? 0 : Math.min(59, Number(digits));
    onChange(hmToMinutes({ hours, minutes: Number.isFinite(parsed) ? parsed : 0 }));
  };

  return (
    <div className="flex flex-col gap-1">
      <span id={`${fieldId}-label`} className="text-body-sm font-medium text-neutral-700">
        {label}
        {required ? (
          <span aria-hidden="true" className="ml-0.5 text-error-dark">
            *
          </span>
        ) : null}
      </span>
      {/* eslint-disable-next-line jsx-a11y/role-supports-aria-props -- aria-invalid/aria-required global ARIA 1.2 atributlari */}
      <div
        id={fieldId}
        role="group"
        aria-labelledby={`${fieldId}-label`}
        aria-invalid={Boolean(error) || undefined}
        aria-required={required || undefined}
        aria-describedby={describedBy}
        className={`flex h-10 w-32 items-center gap-1 rounded-md border bg-surface px-2 focus-within:ring-2 focus-within:ring-primary focus-within:ring-offset-1 ${
          error ? 'border-error-base' : 'border-stroke'
        } ${disabled ? 'cursor-not-allowed bg-surface-muted opacity-60' : ''}`}
      >
        <input
          inputMode="numeric"
          aria-label={t('ui.form.time.hours')}
          disabled={disabled}
          value={String(hours).padStart(2, '0')}
          onChange={(event) => handleHoursChange(event.target.value)}
          maxLength={3}
          className="h-full w-10 bg-transparent text-center text-body text-neutral-800 outline-none disabled:cursor-not-allowed"
        />
        <span className="text-neutral-400">:</span>
        <input
          inputMode="numeric"
          aria-label={t('ui.form.time.minutes')}
          disabled={disabled}
          value={String(minutes).padStart(2, '0')}
          onChange={(event) => handleMinutesChange(event.target.value)}
          maxLength={2}
          className="h-full w-8 bg-transparent text-center text-body text-neutral-800 outline-none disabled:cursor-not-allowed"
        />
      </div>
      {error ? (
        <p id={errorId} role="alert" className="text-body-sm text-error-dark">
          {error}
        </p>
      ) : hint ? (
        <p id={hintId} className="text-body-sm text-neutral-600">
          {hint}
        </p>
      ) : null}
    </div>
  );
}

export default DurationField;
