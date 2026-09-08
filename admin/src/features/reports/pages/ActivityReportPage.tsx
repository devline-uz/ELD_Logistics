/**
 * Activity Report — `/reports/activity` (Bosqich 6.2, `docs/tz/07-8-reports.md` §7.8.1).
 *
 * `GET /reports/activity?subject=drivers|units&from*&to*&unit_id&driver_id` (`reports.read`).
 * Tablar `Drivers`/`Units` — `subject` parametri, URL'da saqlanadi (`useListParams`). Sana
 * oralig'i (`from`/`to`) ham URL filtrlarida — majburiy, default oxirgi 7 kun.
 *
 * Eksport (F121 — bitta tugma, filtr panelida): `POST /reports/export-jobs
 * {type:"activity", format, params}` — `ExportJobModal` orqali.
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import { useReportsActivity } from '@/api/queries/reports';
import type { ActivityRow, ReportsActivityParams } from '@/api/types';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { Button } from '@/components/ui/Button';
import { DateRangePicker, type DateRange } from '@/components/ui/DateRangePicker';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { Select } from '@/components/ui/Select';
import { useListParams } from '@/hooks/useListParams';
import { useWriteGuard } from '@/hooks/useWriteGuard';
import { PERM } from '@/lib/permissions';

import { ActivityTable, type ActivitySubject } from '../components/ActivityTable';
import { ExportJobModal } from '../components/ExportJobModal';
import { fromDateFilter, toDateFilter } from '../lib/reportFilters';
import { useDriverOptions, useUnitOptions } from '../lib/useEntityOptions';

function defaultRange(): DateRange {
  const end = new Date();
  const start = new Date(end);
  start.setDate(start.getDate() - 7);
  return { start, end };
}

export function ActivityReportPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const listParams = useListParams();
  const writeGuard = useWriteGuard();
  const [exportOpen, setExportOpen] = useState(false);

  const subject: ActivitySubject = listParams.filters.subject === 'drivers' ? 'drivers' : 'units';

  const fallback = useMemo(defaultRange, []);
  const range: DateRange = {
    start: fromDateFilter(listParams.filters.from) ?? fallback.start,
    end: fromDateFilter(listParams.filters.to) ?? fallback.end,
  };

  const from = toDateFilter(range.start);
  const to = toDateFilter(range.end);

  const drivers = useDriverOptions();
  const units = useUnitOptions();

  const queryParams = useMemo<ReportsActivityParams>(
    () => ({
      subject,
      from: from ?? '',
      to: to ?? '',
      page: listParams.page,
      per_page: listParams.perPage,
      unit_id: subject === 'units' ? listParams.filters.unit_id || undefined : undefined,
      driver_id: subject === 'drivers' ? listParams.filters.driver_id || undefined : undefined,
    }),
    [
      subject,
      from,
      to,
      listParams.page,
      listParams.perPage,
      listParams.filters.unit_id,
      listParams.filters.driver_id,
    ],
  );

  const list = useReportsActivity(queryParams, { enabled: Boolean(from && to) });

  const hasActiveFilters = Boolean(listParams.filters.unit_id || listParams.filters.driver_id);

  const openDetail = (row: ActivityRow) => {
    if (!row.subject_id) return;
    navigate(`/reports/activity/${row.subject_id}`, { state: { name: row.name, subject } });
  };

  const exportParams = {
    subject,
    from,
    to,
    unit_ids:
      subject === 'units' && listParams.filters.unit_id ? [listParams.filters.unit_id] : undefined,
    driver_ids:
      subject === 'drivers' && listParams.filters.driver_id
        ? [listParams.filters.driver_id]
        : undefined,
  };

  return (
    <div data-print-root>
      <ListScreen
        title={t('reports.activityReport.title')}
        tabs={[
          { key: 'units', label: t('reports.activityReport.tabs.units') },
          { key: 'drivers', label: t('reports.activityReport.tabs.drivers') },
        ]}
        activeTab={subject}
        onTabChange={(key) => listParams.setFilter('subject', key)}
        actions={
          <Button variant="secondary" onClick={() => window.print()}>
            {t('reports.activityReport.actions.print')}
          </Button>
        }
        filtersBar={
          <div className="flex flex-wrap items-end gap-3">
            <DateRangePicker
              label={t('reports.activityReport.filters.dateRange')}
              value={range}
              onChange={(next) =>
                listParams.setFilters({
                  from: toDateFilter(next.start),
                  to: toDateFilter(next.end),
                })
              }
            />
            {subject === 'units' ? (
              <Select
                label={t('reports.activityReport.filters.unit')}
                placeholder={t('reports.activityReport.filters.unitPlaceholder')}
                searchable
                clearable
                loading={units.isLoading}
                value={listParams.filters.unit_id ?? null}
                onChange={(value) => listParams.setFilter('unit_id', value ?? undefined)}
                options={units.options}
                className="w-56"
              />
            ) : (
              <Select
                label={t('reports.activityReport.filters.driver')}
                placeholder={t('reports.activityReport.filters.driverPlaceholder')}
                searchable
                clearable
                loading={drivers.isLoading}
                value={listParams.filters.driver_id ?? null}
                onChange={(value) => listParams.setFilter('driver_id', value ?? undefined)}
                options={drivers.options}
                className="w-56"
              />
            )}
            <PermissionGate permission={PERM.reportsExport}>
              <Button
                variant="secondary"
                className="ms-auto"
                onClick={() => setExportOpen(true)}
                disabled={!writeGuard.canWrite(PERM.reportsExport)}
                title={writeGuard.disabledReason(PERM.reportsExport)}
              >
                {t('reports.activityReport.actions.export')}
              </Button>
            </PermissionGate>
          </div>
        }
        table={
          <ActivityTable
            subject={subject}
            data={list.data?.data ?? []}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            emptyDescription={
              hasActiveFilters
                ? t('reports.activityReport.empty.filteredDescription')
                : t('reports.activityReport.empty.description')
            }
            onClearFilters={
              hasActiveFilters
                ? () => listParams.setFilters({ unit_id: undefined, driver_id: undefined })
                : undefined
            }
            rowOffset={(listParams.page - 1) * listParams.perPage}
            onRowClick={openDetail}
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

      <ExportJobModal
        open={exportOpen}
        onClose={() => setExportOpen(false)}
        type="activity"
        titleKey="reports.activityReport.exportModal.title"
        params={exportParams}
        formats={['csv', 'xlsx', 'pdf']}
      />
    </div>
  );
}

export default ActivityReportPage;
