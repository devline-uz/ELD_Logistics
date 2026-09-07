/**
 * 4.12 — 500 marker performans o'lchovi (proksi test).
 *
 * jsdom WebGL bermaydi (`fe-map` skill), shuning uchun haqiqiy GPU fps'ni
 * shu yerda o'lchab bo'lmaydi — real fps Playwright/qo'lda tekshiriladi.
 * Bu test **klient tomonidagi eng qimmat qadam** — GeoJSON `FeatureCollection`
 * qurish (har WS/refetch tsiklida `source.setData()`ga uzatiladigan payload) —
 * 500 unit uchun bitta kadr byudjetidan (~33 ms, 30 fps) sezilarli arzon
 * ekanini tasdiqlaydi, shunda MapLibre GPU tomoni ≥30 fps ushlab turishga
 * imkon topadi (klasterlash F167 bilan birga).
 */
import { describe, expect, it } from 'vitest';

import type { LiveUnit } from '@/api/types';

import { buildLiveUnitsGeoJson } from './liveUnitsGeoJson';

const DUTY_STATUSES = ['OFF', 'SB', 'DR', 'ON'] as const;
const ONLINE_STATUSES = ['online', 'offline', 'disconnected'] as const;

function buildUnits(count: number): LiveUnit[] {
  return Array.from({ length: count }, (_, i) => ({
    unit_id: `unit-${i}`,
    unit_number: String(1000 + i),
    duty_status: DUTY_STATUSES[i % DUTY_STATUSES.length],
    online_status: ONLINE_STATUSES[i % ONLINE_STATUSES.length],
    lat: 30 + (i % 100) * 0.01,
    lng: -90 + (i % 100) * 0.01,
    heading_deg: (i * 7) % 360,
    last_seen_at: new Date(Date.now() - (i % 120) * 1000).toISOString(),
  }));
}

describe('buildLiveUnitsGeoJson — 500 marker performans (proksi)', () => {
  it('500 unit uchun bitta kadr byudjetidan sezilarli arzon', () => {
    const units = buildUnits(500);

    const start = performance.now();
    const geojson = buildLiveUnitsGeoJson(units);
    const elapsedMs = performance.now() - start;

    expect(geojson.features).toHaveLength(500);
    // 30 fps kadr byudjeti — 33.3 ms; GeoJSON qurish shundan ancha past bo'lishi kerak.
    expect(elapsedMs).toBeLessThan(20);
  });

  it('koordinatasiz unit yozuvlarini chizmaydi', () => {
    const units = buildUnits(10);
    units[0]!.lat = undefined;
    units[0]!.lng = undefined;

    const geojson = buildLiveUnitsGeoJson(units);

    expect(geojson.features).toHaveLength(9);
  });

  it('60 soniyadan eski nuqtani `stale: true` deb belgilaydi', () => {
    const now = Date.now();
    const units = buildUnits(1);
    units[0]!.last_seen_at = new Date(now - 90_000).toISOString();

    const geojson = buildLiveUnitsGeoJson(units, now);

    expect(geojson.features[0]?.properties.stale).toBe(true);
  });
});
