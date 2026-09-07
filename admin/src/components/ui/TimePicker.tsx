import { forwardRef, useId, useMemo } from 'react';
import type { ChangeEvent, KeyboardEvent } from 'react';

import { cn } from './cn';
import { useTranslation } from 'react-i18next';

export interface TimeValue {
  hours: number;
  minutes: number;
  seconds: number;
}

export interface TimePickerProps {
  value: TimeValue;
  onChange: (value: TimeValue) => void;
  label?: string;
  error?: string;
  hint?: string;
  required?: boolean;
  disabled?: boolean;
  /** Soniya bo'limini ko'rsatish (Insert duty status uchun default true). */
  showSeconds?: boolean;
  id?: string;
  name?: string;
  className?: string;
}

function clamp(n: number, min: number, max: number): number {
  if (Number.isNaN(n)) return min;
  return Math.min(Math.max(n, min), max);
}

function pad(n: number): string {
  return String(n).padStart(2, '0');
}

/**
 * `HH:mm:ss` vaqt kirish maydoni — Insert duty status kabi aniq vaqt
 * kiritilishi kerak bo'lgan formalar uchun.
 */
export const TimePicker = forwardRef<HTMLDivElement, TimePickerProps>(function TimePicker(
  {
    value,
    onChange,
    label,
    error,
    hint,
    required,
    disabled,
    showSeconds = true,
    id,
    name,
    className,
  },
  ref,
) {
  const { t } = useTranslation();
  const generatedId = useId();
  const fieldId = id ?? generatedId;
  const errorId = `${fieldId}-error`;
  const hintId = `${fieldId}-hint`;

  const describedBy =
    [error ? errorId : null, !error && hint ? hintId : null].filter(Boolean).join(' ') || undefined;

  const segments = useMemo(
    () => [
      { key: 'hours' as const, max: 23, labelKey: 'ui.form.time.hours' as const },
      { key: 'minutes' as const, max: 59, labelKey: 'ui.form.time.minutes' as const },
      ...(showSeconds
        ? [{ key: 'seconds' as const, max: 59, labelKey: 'ui.form.time.seconds' as const }]
        : []),
    ],
    [showSeconds],
  );

  const handleChange =
    (key: keyof TimeValue, max: number) => (event: ChangeEvent<HTMLInputElement>) => {
      const raw = event.target.value.replace(/\D/g, '').slice(0, 2);
      const next = raw === '' ? 0 : clamp(Number(raw), 0, max);
      onChange({ ...value, [key]: next });
    };

  const handleKeyDown =
    (key: keyof TimeValue, max: number) => (event: KeyboardEvent<HTMLInputElement>) => {
      if (event.key === 'ArrowUp') {
        event.preventDefault();
        onChange({ ...value, [key]: clamp(value[key] + 1, 0, max) });
      } else if (event.key === 'ArrowDown') {
        event.preventDefault();
        onChange({ ...value, [key]: clamp(value[key] - 1, 0, max) });
      }
    };

  return (
    <div className={cn('flex flex-col gap-1', className)} ref={ref}>
      {label ? (
        <span id={`${fieldId}-label`} className="text-body-sm font-medium text-neutral-700">
          {label}
          {required ? (
            <span aria-hidden="true" className="ml-0.5 text-error-dark">
              *
            </span>
          ) : null}
        </span>
      ) : null}

      {/* eslint-disable-next-line jsx-a11y/role-supports-aria-props -- aria-invalid/aria-required global ARIA 1.2 atributlari */}
      <div
        id={fieldId}
        role="group"
        aria-labelledby={label ? `${fieldId}-label` : undefined}
        aria-invalid={Boolean(error) || undefined}
        aria-required={required || undefined}
        aria-describedby={describedBy}
        className={cn(
          'flex h-10 w-fit items-center gap-1 rounded-md border bg-surface px-2',
          'focus-within:ring-2 focus-within:ring-primary focus-within:ring-offset-1',
          error ? 'border-error-base' : 'border-stroke',
          disabled && 'cursor-not-allowed bg-surface-muted opacity-60',
        )}
      >
        {segments.map((segment, index) => (
          <div key={segment.key} className="flex items-center">
            {index > 0 ? <span className="px-0.5 text-neutral-400">:</span> : null}
            <input
              name={name ? `${name}.${segment.key}` : undefined}
              inputMode="numeric"
              aria-label={t(segment.labelKey)}
              disabled={disabled}
              value={pad(value[segment.key])}
              onChange={handleChange(segment.key, segment.max)}
              onKeyDown={handleKeyDown(segment.key, segment.max)}
              maxLength={2}
              className="h-full w-6 bg-transparent text-center text-body text-neutral-800 outline-none disabled:cursor-not-allowed"
            />
          </div>
        ))}
      </div>

      {error ? (
        <p id={errorId} role="alert" className="text-body-sm text-error-dark">
          {error}
        </p>
      ) : hint ? (
        <p id={hintId} className="text-body-sm text-neutral-500">
          {hint}
        </p>
      ) : null}
    </div>
  );
});

export default TimePicker;
