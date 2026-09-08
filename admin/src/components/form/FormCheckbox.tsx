/**
 * `react-hook-form` bilan bog'langan checkbox. `@/components/ui/Checkbox`
 * o'zi label/description/xato bog'lanishini boshqaradi.
 */
import type { Control, FieldPath, FieldValues } from 'react-hook-form';
import { useController } from 'react-hook-form';

import { Checkbox } from '@/components/ui/Checkbox';

export interface FormCheckboxProps<TFieldValues extends FieldValues> {
  name: FieldPath<TFieldValues>;
  control: Control<TFieldValues>;
  label: string;
  description?: string;
  disabled?: boolean;
  className?: string;
}

export function FormCheckbox<TFieldValues extends FieldValues>({
  name,
  control,
  label,
  description,
  disabled,
  className,
}: FormCheckboxProps<TFieldValues>) {
  const {
    field,
    fieldState: { error },
  } = useController({ name, control });

  return (
    <Checkbox
      name={field.name}
      ref={field.ref}
      checked={Boolean(field.value)}
      onChange={(event) => field.onChange(event.target.checked)}
      onBlur={field.onBlur}
      label={label}
      description={description}
      disabled={disabled}
      className={className}
      error={error?.message}
    />
  );
}
