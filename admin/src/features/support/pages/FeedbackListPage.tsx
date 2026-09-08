/**
 * Feedback — `/feedback` (8.9, §7.10.2). `GET /feedback` (`feedback.read`);
 * filters `driver_id`, `min_rating`, `from`/`to`.
 *
 * **F137**: no reply action (feedback is never answered); long text is
 * truncated in the row and shown in full via `FeedbackDetailModal` on row
 * click (no dedicated detail endpoint — reuses the already-fetched row).
 *
 * D39: the design's `App version` column has no backend field
 * (`support_dto.Feedback` carries `id/driver_id/driver_name/app_rating/
 * text/submitted_at` only) — the column is kept for spec parity but always
 * renders `N/A`; see `docs/tz/16-17-registry-open-questions.md` D39.
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Star } from 'lucide-react';
import type { ColumnDef } from '@tanstack/react-table';

import { useDriversList } from '@/api/queries/drivers';
import { useFeedbackList } from '@/api/queries/feedback';
import type { Feedback, FeedbackListParams } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { Icon } from '@/components/ui/Icon';
import { DateRangePicker, type DateRange } from '@/components/ui/DateRangePicker';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { NA, formatPersonName, toDateParam } from '@/lib/format';

import { FeedbackDetailModal } from '../components/FeedbackDetailModal';

const TABLE_ID = 'feedback';
const RATING_OPTIONS = [1, 2, 3, 4, 5] as const;
const TRUNCATE_LENGTH = 80;

function truncate(text: string | undefined): string {
  if (!text) return NA;
  return text.length > TRUNCATE_LENGTH ? `${text.slice(0, TRUNCATE_LENGTH)}…` : text;
}

function isoDate(date: Date | null): string | undefined {
  return date ? toDateParam(date) : undefined;
}

function parseIso(value: string | undefined): Date | null {
  if (!value) return null;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

export function FeedbackListPage() {
  const { t } = useTranslation();
  const dateFormat = useDateFormat();
  const listParams = useListParams();
  const [selected, setSelected] = useState<Feedback | undefined>(undefined);

  const drivers = useDriversList({ per_page: 50 });

  const queryParams = useMemo<FeedbackListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      driver_id: listParams.filters.driver_id || undefined,
      min_rating: listParams.filters.min_rating ? Number(listParams.filters.min_rating) : undefined,
      from: listParams.filters.from || undefined,
      to: listParams.filters.to || undefined,
    }),
    [
      listParams.page,
      listParams.perPage,
      listParams.filters.driver_id,
      listParams.filters.min_rating,
      listParams.filters.from,
      listParams.filters.to,
    ],
  );

  const list = useFeedbackList(queryParams);
  const rows = list.data?.data ?? [];

  const columns: ColumnDef<Feedback, unknown>[] = useMemo(
    () => [
      {
        id: 'index',
        header: t('feedback.list.columns.number'),
        cell: ({ row }) => (listParams.page - 1) * listParams.perPage + row.index + 1,
      },
      {
        id: 'driver_name',
        header: t('feedback.list.columns.driverName'),
        cell: ({ row }) => row.original.driver_name ?? t('common.na'),
      },
      {
        id: 'app_rating',
        header: t('feedback.list.columns.appRating'),
        cell: ({ row }) => (
          <span className="inline-flex items-center gap-1">
            <Icon icon={Star} size={14} className="fill-warning-base text-warning-base" />
            {typeof row.original.app_rating === 'number' ? row.original.app_rating : NA}
          </span>
        ),
      },
      {
        id: 'text',
        header: t('feedback.list.columns.feedback'),
        cell: ({ row }) => truncate(row.original.text),
      },
      {
        id: 'app_version',
        header: t('feedback.list.columns.appVersion'),
        cell: () => NA,
      },
      {
        id: 'submitted_at',
        header: t('feedback.list.columns.submittedOn'),
        cell: ({ row }) => dateFormat.formatDateTime(row.original.submitted_at),
      },
    ],
    [t, dateFormat, listParams.page, listParams.perPage],
  );

  return (
    <div className="flex flex-col gap-4">
      <ListScreen
        title={t('feedback.list.title')}
        filtersBar={
          <div className="flex flex-col gap-3">
            <FiltersBar
              search={listParams.search}
              onSearchChange={listParams.setSearch}
              searchPlaceholder={t('feedback.list.filters.searchPlaceholder')}
              filters={[
                {
                  key: 'driver_id',
                  label: t('feedback.list.filters.driver'),
                  options: (drivers.data?.data ?? []).map((driver) => ({
                    value: driver.id ?? '',
                    label: formatPersonName(driver, driver.id ?? ''),
                  })),
                },
                {
                  key: 'min_rating',
                  label: t('feedback.list.filters.minRating'),
                  options: RATING_OPTIONS.map((value) => ({
                    value: String(value),
                    label: t('feedback.list.filters.minRatingOption', { count: value }),
                  })),
                },
              ]}
              activeFilters={listParams.filters}
              onFilterChange={listParams.setFilter}
              onClearAll={listParams.clearFilters}
            />
            <DateRangePicker
              label={t('feedback.list.filters.dateRange')}
              value={{
                start: parseIso(listParams.filters.from),
                end: parseIso(listParams.filters.to),
              }}
              onChange={(value: DateRange) =>
                listParams.setFilters({ from: isoDate(value.start), to: isoDate(value.end) })
              }
              className="w-72"
            />
          </div>
        }
        table={
          <DataTable
            tableId={TABLE_ID}
            columns={columns}
            data={rows}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            emptyTitle={
              listParams.hasActiveFilters
                ? t('feedback.list.empty.filteredTitle')
                : t('feedback.list.empty.title')
            }
            emptyDescription={
              listParams.hasActiveFilters
                ? t('feedback.list.empty.filteredDescription')
                : t('feedback.list.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            getRowId={(row, index) => row.id ?? String(index)}
            onRowClick={setSelected}
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
      <FeedbackDetailModal feedback={selected} onClose={() => setSelected(undefined)} />
    </div>
  );
}

export default FeedbackListPage;
