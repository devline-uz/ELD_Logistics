/**
 * Route "Directions" drawer'ining **xarita qismi** — §7.7.3: geofence doirasi
 * (F170) + tavsiya etilgan yo'nalish uzuq chizig'i.
 *
 * F165: bu fayl `maplibre-gl` ni statik import qiladi (Marker + qatlam
 * hook'lari), shuning uchun u alohida lazy chunk sifatida ajratilgan —
 * `LazyRouteDirectionsMap` orqali. Drawer'ning o'zi (va u bilan birga
 * `RouteListPage`) maplibre'ga statik bog'lanmaydi.
 */
import { useEffect, useMemo, useRef, useState } from 'react';
import * as maplibregl from 'maplibre-gl';
import type { Map as MapLibreMap } from 'maplibre-gl';

import { LazyMapCanvas } from '@/components/map/LazyMapCanvas';
import { decodePolyline } from '@/components/map/polyline';
import { useGeofenceLayer } from '@/components/map/useGeofenceLayer';

export interface RouteDirectionsMapPoint {
  lat?: number | null;
  lng?: number | null;
}

export interface RouteDirectionsMapProps {
  /** Geofence markazi — route manzili (`destination`). */
  destination?: [number, number];
  /** Geofence radiusi, metrda (default 300 m — F170). */
  geofenceM?: number;
  /** `GET /routes/{id}/directions` javobidagi kodlangan polyline. */
  polyline?: string | null;
  /** Marker qo'yiladigan boshlanish nuqtasi. */
  origin?: RouteDirectionsMapPoint;
  /** Marker qo'yiladigan tugash nuqtasi. */
  destinationPoint?: RouteDirectionsMapPoint;
  ariaLabel: string;
  /** Xarita ekvivalenti bo'lgan jadval id'si (F171). */
  ariaDescribedBy?: string;
  className?: string;
}

export function RouteDirectionsMap({
  destination,
  geofenceM,
  polyline,
  origin,
  destinationPoint,
  ariaLabel,
  ariaDescribedBy,
  className,
}: RouteDirectionsMapProps) {
  const [map, setMap] = useState<MapLibreMap | null>(null);
  const markersRef = useRef<InstanceType<typeof maplibregl.Marker>[]>([]);

  const directionsLine = useMemo(() => decodePolyline(polyline), [polyline]);

  useGeofenceLayer(map, {
    destination,
    geofenceM: geofenceM ?? 300,
    directions: directionsLine,
  });

  useEffect(() => {
    if (!map) return undefined;
    for (const marker of markersRef.current) marker.remove();
    markersRef.current = [];

    if (typeof origin?.lng === 'number' && typeof origin?.lat === 'number') {
      markersRef.current.push(
        new maplibregl.Marker().setLngLat([origin.lng, origin.lat]).addTo(map),
      );
    }
    if (typeof destinationPoint?.lng === 'number' && typeof destinationPoint?.lat === 'number') {
      markersRef.current.push(
        new maplibregl.Marker().setLngLat([destinationPoint.lng, destinationPoint.lat]).addTo(map),
      );
    }

    return () => {
      for (const marker of markersRef.current) marker.remove();
      markersRef.current = [];
    };
  }, [map, origin, destinationPoint]);

  return (
    <LazyMapCanvas
      onLoad={setMap}
      ariaLabel={ariaLabel}
      initialCenter={destination}
      initialZoom={destination ? 10 : undefined}
      ariaDescribedBy={ariaDescribedBy}
      className={className}
    />
  );
}

export default RouteDirectionsMap;
