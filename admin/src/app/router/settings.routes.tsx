import { Navigate, type RouteObject } from 'react-router-dom';

import { guardedRoute, lazyRoute } from '@/app/router/route-helpers';
import { PERM } from '@/lib/permissions';

/**
 * Settings nav'da emas — profil menyusi orqali ochiladi.
 * Profil va Security — shaxsiy, ruxsat kaliti talab qilmaydi (fe-permissions §8).
 *
 * Har tab o'z sahifa fayliga ega (bosqich 8 — parallel agentlar):
 * Company/Branches/Company history (bu fayl egasi), HOS Policy, Notification
 * settings, Profile, Security.
 */
export const settingsRoutes: RouteObject[] = [
  { path: 'settings', element: <Navigate to="/settings/profile" replace /> },
  lazyRoute(
    'settings/profile',
    async () => (await import('@/features/settings/pages/ProfileSettingsPage')).ProfileSettingsPage,
  ),
  lazyRoute(
    'settings/security',
    async () =>
      (await import('@/features/settings/pages/SecuritySettingsPage')).SecuritySettingsPage,
  ),
  guardedRoute(
    'settings/company',
    async () => (await import('@/features/settings/pages/CompanySettingsPage')).CompanySettingsPage,
    { permission: PERM.companyRead },
  ),
  guardedRoute(
    'settings/branches',
    async () => (await import('@/features/settings/pages/BranchesPage')).BranchesPage,
    { permission: PERM.branchesRead },
  ),
  guardedRoute(
    'settings/history',
    async () => (await import('@/features/settings/pages/CompanyHistoryPage')).CompanyHistoryPage,
    { permission: PERM.companyHistoryView },
  ),
  guardedRoute(
    'settings/hos',
    async () => (await import('@/features/settings/pages/HosPolicyPage')).HosPolicyPage,
    { permission: PERM.hosPolicyRead },
  ),
  guardedRoute(
    'settings/notifications',
    async () =>
      (await import('@/features/settings/pages/NotificationSettingsPage')).NotificationSettingsPage,
    { permission: PERM.notificationSettingsRead },
  ),
];
