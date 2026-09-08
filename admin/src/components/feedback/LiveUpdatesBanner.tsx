import { useTranslation } from 'react-i18next';

import { reconnectNow } from '@/lib/ws';
import { useConnectionStore } from '@/stores/connection';

/**
 * «Live updates paused» banneri (`fe-realtime` F158, TZ 7.5).
 *
 * Faqat `paused` holatida ko'rsatiladi — qayta ulanish faol davom etmoqda.
 * `connecting` (birinchi urinish) va `offline` (hali obuna yo'q yoki sessiya
 * tugagan) holatlarida jimgina yashiriladi, aks holda login/logout oqimida
 * keraksiz miltillash bo'lardi.
 */
export function LiveUpdatesBanner() {
  const { t } = useTranslation();
  const status = useConnectionStore((state) => state.status);
  const reconnectAttempt = useConnectionStore((state) => state.reconnectAttempt);

  if (status !== 'paused') return null;

  return (
    <div
      role="status"
      className="flex items-center gap-3 bg-[var(--color-warning-bg)] px-6 py-2 text-sm text-[var(--color-warning-dark)]"
    >
      <strong className="font-semibold">{t('realtime.banner.title')}</strong>
      <span>{t('realtime.banner.description')}</span>
      {reconnectAttempt > 0 && (
        <span className="text-xs opacity-80">
          {t('realtime.banner.attempt', { count: reconnectAttempt })}
        </span>
      )}
      <button
        type="button"
        onClick={() => reconnectNow()}
        className="ml-auto rounded border border-current px-2 py-0.5 text-xs font-medium hover:bg-black/5"
        aria-label={t('realtime.banner.retryNow')}
      >
        {t('realtime.banner.retryNow')}
      </button>
    </div>
  );
}

export default LiveUpdatesBanner;
