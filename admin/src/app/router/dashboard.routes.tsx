import type { RouteObject } from 'react-router-dom';

import { guardedIndexRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

export const dashboardRoutes: RouteObject[] = [
  guardedIndexRoute(
    async () => (await import('@/features/dashboard/pages/DashboardPage')).DashboardPage,
    { permission: PERM.dashboardRead },
  ),
];
