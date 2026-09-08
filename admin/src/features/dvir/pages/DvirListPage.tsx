/**
 * DVIR ro'yxati — `/dvir` (5.2, `docs/tz/07-5-dvir-maintenance.md` §7.5).
 *
 * Tablar: `All` (`GET /dvir-reports`) va `Pending certification`
 * (`GET /dvir-reports/pending-certification` — faqat `unit_id` filtri,
 * sahifalash yo'q).
 *
 * **F107**: admin DVIR **yaratmaydi** — bu ekranda `Add`/`Generate report`
 * tugmasi umuman yo'q. **F108**: ro'yxatda kritik nuqsonli (out of service)
 * hisobot bo'lsa jadval ustida qizil banner.
 * **F106**: `draft` — mobil lokal holat, status filtrida ko'rsatilmaydi.
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import { useDriversList } from '@/api/queries/drivers';
import { useUnitsList } from '@/api/queries/units';
import type { DvirReport, DvirReportsListParams } from '@/api/types';
import { FiltersBar, type FilterDef } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { DateRangePicker, type DateRange } from '@/components/ui/DateRangePicker';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { formatPersonName } from '@/lib/format';

import { DvirAllTab } from '../components/DvirAllTab';
import { DvirPendingTab } from '../components/DvirPendingTab';
import { buildDvirColumns } from '../components/dvirColumns';
import { DVIR_FILTERABLE_STATUSES } from '../lib/status';

const TAB_ALL = 'all';
const TAB_PENDING = 'pending';

function isoDate(date: Date | null): string | undefined {
  return date ? date.toISOString().slice(0, 10) : undefined;
}

function parseIso(value: string | undefined): Date | null {
  if (!value) return null;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

export function DvirListPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const dateFormat = useDateFormat();
  const listParams = useListParams();

  const tab = listParams.filters.tab === TAB_PENDING ? TAB_PENDING : TAB_ALL;
  const isPending = tab === TAB_PENDING;

  const units = useUnitsList({ per_page: 50 });
  const drivers = useDriversList({ per_page: 50 });

  const queryParams = useMemo<DvirReportsListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      unit_id: listParams.filters.unit_id || undefined,
      driver_id: listParams.filters.driver_id || undefined,
      type: (listParams.filters.type as DvirReportsListParams['type']) || undefined,
      status: (listParams.filters.status as DvirReportsListParams['status']) || undefined,
      from: listParams.filters.from || undefined,
      to: listParams.filters.to || undefined,
    }),
    [
      listParams.page,
      listParams.perPage,
      listParams.filters.unit_id,
      listParams.filters.driver_id,
      listParams.filters.type,
      listParams.filters.status,
      listParams.filters.from,
      listParams.filters.to,
    ],
  );

  const openReport = (report: DvirReport) => {
    if (report.id) navigate(`/dvir/${report.id}`);
  };

  const searchTerm = listParams.search;

  const columns = buildDvirColumns(t, {
    startIndex: isPending ? 0 : (listParams.page - 1) * listParams.perPage,
    dateFormat,
    onView: openReport,
  });

  const filterDefs: FilterDef[] = [
    {
      key: 'unit_id',
      label: t('dvir.list.filters.unit'),
      options: (units.data?.data ?? []).map((unit) => ({
        value: unit.id ?? '',
        label: unit.unit_number ?? unit.id ?? '',
      })),
    },
    ...(isPending
      ? []
      : [
          {
            key: 'driver_id',
            label: t('dvir.list.filters.driver'),
            options: (drivers.data?.data ?? []).map((driver) => ({
              value: driver.id ?? '',
              label: formatPersonName(driver, driver.id ?? ''),
            })),
          },
          {
            key: 'type',
            label: t('dvir.list.filters.type'),
            options: [
              { value: 'pre_trip', label: t('enums.dvir_type.pre_trip') },
              { value: 'post_trip', label: t('enums.dvir_type.post_trip') },
            ],
          },
          {
            key: 'status',
            label: t('dvir.list.filters.status'),
            options: DVIR_FILTERABLE_STATUSES.map((status) => ({
              value: status,
              label: t(`enums.dvir_status.${status}`),
            })),
          },
        ]),
  ];

  const range: DateRange = {
    start: parseIso(listParams.filters.from),
    end: parseIso(listParams.filters.to),
  };

  return (
    <ListScreen
      title={t('dvir.list.title')}
      tabs={[
        { key: TAB_ALL, label: t('dvir.list.tabs.all') },
        { key: TAB_PENDING, label: t('dvir.list.tabs.pendingCertification') },
      ]}
      activeTab={tab}
      onTabChange={(key) => listParams.setFilter('tab', key === TAB_ALL ? undefined : key)}
      filtersBar={
        <div className="flex flex-col gap-3">
          <FiltersBar
            search={listParams.search}
            onSearchChange={listParams.setSearch}
            searchPlaceholder={t('dvir.list.filters.searchPlaceholder')}
            filters={filterDefs}
            activeFilters={listParams.filters}
            onFilterChange={listParams.setFilter}
            onClearAll={listParams.clearFilters}
          />
          {isPending ? null : (
            <DateRangePicker
              label={t('dvir.list.filters.dateRange')}
              value={range}
              onChange={(value) =>
                listParams.setFilters({ from: isoDate(value.start), to: isoDate(value.end) })
              }
              className="w-72"
            />
          )}
        </div>
      }
      table={
        isPending ? (
          <DvirPendingTab
            unitId={listParams.filters.unit_id || undefined}
            columns={columns}
            searchTerm={searchTerm}
            emptyTitle={t('dvir.list.empty.pendingTitle')}
            emptyDescription={t('dvir.list.empty.pendingDescription')}
            onRowClick={openReport}
          />
        ) : (
          <DvirAllTab
            params={queryParams}
            columns={columns}
            searchTerm={searchTerm}
            emptyTitle={
              listParams.hasActiveFilters
                ? t('dvir.list.empty.filteredTitle')
                : t('dvir.list.empty.title')
            }
            emptyDescription={
              listParams.hasActiveFilters
                ? t('dvir.list.empty.filteredDescription')
                : t('dvir.list.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            onRowClick={openReport}
            page={listParams.page}
            perPage={listParams.perPage}
            onPageChange={listParams.setPage}
            onPerPageChange={listParams.setPerPage}
          />
        )
      }
    />
  );
}

export default DvirListPage;
