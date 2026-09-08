/**
 * **F108** — kritik nuqsonli DVIR unit'ni `out_of_service` qiladi; ro'yxatda
 * va detal ekranida qizil banner ko'rsatiladi (Q27.2).
 */
import { useTranslation } from 'react-i18next';
import { AlertTriangle } from 'lucide-react';

import { Icon } from '@/components/ui/Icon';

export function OutOfServiceBanner() {
  const { t } = useTranslation();
  return (
    <div
      role="alert"
      className="flex items-start gap-3 rounded-lg border border-error-base bg-error-bg p-4 text-error-dark"
    >
      <Icon icon={AlertTriangle} className="mt-0.5 shrink-0" />
      <div>
        <p className="text-body font-semibold">{t('dvir.outOfService.title')}</p>
        <p className="text-body-sm">{t('dvir.outOfService.description')}</p>
      </div>
    </div>
  );
}
