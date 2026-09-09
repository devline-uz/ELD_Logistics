/**
 * Trip polyline qatlami (`fe-map` skill, Trip polyline bo'limi):
 * `primary` rangda, 4 px, `line-cap: round`; to'xtash nuqtalari raqamli
 * markerlar bilan (1, 2, 3…); segment tanlanganda qolgan segmentlar (kunning
 * boshqa trip'lari, boshlanish/tugash nuqtalaridan tortilgan sodda chiziq —
 * ularning to'liq geometriyasi so'ralmaydi, F169) 30% shaffofga o'tadi va
 * tanlangan segment uchun `fitBounds` (padding 64px) chaqiriladi.
 */
import { useEffect, useRef } from 'react';
import type { Map as MapLibreMap } from 'maplibre-gl';
import * as maplibregl from 'maplibre-gl';
import { LngLatBounds } from 'maplibre-gl';

import { whenStyleReady } from './mapReady';
import type { LngLatTuple } from './polyline';

const OVERVIEW_SOURCE_ID = 'trip-overview-lines';
const OVERVIEW_LAYER = 'trip-overview-lines-line';
const ACTIVE_SOURCE_ID = 'trip-active-line';
const ACTIVE_LAYER = 'trip-active-line-line';

export interface TripStopMarker {
  index: number;
  lngLat: LngLatTuple;
  label: string;
}

export interface UseTripPolylineLayerOptions {
  /** Kunning barcha trip'lari — sodda (boshlanish→tugash) chiziqlar, 30% shaffof. */
  overviewLines?: LngLatTuple[][];
  /** Tanlangan trip'ning to'liq geometriyasi (`include_polyline=true`), to'liq shaffoflik. */
  activeLine?: LngLatTuple[];
  stops?: TripStopMarker[];
  /** Yangi segment tanlanganda `fitBounds` chaqirilsinmi (default true). */
  fitOnChange?: boolean;
}

function addLayers(map: MapLibreMap): void {
  if (!map.getSource(OVERVIEW_SOURCE_ID)) {
    map.addSource(OVERVIEW_SOURCE_ID, {
      type: 'geojson',
      data: { type: 'FeatureCollection', features: [] },
    });
    map.addLayer({
      id: OVERVIEW_LAYER,
      type: 'line',
      source: OVERVIEW_SOURCE_ID,
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': '#2F6FED', 'line-width': 3, 'line-opacity': 0.3 },
    });
  }

  if (!map.getSource(ACTIVE_SOURCE_ID)) {
    map.addSource(ACTIVE_SOURCE_ID, {
      type: 'geojson',
      data: { type: 'FeatureCollection', features: [] },
    });
    map.addLayer({
      id: ACTIVE_LAYER,
      type: 'line',
      source: ACTIVE_SOURCE_ID,
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': '#2F6FED', 'line-width': 4, 'line-opacity': 1 },
    });
  }
}

function toLineFeatures(lines: LngLatTuple[][]): GeoJSON.Feature[] {
  return lines
    .filter((line) => line.length >= 2)
    .map((coordinates) => ({
      type: 'Feature',
      properties: {},
      geometry: { type: 'LineString', coordinates },
    }));
}

export function useTripPolylineLayer(
  map: MapLibreMap | null,
  options: UseTripPolylineLayerOptions,
): void {
  const stopMarkersRef = useRef<InstanceType<typeof maplibregl.Marker>[]>([]);

  useEffect(() => {
    if (!map) return undefined;
    // `once('load')` cleanup'siz qolib ketmasligi uchun — `whenStyleReady`
    // handler'ni cleanup'da `off` qiladi (B2).
    return whenStyleReady(map, addLayers);
  }, [map]);

  useEffect(() => {
    if (!map) return undefined;

    const apply = () => {
      // eslint-disable-next-line @typescript-eslint/no-unnecessary-type-assertion -- tsc talab qiladi (Source'da setData yo'q)
      const overviewSource = map.getSource(OVERVIEW_SOURCE_ID) as
        maplibregl.GeoJSONSource | undefined;
      void overviewSource?.setData({
        type: 'FeatureCollection',
        features: toLineFeatures(options.overviewLines ?? []),
      });

      // eslint-disable-next-line @typescript-eslint/no-unnecessary-type-assertion -- tsc talab qiladi (Source'da setData yo'q)
      const activeSource = map.getSource(ACTIVE_SOURCE_ID) as maplibregl.GeoJSONSource | undefined;
      const activeCoords = options.activeLine ?? [];
      void activeSource?.setData({
        type: 'FeatureCollection',
        features: toLineFeatures(activeCoords.length > 0 ? [activeCoords] : []),
      });

      for (const marker of stopMarkersRef.current) marker.remove();
      stopMarkersRef.current = [];
      for (const stop of options.stops ?? []) {
        const el = document.createElement('div');
        el.className =
          'flex h-6 w-6 items-center justify-center rounded-full bg-primary text-body-sm font-semibold text-white shadow';
        el.textContent = stop.label;
        const marker = new maplibregl.Marker({ element: el }).setLngLat(stop.lngLat).addTo(map);
        stopMarkersRef.current.push(marker);
      }

      if ((options.fitOnChange ?? true) && activeCoords.length > 0) {
        const bounds = activeCoords.reduce(
          (acc, coord) => acc.extend(coord),
          new LngLatBounds(activeCoords[0], activeCoords[0]),
        );
        map.fitBounds(bounds, { padding: 64, duration: 500, maxZoom: 16 });
      }
    };

    if (map.getSource(ACTIVE_SOURCE_ID)) {
      apply();
      return undefined;
    }
    return whenStyleReady(map, () => {
      addLayers(map);
      apply();
    });
  }, [map, options.overviewLines, options.activeLine, options.stops, options.fitOnChange]);

  useEffect(
    () => () => {
      for (const marker of stopMarkersRef.current) marker.remove();
    },
    [],
  );
}
