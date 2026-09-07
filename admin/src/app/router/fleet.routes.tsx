import type { RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

const load = () => import('@/features/fleet/pages/stubs');

export const fleetRoutes: RouteObject[] = [
  guardedRoute('units', async () => (await load()).UnitListPage, { permission: PERM.unitsRead }),
  guardedRoute('units/:unitId', async () => (await load()).UnitDetailPage, {
    permission: PERM.unitsRead,
  }),
  guardedRoute('drivers', async () => (await load()).DriverListPage, {
    permission: PERM.driversRead,
  }),
  guardedRoute('drivers/:driverId', async () => (await load()).DriverDetailPage, {
    permission: PERM.driversRead,
  }),
  guardedRoute('eld-devices', async () => (await load()).EldDeviceListPage, {
    permission: PERM.eldDevicesRead,
  }),
  guardedRoute('trailers', async () => (await load()).TrailerListPage, {
    permission: PERM.trailersRead,
  }),
  guardedRoute('shipping-documents', async () => (await load()).ShippingDocumentListPage, {
    permission: PERM.shippingDocumentsRead,
  }),
  guardedRoute('users', async () => (await load()).UserListPage, { permission: PERM.usersRead }),
  guardedRoute('roles', async () => (await load()).RoleListPage, { permission: PERM.rolesRead }),
];
