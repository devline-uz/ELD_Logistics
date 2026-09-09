import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';

export interface ForbiddenScreenProps {
  /** Qaysi kalit yetishmayotgani — faqat dev rejimda ko'rsatiladi. */
  requiredPermission?: string;
}

/** 403 — resurs mavjud, lekin ruxsat kaliti yo'q (fe-permissions §5). */
export function ForbiddenScreen({ requiredPermission }: ForbiddenScreenProps) {
  const { t } = useTranslation();

  return (
    <section className="mx-auto flex max-w-lg flex-col items-start gap-3 py-16" role="alert">
      <h1 className="text-xl font-semibold text-neutral-900">
        {t('errors.forbiddenScreen.title')}
      </h1>
      <p className="text-sm text-neutral-600">{t('errors.forbiddenScreen.description')}</p>
      {import.meta.env.DEV && requiredPermission ? (
        <p className="font-mono text-xs text-neutral-600">
          {t('errors.forbiddenScreen.requiredPermission', { permission: requiredPermission })}
        </p>
      ) : null}
      <Link className="text-sm underline" to="/">
        {t('common.actions.goHome')}
      </Link>
    </section>
  );
}

export default ForbiddenScreen;
