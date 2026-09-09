/**
 * "Viewing as <Company>" banner — F152 (§7.14). Super Admin tenant
 * tanlaganda doim ko'rinadi (chiqish yo'li bilan). `SubscriptionBanner`/
 * `LiveUpdatesBanner` bilan bir xil o'z-o'zini boshqaruvchi naqsh — hech
 * narsa tanlanmaganda `null` qaytaradi.
 */
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import { Button } from '@/components/ui/Button';
import { useAuthStore } from '@/store/auth-store';

import { exitCompany, useImpersonationStore } from '../lib/impersonation';

export function ImpersonationBanner() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const companyId = useAuthStore((state) => state.impersonatedCompanyId);
  const companyName = useImpersonationStore((state) => state.companyName);

  if (!companyId) return null;

  return (
    <div
      role="status"
      className="flex items-center justify-between gap-3 border-b border-[var(--color-warning-base)] bg-[var(--color-warning-bg)] px-6 py-2 text-sm text-[var(--color-warning-dark)]"
    >
      <span>
        {t('superadmin.impersonation.banner', {
          company: companyName ?? t('common.na'),
        })}
      </span>
      <Button
        variant="secondary"
        size="sm"
        onClick={() => {
          exitCompany();
          void navigate('/companies');
        }}
      >
        {t('superadmin.impersonation.exit')}
      </Button>
    </div>
  );
}

export default ImpersonationBanner;
