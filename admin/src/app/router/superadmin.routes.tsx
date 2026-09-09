import type { RouteObject } from 'react-router-dom';

import { guardedRoute } from '@/app/router/route-helpers';

/**
 * `/companies` — Super Admin konsoli (9.15, §7.14, `[MAY]`).
 *
 * `super_admin` — rol emas, alohida bayroq (F33), `PERM` katalogida yo'q.
 * `RouteGuard` `can.isSuperAdmin`ni tekshiradi — oddiy foydalanuvchi
 * to'g'ridan-to'g'ri URL kiritsa 403 ko'radi (403, redirect ham 404 ham emas).
 */
export const superadminRoutes: RouteObject[] = [
  guardedRoute(
    'companies',
    async () => (await import('@/features/superadmin/pages/CompaniesPage')).CompaniesPage,
    { superAdminOnly: true },
  ),
];
