/**
 * `TrackingMapPanel`ning lazy kirish nuqtasi (F165) — jonli kuzatuv qatlam
 * hook'lari bilan birga `maplibre-gl` faqat panel haqiqatan chizilganda
 * yuklanadi. Kuzatuv ekranlari **shu** faylni import qiladi.
 */
import { lazy, Suspense } from 'react';

import { Skeleton } from '@/components/feedback/Skeleton';

import type { TrackingMapPanelProps } from './TrackingMapPanel';

const InnerTrackingMapPanel = lazy(() => import('./TrackingMapPanel'));

export function LazyTrackingMapPanel(props: TrackingMapPanelProps) {
  return (
    <Suspense fallback={<Skeleton variant="map" className={props.className} />}>
      <InnerTrackingMapPanel {...props} />
    </Suspense>
  );
}

export default LazyTrackingMapPanel;
