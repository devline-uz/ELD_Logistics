/**
 * Ro'yxat ekrani filtr paneli — qidiruv (400ms debounce), select filtrlar,
 * faol filtr badge'lari va "Clear all" (fe-screens §1). Domenni bilmaydi:
 * filtr ta'riflari (`FilterDef[]`) va joriy qiymatlar chaqiruvchidan keladi
 * (odatda `useListParams`).
 */
import { useEffect, useRef, useState } from 'react';
import { X } from 'lucide-react';

import { Icon } from '@/components/ui/Icon';
import { Input } from '@/components/ui/Input';
import { Select, type SelectOption } from '@/components/ui/Select';
import { Badge } from '@/components/ui/Badge';

import { useTranslation } from 'react-i18next';

export interface FilterOption {
  value: string;
  label: string;
}

export interface FilterDef {
  key: string;
  label: string;
  options: FilterOption[];
  placeholder?: string;
}

export interface FiltersBarProps {
  search: string;
  onSearchChange: (value: string) => void;
  searchPlaceholder?: string;
  filters?: FilterDef[];
  activeFilters: Record<string, string>;
  onFilterChange: (key: string, value: string | undefined) => void;
  onClearAll: () => void;
  /** Test/maxsus holatlar uchun — default 400ms (fe-screens §1). */
  debounceMs?: number;
  className?: string;
}

export function FiltersBar({
  search,
  onSearchChange,
  searchPlaceholder,
  filters = [],
  activeFilters,
  onFilterChange,
  onClearAll,
  debounceMs = 400,
  className,
}: FiltersBarProps) {
  const { t } = useTranslation();
  const [inputValue, setInputValue] = useState(search);
  const timerRef = useRef<ReturnType<typeof setTimeout>>();

  // Tashqi holat (masalan "Clear all") o'zgarsa — lokal input sinxronlanadi.
  useEffect(() => {
    setInputValue(search);
  }, [search]);

  useEffect(() => {
    return () => window.clearTimeout(timerRef.current);
  }, []);

  const handleSearchInput = (value: string) => {
    setInputValue(value);
    window.clearTimeout(timerRef.current);
    timerRef.current = setTimeout(() => onSearchChange(value), debounceMs);
  };

  const activeBadges = filters
    .map((filter) => {
      const value = activeFilters[filter.key];
      if (!value) return null;
      const option = filter.options.find((o) => o.value === value);
      return { key: filter.key, label: filter.label, valueLabel: option?.label ?? value };
    })
    .filter((entry): entry is NonNullable<typeof entry> => entry !== null);

  const hasActive = inputValue.length > 0 || activeBadges.length > 0;

  return (
    <div className={`flex flex-col gap-3 ${className ?? ''}`}>
      <div className="flex flex-wrap items-center gap-3">
        <Input
          value={inputValue}
          onChange={(event) => handleSearchInput(event.target.value)}
          placeholder={searchPlaceholder ?? t('ui.data.filtersBar.searchPlaceholder')}
          containerClassName="w-full max-w-xs"
          aria-label={searchPlaceholder ?? t('ui.data.filtersBar.searchPlaceholder')}
        />

        {filters.map((filter) => (
          <Select
            key={filter.key}
            value={activeFilters[filter.key] ?? null}
            onChange={(value) => onFilterChange(filter.key, value ?? undefined)}
            options={filter.options as SelectOption<string>[]}
            placeholder={filter.placeholder ?? filter.label}
            clearable
            className="w-48"
          />
        ))}

        {hasActive ? (
          <button
            type="button"
            onClick={onClearAll}
            className="ms-auto text-body-sm font-medium text-primary hover:underline"
          >
            {t('ui.form.actions.clearAll')}
          </button>
        ) : null}
      </div>

      {activeBadges.length > 0 ? (
        <div className="flex flex-wrap items-center gap-2">
          {activeBadges.map((badge) => (
            <Badge key={badge.key} tone="neutral">
              <span className="inline-flex items-center gap-1">
                {badge.label}: {badge.valueLabel}
                <button
                  type="button"
                  onClick={() => onFilterChange(badge.key, undefined)}
                  aria-label={t('ui.data.filtersBar.removeFilter', { label: badge.label })}
                  className="ms-1 rounded hover:text-neutral-900"
                >
                  <Icon icon={X} size={12} />
                </button>
              </span>
            </Badge>
          ))}
        </div>
      ) : null}
    </div>
  );
}
