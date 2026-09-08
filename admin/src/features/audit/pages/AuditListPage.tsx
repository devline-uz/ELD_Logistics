/**
 * Histories — `/audit` (8.10, §7.10.3). `GET /audit-log` (`audit.view`);
 * filters `table` (`GET /audit-log/tables`) and `user`
 * (`GET /users` — acting user, matches `audit_log.edited_by`), plus a date
 * range. Append-only (F141) — no row action, no create/edit/delete.
 *
 * **F138**: this is the single audit trail; `Unit Activities`/`Driver
 * Activities`/`Company history` are filtered views of the same table living
 * on their own routes (owned by fleet/settings, out of scope here).
 * **F139**: the design's `Add User` button and the `Export Drivers`/
 * `Import Drivers` filter buttons are **not** rendered on this screen — they
 * do not belong here (§16).
 * **F140**: date column shows a 3-letter weekday (`formatDateWithWeekday`),
 * not the design's 4-letter `Tues`/`Thurs`.
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import type { ColumnDef } from '@tanstack/react-table';

import { useAuditLogList, useAuditLogTables } from '@/api/queries/audit';
import { useUsersList } from '@/api/queries/users';
import type { AuditLogEntry, AuditLogListParams } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { Badge } from '@/components/ui/Badge';
import { DateRangePicker, type DateRange } from '@/components/ui/DateRangePicker';
import { Select } from '@/components/ui/Select';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { NA, toDateParam } from '@/lib/format';

import { formatAuditChange } from '../lib/changes';

const TABLE_ID = 'audit-log';

function isoDate(date: Date | null): string | undefined {
  return date ? toDateParam(date) : undefined;
}

function parseIso(value: string | undefined): Date | null {
  if (!value) return null;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

export function AuditListPage() {
  const { t } = useTranslation();
  const dateFormat = useDateFormat();
  const listParams = useListParams();

  const tables = useAuditLogTables();
  const users = useUsersList({ per_page: 50 });

  const queryParams = useMemo<AuditLogListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      table: listParams.filters.table || undefined,
      user: listParams.filters.user || undefined,
      from: listParams.filters.from || undefined,
      to: listParams.filters.to || undefined,
    }),
    [
      listParams.page,
      listParams.perPage,
      listParams.filters.table,
      listParams.filters.user,
      listParams.filters.from,
      listParams.filters.to,
    ],
  );

  const list = useAuditLogList(queryParams);
  const rows = list.data?.data ?? [];

  const columns: ColumnDef<AuditLogEntry, unknown>[] = useMemo(
    () => [
      {
        id: 'ts',
        header: t('audit.list.columns.date'),
        cell: ({ row }) =>
          `${dateFormat.formatWeekday(row.original.ts)}, ${dateFormat.formatDateTime(row.original.ts)}`,
      },
      {
        id: 'user',
        header: t('audit.list.columns.user'),
        cell: ({ row }) => row.original.edited_by_name ?? row.original.username ?? NA,
      },
      {
        id: 'action',
        header: t('audit.list.columns.action'),
        cell: ({ row }) =>
          row.original.action ? (
            <Badge tone="neutral">{t(`enums.audit_action.${row.original.action}`)}</Badge>
          ) : (
            NA
          ),
      },
      {
        id: 'table',
        header: t('audit.list.columns.table'),
        cell: ({ row }) => row.original.table ?? NA,
      },
      {
        id: 'record_id',
        header: t('audit.list.columns.record'),
        cell: ({ row }) => row.original.record_id ?? NA,
      },
      {
        id: 'changes',
        header: t('audit.list.columns.changes'),
        cell: ({ row }) => formatAuditChange(t, row.original),
      },
    ],
    [t, dateFormat],
  );

  return (
    <ListScreen
      title={t('audit.list.title')}
      filtersBar={
        <div className="flex flex-col gap-3">
          <div className="flex flex-wrap items-center gap-3">
            <Select
              value={listParams.filters.table ?? null}
              onChange={(value) => listParams.setFilter('table', value ?? undefined)}
              options={(tables.data ?? []).map((table) => ({ value: table, label: table }))}
              placeholder={t('audit.list.filters.table')}
              clearable
              loading={tables.isLoading}
              className="w-56"
            />
            <Select
              value={listParams.filters.user ?? null}
              onChange={(value) => listParams.setFilter('user', value ?? undefined)}
              options={(users.data?.data ?? []).map((user) => ({
                value: user.id ?? '',
                label: user.full_name ?? user.email ?? user.id ?? '',
              }))}
              placeholder={t('audit.list.filters.user')}
              clearable
              loading={users.isLoading}
              className="w-56"
            />
            {listParams.hasActiveFilters ? (
              <button
                type="button"
                onClick={listParams.clearFilters}
                className="text-body-sm font-medium text-primary hover:underline"
              >
                {t('ui.form.actions.clearAll')}
              </button>
            ) : null}
          </div>
          <DateRangePicker
            label={t('audit.list.filters.dateRange')}
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
              ? t('audit.list.empty.filteredTitle')
              : t('audit.list.empty.title')
          }
          emptyDescription={
            listParams.hasActiveFilters
              ? t('audit.list.empty.filteredDescription')
              : t('audit.list.empty.description')
          }
          onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
          getRowId={(row, index) => row.id ?? String(index)}
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

export default AuditListPage;
