import { Navigate, type RouteObject } from 'react-router-dom';

import { guardedRoute, lazyRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

const load = () => import('@/features/settings/pages/stubs');

/**
 * Settings nav'da emas — profil menyusi orqali ochiladi.
 * Profil va Security — shaxsiy, ruxsat kaliti talab qilmaydi (fe-permissions §8).
 */
export const settingsRoutes: RouteObject[] = [
  { path: 'settings', element: <Navigate to="/settings/profile" replace /> },
  lazyRoute('settings/profile', async () => (await load()).ProfileSettingsPage),
  lazyRoute('settings/security', async () => (await load()).SecuritySettingsPage),
  guardedRoute('settings/company', async () => (await load()).CompanySettingsPage, {
    permission: PERM.companyRead,
  }),
  guardedRoute('settings/hos', async () => (await load()).HosPolicySettingsPage, {
    permission: PERM.hosPolicyRead,
  }),
];
