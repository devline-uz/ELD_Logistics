import type { ReactNode } from 'react';

export type AlertVariant = 'error' | 'warning' | 'info' | 'success';

export interface AlertProps {
  message: ReactNode;
  variant?: AlertVariant;
  className?: string;
}

/**
 * Forma tepasidagi (yoki sahifa ichidagi) umumiy inline ogohlantirish satri
 * (fe-screens §2 — noma'lum server `field` xatosi, sessiya tugashi haqida
 * xabar va h.k.). Domenni bilmaydi — faqat `message` + `variant`.
 *
 * `error` — foydalanuvchi e'tiborini darhol talab qiladi: `role="alert"` +
 * `aria-live="assertive"`. Qolgan variantlar — `role="status"` +
 * `aria-live="polite"` (fe-a11y: assertive faqat haqiqiy xatoda).
 */
const VARIANT_CLASSES: Record<AlertVariant, string> = {
  error: 'bg-error-bg text-error-dark',
  warning: 'bg-warning-bg text-warning-dark',
  info: 'bg-light text-decorative-blue',
  success: 'bg-success-bg text-success-dark',
};

export function Alert({ message, variant = 'error', className }: AlertProps) {
  const isError = variant === 'error';

  const classes = ['rounded-md px-3 py-2 text-body-sm', VARIANT_CLASSES[variant], className]
    .filter(Boolean)
    .join(' ');

  return (
    <div
      role={isError ? 'alert' : 'status'}
      aria-live={isError ? 'assertive' : 'polite'}
      className={classes}
    >
      {message}
    </div>
  );
}

export default Alert;
