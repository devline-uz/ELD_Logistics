/* eslint-disable react-refresh/only-export-components -- marshrutlar reestri, komponent moduli emas */
import { createBrowserRouter, type RouteObject } from 'react-router-dom';

import { AppLayout } from '@/app/layouts/AppLayout';
import { authRoutes } from '@/app/router/auth.routes';
import { chatRoutes } from '@/app/router/chat.routes';
import { dashboardRoutes } from '@/app/router/dashboard.routes';
import { fleetRoutes } from '@/app/router/fleet.routes';
import { logsRoutes } from '@/app/router/logs.routes';
import { maintenanceRoutes } from '@/app/router/maintenance.routes';
import { notificationsRoutes } from '@/app/router/notifications.routes';
import { reportsRoutes } from '@/app/router/reports.routes';
import { settingsRoutes } from '@/app/router/settings.routes';
import { supportRoutes } from '@/app/router/support.routes';
import { trackingRoutes } from '@/app/router/tracking.routes';
import { NotFoundScreen } from '@/components/feedback/NotFoundScreen';
import { RouteErrorBoundary } from '@/components/feedback/RouteErrorBoundary';

/**
 * Marshrutlar daraxti (0.20).
 *
 * Modul bo'yicha alohida fayllar (`router/<modul>.routes.tsx`) — keyingi
 * bosqichlarda parallel agentlar faqat o'z faylini tahrirlaydi (W2/W11).
 * Barcha ekran komponentlari `lazy` — birorta ham sahifa asosiy bundle'da emas.
 */
export const routes: RouteObject[] = [
  ...authRoutes,
  {
    path: '/',
    element: <AppLayout />,
    errorElement: <RouteErrorBoundary />,
    children: [
      ...dashboardRoutes,
      ...trackingRoutes,
      ...logsRoutes,
      ...fleetRoutes,
      ...maintenanceRoutes,
      ...reportsRoutes,
      ...supportRoutes,
      ...chatRoutes,
      ...notificationsRoutes,
      ...settingsRoutes,
      // Mavjud bo'lmagan manzil — 404 (403 dan qat'iy farqlanadi).
      { path: '*', element: <NotFoundScreen /> },
    ],
  },
];

/** v7 ogohlantirishlarini o'chirish uchun future bayroqlari (konsol toza bo'lishi shart). */
export const ROUTER_FUTURE = {
  v7_startTransition: true,
  v7_relativeSplatPath: true,
  v7_fetcherPersist: true,
  v7_normalizeFormMethod: true,
  v7_partialHydration: true,
  v7_skipActionErrorRevalidation: true,
} as const;

export function createAppRouter() {
  return createBrowserRouter(routes, { future: ROUTER_FUTURE });
}
