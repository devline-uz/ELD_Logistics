/**
 * Ro'yxat-ekran shabloni — fe-screens §1 tuzilmasi:
 * sarlavha + amal tugmalari + tablar + filtr paneli + jadval + sahifalash.
 *
 * Bu komponent faqat joylashuvni beradi (kompozitsiya) — `DataTable`,
 * `FiltersBar`, `Pagination` va amal tugmalari chaqiruvchi tomonidan
 * tayyorlanadi va slot sifatida uzatiladi. Domenga xos bilim yo'q.
 */
import type { ReactNode } from 'react';

export interface ListScreenTab {
  key: string;
  label: string;
}

export interface ListScreenProps {
  /** Sahifa sarlavhasi (H3, i18n kalitidan) — fe-screens §10. */
  title: string;
  /** Breadcrumb (ichki ekranlarda) — chaqiruvchi `Breadcrumb` komponentini beradi. */
  breadcrumb?: ReactNode;
  /** Asosiy amal tugmasi(lari) — `PermissionGate` bilan chaqiruvchi tomonidan o'raladi. */
  actions?: ReactNode;
  tabs?: ListScreenTab[];
  activeTab?: string;
  onTabChange?: (key: string) => void;
  /** `<FiltersBar ... />` — to'liq wiring chaqiruvchida. */
  filtersBar?: ReactNode;
  /** `<DataTable ... />`. */
  table: ReactNode;
  /** `<Pagination ... />` — bo'sh/xato holatda ham ko'rinishi kerak bo'lsa chaqiruvchi shart qo'yadi. */
  pagination?: ReactNode;
  className?: string;
}

export function ListScreen({
  title,
  breadcrumb,
  actions,
  tabs,
  activeTab,
  onTabChange,
  filtersBar,
  table,
  pagination,
  className,
}: ListScreenProps) {
  return (
    <div className={`flex flex-col gap-4 ${className ?? ''}`}>
      {breadcrumb}

      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-h3 font-bold text-neutral-900">{title}</h1>
        {actions ? <div className="flex items-center gap-2">{actions}</div> : null}
      </div>

      {tabs && tabs.length > 0 ? (
        <div role="tablist" aria-label={title} className="flex gap-1 border-b border-stroke">
          {tabs.map((tab) => {
            const selected = tab.key === activeTab;
            return (
              <button
                key={tab.key}
                type="button"
                role="tab"
                aria-selected={selected}
                tabIndex={selected ? 0 : -1}
                onClick={() => onTabChange?.(tab.key)}
                className={`border-b-2 px-3 py-2 text-body-sm font-medium ${
                  selected
                    ? 'border-primary text-primary'
                    : 'border-transparent text-neutral-500 hover:text-neutral-700'
                }`}
              >
                {tab.label}
              </button>
            );
          })}
        </div>
      ) : null}

      {filtersBar}

      {table}

      {pagination}
    </div>
  );
}
