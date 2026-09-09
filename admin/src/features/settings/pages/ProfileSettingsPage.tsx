import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';

import { useMyProfile } from '@/api/queries/profile';
import { Alert } from '@/components/feedback/Alert';
import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { Avatar } from '@/components/ui/Avatar';
import { Badge, type BadgeTone } from '@/components/ui/Badge';
import { Card } from '@/components/ui/Card';
import type { Profile } from '@/api/types';
import { isApiError } from '@/lib/errors';
import { formatPersonName } from '@/lib/format';

function ProfileField({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div>
      <dt className="text-body-sm font-medium text-neutral-600">{label}</dt>
      <dd className="mt-0.5 text-body text-neutral-900">{value}</dd>
    </div>
  );
}

const STATUS_TONE: Record<NonNullable<Profile['status']>, BadgeTone> = {
  active: 'success',
  invited: 'warning',
  inactive: 'neutral',
};

/**
 * `/settings/profile` — 7.13.6. `authenticated` — shaxsiy ekran, permission
 * kaliti talab qilmaydi (fe-permissions §8).
 *
 * **D40 (backend bo'shlig'i):** swagger'da profilni yangilaydigan endpoint
 * (`PATCH /me` yoki shunga o'xshash) yo'q — ekran shuning uchun faqat
 * o'qiladi, tahrirlash imkoni yo'q (`docs/tz/16-17-registry-open-questions.md`).
 */
export function ProfileSettingsPage() {
  const { t } = useTranslation();
  const { data: profile, isPending, isError, error, refetch } = useMyProfile();

  const fullName = formatPersonName(profile, '');
  const avatarName = fullName || profile?.username || '';
  const status = profile?.status ?? 'active';

  return (
    <div className="flex max-w-2xl flex-col gap-6">
      <div>
        <h1 className="text-h3 font-bold text-neutral-900">{t('settings.profile.title')}</h1>
        <p className="mt-1 text-body text-neutral-600">{t('settings.profile.subtitle')}</p>
      </div>

      <Card>
        {isPending ? (
          <Skeleton count={6} variant="text" />
        ) : isError ? (
          <ErrorState
            message={isApiError(error) ? error.message : t('settings.profile.loadError')}
            onRetry={() => {
              void refetch();
            }}
          />
        ) : !profile ? (
          <EmptyState description={t('settings.profile.empty')} />
        ) : (
          <div className="flex flex-col gap-6">
            <div className="flex items-center gap-4">
              <Avatar name={avatarName} size="lg" />
              <div>
                <p className="text-body-lg font-semibold text-neutral-900">
                  {fullName || profile.username}
                </p>
                {profile.role_name ? (
                  <p className="text-body-sm text-neutral-600">{profile.role_name}</p>
                ) : null}
              </div>
            </div>

            <dl className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <ProfileField
                label={t('settings.profile.fields.firstName')}
                value={profile.first_name || t('common.na')}
              />
              <ProfileField
                label={t('settings.profile.fields.lastName')}
                value={profile.last_name || t('common.na')}
              />
              <ProfileField
                label={t('settings.profile.fields.email')}
                value={profile.email || t('common.na')}
              />
              <ProfileField
                label={t('settings.profile.fields.username')}
                value={profile.username || t('common.na')}
              />
              <ProfileField
                label={t('settings.profile.fields.role')}
                value={profile.role_name || t('common.na')}
              />
              <ProfileField
                label={t('settings.profile.fields.status')}
                value={
                  <Badge tone={STATUS_TONE[status]}>{t(`settings.profile.status.${status}`)}</Badge>
                }
              />
              <ProfileField
                label={t('settings.profile.fields.twoFactor')}
                value={
                  <Badge tone={profile.totp_enabled ? 'success' : 'neutral'}>
                    {profile.totp_enabled
                      ? t('settings.profile.twoFactorEnabled')
                      : t('settings.profile.twoFactorDisabled')}
                  </Badge>
                }
              />
            </dl>

            <Alert message={t('settings.profile.readOnlyNotice')} variant="info" />
          </div>
        )}
      </Card>
    </div>
  );
}

export default ProfileSettingsPage;
