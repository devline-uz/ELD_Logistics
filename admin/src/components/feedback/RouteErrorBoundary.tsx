import { useTranslation } from 'react-i18next';
import { isRouteErrorResponse, useRouteError } from 'react-router-dom';

import { ForbiddenScreen } from '@/components/feedback/ForbiddenScreen';
import { NotFoundScreen } from '@/components/feedback/NotFoundScreen';
import { ApiError } from '@/lib/errors';

/**
 * Router darajasidagi `errorElement`.
 *
 * 403 va 404 qat'iy ajratiladi (fe-permissions §5): 403 — kirish darajasi,
 * 404 — ma'lumot darajasi (boshqa tenant/filial yozuvi ham 404).
 */
export function RouteErrorBoundary() {
  const error = useRouteError();
  const { t } = useTranslation();

  const status = isRouteErrorResponse(error)
    ? error.status
    : error instanceof ApiError
      ? error.status
      : undefined;

  if (status === 404) {
    return <NotFoundScreen />;
  }
  if (status === 403) {
    return <ForbiddenScreen />;
  }

  const traceId = error instanceof ApiError ? error.traceId : undefined;

  return (
    <section className="mx-auto flex max-w-lg flex-col items-start gap-3 py-16" role="alert">
      <h1 className="text-xl font-semibold text-neutral-900">{t('errors.boundary.title')}</h1>
      <p className="text-sm text-neutral-600">{t('errors.boundary.description')}</p>
      {traceId ? (
        <p className="font-mono text-xs text-neutral-500">
          {t('errors.boundary.traceId', { traceId })}
        </p>
      ) : null}
      <button
        type="button"
        className="text-sm underline"
        onClick={() => {
          window.location.reload();
        }}
      >
        {t('common.actions.reload')}
      </button>
    </section>
  );
}

export default RouteErrorBoundary;
