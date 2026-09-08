/**
 * Trip xaritasi paneli — polyline + geofence qatlamlari bilan tayyor blok.
 *
 * Bu fayl qatlam hook'larini (`useTripPolylineLayer`, `useGeofenceLayer`)
 * import qiladi, ular esa `maplibre-gl`ni **statik** import qiladi. Shuning
 * uchun chaqiruvchi bu faylni to'g'ridan-to'g'ri emas, `LazyTripMapPanel`
 * orqali ishlatadi (F165) — aks holda xaritasiz ekran (masalan `LogViewPage`)
 * ham 800 KB'lik maplibre chunk'ini tortib olardi.
 */
import { useState } from 'react';
import type { Map as MapLibreMap } from 'maplibre-gl';

import { LazyMapCanvas } from './LazyMapCanvas';
import type { LngLatTuple } from './polyline';
import { useGeofenceLayer } from './useGeofenceLayer';
import { useTripPolylineLayer, type TripStopMarker } from './useTripPolylineLayer';

export interface TripMapPanelProps {
  ariaLabel: string;
  /** Jadval ekvivalenti (`MapDataTable`) `id`si — F171. */
  ariaDescribedBy?: string;
  className?: string;
  /** Tanlanmagan segmentlar — 30% shaffof chiziqlar. */
  overviewLines?: LngLatTuple[][];
  /** Tanlangan segment — to'liq shaffofsiz chiziq + `fitBounds`. */
  activeLine?: LngLatTuple[];
  stops?: TripStopMarker[];
  /** Geofence markazi; berilmasa doira chizilmaydi (F170). */
  destination?: LngLatTuple;
  geofenceM?: number;
  initialCenter?: LngLatTuple;
  initialZoom?: number;
}

export function TripMapPanel({
  ariaLabel,
  ariaDescribedBy,
  className,
  overviewLines,
  activeLine,
  stops,
  destination,
  geofenceM,
  initialCenter,
  initialZoom,
}: TripMapPanelProps) {
  const [map, setMap] = useState<MapLibreMap | null>(null);

  useTripPolylineLayer(map, { overviewLines, activeLine, stops });
  useGeofenceLayer(map, { destination, geofenceM });

  return (
    <LazyMapCanvas
      onLoad={setMap}
      ariaLabel={ariaLabel}
      ariaDescribedBy={ariaDescribedBy}
      className={className}
      initialCenter={initialCenter}
      initialZoom={initialZoom}
    />
  );
}

export default TripMapPanel;
