import { forwardRef, useId, type InputHTMLAttributes, type ReactNode } from 'react';

export interface FormFieldProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'id'> {
  label: string;
  error?: string;
  /** Ikkinchi elementni (ko'z ikonkasi kabi) input yoniga qo'yish uchun. */
  suffix?: ReactNode;
}

/**
 * Auth formalari uchun umumiy maydon: label + input + xato matni.
 *
 * `aria-required` majburiy maydonlarda, `aria-invalid`/`aria-describedby` —
 * xato bo'lganda (fe-a11y). Dizayn tizimi hali yo'q — mavjud CSS
 * o'zgaruvchilaridan foydalaniladi (Bosqich 1 gacha).
 *
 * `forwardRef` **majburiy** — `react-hook-form`ning `register()` funksiyasi
 * qiymatni DOM node orqali (uncontrolled) o'qiydi; oddiy funksiya
 * komponentida `ref` yetib bormay, forma qiymati doim `undefined` bo'lib
 * qolardi.
 */
export const FormField = forwardRef<HTMLInputElement, FormFieldProps>(function FormField(
  { label, error, suffix, required, className, ...inputProps },
  ref,
) {
  const id = useId();
  const errorId = `${id}-error`;

  return (
    <div className="flex flex-col gap-1">
      <label className="text-sm font-medium text-neutral-800" htmlFor={id}>
        {label}
        {required ? <span aria-hidden="true"> *</span> : null}
      </label>
      <div className="relative flex items-center">
        <input
          ref={ref}
          id={id}
          aria-describedby={error ? errorId : undefined}
          aria-invalid={error ? true : undefined}
          aria-required={required}
          className={`w-full rounded border px-3 py-2 text-sm outline-none focus:ring-2 ${className ?? ''}`}
          required={required}
          style={{
            borderColor: error ? 'var(--color-error-base)' : 'var(--color-stroke)',
            backgroundColor: 'var(--color-surface)',
          }}
          {...inputProps}
        />
        {suffix}
      </div>
      {error ? (
        <p
          className="text-xs"
          id={errorId}
          role="alert"
          style={{ color: 'var(--color-error-dark)' }}
        >
          {error}
        </p>
      ) : null}
    </div>
  );
});

export default FormField;
