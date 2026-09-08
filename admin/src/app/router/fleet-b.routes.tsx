/**
 * Fleet — B guruhi marshrutlari: Driver / User / Role (2.4/2.5/2.8/2.9).
 *
 * Bu fayl `fleet.routes.tsx` (asosiy sessiya birlashtiradigan umumiy fayl)
 * bilan **birlashtiriladi** — bu agent `fleet.routes.tsx`ga tegmaydi (W2).
 *
 * `/roles` ro'yxatini ochish uchun OR istisnosi (fe-permissions §1.2):
 * `GET /permissions` `permissions.read` **yoki** `roles.read` bilan ochiladi.
 */
import type { RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

const loadDriverList = () =>
  import('@/features/fleet/drivers/pages/DriverListPage').then((m) => m.DriverListPage);
const loadDriverDetail = () =>
  import('@/features/fleet/drivers/pages/DriverDetailPage').then((m) => m.DriverDetailPage);
const loadDriverActivities = () =>
  import('@/features/fleet/drivers/pages/DriverDetailPage').then((m) => m.DriverActivitiesPage);
const loadDriverDailyLogs = () =>
  import('@/features/fleet/drivers/pages/DriverDetailPage').then((m) => m.DriverDailyLogsPage);
const loadUserList = () =>
  import('@/features/fleet/users/pages/UserListPage').then((m) => m.UserListPage);
const loadRoleList = () =>
  import('@/features/fleet/roles/pages/RoleListPage').then((m) => m.RoleListPage);

export const fleetBRoutes: RouteObject[] = [
  guardedRoute('drivers', loadDriverList, { permission: PERM.driversRead }),
  guardedRoute('drivers/:driverId', loadDriverDetail, { permission: PERM.driversRead }),
  guardedRoute('drivers/:driverId/activities', loadDriverActivities, {
    permission: PERM.driversRead,
  }),
  guardedRoute('drivers/:driverId/logs', loadDriverDailyLogs, {
    permission: PERM.driversRead,
  }),
  guardedRoute('users', loadUserList, { permission: PERM.usersRead }),
  guardedRoute('roles', loadRoleList, {
    anyOf: [PERM.permissionsRead, PERM.rolesRead],
  }),
];
