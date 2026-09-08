/**
 * `react-hook-form` bilan bog'langan textarea — belgilar hisoblagichi bilan
 * (masalan Notes ≤ 60). `@/components/ui/Textarea` o'zi label/hint/xato
 * bog'lanishini boshqaradi.
 */
import type { ComponentProps } from 'react';
import type { Control, FieldPath, FieldValues } from 'react-hook-form';
import { useController } from 'react-hook-form';

import { Textarea } from '@/components/ui/Textarea';

type TextareaOwnProps = ComponentProps<typeof Textarea>;

export interface FormTextareaProps<TFieldValues extends FieldValues> extends Pick<
  TextareaOwnProps,
  'placeholder' | 'disabled' | 'maxLength' | 'rows' | 'className'
> {
  name: FieldPath<TFieldValues>;
  control: Control<TFieldValues>;
  label: string;
  required?: boolean;
  description?: string;
}

export function FormTextarea<TFieldValues extends FieldValues>({
  name,
  control,
  label,
  required,
  description,
  ...textareaProps
}: FormTextareaProps<TFieldValues>) {
  const {
    field,
    fieldState: { error },
  } = useController({ name, control });

  return (
    <Textarea
      {...textareaProps}
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
