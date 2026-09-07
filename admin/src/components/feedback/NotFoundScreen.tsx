import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';

/**
 * 404 — resurs yo'q **yoki boshqa tenantga tegishli**. UI hech qachon
 * «bu boshqa kompaniyaniki» demaydi (fe-permissions §5).
 */
export function NotFoundScreen() {
  const { t } = useTranslation();

  return (
    <section className="mx-auto flex max-w-lg flex-col items-start gap-3 py-16">
      <h1 className="text-xl font-semibold text-neutral-900">{t('errors.notFoundScreen.title')}</h1>
      <p className="text-sm text-neutral-600">{t('errors.notFoundScreen.description')}</p>
      <Link className="text-sm underline" to="/">
        {t('common.actions.goHome')}
      </Link>
    </section>
  );
}

export default NotFoundScreen;
