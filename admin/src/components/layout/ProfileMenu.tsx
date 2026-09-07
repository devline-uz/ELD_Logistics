import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';

import { PermissionGate } from '@/components/ui/PermissionGate';
import { PERM } from '@/lib/permissions';

export interface ProfileMenuProps {
  onSignOut?: () => void;
}

/** Profil menyusi — Settings shu yerdan ochiladi (nav'da yo'q). */
export function ProfileMenu({ onSignOut }: ProfileMenuProps) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const container = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) {
      return;
    }
    const onDocumentPointerDown = (event: MouseEvent) => {
      if (!container.current?.contains(event.target as Node)) {
        setOpen(false);
      }
    };
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setOpen(false);
      }
    };
    document.addEventListener('mousedown', onDocumentPointerDown);
    document.addEventListener('keydown', onKeyDown);
    return () => {
      document.removeEventListener('mousedown', onDocumentPointerDown);
      document.removeEventListener('keydown', onKeyDown);
    };
  }, [open]);

  return (
    <div className="relative" ref={container}>
      <button
        type="button"
        className="flex h-8 w-8 items-center justify-center rounded-full bg-white/20 text-sm font-semibold"
        aria-haspopup="menu"
        aria-expanded={open}
        aria-label={t('nav.brand.profileMenu')}
        onClick={() => {
          setOpen((value) => !value);
        }}
      >
        <svg aria-hidden="true" className="h-4 w-4" viewBox="0 0 16 16" fill="currentColor">
          <circle cx="8" cy="5.5" r="3" />
          <path d="M2 14a6 6 0 0 1 12 0Z" />
        </svg>
      </button>

      {open ? (
        <div
          role="menu"
          aria-label={t('profileMenu.label')}
          className="absolute end-0 top-10 z-40 w-56 rounded border border-[var(--color-stroke)] bg-[var(--color-surface)] py-1 text-sm text-neutral-800 shadow-lg"
        >
          <Link
            role="menuitem"
            className="block px-3 py-2 hover:bg-[var(--color-surface-muted)]"
            to="/settings/profile"
          >
            {t('profileMenu.profile')}
          </Link>
          <PermissionGate permission={PERM.companyRead}>
            <Link
              role="menuitem"
              className="block px-3 py-2 hover:bg-[var(--color-surface-muted)]"
              to="/settings/company"
            >
              {t('profileMenu.company')}
            </Link>
          </PermissionGate>
          <PermissionGate permission={PERM.hosPolicyRead}>
            <Link
              role="menuitem"
              className="block px-3 py-2 hover:bg-[var(--color-surface-muted)]"
              to="/settings/hos"
            >
              {t('profileMenu.hosPolicy')}
            </Link>
          </PermissionGate>
          <Link
            role="menuitem"
            className="block px-3 py-2 hover:bg-[var(--color-surface-muted)]"
            to="/settings/security"
          >
            {t('profileMenu.security')}
          </Link>
          <button
            type="button"
            role="menuitem"
            className="block w-full px-3 py-2 text-start hover:bg-[var(--color-surface-muted)]"
            onClick={() => {
              setOpen(false);
              onSignOut?.();
            }}
          >
            {t('profileMenu.signOut')}
          </button>
        </div>
      ) : null}
    </div>
  );
}

export default ProfileMenu;
