/**
 * `react-hook-form` bilan bog'langan bitta tanlovli select (combobox).
 *
 * `@/components/ui/Select` allaqachon label/hint/xato bog'lanishini o'zi
 * boshqaradi — bu wrapper faqat `Controller` orqali qiymatni ko'chiradi.
 */
import type { Control, FieldPath, FieldValues } from 'react-hook-form';
import { useController } from 'react-hook-form';

import { Select, type SelectOption } from '@/components/ui/Select';

export interface FormSelectProps<TFieldValues extends FieldValues, TValue extends string = string> {
  name: FieldPath<TFieldValues>;
  control: Control<TFieldValues>;
  label: string;
  options: readonly SelectOption<TValue>[];
  required?: boolean;
  description?: string;
  placeholder?: string;
  disabled?: boolean;
  searchable?: boolean;
  clearable?: boolean;
  loading?: boolean;
  className?: string;
}

export function FormSelect<TFieldValues extends FieldValues, TValue extends string = string>({
  name,
  control,
  label,
  options,
  required,
  description,
  placeholder,
  disabled,
  searchable,
  clearable,
  loading,
  className,
}: FormSelectProps<TFieldValues, TValue>) {
  const {
    field,
    fieldState: { error },
  } = useController({ name, control });

  return (
    <Select
      name={field.name}
      value={field.value ?? null}
      onChange={(value) => field.onChange(value)}
      options={options}
      label={label}
      required={required}
      hint={description}
      placeholder={placeholder}
      disabled={disabled}
      searchable={searchable}
      clearable={clearable}
      loading={loading}
      className={className}
      error={error?.message}
    />
  );
}
