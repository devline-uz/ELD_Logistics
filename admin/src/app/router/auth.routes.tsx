import type { RouteObject } from 'react-router-dom';

import { lazyRoute } from '@/app/router/route-helpers';

/**
 * `AppLayout'dan tashqaridagi marshrutlar (0.11, TZ §7.1).
 *
 * Barchasi public — `RouteGuard` ishlatilmaydi. `TwoFactorSetupPage` /
 * `TwoFactorVerifyPage` cheklangan token bilan kirishni o'zi cheklaydi
 * (limited session'da boshqa API chaqiruvi 401 qaytaradi).
 */
export const authRoutes: RouteObject[] = [
  lazyRoute('/login', async () => (await import('@/features/auth/pages/LoginPage')).LoginPage),
  lazyRoute(
    '/2fa/setup',
    async () => (await import('@/features/auth/pages/TwoFactorSetupPage')).TwoFactorSetupPage,
  ),
  lazyRoute(
    '/2fa/verify',
    async () => (await import('@/features/auth/pages/TwoFactorVerifyPage')).TwoFactorVerifyPage,
  ),
  lazyRoute(
    '/forgot-password',
    async () => (await import('@/features/auth/pages/ForgotPasswordPage')).ForgotPasswordPage,
  ),
  lazyRoute(
    '/reset-password',
    async () => (await import('@/features/auth/pages/ResetPasswordPage')).ResetPasswordPage,
  ),
  lazyRoute(
    '/invitation/accept',
    async () => (await import('@/features/auth/pages/InvitationAcceptPage')).InvitationAcceptPage,
  ),
];
