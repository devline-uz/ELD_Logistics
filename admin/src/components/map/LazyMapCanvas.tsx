/**
 * `MapCanvas`ning lazy chunk kirish nuqtasi (F165) — ekranlar bu faylni
 * ishlatadi, `MapCanvas.tsx`ni to'g'ridan-to'g'ri emas, shunda `maplibre-gl`
 * (~800 KB) faqat xarita kerak bo'lganda yuklanadi.
 *
 * `VITE_MAP_STYLE_URL` bo'sh bo'lsa xarita umuman import qilinmaydi —
 * `MapUnavailable` ko'rsatiladi (D-Q1), shu bilan bo'sh muhitda ham chunk
 * behuda yuklanmaydi.
 */
import { lazy, Suspense, type Ref } from 'react';

import { Skeleton } from '@/components/feedback/Skeleton';

import { MapUnavailable } from './MapUnavailable';
import type { MapCanvasHandle, MapCanvasProps } from './MapCanvas';

const InnerMapCanvas = lazy(() => import('./MapCanvas'));

export const MAP_STYLE_URL = import.meta.env.VITE_MAP_STYLE_URL ?? '';

export interface LazyMapCanvasProps extends Omit<MapCanvasProps, 'styleUrl'> {
  mapRef?: Ref<MapCanvasHandle>;
}

/** Xarita kerak bo'lgan har bir ekran shu komponentni ishlatadi. */
export function LazyMapCanvas({ mapRef, className, ...props }: LazyMapCanvasProps) {
  if (!MAP_STYLE_URL) {
    return <MapUnavailable className={className} />;
  }

  return (
    <Suspense fallback={<Skeleton variant="map" className={className} />}>
      <InnerMapCanvas ref={mapRef} styleUrl={MAP_STYLE_URL} className={className} {...props} />
    </Suspense>
  );
}

export default LazyMapCanvas;
