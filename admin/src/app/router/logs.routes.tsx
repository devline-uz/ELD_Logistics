import type { RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

const loadLogsByUnit = () => import('@/features/logs/pages/LogsByUnitPage');
const loadLogsByDriver = () => import('@/features/logs/pages/LogsByDriverPage');
const loadLogView = () => import('@/features/logs/pages/LogViewPage');
const loadLogEditRequests = () => import('@/features/logs/pages/LogEditRequestsPage');
const loadUnassignedDriving = () => import('@/features/logs/pages/UnassignedDrivingPage');
const loadViolations = () => import('@/features/logs/pages/ViolationsPage');
const loadViolationDetail = () => import('@/features/logs/pages/ViolationDetailPage');

export const logsRoutes: RouteObject[] = [
  guardedRoute('logs/by-unit', async () => (await loadLogsByUnit()).LogsByUnitPage, {
    permission: PERM.logsRead,
  }),
  guardedRoute('logs/by-driver', async () => (await loadLogsByDriver()).LogsByDriverPage, {
    permission: PERM.logsRead,
  }),
  guardedRoute('logs/view/:logId', async () => (await loadLogView()).LogViewPage, {
    permission: PERM.logsRead,
  }),
  guardedRoute(
    'logs/edit-requests',
    async () => (await loadLogEditRequests()).LogEditRequestsPage,
    {
      permission: PERM.logsRead,
    },
  ),
  guardedRoute(
    'logs/unassigned',
    async () => (await loadUnassignedDriving()).UnassignedDrivingPage,
    {
      anyOf: [PERM.logsAssignUnidentified, PERM.logsRead],
    },
  ),
  guardedRoute('violations', async () => (await loadViolations()).ViolationsPage, {
    permission: PERM.violationsRead,
  }),
  guardedRoute('violations/:violationId', async () => (await loadViolationDetail()).default, {
    permission: PERM.violationsRead,
  }),
];
