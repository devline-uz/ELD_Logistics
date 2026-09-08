import type { ReactNode } from 'react';

import { useNotificationsRealtime } from '../hooks/useNotificationsRealtime';

export interface NotificationsRealtimeProviderProps {
  children: ReactNode;
}

/**
 * Ildiz darajasidagi kichik provayder — `notifications` WS kanaliga bir
 * marta obuna bo'ladi (F156). `app/providers.tsx` ichida mount qilinadi,
 * har ekranda emas.
 */
export function NotificationsRealtimeProvider({ children }: NotificationsRealtimeProviderProps) {
  useNotificationsRealtime();
  return <>{children}</>;
}

export default NotificationsRealtimeProvider;
