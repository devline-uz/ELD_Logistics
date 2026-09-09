/**
 * Generik ma'lumot jadvali — TanStack Table v8 ustida (fe-screens §1, §6).
 *
 * - Saralash **server tomonida**: `sort`/`order` props + `onSortChange`
 *   chaqiruvchiga uzatiladi (`useListParams` bilan bog'lash chaqiruvchining
 *   ishi — komponent domenni yoki URL'ni bilmaydi).
 * - Ustun ko'rsatish/yashirish `localStorage`da saqlanadi (`table:<tableId>:columns`).
 * - Birinchi ustun `sticky left-0`, konteyner `overflow-x: auto` — sahifa
 *   gorizontal scroll qilmaydi.
 * - Holatlar: yuklanish → skeleton qatorlar; bo'sh → `EmptyState`;
 *   xato → `ErrorState`.
 */
import { useEffect, useMemo, useState, type KeyboardEvent, type ReactNode } from 'react';
import {
  flexRender,
  getCoreRowModel,
  useReactTable,
  type ColumnDef,
  type VisibilityState,
} from '@tanstack/react-table';
import { ArrowDown, ArrowUp, ChevronsUpDown } from 'lucide-react';

import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Icon } from '@/components/ui/Icon';
import { Skeleton } from '@/components/feedback/Skeleton';

import { ColumnPicker, type ColumnPickerColumn } from './ColumnPicker';
import { useTranslation } from 'react-i18next';

export type SortOrder = 'asc' | 'desc';

export interface DataTableProps<TData> {
  /** `localStorage` kaliti uchun barqaror identifikator (masalan `"units"`). */
  tableId: string;
  columns: ColumnDef<TData, unknown>[];
  data: TData[];
  isLoading?: boolean;
  isError?: boolean;
  errorMessage?: string;
  onRetry?: () => void;
  emptyTitle?: string;
  emptyDescription?: string;
  /** Faol filtr natijasi bo'sh bo'lganda "Clear filters" tugmasi ko'rsatiladi. */
  onClearFilters?: () => void;
  /** Joriy server saralashi — sarlavhada `aria-sort` va yo'nalish ikonkasi uchun. */
  sort?: string;
  order?: SortOrder;
  onSortChange?: (columnId: string, order: SortOrder) => void;
  /** Qator o'ng chetidagi `···` amallar menyusi. */
  rowActions?: (row: TData) => ReactNode;
  onRowClick?: (row: TData) => void;
  getRowId?: (row: TData, index: number) => string;
  skeletonRowCount?: number;
  className?: string;
}

function readStoredVisibility(tableId: string): VisibilityState {
  try {
    const raw = window.localStorage.getItem(`table:${tableId}:columns`);
    return raw ? (JSON.parse(raw) as VisibilityState) : {};
  } catch {
    return {};
  }
}

function persistVisibility(tableId: string, visibility: VisibilityState): void {
  try {
    window.localStorage.setItem(`table:${tableId}:columns`, JSON.stringify(visibility));
  } catch {
    // localStorage mavjud bo'lmasa (privat rejim va h.k.) — jim o'tkaziladi.
  }
}

export function DataTable<TData>({
  tableId,
  columns,
  data,
  isLoading = false,
  isError = false,
  errorMessage,
  onRetry,
  emptyTitle,
  emptyDescription,
  onClearFilters,
  sort,
  order,
  onSortChange,
  rowActions,
  onRowClick,
  getRowId,
  skeletonRowCount = 5,
  className,
}: DataTableProps<TData>) {
  const { t } = useTranslation();
  const [columnVisibility, setColumnVisibility] = useState<VisibilityState>(() =>
    readStoredVisibility(tableId),
  );

  useEffect(() => {
    // tableId almashsa (bir xil komponent boshqa jadval uchun qayta ishlatilsa)
    // saqlangan holat qayta o'qiladi.
    setColumnVisibility(readStoredVisibility(tableId));
  }, [tableId]);

  const updateVisibility = (next: VisibilityState) => {
    setColumnVisibility(next);
    persistVisibility(tableId, next);
  };

  const columnsWithActions = useMemo<ColumnDef<TData, unknown>[]>(() => {
    if (!rowActions) return columns;
    return [
      ...columns,
      {
        id: '__actions',
        header: () => <span className="sr-only">{t('ui.data.dataTable.rowActions')}</span>,
        enableHiding: false,
        enableSorting: false,
        cell: ({ row }) => rowActions(row.original),
      },
    ];
  }, [columns, rowActions, t]);

  const table = useReactTable({
    data,
    columns: columnsWithActions,
    state: { columnVisibility },
    onColumnVisibilityChange: (updater) => {
      const next = typeof updater === 'function' ? updater(columnVisibility) : updater;
      updateVisibility(next);
    },
    getRowId: getRowId ? (row, index) => getRowId(row, index) : undefined,
    getCoreRowModel: getCoreRowModel(),
    manualSorting: true,
  });

  const pickerColumns: ColumnPickerColumn[] = useMemo(
    () =>
      table
        .getAllLeafColumns()
        .filter((column) => column.columnDef.enableHiding !== false)
        .map((column) => ({
          id: column.id,
          label: typeof column.columnDef.header === 'string' ? column.columnDef.header : column.id,
        })),
    [table],
  );

  const headerGroups = table.getHeaderGroups();
  const rows = table.getRowModel().rows;
  const visibleColumnCount = table.getVisibleLeafColumns().length;

  const handleSort = (columnId: string) => {
    if (!onSortChange) return;
    const nextOrder: SortOrder = sort === columnId && order === 'asc' ? 'desc' : 'asc';
    onSortChange(columnId, nextOrder);
  };

  return (
    <div className={className}>
      <div className="flex items-center justify-end pb-2">
        <ColumnPicker
          columns={pickerColumns}
          visibility={columnVisibility}
          onToggle={(id, visible) => updateVisibility({ ...columnVisibility, [id]: visible })}
          onSelectAll={() => {
            const allVisible = pickerColumns.every((c) => columnVisibility[c.id] !== false);
            const next: VisibilityState = {};
            for (const c of pickerColumns) next[c.id] = !allVisible;
            updateVisibility(next);
          }}
        />
      </div>

      <div className="overflow-x-auto rounded-lg border border-stroke">
        <table className="w-full border-collapse text-body">
          <thead className="bg-surface-muted">
            {headerGroups.map((headerGroup) => (
              <tr key={headerGroup.id}>
                {headerGroup.headers.map((header, index) => {
                  const canSort = header.column.columnDef.enableSorting === true;
                  const isSorted = sort === header.column.id;
                  const ariaSort = !canSort
                    ? undefined
                    : isSorted
                      ? order === 'desc'
                        ? 'descending'
                        : 'ascending'
                      : 'none';

                  return (
                    <th
                      key={header.id}
                      scope="col"
                      aria-sort={ariaSort}
                      className={`whitespace-nowrap px-4 py-3 text-start text-body-sm font-medium uppercase tracking-wide text-neutral-600 ${
                        index === 0 ? 'sticky left-0 z-10 bg-surface-muted' : ''
                      }`}
                    >
                      {header.isPlaceholder ? null : canSort ? (
                        <button
                          type="button"
                          onClick={() => handleSort(header.column.id)}
                          className="inline-flex items-center gap-1 hover:text-neutral-700"
                        >
                          {flexRender(header.column.columnDef.header, header.getContext())}
                          <Icon
                            icon={
                              isSorted ? (order === 'desc' ? ArrowDown : ArrowUp) : ChevronsUpDown
                            }
                            size={14}
                            className={isSorted ? 'text-primary' : 'text-neutral-400'}
                          />
                        </button>
                      ) : (
                        flexRender(header.column.columnDef.header, header.getContext())
                      )}
                    </th>
                  );
                })}
              </tr>
            ))}
          </thead>

          <tbody>
            {isLoading ? (
              Array.from({ length: skeletonRowCount }).map((_, rowIndex) => (
                <tr key={`skeleton-${rowIndex}`} className="border-t border-stroke">
                  {Array.from({ length: visibleColumnCount }).map((__, cellIndex) => (
                    <td key={`skeleton-cell-${cellIndex}`} className="px-4 py-3">
                      <Skeleton variant="text" />
                    </td>
                  ))}
                </tr>
              ))
            ) : isError ? (
              <tr>
                <td colSpan={visibleColumnCount || 1} className="p-8">
                  <ErrorState
                    message={errorMessage ?? t('ui.data.dataTable.error.message')}
                    onRetry={onRetry}
                  />
                </td>
              </tr>
            ) : rows.length === 0 ? (
              <tr>
                <td colSpan={visibleColumnCount || 1} className="p-8">
                  <EmptyState
                    title={emptyTitle}
                    description={emptyDescription}
                    action={
                      onClearFilters ? (
                        <button
                          type="button"
                          onClick={onClearFilters}
                          className="text-body-sm font-medium text-primary hover:underline"
                        >
                          {t('ui.overlay.emptyState.clearFilters')}
                        </button>
                      ) : undefined
                    }
                  />
                </td>
              </tr>
            ) : (
              rows.map((row) => (
                <tr
                  key={row.id}
                  className={`border-t border-stroke bg-surface ${onRowClick ? 'cursor-pointer hover:bg-surface-muted' : ''}`}
                  {...(onRowClick
                    ? {
                        // `role="button"` ataylab qo'yilmagan: qator ichida
                        // haqiqiy interaktiv element (`__actions` tugmasi)
                        // bor — ARIA interaktiv rollarni ichma-ich
                        // joylashtirishni taqiqlaydi (axe `nested-interactive`,
                        // serious). `tabIndex`/`onKeyDown` orqali klaviatura
                        // bilan baribir yetiladi va `Enter`/`Space` ishlaydi;
                        // faqat ekran o'quvchisiga "button" deb e'lon
                        // qilinmaydi (qator semantikasi — implicit `row`).
                        tabIndex: 0,
                        onClick: () => onRowClick(row.original),
                        onKeyDown: (event: KeyboardEvent<HTMLTableRowElement>) => {
                          if (event.key === 'Enter' || event.key === ' ') {
                            event.preventDefault();
                            onRowClick(row.original);
                          }
                        },
                      }
                    : {})}
                >
                  {row.getVisibleCells().map((cell, index) => (
                    <td
                      key={cell.id}
                      className={`px-4 py-3 text-body text-neutral-800 ${
                        index === 0 ? 'sticky left-0 z-10 bg-surface' : ''
                      }`}
                      onClick={
                        cell.column.id === '__actions'
                          ? (event) => event.stopPropagation()
                          : undefined
                      }
                    >
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
