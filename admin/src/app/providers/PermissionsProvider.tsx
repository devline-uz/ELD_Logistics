import { useMemo, type ReactNode } from 'react';

import { PermissionsContext, type PermissionState } from '@/lib/permissions';

export interface PermissionsProviderProps {
  /**
   * `GET /me` javobidagi ruxsat kalitlari. Auth store (0.15) ulangach shu prop
   * store'dan to'ldiriladi; testda to'g'ridan-to'g'ri ro'yxat beriladi.
   */
  permissions?: readonly string[];
  /** `super_admin` — alohida bayroq, rol emas (F33). */
  isSuperAdmin?: boolean;
  children: ReactNode;
}

export function PermissionsProvider({
  permissions = [],
  isSuperAdmin = false,
  children,
}: PermissionsProviderProps) {
  const value = useMemo<PermissionState>(
    () => ({ permissions, isSuperAdmin }),
    [permissions, isSuperAdmin],
  );

  return <PermissionsContext.Provider value={value}>{children}</PermissionsContext.Provider>;
}
