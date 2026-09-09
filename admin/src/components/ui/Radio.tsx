import { forwardRef, useId } from 'react';
import type { InputHTMLAttributes } from 'react';

import { cn } from './cn';

export interface RadioProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'type' | 'size'> {
  label?: string;
  description?: string;
  error?: string;
}

export const Radio = forwardRef<HTMLInputElement, RadioProps>(function Radio(
  { label, description, error, id, className, disabled, ...rest },
  ref,
) {
  const generatedId = useId();
  const radioId = id ?? generatedId;
  const descId = description ? `${radioId}-desc` : undefined;
  const errorId = error ? `${radioId}-error` : undefined;

  return (
    <div className="flex flex-col gap-1">
      <label htmlFor={radioId} className={cn('flex items-start gap-2', disabled && 'opacity-60')}>
        <span className="relative mt-0.5 flex h-4 w-4 shrink-0 items-center justify-center">
          {/* eslint-disable-next-line jsx-a11y/role-supports-aria-props -- aria-invalid global ARIA 1.2 atributi, plagin ro'yxati eski (ARIA 1.1) */}
          <input
            ref={ref}
            type="radio"
            id={radioId}
            disabled={disabled}
            aria-label={label}
            aria-invalid={Boolean(error) || undefined}
            aria-describedby={cn(descId, errorId).trim() || undefined}
            className={cn(
              'peer h-4 w-4 shrink-0 appearance-none rounded-full border border-stroke bg-surface',
              'checked:border-primary',
              'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-1',
              'disabled:cursor-not-allowed',
              error && 'border-error-base',
              className,
            )}
            {...rest}
          />
          <span className="pointer-events-none absolute h-2 w-2 scale-0 rounded-full bg-primary transition-transform peer-checked:scale-100" />
        </span>
        {(label ?? description) ? (
          <span className="flex flex-col">
            {label ? <span className="text-body text-neutral-800">{label}</span> : null}
            {description ? (
              <span id={descId} className="text-body-sm text-neutral-600">
                {description}
              </span>
            ) : null}
          </span>
        ) : null}
      </label>
      {error ? (
        <p id={errorId} role="alert" className="text-body-sm text-error-dark">
          {error}
        </p>
      ) : null}
    </div>
  );
});

export default Radio;
