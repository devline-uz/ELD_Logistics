import { useTranslation } from 'react-i18next';

import { useMyProfile } from '@/api/queries/profile';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { PasswordChangeCard } from '@/features/settings/profile/PasswordChangeCard';
import { SessionsCard } from '@/features/settings/profile/SessionsCard';
import { TwoFactorCard } from '@/features/settings/profile/TwoFactorCard';
import { isApiError } from '@/lib/errors';

/**
 * `/settings/security` — 7.13.7. `authenticated` — shaxsiy ekran, permission
 * kaliti talab qilmaydi (fe-permissions §8).
 *
 * Profil (`useMyProfile`) faqat `username` (parol email oqimi uchun) va
 * `totp_enabled` holatini olish uchun so'raladi — asosiy ma'lumot Profile
 * ekranida.
 */
export function SecuritySettingsPage() {
  const { t } = useTranslation();
  const { data: profile, isPending, isError, error, refetch } = useMyProfile();

  return (
    <div className="flex max-w-2xl flex-col gap-6">
      <div>
        <h1 className="text-h3 font-bold text-neutral-900">{t('settings.security.title')}</h1>
        <p className="mt-1 text-body text-neutral-500">{t('settings.security.subtitle')}</p>
      </div>

      {isPending ? (
        <Skeleton count={6} variant="card" />
      ) : isError ? (
        <ErrorState
          message={isApiError(error) ? error.message : t('settings.profile.loadError')}
          onRetry={() => {
            void refetch();
          }}
        />
      ) : (
        <>
          <PasswordChangeCard username={profile?.username ?? ''} />
          <TwoFactorCard enabled={profile?.totp_enabled ?? false} />
          <SessionsCard />
        </>
      )}
    </div>
  );
}

export default SecuritySettingsPage;
