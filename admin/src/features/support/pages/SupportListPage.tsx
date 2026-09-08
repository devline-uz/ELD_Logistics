/**
 * Contact Support — `/support` (8.8, `docs/tz/07-9-chat-support-audit.md`
 * §7.10.1). `GET /support-tickets` (`support.read`); filters: `status`,
 * `driver_id`, `search` (subject), `from`/`to`.
 *
 * **F134**: ticket identifier column is `Ticket #` / `Subject` in both the
 * empty and populated state (no `Ticket ID`/`Message` variant from the
 * design). Ticket # has no dedicated numeric field in the backend DTO — the
 * first 8 chars of the UUID are shown, matching the DVIR/report convention.
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import type { ColumnDef } from '@tanstack/react-table';

import { useSupportTicketsList } from '@/api/queries/support';
import { useDriversList } from '@/api/queries/drivers';
import type { SupportTicket, SupportTicketsListParams } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { DateRangePicker, type DateRange } from '@/components/ui/DateRangePicker';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { NA, formatPersonName, toDateParam } from '@/lib/format';

import { SupportStatusBadge } from '../components/SupportStatusBadge';
import { SUPPORT_TICKET_STATUSES } from '../lib/status';

const TABLE_ID = 'support-tickets';

function ticketNumber(ticket: SupportTicket): string {
  return ticket.id ? `#${ticket.id.slice(0, 8).toUpperCase()}` : NA;
}

function isoDate(date: Date | null): string | undefined {
  return date ? toDateParam(date) : undefined;
}

function parseIso(value: string | undefined): Date | null {
  if (!value) return null;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

export function SupportListPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const dateFormat = useDateFormat();
  const listParams = useListParams();

  const drivers = useDriversList({ per_page: 50 });

  const queryParams = useMemo<SupportTicketsListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      search: listParams.search || undefined,
      status: (listParams.filters.status as SupportTicketsListParams['status']) || undefined,
      driver_id: listParams.filters.driver_id || undefined,
      from: listParams.filters.from || undefined,
      to: listParams.filters.to || undefined,
    }),
    [
      listParams.page,
      listParams.perPage,
      listParams.search,
      listParams.filters.status,
      listParams.filters.driver_id,
      listParams.filters.from,
      listParams.filters.to,
    ],
  );

  const list = useSupportTicketsList(queryParams);

  const openTicket = (ticket: SupportTicket) => {
    if (ticket.id) navigate(`/support/${encodeURIComponent(ticket.id)}`);
  };

  const columns: ColumnDef<SupportTicket, unknown>[] = useMemo(
    () => [
      {
        id: 'ticket_number',
        header: t('support.list.columns.ticketNumber'),
        cell: ({ row }) => ticketNumber(row.original),
      },
      {
        id: 'driver_name',
        header: t('support.list.columns.driverName'),
        cell: ({ row }) => row.original.driver_name ?? t('common.na'),
      },
      {
        id: 'subject',
        header: t('support.list.columns.subject'),
        cell: ({ row }) => row.original.subject ?? NA,
      },
      {
        id: 'issue_date',
        header: t('support.list.columns.issueDate'),
        cell: ({ row }) => dateFormat.formatDateTime(row.original.created_at),
      },
      {
        id: 'status',
        header: t('support.list.columns.status'),
        cell: ({ row }) => <SupportStatusBadge status={row.original.status} />,
      },
    ],
    [t, dateFormat],
  );

  const range: DateRange = {
    start: parseIso(listParams.filters.from),
    end: parseIso(listParams.filters.to),
  };

  return (
    <ListScreen
      title={t('support.list.title')}
      filtersBar={
        <div className="flex flex-col gap-3">
          <FiltersBar
            search={listParams.search}
            onSearchChange={listParams.setSearch}
            searchPlaceholder={t('support.list.filters.searchPlaceholder')}
            filters={[
              {
                key: 'status',
                label: t('support.list.filters.status'),
                options: SUPPORT_TICKET_STATUSES.map((value) => ({
                  value,
                  label: t(`enums.support_ticket_status.${value}`),
                })),
              },
              {
                key: 'driver_id',
                label: t('support.list.filters.driver'),
                options: (drivers.data?.data ?? []).map((driver) => ({
                  value: driver.id ?? '',
                  label: formatPersonName(driver, driver.id ?? ''),
                })),
              },
            ]}
            activeFilters={listParams.filters}
            onFilterChange={listParams.setFilter}
            onClearAll={listParams.clearFilters}
          />
          <DateRangePicker
            label={t('support.list.filters.dateRange')}
            value={range}
            onChange={(value) =>
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
          data={list.data?.data ?? []}
          isLoading={list.isLoading}
          isError={list.isError}
          errorMessage={list.error?.message}
          onRetry={() => void list.refetch()}
          emptyTitle={
            listParams.hasActiveFilters
              ? t('support.list.empty.filteredTitle')
              : t('support.list.empty.title')
          }
          emptyDescription={
            listParams.hasActiveFilters
              ? t('support.list.empty.filteredDescription')
              : t('support.list.empty.description')
          }
          onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
          getRowId={(ticket, index) => ticket.id ?? String(index)}
          onRowClick={openTicket}
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

export default SupportListPage;
