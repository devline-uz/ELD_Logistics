import type { ReactNode } from 'react';

import { usePermission, type Permission } from '@/lib/permissions';

export interface PermissionGateProps {
  /** Bitta majburiy kalit. */
  permission?: Permission;
  /** Kamida bittasi yetarli. */
  anyOf?: readonly Permission[];
  /** Hammasi talab qilinadi. */
  allOf?: readonly Permission[];
  /** Ruxsat yo'q bo'lganda ko'rsatiladigan muqobil (default — hech narsa). */
  fallback?: ReactNode;
  children: ReactNode;
}

/**
 * Ruxsat yo'q bo'lsa bola element **DOM'da umuman bo'lmaydi** (fe-permissions §3).
 * Bu UI qulayligi, xavfsizlik emas — har amal backendda qayta tekshiriladi.
 */
export function PermissionGate({
  permission,
  anyOf,
  allOf,
  fallback = null,
  children,
}: PermissionGateProps) {
  const can = usePermission();

  const allowed =
    (permission === undefined || can(permission)) &&
    (anyOf === undefined || can.any(anyOf)) &&
    (allOf === undefined || can.all(allOf));

  return <>{allowed ? children : fallback}</>;
}

export default PermissionGate;
