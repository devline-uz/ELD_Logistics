/**
 * DVIR Report — `/reports/dvir` (Bosqich 6.5, `docs/tz/07-8-reports.md` §7.8.4).
 *
 * `GET /dvir-reports` (jonli ro'yxat, `reports.read`) + `POST /reports/export-jobs
 * {type:"dvir"}` (`reports.export`) — `ExportJobModal` orqali.
 *
 * **F107 [MUST]: imzo joylashtirish formasi YO'Q.** Ekran faqat filtr
 * (`Driver`, `Unit`, `Date range`, `Type`, `Status`) + jadval + `Export`
 * (`csv|xlsx|pdf`) dan iborat — hech qanday DVIR-ni tahrirlash/tasdiqlash
 * amali yo'q (bu `features/dvir` ekranlarining ishi).
 *
 * Jadval ustunlari `features/dvir` dan import qilinmaydi (ESLint
 * `no-restricted-imports` features kesishmasini taqiqlaydi) — `DvirReportTable`
 * o'z ustunlarini mustaqil quradi.
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import { useDvirList } from '@/api/queries/dvir';
import type { DvirReportsListParams, ExportParams } from '@/api/types';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { Button } from '@/components/ui/Button';
import { DateRangePicker, type DateRange } from '@/components/ui/DateRangePicker';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { Select, type SelectOption } from '@/components/ui/Select';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { useWriteGuard } from '@/hooks/useWriteGuard';
import { PERM } from '@/lib/permissions';

import { DvirReportTable } from '../components/DvirReportTable';
import { ExportJobModal } from '../components/ExportJobModal';
import { fromDateFilter, toDateFilter } from '../lib/reportFilters';
import { useDriverOptions, useUnitOptions } from '../lib/useEntityOptions';

/** DVIR `draft` — mobil qurilmadagi lokal holat, admin filtrida ko'rsatilmaydi. */
const FILTERABLE_STATUSES = [
  'submitted_no_defects',
  'submitted_defects_found',
  'repaired',
  'certified',
  'closed_no_certification',
] as const;

const TYPES = ['pre_trip', 'post_trip'] as const;

export function DvirReportPage() {
  const { t } = useTranslation();
  const dateFormat = useDateFormat();
  const listParams = useListParams();
  const writeGuard = useWriteGuard();
  const [exportOpen, setExportOpen] = useState(false);

  const units = useUnitOptions();
  const drivers = useDriverOptions();

  const unitFilter = listParams.filters.unit_id || undefined;
  const driverFilter = listParams.filters.driver_id || undefined;
  const typeFilter = (listParams.filters.type as DvirReportsListParams['type']) || undefined;
  const statusFilter = (listParams.filters.status as DvirReportsListParams['status']) || undefined;

  // `GET /dvir-reports` `from`/`to` — kalendar sanasi (`DvirListPage` (5.2) bilan
  // izchil). Mahalliy sana `toDateFilter` orqali — UTC siljishi yo'q.
  const range: DateRange = {
    start: fromDateFilter(listParams.filters.from),
    end: fromDateFilter(listParams.filters.to),
  };

  const queryParams = useMemo<DvirReportsListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      unit_id: unitFilter,
      driver_id: driverFilter,
      type: typeFilter,
      status: statusFilter,
      from: listParams.filters.from || undefined,
      to: listParams.filters.to || undefined,
    }),
    [
      listParams.page,
      listParams.perPage,
      unitFilter,
      driverFilter,
      typeFilter,
      statusFilter,
      listParams.filters.from,
      listParams.filters.to,
    ],
  );

  const list = useDvirList(queryParams);

  const typeOptions: SelectOption[] = TYPES.map((value) => ({
    value,
    label: t(`enums.dvir_type.${value}`),
  }));
  const statusOptions: SelectOption[] = FILTERABLE_STATUSES.map((value) => ({
    value,
    label: t(`enums.dvir_status.${value}`),
  }));

  const hasActiveFilters = Boolean(unitFilter || driverFilter || typeFilter || statusFilter);

  const exportParams: ExportParams = {
    unit_ids: unitFilter ? [unitFilter] : undefined,
    driver_ids: driverFilter ? [driverFilter] : undefined,
    from: listParams.filters.from || undefined,
    to: listParams.filters.to || undefined,
  };

  return (
    <>
      <ListScreen
        title={t('reports.dvirReport.title')}
        filtersBar={
          <div className="flex flex-wrap items-end gap-3">
            <Select
              label={t('reports.dvirReport.filters.driver')}
              placeholder={t('reports.dvirReport.filters.driverPlaceholder')}
              searchable
              clearable
              loading={drivers.isLoading}
              value={driverFilter ?? null}
              onChange={(value) => listParams.setFilter('driver_id', value ?? undefined)}
              options={drivers.options}
              className="w-56"
            />
            <Select
              label={t('reports.dvirReport.filters.unit')}
              placeholder={t('reports.dvirReport.filters.unitPlaceholder')}
              searchable
              clearable
              loading={units.isLoading}
              value={unitFilter ?? null}
              onChange={(value) => listParams.setFilter('unit_id', value ?? undefined)}
              options={units.options}
              className="w-56"
            />
            <DateRangePicker
              label={t('reports.dvirReport.filters.dateRange')}
              value={range}
              onChange={(next) =>
                listParams.setFilters({
                  from: toDateFilter(next.start),
                  to: toDateFilter(next.end),
                })
              }
              className="w-72"
            />
            <Select
              label={t('reports.dvirReport.filters.type')}
              placeholder={t('reports.dvirReport.filters.typePlaceholder')}
              clearable
              value={typeFilter ?? null}
              onChange={(value) => listParams.setFilter('type', value ?? undefined)}
              options={typeOptions}
              className="w-40"
            />
            <Select
              label={t('reports.dvirReport.filters.status')}
              placeholder={t('reports.dvirReport.filters.statusPlaceholder')}
              clearable
              value={statusFilter ?? null}
              onChange={(value) => listParams.setFilter('status', value ?? undefined)}
              options={statusOptions}
              className="w-48"
            />
            <PermissionGate permission={PERM.reportsExport}>
              <Button
                variant="secondary"
                className="ms-auto"
                onClick={() => setExportOpen(true)}
                disabled={!writeGuard.canWrite(PERM.reportsExport)}
                title={writeGuard.disabledReason(PERM.reportsExport)}
              >
                {t('reports.dvirReport.actions.export')}
              </Button>
            </PermissionGate>
          </div>
        }
        table={
          <DvirReportTable
            data={list.data?.data ?? []}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            emptyDescription={
              hasActiveFilters
                ? t('reports.dvirReport.empty.filteredDescription')
                : t('reports.dvirReport.empty.description')
            }
            onClearFilters={
              hasActiveFilters
                ? () =>
                    listParams.setFilters({
                      unit_id: undefined,
                      driver_id: undefined,
                      type: undefined,
                      status: undefined,
                      from: undefined,
                      to: undefined,
                    })
                : undefined
            }
            rowOffset={(listParams.page - 1) * listParams.perPage}
            dateFormat={dateFormat}
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
        type="dvir"
        titleKey="reports.dvirReport.exportModal.title"
        params={exportParams}
        formats={['csv', 'xlsx', 'pdf']}
      />
    </>
  );
}

export default DvirReportPage;
