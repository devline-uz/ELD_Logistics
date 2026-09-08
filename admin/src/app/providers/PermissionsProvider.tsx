import { useMemo, type ReactNode } from 'react';

import { PermissionsContext, type PermissionState } from '@/lib/permissions';
import { selectIsSuperAdmin, selectPermissions, useAuthStore } from '@/store/auth-store';

export interface PermissionsProviderProps {
  /**
   * Ruxsat kalitlari. Berilmasa — auth store'dagi `GET /me` javobidan olinadi
   * (0.15). Prop faqat testda va Storybook'da qiymatni majburlash uchun.
   */
  permissions?: readonly string[];
  /** `super_admin` — alohida bayroq, rol emas (F33). */
  isSuperAdmin?: boolean;
  children: ReactNode;
}

export function PermissionsProvider({
  permissions,
  isSuperAdmin,
  children,
}: PermissionsProviderProps) {
  const storePermissions = useAuthStore(selectPermissions);
  const storeIsSuperAdmin = useAuthStore(selectIsSuperAdmin);

  const effectivePermissions = permissions ?? storePermissions;
  const effectiveIsSuperAdmin = isSuperAdmin ?? storeIsSuperAdmin;

  const value = useMemo<PermissionState>(
    () => ({ permissions: effectivePermissions, isSuperAdmin: effectiveIsSuperAdmin }),
    [effectivePermissions, effectiveIsSuperAdmin],
  );

  return <PermissionsContext.Provider value={value}>{children}</PermissionsContext.Provider>;
}
