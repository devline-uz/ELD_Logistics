import { forwardRef, useId } from 'react';
import type { InputHTMLAttributes } from 'react';

import { cn } from './cn';

export interface SwitchProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'type' | 'size'> {
  label?: string;
  description?: string;
}

/**
 * Boolean holat almashtirgichi. Semantik jihatdan `role="switch"` bilan
 * `<input type="checkbox">` ustiga qurilgan.
 */
export const Switch = forwardRef<HTMLInputElement, SwitchProps>(function Switch(
  { label, description, id, className, disabled, ...rest },
  ref,
) {
  const generatedId = useId();
  const switchId = id ?? generatedId;
  const descId = description ? `${switchId}-desc` : undefined;

  return (
    <label htmlFor={switchId} className={cn('flex items-start gap-3', disabled && 'opacity-60')}>
      <span className="relative mt-0.5 inline-flex h-5 w-9 shrink-0 items-center">
        <input
          ref={ref}
          type="checkbox"
          role="switch"
          id={switchId}
          disabled={disabled}
          aria-label={label}
          aria-describedby={descId}
          className={cn(
            'peer h-5 w-9 shrink-0 appearance-none rounded-full bg-neutral-300 transition-colors',
            'checked:bg-primary',
            'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-1',
            'disabled:cursor-not-allowed',
            className,
          )}
          {...rest}
        />
        <span className="pointer-events-none absolute left-0.5 h-4 w-4 rounded-full bg-white transition-transform peer-checked:translate-x-4" />
      </span>
      {(label ?? description) ? (
        <span className="flex flex-col">
          {label ? <span className="text-body text-neutral-800">{label}</span> : null}
          {description ? (
            <span id={descId} className="text-body-sm text-neutral-500">
              {description}
            </span>
          ) : null}
        </span>
      ) : null}
    </label>
  );
});

export default Switch;
