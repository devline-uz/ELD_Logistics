import { useTranslation } from 'react-i18next';

import { useSessionFlags } from '@/app/providers/session-flags-context';

/**
 * `subscription_readonly` — yuqorida **doimiy** banner; barcha yozuv amallari
 * `useWriteGuard()` orqali `disabled` bo'ladi va sababi tooltip'da ko'rsatiladi (F35).
 */
export function SubscriptionBanner() {
  const { t } = useTranslation();
  const { subscriptionReadonly } = useSessionFlags();

  if (!subscriptionReadonly) {
    return null;
  }

  return (
    <div
      role="status"
      className="flex items-center gap-2 bg-[var(--color-warning-bg)] px-6 py-2 text-sm text-[var(--color-warning-dark)]"
    >
      <strong className="font-semibold">{t('banner.subscriptionReadonly.title')}</strong>
      <span>{t('banner.subscriptionReadonly.description')}</span>
    </div>
  );
}

export default SubscriptionBanner;
