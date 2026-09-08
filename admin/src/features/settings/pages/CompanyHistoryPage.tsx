/**
 * Settings › Company history — `/settings/history` (8.7, §7.13.5).
 * `GET /company/history` (`company.history.view`).
 *
 * Filtrlar: `user` (muharrir ID) + `table` (jadval nomi) + sana oralig'i
 * (`from`/`to`). F149: dizayndagi uchta mustaqil qidiruv o'rniga bitta
 * `user` filtri — `Dispatcher` so'zi (begona rol nomi) ishlatilmaydi.
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';

import { useCompanyHistory } from '@/api/queries/company';
import type { CompanyHistoryParams } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { DateRangePicker, type DateRange } from '@/components/ui/DateRangePicker';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { toDateParam } from '@/lib/format';

import { DebouncedTextFilter } from '../history/components/DebouncedTextFilter';
import { buildHistoryColumns } from '../history/components/historyColumns';

function isoDate(date: Date | null): string | undefined {
  return date ? toDateParam(date) : undefined;
}

function parseIso(value: string | undefined): Date | null {
  if (!value) return null;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

export function CompanyHistoryPage() {
  const { t } = useTranslation();
  const dateFormat = useDateFormat();
  const listParams = useListParams();

  const queryParams = useMemo<CompanyHistoryParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      user: listParams.filters.user || undefined,
      table: listParams.filters.table || undefined,
      from: listParams.filters.from || undefined,
      to: listParams.filters.to || undefined,
    }),
    [
      listParams.page,
      listParams.perPage,
      listParams.filters.user,
      listParams.filters.table,
      listParams.filters.from,
      listParams.filters.to,
    ],
  );

  const list = useCompanyHistory(queryParams);
  const columns = buildHistoryColumns(t, { dateFormat });

  const range: DateRange = {
    start: parseIso(listParams.filters.from),
    end: parseIso(listParams.filters.to),
  };

  const hasActiveFilters = listParams.hasActiveFilters;

  return (
    <ListScreen
      title={t('settings.history.title')}
      filtersBar={
        <div className="flex flex-wrap items-end gap-3">
          <DebouncedTextFilter
            value={listParams.filters.user ?? ''}
            onChange={(value) => listParams.setFilter('user', value || undefined)}
            label={t('settings.history.filters.user')}
            placeholder={t('settings.history.filters.userPlaceholder')}
            className="w-56"
          />

          <DebouncedTextFilter
            value={listParams.filters.table ?? ''}
            onChange={(value) => listParams.setFilter('table', value || undefined)}
            label={t('settings.history.filters.table')}
            placeholder={t('settings.history.filters.tablePlaceholder')}
            className="w-56"
          />

          <DateRangePicker
            label={t('settings.history.filters.dateRange')}
            value={range}
            onChange={(value) =>
              listParams.setFilters({ from: isoDate(value.start), to: isoDate(value.end) })
            }
            className="w-72"
          />

          {hasActiveFilters ? (
            <button
              type="button"
              onClick={listParams.clearFilters}
              className="text-body-sm font-medium text-primary hover:underline"
            >
              {t('ui.form.actions.clearAll')}
            </button>
          ) : null}
        </div>
      }
      table={
        <DataTable
          tableId="settings-history"
          columns={columns}
          data={list.data?.data ?? []}
          isLoading={list.isLoading}
          isError={list.isError}
          errorMessage={list.error?.message}
          onRetry={() => void list.refetch()}
          emptyTitle={
            hasActiveFilters
              ? t('settings.history.empty.filteredTitle')
              : t('settings.history.empty.title')
          }
          emptyDescription={
            hasActiveFilters
              ? t('settings.history.empty.filteredDescription')
              : t('settings.history.empty.description')
          }
          onClearFilters={hasActiveFilters ? listParams.clearFilters : undefined}
          getRowId={(item, index) => item.id ?? String(index)}
        />
      }
      pagination={
        <Pagination
          page={listParams.page}
          perPage={listParams.perPage}
          total={list.data?.meta?.total ?? 0}
          onPageChange={listParams.setPage}
          onPerPageChange={listParams.setPerPage}
        />
      }
    />
  );
}

export default CompanyHistoryPage;
