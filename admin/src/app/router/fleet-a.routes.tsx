/**
 * Fleet marshrutlari — A guruhi bo'lagi (units, eld-devices, trailers,
 * shipping-documents; 2.2/2.3/2.6/2.7, `docs/tz/07-3-fleet.md`).
 *
 * Drivers/Users/Roles — B guruhi (`fleet-b.routes.tsx`, alohida fayl).
 * Asosiy sessiya bu ikkalasini `fleet.routes.tsx` ichida birlashtiradi (W2).
 */
import type { RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

const loadUnits = () => import('@/features/fleet/units/pages/UnitListPage');
const loadUnitDetail = () => import('@/features/fleet/units/pages/UnitDetailPage');
const loadEldDevices = () => import('@/features/fleet/eld/pages/EldDeviceListPage');
const loadTrailers = () => import('@/features/fleet/trailers/pages/TrailerListPage');
const loadShippingDocuments = () =>
  import('@/features/fleet/documents/pages/ShippingDocumentListPage');

export const fleetARoutes: RouteObject[] = [
  guardedRoute('units', async () => (await loadUnits()).UnitListPage, {
    permission: PERM.unitsRead,
  }),
  guardedRoute('units/:unitId', async () => (await loadUnitDetail()).default, {
    permission: PERM.unitsRead,
  }),
  guardedRoute(
    'units/:unitId/activities',
    async () => (await loadUnitDetail()).UnitActivitiesPage,
    {
      permission: PERM.unitsRead,
    },
  ),
  guardedRoute(
    'units/:unitId/diagnostics',
    async () => (await loadUnitDetail()).UnitDiagnosticsPage,
    { permission: PERM.unitsDiagnostics },
  ),
  guardedRoute('eld-devices', async () => (await loadEldDevices()).EldDeviceListPage, {
    permission: PERM.eldDevicesRead,
  }),
  guardedRoute('trailers', async () => (await loadTrailers()).TrailerListPage, {
    permission: PERM.trailersRead,
  }),
  guardedRoute(
    'shipping-documents',
    async () => (await loadShippingDocuments()).ShippingDocumentListPage,
    { permission: PERM.shippingDocumentsRead },
  ),
];

export default fleetARoutes;
