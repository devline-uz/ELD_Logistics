import { useEffect, useId, useMemo, useRef, useState } from 'react';
import type { KeyboardEvent } from 'react';
import { Check, ChevronDown, X } from 'lucide-react';

import { cn } from './cn';
import { Icon } from './Icon';
import { useUiFormTranslation } from './i18n';

export interface SelectOption<TValue extends string = string> {
  value: TValue;
  label: string;
  disabled?: boolean;
}

export interface SelectProps<TValue extends string = string> {
  options: readonly SelectOption<TValue>[];
  value: TValue | null;
  onChange: (value: TValue | null) => void;
  label?: string;
  placeholder?: string;
  error?: string;
  hint?: string;
  required?: boolean;
  disabled?: boolean;
  /** Ichki qidiruv maydonini ko'rsatish (combobox). */
  searchable?: boolean;
  clearable?: boolean;
  /** Tashqi (server) yuklanish holati — masalan async variantlar keladi. */
  loading?: boolean;
  id?: string;
  name?: string;
  className?: string;
}

/**
 * Bitta tanlovli, klaviatura bilan to'liq boshqariladigan select/combobox.
 * `role="listbox"` / `role="option"` — WAI-ARIA combobox naqshiga mos.
 */
export function Select<TValue extends string = string>({
  options,
  value,
  onChange,
  label,
  placeholder,
  error,
  hint,
  required,
  disabled,
  searchable = false,
  clearable = false,
  loading = false,
  id,
  name,
  className,
}: SelectProps<TValue>) {
  const { t } = useUiFormTranslation();
  const generatedId = useId();
  const selectId = id ?? generatedId;
  const listboxId = `${selectId}-listbox`;
  const errorId = `${selectId}-error`;
  const hintId = `${selectId}-hint`;

  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState('');
  const [activeIndex, setActiveIndex] = useState(-1);
  const [typeAhead, setTypeAhead] = useState('');
  const rootRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const typeAheadTimer = useRef<ReturnType<typeof setTimeout>>();

  const filteredOptions = useMemo(() => {
    if (!searchable || !query) return options;
    const q = query.toLowerCase();
    return options.filter((option) => option.label.toLowerCase().includes(q));
  }, [options, query, searchable]);

  const selectedOption = useMemo(
    () => options.find((option) => option.value === value) ?? null,
    [options, value],
  );

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

  const openList = () => {
    if (disabled) return;
    setOpen(true);
    const currentIndex = filteredOptions.findIndex((option) => option.value === value);
    setActiveIndex(currentIndex >= 0 ? currentIndex : 0);
  };

  const closeList = () => {
    setOpen(false);
    setQuery('');
  };

  const commitSelection = (option: SelectOption<TValue> | undefined) => {
    if (!option || option.disabled) return;
    onChange(option.value);
    closeList();
    inputRef.current?.focus();
  };

  const moveActive = (delta: number) => {
    setActiveIndex((prev) => {
      const count = filteredOptions.length;
      if (count === 0) return -1;
      let next = prev;
      for (let i = 0; i < count; i += 1) {
        next = (next + delta + count) % count;
        if (!filteredOptions[next]?.disabled) return next;
      }
      return prev;
    });
  };

  const handleTypeAhead = (char: string) => {
    if (searchable) return;
    window.clearTimeout(typeAheadTimer.current);
    const next = typeAhead + char.toLowerCase();
    setTypeAhead(next);
    const matchIndex = filteredOptions.findIndex((option) =>
      option.label.toLowerCase().startsWith(next),
    );
    if (matchIndex >= 0) setActiveIndex(matchIndex);
    typeAheadTimer.current = setTimeout(() => setTypeAhead(''), 500);
  };

  const handleKeyDown = (event: KeyboardEvent<HTMLDivElement>) => {
    if (disabled) return;
    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault();
        if (!open) openList();
        else moveActive(1);
        break;
      case 'ArrowUp':
        event.preventDefault();
        if (!open) openList();
        else moveActive(-1);
        break;
      case 'Enter':
        if (open) {
          event.preventDefault();
          commitSelection(filteredOptions[activeIndex]);
        }
        break;
      case 'Escape':
        if (open) {
          event.preventDefault();
          closeList();
        }
        break;
      case 'Tab':
        setOpen(false);
        break;
      default:
        if (!searchable && event.key.length === 1 && /[a-z0-9]/i.test(event.key)) {
          if (!open) openList();
          handleTypeAhead(event.key);
        }
    }
  };

  const describedBy =
    [error ? errorId : null, !error && hint ? hintId : null].filter(Boolean).join(' ') || undefined;

  return (
    <div className={cn('flex flex-col gap-1', className)} ref={rootRef}>
      {label ? (
        <label htmlFor={selectId} className="text-body-sm font-medium text-neutral-700">
          {label}
          {required ? (
            <span aria-hidden="true" className="ml-0.5 text-error-base">
              *
            </span>
          ) : null}
        </label>
      ) : null}

      <div className="relative">
        <div className="relative">
          <input
            ref={inputRef}
            id={selectId}
            name={name}
            role="combobox"
            aria-expanded={open}
            aria-haspopup="listbox"
            aria-owns={listboxId}
            aria-controls={listboxId}
            readOnly={!searchable || !open}
            disabled={disabled}
            required={required}
            aria-invalid={Boolean(error) || undefined}
            aria-required={required || undefined}
            aria-describedby={describedBy}
            aria-autocomplete={searchable ? 'list' : 'none'}
            value={open && searchable ? query : (selectedOption?.label ?? '')}
            placeholder={placeholder ?? t('select.placeholder')}
            onFocus={openList}
            onClick={openList}
            onChange={(event) => setQuery(event.target.value)}
            onKeyDown={handleKeyDown}
            className={cn(
              'h-10 w-full rounded-md border bg-surface px-3 pr-16 text-body text-neutral-800 outline-none',
              'placeholder:text-neutral-400',
              'focus:ring-2 focus:ring-primary focus:ring-offset-1',
              error ? 'border-error-base' : 'border-stroke',
              disabled && 'cursor-not-allowed bg-surface-muted opacity-60',
            )}
          />
          <div className="absolute inset-y-0 end-2 flex items-center gap-1">
            {clearable && selectedOption && !disabled ? (
              <button
                type="button"
                aria-label={t('actions.clear')}
                onClick={(event) => {
                  event.stopPropagation();
                  onChange(null);
                }}
                className="rounded p-0.5 text-neutral-400 hover:text-neutral-600"
              >
                <Icon icon={X} size={14} />
              </button>
            ) : null}
            <Icon icon={ChevronDown} size={16} className="pointer-events-none text-neutral-400" />
          </div>
        </div>

        {open ? (
          <ul
            id={listboxId}
            role="listbox"
            aria-label={label ?? 'options'}
            className={cn(
              'absolute z-20 mt-1 max-h-60 w-full overflow-auto rounded-md border border-stroke bg-surface py-1 shadow-dropdown',
            )}
          >
            {loading ? (
              <li className="px-3 py-2 text-body-sm text-neutral-400">{t('select.loading')}</li>
            ) : filteredOptions.length === 0 ? (
              <li className="px-3 py-2 text-body-sm text-neutral-400">{t('select.noResults')}</li>
            ) : (
              filteredOptions.map((option, index) => (
                <li
                  key={option.value}
                  role="option"
                  aria-selected={option.value === value}
                  aria-disabled={option.disabled || undefined}
                  onMouseEnter={() => setActiveIndex(index)}
                  onMouseDown={(event) => {
                    event.preventDefault();
                    commitSelection(option);
                  }}
                  className={cn(
                    'flex cursor-pointer items-center justify-between px-3 py-2 text-body text-neutral-800',
                    index === activeIndex && 'bg-surface-muted',
                    option.disabled && 'cursor-not-allowed text-neutral-400',
                  )}
                >
                  {option.label}
                  {option.value === value ? (
                    <Icon icon={Check} size={16} className="text-primary" />
                  ) : null}
                </li>
              ))
            )}
          </ul>
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

export default Select;
