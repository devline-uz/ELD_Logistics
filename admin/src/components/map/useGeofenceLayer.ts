/**
 * Geofence doirasi + tavsiya etilgan yo'nalish (`fe-map` skill, Geofence bo'limi):
 * - `geofence_m` radiusi manzil nuqtasi atrofida doira: fill 10% `success`,
 *   stroke `success` (default radius 300 m, F170).
 * - `directions` — uzuq chiziq (`line-dasharray`), rang `neutral-400`.
 */
import { useEffect } from 'react';
import type { GeoJSONSource, Map as MapLibreMap } from 'maplibre-gl';

import { whenStyleReady } from './mapReady';
import type { LngLatTuple } from './polyline';

const GEOFENCE_SOURCE = 'route-geofence';
const GEOFENCE_FILL_LAYER = 'route-geofence-fill';
const GEOFENCE_STROKE_LAYER = 'route-geofence-stroke';
const DIRECTIONS_SOURCE = 'route-directions';
const DIRECTIONS_LAYER = 'route-directions-line';

const SUCCESS_COLOR = '#1AA05D';
const NEUTRAL_400 = '#9AA4B2';
const EARTH_RADIUS_M = 6_378_137;

/** Doira geometriyasini poligon sifatida quradi (64 nuqta — yetarli silliqlik). */
function circlePolygon(center: LngLatTuple, radiusM: number): LngLatTuple[] {
  const [lng, lat] = center;
  const points: LngLatTuple[] = [];
  const latRad = (lat * Math.PI) / 180;
  for (let i = 0; i <= 64; i++) {
    const angle = (i / 64) * 2 * Math.PI;
    const dx = (radiusM * Math.cos(angle)) / (EARTH_RADIUS_M * Math.cos(latRad));
    const dy = (radiusM * Math.sin(angle)) / EARTH_RADIUS_M;
    points.push([lng + (dx * 180) / Math.PI, lat + (dy * 180) / Math.PI]);
  }
  return points;
}

export interface UseGeofenceLayerOptions {
  destination?: LngLatTuple;
  geofenceM?: number;
  directions?: LngLatTuple[];
}

function ensureLayers(map: MapLibreMap): void {
  if (!map.getSource(GEOFENCE_SOURCE)) {
    map.addSource(GEOFENCE_SOURCE, {
      type: 'geojson',
      data: { type: 'FeatureCollection', features: [] },
    });
    map.addLayer({
      id: GEOFENCE_FILL_LAYER,
      type: 'fill',
      source: GEOFENCE_SOURCE,
      paint: { 'fill-color': SUCCESS_COLOR, 'fill-opacity': 0.1 },
    });
    map.addLayer({
      id: GEOFENCE_STROKE_LAYER,
      type: 'line',
      source: GEOFENCE_SOURCE,
      paint: { 'line-color': SUCCESS_COLOR, 'line-width': 2 },
    });
  }

  if (!map.getSource(DIRECTIONS_SOURCE)) {
    map.addSource(DIRECTIONS_SOURCE, {
      type: 'geojson',
      data: { type: 'FeatureCollection', features: [] },
    });
    map.addLayer({
      id: DIRECTIONS_LAYER,
      type: 'line',
      source: DIRECTIONS_SOURCE,
      layout: { 'line-cap': 'round' },
      paint: { 'line-color': NEUTRAL_400, 'line-width': 3, 'line-dasharray': [2, 2] },
    });
  }
}

export function useGeofenceLayer(map: MapLibreMap | null, options: UseGeofenceLayerOptions): void {
  useEffect(() => {
    if (!map) return undefined;

    const apply = () => {
      ensureLayers(map);

      // eslint-disable-next-line @typescript-eslint/no-unnecessary-type-assertion -- tsc talab qiladi (Source'da setData yo'q)
      const geofenceSource = map.getSource(GEOFENCE_SOURCE) as GeoJSONSource | undefined;
      if (geofenceSource) {
        void geofenceSource.setData({
          type: 'FeatureCollection',
          features:
            options.destination && options.geofenceM
              ? [
                  {
                    type: 'Feature',
                    properties: {},
                    geometry: {
                      type: 'Polygon',
                      coordinates: [circlePolygon(options.destination, options.geofenceM)],
                    },
                  },
                ]
              : [],
        });
      }

      // eslint-disable-next-line @typescript-eslint/no-unnecessary-type-assertion -- tsc talab qiladi (Source'da setData yo'q)
      const directionsSource = map.getSource(DIRECTIONS_SOURCE) as GeoJSONSource | undefined;
      if (directionsSource) {
        void directionsSource.setData({
          type: 'FeatureCollection',
          features:
            options.directions && options.directions.length > 0
              ? [
                  {
                    type: 'Feature',
                    properties: {},
                    geometry: { type: 'LineString', coordinates: options.directions },
                  },
                ]
              : [],
        });
      }
    };

    // `once('load')` cleanup'siz qolib ketmasligi uchun (B2).
    return whenStyleReady(map, apply);
  }, [map, options.destination, options.geofenceM, options.directions]);
}
