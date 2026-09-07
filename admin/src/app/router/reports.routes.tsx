import type { RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

const load = () => import('@/features/reports/pages/stubs');

export const reportsRoutes: RouteObject[] = [
  guardedRoute('reports/activity', async () => (await load()).ActivityReportPage, {
    permission: PERM.reportsRead,
  }),
  guardedRoute('reports/distance-by-region', async () => (await load()).DistanceByRegionPage, {
    permission: PERM.reportsRead,
  }),
  guardedRoute('reports/regulator', async () => (await load()).RegulatorExportPage, {
    permission: PERM.reportsRead,
  }),
  guardedRoute('reports/dvir', async () => (await load()).DvirReportPage, {
    permission: PERM.reportsRead,
  }),
  guardedRoute('reports/uncertified-logs', async () => (await load()).UncertifiedLogsPage, {
    permission: PERM.reportsRead,
  }),
  guardedRoute('reports/exports', async () => (await load()).ExportJobsPage, {
    permission: PERM.reportsRead,
  }),
];
