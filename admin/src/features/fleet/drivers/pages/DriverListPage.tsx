/**
 * Driver Management — `/drivers` (2.4, TZ 7.3.4).
 *
 * Ruxsat: `drivers.read`. Tablar Active/Inactive (+ `invited` badge bilan
 * Active ichida). Amallar: `Add Driver` · satr `View · Edit · Send password
 * reset · Activate/Deactivate · Delete`.
 */
import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import type { ColumnDef } from '@tanstack/react-table';

import {
  useDriverActivate,
  useDriverCreate,
  useDriverDeactivate,
  useDriverDelete,
  useDriverResetPassword,
  useDriverUpdate,
  useDriversList,
} from '@/api/queries/drivers';
import { useUsersList } from '@/api/queries/users';
import type { Driver, DriverCreate, DriversListParams, DriverUpdate } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar, type FilterDef } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { useToast } from '@/components/feedback/toast-context';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { useWriteGuard } from '@/hooks/useWriteGuard';
import { PERM } from '@/lib/permissions';

import { DriverFormModal } from '../components/DriverFormModal';
import { RowActionsMenu, type RowAction } from '../components/RowActionsMenu';

type DriverTab = 'active' | 'inactive';

/**
 * `GET /drivers` faqat `name|username|status|created_at` bo'yicha saralaydi
 * (swagger) — jadval `first_name`/`last_name` ustunlari ikkisi ham `name`
 * backend kalitiga tushadi.
 */
const DATA_TABLE_TO_API_SORT: Record<string, DriversListParams['sort']> = {
  first_name: 'name',
  last_name: 'name',
  username: 'username',
  status: 'status',
};

export function DriverListPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const toast = useToast();
  const { formatDate } = useDateFormat();
  const { canWrite, disabledReason } = useWriteGuard();
  const listParams = useListParams();

  const [tab, setTab] = useState<DriverTab>('active');
  const [formOpen, setFormOpen] = useState(false);
  const [editingDriver, setEditingDriver] = useState<Driver | undefined>();
  const [deactivateTarget, setDeactivateTarget] = useState<Driver | undefined>();
  const [deleteTarget, setDeleteTarget] = useState<Driver | undefined>();
  const [resetPasswordTarget, setResetPasswordTarget] = useState<Driver | undefined>();

  const queryParams = useMemo<DriversListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      search: listParams.search || undefined,
      status: tab === 'active' ? undefined : ('inactive' as const),
      sort: listParams.sort ? DATA_TABLE_TO_API_SORT[listParams.sort] : undefined,
      order: listParams.order,
      branch_id: listParams.filters.branch_id,
      fleet_manager_id: listParams.filters.fleet_manager_id,
    }),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [listParams, tab],
  );

  const driversQuery = useDriversList(queryParams);
  const createMutation = useDriverCreate();
  const updateMutation = useDriverUpdate();
  const activateMutation = useDriverActivate();
  const deactivateMutation = useDriverDeactivate();
  const deleteMutation = useDriverDelete();
  const resetPasswordMutation = useDriverResetPassword();

  const managersQuery = useUsersList({ per_page: 50 });
  const filters: FilterDef[] = [
    {
      key: 'fleet_manager_id',
      label: t('fleetDrivers.filters.fleetManager'),
      options: (managersQuery.data?.data ?? []).map((user) => ({
        value: user.id ?? '',
        label: user.full_name ?? `${user.first_name ?? ''} ${user.last_name ?? ''}`.trim(),
      })),
      placeholder: t('fleetDrivers.filters.fleetManager'),
    },
  ];

  const columns = useMemo<ColumnDef<Driver, unknown>[]>(
    () => [
      {
        id: 'first_name',
        header: t('fleetDrivers.columns.firstName'),
        accessorKey: 'first_name',
        enableSorting: true,
      },
      {
        id: 'last_name',
        header: t('fleetDrivers.columns.lastName'),
        accessorKey: 'last_name',
        enableSorting: true,
      },
      {
        id: 'username',
        header: t('fleetDrivers.columns.username'),
        accessorKey: 'username',
        enableSorting: true,
      },
      {
        id: 'fleet_manager_name',
        header: t('fleetDrivers.columns.fleetManager'),
        accessorKey: 'fleet_manager_name',
        cell: ({ getValue }) =>
          (getValue() as string | undefined) ?? t('common.states.notAvailable'),
      },
      {
        id: 'default_unit_number',
        header: t('fleetDrivers.columns.unitNumber'),
        accessorKey: 'default_unit_number',
        cell: ({ getValue }) =>
          (getValue() as string | undefined) ?? t('common.states.notAvailable'),
      },
      {
        id: 'app_version',
        header: t('fleetDrivers.columns.appVersion'),
        accessorKey: 'app_version',
        cell: ({ getValue }) =>
          (getValue() as string | undefined) ?? t('common.states.notAvailable'),
      },
      {
        id: 'activated_on',
        header: t('fleetDrivers.columns.activatedOn'),
        accessorKey: 'activated_on',
        enableSorting: true,
        cell: ({ getValue }) => formatDate(getValue() as string | undefined),
      },
      {
        id: 'status',
        header: t('fleetDrivers.columns.status'),
        accessorKey: 'status',
        enableSorting: true,
        cell: ({ getValue }) => {
          const status = getValue() as Driver['status'];
          const tone =
            status === 'invited' ? 'warning' : status === 'active' ? 'success' : 'neutral';
          return (
            <Badge tone={tone}>
              {t(`enums.driver_status.${status}`, { defaultValue: status ?? '' })}
            </Badge>
          );
        },
      },
    ],
    [t, formatDate],
  );

  const rows = driversQuery.data?.data ?? [];
  const total = driversQuery.data?.meta?.total ?? 0;

  const buildRowActions = (driver: Driver): RowAction[] => {
    const id = driver.id ?? '';
    const name = `${driver.first_name ?? ''} ${driver.last_name ?? ''}`.trim();
    const actions: RowAction[] = [
      {
        key: 'view',
        label: t('common.actions.view'),
        onSelect: () => navigate(`/drivers/${id}`),
      },
    ];

    if (canWrite(PERM.driversUpdate)) {
      actions.push({
        key: 'edit',
        label: t('common.actions.edit'),
        onSelect: () => {
          setEditingDriver(driver);
          setFormOpen(true);
        },
      });
    }

    actions.push({
      key: 'reset-password',
      label: t('fleetDrivers.actions.sendPasswordReset'),
      disabled: !canWrite(PERM.driversResetPassword),
      disabledReason: disabledReason(PERM.driversResetPassword),
      onSelect: () => setResetPasswordTarget(driver),
    });

    if (driver.status === 'active') {
      actions.push({
        key: 'deactivate',
        label: t('common.actions.deactivate'),
        disabled: !canWrite(PERM.driversDeactivate),
        disabledReason: disabledReason(PERM.driversDeactivate),
        onSelect: () => setDeactivateTarget(driver),
      });
    } else if (driver.status === 'inactive') {
      actions.push({
        key: 'activate',
        label: t('common.actions.activate'),
        disabled: !canWrite(PERM.driversActivate),
        disabledReason: disabledReason(PERM.driversActivate),
        onSelect: () =>
          activateMutation.mutate(
            { id },
            {
              onSuccess: () =>
                toast.show({
                  variant: 'success',
                  message: t('fleetDrivers.toast.activated', { name }),
                }),
              onError: () =>
                toast.show({ variant: 'error', message: t('fleetDrivers.toast.activateFailed') }),
            },
          ),
      });
    }

    actions.push({
      key: 'delete',
      label: t('common.actions.delete'),
      danger: true,
      disabled: !canWrite(PERM.driversDelete),
      disabledReason: disabledReason(PERM.driversDelete),
      onSelect: () => setDeleteTarget(driver),
    });

    return actions;
  };

  return (
    <>
      <ListScreen
        title={t('pages.drivers.title')}
        actions={
          <PermissionGate permission={PERM.driversCreate}>
            <Button
              onClick={() => {
                setEditingDriver(undefined);
                setFormOpen(true);
              }}
            >
              {t('fleetDrivers.actions.addDriver')}
            </Button>
          </PermissionGate>
        }
        tabs={[
          { key: 'active', label: t('fleetDrivers.tabs.active') },
          { key: 'inactive', label: t('fleetDrivers.tabs.inactive') },
        ]}
        activeTab={tab}
        onTabChange={(key) => setTab(key as DriverTab)}
        filtersBar={
          <FiltersBar
            search={listParams.search}
            onSearchChange={listParams.setSearch}
            searchPlaceholder={t('fleetDrivers.filters.searchPlaceholder')}
            filters={filters}
            activeFilters={listParams.filters}
            onFilterChange={listParams.setFilter}
            onClearAll={listParams.clearFilters}
          />
        }
        table={
          <DataTable
            tableId="drivers"
            columns={columns}
            data={rows}
            isLoading={driversQuery.isLoading}
            isError={driversQuery.isError}
            errorMessage={driversQuery.error?.message}
            onRetry={() => void driversQuery.refetch()}
            emptyTitle={
              listParams.hasActiveFilters
                ? t('ui.overlay.emptyState.noResultsTitle')
                : t('fleetDrivers.empty.title')
            }
            emptyDescription={
              listParams.hasActiveFilters
                ? t('ui.overlay.emptyState.noResultsDescription')
                : t('fleetDrivers.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            sort={listParams.sort}
            order={listParams.order}
            onSortChange={listParams.setSort}
            onRowClick={(driver) => navigate(`/drivers/${driver.id}`)}
            getRowId={(driver, index) => driver.id ?? String(index)}
            rowActions={(driver) => (
              <RowActionsMenu
                actions={buildRowActions(driver)}
                ariaLabel={t('fleetDrivers.actions.rowMenuLabel', {
                  name: `${driver.first_name ?? ''} ${driver.last_name ?? ''}`.trim(),
                })}
              />
            )}
          />
        }
        pagination={
          <Pagination
            page={listParams.page}
            perPage={listParams.perPage}
            total={total}
            onPageChange={listParams.setPage}
            onPerPageChange={listParams.setPerPage}
          />
        }
      />

      {formOpen ? (
        <DriverFormModal
          open={formOpen}
          onClose={() => setFormOpen(false)}
          driver={editingDriver}
          submitting={createMutation.isPending || updateMutation.isPending}
          onSubmitCreate={async (body: DriverCreate) => {
            await createMutation.mutateAsync(body);
            toast.show({ variant: 'success', message: t('fleetDrivers.toast.created') });
          }}
          onSubmitUpdate={async (body: DriverUpdate) => {
            if (!editingDriver?.id) return;
            await updateMutation.mutateAsync({ id: editingDriver.id, body });
            toast.show({ variant: 'success', message: t('fleetDrivers.toast.updated') });
          }}
        />
      ) : null}

      <ConfirmDialog
        open={Boolean(deactivateTarget)}
        onClose={() => setDeactivateTarget(undefined)}
        loading={deactivateMutation.isPending}
        onConfirm={() => {
          if (!deactivateTarget?.id) return;
          deactivateMutation.mutate(
            { id: deactivateTarget.id },
            {
              onSuccess: () => {
                toast.show({ variant: 'success', message: t('fleetDrivers.toast.deactivated') });
                setDeactivateTarget(undefined);
              },
              onError: () => {
                toast.show({ variant: 'error', message: t('fleetDrivers.toast.deactivateFailed') });
                setDeactivateTarget(undefined);
              },
            },
          );
        }}
        title={t('ui.overlay.confirmDialog.title')}
        description={t('fleetDrivers.confirm.deactivate', {
          name: `${deactivateTarget?.first_name ?? ''} ${deactivateTarget?.last_name ?? ''}`.trim(),
        })}
      />

      <ConfirmDialog
        open={Boolean(deleteTarget)}
        onClose={() => setDeleteTarget(undefined)}
        variant="danger"
        loading={deleteMutation.isPending}
        onConfirm={() => {
          if (!deleteTarget?.id) return;
          deleteMutation.mutate(deleteTarget.id, {
            onSuccess: () => {
              toast.show({ variant: 'success', message: t('fleetDrivers.toast.deleted') });
              setDeleteTarget(undefined);
            },
            onError: () => {
              toast.show({ variant: 'error', message: t('fleetDrivers.toast.deleteFailed') });
              setDeleteTarget(undefined);
            },
          });
        }}
        title={t('ui.overlay.confirmDialog.title')}
        description={t('fleetDrivers.confirm.delete', {
          name: `${deleteTarget?.first_name ?? ''} ${deleteTarget?.last_name ?? ''}`.trim(),
        })}
      />

      <ConfirmDialog
        open={Boolean(resetPasswordTarget)}
        onClose={() => setResetPasswordTarget(undefined)}
        loading={resetPasswordMutation.isPending}
        onConfirm={() => {
          if (!resetPasswordTarget?.id) return;
          resetPasswordMutation.mutate(resetPasswordTarget.id, {
            onSuccess: () => {
              toast.show({
                variant: 'success',
                message: t('fleetDrivers.toast.passwordResetSent'),
              });
              setResetPasswordTarget(undefined);
            },
            onError: () => {
              toast.show({
                variant: 'error',
                message: t('fleetDrivers.toast.passwordResetFailed'),
              });
              setResetPasswordTarget(undefined);
            },
          });
        }}
        title={t('fleetDrivers.confirm.resetPasswordTitle')}
        description={t('fleetDrivers.confirm.resetPassword', {
          name: `${resetPasswordTarget?.first_name ?? ''} ${resetPasswordTarget?.last_name ?? ''}`.trim(),
        })}
      />
    </>
  );
}

export default DriverListPage;
