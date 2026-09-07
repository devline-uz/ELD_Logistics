import type { RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

const load = () => import('@/features/logs/pages/stubs');

export const logsRoutes: RouteObject[] = [
  guardedRoute('logs/by-unit', async () => (await load()).LogsByUnitPage, {
    permission: PERM.logsRead,
  }),
  guardedRoute('logs/by-driver', async () => (await load()).LogsByDriverPage, {
    permission: PERM.logsRead,
  }),
  guardedRoute('logs/view/:logId', async () => (await load()).LogViewPage, {
    permission: PERM.logsRead,
  }),
  guardedRoute('logs/edit-requests', async () => (await load()).LogEditRequestsPage, {
    permission: PERM.logsRead,
  }),
  guardedRoute('logs/unassigned', async () => (await load()).UnassignedDrivingPage, {
    anyOf: [PERM.logsAssignUnidentified, PERM.logsRead],
  }),
  guardedRoute('violations', async () => (await load()).ViolationsPage, {
    permission: PERM.violationsRead,
  }),
];
