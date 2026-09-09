/**
 * Route "Directions" paneli — §7.7.3: geofence doirasi (F170) + tavsiya
 * etilgan yo'nalish (`GET /routes/{id}/directions`, uzuq chiziq).
 */
import { useId, useMemo } from 'react';
import { useTranslation } from 'react-i18next';

import { useRouteDirections } from '@/api/queries/routes';
import type { Route } from '@/api/types';
import { MapDataTable } from '@/components/map/MapDataTable';
import { Drawer } from '@/components/ui/Drawer';
import { Skeleton } from '@/components/feedback/Skeleton';
import { useUnitSystem } from '@/hooks/useUnitSystem';
import { useDateFormat } from '@/hooks/useDateFormat';

import { LazyRouteDirectionsMap } from './LazyRouteDirectionsMap';

export interface RouteDirectionsDrawerProps {
  open: boolean;
  onClose: () => void;
  route: Route | undefined;
}

export function RouteDirectionsDrawer({ open, onClose, route }: RouteDirectionsDrawerProps) {
  const { t } = useTranslation();
  const { formatDistance } = useUnitSystem();
  const { formatDuration } = useDateFormat();
  const mapTableId = useId();

  const directions = useRouteDirections(route?.id, { enabled: open });

  const destination = useMemo<[number, number] | undefined>(
    () =>
      typeof route?.destination?.lng === 'number' && typeof route?.destination?.lat === 'number'
        ? [route.destination.lng, route.destination.lat]
        : undefined,
    [route],
  );

  /** Xarita nuqtalari — jadval ekvivalenti uchun (F171). */
  const pointRows = useMemo(() => {
    const origin = directions.data?.origin ?? route?.origin;
    const dest = directions.data?.destination ?? route?.destination;
    const rows: { key: string; point: string; label: string; coordinates: string }[] = [];
    if (typeof origin?.lat === 'number' && typeof origin?.lng === 'number') {
      rows.push({
        key: 'origin',
        point: t('routes.directions.table.origin'),
        label: origin.text ?? '',
        coordinates: `${origin.lat.toFixed(7)}, ${origin.lng.toFixed(7)}`,
      });
    }
    if (typeof dest?.lat === 'number' && typeof dest?.lng === 'number') {
      rows.push({
        key: 'destination',
        point: t('routes.directions.table.destination'),
        label: dest.text ?? '',
        coordinates: `${dest.lat.toFixed(7)}, ${dest.lng.toFixed(7)}`,
      });
    }
    if (destination) {
      rows.push({
        key: 'geofence',
        point: t('routes.directions.table.geofence'),
        label: '',
        coordinates: formatDistance(route?.geofence_m ?? 300),
      });
    }
    return rows;
  }, [directions.data, route, destination, formatDistance, t]);

  return (
    <Drawer open={open} onClose={onClose} title={t('routes.list.actions.directions')} size="lg">
      <div className="flex h-full flex-col gap-3">
        <div className="h-72 overflow-hidden rounded-lg">
          <LazyRouteDirectionsMap
            destination={destination}
            geofenceM={route?.geofence_m ?? 300}
            polyline={directions.data?.polyline}
            origin={directions.data?.origin ?? route?.origin}
            destinationPoint={directions.data?.destination ?? route?.destination}
            ariaLabel={t('routes.list.actions.directions')}
            ariaDescribedBy={mapTableId}
          />
        </div>

        {/* F171 — xarita nuqtalarining jadval ekvivalenti. */}
        <MapDataTable
          id={mapTableId}
          caption={t('routes.directions.table.caption')}
          emptyLabel={t('routes.directions.table.empty')}
          rows={pointRows}
          getRowKey={(row) => row.key}
          columns={[
            { key: 'point', header: t('routes.directions.table.point'), cell: (row) => row.point },
            { key: 'label', header: t('routes.directions.table.label'), cell: (row) => row.label },
            {
              key: 'coordinates',
              header: t('routes.directions.table.coordinates'),
              cell: (row) => row.coordinates,
            },
          ]}
        />

        {directions.isLoading ? (
          <Skeleton variant="text" count={2} />
        ) : directions.data?.provider === 'nop' || !directions.data?.polyline ? (
          <p className="text-body-sm text-neutral-600">{t('routes.directions.unavailable')}</p>
        ) : (
          <dl className="grid grid-cols-2 gap-2 text-body-sm">
            <dt className="text-neutral-600">{t('routes.directions.distance')}</dt>
            <dd className="text-neutral-900">
              {formatDistance(directions.data?.distance_m ?? undefined)}
            </dd>
            <dt className="text-neutral-600">{t('routes.directions.duration')}</dt>
            <dd className="text-neutral-900">
              {formatDuration(
                typeof directions.data?.duration_s === 'number'
                  ? directions.data.duration_s
                  : undefined,
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
