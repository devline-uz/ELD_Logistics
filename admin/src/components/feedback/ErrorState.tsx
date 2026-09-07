import { AlertTriangle } from 'lucide-react';
import { useTranslation } from 'react-i18next';

export interface ErrorStateProps {
  title?: string;
  message?: string;
  onRetry?: () => void;
  retryLabel?: string;
}

/** Xato xabari + «Try again» tugmasi (fe-screens §7). */
export function ErrorState({ title, message, onRetry, retryLabel }: ErrorStateProps) {
  const { t } = useTranslation();

  return (
    <div
      role="alert"
      className="flex flex-col items-center justify-center gap-3 px-6 py-16 text-center"
    >
      <AlertTriangle aria-hidden="true" className="h-10 w-10 text-error-base" />
      <h3 className="text-body-lg font-semibold text-neutral-900">
        {title ?? t('common.states.error')}
      </h3>
      <p className="max-w-sm text-body text-neutral-500">{message ?? t('errors.unknown')}</p>
      {onRetry ? (
        <button
          type="button"
          onClick={onRetry}
          className="mt-2 rounded-md bg-primary px-4 py-2 text-body font-medium text-white hover:bg-primary-hover"
        >
          {retryLabel ?? t('common.actions.tryAgain')}
        </button>
      ) : null}
    </div>
  );
}

export default ErrorState;
