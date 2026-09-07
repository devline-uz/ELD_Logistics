/**
 * Forma maydoni konteyneri — label, majburiylik belgisi, tavsif va xato
 * matnini bir joyga yig'adi va a11y bog'lanishini (`aria-describedby`,
 * `aria-invalid`) ta'minlaydi (fe-a11y §2, fe-screens §2).
 *
 * Domenga xos bilim yo'q: `htmlFor`/`id` chaqiruvchi tomonidan beriladi,
 * `FormField` faqat joylashuv va ARIA simini quradi. `FormInput`/`FormSelect`/
 * boshqalar shu komponent ustiga quriladi.
 */
import type { ReactNode } from 'react';
import { useId } from 'react';

export interface FormFieldProps {
  /** Maydon uchun label matni (allaqachon tarjima qilingan). */
  label: ReactNode;
  /** `<label htmlFor>` va ichki inputga uzatiladigan id. Berilmasa avtomatik. */
  id?: string;
  /** Majburiy maydon — label yonida `*` va `aria-required` ko'rsatiladi. */
  required?: boolean;
  /** Label ostidagi yordamchi matn. */
  description?: ReactNode;
  /** Server yoki client validatsiya xatosi. Bo'lsa qizil matn + `aria-invalid`. */
  error?: string;
  /** Ichki input/select/textarea — render-prop orqali `id`/`aria-*` oladi. */
  children: (bindings: {
    id: string;
    'aria-describedby': string | undefined;
    'aria-invalid': boolean;
    'aria-required': boolean;
  }) => ReactNode;
  className?: string;
}

/** `FormField` bolasiga uzatiladigan ARIA bog'lanishi. Testlarda ham qayta ishlatiladi. */
export function useFormFieldBindings(
  id: string,
  { error, description, required }: Pick<FormFieldProps, 'error' | 'description' | 'required'>,
) {
  const describedBy = [error ? `${id}-error` : null, description ? `${id}-description` : null]
    .filter(Boolean)
    .join(' ');

  return {
    id,
    'aria-describedby': describedBy.length > 0 ? describedBy : undefined,
    'aria-invalid': Boolean(error),
    'aria-required': Boolean(required),
  };
}

export function FormField({
  label,
  id,
  required,
  description,
  error,
  children,
  className,
}: FormFieldProps) {
  const generatedId = useId();
  const fieldId = id ?? generatedId;
  const bindings = useFormFieldBindings(fieldId, { error, description, required });

  return (
    <div className={className ? `flex flex-col gap-1 ${className}` : 'flex flex-col gap-1'}>
      <label htmlFor={fieldId} className="text-body font-medium text-neutral-700">
        {label}
        {required ? (
          <span className="ml-1 text-error-base" aria-hidden="true">
            *
          </span>
        ) : null}
      </label>

      {children(bindings)}

      {description ? (
        <p id={`${fieldId}-description`} className="text-body-sm text-neutral-500">
          {description}
        </p>
      ) : null}

      {error ? (
        <p id={`${fieldId}-error`} role="alert" className="text-body-sm text-error-base">
          {error}
        </p>
      ) : null}
    </div>
  );
}
