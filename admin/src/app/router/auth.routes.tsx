import type { RouteObject } from 'react-router-dom';

import { lazyRoute } from '@/app/router/route-helpers';

/** AppLayout'dan tashqaridagi marshrutlar. Haqiqiy ekranlar — 0.11–0.15. */
export const authRoutes: RouteObject[] = [
  lazyRoute('/login', async () => (await import('@/features/auth/pages/stubs')).LoginPage),
];
