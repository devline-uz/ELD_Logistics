/**
 * Unit Management — `/units` (2.2, `docs/tz/07-3-fleet.md` §7.3.1/§7.3.2).
 *
 * Tablar (Active/Inactive) + qidiruv/filtrlar + saralash + ustun tanlash +
 * Add/Edit modal + Export/Import + satr amallari (View/Edit/Track on
 * Map/Activate-Deactivate/Delete).
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useSearchParams } from 'react-router-dom';

import { useBranchesList } from '@/api/queries/branches';
import {
  useUnitActivate,
  useUnitDeactivate,
  useUnitDelete,
  useUnitsExport,
  useUnitsList,
} from '@/api/queries/units';
import type { Unit, UnitsListParams } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar, type FilterDef } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { useToast } from '@/components/feedback/toast-context';
import { Button } from '@/components/ui/Button';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { useListParams } from '@/hooks/useListParams';
import { useIsCompanyScope } from '@/hooks/useScope';
import { useWriteGuard } from '@/hooks/useWriteGuard';
import { isApiError } from '@/lib/errors';
import { PERM } from '@/lib/permissions';

import { buildUnitColumns } from '../components/columns';
import { RowActionsMenu } from '@/components/data/RowActionsMenu';
import { UnitFormModal } from '../components/UnitFormModal';
import { UnitImportModal } from '../components/UnitImportModal';

type PendingAction = { type: 'activate' | 'deactivate' | 'delete'; unit: Unit } | undefined;

export function UnitListPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const toast = useToast();
  const { canWrite, disabledReason } = useWriteGuard();
  const [searchParams, setSearchParams] = useSearchParams();

  const listParams = useListParams();
  const activeTab = listParams.filters.status === 'inactive' ? 'inactive' : 'active';
  const isCompanyScope = useIsCompanyScope();
  const branches = useBranchesList({ per_page: 50 }, { enabled: isCompanyScope });

  const modal = searchParams.get('modal');
  const editId = searchParams.get('id') ?? undefined;
  const showImport = searchParams.get('modal') === 'import';

  const [pendingAction, setPendingAction] = useState<PendingAction>(undefined);

  const queryParams = useMemo<UnitsListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      sort: listParams.sort as UnitsListParams['sort'],
      order: listParams.order,
      search: listParams.search || undefined,
      status: activeTab,
      out_of_service:
        listParams.filters.out_of_service === 'true'
          ? true
          : listParams.filters.out_of_service === 'false'
            ? false
            : undefined,
      branch_id: listParams.filters.branch_id || undefined,
    }),
    [
      listParams.page,
      listParams.perPage,
      listParams.sort,
      listParams.order,
      listParams.search,
      listParams.filters.out_of_service,
      listParams.filters.branch_id,
      activeTab,
    ],
  );

  const list = useUnitsList(queryParams);
  const activate = useUnitActivate();
  const deactivate = useUnitDeactivate();
  const remove = useUnitDelete();
  const exportUnits = useUnitsExport();

  const editingUnit = useMemo(
    () => (editId ? list.data?.data?.find((unit) => unit.id === editId) : undefined),
    [editId, list.data],
  );

  const closeModal = () => {
    setSearchParams(
      (prev) => {
        const next = new URLSearchParams(prev);
        next.delete('modal');
        next.delete('id');
        return next;
      },
      { replace: true },
    );
  };

  const openAddModal = () => {
    setSearchParams(
      (prev) => {
        const next = new URLSearchParams(prev);
        next.set('modal', 'add');
        next.delete('id');
        return next;
      },
      { replace: true },
    );
  };

  const openEditModal = (unit: Unit) => {
    setSearchParams(
      (prev) => {
        const next = new URLSearchParams(prev);
        next.set('modal', 'edit');
        if (unit.id) next.set('id', unit.id);
        return next;
      },
      { replace: true },
    );
  };

  const openImportModal = () => {
    setSearchParams(
      (prev) => {
        const next = new URLSearchParams(prev);
        next.set('modal', 'import');
        return next;
      },
      { replace: true },
    );
  };

  const filterDefs: FilterDef[] = [
    {
      key: 'out_of_service',
      label: t('fleet.units.filters.outOfService'),
      options: [
        { value: 'true', label: t('common.boolean.yes') },
        { value: 'false', label: t('common.boolean.no') },
      ],
    },
    ...(isCompanyScope
      ? [
          {
            key: 'branch_id',
            label: t('common.filters.branch'),
            options: (branches.data?.data ?? []).map((branch) => ({
              value: branch.id ?? '',
              label: branch.name ?? branch.id ?? '',
            })),
          } satisfies FilterDef,
        ]
      : []),
  ];

  const columns = buildUnitColumns(t, (listParams.page - 1) * listParams.perPage);

  const handleExport = async (format: 'csv' | 'xlsx') => {
    try {
      const blob = await exportUnits.mutateAsync({ format });
      const objectUrl = URL.createObjectURL(blob);
      const anchor = document.createElement('a');
      anchor.href = objectUrl;
      anchor.download = `units.${format}`;
      document.body.appendChild(anchor);
      anchor.click();
      anchor.remove();
      URL.revokeObjectURL(objectUrl);
    } catch {
      toast.show({ variant: 'error', message: t('fleet.units.toast.exportFailed') });
    }
  };

  const confirmPendingAction = async () => {
    if (!pendingAction) return;
    const { type, unit } = pendingAction;
    if (!unit.id) return;
    try {
      if (type === 'activate') {
        await activate.mutateAsync(unit.id);
        toast.show({
          variant: 'success',
          message: t('fleet.units.toast.activated', { unitNumber: unit.unit_number }),
        });
      } else if (type === 'deactivate') {
        await deactivate.mutateAsync(unit.id);
        toast.show({
          variant: 'success',
          message: t('fleet.units.toast.deactivated', { unitNumber: unit.unit_number }),
        });
      } else {
        await remove.mutateAsync(unit.id);
        toast.show({
          variant: 'success',
          message: t('fleet.units.toast.deleted', { unitNumber: unit.unit_number }),
        });
      }
      setPendingAction(undefined);
    } catch (error) {
      const message =
        isApiError(error) && error.status === 409
          ? t('fleet.units.toast.deleteConflict')
          : t('errors.unknown');
      toast.show({ variant: 'error', message });
    }
  };

  const actionPending = activate.isPending || deactivate.isPending || remove.isPending;

  return (
    <>
      <ListScreen
        title={t('fleet.units.title')}
        tabs={[
          { key: 'active', label: t('fleet.units.tabs.active') },
          { key: 'inactive', label: t('fleet.units.tabs.inactive') },
        ]}
        activeTab={activeTab}
        onTabChange={(key) => listParams.setFilter('status', key === 'active' ? undefined : key)}
        actions={
          <>
            <PermissionGate permission={PERM.unitsExport}>
              <Button
                variant="secondary"
                onClick={() => {
                  void handleExport('csv');
                }}
                loading={exportUnits.isPending}
              >
                {t('fleet.units.actions.export')}
              </Button>
            </PermissionGate>
            <PermissionGate permission={PERM.unitsImport}>
              <Button variant="secondary" onClick={openImportModal}>
                {t('fleet.units.actions.import')}
              </Button>
            </PermissionGate>
            <PermissionGate permission={PERM.unitsCreate}>
              <Button onClick={openAddModal}>{t('fleet.units.actions.add')}</Button>
            </PermissionGate>
          </>
        }
        filtersBar={
          <FiltersBar
            search={listParams.search}
            onSearchChange={listParams.setSearch}
            searchPlaceholder={t('fleet.units.filters.searchPlaceholder')}
            filters={filterDefs}
            activeFilters={listParams.filters}
            onFilterChange={listParams.setFilter}
            onClearAll={listParams.clearFilters}
          />
        }
        table={
          <DataTable
            tableId="units"
            columns={columns}
            data={list.data?.data ?? []}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            emptyTitle={t('fleet.units.empty.title')}
            emptyDescription={
              listParams.hasActiveFilters
                ? t('fleet.units.empty.filteredDescription')
                : t('fleet.units.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            sort={listParams.sort}
            order={listParams.order}
            onSortChange={listParams.setSort}
            onRowClick={(unit) => unit.id && navigate(`/units/${unit.id}`)}
            getRowId={(unit, index) => unit.id ?? String(index)}
            rowActions={(unit) => (
              <RowActionsMenu
                ariaLabel={t('fleet.units.rowActionsLabel', { unitNumber: unit.unit_number })}
                items={[
                  {
                    key: 'view',
                    label: t('common.actions.view'),
                    onSelect: () => unit.id && navigate(`/units/${unit.id}`),
                  },
                  {
                    key: 'edit',
                    label: t('common.actions.edit'),
                    onSelect: () => openEditModal(unit),
                    disabled: !canWrite(PERM.unitsUpdate),
                    disabledReason: disabledReason(PERM.unitsUpdate),
                  },
                  {
                    key: 'track',
                    label: t('fleet.units.actions.trackOnMap'),
                    onSelect: () => unit.id && navigate(`/tracking?unit_id=${unit.id}`),
                  },
                  unit.status === 'active'
                    ? {
                        key: 'deactivate',
                        label: t('common.actions.deactivate'),
                        onSelect: () => setPendingAction({ type: 'deactivate', unit }),
                        disabled: !canWrite(PERM.unitsDeactivate),
                        disabledReason: disabledReason(PERM.unitsDeactivate),
                      }
                    : {
                        key: 'activate',
                        label: t('common.actions.activate'),
                        onSelect: () => setPendingAction({ type: 'activate', unit }),
                        disabled: !canWrite(PERM.unitsActivate),
                        disabledReason: disabledReason(PERM.unitsActivate),
                      },
                  {
                    key: 'delete',
                    label: t('common.actions.delete'),
                    danger: true,
                    onSelect: () => setPendingAction({ type: 'delete', unit }),
                    disabled: !canWrite(PERM.unitsDelete),
                    disabledReason: disabledReason(PERM.unitsDelete),
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

      {modal === 'add' || modal === 'edit' ? (
        <UnitFormModal
          open
          onClose={closeModal}
          unit={modal === 'edit' ? editingUnit : undefined}
        />
      ) : null}

      {showImport ? <UnitImportModal open onClose={closeModal} /> : null}

      <ConfirmDialog
        open={Boolean(pendingAction)}
        onClose={() => setPendingAction(undefined)}
        onConfirm={() => {
          void confirmPendingAction();
        }}
        loading={actionPending}
        variant={pendingAction?.type === 'delete' ? 'danger' : 'default'}
        title={t('ui.overlay.confirmDialog.title')}
        description={
          pendingAction?.type === 'delete'
            ? t('fleet.units.confirm.deleteDescription', {
                unitNumber: pendingAction.unit.unit_number,
              })
            : pendingAction?.type === 'deactivate'
              ? t('fleet.units.confirm.deactivateDescription', {
                  unitNumber: pendingAction.unit.unit_number,
                })
              : t('fleet.units.confirm.activateDescription', {
                  unitNumber: pendingAction?.unit.unit_number,
                })
        }
      />
    </>
  );
}

export default UnitListPage;
