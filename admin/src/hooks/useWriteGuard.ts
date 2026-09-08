import { useCallback, useMemo } from 'react';
import { useTranslation } from 'react-i18next';

import { useSessionFlags } from '@/app/providers/session-flags-context';
import { usePermission, type Permission } from '@/lib/permissions';

export interface WriteGuard {
  /** Yozuv amali bajarilishi mumkinmi (ruxsat + obuna holati). */
  canWrite: (permission: Permission) => boolean;
  /**
   * `disabled` tugma uchun sabab matni (F35 — hech qanday tugma sababsiz
   * o'chirilmaydi). Amal ochiq bo'lsa `undefined`.
   */
  disabledReason: (permission: Permission) => string | undefined;
}

/** Yozuv amallarining yagona darvozasi: ruxsat kaliti + `subscription_readonly`. */
export function useWriteGuard(): WriteGuard {
  const can = usePermission();
  const { subscriptionReadonly } = useSessionFlags();
  const { t } = useTranslation();

  const canWrite = useCallback(
    (permission: Permission) => !subscriptionReadonly && can(permission),
    [can, subscriptionReadonly],
  );

  const disabledReason = useCallback(
    (permission: Permission) => {
      if (subscriptionReadonly) {
        return t('writeGuard.subscriptionReadonly');
      }
      if (!can(permission)) {
        return t('writeGuard.missingPermission', { permission });
      }
      return undefined;
    },
    [can, subscriptionReadonly, t],
  );

  return useMemo(() => ({ canWrite, disabledReason }), [canWrite, disabledReason]);
}
