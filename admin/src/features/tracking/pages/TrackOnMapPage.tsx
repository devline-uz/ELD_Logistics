/**
 * Track on Map — `/tracking/units/:unitId` (§7.7.2, 4.6-4.8).
 *
 * Ikki kirish yo'li: `Unit Management › Unit # n › Track on Map` yoki
 * `Tracking › Unit # n` — breadcrumb `location.state?.from` orqali tanlanadi
 * (fleet `UnitListPage` `state: {from: 'units'}` bersa Unit Management
 * yo'li ko'rsatiladi; berilmasa — Tracking, F117 breadcrumb ikkalasida ham
 * blok nomi bir xil `Unit Diagnostics`).
 *
 * A11y (F171): xarita yonida to'liq matnli ekvivalent — haydovchi/diagnostika
 * `<dl>` maydonlari + `Histories` vertikal ro'yxati (`role="application"`
 * xaritaning o'zi, lekin barcha ma'lumot alohida matn sifatida ham mavjud).
 */
import { useCallback, useId, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { useQueryClient } from '@tanstack/react-query';

import { useUnit, useUnitDiagnostics } from '@/api/queries/units';
import { useHosSummary } from '@/api/queries/hos';
import {
  trackingKeys,
  useTrackingLive,
  useTrackingRefresh,
  useUnitTrips,
  useTrip,
} from '@/api/queries/tracking';
import type { ListResponse, LiveUnit } from '@/api/types';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { Button } from '@/components/ui/Button';
import { DatePicker } from '@/components/ui/DatePicker';
import { IconButton } from '@/components/ui/IconButton';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { PERM } from '@/lib/permissions';
import { LazyTrackingMapPanel } from '@/components/map/LazyTrackingMapPanel';
import { MapDataTable } from '@/components/map/MapDataTable';
import type { UseLiveUnitsLayerOptions } from '@/components/map/useLiveUnitsLayer';
import type { TripStopMarker } from '@/components/map/useTripPolylineLayer';
import { decodePolyline } from '@/components/map/polyline';
import {
  formatCoordinate,
  formatCoordinatePair,
  formatPersonName,
  toDateParam,
} from '@/lib/format';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useUnitSystem } from '@/hooks/useUnitSystem';
import {
  ChevronLeft,
  ChevronRight,
  PanelRightClose,
  PanelRightOpen,
  RefreshCw,
} from 'lucide-react';

import { DriverInfoPanel } from '../components/DriverInfoPanel';
import type { UnitLastStateEvent } from '../hooks/useTrackingChannel';
import { TripHistoryTimeline } from '../components/TripHistoryTimeline';
import { dutyStatusTone, onlineStatusTone } from '@/lib/statusTone';
import { UnitDiagnosticsPanel } from '../components/UnitDiagnosticsPanel';
import { useTrackingChannel } from '../hooks/useTrackingChannel';

/**
 * WS `unit_last_state.data` dan keshga ko'chiriladigan `LiveUnit` maydonlari
 * (F115 naqshi — `TrackingListPage` bilan bir xil). Oq ro'yxat: REST javobida
 * yo'q maydon ham qo'llanadi, begona kalitlar esa keshga tushmaydi.
 */
const LIVE_UNIT_PATCH_FIELDS = [
  'duty_status',
  'eld_device_id',
  'eld_device_serial',
  'engine_hours',
  'heading_deg',
  'last_seen_at',
  'lat',
  'lng',
  'malfunction_codes',
  'odometer_m',
  'online_status',
  'out_of_service',
  'speed_kmh',
  'unit_number',
] as const satisfies readonly (keyof LiveUnit)[];

function mergeLiveUnit(existing: LiveUnit, patch: Record<string, unknown>): LiveUnit {
  const next: LiveUnit = { ...existing };
  for (const key of LIVE_UNIT_PATCH_FIELDS) {
    if (key in patch && patch[key] !== undefined) {
      (next as Record<string, unknown>)[key] = patch[key];
    }
  }
  return next;
}

export function TrackOnMapPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation() as { state?: { from?: 'units' } };
  const { unitId } = useParams<{ unitId: string }>();
  const { formatDate, formatRelative } = useDateFormat();
  const { formatDistance } = useUnitSystem();
  const queryClient = useQueryClient();
  const mapTableId = useId();

  const [panelOpen, setPanelOpen] = useState(true);
  const [date, setDate] = useState<Date>(new Date());
  const [selectedTripId, setSelectedTripId] = useState<string | undefined>(undefined);

  const liveParams = useMemo(() => ({ unit_ids: unitId ?? '' }), [unitId]);
  const live = useTrackingLive(liveParams, { enabled: Boolean(unitId) });
  const unit = live.data?.data?.find((u) => u.unit_id === unitId);

  /**
   * F115 — WS hodisasi keshni **joyida** yangilaydi. Ilgari bu yerda
   * `live.refetch()` chaqirilardi: har `unit_last_state` bitta
   * `GET /tracking/live` so'roviga aylanib so'rov bo'roniga olib kelardi.
   */
  const liveQueryKey = useMemo(() => trackingKeys.liveList(liveParams), [liveParams]);
  const handleWsEvent = useCallback(
    (event: UnitLastStateEvent) => {
      const eventUnitId = typeof event.data.unit_id === 'string' ? event.data.unit_id : undefined;
      if (!eventUnitId || eventUnitId !== unitId) return;

      queryClient.setQueryData<ListResponse<LiveUnit>>(liveQueryKey, (current) => {
        if (!current?.data) return current;
        const index = current.data.findIndex((u) => u.unit_id === eventUnitId);
        if (index === -1) return current;
        const nextData = [...current.data];
        nextData[index] = mergeLiveUnit(nextData[index]!, event.data);
        return { ...current, data: nextData };
      });
    },
    [liveQueryKey, queryClient, unitId],
  );

  useTrackingChannel({
    enabled: Boolean(unitId),
    unitIds: unitId ? [unitId] : undefined,
    onEvent: handleWsEvent,
  });

  const unitDetail = useUnit(unitId);
  const diagnostics = useUnitDiagnostics(unitId);
  const hosSummary = useHosSummary(unit?.driver?.id);
  const trips = useUnitTrips(unitId, { date: toDateParam(date) });
  const refresh = useTrackingRefresh();

  const selectedTrip = trips.data?.data?.find((trip) => trip.id === selectedTripId);
  // F169 [MUST] — `include_polyline=true` FAQAT bitta trip tanlanganda so'raladi.
  const tripDetail = useTrip(selectedTripId, true, { enabled: Boolean(selectedTripId) });

  const overviewLines = useMemo(
    () =>
      (trips.data?.data ?? [])
        .filter((trip) => trip.id !== selectedTripId)
        .map((trip): [number, number][] =>
          typeof trip.start_lat === 'number' &&
          typeof trip.start_lng === 'number' &&
          typeof trip.end_lat === 'number' &&
          typeof trip.end_lng === 'number'
            ? [
                [trip.start_lng, trip.start_lat],
                [trip.end_lng, trip.end_lat],
              ]
            : [],
        )
        .filter((line) => line.length === 2),
    [trips.data, selectedTripId],
  );

  const activeLine = useMemo(
    () => decodePolyline(tripDetail.data?.polyline),
    [tripDetail.data?.polyline],
  );

  const stops = useMemo<TripStopMarker[]>(() => {
    if (!selectedTrip) return [];
    const result: TripStopMarker[] = [];
    if (typeof selectedTrip.start_lat === 'number' && typeof selectedTrip.start_lng === 'number') {
      result.push({
        index: 1,
        lngLat: [selectedTrip.start_lng, selectedTrip.start_lat],
        label: '1',
      });
    }
    if (typeof selectedTrip.end_lat === 'number' && typeof selectedTrip.end_lng === 'number') {
      result.push({ index: 2, lngLat: [selectedTrip.end_lng, selectedTrip.end_lat], label: '2' });
    }
    return result;
  }, [selectedTrip]);

  const liveOptions: UseLiveUnitsLayerOptions = {
    buildPopupProps: (u) => ({
      driverName: formatPersonName(u.driver, t('common.na')),
      dutyStatus: u.duty_status ?? 'OFF',
      dutyStatusTone: dutyStatusTone(u.duty_status),
      unitNumber: u.unit_number ?? t('common.na'),
      odometer: formatDistance(u.odometer_m),
      location: `${formatCoordinate(u.lat)}, ${formatCoordinate(u.lng)}`,
      hasCoordinates: typeof u.lat === 'number' && typeof u.lng === 'number',
      relativeTime: formatRelative(u.last_seen_at),
      onlineTone: onlineStatusTone(u.online_status),
      onlineLabel: t(`enums.connection_status.${u.online_status ?? 'offline'}`, {
        defaultValue: u.online_status ?? 'offline',
      }),
      onViewTracking: () => undefined,
    }),
    formatListEntry: (u) => u.unit_number ?? t('common.na'),
    listPopupTitle: t('map.clusterPopup.title'),
  };

  const breadcrumbItems =
    location.state?.from === 'units'
      ? [
          { label: t('fleet.units.title'), href: '/units' },
          {
            label: t('fleet.units.detail.breadcrumb', { unitNumber: unit?.unit_number ?? unitId }),
            href: `/units/${unitId}`,
          },
          { label: t('tracking.trackOnMap.breadcrumbLeaf') },
        ]
      : [
          { label: t('tracking.list.title'), href: '/tracking' },
          { label: t('tracking.trackOnMap.heading', { unitNumber: unit?.unit_number ?? unitId }) },
        ];

  return (
    <div className="flex h-full flex-col gap-3">
      <Breadcrumb items={breadcrumbItems} />

      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-2">
          <IconButton
            icon={ChevronLeft}
            aria-label={t('common.actions.back')}
            variant="ghost"
            onClick={() => navigate(-1)}
          />
          <h1 className="text-h3 font-bold text-neutral-900">
            {t('tracking.trackOnMap.heading', { unitNumber: unit?.unit_number ?? unitId })}
          </h1>
        </div>

        <div className="flex items-center gap-2">
          <DatePicker value={date} onChange={(value) => value && setDate(value)} />
          <Button
            variant="secondary"
            iconLeft={<RefreshCw className="h-4 w-4" aria-hidden="true" />}
            loading={refresh.isPending}
            onClick={() => void refresh.mutateAsync()}
          >
            {t('common.actions.refresh')}
          </Button>
        </div>
      </div>

      {live.isError ? (
        /* fe-screens §7 (2-daraja) — `/tracking/live` yiqilsa bo'sh xarita
           qolmaydi: blok o'rnida ErrorState + retry, sarlavha/breadcrumb joyida. */
        <div className="flex min-h-[520px] flex-1 items-center justify-center rounded-lg border border-stroke bg-surface">
          <ErrorState
            message={live.error?.message ?? t('tracking.trackOnMap.error')}
            onRetry={() => void live.refetch()}
          />
        </div>
      ) : (
        <div className="relative flex min-h-[520px] flex-1 gap-3">
          <div className="relative flex-1 overflow-hidden rounded-lg">
            <LazyTrackingMapPanel
              ariaLabel={t('tracking.trackOnMap.mapAriaLabel', {
                unitNumber: unit?.unit_number ?? unitId,
              })}
              ariaDescribedBy={mapTableId}
              units={unit ? [unit] : []}
              liveOptions={liveOptions}
              overviewLines={overviewLines}
              activeLine={activeLine}
              stops={stops}
              initialCenter={
                typeof unit?.lng === 'number' && typeof unit?.lat === 'number'
                  ? [unit.lng, unit.lat]
                  : undefined
              }
              initialZoom={typeof unit?.lat === 'number' ? 12 : undefined}
            />
            {/* F171 — xarita ma'lumotining jadval ekvivalenti (trip segmentlari). */}
            <MapDataTable
              id={mapTableId}
              className="absolute bottom-3 left-3 z-10 max-w-[min(28rem,60%)] rounded-md bg-surface/95 p-2"
              caption={t('tracking.trackOnMap.table.caption')}
              emptyLabel={t('tracking.trackOnMap.table.empty')}
              rows={trips.data?.data ?? []}
              getRowKey={(trip, index) => trip.id ?? String(index)}
              columns={[
                {
                  key: 'index',
                  header: t('tracking.trackOnMap.table.index'),
                  cell: (_trip, index) => index + 1,
                },
                {
                  key: 'start',
                  header: t('tracking.trackOnMap.table.start'),
                  cell: (trip) => formatCoordinatePair(trip.start_lat, trip.start_lng),
                },
                {
                  key: 'end',
                  header: t('tracking.trackOnMap.table.end'),
                  cell: (trip) => formatCoordinatePair(trip.end_lat, trip.end_lng),
                },
                {
                  key: 'range',
                  header: t('tracking.trackOnMap.table.range'),
                  cell: (trip) => formatDistance(trip.distance_m ?? undefined),
                },
              ]}
            />
            <IconButton
              icon={panelOpen ? PanelRightClose : PanelRightOpen}
              aria-label={
                panelOpen
                  ? t('tracking.trackOnMap.collapsePanel')
                  : t('tracking.trackOnMap.expandPanel')
              }
              variant="secondary"
              className="absolute right-3 top-3 z-10"
              onClick={() => setPanelOpen((open) => !open)}
            />
          </div>

          {panelOpen ? (
            <aside
              aria-label={t('tracking.trackOnMap.sidePanelLabel')}
              className="flex w-80 shrink-0 flex-col gap-4 overflow-y-auto rounded-lg border border-stroke bg-surface p-4"
            >
              <DriverInfoPanel
                unit={unit}
                hosSummary={hosSummary.data}
                hasMalfunction={(unit?.malfunction_codes?.length ?? 0) > 0}
                telemetry={diagnostics.data?.telemetry}
              />

              <PermissionGate permission={PERM.unitsDiagnostics}>
                <UnitDiagnosticsPanel
                  diagnostics={diagnostics.data}
                  isLoading={diagnostics.isLoading}
                  vin={unitDetail.data?.vin}
                />
              </PermissionGate>

              <PermissionGate permission={PERM.trackingViewHistory}>
                <div>
                  <div className="mb-2 flex items-center justify-between">
                    <h3 className="text-body-sm font-semibold uppercase tracking-wide text-neutral-600">
                      {t('tracking.trackOnMap.histories.title')}
                    </h3>
                    <div className="flex items-center gap-1">
                      <IconButton
                        icon={ChevronLeft}
                        size="sm"
                        variant="ghost"
                        aria-label={t('tracking.trackOnMap.histories.previousDay')}
                        onClick={() => setDate((d) => new Date(d.getTime() - 86_400_000))}
                      />
                      <span className="text-body-sm text-neutral-700">{formatDate(date)}</span>
                      <IconButton
                        icon={ChevronRight}
                        size="sm"
                        variant="ghost"
                        aria-label={t('tracking.trackOnMap.histories.nextDay')}
                        onClick={() => setDate((d) => new Date(d.getTime() + 86_400_000))}
                      />
                    </div>
                  </div>
                  <TripHistoryTimeline
                    trips={trips.data?.data ?? []}
                    selectedTripId={selectedTripId}
                    onSelect={setSelectedTripId}
                    isLoading={trips.isLoading}
                    isError={trips.isError}
                    onRetry={() => void trips.refetch()}
                  />
                </div>
              </PermissionGate>
            </aside>
          ) : null}
        </div>
      )}
    </div>
  );
}

export default TrackOnMapPage;
