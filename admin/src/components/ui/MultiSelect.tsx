import { useEffect, useId, useMemo, useRef, useState } from 'react';
import type { KeyboardEvent } from 'react';
import { Check, ChevronDown, X } from 'lucide-react';

import { cn } from './cn';
import { Icon } from './Icon';
import { useTranslation } from 'react-i18next';

export interface MultiSelectOption<TValue extends string = string> {
  value: TValue;
  label: string;
  disabled?: boolean;
}

export interface MultiSelectProps<TValue extends string = string> {
  options: readonly MultiSelectOption<TValue>[];
  values: readonly TValue[];
  onChange: (values: TValue[]) => void;
  label?: string;
  placeholder?: string;
  error?: string;
  hint?: string;
  required?: boolean;
  disabled?: boolean;
  searchable?: boolean;
  /** "Select all" pseudo-variantini ko'rsatish (IFTA States, Truck Defects). */
  selectAll?: boolean;
  loading?: boolean;
  id?: string;
  name?: string;
  className?: string;
}

/**
 * Bir nechta tanlovli select — tanlangan qiymatlar chip sifatida ko'rsatiladi.
 * `role="listbox"` bilan `aria-multiselectable="true"`.
 */
export function MultiSelect<TValue extends string = string>({
  options,
  values,
  onChange,
  label,
  placeholder,
  error,
  hint,
  required,
  disabled,
  searchable = false,
  selectAll = false,
  loading = false,
  id,
  name,
  className,
}: MultiSelectProps<TValue>) {
  const { t } = useTranslation();
  const generatedId = useId();
  const selectId = id ?? generatedId;
  const listboxId = `${selectId}-listbox`;
  const errorId = `${selectId}-error`;
  const hintId = `${selectId}-hint`;

  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState('');
  const [activeIndex, setActiveIndex] = useState(-1);
  const rootRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const filteredOptions = useMemo(() => {
    if (!searchable || !query) return options;
    const q = query.toLowerCase();
    return options.filter((option) => option.label.toLowerCase().includes(q));
  }, [options, query, searchable]);

  const selectableOptions = useMemo(() => options.filter((o) => !o.disabled), [options]);
  const allSelected =
    selectableOptions.length > 0 && selectableOptions.every((o) => values.includes(o.value));

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
    setActiveIndex(0);
  };

  const closeList = () => {
    setOpen(false);
    setQuery('');
  };

  const toggleValue = (option: MultiSelectOption<TValue>) => {
    if (option.disabled) return;
    if (values.includes(option.value)) {
      onChange(values.filter((v) => v !== option.value));
    } else {
      onChange([...values, option.value]);
    }
  };

  const toggleSelectAll = () => {
    if (allSelected) {
      onChange([]);
    } else {
      onChange(selectableOptions.map((o) => o.value));
    }
  };

  const removeValue = (value: TValue) => {
    onChange(values.filter((v) => v !== value));
  };

  const moveActive = (delta: number) => {
    const count = filteredOptions.length + (selectAll ? 1 : 0);
    setActiveIndex((prev) => {
      if (count === 0) return -1;
      return (prev + delta + count) % count;
    });
  };

  const commitActive = () => {
    if (selectAll && activeIndex === 0) {
      toggleSelectAll();
      return;
    }
    const optionIndex = activeIndex - (selectAll ? 1 : 0);
    const option = filteredOptions[optionIndex];
    if (option) toggleValue(option);
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
          commitActive();
        }
        break;
      case 'Escape':
        if (open) {
          event.preventDefault();
          closeList();
        }
        break;
      case 'Backspace':
        if (!query && values.length > 0) {
          onChange(values.slice(0, -1));
        }
        break;
      case 'Tab':
        setOpen(false);
        break;
      default:
        break;
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
            <span aria-hidden="true" className="ml-0.5 text-error-dark">
              *
            </span>
          ) : null}
        </label>
      ) : null}

      <div className="relative">
        <div
          className={cn(
            'flex min-h-10 w-full flex-wrap items-center gap-1 rounded-md border bg-surface px-2 py-1',
            'focus-within:ring-2 focus-within:ring-primary focus-within:ring-offset-1',
            error ? 'border-error-base' : 'border-stroke',
            disabled && 'cursor-not-allowed bg-surface-muted opacity-60',
          )}
        >
          {values.map((v) => {
            const option = options.find((o) => o.value === v);
            if (!option) return null;
            return (
              <span
                key={v}
                className="flex items-center gap-1 rounded-sm bg-surface-muted px-2 py-0.5 text-body-sm text-neutral-700"
              >
                {option.label}
                {!disabled ? (
                  <button
                    type="button"
                    aria-label={`${t('ui.form.actions.clear')}: ${option.label}`}
                    onClick={() => removeValue(v)}
                    className="text-neutral-400 hover:text-neutral-600"
                  >
                    <Icon icon={X} size={12} />
                  </button>
                ) : null}
              </span>
            );
          })}
          <input
            ref={inputRef}
            id={selectId}
            name={name}
            role="combobox"
            aria-expanded={open}
            aria-haspopup="listbox"
            aria-owns={listboxId}
            aria-controls={listboxId}
            readOnly={!searchable}
            disabled={disabled}
            required={required}
            aria-invalid={Boolean(error) || undefined}
            aria-required={required || undefined}
            aria-describedby={describedBy}
            aria-autocomplete={searchable ? 'list' : 'none'}
            aria-activedescendant={
              open && activeIndex >= 0 ? `${listboxId}-option-${activeIndex}` : undefined
            }
            value={query}
            placeholder={
              values.length === 0 ? (placeholder ?? t('ui.form.multiSelect.placeholder')) : ''
            }
            onKeyDown={handleKeyDown}
            onFocus={openList}
            onClick={openList}
            onChange={(event) => setQuery(event.target.value)}
            className="h-7 min-w-[4rem] flex-1 bg-transparent text-body text-neutral-800 outline-none placeholder:text-neutral-400"
          />
          <Icon
            icon={ChevronDown}
            size={16}
            className="pointer-events-none ml-auto text-neutral-400"
          />
        </div>

        {open ? (
          <ul
            id={listboxId}
            role="listbox"
            aria-multiselectable="true"
            aria-label={label ?? 'options'}
            className="absolute z-20 mt-1 max-h-60 w-full overflow-auto rounded-md border border-stroke bg-surface py-1 shadow-dropdown"
          >
            {selectAll ? (
              <li
                id={`${listboxId}-option-0`}
                role="option"
                aria-selected={allSelected}
                onMouseEnter={() => setActiveIndex(0)}
                onMouseDown={(event) => {
                  event.preventDefault();
                  toggleSelectAll();
                }}
                className={cn(
                  'flex cursor-pointer items-center justify-between border-b border-stroke px-3 py-2 text-body font-medium text-neutral-800',
                  activeIndex === 0 && 'bg-surface-muted',
                )}
              >
                {t('ui.form.actions.selectAll')}
                {allSelected ? <Icon icon={Check} size={16} className="text-primary" /> : null}
              </li>
            ) : null}
            {loading ? (
              <li className="px-3 py-2 text-body-sm text-neutral-400">
                {t('ui.form.select.loading')}
              </li>
            ) : filteredOptions.length === 0 ? (
              <li className="px-3 py-2 text-body-sm text-neutral-400">
                {t('ui.form.select.noResults')}
              </li>
            ) : (
              filteredOptions.map((option, index) => {
                const activeOffset = selectAll ? 1 : 0;
                const isChecked = values.includes(option.value);
                return (
                  <li
                    key={option.value}
                    id={`${listboxId}-option-${index + activeOffset}`}
                    role="option"
                    aria-selected={isChecked}
                    aria-disabled={option.disabled || undefined}
                    onMouseEnter={() => setActiveIndex(index + activeOffset)}
                    onMouseDown={(event) => {
                      event.preventDefault();
                      toggleValue(option);
                    }}
                    className={cn(
                      'flex cursor-pointer items-center justify-between px-3 py-2 text-body text-neutral-800',
                      index + activeOffset === activeIndex && 'bg-surface-muted',
                      option.disabled && 'cursor-not-allowed text-neutral-400',
                    )}
                  >
                    {option.label}
                    {isChecked ? <Icon icon={Check} size={16} className="text-primary" /> : null}
                  </li>
                );
              })
            )}
          </ul>
        ) : null}
      </div>

      {error ? (
        <p id={errorId} role="alert" className="text-body-sm text-error-dark">
          {error}
        </p>
      ) : hint ? (
        <p id={hintId} className="text-body-sm text-neutral-500">
          {hint}
        </p>
      ) : (
        values.length > 0 && (
          <p className="text-body-sm text-neutral-400">
            {t('ui.form.multiSelect.selectedCount', { count: values.length })}
          </p>
        )
      )}
    </div>
  );
}

export default MultiSelect;
