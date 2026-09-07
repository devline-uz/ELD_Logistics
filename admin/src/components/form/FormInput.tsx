/**
 * `react-hook-form` bilan bog'langan matn/raqam/parol inputi.
 *
 * `@/components/ui/Input` allaqachon label/hint/xato/`aria-*` bog'lanishini
 * o'zi boshqaradi (fe-design-system §6) — bu wrapper faqat `Controller`
 * orqali forma holatini shu propslarga ko'chiradi. Domenga xos bilim yo'q.
 */
import type { ComponentProps } from 'react';
import type { Control, FieldPath, FieldValues } from 'react-hook-form';
import { useController } from 'react-hook-form';

import { Input } from '@/components/ui/Input';

type InputOwnProps = ComponentProps<typeof Input>;

export interface FormInputProps<TFieldValues extends FieldValues> extends Pick<
  InputOwnProps,
  | 'type'
  | 'placeholder'
  | 'disabled'
  | 'autoComplete'
  | 'prefix'
  | 'suffix'
  | 'maxLength'
  | 'className'
> {
  name: FieldPath<TFieldValues>;
  control: Control<TFieldValues>;
  label: string;
  required?: boolean;
  /** `Input`ning `hint` propiga uzatiladi. */
  description?: string;
}

export function FormInput<TFieldValues extends FieldValues>({
  name,
  control,
  label,
  required,
  description,
  ...inputProps
}: FormInputProps<TFieldValues>) {
  const {
    field,
    fieldState: { error },
  } = useController({ name, control });

  return (
    <Input
      {...inputProps}
      name={field.name}
      ref={field.ref}
      value={field.value ?? ''}
      onChange={(event) => field.onChange(event.target.value)}
      onBlur={field.onBlur}
      label={label}
      required={required}
      hint={description}
      error={error?.message}
    />
  );
}
