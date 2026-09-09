import { AlertTriangle } from 'lucide-react';
import { useTranslation } from 'react-i18next';

export interface ErrorStateProps {
  title?: string;
  message?: string;
  onRetry?: () => void;
  retryLabel?: string;
  /**
   * Sarlavha HTML darajasi — chaqiruvchi ekran o'z `h1`/`h2` ierarxiyasiga
   * mos moslashtiradi (fe-a11y §4). Default `2`: bu komponent odatda sahifa
   * `h1`idan keyingi birinchi kontent sarlavhasi sifatida ishlatiladi.
   */
  headingLevel?: 2 | 3 | 4;
}

/** Xato xabari + «Try again» tugmasi (fe-screens §7). */
export function ErrorState({
  title,
  message,
  onRetry,
  retryLabel,
  headingLevel = 2,
}: ErrorStateProps) {
  const { t } = useTranslation();
  const HeadingTag = `h${headingLevel}` as const;

  return (
    <div
      role="alert"
      className="flex flex-col items-center justify-center gap-3 px-6 py-16 text-center"
    >
      <AlertTriangle aria-hidden="true" className="h-10 w-10 text-error-base" />
      <HeadingTag className="text-body-lg font-semibold text-neutral-900">
        {title ?? t('common.states.error')}
      </HeadingTag>
      <p className="max-w-sm text-body text-neutral-600">{message ?? t('errors.unknown')}</p>
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
