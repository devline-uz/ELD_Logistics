import type { ReactNode } from 'react';

import { ForbiddenScreen } from '@/components/feedback/ForbiddenScreen';
import { usePermission, type Permission } from '@/lib/permissions';

export interface RouteGuardProps {
  /** Bitta majburiy kalit. */
  permission?: Permission;
  /** Kamida bittasi yetarli. */
  anyOf?: readonly Permission[];
  /** Hammasi talab qilinadi. */
  allOf?: readonly Permission[];
  children: ReactNode;
}

/**
 * Marshrut darajasidagi ruxsat darvozasi (fe-permissions §7).
 *
 * **MUST:** nav'da element yashirilgan bo'lsa ham, to'g'ridan-to'g'ri URL
 * kiritilganda **403 ekrani** ko'rsatiladi — redirect ham, 404 ham emas.
 * 404 faqat ma'lumot darajasida (backend `NOT_FOUND`) chiqadi.
 */
export function RouteGuard({ permission, anyOf, allOf, children }: RouteGuardProps) {
  const can = usePermission();

  if (permission !== undefined && !can(permission)) {
    return <ForbiddenScreen requiredPermission={permission} />;
  }
  if (anyOf !== undefined && !can.any(anyOf)) {
    return <ForbiddenScreen requiredPermission={anyOf.join(' | ')} />;
  }
  if (allOf !== undefined && !can.all(allOf)) {
    return <ForbiddenScreen requiredPermission={allOf.join(' + ')} />;
  }

  return <>{children}</>;
}

export default RouteGuard;
