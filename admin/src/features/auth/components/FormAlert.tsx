export interface FormAlertProps {
  message: string;
  variant?: 'error' | 'info';
}

/** Forma tepasidagi umumiy xato/ma'lumot satri (fe-screens §2 — noma'lum `field`). */
export function FormAlert({ message, variant = 'error' }: FormAlertProps) {
  const isError = variant === 'error';

  return (
    <div
      aria-live="assertive"
      className="rounded px-3 py-2 text-sm"
      role="alert"
      style={{
        backgroundColor: isError ? 'var(--color-error-bg)' : 'var(--color-warning-bg)',
        color: isError ? 'var(--color-error-dark)' : 'var(--color-warning-dark)',
      }}
    >
      {message}
    </div>
  );
}

export default FormAlert;
