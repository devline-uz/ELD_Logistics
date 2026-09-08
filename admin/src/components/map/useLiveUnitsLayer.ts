/**
 * Jonli kuzatuv qatlami — GeoJSON `source` + `cluster: true` (F167 [MUST]).
 *
 * - `cluster radius`: 50 px, `clusterMaxZoom`: 14 (fe-map jadvali).
 * - Klaster bosilganda: agar kengaytirish mumkin bo'lsa zoom qilinadi;
 *   oxirgi zoom darajasida (`clusterMaxZoom` dan keyin ham to'plangan bo'lsa)
 *   spiderfy o'rniga ro'yxat popup'i ko'rsatiladi (fe-map).
 * - 60 soniyadan eski nuqta 50% shaffof (F166) — `stale` xususiyati har
 *   15 soniyada qayta hisoblanadi (yangi fetch kutilmaydi).
 * - `bounds` o'zgarishi hech qachon `GET /tracking/live`ni qayta chaqirmaydi
 *   (F168) — bu hook faqat client tomonda mavjud `units`ni chizadi.
 */
import { useCallback, useEffect, useRef } from 'react';
import type { Root } from 'react-dom/client';
import type { GeoJSONSource, Map as MapLibreMap, MapGeoJSONFeature } from 'maplibre-gl';
import maplibregl from 'maplibre-gl';

import type { LiveUnit } from '@/api/types';

import { buildLiveUnitsGeoJson, type LiveUnitFeatureProperties } from './liveUnitsGeoJson';
import { whenStyleReady } from './mapReady';
import { registerDutyStatusIcons } from './markerIcons';
import { mountUnitMarkerCard, type UnitMarkerCardProps } from './UnitMarkerCard';

const SOURCE_ID = 'live-units';
const CLUSTER_LAYER = 'live-units-clusters';
const CLUSTER_COUNT_LAYER = 'live-units-cluster-count';
const RING_LAYER = 'live-units-ring';
const POINT_LAYER = 'live-units-point';

const STALE_RECOMPUTE_INTERVAL_MS = 15_000;

export type { LiveUnitFeatureProperties };

export interface UseLiveUnitsLayerOptions {
  /** Marker bosilganda — `UnitMarkerCard` popup'i shu callback bergan matnlarni oladi. */
  buildPopupProps: (unit: LiveUnit) => UnitMarkerCardProps;
  /** Ro'yxat popup'idagi (klaster to'liq kengaytirilmagan) bitta yozuv matni. */
  formatListEntry: (unit: LiveUnit) => string;
  listPopupTitle: string;
}

const buildGeoJson = buildLiveUnitsGeoJson;

/** `online_status` → halqa rangi (fe-map: online yashil, offline kulrang, disconnected qizil). */
const ONLINE_RING_COLOR: Record<
  'online' | 'idle' | 'offline' | 'disconnected' | 'malfunction',
  string
> = {
  online: '#1AA05D',
  idle: '#F6BA47',
  offline: '#8A94A6',
  disconnected: '#E5484D',
  malfunction: '#E5484D',
};

function addLayers(map: MapLibreMap): void {
  if (map.getSource(SOURCE_ID)) return;

  registerDutyStatusIcons(map);

  map.addSource(SOURCE_ID, {
    type: 'geojson',
    data: buildGeoJson([]),
    cluster: true,
    clusterRadius: 50,
    clusterMaxZoom: 14,
  });

  map.addLayer({
    id: CLUSTER_LAYER,
    type: 'circle',
    source: SOURCE_ID,
    filter: ['has', 'point_count'],
    paint: {
      'circle-color': '#2F6FED',
      'circle-opacity': 0.85,
      'circle-radius': ['step', ['get', 'point_count'], 16, 25, 20, 100, 26],
    },
  });

  map.addLayer({
    id: CLUSTER_COUNT_LAYER,
    type: 'symbol',
    source: SOURCE_ID,
    filter: ['has', 'point_count'],
    layout: {
      'text-field': ['get', 'point_count_abbreviated'],
      'text-size': 12,
    },
    paint: { 'text-color': '#ffffff' },
  });

  // `online_status` halqasi — alohida circle layer (symbol layer'da haqiqiy
  // ikonka ustiga halqa chizishning to'g'ri usuli yo'q, faqat SDF ikonkalar
  // uchun `icon-color` bor; bizning ikonkalarimiz rangi canvasda pishirilgan).
  map.addLayer({
    id: RING_LAYER,
    type: 'circle',
    source: SOURCE_ID,
    filter: ['!', ['has', 'point_count']],
    paint: {
      'circle-radius': 11,
      'circle-color': 'transparent',
      'circle-stroke-width': 2,
      'circle-opacity': ['case', ['get', 'stale'], 0.5, 1],
      'circle-stroke-opacity': ['case', ['get', 'stale'], 0.5, 1],
      'circle-stroke-color': [
        'match',
        ['get', 'onlineStatus'],
        'online',
        ONLINE_RING_COLOR.online,
        'idle',
        ONLINE_RING_COLOR.idle,
        'disconnected',
        ONLINE_RING_COLOR.disconnected,
        'malfunction',
        ONLINE_RING_COLOR.malfunction,
        ONLINE_RING_COLOR.offline,
      ],
    },
  });

  map.addLayer({
    id: POINT_LAYER,
    type: 'symbol',
    source: SOURCE_ID,
    filter: ['!', ['has', 'point_count']],
    layout: {
      'icon-image': ['concat', 'unit-duty-', ['downcase', ['get', 'dutyStatus']]],
      'icon-rotate': ['get', 'heading'],
      'icon-rotation-alignment': 'map',
      'icon-allow-overlap': true,
    },
    paint: {
      'icon-opacity': ['case', ['get', 'stale'], 0.5, 1],
    },
  });
}

export function useLiveUnitsLayer(
  map: MapLibreMap | null,
  units: LiveUnit[],
  options: UseLiveUnitsLayerOptions,
): void {
  const unitsRef = useRef(units);
  unitsRef.current = units;
  const optionsRef = useRef(options);
  optionsRef.current = options;
  const popupRef = useRef<InstanceType<typeof maplibregl.Popup> | null>(null);
  /**
   * Popup ichidagi React root — `popup.remove()` faqat DOM'ni oladi, root
   * `unmount()` qilinmasa uzilgan React daraxti va uning i18n obunasi
   * xotirada qolib ketadi (har marker bosilishida bittadan).
   */
  const popupRootRef = useRef<Root | null>(null);

  /** Popup'ni yopadi va React root'ni bo'shatadi (render tsiklidan tashqarida). */
  const destroyPopup = useCallback(() => {
    const root = popupRootRef.current;
    popupRootRef.current = null;
    popupRef.current?.remove();
    popupRef.current = null;
    // `unmount()` render/commit fazasida chaqirilmasligi kerak — mikrotaskda.
    if (root) queueMicrotask(() => root.unmount());
  }, []);

  // Qatlamlarni bir marta qo'shish + hodisa handler'lari.
  useEffect(() => {
    if (!map) return undefined;

    const cancelReady = whenStyleReady(map, addLayers);

    const showPopup = (
      lngLat: [number, number],
      props: Parameters<typeof mountUnitMarkerCard>[1],
    ) => {
      destroyPopup();
      const container = document.createElement('div');
      popupRootRef.current = mountUnitMarkerCard(container, props);
      const popup = new maplibregl.Popup({ closeButton: true, maxWidth: '220px' })
        .setLngLat(lngLat)
        .setDOMContent(container)
        .addTo(map);
      // Foydalanuvchi popup'ni yopganda ham root bo'shatiladi.
      void popup.once('close', () => {
        const root = popupRootRef.current;
        popupRootRef.current = null;
        if (popupRef.current === popup) popupRef.current = null;
        if (root) queueMicrotask(() => root.unmount());
      });
      popupRef.current = popup;
    };

    const onPointClick = (event: { features?: MapGeoJSONFeature[] }) => {
      const feature = event.features?.[0];
      if (!feature) return;
      const unitId = (feature.properties as LiveUnitFeatureProperties | undefined)?.unitId;
      const unit = unitsRef.current.find((u) => u.unit_id === unitId);
      if (!unit || typeof unit.lng !== 'number' || typeof unit.lat !== 'number') return;
      showPopup([unit.lng, unit.lat], optionsRef.current.buildPopupProps(unit));
    };

    const showListPopup = (lngLat: { lng: number; lat: number }, leaves: GeoJSON.Feature[]) => {
      const ids = new Set(
        leaves
          .map((leaf) => (leaf.properties as LiveUnitFeatureProperties | undefined)?.unitId)
          .filter((id): id is string => Boolean(id)),
      );
      const list = unitsRef.current.filter((unit) => unit.unit_id && ids.has(unit.unit_id));

      const container = document.createElement('div');
      container.className = 'flex max-h-60 w-56 flex-col gap-1 overflow-y-auto p-2 text-body-sm';
      const title = document.createElement('div');
      title.className = 'font-semibold text-neutral-900';
      title.textContent = optionsRef.current.listPopupTitle;
      container.appendChild(title);
      for (const unit of list) {
        const row = document.createElement('div');
        row.className = 'text-neutral-700';
        row.textContent = optionsRef.current.formatListEntry(unit);
        container.appendChild(row);
      }

      destroyPopup();
      popupRef.current = new maplibregl.Popup({ closeButton: true, maxWidth: '240px' })
        .setLngLat(lngLat)
        .setDOMContent(container)
        .addTo(map);
    };

    const onClusterClick = (event: {
      features?: MapGeoJSONFeature[];
      lngLat: { lng: number; lat: number };
    }) => {
      const feature = event.features?.[0];
      if (!feature) return;
      const clusterId = feature.properties?.cluster_id as number | undefined;
      // eslint-disable-next-line @typescript-eslint/no-unnecessary-type-assertion -- tsc talab qiladi (Source'da getClusterExpansionZoom yo'q)
      const source = map.getSource(SOURCE_ID) as GeoJSONSource | undefined;
      if (clusterId === undefined || !source) return;

      void source
        .getClusterExpansionZoom(clusterId)
        .then((zoom) => {
          if (zoom <= (map.getMaxZoom() ?? 22)) {
            map.easeTo({ center: event.lngLat, zoom, duration: 300 });
            return undefined;
          }
          // Kengaytirish mumkin emas (max zoom'da ham to'plangan) — spiderfy
          // o'rniga ro'yxat popup'i (fe-map).
          return source.getClusterLeaves(clusterId, 100, 0).then((leaves) => {
            showListPopup(event.lngLat, leaves);
          });
        })
        .catch(() => {
          // Klaster kengayishi so'ralmadi — jim o'tkaziladi, xarita ishlashda davom etadi.
        });
    };

    const onEnter = () => {
      map.getCanvas().style.cursor = 'pointer';
    };
    const onLeave = () => {
      map.getCanvas().style.cursor = '';
    };

    map.on('click', POINT_LAYER, onPointClick);
    map.on('click', CLUSTER_LAYER, onClusterClick);
    map.on('mouseenter', POINT_LAYER, onEnter);
    map.on('mouseleave', POINT_LAYER, onLeave);
    map.on('mouseenter', CLUSTER_LAYER, onEnter);
    map.on('mouseleave', CLUSTER_LAYER, onLeave);

    return () => {
      map.off('click', POINT_LAYER, onPointClick);
      map.off('click', CLUSTER_LAYER, onClusterClick);
      map.off('mouseenter', POINT_LAYER, onEnter);
      map.off('mouseleave', POINT_LAYER, onLeave);
      map.off('mouseenter', CLUSTER_LAYER, onEnter);
      map.off('mouseleave', CLUSTER_LAYER, onLeave);
      cancelReady();
      destroyPopup();
    };
  }, [map, destroyPopup]);

  // Ma'lumot yangilanganda source'ni yangilash (bounds o'zgarishi trigger qilmaydi — F168).
  //
  // Chaqiruvchi har render'da yangi massiv beradi (`unit ? [unit] : []`), shuning
  // uchun effekt bog'liqligi massiv identifikatori emas, mazmun bo'yicha
  // **barqaror imzo** (signature) — aks holda 15 s'lik stale-taymer har
  // render'da nolga qaytardi va F166 qayta hisobi hech qachon otilmasdi.
  const unitsSignature = units
    .map(
      (unit) =>
        `${unit.unit_id ?? ''}:${unit.lat ?? ''}:${unit.lng ?? ''}:${unit.heading_deg ?? ''}:${
          unit.duty_status ?? ''
        }:${unit.online_status ?? ''}:${unit.last_seen_at ?? ''}`,
    )
    .join('|');

  const updateData = useCallback(() => {
    if (!map) return;
    // eslint-disable-next-line @typescript-eslint/no-unnecessary-type-assertion -- tsc talab qiladi (Source'da setData yo'q)
    const source = map.getSource(SOURCE_ID) as GeoJSONSource | undefined;
    source?.setData(buildGeoJson(unitsRef.current));
  }, [map]);

  // Ma'lumot o'zgarganda — bir marta qo'llash.
  useEffect(() => {
    if (!map) return undefined;
    // `unitsSignature` — mazmun bo'yicha bog'liqlik (yuqoridagi izohga qarang).
    return whenStyleReady(map, updateData);
  }, [map, updateData, unitsSignature]);

  // 60s'dan eski nuqta shaffofligini yangi fetch bo'lmasa ham yangilash (F166).
  useEffect(() => {
    if (!map) return undefined;
    const interval = window.setInterval(updateData, STALE_RECOMPUTE_INTERVAL_MS);
    return () => window.clearInterval(interval);
  }, [map, updateData]);
}
