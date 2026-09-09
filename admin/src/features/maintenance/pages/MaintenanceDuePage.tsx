/**
 * Maintenance › **Due** tabi — `/maintenance/due` (5.6, 5.10; §7.6).
 * `GET /maintenance/due?unit_id=&schedule_id=&status=` (`maintenance.read`).
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import { useMaintenanceDue } from '@/api/queries/maintenance';
import { FiltersBar } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { useListParams } from '@/hooks/useListParams';

import { DueTable } from '../components/DueTable';
import { MAINTENANCE_TAB_PATHS, maintenanceTabs } from '../components/tabs';
import { useMaintenanceActions } from '../components/useMaintenanceActions';
import { SCHEDULE_UNIT_STATUSES } from '../constants';
import { useUnitLookup } from '../useUnitLookup';

export function MaintenanceDuePage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const listParams = useListParams();
  const { units } = useUnitLookup();
  const actions = useMaintenanceActions();

  const queryParams = useMemo(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      unit_id: listParams.filters.unit_id || undefined,
      status:
        (listParams.filters.status as (typeof SCHEDULE_UNIT_STATUSES)[number] | undefined) ||
        undefined,
    }),
    [listParams.page, listParams.perPage, listParams.filters.unit_id, listParams.filters.status],
  );

  const list = useMaintenanceDue(queryParams);

  return (
    <>
      <ListScreen
        title={t('maintenance.title')}
        tabs={maintenanceTabs(t)}
        activeTab="due"
        onTabChange={(key) => navigate(MAINTENANCE_TAB_PATHS[key as 'schedules' | 'history'])}
        filtersBar={
          <FiltersBar
            search={listParams.search}
            onSearchChange={listParams.setSearch}
            searchPlaceholder={t('maintenance.due.filters.searchPlaceholder')}
            filters={[
              {
                key: 'status',
                label: t('maintenance.due.filters.status'),
                options: SCHEDULE_UNIT_STATUSES.map((value) => ({
                  value,
                  label: t(`enums.maintenance_unit_status.${value}`),
                })),
              },
              {
                key: 'unit_id',
                label: t('maintenance.due.columns.unit'),
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
          <DueTable
            tableId="maintenance-due"
            data={list.data?.data ?? []}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            emptyDescription={
              listParams.hasActiveFilters
                ? t('maintenance.empty.filteredDescription')
                : t('maintenance.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            rowOffset={(listParams.page - 1) * listParams.perPage}
            onView={(row) =>
              navigate(`/maintenance/schedules/${encodeURIComponent(row.schedule_id ?? '')}`)
            }
            onComplete={actions.openComplete}
            onCancel={actions.openCancel}
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

      {actions.dialogs}
    </>
  );
}

export default MaintenanceDuePage;
