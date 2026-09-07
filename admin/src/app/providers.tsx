import type { QueryClient } from '@tanstack/react-query';
import { useEffect, type ReactNode } from 'react';

import '@/app/i18n';
import { BootstrapGate } from '@/app/providers/BootstrapGate';
import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { QueryProvider } from '@/app/providers/QueryProvider';
import { SessionFlagsProvider } from '@/app/providers/SessionFlagsProvider';
import type { SessionFlags } from '@/app/providers/session-flags-context';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { useAuthStore } from '@/store/auth-store';

export interface AppProvidersProps {
  /**
   * Ruxsatlarni majburlash (test/Storybook). Berilmasa — auth store'dagi
   * `GET /me` natijasi ishlatiladi (0.15).
   */
  permissions?: readonly string[];
  isSuperAdmin?: boolean;
  /**
   * Sessiya bayroqlarini majburlash (test/Storybook). Bayroqlarning o'zi
   * auth store'da yashaydi (`session-flags-context.ts`); bu prop faqat
   * qulaylik uchun — store'ga to'g'ridan-to'g'ri yoziladi. Yangi testlar
   * `useAuthStore.setState(...)` ni to'g'ridan-to'g'ri chaqirishi mumkin.
   */
  sessionFlags?: Partial<SessionFlags>;
  /** Bootstrap'ni o'tkazib yuborish (test). */
  skipBootstrap?: boolean;
  /** Testda o'z Query klientini berish. */
  queryClient?: QueryClient;
  children: ReactNode;
}

/**
 * Provayderlar tartibi (0.12–0.15):
 *
 * `QueryProvider` → `ToastProvider` → `BootstrapGate` → `PermissionsProvider`
 * → `SessionFlagsProvider`.
 *
 * `BootstrapGate` ruxsat provayderidan **yuqorida** turadi: `GET /me` javobi
 * kelmaguncha hech qanday ekran (va ruxsat tekshiruvi) render qilinmaydi,
 * aks holda ruxsatlar bo'sh bo'lgan bir lahzada 403 ekrani chaqnab ketardi.
 */
export function AppProviders({
  permissions,
  isSuperAdmin,
  sessionFlags,
  skipBootstrap,
  queryClient,
  children,
}: AppProvidersProps) {
  // Faqat test/Storybook qulayligi — sessiya bayroqlarining haqiqiy manbai
  // auth store, shuning uchun bu yerda Context emas, to'g'ridan-to'g'ri
  // `setState` chaqiriladi.
  useEffect(() => {
    if (sessionFlags) useAuthStore.setState(sessionFlags);
    // eslint-disable-next-line react-hooks/exhaustive-deps -- faqat mount'da bir marta sozlash yetarli
  }, []);

  return (
    <QueryProvider client={queryClient}>
      <ToastProvider>
        <BootstrapGate skip={skipBootstrap}>
          <PermissionsProvider isSuperAdmin={isSuperAdmin} permissions={permissions}>
            <SessionFlagsProvider>{children}</SessionFlagsProvider>
          </PermissionsProvider>
        </BootstrapGate>
      </ToastProvider>
    </QueryProvider>
  );
}

export default AppProviders;
