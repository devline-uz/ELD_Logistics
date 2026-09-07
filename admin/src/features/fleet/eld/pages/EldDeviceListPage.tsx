/**
 * ELD Devices — `/eld-devices` (2.6, `docs/tz/07-3-fleet.md` §7.3.6, 🎨 F88).
 * Dizaynda yo'q — standart ro'yxat patterni (fe-screens §6).
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useSearchParams } from 'react-router-dom';
import type { ColumnDef } from '@tanstack/react-table';

import { useEldDeviceDelete, useEldDevicesList } from '@/api/queries/eldDevices';
import type { EldDevice, EldDevicesListParams } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar, type FilterDef } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { useToast } from '@/components/feedback/toast-context';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { useWriteGuard } from '@/hooks/useWriteGuard';
import { isApiError } from '@/lib/errors';
import { PERM } from '@/lib/permissions';

import { CONNECTION_TYPES, DEVICE_STATUSES } from '../schemas';
import { EldDeviceAssignUnitModal } from '../components/EldDeviceAssignUnitModal';
import { EldDeviceFormModal } from '../components/EldDeviceFormModal';
import { RowActionsMenu } from '@/components/data/RowActionsMenu';

const STATUS_TONE: Record<string, 'success' | 'neutral' | 'error'> = {
  active: 'success',
  inactive: 'neutral',
  malfunction: 'error',
};

export function EldDeviceListPage() {
  const { t } = useTranslation();
  const toast = useToast();
  const { formatDateTime } = useDateFormat();
  const { canWrite, disabledReason } = useWriteGuard();
  const [searchParams, setSearchParams] = useSearchParams();
  const listParams = useListParams();

  const modal = searchParams.get('modal');
  const editId = searchParams.get('id') ?? undefined;
  const [deviceToDelete, setDeviceToDelete] = useState<EldDevice | undefined>(undefined);
  const [deviceToAssign, setDeviceToAssign] = useState<EldDevice | undefined>(undefined);

  const queryParams = useMemo<EldDevicesListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      sort: listParams.sort as EldDevicesListParams['sort'],
      order: listParams.order,
      search: listParams.search || undefined,
      status: listParams.filters.status as EldDevicesListParams['status'],
      connection_type: listParams.filters
        .connection_type as EldDevicesListParams['connection_type'],
    }),
    [
      listParams.page,
      listParams.perPage,
      listParams.sort,
      listParams.order,
      listParams.search,
      listParams.filters.status,
      listParams.filters.connection_type,
    ],
  );

  const list = useEldDevicesList(queryParams);
  const remove = useEldDeviceDelete();

  const editingDevice = useMemo(
    () => (editId ? list.data?.data?.find((device) => device.id === editId) : undefined),
    [editId, list.data],
  );

  const closeModal = () =>
    setSearchParams(
      (prev) => {
        const next = new URLSearchParams(prev);
        next.delete('modal');
        next.delete('id');
        return next;
      },
      { replace: true },
    );

  const openAddModal = () =>
    setSearchParams(
      (prev) => {
        const next = new URLSearchParams(prev);
        next.set('modal', 'add');
        next.delete('id');
        return next;
      },
      { replace: true },
    );

  const openEditModal = (device: EldDevice) =>
    setSearchParams(
      (prev) => {
        const next = new URLSearchParams(prev);
        next.set('modal', 'edit');
        if (device.id) next.set('id', device.id);
        return next;
      },
      { replace: true },
    );

  const filterDefs: FilterDef[] = [
    {
      key: 'status',
      label: t('fleet.eldDevices.filters.status'),
      options: DEVICE_STATUSES.map((value) => ({
        value,
        label: t(`fleet.eldDevices.statuses.${value}`),
      })),
    },
    {
      key: 'connection_type',
      label: t('fleet.eldDevices.filters.connectionType'),
      options: CONNECTION_TYPES.map((value) => ({
        value,
        label: t(`fleet.eldDevices.connectionTypes.${value}`),
      })),
    },
  ];

  const columns: ColumnDef<EldDevice, unknown>[] = [
    {
      id: 'serial',
      accessorKey: 'serial',
      header: t('fleet.eldDevices.columns.serial'),
      enableSorting: true,
    },
    {
      id: 'vendor',
      accessorKey: 'vendor',
      header: t('fleet.eldDevices.columns.vendor'),
      enableSorting: true,
    },
    { id: 'model', accessorKey: 'model', header: t('fleet.eldDevices.columns.model') },
    { id: 'firmware', accessorKey: 'firmware', header: t('fleet.eldDevices.columns.firmware') },
    {
      id: 'connection_type',
      header: t('fleet.eldDevices.columns.connection'),
      cell: ({ row }) =>
        row.original.connection_type
          ? t(`fleet.eldDevices.connectionTypes.${row.original.connection_type}`)
          : '—',
    },
    {
      id: 'status',
      header: t('fleet.eldDevices.columns.status'),
      enableSorting: true,
      cell: ({ row }) => (
        <Badge tone={STATUS_TONE[row.original.status ?? 'inactive']}>
          {t(`fleet.eldDevices.statuses.${row.original.status ?? 'inactive'}`)}
        </Badge>
      ),
    },
    {
      id: 'unit_number',
      header: t('fleet.eldDevices.columns.assignedUnit'),
      cell: ({ row }) => row.original.unit_number ?? t('fleet.eldDevices.unassigned'),
    },
    {
      id: 'last_seen_at',
      header: t('fleet.eldDevices.columns.lastSeen'),
      enableSorting: true,
      cell: ({ row }) => formatDateTime(row.original.last_seen_at),
    },
  ];

  const handleDelete = async () => {
    if (!deviceToDelete?.id) return;
    try {
      await remove.mutateAsync(deviceToDelete.id);
      toast.show({
        variant: 'success',
        message: t('fleet.eldDevices.toast.deleted', { serial: deviceToDelete.serial }),
      });
      setDeviceToDelete(undefined);
    } catch (error) {
      toast.show({
        variant: 'error',
        message:
          isApiError(error) && error.status === 409
            ? t('fleet.eldDevices.toast.deleteConflict')
            : t('errors.unknown'),
      });
    }
  };

  return (
    <>
      <ListScreen
        title={t('fleet.eldDevices.title')}
        actions={
          <PermissionGate permission={PERM.eldDevicesCreate}>
            <Button onClick={openAddModal}>{t('fleet.eldDevices.actions.register')}</Button>
          </PermissionGate>
        }
        filtersBar={
          <FiltersBar
            search={listParams.search}
            onSearchChange={listParams.setSearch}
            searchPlaceholder={t('fleet.eldDevices.filters.searchPlaceholder')}
            filters={filterDefs}
            activeFilters={listParams.filters}
            onFilterChange={listParams.setFilter}
            onClearAll={listParams.clearFilters}
          />
        }
        table={
          <DataTable
            tableId="eldDevices"
            columns={columns}
            data={list.data?.data ?? []}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            emptyTitle={t('fleet.eldDevices.empty.title')}
            emptyDescription={
              listParams.hasActiveFilters
                ? t('fleet.eldDevices.empty.filteredDescription')
                : t('fleet.eldDevices.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            sort={listParams.sort}
            order={listParams.order}
            onSortChange={listParams.setSort}
            getRowId={(device, index) => device.id ?? String(index)}
            rowActions={(device) => (
              <RowActionsMenu
                ariaLabel={t('fleet.eldDevices.rowActionsLabel', { serial: device.serial })}
                items={[
                  {
                    key: 'edit',
                    label: t('common.actions.edit'),
                    onSelect: () => openEditModal(device),
                    disabled: !canWrite(PERM.eldDevicesUpdate),
                    disabledReason: disabledReason(PERM.eldDevicesUpdate),
                  },
                  {
                    key: 'assign',
                    label: t('fleet.eldDevices.actions.assignToUnit'),
                    onSelect: () => setDeviceToAssign(device),
                    disabled: !canWrite(PERM.eldDevicesAssignUnit),
                    disabledReason: disabledReason(PERM.eldDevicesAssignUnit),
                  },
                  {
                    key: 'delete',
                    label: t('common.actions.delete'),
                    danger: true,
                    onSelect: () => setDeviceToDelete(device),
                    disabled: !canWrite(PERM.eldDevicesDelete),
                    disabledReason: disabledReason(PERM.eldDevicesDelete),
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

      <EldDeviceFormModal
        open={modal === 'add' || modal === 'edit'}
        onClose={closeModal}
        device={modal === 'edit' ? editingDevice : undefined}
      />

      {deviceToAssign ? (
        <EldDeviceAssignUnitModal
          open
          onClose={() => setDeviceToAssign(undefined)}
          device={deviceToAssign}
        />
      ) : null}

      <ConfirmDialog
        open={Boolean(deviceToDelete)}
        onClose={() => setDeviceToDelete(undefined)}
        onConfirm={() => void handleDelete()}
        loading={remove.isPending}
        variant="danger"
        description={t('fleet.eldDevices.confirm.deleteDescription', {
          serial: deviceToDelete?.serial,
        })}
      />
    </>
  );
}

export default EldDeviceListPage;
