import type { ReactNode } from 'react';
import { Inbox } from 'lucide-react';
import { useTranslation } from 'react-i18next';

export interface EmptyStateProps {
  icon?: ReactNode;
  title?: string;
  description?: string;
  action?: ReactNode;
}

/** Ikonka/illyustratsiya + sarlavha + tavsif + ixtiyoriy amal (fe-screens §5). */
export function EmptyState({ icon, title, description, action }: EmptyStateProps) {
  const { t } = useTranslation();

  return (
    <div className="flex flex-col items-center justify-center gap-3 px-6 py-16 text-center">
      <div className="text-neutral-300" aria-hidden="true">
        {icon ?? <Inbox className="h-12 w-12" />}
      </div>
      <h3 className="text-body-lg font-semibold text-neutral-900">
        {title ?? t('ui.overlay.emptyState.defaultTitle')}
      </h3>
      <p className="max-w-sm text-body text-neutral-500">
        {description ?? t('ui.overlay.emptyState.defaultDescription')}
      </p>
      {action ? <div className="mt-2">{action}</div> : null}
    </div>
  );
}

export default EmptyState;
