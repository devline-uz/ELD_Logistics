import { forwardRef, useId } from 'react';
import type { InputHTMLAttributes } from 'react';
import { Check, Minus } from 'lucide-react';

import { cn } from './cn';
import { Icon } from './Icon';

export interface CheckboxProps extends Omit<
  InputHTMLAttributes<HTMLInputElement>,
  'type' | 'size'
> {
  label?: string;
  /** Tavsif satri (label ostida, kichikroq matn). */
  description?: string;
  error?: string;
  /** Ba'zi tanlangan / hech biri emas holati (masalan "Select all"). */
  indeterminate?: boolean;
}

export const Checkbox = forwardRef<HTMLInputElement, CheckboxProps>(function Checkbox(
  { label, description, error, indeterminate = false, id, className, disabled, ...rest },
  ref,
) {
  const generatedId = useId();
  const checkboxId = id ?? generatedId;
  const descId = description ? `${checkboxId}-desc` : undefined;
  const errorId = error ? `${checkboxId}-error` : undefined;

  return (
    <div className="flex flex-col gap-1">
      <label
        htmlFor={checkboxId}
        className={cn('flex items-start gap-2', disabled && 'opacity-60')}
      >
        <span className="relative mt-0.5 flex h-4 w-4 shrink-0 items-center justify-center">
          <input
            ref={(node) => {
              if (node) node.indeterminate = indeterminate;
              if (typeof ref === 'function') ref(node);
              else if (ref) ref.current = node;
            }}
            type="checkbox"
            id={checkboxId}
            disabled={disabled}
            aria-label={label}
            aria-invalid={Boolean(error) || undefined}
            aria-describedby={cn(descId, errorId).trim() || undefined}
            className={cn(
              'peer h-4 w-4 shrink-0 appearance-none rounded-sm border border-stroke bg-surface',
              'checked:border-primary checked:bg-primary',
              'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-1',
              'disabled:cursor-not-allowed',
              error && 'border-error-base',
              className,
            )}
            {...rest}
          />
          <span className="pointer-events-none absolute inset-0 hidden items-center justify-center text-white peer-checked:flex">
            <Icon icon={indeterminate ? Minus : Check} size={12} />
          </span>
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

export default Checkbox;
