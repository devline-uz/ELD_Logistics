/**
 * `LiveUnit[]` → klasterlanadigan GeoJSON `FeatureCollection` — sof funksiya,
 * `useLiveUnitsLayer.ts` va 4.12 performans testidan (`liveUnitsGeoJson.perf.test.ts`)
 * alohida import qilinadi.
 */
import type { LiveUnit } from '@/api/types';

export const STALE_AFTER_MS = 60_000;

export interface LiveUnitFeatureProperties {
  unitId: string;
  heading: number;
  dutyStatus: string;
  onlineStatus: string;
  stale: boolean;
}

export type LiveUnitFeatureCollection = GeoJSON.FeatureCollection<
  GeoJSON.Point,
  LiveUnitFeatureProperties
>;

function toFeature(unit: LiveUnit, now: number): LiveUnitFeatureCollection['features'][number] {
  const lastSeenMs = unit.last_seen_at ? Date.parse(unit.last_seen_at) : NaN;
  const stale = Number.isFinite(lastSeenMs) ? now - lastSeenMs > STALE_AFTER_MS : false;

  return {
    type: 'Feature',
    id: unit.unit_id,
    geometry: {
      type: 'Point',
      coordinates: [unit.lng ?? 0, unit.lat ?? 0],
    },
    properties: {
      unitId: unit.unit_id ?? '',
      heading: unit.heading_deg ?? 0,
      dutyStatus: unit.duty_status ?? 'OFF',
      onlineStatus: unit.online_status ?? 'offline',
      stale,
    },
  };
}

/** Koordinatasiz unit'lar (hali telemetriya kelmagan) chizilmaydi. */
export function buildLiveUnitsGeoJson(
  units: LiveUnit[],
  now: number = Date.now(),
): LiveUnitFeatureCollection {
  return {
    type: 'FeatureCollection',
    features: units
      .filter((unit) => typeof unit.lat === 'number' && typeof unit.lng === 'number')
      .map((unit) => toFeature(unit, now)),
  };
}
