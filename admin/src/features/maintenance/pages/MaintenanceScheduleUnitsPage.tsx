/**
 * Guruh ichiga kirish — `/maintenance/schedules/:id/units` (5.9, §7.6).
 *
 * `Schedule` jadvalidagi «N Units» qatori bosilganda ochiladi. Yangi endpoint
 * emas — `GET /maintenance/due?schedule_id=` qayta ishlatiladi. Breadcrumb
 * `Due › N units`, ustunlar `Due` bilan **bir xil**, `Refresh` tugmasi bor.
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useParams } from 'react-router-dom';

import { useMaintenanceDue } from '@/api/queries/maintenance';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { Button } from '@/components/ui/Button';
import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { useListParams } from '@/hooks/useListParams';

import { DueTable } from '../components/DueTable';
import { useMaintenanceActions } from '../components/useMaintenanceActions';

export function MaintenanceScheduleUnitsPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const listParams = useListParams();
  const actions = useMaintenanceActions();

  const queryParams = useMemo(
    () => ({
      schedule_id: id,
      page: listParams.page,
      per_page: listParams.perPage,
    }),
    [id, listParams.page, listParams.perPage],
  );

  const list = useMaintenanceDue(queryParams);
  const total = list.data?.meta?.total ?? 0;

  return (
    <>
      <ListScreen
        title={t('maintenance.group.title', { count: total })}
        breadcrumb={
          <Breadcrumb
            items={[
              { label: t('maintenance.title'), href: '/maintenance/schedules' },
              { label: t('maintenance.group.breadcrumbDue'), href: '/maintenance/due' },
              { label: t('maintenance.group.title', { count: total }) },
            ]}
          />
        }
        actions={
          <Button variant="secondary" onClick={() => void list.refetch()} loading={list.isFetching}>
            {t('maintenance.group.refresh')}
          </Button>
        }
        table={
          <DueTable
            tableId="maintenance-schedule-units"
            data={list.data?.data ?? []}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            rowOffset={(listParams.page - 1) * listParams.perPage}
            onView={() => navigate(`/maintenance/schedules/${id ?? ''}`)}
            onComplete={actions.openComplete}
            onCancel={actions.openCancel}
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

      {actions.dialogs}
    </>
  );
}

export default MaintenanceScheduleUnitsPage;
