import type { ReactNode } from 'react';

import '@/app/i18n';
import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { SessionFlagsProvider } from '@/app/providers/SessionFlagsProvider';
import type { SessionFlags } from '@/app/providers/session-flags-context';
import { ToastProvider } from '@/components/feedback/ToastProvider';

export interface AppProvidersProps {
  /**
   * `GET /me` ruxsatlari. Auth store (0.12/0.15) ulangach shu yerga store'dan
   * uzatiladi; hozircha bo'sh ro'yxat (test provider'ga to'g'ridan-to'g'ri beradi).
   */
  permissions?: readonly string[];
  isSuperAdmin?: boolean;
  sessionFlags?: Partial<SessionFlags>;
  children: ReactNode;
}

/** TanStack Query provayderi 0.12 (auth oqimi) bilan birga qo'shiladi. */
export function AppProviders({
  permissions,
  isSuperAdmin,
  sessionFlags,
  children,
}: AppProvidersProps) {
  return (
    <ToastProvider>
      <PermissionsProvider permissions={permissions} isSuperAdmin={isSuperAdmin}>
        <SessionFlagsProvider initial={sessionFlags}>{children}</SessionFlagsProvider>
      </PermissionsProvider>
    </ToastProvider>
  );
}

export default AppProviders;
