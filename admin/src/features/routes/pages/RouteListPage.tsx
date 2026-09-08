/**
 * Routes — `/routes` (§7.7.3).
 *
 * **F118** `ongoing → completed` avtomatik (geofence, backend) — qo'lda
 * "Complete" tugmasi yo'q, faqat `Close as not completed`.
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import { useRouteDelete, useRoutesList } from '@/api/queries/routes';
import type { Route, RoutesListParams } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar, type FilterDef } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { RowActionsMenu } from '@/components/data/RowActionsMenu';
import { useToast } from '@/components/feedback/toast-context';
import { Button } from '@/components/ui/Button';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { useUnitSystem } from '@/hooks/useUnitSystem';
import { useWriteGuard } from '@/hooks/useWriteGuard';
import { PERM } from '@/lib/permissions';

import { RouteDirectionsDrawer } from '../components/RouteDirectionsDrawer';
import { RouteFormModal } from '../components/RouteFormModal';
import { RouteNotCompletedModal } from '../components/RouteNotCompletedModal';
import { buildRoutesColumns } from '../components/routesColumns';

const ROUTE_STATUS_OPTIONS = ['ongoing', 'completed', 'not_completed', 'cancelled'] as const;

type Overlay =
  | { type: 'add' }
  | { type: 'edit'; route: Route }
  | { type: 'not-completed'; route: Route }
  | { type: 'directions'; route: Route }
  | { type: 'delete'; route: Route }
  | undefined;

export function RouteListPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const toast = useToast();
  const { canWrite, disabledReason } = useWriteGuard();
  const { formatDateTime } = useDateFormat();
  const { formatDistance } = useUnitSystem();

  const listParams = useListParams();
  const [overlay, setOverlay] = useState<Overlay>(undefined);
  const remove = useRouteDelete();

  const queryParams = useMemo<RoutesListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      sort: listParams.sort as RoutesListParams['sort'],
      order: listParams.order,
      status: (listParams.filters.status as RoutesListParams['status']) || undefined,
    }),
    [
      listParams.page,
      listParams.perPage,
      listParams.sort,
      listParams.order,
      listParams.filters.status,
    ],
  );

  const list = useRoutesList(queryParams);

  const columns = buildRoutesColumns(t, (listParams.page - 1) * listParams.perPage, {
    formatDateTime,
    formatDistance,
  });

  const filterDefs: FilterDef[] = [
    {
      key: 'status',
      label: t('routes.list.filters.status'),
      options: ROUTE_STATUS_OPTIONS.map((value) => ({
        value,
        label: t(`enums.route_status.${value}`),
      })),
    },
  ];

  const confirmDelete = async () => {
    if (overlay?.type !== 'delete' || !overlay.route.id) return;
    try {
      await remove.mutateAsync(overlay.route.id);
      toast.show({ variant: 'success', message: t('routes.list.toast.deleted') });
      setOverlay(undefined);
    } catch {
      toast.show({ variant: 'error', message: t('errors.unknown') });
    }
  };

  return (
    <>
      <ListScreen
        title={t('routes.list.title')}
        actions={
          <PermissionGate permission={PERM.routesCreate}>
            <Button onClick={() => setOverlay({ type: 'add' })}>
              {t('routes.list.actions.create')}
            </Button>
          </PermissionGate>
        }
        filtersBar={
          <FiltersBar
            search={listParams.search}
            onSearchChange={listParams.setSearch}
            searchPlaceholder={t('routes.list.filters.searchPlaceholder')}
            filters={filterDefs}
            activeFilters={listParams.filters}
            onFilterChange={listParams.setFilter}
            onClearAll={listParams.clearFilters}
          />
        }
        table={
          <DataTable
            tableId="routes"
            columns={columns}
            data={list.data?.data ?? []}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            emptyTitle={t('routes.list.empty.title')}
            emptyDescription={
              listParams.hasActiveFilters
                ? t('routes.list.empty.filteredDescription')
                : t('routes.list.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            sort={listParams.sort}
            order={listParams.order}
            onSortChange={listParams.setSort}
            getRowId={(route, index) => route.id ?? String(index)}
            onRowClick={(route) => route.unit_id && navigate(`/tracking/units/${route.unit_id}`)}
            rowActions={(route) => (
              <RowActionsMenu
                ariaLabel={t('routes.list.rowActionsLabel', { routeId: route.id })}
                items={[
                  {
                    key: 'directions',
                    label: t('routes.list.actions.directions'),
                    onSelect: () => setOverlay({ type: 'directions', route }),
                  },
                  {
                    key: 'edit',
                    label: t('routes.list.actions.edit'),
                    onSelect: () => setOverlay({ type: 'edit', route }),
                    disabled: !canWrite(PERM.routesUpdate) || route.status !== 'ongoing',
                    disabledReason: disabledReason(PERM.routesUpdate),
                  },
                  {
                    key: 'not-completed',
                    label: t('routes.list.actions.closeNotCompleted'),
                    onSelect: () => setOverlay({ type: 'not-completed', route }),
                    disabled: !canWrite(PERM.routesComplete) || route.status !== 'ongoing',
                    disabledReason: disabledReason(PERM.routesComplete),
                  },
                  {
                    key: 'delete',
                    label: t('routes.list.actions.delete'),
                    danger: true,
                    onSelect: () => setOverlay({ type: 'delete', route }),
                    disabled: !canWrite(PERM.routesDelete),
                    disabledReason: disabledReason(PERM.routesDelete),
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

      {overlay?.type === 'add' || overlay?.type === 'edit' ? (
        <RouteFormModal
          open
          onClose={() => setOverlay(undefined)}
          route={overlay.type === 'edit' ? overlay.route : undefined}
        />
      ) : null}

      <RouteNotCompletedModal
        open={overlay?.type === 'not-completed'}
        onClose={() => setOverlay(undefined)}
        route={overlay?.type === 'not-completed' ? overlay.route : undefined}
      />

      <RouteDirectionsDrawer
        open={overlay?.type === 'directions'}
        onClose={() => setOverlay(undefined)}
        route={overlay?.type === 'directions' ? overlay.route : undefined}
      />

      <ConfirmDialog
        open={overlay?.type === 'delete'}
        onClose={() => setOverlay(undefined)}
        onConfirm={() => void confirmDelete()}
        loading={remove.isPending}
        variant="danger"
        title={t('ui.overlay.confirmDialog.title')}
        description={t('routes.list.confirm.deleteDescription')}
      />
    </>
  );
}

export default RouteListPage;
