import type { RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

export const reportsRoutes: RouteObject[] = [
  guardedRoute(
    'reports/activity',
    async () => (await import('@/features/reports/pages/ActivityReportPage')).ActivityReportPage,
    { permission: PERM.reportsRead },
  ),
  guardedRoute(
    'reports/activity/:subjectId',
    async () =>
      (await import('@/features/reports/pages/ActivityReportDetailPage')).ActivityReportDetailPage,
    { permission: PERM.reportsRead },
  ),
  guardedRoute(
    'reports/distance-by-region',
    async () =>
      (await import('@/features/reports/pages/DistanceByRegionPage')).DistanceByRegionPage,
    { permission: PERM.reportsRead },
  ),
  guardedRoute(
    'reports/regulator',
    async () => (await import('@/features/reports/pages/RegulatorExportPage')).RegulatorExportPage,
    { permission: PERM.reportsRead },
  ),
  guardedRoute(
    'reports/dvir',
    async () => (await import('@/features/reports/pages/DvirReportPage')).DvirReportPage,
    { permission: PERM.reportsRead },
  ),
  guardedRoute(
    'reports/uncertified-logs',
    async () => (await import('@/features/reports/pages/UncertifiedLogsPage')).UncertifiedLogsPage,
    { permission: PERM.reportsRead },
  ),
  guardedRoute(
    'reports/exports',
    async () => (await import('@/features/reports/pages/ExportJobsPage')).ExportJobsPage,
    { permission: PERM.reportsRead },
  ),
];
