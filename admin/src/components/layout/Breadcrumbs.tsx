import { useTranslation } from 'react-i18next';
import { Link, useLocation } from 'react-router-dom';

import { navGroupOf, routeTitleKey } from '@/app/nav-config';

/** QATLAM 3 — breadcrumb (faqat ichki ekranlarda; `/` da ko'rsatilmaydi). */
export function Breadcrumbs() {
  const { t } = useTranslation();
  const { pathname } = useLocation();

  if (pathname === '/') {
    return null;
  }

  const group = navGroupOf(pathname);
  const titleKey = routeTitleKey(pathname);

  return (
    <nav
      aria-label={t('nav.breadcrumb')}
      className="border-b border-[var(--color-stroke)] bg-[var(--color-surface)] px-6 py-2 text-xs text-neutral-500"
    >
      <ol className="flex items-center gap-2">
        <li>
          <Link className="hover:underline" to="/">
            {t('nav.home')}
          </Link>
        </li>
        {group ? (
          <li aria-hidden="true" className="flex items-center gap-2">
            <span>/</span>
            <span>{t(group.labelKey)}</span>
          </li>
        ) : null}
        {titleKey ? (
          <li className="flex items-center gap-2 text-neutral-800" aria-current="page">
            <span aria-hidden="true">/</span>
            <span>{t(titleKey)}</span>
          </li>
        ) : null}
      </ol>
    </nav>
  );
}

export default Breadcrumbs;
