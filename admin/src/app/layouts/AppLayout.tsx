import { Suspense, useCallback } from 'react';
import { useTranslation } from 'react-i18next';
import { Outlet, useNavigate } from 'react-router-dom';

import { clearSession } from '@/api/session';
import { LiveUpdatesBanner } from '@/components/feedback/LiveUpdatesBanner';
import { BrandBar } from '@/components/layout/BrandBar';
import { Breadcrumbs } from '@/components/layout/Breadcrumbs';
import { IdleTimeoutDialog } from '@/components/layout/IdleTimeoutDialog';
import { MainNav } from '@/components/layout/MainNav';
import { SubscriptionBanner } from '@/components/layout/SubscriptionBanner';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { NotificationsDropdown } from '@/features/notifications/components/NotificationsDropdown';
import { ImpersonationBanner } from '@/features/superadmin/components/ImpersonationBanner';
import { PERM } from '@/lib/permissions';

/**
 * Uch qatlamli sarlavha (fe-permissions §6):
 * 1 — brend panel · 2 — navigatsiya · 3 — breadcrumb.
 *
 * `subscription_readonly` banneri navigatsiya ostida, kontent ustida turadi.
 */
export function AppLayout() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const signOut = useCallback(
    (reason: 'user' | 'idle_timeout') => {
      // Server sessiyasini yopish (`POST /auth/logout`) 0.12 da qo'shiladi;
      // lokal tozalash har holatda bajariladi.
      // `clearSession()` xotira + `sessionStorage` (`eld.rt`) ni o'zi tozalaydi.
      clearSession();
      void navigate(`/login?reason=${reason}`, { replace: true });
    },
    [navigate],
  );

  return (
    <div className="min-h-screen">
      <a className="sr-only focus:not-sr-only" href="#main-content">
        {t('nav.brand.skipToContent')}
      </a>

      <header>
        <BrandBar
          onSignOut={() => {
            signOut('user');
          }}
          notificationsSlot={
            <PermissionGate permission={PERM.notificationsRead}>
              <NotificationsDropdown />
            </PermissionGate>
          }
        />
        <MainNav />
        <ImpersonationBanner />
        <SubscriptionBanner />
        <LiveUpdatesBanner />
        <Breadcrumbs />
      </header>

      <main id="main-content" className="px-6 py-6">
        <Suspense
          fallback={<p className="text-sm text-neutral-500">{t('common.states.loading')}</p>}
        >
          <Outlet />
        </Suspense>
      </main>

      <IdleTimeoutDialog
        onTimeout={() => {
          signOut('idle_timeout');
        }}
      />
    </div>
  );
}

export default AppLayout;
