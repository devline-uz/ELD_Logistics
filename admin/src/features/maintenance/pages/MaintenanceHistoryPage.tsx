/**
 * Maintenance › **History** tabi — `/maintenance/history` (5.6, §7.6).
 * `GET /maintenance-records?unit_id=&status=&from=&to=` (`maintenance.read`).
 *
 * 13 ustun (11 dan ko'p) → **F56**: `Odometer`, `Engine Hours`, `Attachment`
 * default'da yashirin. `DataTable` ustun ko'rinishini `localStorage` da
 * saqlaydi; boshlang'ich yashirish shu ekranda bir marta ekiladi (foydalanuvchi
 * `⚙` orqali o'zgartirsa — tanlovi ustun turadi).
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import type { ColumnDef } from '@tanstack/react-table';

import { useMaintenanceRecordsList } from '@/api/queries/maintenance';
import type { MaintenanceRecord } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { RowActionsMenu } from '@/components/data/RowActionsMenu';
import { Badge } from '@/components/ui/Badge';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { useUnitSystem } from '@/hooks/useUnitSystem';

import { MAINTENANCE_TAB_PATHS, maintenanceTabs } from '../components/tabs';
import { RECORD_STATUSES } from '../constants';
import { useUnitLookup } from '../useUnitLookup';
import { NA } from '@/lib/format';

const TABLE_ID = 'maintenance-history';
const DEFAULT_HIDDEN_COLUMNS = ['odometer', 'engine_hours', 'attachment'];

/** F56 — birinchi ochilishda uchta ustun yashiriladi (keyin foydalanuvchi hal qiladi). */
function seedHiddenColumns(): void {
  const key = `table:${TABLE_ID}:columns`;
  try {
    if (window.localStorage.getItem(key) !== null) return;
    const visibility: Record<string, boolean> = {};
    for (const id of DEFAULT_HIDDEN_COLUMNS) visibility[id] = false;
    window.localStorage.setItem(key, JSON.stringify(visibility));
  } catch {
    // localStorage yo'q (privat rejim) — barcha ustunlar ko'rinadi, xato emas.
  }
}

export function MaintenanceHistoryPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const listParams = useListParams();
  const { formatDate } = useDateFormat();
  const { formatDistance } = useUnitSystem();
  const { units, byId } = useUnitLookup();

  // Jadval o'z holatini `useState` initializer'ida o'qiydi — ekish undan oldin
  // bo'lishi uchun render tanasida (bir martalik, idempotent).
  seedHiddenColumns();

  const queryParams = useMemo(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      unit_id: listParams.filters.unit_id || undefined,
      status:
        (listParams.filters.status as (typeof RECORD_STATUSES)[number] | undefined) || undefined,
      from: listParams.filters.from || undefined,
      to: listParams.filters.to || undefined,
    }),
    [
      listParams.page,
      listParams.perPage,
      listParams.filters.unit_id,
      listParams.filters.status,
      listParams.filters.from,
      listParams.filters.to,
    ],
  );

  const list = useMaintenanceRecordsList(queryParams);

  const columns: ColumnDef<MaintenanceRecord, unknown>[] = useMemo(
    () => [
      {
        id: 'performed_at',
        header: t('maintenance.history.columns.date'),
        cell: ({ row }) => (row.original.performed_at ? formatDate(row.original.performed_at) : NA),
      },
      {
        id: 'unit_number',
        header: t('maintenance.history.columns.unit'),
        cell: ({ row }) => row.original.unit_number ?? NA,
      },
      {
        // Backend `Record` da haydovchi yo'q — §16 nomzodi (hisobotda).
        id: 'driver',
        header: t('maintenance.history.columns.driver'),
        cell: () => NA,
      },
      {
        id: 'make_model',
        header: t('maintenance.history.columns.makeModel'),
        cell: ({ row }) => {
          const unit = byId.get(row.original.unit_id ?? '');
          if (!unit?.make && !unit?.model) return NA;
          return [unit?.make, unit?.model].filter(Boolean).join(' ');
        },
      },
      {
        id: 'type',
        header: t('maintenance.history.columns.type'),
        cell: () => NA,
      },
      {
        id: 'status',
        header: t('maintenance.history.columns.status'),
        cell: ({ row }) => (
          <Badge tone={row.original.status === 'completed' ? 'success' : 'neutral'}>
            {t(`enums.maintenance_record_status.${row.original.status ?? 'completed'}`)}
          </Badge>
        ),
      },
      {
        id: 'invoice_no',
        header: t('maintenance.history.columns.invoiceNo'),
        cell: ({ row }) => row.original.invoice_no ?? NA,
      },
      {
        id: 'vendor',
        header: t('maintenance.history.columns.vendor'),
        cell: ({ row }) => row.original.vendor ?? NA,
      },
      {
        id: 'cost',
        header: t('maintenance.history.columns.cost'),
        cell: ({ row }) =>
          typeof row.original.cost === 'number'
            ? row.original.cost.toLocaleString('en-US', {
                style: 'currency',
                currency: row.original.currency ?? 'USD',
              })
            : NA,
      },
      {
        id: 'schedule_name',
        header: t('maintenance.history.columns.scheduleName'),
        cell: () => NA,
      },
      {
        id: 'odometer',
        header: t('maintenance.history.columns.odometer'),
        cell: ({ row }) => formatDistance(row.original.odometer_m),
      },
      {
        id: 'engine_hours',
        header: t('maintenance.history.columns.engineHours'),
        cell: ({ row }) =>
          typeof row.original.engine_hours === 'number'
            ? t('maintenance.units.engineHours', { count: row.original.engine_hours })
            : NA,
      },
      {
        id: 'attachment',
        header: t('maintenance.history.columns.attachment'),
        cell: ({ row }) =>
          row.original.invoice_key
            ? t('maintenance.history.attachmentPresent')
            : t('maintenance.history.attachmentNone'),
      },
    ],
    [t, formatDate, formatDistance, byId],
  );

  const openRecord = (row: MaintenanceRecord) => {
    if (row.schedule_unit_id)
      navigate(`/maintenance/history/${encodeURIComponent(row.schedule_unit_id)}`);
  };

  return (
    <ListScreen
      title={t('maintenance.title')}
      tabs={maintenanceTabs(t)}
      activeTab="history"
      onTabChange={(key) => navigate(MAINTENANCE_TAB_PATHS[key as 'schedules' | 'due'])}
      filtersBar={
        <FiltersBar
          search={listParams.search}
          onSearchChange={listParams.setSearch}
          searchPlaceholder={t('maintenance.history.filters.searchPlaceholder')}
          filters={[
            {
              key: 'status',
              label: t('maintenance.history.filters.status'),
              options: RECORD_STATUSES.map((value) => ({
                value,
                label: t(`enums.maintenance_record_status.${value}`),
              })),
            },
            {
              key: 'unit_id',
              label: t('maintenance.history.columns.unit'),
              options: units
                .filter((unit): unit is typeof unit & { id: string } => Boolean(unit.id))
                .map((unit) => ({ value: unit.id, label: unit.unit_number ?? unit.id })),
            },
          ]}
          activeFilters={listParams.filters}
          onFilterChange={listParams.setFilter}
          onClearAll={listParams.clearFilters}
        />
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
          emptyTitle={t('maintenance.empty.title')}
          emptyDescription={
            listParams.hasActiveFilters
              ? t('maintenance.empty.filteredDescription')
              : t('maintenance.empty.description')
          }
          onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
          getRowId={(row, index) => row.id ?? String(index)}
          onRowClick={openRecord}
          rowActions={(row) => (
            <RowActionsMenu
              ariaLabel={t('maintenance.history.rowActionsLabel', { unit: row.unit_number })}
              items={[
                {
                  key: 'view',
                  label: t('maintenance.actions.view'),
                  onSelect: () => openRecord(row),
                  disabled: !row.schedule_unit_id,
                },
              ]}
            />
          )}
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

export default MaintenanceHistoryPage;
