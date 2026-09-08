/**
 * `react-hook-form` bilan bog'langan bitta sana tanlagich.
 *
 * `@/components/ui/DatePicker` label/hint/xato bog'lanishini o'zi boshqaradi;
 * qiymati `Date | null` (ekranga chiqarish formati `displayFormat` orqali
 * komponent ichida hal qilinadi). Bu wrapper faqat qiymatni ko'chiradi.
 */
import type { Control, FieldPath, FieldValues } from 'react-hook-form';
import { useController } from 'react-hook-form';

import { DatePicker } from '@/components/ui/DatePicker';

export interface FormDatePickerProps<TFieldValues extends FieldValues> {
  name: FieldPath<TFieldValues>;
  control: Control<TFieldValues>;
  label: string;
  required?: boolean;
  description?: string;
  placeholder?: string;
  disabled?: boolean;
  minDate?: Date;
  maxDate?: Date;
  className?: string;
}

export function FormDatePicker<TFieldValues extends FieldValues>({
  name,
  control,
  label,
  required,
  description,
  placeholder,
  disabled,
  minDate,
  maxDate,
  className,
}: FormDatePickerProps<TFieldValues>) {
  const {
    field,
    fieldState: { error },
  } = useController({ name, control });

  return (
    <DatePicker
      name={field.name}
      value={field.value ?? null}
      onChange={(value) => field.onChange(value)}
      label={label}
      required={required}
      hint={description}
      placeholder={placeholder}
      disabled={disabled}
      minDate={minDate}
      maxDate={maxDate}
      className={className}
      error={error?.message}
    />
  );
}
