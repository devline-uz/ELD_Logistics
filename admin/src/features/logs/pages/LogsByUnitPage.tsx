/**
 * Logs By Unit — `/logs/by-unit` (3.2, `docs/tz/07-4-logs.md` 7.4.1).
 *
 * **F95 [MUST] kompozitsiya.** Backendda "bir kun x barcha unitlar x HOS"
 * beruvchi yagona endpoint yo'q:
 * 1. Asosiy ustunlar `useTrackingLive` (`GET /tracking/live`, bitta so'rov).
 * 2. Break/Drive/Shift/Cycle/Recap — foydalanuvchi "Show HOS counters"
 *    tugmasini bossagina `useHosSummaries` (concurrency <= 6, staleTime 60s)
 *    joriy sahifadagi haydovchilar uchun so'raladi.
 * 3. Warnings & Violations — bitta `useViolationsList({from, to})`, natija
 *    `unit_id` bo'yicha guruhlanadi.
 *
 * **Ma'lum bo'shliqlar** (`docs/tz/16-17-registry-open-questions.md`ga
 * qayd etilgan):
 * - `GET /tracking/live` hech qanday `search`/`date` parametriga ega emas —
 *   ekran "live" holatni ko'rsatadi, `search` shu sabab **client-side**
 *   (joriy sahifa ichida) filtrlanadi, `date` faqat HOS/violations konteksti
 *   uchun ishlatiladi (default bugun).
 * - Backend `LastKnownLocation` uchun teskari-geokod matni bermaydi — faqat
 *   `lat`/`lng` ko'rsatiladi.
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import { api } from '@/api/client';
import { useHosSummaries } from '@/api/queries/hos';
import { useTrackingLive } from '@/api/queries/logs';
import { useViolationsList } from '@/api/queries/violations';
import type { LiveUnit, TrackingLiveParams, Violation } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar, type FilterDef } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { Button } from '@/components/ui/Button';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';

import { buildLogsByUnitColumns } from '../components/logsByUnitColumns';
import { formatPersonName } from '@/lib/format';

function todayIsoDate(): string {
  return new Date().toISOString().slice(0, 10);
}

function groupViolationsByUnit(violations: Violation[]): Map<string, Violation[]> {
  const map = new Map<string, Violation[]>();
  for (const violation of violations) {
    if (!violation.unit_id) continue;
    const list = map.get(violation.unit_id) ?? [];
    list.push(violation);
    map.set(violation.unit_id, list);
  }
  return map;
}

export function LogsByUnitPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const dateFormat = useDateFormat();
  const listParams = useListParams();
  const [showExtended, setShowExtended] = useState(false);
  const [date] = useState(todayIsoDate);

  const queryParams = useMemo<TrackingLiveParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      branch_id: listParams.filters.branch_id || undefined,
      online_status:
        (listParams.filters.online_status as TrackingLiveParams['online_status']) || undefined,
    }),
    [
      listParams.page,
      listParams.perPage,
      listParams.filters.branch_id,
      listParams.filters.online_status,
    ],
  );

  const live = useTrackingLive(queryParams);

  const dayStart = `${date}T00:00:00Z`;
  const dayEnd = `${date}T23:59:59Z`;
  const violationsQuery = useViolationsList({ from: dayStart, to: dayEnd, per_page: 100 });
  const violationsByUnit = useMemo(
    () => groupViolationsByUnit(violationsQuery.data?.data ?? []),
    [violationsQuery.data],
  );

  const driverIds = useMemo(
    () =>
      Array.from(
        new Set(
          (live.data?.data ?? [])
            .map((unit) => unit.driver?.id)
            .filter((id): id is string => Boolean(id)),
        ),
      ),
    [live.data],
  );
  const hosSummaries = useHosSummaries(driverIds, date, { enabled: showExtended });

  const searchTerm = listParams.search.trim().toLowerCase();
  const rows = useMemo(() => {
    const all = live.data?.data ?? [];
    let filtered = all;
    if (searchTerm) {
      filtered = filtered.filter((unit) => {
        const name = formatPersonName(unit.driver, '').toLowerCase();
        return (
          name.includes(searchTerm) || (unit.unit_number ?? '').toLowerCase().includes(searchTerm)
        );
      });
    }
    if (listParams.filters.has_violations === 'true') {
      filtered = filtered.filter((unit) => {
        const list = unit.unit_id ? violationsByUnit.get(unit.unit_id) : undefined;
        return (list ?? []).some((violation) => violation.severity === 'violation');
      });
    }
    if (listParams.filters.has_warnings === 'true') {
      filtered = filtered.filter((unit) => {
        const list = unit.unit_id ? violationsByUnit.get(unit.unit_id) : undefined;
        return (list ?? []).some((violation) => violation.severity === 'warning');
      });
    }
    return filtered;
  }, [
    live.data,
    searchTerm,
    listParams.filters.has_violations,
    listParams.filters.has_warnings,
    violationsByUnit,
  ]);

  const openLog = async (unit: LiveUnit) => {
    if (!unit.driver?.id) return;
    const { data } = await api.GET('/drivers/{id}/daily-logs', {
      params: { path: { id: unit.driver.id }, query: { from: date, to: date } },
    });
    const logId = data?.data?.[0]?.id;
    if (logId) navigate(`/logs/view/${logId}`);
  };

  const columns = buildLogsByUnitColumns(t, {
    startIndex: (listParams.page - 1) * listParams.perPage,
    showExtended,
    hosByDriver: hosSummaries.data ?? {},
    violationsByUnit,
    dateFormat,
    onOpenLog: (unit) => void openLog(unit),
  });

  const filterDefs: FilterDef[] = [
    {
      key: 'online_status',
      label: t('logs.byUnit.filters.onlineStatus'),
      options: [
        { value: 'online', label: t('logs.byUnit.onlineStatus.online') },
        { value: 'offline', label: t('logs.byUnit.onlineStatus.offline') },
        { value: 'disconnected', label: t('logs.byUnit.onlineStatus.disconnected') },
      ],
    },
    {
      key: 'has_violations',
      label: t('logs.byUnit.filters.violations'),
      options: [{ value: 'true', label: t('common.boolean.yes') }],
    },
    {
      key: 'has_warnings',
      label: t('logs.byUnit.filters.warnings'),
      options: [{ value: 'true', label: t('common.boolean.yes') }],
    },
  ];

  return (
    <ListScreen
      title={t('logs.byUnit.title')}
      actions={
        <Button variant="secondary" onClick={() => setShowExtended((prev) => !prev)}>
          {showExtended ? t('logs.byUnit.actions.hideHos') : t('logs.byUnit.actions.showHos')}
        </Button>
      }
      filtersBar={
        <FiltersBar
          search={listParams.search}
          onSearchChange={listParams.setSearch}
          searchPlaceholder={t('logs.byUnit.filters.searchPlaceholder')}
          filters={filterDefs}
          activeFilters={listParams.filters}
          onFilterChange={listParams.setFilter}
          onClearAll={listParams.clearFilters}
        />
      }
      table={
        <DataTable
          tableId="logs-by-unit"
          columns={columns}
          data={rows}
          isLoading={live.isLoading}
          isError={live.isError}
          errorMessage={live.error?.message}
          onRetry={() => void live.refetch()}
          emptyTitle={t('logs.byUnit.empty.title')}
          emptyDescription={
            listParams.hasActiveFilters
              ? t('logs.byUnit.empty.filteredDescription')
              : t('logs.byUnit.empty.description')
          }
          onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
          onRowClick={(unit) => void openLog(unit)}
          getRowId={(unit, index) => unit.unit_id ?? String(index)}
        />
      }
      pagination={
        <Pagination
          page={listParams.page}
          perPage={listParams.perPage}
          total={live.data?.meta?.total ?? 0}
          onPageChange={listParams.setPage}
          onPerPageChange={listParams.setPerPage}
        />
      }
    />
  );
}

export default LogsByUnitPage;
