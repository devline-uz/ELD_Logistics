/**
 * Sahifalash — `Rows per page: 10/25/50` + `Previous · <sahifalar> · Next`
 * (fe-screens §1, fe-api §7). `per_page` faqat 10|25|50 — boshqasi backendda
 * 422. Komponent domenni bilmaydi: `page`/`perPage`/`total` va callback'lar
 * chaqiruvchidan keladi (odatda `useListParams`).
 */
import { ChevronLeft, ChevronRight } from 'lucide-react';

import { PER_PAGE_OPTIONS, type PerPage } from '@/api/types';
import { Icon } from '@/components/ui/Icon';
import { Select, type SelectOption } from '@/components/ui/Select';

import { useUiDataTranslation } from './i18n';

export interface PaginationProps {
  page: number;
  perPage: PerPage;
  total: number;
  onPageChange: (page: number) => void;
  onPerPageChange: (perPage: PerPage) => void;
  className?: string;
}

const PER_PAGE_SELECT_OPTIONS: SelectOption<string>[] = PER_PAGE_OPTIONS.map((value) => ({
  value: String(value),
  label: String(value),
}));

/** Sahifa raqamlarini "1 … 4 5 6 … 12" ko'rinishida qisqartiradi. */
function buildPageWindow(current: number, totalPages: number): (number | 'ellipsis')[] {
  const pages = new Set<number>([1, totalPages, current, current - 1, current + 1]);
  const sorted = Array.from(pages)
    .filter((p) => p >= 1 && p <= totalPages)
    .sort((a, b) => a - b);

  const result: (number | 'ellipsis')[] = [];
  let previous = 0;
  for (const p of sorted) {
    if (previous && p - previous > 1) result.push('ellipsis');
    result.push(p);
    previous = p;
  }
  return result;
}

export function Pagination({
  page,
  perPage,
  total,
  onPageChange,
  onPerPageChange,
  className,
}: PaginationProps) {
  const { t } = useUiDataTranslation();
  const totalPages = Math.max(1, Math.ceil(total / perPage));
  const clampedPage = Math.min(Math.max(page, 1), totalPages);
  const pageWindow = buildPageWindow(clampedPage, totalPages);

  return (
    <div className={`flex flex-wrap items-center justify-between gap-4 ${className ?? ''}`}>
      <div className="flex items-center gap-2">
        <span className="text-body-sm text-neutral-600">{t('pagination.rowsPerPage')}</span>
        <Select
          value={String(perPage)}
          onChange={(value) => value && onPerPageChange(Number(value) as PerPage)}
          options={PER_PAGE_SELECT_OPTIONS}
          className="w-20"
        />
      </div>

      <nav aria-label={t('pagination.navLabel')} className="flex items-center gap-1">
        <button
          type="button"
          onClick={() => onPageChange(clampedPage - 1)}
          disabled={clampedPage <= 1}
          className="inline-flex h-8 items-center gap-1 rounded-md px-2 text-body-sm text-neutral-700 hover:bg-surface-muted disabled:cursor-not-allowed disabled:text-neutral-400"
        >
          <Icon icon={ChevronLeft} size={16} />
          {t('pagination.previous')}
        </button>

        {pageWindow.map((entry, index) =>
          entry === 'ellipsis' ? (
            <span key={`ellipsis-${index}`} className="px-2 text-body-sm text-neutral-400">
              …
            </span>
          ) : (
            <button
              key={entry}
              type="button"
              aria-current={entry === clampedPage ? 'page' : undefined}
              onClick={() => onPageChange(entry)}
              className={`inline-flex h-8 min-w-8 items-center justify-center rounded-md px-2 text-body-sm ${
                entry === clampedPage
                  ? 'bg-primary text-white'
                  : 'text-neutral-700 hover:bg-surface-muted'
              }`}
            >
              {entry}
            </button>
          ),
        )}

        <button
          type="button"
          onClick={() => onPageChange(clampedPage + 1)}
          disabled={clampedPage >= totalPages}
          className="inline-flex h-8 items-center gap-1 rounded-md px-2 text-body-sm text-neutral-700 hover:bg-surface-muted disabled:cursor-not-allowed disabled:text-neutral-400"
        >
          {t('pagination.next')}
          <Icon icon={ChevronRight} size={16} />
        </button>
      </nav>
    </div>
  );
}
