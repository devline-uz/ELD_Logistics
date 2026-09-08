import type { RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

/** `/notifications` — sahifa (7.8, TZ §7.11). */
export const notificationsRoutes: RouteObject[] = [
  guardedRoute(
    'notifications',
    async () =>
      (await import('@/features/notifications/pages/NotificationsPage')).NotificationsPage,
    { permission: PERM.notificationsRead },
  ),
];
