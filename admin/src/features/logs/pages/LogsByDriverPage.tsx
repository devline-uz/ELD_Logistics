/**
 * Logs By Driver — `/logs/by-driver` (3.3, `docs/tz/07-4-logs.md` 7.4.2).
 *
 * Haydovchi tanlanmaguncha jadval o'rnida "Select driver first" bo'sh holati
 * ko'rsatiladi (§6.5) — hatto sarlavha/sahifalash ko'rinib tursa ham
 * ma'lumot so'ralmaydi (`useDriverDailyLogs` `enabled: Boolean(driverId)`).
 * Default sana oralig'i — oxirgi 8 kun (sertifikatsiya oynasi, Q...).
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import { useDriverDailyLogs } from '@/api/queries/logs';
import { useDriversList } from '@/api/queries/drivers';
import { useViolationsList } from '@/api/queries/violations';
import type { DailyLogSummary, DriverDailyLogsParams, Violation } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { Button } from '@/components/ui/Button';
import { DateRangePicker, type DateRange } from '@/components/ui/DateRangePicker';
import { Select, type SelectOption } from '@/components/ui/Select';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { useUnitSystem } from '@/hooks/useUnitSystem';

import { useHosSummariesByDate } from '../lib/hosByDate';
import { buildLogsByDriverColumns } from '../components/logsByDriverColumns';
import { formatPersonName } from '@/lib/format';

function isoDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function defaultRange(): DateRange {
  const end = new Date();
  const start = new Date(end);
  start.setDate(start.getDate() - 7);
  return { start, end };
}

function groupViolationsByLogId(violations: Violation[]): Map<string, Violation[]> {
  const map = new Map<string, Violation[]>();
  for (const violation of violations) {
    if (!violation.daily_log_id) continue;
    const list = map.get(violation.daily_log_id) ?? [];
    list.push(violation);
    map.set(violation.daily_log_id, list);
  }
  return map;
}

export function LogsByDriverPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const dateFormat = useDateFormat();
  const unitSystem = useUnitSystem();
  const listParams = useListParams();

  const driverId = listParams.filters.driver_id || undefined;
  const [range, setRange] = useState<DateRange>(defaultRange);
  const [showExtended, setShowExtended] = useState(false);

  const drivers = useDriversList({ per_page: 50 });
  const driverOptions: SelectOption[] = useMemo(
    () =>
      (drivers.data?.data ?? []).map((driver) => ({
        value: driver.id ?? '',
        label: formatPersonName(driver, driver.id ?? ''),
      })),
    [drivers.data],
  );

  const from = range.start ? isoDate(range.start) : undefined;
  const to = range.end ? isoDate(range.end) : undefined;

  const queryParams = useMemo<DriverDailyLogsParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      from,
      to,
    }),
    [listParams.page, listParams.perPage, from, to],
  );

  const dailyLogs = useDriverDailyLogs(driverId, queryParams);

  const violationsQuery = useViolationsList(
    driverId ? { driver_id: driverId, from, to, per_page: 100 } : {},
  );
  const violationsByLogId = useMemo(
    () => groupViolationsByLogId(violationsQuery.data?.data ?? []),
    [violationsQuery.data],
  );

  const logDates = useMemo(
    () =>
      (dailyLogs.data?.data ?? [])
        .map((log) => log.log_date)
        .filter((d): d is string => Boolean(d)),
    [dailyLogs.data],
  );
  const hosSummaries = useHosSummariesByDate(driverId, logDates, { enabled: showExtended });

  const columns = buildLogsByDriverColumns(t, {
    startIndex: (listParams.page - 1) * listParams.perPage,
    showExtended,
    hosByDate: hosSummaries.data ?? {},
    violationsByLogId,
    dateFormat,
    unitSystem,
  });

  const openLog = (log: DailyLogSummary) => {
    if (log.id) navigate(`/logs/view/${log.id}`);
  };

  return (
    <ListScreen
      title={t('logs.byDriver.title')}
      actions={
        driverId ? (
          <Button variant="secondary" onClick={() => setShowExtended((prev) => !prev)}>
            {showExtended ? t('logs.byUnit.actions.hideHos') : t('logs.byUnit.actions.showHos')}
          </Button>
        ) : null
      }
      filtersBar={
        <div className="flex flex-wrap items-end gap-3">
          <Select
            label={t('logs.byDriver.filters.driver')}
            placeholder={t('logs.byDriver.filters.driverPlaceholder')}
            searchable
            clearable
            loading={drivers.isLoading}
            value={driverId ?? null}
            onChange={(value) => listParams.setFilter('driver_id', value ?? undefined)}
            options={driverOptions}
            className="w-64"
          />
          <DateRangePicker
            label={t('logs.byDriver.filters.dateRange')}
            value={range}
            onChange={setRange}
          />
        </div>
      }
      table={
        !driverId ? (
          <div className="rounded-lg border border-stroke bg-surface px-6 py-16 text-center">
            <h3 className="text-body-lg font-semibold text-neutral-900">
              {t('logs.byDriver.empty.selectDriverTitle')}
            </h3>
            <p className="mt-2 text-body text-neutral-600">
              {t('logs.byDriver.empty.selectDriverDescription')}
            </p>
          </div>
        ) : (
          <DataTable
            tableId="logs-by-driver"
            columns={columns}
            data={dailyLogs.data?.data ?? []}
            isLoading={dailyLogs.isLoading}
            isError={dailyLogs.isError}
            errorMessage={dailyLogs.error?.message}
            onRetry={() => void dailyLogs.refetch()}
            emptyTitle={t('logs.byDriver.empty.title')}
            emptyDescription={t('logs.byDriver.empty.description')}
            onRowClick={openLog}
            getRowId={(log, index) => log.id ?? String(index)}
          />
        )
      }
      pagination={
        driverId ? (
          <Pagination
            page={listParams.page}
            perPage={listParams.perPage}
            total={dailyLogs.data?.meta?.total ?? 0}
            onPageChange={listParams.setPage}
            onPerPageChange={listParams.setPerPage}
          />
        ) : undefined
      }
    />
  );
}

export default LogsByDriverPage;
