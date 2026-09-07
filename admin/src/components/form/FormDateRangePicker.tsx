/**
 * `react-hook-form` bilan bog'langan sana oralig'i tanlagichi
 * (`Start date – End date`, presetlar — fe-design-system §6). Forma qiymati
 * bitta maydonda `{ start: Date|null, end: Date|null }` shaklida saqlanadi
 * (`@/components/ui/DateRangePicker` shaklidan).
 */
import type { Control, FieldPath, FieldValues } from 'react-hook-form';
import { useController } from 'react-hook-form';

import { DateRangePicker, type DateRange } from '@/components/ui/DateRangePicker';

export interface FormDateRangePickerProps<TFieldValues extends FieldValues> {
  name: FieldPath<TFieldValues>;
  control: Control<TFieldValues>;
  label: string;
  description?: string;
  disabled?: boolean;
  className?: string;
}

const EMPTY_RANGE: DateRange = { start: null, end: null };

export function FormDateRangePicker<TFieldValues extends FieldValues>({
  name,
  control,
  label,
  description,
  disabled,
  className,
}: FormDateRangePickerProps<TFieldValues>) {
  const {
    field,
    fieldState: { error },
  } = useController({ name, control });

  return (
    <DateRangePicker
      value={field.value ?? EMPTY_RANGE}
      onChange={(value) => field.onChange(value)}
      label={label}
      hint={description}
      disabled={disabled}
      className={className}
      error={error?.message}
    />
  );
}
