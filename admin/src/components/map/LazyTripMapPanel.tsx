/**
 * `TripMapPanel`ning lazy kirish nuqtasi (F165) — xarita qatlam hook'lari
 * bilan birga `maplibre-gl` faqat panel haqiqatan chizilganda yuklanadi.
 */
import { lazy, Suspense } from 'react';

import { Skeleton } from '@/components/feedback/Skeleton';

import type { TripMapPanelProps } from './TripMapPanel';

const InnerTripMapPanel = lazy(() => import('./TripMapPanel'));

export function LazyTripMapPanel(props: TripMapPanelProps) {
  return (
    <Suspense fallback={<Skeleton variant="map" className={props.className} />}>
      <InnerTripMapPanel {...props} />
    </Suspense>
  );
}

export default LazyTripMapPanel;
