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
import { useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useLocation, useNavigate, useParams } from 'react-router-dom';

import { useUnitDiagnostics } from '@/api/queries/units';
import { useHosSummary } from '@/api/queries/hos';
import { useTrackingLive, useTrackingRefresh, useUnitTrips, useTrip } from '@/api/queries/tracking';
import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { Button } from '@/components/ui/Button';
import { DatePicker } from '@/components/ui/DatePicker';
import { IconButton } from '@/components/ui/IconButton';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { PERM } from '@/lib/permissions';
import { LazyMapCanvas } from '@/components/map/LazyMapCanvas';
import type { MapCanvasHandle } from '@/components/map/MapCanvas';
import type { Map as MapLibreMap } from 'maplibre-gl';
import { useLiveUnitsLayer } from '@/components/map/useLiveUnitsLayer';
import { useTripPolylineLayer, type TripStopMarker } from '@/components/map/useTripPolylineLayer';
import { decodePolyline } from '@/components/map/polyline';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useUnitSystem } from '@/hooks/useUnitSystem';
import { ChevronLeft, ChevronRight, PanelRightClose, PanelRightOpen, RefreshCw } from 'lucide-react';

import { DriverInfoPanel } from '../components/DriverInfoPanel';
import { TripHistoryTimeline } from '../components/TripHistoryTimeline';
import { DUTY_STATUS_TONE, ONLINE_STATUS_TONE } from '../components/trackingColumns';
import { UnitDiagnosticsPanel } from '../components/UnitDiagnosticsPanel';
import { useTrackingChannel } from '../hooks/useTrackingChannel';

function toDateParam(date: Date): string {
  return date.toISOString().slice(0, 10);
}

export function TrackOnMapPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation() as { state?: { from?: 'units' } };
  const { unitId } = useParams<{ unitId: string }>();
  const { formatDate, formatRelative } = useDateFormat();
  const { formatDistance } = useUnitSystem();

  const [panelOpen, setPanelOpen] = useState(true);
  const [date, setDate] = useState<Date>(new Date());
  const [selectedTripId, setSelectedTripId] = useState<string | undefined>(undefined);
  const mapRef = useRef<MapCanvasHandle>(null);
  // Ref o'zgarishi qayta render'ni trigger qilmaydi — qatlam hook'lari uchun
  // xarita instansiyasi `onLoad` orqali holatga olinadi.
  const [mapInstance, setMapInstance] = useState<MapLibreMap | null>(null);

  const live = useTrackingLive({ unit_ids: unitId ?? '' }, { enabled: Boolean(unitId) });
  const unit = live.data?.data?.find((u) => u.unit_id === unitId);

  useTrackingChannel({ enabled: Boolean(unitId), unitIds: unitId ? [unitId] : undefined, onEvent: () => void live.refetch() });

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
      result.push({ index: 1, lngLat: [selectedTrip.start_lng, selectedTrip.start_lat], label: '1' });
    }
    if (typeof selectedTrip.end_lat === 'number' && typeof selectedTrip.end_lng === 'number') {
      result.push({ index: 2, lngLat: [selectedTrip.end_lng, selectedTrip.end_lat], label: '2' });
    }
    return result;
  }, [selectedTrip]);

  const map = mapInstance;

  useLiveUnitsLayer(map, unit ? [unit] : [], {
    buildPopupProps: (u) => ({
      driverName: `${u.driver?.first_name ?? ''} ${u.driver?.last_name ?? ''}`.trim() || 'N/A',
      dutyStatus: u.duty_status ?? 'OFF',
      dutyStatusTone: DUTY_STATUS_TONE[u.duty_status ?? 'OFF'] ?? 'neutral',
      unitNumber: u.unit_number ?? 'N/A',
      odometer: formatDistance(u.odometer_m),
      location: `${u.lat?.toFixed(7) ?? 'N/A'}, ${u.lng?.toFixed(7) ?? 'N/A'}`,
      hasCoordinates: typeof u.lat === 'number' && typeof u.lng === 'number',
      relativeTime: formatRelative(u.last_seen_at),
      onlineTone: ONLINE_STATUS_TONE[u.online_status ?? 'offline'] ?? 'neutral',
      onlineLabel: t(`enums.connection_status.${u.online_status ?? 'offline'}`, {
        defaultValue: u.online_status ?? 'offline',
      }),
      onViewTracking: () => undefined,
    }),
    formatListEntry: (u) => u.unit_number ?? 'N/A',
    listPopupTitle: t('map.clusterPopup.title'),
  });

  useTripPolylineLayer(map, { overviewLines, activeLine, stops });

  const breadcrumbItems =
    location.state?.from === 'units'
      ? [
          { label: t('fleet.units.title'), href: '/units' },
          { label: t('fleet.units.detail.breadcrumb', { unitNumber: unit?.unit_number ?? unitId }), href: `/units/${unitId}` },
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

      <div className="relative flex min-h-[520px] flex-1 gap-3">
        <div className="relative flex-1 overflow-hidden rounded-lg">
          <LazyMapCanvas
            mapRef={mapRef}
            onLoad={setMapInstance}
            ariaLabel={t('tracking.trackOnMap.mapAriaLabel', { unitNumber: unit?.unit_number ?? unitId })}
            initialCenter={
              typeof unit?.lng === 'number' && typeof unit?.lat === 'number'
                ? [unit.lng, unit.lat]
                : undefined
            }
            initialZoom={typeof unit?.lat === 'number' ? 12 : undefined}
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
            />

            <PermissionGate permission={PERM.unitsDiagnostics}>
              <UnitDiagnosticsPanel diagnostics={diagnostics.data} isLoading={diagnostics.isLoading} />
            </PermissionGate>

            <PermissionGate permission={PERM.trackingViewHistory}>
              <div>
                <div className="mb-2 flex items-center justify-between">
                  <h3 className="text-body-sm font-semibold uppercase tracking-wide text-neutral-500">
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
    </div>
  );
}

export default TrackOnMapPage;
