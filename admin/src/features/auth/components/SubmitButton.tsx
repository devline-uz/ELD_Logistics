import type { ButtonHTMLAttributes } from 'react';

export interface SubmitButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  loading?: boolean;
}

/** Auth formalarining asosiy tugmasi — yuklanishda `aria-busy` + spinner (fe-screens §6). */
export function SubmitButton({ loading, disabled, children, ...rest }: SubmitButtonProps) {
  return (
    <button
      aria-busy={loading || undefined}
      className="w-full rounded px-4 py-2 text-sm font-semibold text-white transition-opacity disabled:cursor-not-allowed disabled:opacity-60"
      disabled={loading || disabled}
      style={{ backgroundColor: 'var(--color-primary)' }}
      type="submit"
      {...rest}
    >
      {loading ? (
        <span className="inline-flex items-center gap-2">
          <span
            aria-hidden="true"
            className="h-3.5 w-3.5 animate-spin rounded-full border-2 border-white border-t-transparent"
          />
          {children}
        </span>
      ) : (
        children
      )}
    </button>
  );
}

export default SubmitButton;
