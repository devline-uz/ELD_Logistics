/**
 * MapLibre GL JS wrapper — qo'lda yozilgan, `react-map-gl` ishlatilmaydi (F3).
 *
 * Bu fayl `maplibre-gl`ni (~800 KB) statik import qiladi — shuning uchun
 * chaqiruvchi **hech qachon** to'g'ridan-to'g'ri import qilmaydi, faqat
 * `React.lazy(() => import('@/components/map/MapCanvas'))` orqali (F165),
 * shunda bu chunk asosiy bundle'ga kirmaydi.
 *
 * Provayderga bog'liqlik yo'q (F164): yagona tashqi kirish — `styleUrl` props'i
 * (`VITE_MAP_STYLE_URL`). Xarita komponenti hech qanday provayderga xos SDK
 * yoki kalitni bilmaydi.
 *
 * Qatlamlar (klasterlangan unit'lar, trip polyline, geofence doirasi) bu
 * faylda emas — alohida hook'larda (`useLiveUnitsLayer.ts`,
 * `useTripPolylineLayer.ts`, `useGeofenceLayer.ts`), ular `onLoad` orqali
 * olingan `maplibregl.Map` instansiyasi ustida ishlaydi. `MapCanvas`ning o'zi
 * faqat konteyner, boshqaruvlar va hayot davri (lifecycle) uchun javobgar.
 */
import {
  forwardRef,
  useEffect,
  useImperativeHandle,
  useRef,
  type CSSProperties,
} from 'react';
import maplibregl, { type LngLatLike, type Map as MapLibreMap } from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';

export interface MapCanvasHandle {
  getMap: () => MapLibreMap | null;
}

export interface MapCanvasProps {
  /** `VITE_MAP_STYLE_URL` — bo'sh bo'lishi mumkin emas, chaqiruvchi oldindan tekshiradi. */
  styleUrl: string;
  ariaLabel: string;
  initialCenter?: LngLatLike;
  initialZoom?: number;
  className?: string;
  style?: CSSProperties;
  /** Xarita va uslub to'liq yuklangach — qatlam hook'lari shu yerda ulanadi. */
  onLoad?: (map: MapLibreMap) => void;
}

/** `prefers-reduced-motion` — qatlam hook'lari `easeTo` davomiyligini shunga qarab tanlaydi (F166). */
export function prefersReducedMotion(): boolean {
  if (typeof window === 'undefined' || typeof window.matchMedia !== 'function') return false;
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

/** Marker/kamera animatsiyasi davomiyligi — reduced-motion'da 0 (F166, fe-map jadvali). */
export function easeDurationMs(): number {
  return prefersReducedMotion() ? 0 : 500;
}

export const MapCanvas = forwardRef<MapCanvasHandle, MapCanvasProps>(function MapCanvas(
  { styleUrl, ariaLabel, initialCenter = [0, 20], initialZoom = 3, className, style, onLoad },
  ref,
) {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<MapLibreMap | null>(null);
  const onLoadRef = useRef(onLoad);
  onLoadRef.current = onLoad;

  useImperativeHandle(ref, () => ({ getMap: () => mapRef.current }), []);

  useEffect(() => {
    if (!containerRef.current) return undefined;

    const map = new maplibregl.Map({
      container: containerRef.current,
      style: styleUrl,
      center: initialCenter,
      zoom: initialZoom,
      attributionControl: { compact: true },
      // Klaviatura bilan pan/zoom — F171 (maplibre'ning o'rnatilgan xususiyati).
      keyboard: true,
      cooperativeGestures: false,
    });

    map.addControl(new maplibregl.NavigationControl({ showCompass: false }), 'top-right');
    map.addControl(
      new maplibregl.GeolocateControl({ positionOptions: { enableHighAccuracy: true } }),
      'top-right',
    );

    mapRef.current = map;

    void map.once('load', () => {
      onLoadRef.current?.(map);
    });

    return () => {
      map.remove();
      mapRef.current = null;
    };
    // `styleUrl` o'zgarishi kamdan-kam (env darajasida) — o'zgarsa xarita qayta yaratiladi.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [styleUrl]);

  return (
    <div
      ref={containerRef}
      role="application"
      aria-label={ariaLabel}
      className={className}
      style={{ width: '100%', height: '100%', ...style }}
    />
  );
});

export default MapCanvas;
