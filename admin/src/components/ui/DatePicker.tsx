import { useEffect, useId, useMemo, useRef, useState } from 'react';
import type { KeyboardEvent } from 'react';
import {
  addDays,
  addMonths,
  endOfMonth,
  endOfWeek,
  format,
  isSameDay,
  isSameMonth,
  startOfMonth,
  startOfWeek,
  subMonths,
} from 'date-fns';
import { CalendarDays, ChevronLeft, ChevronRight } from 'lucide-react';

import { cn } from './cn';
import { Icon } from './Icon';
import { useUiFormTranslation } from './i18n';

export interface DatePickerProps {
  value: Date | null;
  onChange: (value: Date | null) => void;
  label?: string;
  placeholder?: string;
  error?: string;
  hint?: string;
  required?: boolean;
  disabled?: boolean;
  /** Ekranga chiqariladigan format (default `date-fns` `dd/MM/yyyy`). Kompozitsion — `lib/format.ts` bilan mos ravishda chaqiruvchi tomonidan beriladi. */
  displayFormat?: string;
  minDate?: Date;
  maxDate?: Date;
  id?: string;
  name?: string;
  className?: string;
}

function buildMonthGrid(month: Date): Date[] {
  const start = startOfWeek(startOfMonth(month), { weekStartsOn: 0 });
  const end = endOfWeek(endOfMonth(month), { weekStartsOn: 0 });
  const days: Date[] = [];
  let cursor = start;
  while (cursor <= end) {
    days.push(cursor);
    cursor = addDays(cursor, 1);
  }
  return days;
}

/**
 * Bitta sanani tanlash. Kalendar `date-fns` bilan quriladi, ichki matnlar
 * `ui-form` i18n bo'lagidan olinadi.
 */
export function DatePicker({
  value,
  onChange,
  label,
  placeholder,
  error,
  hint,
  required,
  disabled,
  displayFormat = 'dd/MM/yyyy',
  minDate,
  maxDate,
  id,
  name,
  className,
}: DatePickerProps) {
  const { t } = useUiFormTranslation();
  const generatedId = useId();
  const fieldId = id ?? generatedId;
  const errorId = `${fieldId}-error`;
  const hintId = `${fieldId}-hint`;

  const [open, setOpen] = useState(false);
  const [visibleMonth, setVisibleMonth] = useState<Date>(value ?? new Date());
  const [focusedDay, setFocusedDay] = useState<Date>(value ?? new Date());
  const rootRef = useRef<HTMLDivElement>(null);

  const months = t('calendar.months', { returnObjects: true }) as string[];
  const weekdays = t('calendar.weekdaysShort', { returnObjects: true }) as string[];

  const days = useMemo(() => buildMonthGrid(visibleMonth), [visibleMonth]);

  useEffect(() => {
    if (!open) return undefined;
    const handleClickOutside = (event: MouseEvent) => {
      if (rootRef.current && !rootRef.current.contains(event.target as Node)) {
        setOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [open]);

  const isDisabledDay = (day: Date) =>
    (minDate && day < minDate) || (maxDate && day > maxDate) || false;

  const openCalendar = () => {
    if (disabled) return;
    setVisibleMonth(value ?? new Date());
    setFocusedDay(value ?? new Date());
    setOpen(true);
  };

  const selectDay = (day: Date) => {
    if (isDisabledDay(day)) return;
    onChange(day);
    setOpen(false);
  };

  const handleGridKeyDown = (event: KeyboardEvent<HTMLDivElement>) => {
    const deltas: Record<string, number> = {
      ArrowLeft: -1,
      ArrowRight: 1,
      ArrowUp: -7,
      ArrowDown: 7,
    };
    if (event.key in deltas) {
      event.preventDefault();
      const next = addDays(focusedDay, deltas[event.key] ?? 0);
      setFocusedDay(next);
      if (!isSameMonth(next, visibleMonth)) setVisibleMonth(next);
      return;
    }
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      selectDay(focusedDay);
      return;
    }
    if (event.key === 'Escape') {
      event.preventDefault();
      setOpen(false);
    }
  };

  const describedBy =
    [error ? errorId : null, !error && hint ? hintId : null].filter(Boolean).join(' ') || undefined;

  const labelId = `${fieldId}-label`;
  const valueId = `${fieldId}-value`;

  return (
    <div className={cn('flex flex-col gap-1', className)} ref={rootRef}>
      {label ? (
        <span id={labelId} className="text-body-sm font-medium text-neutral-700">
          {label}
          {required ? (
            <span aria-hidden="true" className="ml-0.5 text-error-base">
              *
            </span>
          ) : null}
        </span>
      ) : null}

      <div className="relative">
        {/* eslint-disable-next-line jsx-a11y/role-supports-aria-props -- aria-invalid/aria-required global ARIA 1.2 atributlari */}
        <button
          type="button"
          id={fieldId}
          name={name}
          disabled={disabled}
          aria-haspopup="dialog"
          aria-expanded={open}
          aria-invalid={Boolean(error) || undefined}
          aria-required={required || undefined}
          aria-labelledby={label ? `${labelId} ${valueId}` : undefined}
          aria-describedby={describedBy}
          onClick={() => (open ? setOpen(false) : openCalendar())}
          className={cn(
            'flex h-10 w-full items-center justify-between gap-2 rounded-md border bg-surface px-3 text-body text-neutral-800',
            'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-1',
            error ? 'border-error-base' : 'border-stroke',
            disabled && 'cursor-not-allowed bg-surface-muted opacity-60',
          )}
        >
          <span id={valueId} className={cn(!value && 'text-neutral-400')}>
            {value ? format(value, displayFormat) : (placeholder ?? t('date.placeholder'))}
          </span>
          <Icon icon={CalendarDays} size={16} className="text-neutral-400" />
        </button>

        {open ? (
          <div
            role="dialog"
            aria-label={label ?? t('date.placeholder')}
            className="absolute z-20 mt-1 w-72 rounded-md border border-stroke bg-surface p-3 shadow-dropdown"
          >
            <div className="mb-2 flex items-center justify-between">
              <button
                type="button"
                aria-label={t('calendar.previousMonth')}
                onClick={() => setVisibleMonth((m) => subMonths(m, 1))}
                className="rounded p-1 text-neutral-500 hover:bg-surface-muted"
              >
                <Icon icon={ChevronLeft} size={16} />
              </button>
              <span className="text-body-sm font-medium text-neutral-800">
                {months[visibleMonth.getMonth()]} {visibleMonth.getFullYear()}
              </span>
              <button
                type="button"
                aria-label={t('calendar.nextMonth')}
                onClick={() => setVisibleMonth((m) => addMonths(m, 1))}
                className="rounded p-1 text-neutral-500 hover:bg-surface-muted"
              >
                <Icon icon={ChevronRight} size={16} />
              </button>
            </div>

            <div className="grid grid-cols-7 gap-1 text-center text-body-xs text-neutral-500">
              {weekdays.map((weekday) => (
                <span key={weekday}>{weekday}</span>
              ))}
            </div>

            <div
              role="grid"
              tabIndex={-1}
              onKeyDown={handleGridKeyDown}
              className="grid grid-cols-7 gap-1"
            >
              {days.map((day) => {
                const selected = value ? isSameDay(day, value) : false;
                const outsideMonth = !isSameMonth(day, visibleMonth);
                const dayDisabled = isDisabledDay(day);
                const isFocusTarget = isSameDay(day, focusedDay);
                return (
                  <button
                    key={day.toISOString()}
                    type="button"
                    role="gridcell"
                    tabIndex={isFocusTarget ? 0 : -1}
                    aria-selected={selected}
                    disabled={dayDisabled}
                    onFocus={() => setFocusedDay(day)}
                    onClick={() => selectDay(day)}
                    className={cn(
                      'h-8 w-8 rounded-md text-body-sm',
                      outsideMonth && 'text-neutral-300',
                      !outsideMonth && !selected && 'text-neutral-700 hover:bg-surface-muted',
                      selected && 'bg-primary text-white',
                      dayDisabled && 'cursor-not-allowed text-neutral-300 hover:bg-transparent',
                    )}
                  >
                    {day.getDate()}
                  </button>
                );
              })}
            </div>
          </div>
        ) : null}
      </div>

      {error ? (
        <p id={errorId} role="alert" className="text-body-sm text-error-base">
          {error}
        </p>
      ) : hint ? (
        <p id={hintId} className="text-body-sm text-neutral-500">
          {hint}
        </p>
      ) : null}
    </div>
  );
}

export default DatePicker;
