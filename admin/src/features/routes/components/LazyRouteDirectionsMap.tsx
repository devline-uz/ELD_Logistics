/**
 * `RouteDirectionsMap`ning lazy kirish nuqtasi (F165) — `LazyTripMapPanel`
 * bilan bir xil usul: `maplibre-gl` va geofence qatlam hook'lari faqat
 * "Directions" drawer'i ochilganda yuklanadi, `RouteListPage` chunk'i
 * maplibre'ga statik bog'lanmaydi.
 */
import { lazy, Suspense } from 'react';

import { Skeleton } from '@/components/feedback/Skeleton';

import type { RouteDirectionsMapProps } from './RouteDirectionsMap';

const InnerRouteDirectionsMap = lazy(() => import('./RouteDirectionsMap'));

export function LazyRouteDirectionsMap(props: RouteDirectionsMapProps) {
  return (
    <Suspense fallback={<Skeleton variant="map" className={props.className} />}>
      <InnerRouteDirectionsMap {...props} />
    </Suspense>
  );
}

export default LazyRouteDirectionsMap;
