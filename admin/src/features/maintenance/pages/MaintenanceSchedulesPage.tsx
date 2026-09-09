/**
 * Maintenance › **Schedule** tabi — `/maintenance/schedules` (5.6, §7.6).
 *
 * `GET /maintenance-schedules?status=&q=` (`maintenance.read`).
 * Ustunlar: `# · Unit # (yoki «N Units») · Type · Schedule Name ·
 * Maintenance Frequency · Status · Action`.
 *
 * **N11/F109** — ustunlar to'plami ma'lumot borligiga qarab hech qachon
 * o'zgarmaydi: `DataTable` bo'sh holatda ham xuddi shu `columns` bilan
 * chaqiriladi, jadval sarlavhasi va sahifalash ko'rinib turadi.
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import type { ColumnDef } from '@tanstack/react-table';

import {
  useMaintenanceDue,
  useMaintenanceScheduleDelete,
  useMaintenanceSchedulesList,
} from '@/api/queries/maintenance';
import type { MaintenanceSchedule } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { RowActionsMenu } from '@/components/data/RowActionsMenu';
import { useToast } from '@/components/feedback/toast-context';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { useListParams } from '@/hooks/useListParams';
import { useWriteGuard } from '@/hooks/useWriteGuard';
import { PERM } from '@/lib/permissions';

import { MaintenanceFormModal } from '../components/MaintenanceFormModal';
import { MAINTENANCE_TAB_PATHS, maintenanceTabs } from '../components/tabs';
import { SCHEDULE_STATUSES } from '../constants';
import { useIntervalFormat } from '../useIntervalFormat';
import { NA } from '@/lib/format';

export function MaintenanceSchedulesPage() {
  const { t } = useTranslation();
  const toast = useToast();
  const navigate = useNavigate();
  const listParams = useListParams();
  const { canWrite, disabledReason } = useWriteGuard();
  const { formatInterval } = useIntervalFormat();
  const [searchParams, setSearchParams] = useSearchParams();
  const [scheduleToDelete, setScheduleToDelete] = useState<MaintenanceSchedule | undefined>(
    undefined,
  );

  const modal = searchParams.get('modal');
  const editId = searchParams.get('id') ?? undefined;

  const queryParams = useMemo(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      q: listParams.search || undefined,
      status: (listParams.filters.status as 'active' | 'inactive' | undefined) || undefined,
    }),
    [listParams.page, listParams.perPage, listParams.search, listParams.filters.status],
  );

  const list = useMaintenanceSchedulesList(queryParams);
  const remove = useMaintenanceScheduleDelete();

  const editingSchedule = useMemo(
    () => (editId ? list.data?.data?.find((row) => row.id === editId) : undefined),
    [editId, list.data],
  );

  /** Tahrirlashda biriktirilgan unit qatorlari — `last_service_value` uchun. */
  const editingUnits = useMaintenanceDue(
    editId ? { schedule_id: editId, per_page: 50 } : { per_page: 50 },
  );

  const updateParams = (mutate: (next: URLSearchParams) => void) =>
    setSearchParams(
      (prev) => {
        const next = new URLSearchParams(prev);
        mutate(next);
        return next;
      },
      { replace: true },
    );

  const closeModal = () =>
    updateParams((next) => {
      next.delete('modal');
      next.delete('id');
    });

  const columns: ColumnDef<MaintenanceSchedule, unknown>[] = useMemo(
    () => [
      {
        id: 'index',
        header: t('maintenance.schedules.columns.index'),
        cell: ({ row }) => (listParams.page - 1) * listParams.perPage + row.index + 1,
      },
      {
        id: 'units',
        header: t('maintenance.schedules.columns.unit'),
        cell: ({ row }) => {
          const count = row.original.unit_count ?? 0;
          if (count === 0) return t('maintenance.schedules.noUnits');
          return (
            <Link
              to={`/maintenance/schedules/${encodeURIComponent(row.original.id ?? '')}/units`}
              onClick={(event) => event.stopPropagation()}
              className="text-primary hover:underline"
            >
              {t('maintenance.schedules.unitCount', { count })}
            </Link>
          );
        },
      },
      {
        id: 'type',
        header: t('maintenance.schedules.columns.type'),
        cell: ({ row }) =>
          row.original.type ? t(`enums.maintenance_type.${row.original.type}`) : NA,
      },
      {
        id: 'name',
        accessorKey: 'name',
        header: t('maintenance.schedules.columns.name'),
      },
      {
        id: 'interval',
        header: t('maintenance.schedules.columns.frequency'),
        cell: ({ row }) => formatInterval(row.original.interval_value, row.original.interval_unit),
      },
      {
        id: 'status',
        header: t('maintenance.schedules.columns.status'),
        cell: ({ row }) => (
          <Badge tone={row.original.status === 'active' ? 'success' : 'neutral'}>
            {t(`enums.maintenance_schedule_status.${row.original.status ?? 'inactive'}`)}
          </Badge>
        ),
      },
    ],
    [t, formatInterval, listParams.page, listParams.perPage],
  );

  const handleDelete = async () => {
    if (!scheduleToDelete?.id) return;
    try {
      await remove.mutateAsync(scheduleToDelete.id);
      toast.show({
        variant: 'success',
        message: t('maintenance.toast.deleted', { name: scheduleToDelete.name }),
      });
      setScheduleToDelete(undefined);
    } catch {
      toast.show({ variant: 'error', message: t('errors.unknown') });
    }
  };

  return (
    <>
      <ListScreen
        title={t('maintenance.title')}
        tabs={maintenanceTabs(t)}
        activeTab="schedules"
        onTabChange={(key) => navigate(MAINTENANCE_TAB_PATHS[key as 'due' | 'history'])}
        actions={
          <PermissionGate permission={PERM.maintenanceCreate}>
            <Button
              onClick={() =>
                updateParams((next) => {
                  next.set('modal', 'add');
                  next.delete('id');
                })
              }
            >
              {t('maintenance.actions.add')}
            </Button>
          </PermissionGate>
        }
        filtersBar={
          <FiltersBar
            search={listParams.search}
            onSearchChange={listParams.setSearch}
            searchPlaceholder={t('maintenance.schedules.filters.searchPlaceholder')}
            filters={[
              {
                key: 'status',
                label: t('maintenance.schedules.filters.status'),
                options: SCHEDULE_STATUSES.map((value) => ({
                  value,
                  label: t(`enums.maintenance_schedule_status.${value}`),
                })),
              },
            ]}
            activeFilters={listParams.filters}
            onFilterChange={listParams.setFilter}
            onClearAll={listParams.clearFilters}
          />
        }
        table={
          <DataTable
            tableId="maintenance-schedules"
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
            onRowClick={(row) =>
              navigate(`/maintenance/schedules/${encodeURIComponent(row.id ?? '')}`)
            }
            rowActions={(row) => (
              <RowActionsMenu
                ariaLabel={t('maintenance.schedules.rowActionsLabel', { name: row.name })}
                items={[
                  {
                    key: 'view',
                    label: t('maintenance.actions.view'),
                    onSelect: () =>
                      navigate(`/maintenance/schedules/${encodeURIComponent(row.id ?? '')}`),
                  },
                  {
                    key: 'edit',
                    label: t('common.actions.edit'),
                    onSelect: () =>
                      updateParams((next) => {
                        next.set('modal', 'edit');
                        if (row.id) next.set('id', row.id);
                      }),
                    disabled: !canWrite(PERM.maintenanceUpdate),
                    disabledReason: disabledReason(PERM.maintenanceUpdate),
                  },
                  {
                    key: 'delete',
                    label: t('common.actions.delete'),
                    danger: true,
                    onSelect: () => setScheduleToDelete(row),
                    disabled: !canWrite(PERM.maintenanceDelete),
                    disabledReason: disabledReason(PERM.maintenanceDelete),
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

      <MaintenanceFormModal
        open={modal === 'add' || modal === 'edit'}
        onClose={closeModal}
        schedule={modal === 'edit' ? editingSchedule : undefined}
        scheduleUnits={modal === 'edit' ? editingUnits.data?.data : undefined}
      />

      <ConfirmDialog
        open={Boolean(scheduleToDelete)}
        onClose={() => setScheduleToDelete(undefined)}
        onConfirm={() => void handleDelete()}
        loading={remove.isPending}
        variant="danger"
        description={t('maintenance.confirm.deleteDescription', { name: scheduleToDelete?.name })}
      />
    </>
  );
}

export default MaintenanceSchedulesPage;
