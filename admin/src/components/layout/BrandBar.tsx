import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';

import { ProfileMenu } from '@/components/layout/ProfileMenu';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { NotificationsDropdown } from '@/features/notifications/components/NotificationsDropdown';
import { PERM } from '@/lib/permissions';

export interface BrandBarProps {
  onSignOut?: () => void;
}

/** QATLAM 1 — brend panel (`--color-primary`): logotip · global qidiruv · qo'ng'iroq · profil. */
export function BrandBar({ onSignOut }: BrandBarProps) {
  const { t } = useTranslation();

  return (
    <div className="flex h-14 items-center gap-4 bg-[var(--color-primary)] px-6 text-white">
      <Link to="/" className="text-sm font-semibold tracking-wide">
        {t('app.name')}
      </Link>

      <search className="ml-auto w-72">
        <label className="sr-only" htmlFor="global-search">
          {t('nav.brand.searchPlaceholder')}
        </label>
        {/* Bosqich 2: `GET /drivers?search=` + `GET /units?search=` kompozitsiyasi */}
        <input
          id="global-search"
          type="search"
          disabled
          placeholder={t('nav.brand.searchPlaceholder')}
          className="w-full rounded border border-white/30 bg-white/10 px-3 py-1.5 text-sm text-white placeholder:text-white/70"
        />
      </search>

      <PermissionGate permission={PERM.notificationsRead}>
        <NotificationsDropdown />
      </PermissionGate>

      <ProfileMenu onSignOut={onSignOut} />
    </div>
  );
}

export default BrandBar;
