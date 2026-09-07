import type { RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

/** Schedule / Due / History — bitta marshrut ichida tab (Bosqich 5). */
export const maintenanceRoutes: RouteObject[] = [
  guardedRoute(
    'maintenance',
    async () => (await import('@/features/maintenance/pages/stubs')).MaintenancePage,
    { permission: PERM.maintenanceRead },
  ),
  guardedRoute('dvir', async () => (await import('@/features/dvir/pages/stubs')).DvirPage, {
    permission: PERM.dvirRead,
  }),
];
