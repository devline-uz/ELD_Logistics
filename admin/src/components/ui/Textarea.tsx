import { forwardRef, useId } from 'react';
import type { TextareaHTMLAttributes } from 'react';

import { cn } from './cn';
import { useTranslation } from 'react-i18next';

export interface TextareaProps extends TextareaHTMLAttributes<HTMLTextAreaElement> {
  label?: string;
  error?: string;
  hint?: string;
  containerClassName?: string;
}

/**
 * Ko'p qatorli matn maydoni. `maxLength` berilsa belgilar hisoblagichi
 * ko'rsatiladi (masalan Notes ≤ 60).
 */
export const Textarea = forwardRef<HTMLTextAreaElement, TextareaProps>(function Textarea(
  {
    label,
    error,
    hint,
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
    rows = 3,
    ...rest
  },
  ref,
) {
  const { t } = useTranslation();
  const generatedId = useId();
  const textareaId = id ?? generatedId;
  const errorId = `${textareaId}-error`;
  const hintId = `${textareaId}-hint`;
  const counterId = `${textareaId}-counter`;

  const describedBy =
    [error ? errorId : null, !error && hint ? hintId : null, maxLength ? counterId : null]
      .filter(Boolean)
      .join(' ') || undefined;

  const currentLength = typeof value === 'string' ? value.length : 0;

  return (
    <div className={cn('flex flex-col gap-1', containerClassName)}>
      {label ? (
        <label htmlFor={textareaId} className="text-body-sm font-medium text-neutral-700">
          {label}
          {required ? (
            <span aria-hidden="true" className="ml-0.5 text-error-dark">
              *
            </span>
          ) : null}
        </label>
      ) : null}

      <textarea
        ref={ref}
        id={textareaId}
        name={name}
        value={value}
        onChange={onChange}
        disabled={disabled}
        readOnly={readOnly}
        required={required}
        maxLength={maxLength}
        rows={rows}
        aria-invalid={Boolean(error) || undefined}
        aria-required={required || undefined}
        aria-describedby={describedBy}
        className={cn(
          'w-full rounded-md border bg-surface px-3 py-2 text-body text-neutral-800 outline-none',
          'placeholder:text-neutral-400',
          'focus:ring-2 focus:ring-primary focus:ring-offset-1',
          error ? 'border-error-base' : 'border-stroke',
          disabled && 'cursor-not-allowed bg-surface-muted opacity-60',
          className,
        )}
        {...rest}
      />

      <div className="flex items-start justify-between gap-2">
        <div className="flex-1">
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
        {maxLength ? (
          <p id={counterId} className="shrink-0 text-body-sm text-neutral-600">
            {t('ui.form.input.charactersRemaining', {
              count: Math.max(maxLength - currentLength, 0),
            })}
          </p>
        ) : null}
      </div>
    </div>
  );
});

export default Textarea;
