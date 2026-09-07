import { Fragment } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';

export interface BreadcrumbItem {
  label: string;
  href?: string;
}

export interface BreadcrumbProps {
  items: BreadcrumbItem[];
}

/** `<nav aria-label>` + `<ol>`, oxirgi element `aria-current="page"` (fe-a11y §2). */
export function Breadcrumb({ items }: BreadcrumbProps) {
  const { t } = useTranslation();

  return (
    <nav aria-label={t('breadcrumb.navLabel')}>
      <ol className="flex flex-wrap items-center gap-1.5 text-body-sm text-neutral-500">
        {items.map((item, index) => {
          const isLast = index === items.length - 1;
          return (
            <Fragment key={`${item.label}-${index}`}>
              {index > 0 ? (
                <li aria-hidden="true" className="text-neutral-300">
                  /
                </li>
              ) : null}
              <li>
                {isLast || !item.href ? (
                  <span
                    aria-current={isLast ? 'page' : undefined}
                    className={isLast ? 'font-medium text-neutral-700' : undefined}
                  >
                    {item.label}
                  </span>
                ) : (
                  <Link to={item.href} className="hover:text-primary hover:underline">
                    {item.label}
                  </Link>
                )}
              </li>
            </Fragment>
          );
        })}
      </ol>
    </nav>
  );
}

export default Breadcrumb;
