/**
 * Tracking ro'yxati — `/tracking` (§7.7.1).
 *
 * Backend `search` bermaydi — qidiruv **klient tomonda** (driver/unit#)
 * qo'llaniladi. `online_status` filtri to'rt qiymatni beradi (`idle` ham,
 * F116). WS `unit_last_state` kelganda mos satr joyida yangilanadi va
 * 600 ms `bg-light` bilan yonib o'chadi (F115).
 */
import { useEffect, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { useQueryClient } from '@tanstack/react-query';

import { trackingKeys, useTrackingLive } from '@/api/queries/tracking';
import type { LiveUnit, ListResponse, TrackingLiveParams } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar, type FilterDef } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { Button } from '@/components/ui/Button';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { useUnitSystem } from '@/hooks/useUnitSystem';

import { buildTrackingColumns } from '../components/trackingColumns';
import { useTrackingChannel, type UnitLastStateEvent } from '../hooks/useTrackingChannel';

const ONLINE_STATUS_OPTIONS = ['online', 'idle', 'offline', 'disconnected'] as const;

/** Highlight muddati — F115. */
const HIGHLIGHT_MS = 600;

/** WS `unit_last_state.data`ni `LiveUnit` maydonlariga (mavjudlarini) ko'chiradi. */
function mergeLiveUnit(existing: LiveUnit, patch: Record<string, unknown>): LiveUnit {
  const next: LiveUnit = { ...existing };
  for (const key of Object.keys(existing) as (keyof LiveUnit)[]) {
    if (key in patch) {
      (next as Record<string, unknown>)[key] = patch[key];
    }
  }
  return next;
}

export function TrackingListPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { formatRelative } = useDateFormat();
  const { formatSpeed } = useUnitSystem();

  const listParams = useListParams();
  const [highlightedIds, setHighlightedIds] = useState<Set<string>>(new Set());
  const highlightTimers = useRef<Map<string, ReturnType<typeof setTimeout>>>(new Map());

  const queryParams = useMemo<TrackingLiveParams>(
    () => ({
      per_page: listParams.perPage,
      page: listParams.page,
      online_status: (listParams.filters.online_status as TrackingLiveParams['online_status']) || undefined,
      include_inactive: listParams.filters.include_inactive === 'true' ? true : undefined,
    }),
    [listParams.perPage, listParams.page, listParams.filters.online_status, listParams.filters.include_inactive],
  );

  const list = useTrackingLive(queryParams);

  const queryKey = useMemo(() => trackingKeys.liveList(queryParams), [queryParams]);

  const handleWsEvent = (event: UnitLastStateEvent) => {
    const unitId = typeof event.data.unit_id === 'string' ? event.data.unit_id : undefined;
    if (!unitId) return;

    queryClient.setQueryData<ListResponse<LiveUnit>>(queryKey, (current) => {
      if (!current?.data) return current;
      const index = current.data.findIndex((unit) => unit.unit_id === unitId);
      if (index === -1) return current;

      const nextData = [...current.data];
      nextData[index] = mergeLiveUnit(nextData[index]!, event.data);
      return { ...current, data: nextData };
    });

    if (!event.replay) {
      setHighlightedIds((prev) => new Set(prev).add(unitId));
      const existingTimer = highlightTimers.current.get(unitId);
      if (existingTimer) clearTimeout(existingTimer);
      const timer = setTimeout(() => {
        setHighlightedIds((prev) => {
          const next = new Set(prev);
          next.delete(unitId);
          return next;
        });
        highlightTimers.current.delete(unitId);
      }, HIGHLIGHT_MS);
      highlightTimers.current.set(unitId, timer);
    }
  };

  useTrackingChannel({ enabled: true, onEvent: handleWsEvent });

  useEffect(() => {
    const timers = highlightTimers.current;
    return () => {
      for (const timer of timers.values()) clearTimeout(timer);
    };
  }, []);

  const search = listParams.search.trim().toLowerCase();
  const rows = useMemo(() => {
    const data = list.data?.data ?? [];
    if (!search) return data;
    return data.filter((unit) => {
      const driverName = `${unit.driver?.first_name ?? ''} ${unit.driver?.last_name ?? ''}`;
      return (
        driverName.toLowerCase().includes(search) ||
        (unit.unit_number ?? '').toLowerCase().includes(search)
      );
    });
  }, [list.data, search]);

  const columns = buildTrackingColumns(t, (listParams.page - 1) * listParams.perPage, {
    formatRelative,
    formatSpeed,
    isHighlighted: (unit) => Boolean(unit.unit_id && highlightedIds.has(unit.unit_id)),
  });

  const filterDefs: FilterDef[] = [
    {
      key: 'online_status',
      label: t('tracking.list.filters.onlineStatus'),
      options: ONLINE_STATUS_OPTIONS.map((value) => ({
        value,
        label: t(`enums.connection_status.${value}`),
      })),
    },
    {
      key: 'include_inactive',
      label: t('tracking.list.filters.includeInactive'),
      options: [
        { value: 'true', label: t('common.boolean.yes') },
        { value: 'false', label: t('common.boolean.no') },
      ],
    },
  ];

  return (
    <ListScreen
      title={t('tracking.list.title')}
      filtersBar={
        <FiltersBar
          search={listParams.search}
          onSearchChange={listParams.setSearch}
          searchPlaceholder={t('tracking.list.filters.searchPlaceholder')}
          filters={filterDefs}
          activeFilters={listParams.filters}
          onFilterChange={listParams.setFilter}
          onClearAll={listParams.clearFilters}
        />
      }
      table={
        <DataTable
          tableId="tracking"
          columns={columns}
          data={rows}
          isLoading={list.isLoading}
          isError={list.isError}
          errorMessage={list.error?.message}
          onRetry={() => void list.refetch()}
          emptyTitle={t('tracking.list.empty.title')}
          emptyDescription={
            listParams.hasActiveFilters
              ? t('tracking.list.empty.filteredDescription')
              : t('tracking.list.empty.description')
          }
          onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
          getRowId={(unit, index) => unit.unit_id ?? String(index)}
          rowActions={(unit) => (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => unit.unit_id && navigate(`/tracking/units/${unit.unit_id}`)}
            >
              {t('tracking.list.actions.trackOnMap')}
            </Button>
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
  );
}

export default TrackingListPage;
