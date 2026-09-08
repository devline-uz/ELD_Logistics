import type { RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

/** Tracking + Routes (nav'da Tracking; Routes — Tracking/Dashboard'dan ochiladi). */
export const trackingRoutes: RouteObject[] = [
  guardedRoute(
    'tracking',
    async () => (await import('@/features/tracking/pages/TrackingListPage')).TrackingListPage,
    { permission: PERM.trackingViewLive },
  ),
  guardedRoute(
    'tracking/units/:unitId',
    async () => (await import('@/features/tracking/pages/TrackOnMapPage')).TrackOnMapPage,
    { permission: PERM.trackingViewLive },
  ),
  guardedRoute(
    'routes',
    async () => (await import('@/features/routes/pages/RouteListPage')).RouteListPage,
    { permission: PERM.routesRead },
  ),
];
