import { useEffect, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { NavLink, useLocation } from 'react-router-dom';

import { NAV_ENTRIES, filterNav, type VisibleNavEntry } from '@/app/nav-config';
import { usePermission } from '@/lib/permissions';

const LINK_BASE =
  'relative inline-flex h-11 items-center px-3 text-sm text-neutral-700 hover:text-[var(--color-primary)]';
const LINK_ACTIVE =
  'text-[var(--color-primary)] after:absolute after:inset-x-0 after:bottom-0 after:h-0.5 after:bg-[var(--color-primary)]';

function isGroupActive(entry: Extract<VisibleNavEntry, { kind: 'group' }>, pathname: string) {
  return entry.children.some(
    (leaf) => pathname === leaf.path || pathname.startsWith(`${leaf.path}/`),
  );
}

/**
 * QATLAM 2 — navigatsiya (oq fon), faol element qizil + 2 px ostki chiziq.
 * Ruxsat yo'q element **DOM'da bo'lmaydi** (0.19).
 */
export function MainNav() {
  const { t } = useTranslation();
  const can = usePermission();
  const { pathname } = useLocation();
  const [openGroup, setOpenGroup] = useState<string | null>(null);
  const navRef = useRef<HTMLElement>(null);

  const entries = useMemo(() => filterNav(NAV_ENTRIES, can), [can]);

  useEffect(() => {
    setOpenGroup(null);
  }, [pathname]);

  useEffect(() => {
    if (openGroup === null) {
      return;
    }
    const onPointerDown = (event: MouseEvent) => {
      if (!navRef.current?.contains(event.target as Node)) {
        setOpenGroup(null);
      }
    };
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setOpenGroup(null);
      }
    };
    document.addEventListener('mousedown', onPointerDown);
    document.addEventListener('keydown', onKeyDown);
    return () => {
      document.removeEventListener('mousedown', onPointerDown);
      document.removeEventListener('keydown', onKeyDown);
    };
  }, [openGroup]);

  return (
    <nav
      ref={navRef}
      aria-label={t('nav.primary')}
      className="border-b border-[var(--color-stroke)] bg-[var(--color-surface)] px-6"
    >
      <ul className="flex items-stretch gap-1">
        {entries.map((entry) => {
          if (entry.kind === 'leaf') {
            return (
              <li key={entry.id}>
                <NavLink
                  to={entry.path}
                  end={entry.path === '/'}
                  className={({ isActive }) => `${LINK_BASE} ${isActive ? LINK_ACTIVE : ''}`}
                >
                  {t(entry.labelKey)}
                </NavLink>
              </li>
            );
          }

          const active = isGroupActive(entry, pathname);
          const open = openGroup === entry.id;

          return (
            <li key={entry.id} className="relative">
              <button
                type="button"
                aria-haspopup="true"
                aria-expanded={open}
                className={`${LINK_BASE} ${active ? LINK_ACTIVE : ''}`}
                onClick={() => {
                  setOpenGroup(open ? null : entry.id);
                }}
              >
                {t(entry.labelKey)}
                <svg
                  aria-hidden="true"
                  className="ms-1 h-3 w-3"
                  viewBox="0 0 12 12"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1.5"
                >
                  <path d="M3 4.5 6 7.5 9 4.5" />
                </svg>
              </button>

              {open ? (
                <ul className="absolute start-0 top-11 z-40 w-80 rounded border border-[var(--color-stroke)] bg-[var(--color-surface)] py-1 shadow-lg">
                  {entry.children.map((leaf) => (
                    <li key={leaf.id}>
                      <NavLink
                        to={leaf.path}
                        className="block px-3 py-2 hover:bg-[var(--color-surface-muted)]"
                      >
                        <span className="block text-sm font-medium text-neutral-800">
                          {t(leaf.labelKey)}
                        </span>
                        {leaf.descriptionKey ? (
                          <span className="block text-xs text-neutral-500">
                            {t(leaf.descriptionKey)}
                          </span>
                        ) : null}
                      </NavLink>
                    </li>
                  ))}
                </ul>
              ) : null}
            </li>
          );
        })}
      </ul>
    </nav>
  );
}

export default MainNav;
