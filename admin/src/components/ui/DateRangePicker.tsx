import { useEffect, useId, useMemo, useRef, useState } from 'react';
import {
  addDays,
  addMonths,
  endOfDay,
  endOfMonth,
  endOfWeek,
  format,
  isSameDay,
  isSameMonth,
  isWithinInterval,
  startOfDay,
  startOfMonth,
  startOfWeek,
  subDays,
  subMonths,
} from 'date-fns';
import { CalendarDays, ChevronLeft, ChevronRight } from 'lucide-react';

import { Button } from './Button';
import { cn } from './cn';
import { Icon } from './Icon';
import { useUiFormTranslation } from './i18n';

export interface DateRange {
  start: Date | null;
  end: Date | null;
}

export interface DateRangePickerProps {
  value: DateRange;
  onChange: (value: DateRange) => void;
  label?: string;
  placeholder?: string;
  error?: string;
  hint?: string;
  disabled?: boolean;
  displayFormat?: string;
  id?: string;
  className?: string;
}

type PresetKey = 'today' | 'yesterday' | 'last7Days' | 'last30Days' | 'thisMonth' | 'custom';

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

function resolvePreset(preset: PresetKey): DateRange | null {
  const now = new Date();
  switch (preset) {
    case 'today':
      return { start: startOfDay(now), end: endOfDay(now) };
    case 'yesterday': {
      const yesterday = subDays(now, 1);
      return { start: startOfDay(yesterday), end: endOfDay(yesterday) };
    }
    case 'last7Days':
      return { start: startOfDay(subDays(now, 6)), end: endOfDay(now) };
    case 'last30Days':
      return { start: startOfDay(subDays(now, 29)), end: endOfDay(now) };
    case 'thisMonth':
      return { start: startOfMonth(now), end: endOfDay(now) };
    default:
      return null;
  }
}

const PRESET_KEYS: PresetKey[] = [
  'today',
  'yesterday',
  'last7Days',
  'last30Days',
  'thisMonth',
  'custom',
];

/**
 * Sana oralig'ini tanlash — presetlar (Today, Yesterday, Last 7/30 days,
 * This month, Custom) + ikkita oy kalendari.
 */
export function DateRangePicker({
  value,
  onChange,
  label,
  placeholder,
  error,
  hint,
  disabled,
  displayFormat = 'dd/MM/yyyy',
  id,
  className,
}: DateRangePickerProps) {
  const { t } = useUiFormTranslation();
  const generatedId = useId();
  const fieldId = id ?? generatedId;
  const labelId = `${fieldId}-label`;
  const valueId = `${fieldId}-value`;
  const errorId = `${fieldId}-error`;
  const hintId = `${fieldId}-hint`;

  const [open, setOpen] = useState(false);
  const [visibleMonth, setVisibleMonth] = useState<Date>(value.start ?? new Date());
  const [draftStart, setDraftStart] = useState<Date | null>(value.start);
  const [draftEnd, setDraftEnd] = useState<Date | null>(value.end);
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

  const openPicker = () => {
    if (disabled) return;
    setDraftStart(value.start);
    setDraftEnd(value.end);
    setVisibleMonth(value.start ?? new Date());
    setOpen(true);
  };

  const applyPreset = (preset: PresetKey) => {
    if (preset === 'custom') return;
    const range = resolvePreset(preset);
    if (range) {
      setDraftStart(range.start);
      setDraftEnd(range.end);
      if (range.start) setVisibleMonth(range.start);
    }
  };

  const handleDayClick = (day: Date) => {
    if (!draftStart || (draftStart && draftEnd)) {
      setDraftStart(day);
      setDraftEnd(null);
      return;
    }
    if (day < draftStart) {
      setDraftEnd(draftStart);
      setDraftStart(day);
    } else {
      setDraftEnd(day);
    }
  };

  const apply = () => {
    onChange({ start: draftStart, end: draftEnd });
    setOpen(false);
  };

  const cancel = () => {
    setDraftStart(value.start);
    setDraftEnd(value.end);
    setOpen(false);
  };

  const displayValue =
    value.start && value.end
      ? `${format(value.start, displayFormat)} – ${format(value.end, displayFormat)}`
      : (placeholder ?? t('dateRange.placeholder'));

  const describedBy =
    [error ? errorId : null, !error && hint ? hintId : null].filter(Boolean).join(' ') || undefined;

  return (
    <div className={cn('flex flex-col gap-1', className)} ref={rootRef}>
      {label ? (
        <span id={labelId} className="text-body-sm font-medium text-neutral-700">
          {label}
        </span>
      ) : null}

      <div className="relative">
        {/* eslint-disable-next-line jsx-a11y/role-supports-aria-props -- aria-invalid global ARIA 1.2 atributi */}
        <button
          type="button"
          id={fieldId}
          disabled={disabled}
          aria-haspopup="dialog"
          aria-expanded={open}
          aria-invalid={Boolean(error) || undefined}
          aria-labelledby={label ? `${labelId} ${valueId}` : undefined}
          aria-describedby={describedBy}
          onClick={() => (open ? cancel() : openPicker())}
          className={cn(
            'flex h-10 w-full items-center justify-between gap-2 rounded-md border bg-surface px-3 text-body text-neutral-800',
            'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-1',
            error ? 'border-error-base' : 'border-stroke',
            disabled && 'cursor-not-allowed bg-surface-muted opacity-60',
          )}
        >
          <span id={valueId} className={cn(!(value.start && value.end) && 'text-neutral-400')}>
            {displayValue}
          </span>
          <Icon icon={CalendarDays} size={16} className="text-neutral-400" />
        </button>

        {open ? (
          // eslint-disable-next-line jsx-a11y/no-noninteractive-element-interactions -- Escape bilan yopish uchun popover konteyneri
          <div
            role="dialog"
            aria-label={label ?? t('dateRange.placeholder')}
            tabIndex={-1}
            onKeyDown={(event) => {
              if (event.key === 'Escape') {
                event.preventDefault();
                cancel();
              }
            }}
            className="absolute z-20 mt-1 flex w-[30rem] gap-3 rounded-md border border-stroke bg-surface p-3 shadow-dropdown"
          >
            <ul className="flex w-36 shrink-0 flex-col gap-0.5 border-e border-stroke pe-2">
              {PRESET_KEYS.map((preset) => (
                <li key={preset}>
                  <button
                    type="button"
                    onClick={() => applyPreset(preset)}
                    className="w-full rounded px-2 py-1.5 text-start text-body-sm text-neutral-700 hover:bg-surface-muted"
                  >
                    {t(`dateRange.presets.${preset}`)}
                  </button>
                </li>
              ))}
            </ul>

            <div className="flex-1">
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

              <div role="grid" className="grid grid-cols-7 gap-1">
                {days.map((day) => {
                  const outsideMonth = !isSameMonth(day, visibleMonth);
                  const isStart = draftStart ? isSameDay(day, draftStart) : false;
                  const isEnd = draftEnd ? isSameDay(day, draftEnd) : false;
                  const inRange =
                    draftStart && draftEnd
                      ? isWithinInterval(day, { start: draftStart, end: draftEnd })
                      : false;
                  return (
                    <button
                      key={day.toISOString()}
                      type="button"
                      role="gridcell"
                      aria-selected={isStart || isEnd}
                      onClick={() => handleDayClick(day)}
                      className={cn(
                        'h-8 w-8 rounded-md text-body-sm',
                        outsideMonth && 'text-neutral-300',
                        !outsideMonth &&
                          !inRange &&
                          !isStart &&
                          !isEnd &&
                          'text-neutral-700 hover:bg-surface-muted',
                        inRange && !isStart && !isEnd && 'bg-light text-neutral-800',
                        (isStart || isEnd) && 'bg-primary text-white',
                      )}
                    >
                      {day.getDate()}
                    </button>
                  );
                })}
              </div>

              <div className="mt-3 flex items-center justify-between text-body-sm text-neutral-600">
                <span>
                  {t('dateRange.startDate')}: {draftStart ? format(draftStart, displayFormat) : '—'}
                </span>
                <span>
                  {t('dateRange.endDate')}: {draftEnd ? format(draftEnd, displayFormat) : '—'}
                </span>
              </div>

              <div className="mt-3 flex justify-end gap-2">
                <Button variant="ghost" size="sm" onClick={cancel}>
                  {t('actions.cancel')}
                </Button>
                <Button
                  variant="primary"
                  size="sm"
                  disabled={!draftStart || !draftEnd}
                  onClick={apply}
                >
                  {t('actions.apply')}
                </Button>
              </div>
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

export default DateRangePicker;
