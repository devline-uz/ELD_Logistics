/**
 * Jonli kuzatuv xaritasi paneli — `useLiveUnitsLayer` + `useTripPolylineLayer`
 * bir joyda, `TripMapPanel` bilan bir xil naqsh.
 *
 * Bu fayl qatlam hook'lari orqali `maplibre-gl`ni **statik** import qiladi,
 * shuning uchun ekran uni to'g'ridan-to'g'ri emas, `LazyTrackingMapPanel`
 * orqali ishlatadi (F165). Aks holda sahifa chunk'i `VITE_MAP_STYLE_URL`
 * bo'sh bo'lganda ham 800 KB'lik maplibre'ni tortib olardi.
 */
import { useState } from 'react';
import type { Map as MapLibreMap } from 'maplibre-gl';

import type { LiveUnit } from '@/api/types';

import { LazyMapCanvas } from './LazyMapCanvas';
import type { LngLatTuple } from './polyline';
import { useLiveUnitsLayer, type UseLiveUnitsLayerOptions } from './useLiveUnitsLayer';
import { useTripPolylineLayer, type TripStopMarker } from './useTripPolylineLayer';

export interface TrackingMapPanelProps {
  ariaLabel: string;
  /** Jadval ekvivalenti (`MapDataTable`) `id`si — F171. */
  ariaDescribedBy?: string;
  className?: string;
  /** Klasterlanadigan jonli unit'lar (F167); bo'sh massiv ham to'g'ri holat. */
  units: LiveUnit[];
  /** Popup matnlari — domenga xos formatlash chaqiruvchi ekranda qoladi. */
  liveOptions: UseLiveUnitsLayerOptions;
  /** Tanlanmagan trip segmentlari — 30% shaffof chiziqlar (ixtiyoriy). */
  overviewLines?: LngLatTuple[][];
  /** Tanlangan segment — to'liq geometriya + `fitBounds` (ixtiyoriy). */
  activeLine?: LngLatTuple[];
  stops?: TripStopMarker[];
  initialCenter?: LngLatTuple;
  initialZoom?: number;
  /** Xarita instansiyasi kerak bo'lsa (masalan qo'shimcha qatlam uchun). */
  onMapReady?: (map: MapLibreMap) => void;
}

export function TrackingMapPanel({
  ariaLabel,
  ariaDescribedBy,
  className,
  units,
  liveOptions,
  overviewLines,
  activeLine,
  stops,
  initialCenter,
  initialZoom,
  onMapReady,
}: TrackingMapPanelProps) {
  const [map, setMap] = useState<MapLibreMap | null>(null);

  useLiveUnitsLayer(map, units, liveOptions);
  useTripPolylineLayer(map, { overviewLines, activeLine, stops });

  return (
    <LazyMapCanvas
      onLoad={(instance) => {
        setMap(instance);
        onMapReady?.(instance);
      }}
      ariaLabel={ariaLabel}
      ariaDescribedBy={ariaDescribedBy}
      className={className}
      initialCenter={initialCenter}
      initialZoom={initialZoom}
    />
  );
}

export default TrackingMapPanel;
