/**
 * Trip polyline qatlami (`fe-map` skill, Trip polyline bo'limi):
 * `primary` rangda, 4 px, `line-cap: round`; to'xtash nuqtalari raqamli
 * markerlar bilan (1, 2, 3…); segment tanlanganda qolganlari 30% shaffofga
 * o'tadi va `fitBounds` (padding 64px) chaqiriladi.
 */
import { useEffect, useRef } from 'react';
import type { Map as MapLibreMap } from 'maplibre-gl';
import maplibregl, { LngLatBounds } from 'maplibre-gl';

import type { LngLatTuple } from './polyline';

const SOURCE_ID = 'trip-polyline';
const LINE_LAYER = 'trip-polyline-line';

export interface TripStopMarker {
  index: number;
  lngLat: LngLatTuple;
  label: string;
}

export interface UseTripPolylineLayerOptions {
  /** Segment tanlanmagan bo'lsa `undefined` — qatlam butunlay tozalanadi. */
  coordinates: LngLatTuple[] | undefined;
  /** `true` — boshqa (tanlanmagan) segmentlar mavjud, shuning uchun 30% shaffof (fe-map). */
  dimmed?: boolean;
  stops?: TripStopMarker[];
  /** Yangi segment tanlanganda `fitBounds` chaqirilsinmi (default true). */
  fitOnChange?: boolean;
}

function addLayer(map: MapLibreMap): void {
  if (map.getSource(SOURCE_ID)) return;
  map.addSource(SOURCE_ID, {
    type: 'geojson',
    data: { type: 'FeatureCollection', features: [] },
  });
  map.addLayer({
    id: LINE_LAYER,
    type: 'line',
    source: SOURCE_ID,
    layout: { 'line-cap': 'round', 'line-join': 'round' },
    paint: {
      'line-color': '#2F6FED',
      'line-width': 4,
      'line-opacity': 1,
    },
  });
}

export function useTripPolylineLayer(
  map: MapLibreMap | null,
  options: UseTripPolylineLayerOptions,
): void {
  const stopMarkersRef = useRef<InstanceType<typeof maplibregl.Marker>[]>([]);

  useEffect(() => {
    if (!map) return undefined;
    const ensure = () => addLayer(map);
    if (map.isStyleLoaded()) ensure();
    else map.once('load', ensure);
    return undefined;
  }, [map]);

  useEffect(() => {
    if (!map) return undefined;

    const apply = () => {
      const source = map.getSource(SOURCE_ID) as maplibregl.GeoJSONSource | undefined;
      if (!source) return;

      const coordinates = options.coordinates ?? [];
      source.setData({
        type: 'FeatureCollection',
        features:
          coordinates.length > 0
            ? [
                {
                  type: 'Feature',
                  properties: {},
                  geometry: { type: 'LineString', coordinates },
                },
              ]
            : [],
      });

      if (map.getLayer(LINE_LAYER)) {
        map.setPaintProperty(LINE_LAYER, 'line-opacity', options.dimmed ? 0.3 : 1);
      }

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

      if ((options.fitOnChange ?? true) && coordinates.length > 0) {
        const bounds = coordinates.reduce(
          (acc, coord) => acc.extend(coord),
          new LngLatBounds(coordinates[0], coordinates[0]),
        );
        map.fitBounds(bounds, { padding: 64, duration: 500, maxZoom: 16 });
      }
    };

    if (map.isStyleLoaded() && map.getSource(SOURCE_ID)) apply();
    else map.once('load', apply);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [map, options.coordinates, options.dimmed, options.stops, options.fitOnChange]);

  useEffect(
    () => () => {
      for (const marker of stopMarkersRef.current) marker.remove();
    },
    [],
  );
}
