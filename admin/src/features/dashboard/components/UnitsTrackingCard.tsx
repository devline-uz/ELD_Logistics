/**
 * "Units Tracking bloki" — §7.2: MapLibre xarita, marker'lar `GET /tracking/live`
 * dan, WS `tracking` bilan yangilanadi. Afsona: Drive/Sleep/On-Duty/Off-Duty.
 *
 * Vaqt filtri (`Today`/`This week`) — TZ "faqat marker tarixi uchun, jonli
 * holat doim joriy" deydi, lekin `GET /dashboard/summary` na `/tracking/live`
 * hech qanday tarixiy marker/trail endpointi bermaydi (D34,
 * `docs/tz/16-17-registry-open-questions.md`). Filtr shu sabab hozircha
 * faqat vizual tanlov — jonli marker to'plami har ikkala holatda ham bir xil.
 */
import { useCallback, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { useQueryClient } from '@tanstack/react-query';

import { trackingKeys, useTrackingLive } from '@/api/queries/tracking';
import type { LiveUnit } from '@/api/types';
import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { LazyTrackingMapPanel } from '@/components/map/LazyTrackingMapPanel';
import type { UseLiveUnitsLayerOptions } from '@/components/map/useLiveUnitsLayer';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { useChannel } from '@/hooks/useChannel';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useDelayedLoading } from '@/hooks/useDelayedLoading';
import { useUnitSystem } from '@/hooks/useUnitSystem';
import { formatCoordinate, formatPersonName } from '@/lib/format';
import { PERM, usePermission } from '@/lib/permissions';
import { dutyStatusTone, onlineStatusTone } from '@/lib/statusTone';
import type { RealtimeEvent } from '@/lib/ws';

type TimeFilter = 'today' | 'thisWeek';

const LEGEND_ITEMS = [
  { key: 'drive', dot: 'bg-success-base' },
  { key: 'sleep', dot: 'bg-decorative-purple' },
  { key: 'onDuty', dot: 'bg-warning-base' },
  { key: 'offDuty', dot: 'bg-neutral-500' },
] as const;

/** WS hodisalari orasidagi minimal REST refetch oralig'i — so'rov bo'ronining oldini oladi. */
const WS_REFETCH_THROTTLE_MS = 5_000;

export function UnitsTrackingCard() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const can = usePermission();
  const { formatRelative } = useDateFormat();
  const { formatDistance } = useUnitSystem();

  const [timeFilter, setTimeFilter] = useState<TimeFilter>('today');

  const hasAccess = can(PERM.trackingViewLive);
  const live = useTrackingLive({}, { enabled: hasAccess });

  const liveQueryKey = useMemo(() => trackingKeys.liveList({}), []);
  const lastWsRefetchRef = useRef(0);
  const handleTrackingEvent = useCallback(
    (event: RealtimeEvent) => {
      if (event.type !== 'unit_last_state') return;
      const now = Date.now();
      if (now - lastWsRefetchRef.current < WS_REFETCH_THROTTLE_MS) return;
      lastWsRefetchRef.current = now;
      void queryClient.invalidateQueries({ queryKey: liveQueryKey });
    },
    [queryClient, liveQueryKey],
  );

  useChannel('tracking', undefined, handleTrackingEvent, { enabled: hasAccess });

  const units = useMemo(() => live.data?.data ?? [], [live.data]);
  const showLoading = useDelayedLoading(hasAccess && live.isLoading, 500);

  const liveOptions: UseLiveUnitsLayerOptions = {
    buildPopupProps: (unit: LiveUnit) => ({
      driverName: formatPersonName(unit.driver, t('common.na')),
      dutyStatus: unit.duty_status ?? 'OFF',
      dutyStatusTone: dutyStatusTone(unit.duty_status),
      unitNumber: unit.unit_number ?? t('common.na'),
      odometer: formatDistance(unit.odometer_m),
      location: `${formatCoordinate(unit.lat)}, ${formatCoordinate(unit.lng)}`,
      hasCoordinates: typeof unit.lat === 'number' && typeof unit.lng === 'number',
      relativeTime: formatRelative(unit.last_seen_at),
      onlineTone: onlineStatusTone(unit.online_status),
      onlineLabel: t(`enums.connection_status.${unit.online_status ?? 'offline'}`, {
        defaultValue: unit.online_status ?? 'offline',
      }),
      onViewTracking: () =>
        unit.unit_id && navigate(`/tracking/units/${encodeURIComponent(unit.unit_id)}`),
    }),
    formatListEntry: (unit: LiveUnit) => unit.unit_number ?? t('common.na'),
    listPopupTitle: t('map.clusterPopup.title'),
  };

  const timeFilterActions = (
    <div
      role="group"
      aria-label={t('dashboard.map.timeFilter.label')}
      className="flex items-center gap-1"
    >
      <Button
        type="button"
        size="sm"
        variant={timeFilter === 'today' ? 'primary' : 'secondary'}
        aria-pressed={timeFilter === 'today'}
        onClick={() => setTimeFilter('today')}
      >
        {t('dashboard.map.timeFilter.today')}
      </Button>
      <Button
        type="button"
        size="sm"
        variant={timeFilter === 'thisWeek' ? 'primary' : 'secondary'}
        aria-pressed={timeFilter === 'thisWeek'}
        onClick={() => setTimeFilter('thisWeek')}
      >
        {t('dashboard.map.timeFilter.thisWeek')}
      </Button>
    </div>
  );

  return (
    <Card title={t('dashboard.map.title')} actions={timeFilterActions}>
      <ul className="mb-3 flex flex-wrap items-center gap-4 text-body-sm text-neutral-600">
        {LEGEND_ITEMS.map((item) => (
          <li key={item.key} className="flex items-center gap-1.5">
            <span className={`h-2 w-2 rounded-full ${item.dot}`} aria-hidden="true" />
            {t(`dashboard.map.legend.${item.key}`)}
          </li>
        ))}
      </ul>

      {!hasAccess ? (
        <EmptyState
          title={t('ui.overlay.emptyState.noAccessTitle')}
          description={t('ui.overlay.emptyState.noAccessDescription')}
        />
      ) : live.isError ? (
        <ErrorState
          message={live.error?.message ?? t('dashboard.map.error')}
          onRetry={() => void live.refetch()}
        />
      ) : live.isLoading ? (
        <div className="relative min-h-[360px]" aria-busy="true">
          {showLoading ? <Skeleton variant="map" /> : null}
        </div>
      ) : units.length === 0 ? (
        <EmptyState
          title={t('dashboard.map.empty.title')}
          description={t('dashboard.map.empty.description')}
        />
      ) : (
        <div className="relative min-h-[360px] overflow-hidden rounded-lg">
          <LazyTrackingMapPanel
            ariaLabel={t('dashboard.map.ariaLabel')}
            units={units}
            liveOptions={liveOptions}
          />
        </div>
      )}
    </Card>
  );
}

export default UnitsTrackingCard;
