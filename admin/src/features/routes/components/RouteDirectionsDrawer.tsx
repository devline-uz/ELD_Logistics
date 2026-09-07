/**
 * Route "Directions" paneli — §7.7.3: geofence doirasi (F170) + tavsiya
 * etilgan yo'nalish (`GET /routes/{id}/directions`, uzuq chiziq).
 */
import { useEffect, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import maplibregl, { type Map as MapLibreMap } from 'maplibre-gl';

import { useRouteDirections } from '@/api/queries/routes';
import type { Route } from '@/api/types';
import { LazyMapCanvas } from '@/components/map/LazyMapCanvas';
import { decodePolyline } from '@/components/map/polyline';
import { useGeofenceLayer } from '@/components/map/useGeofenceLayer';
import { Drawer } from '@/components/ui/Drawer';
import { Skeleton } from '@/components/feedback/Skeleton';
import { useUnitSystem } from '@/hooks/useUnitSystem';
import { useDateFormat } from '@/hooks/useDateFormat';

export interface RouteDirectionsDrawerProps {
  open: boolean;
  onClose: () => void;
  route: Route | undefined;
}

export function RouteDirectionsDrawer({ open, onClose, route }: RouteDirectionsDrawerProps) {
  const { t } = useTranslation();
  const { formatDistance } = useUnitSystem();
  const { formatDuration } = useDateFormat();
  const [map, setMap] = useState<MapLibreMap | null>(null);
  const markersRef = useRef<InstanceType<typeof maplibregl.Marker>[]>([]);

  const directions = useRouteDirections(route?.id, { enabled: open });

  const destination = useMemo<[number, number] | undefined>(
    () =>
      typeof route?.destination?.lng === 'number' && typeof route?.destination?.lat === 'number'
        ? [route.destination.lng, route.destination.lat]
        : undefined,
    [route],
  );

  useGeofenceLayer(map, {
    destination,
    geofenceM: route?.geofence_m ?? 300,
    directions: decodePolyline(directions.data?.polyline),
  });

  useEffect(() => {
    if (!map) return undefined;
    for (const marker of markersRef.current) marker.remove();
    markersRef.current = [];

    const origin = directions.data?.origin ?? route?.origin;
    const dest = directions.data?.destination ?? route?.destination;
    if (typeof origin?.lng === 'number' && typeof origin?.lat === 'number') {
      markersRef.current.push(new maplibregl.Marker().setLngLat([origin.lng, origin.lat]).addTo(map));
    }
    if (typeof dest?.lng === 'number' && typeof dest?.lat === 'number') {
      markersRef.current.push(new maplibregl.Marker().setLngLat([dest.lng, dest.lat]).addTo(map));
    }

    return () => {
      for (const marker of markersRef.current) marker.remove();
    };
  }, [map, directions.data, route]);

  return (
    <Drawer open={open} onClose={onClose} title={t('routes.list.actions.directions')} size="lg">
      <div className="flex h-full flex-col gap-3">
        <div className="h-72 overflow-hidden rounded-lg">
          <LazyMapCanvas
            onLoad={setMap}
            ariaLabel={t('routes.list.actions.directions')}
            initialCenter={destination}
            initialZoom={destination ? 10 : undefined}
          />
        </div>

        {directions.isLoading ? (
          <Skeleton variant="text" count={2} />
        ) : directions.data?.provider === 'nop' || !directions.data?.polyline ? (
          <p className="text-body-sm text-neutral-500">{t('routes.directions.unavailable')}</p>
        ) : (
          <dl className="grid grid-cols-2 gap-2 text-body-sm">
            <dt className="text-neutral-500">{t('routes.directions.distance')}</dt>
            <dd className="text-neutral-900">{formatDistance(directions.data?.distance_m ?? undefined)}</dd>
            <dt className="text-neutral-500">{t('routes.directions.duration')}</dt>
            <dd className="text-neutral-900">
              {formatDuration(
                typeof directions.data?.duration_s === 'number' ? directions.data.duration_s : undefined,
                { unit: 'seconds' },
              )}
            </dd>
          </dl>
        )}
      </div>
    </Drawer>
  );
}

export default RouteDirectionsDrawer;
