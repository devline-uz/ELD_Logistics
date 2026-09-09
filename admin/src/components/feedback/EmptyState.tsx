import type { ReactNode } from 'react';
import { Inbox } from 'lucide-react';
import { useTranslation } from 'react-i18next';

export interface EmptyStateProps {
  icon?: ReactNode;
  title?: string;
  description?: string;
  action?: ReactNode;
  /**
   * Sarlavha HTML darajasi — chaqiruvchi ekran o'z `h1`/`h2` ierarxiyasiga
   * mos moslashtiradi (fe-a11y §4 "bitta h1, mantiqiy h2/h3"). Default `2`:
   * bu komponent odatda sahifa `h1`idan keyingi birinchi kontent sarlavhasi
   * sifatida ishlatiladi, shu sabab `h3` bilan darajani sakrab o'tmaslik uchun.
   */
  headingLevel?: 2 | 3 | 4;
}

/** Ikonka/illyustratsiya + sarlavha + tavsif + ixtiyoriy amal (fe-screens §5). */
export function EmptyState({
  icon,
  title,
  description,
  action,
  headingLevel = 2,
}: EmptyStateProps) {
  const { t } = useTranslation();
  const HeadingTag = `h${headingLevel}` as const;

  return (
    <div className="flex flex-col items-center justify-center gap-3 px-6 py-16 text-center">
      <div className="text-neutral-300" aria-hidden="true">
        {icon ?? <Inbox className="h-12 w-12" />}
      </div>
      <HeadingTag className="text-body-lg font-semibold text-neutral-900">
        {title ?? t('ui.overlay.emptyState.defaultTitle')}
      </HeadingTag>
      <p className="max-w-sm text-body text-neutral-600">
        {description ?? t('ui.overlay.emptyState.defaultDescription')}
      </p>
      {action ? <div className="mt-2">{action}</div> : null}
    </div>
  );
}

export default EmptyState;
