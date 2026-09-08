import { Navigate, type RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

/** Schedule / Due / History — bitta marshrut ichida tab (Bosqich 5). */
export const maintenanceRoutes: RouteObject[] = [
  { path: 'maintenance', element: <Navigate to="/maintenance/schedules" replace /> },
  guardedRoute(
    'maintenance/schedules',
    async () =>
      (await import('@/features/maintenance/pages/MaintenanceSchedulesPage'))
        .MaintenanceSchedulesPage,
    { permission: PERM.maintenanceRead },
  ),
  guardedRoute(
    'maintenance/due',
    async () =>
      (await import('@/features/maintenance/pages/MaintenanceDuePage')).MaintenanceDuePage,
    { permission: PERM.maintenanceRead },
  ),
  guardedRoute(
    'maintenance/history',
    async () =>
      (await import('@/features/maintenance/pages/MaintenanceHistoryPage')).MaintenanceHistoryPage,
    { permission: PERM.maintenanceRead },
  ),
  guardedRoute(
    'maintenance/schedules/:id',
    async () =>
      (await import('@/features/maintenance/pages/MaintenanceScheduleViewPage'))
        .MaintenanceScheduleViewPage,
    { permission: PERM.maintenanceRead },
  ),
  guardedRoute(
    'maintenance/schedules/:id/units',
    async () =>
      (await import('@/features/maintenance/pages/MaintenanceScheduleUnitsPage'))
        .MaintenanceScheduleUnitsPage,
    { permission: PERM.maintenanceRead },
  ),
  guardedRoute(
    'maintenance/history/:id',
    async () =>
      (await import('@/features/maintenance/pages/MaintenanceRecordViewPage'))
        .MaintenanceRecordViewPage,
    { permission: PERM.maintenanceRead },
  ),
  guardedRoute(
    'dvir',
    async () => (await import('@/features/dvir/pages/DvirListPage')).DvirListPage,
    { permission: PERM.dvirRead },
  ),
  guardedRoute(
    'dvir/:dvirId',
    async () => (await import('@/features/dvir/pages/DvirDetailPage')).DvirDetailPage,
    { permission: PERM.dvirRead },
  ),
  guardedRoute(
    'settings/defect-types',
    async () => (await import('@/features/dvir/pages/DefectTypesPage')).DefectTypesPage,
    { permission: PERM.defectTypesRead },
  ),
];
