import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';

import { ProfileMenu } from '@/components/layout/ProfileMenu';

export interface BrandBarProps {
  /** O'qilmagan bildirishnomalar soni (Bosqich 7 da WS bilan to'ldiriladi). */
  unreadCount?: number;
  onSignOut?: () => void;
}

/** QATLAM 1 — brend panel (`--color-primary`): logotip · global qidiruv · qo'ng'iroq · profil. */
export function BrandBar({ unreadCount = 0, onSignOut }: BrandBarProps) {
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

      <button
        type="button"
        className="relative rounded p-1"
        aria-label={
          unreadCount > 0
            ? t('nav.brand.notificationsUnread', { count: unreadCount })
            : t('nav.brand.notifications')
        }
      >
        <svg
          aria-hidden="true"
          className="h-5 w-5"
          viewBox="0 0 20 20"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.5"
        >
          <path d="M10 3a4 4 0 0 0-4 4v3l-1.5 2.5h11L14 10V7a4 4 0 0 0-4-4Z" />
          <path d="M8.5 15a1.5 1.5 0 0 0 3 0" />
        </svg>
        {unreadCount > 0 ? (
          <span className="absolute -end-1 -top-1 rounded-full bg-white px-1 text-[10px] font-semibold text-[var(--color-primary)]">
            {unreadCount}
          </span>
        ) : null}
      </button>

      <ProfileMenu onSignOut={onSignOut} />
    </div>
  );
}

export default BrandBar;
