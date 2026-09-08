import { forwardRef, useId } from 'react';
import type { InputHTMLAttributes, ReactNode } from 'react';

import { cn } from './cn';
import { useTranslation } from 'react-i18next';

export interface InputProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'prefix'> {
  label?: string;
  error?: string;
  hint?: string;
  prefix?: ReactNode;
  suffix?: ReactNode;
  containerClassName?: string;
}

/**
 * Matnli kirish maydoni. `maxLength` berilsa belgilar hisoblagichi ko'rsatiladi.
 * Xato holatida `aria-invalid` + `aria-describedby` bilan xato matni bog'lanadi.
 */
export const Input = forwardRef<HTMLInputElement, InputProps>(function Input(
  {
    label,
    error,
    hint,
    prefix,
    suffix,
    required,
    disabled,
    readOnly,
    maxLength,
    id,
    name,
    className,
    containerClassName,
    value,
    onChange,
    ...rest
  },
  ref,
) {
  const { t } = useTranslation();
  const generatedId = useId();
  const inputId = id ?? generatedId;
  const errorId = `${inputId}-error`;
  const hintId = `${inputId}-hint`;
  const counterId = `${inputId}-counter`;

  const describedBy =
    [error ? errorId : null, !error && hint ? hintId : null, maxLength ? counterId : null]
      .filter(Boolean)
      .join(' ') || undefined;

  const currentLength = typeof value === 'string' ? value.length : 0;

  return (
    <div className={cn('flex flex-col gap-1', containerClassName)}>
      {label ? (
        <label htmlFor={inputId} className="text-body-sm font-medium text-neutral-700">
          {label}
          {required ? (
            <span aria-hidden="true" className="ml-0.5 text-error-dark">
              *
            </span>
          ) : null}
        </label>
      ) : null}

      <div
        className={cn(
          'flex h-10 items-center gap-2 rounded-md border bg-surface px-3',
          'focus-within:ring-2 focus-within:ring-primary focus-within:ring-offset-1',
          error ? 'border-error-base' : 'border-stroke',
          disabled && 'cursor-not-allowed bg-surface-muted opacity-60',
        )}
      >
        {prefix ? (
          <span className="flex shrink-0 items-center text-neutral-500">{prefix}</span>
        ) : null}
        <input
          ref={ref}
          id={inputId}
          name={name}
          value={value}
          onChange={onChange}
          disabled={disabled}
          readOnly={readOnly}
          required={required}
          maxLength={maxLength}
          aria-invalid={Boolean(error) || undefined}
          aria-required={required || undefined}
          aria-describedby={describedBy}
          className={cn(
            'h-full w-full bg-transparent text-body text-neutral-800 outline-none placeholder:text-neutral-400',
            'disabled:cursor-not-allowed',
            className,
          )}
          {...rest}
        />
        {suffix ? (
          <span className="flex shrink-0 items-center text-neutral-500">{suffix}</span>
        ) : null}
      </div>

      <div className="flex items-start justify-between gap-2">
        <div className="flex-1">
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
        {maxLength ? (
          <p id={counterId} className="shrink-0 text-body-sm text-neutral-400">
            {t('ui.form.input.charactersRemaining', {
              count: Math.max(maxLength - currentLength, 0),
            })}
          </p>
        ) : null}
      </div>
    </div>
  );
});

export default Input;
