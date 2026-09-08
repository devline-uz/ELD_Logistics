import { useTranslation } from 'react-i18next';

import { IDLE_TIMEOUT_MS, useIdleTimeout } from '@/hooks/useIdleTimeout';

export interface IdleTimeoutDialogProps {
  onTimeout: () => void;
  /** Testda qisqartirish uchun. */
  timeoutMs?: number;
  enabled?: boolean;
}

/** 30 daqiqa harakatsizlikdan keyin logout ogohlantirishi (0.22). */
export function IdleTimeoutDialog({
  onTimeout,
  timeoutMs = IDLE_TIMEOUT_MS,
  enabled = true,
}: IdleTimeoutDialogProps) {
  const { t } = useTranslation();
  const { isWarning, secondsLeft, reset } = useIdleTimeout({ timeoutMs, onTimeout, enabled });

  if (!isWarning) {
    return null;
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
      <div
        role="alertdialog"
        aria-modal="true"
        aria-labelledby="idle-timeout-title"
        aria-describedby="idle-timeout-description"
        className="w-96 rounded border border-[var(--color-stroke)] bg-[var(--color-surface)] p-5 shadow-xl"
      >
        <h2 id="idle-timeout-title" className="text-base font-semibold text-neutral-900">
          {t('idle.title')}
        </h2>
        <p id="idle-timeout-description" className="mt-2 text-sm text-neutral-600">
          {t('idle.description', { minutes: Math.round(timeoutMs / 60_000) })}
        </p>
        <p className="mt-1 text-sm font-medium text-[var(--color-primary)]" aria-live="polite">
          {t('idle.countdown', { seconds: secondsLeft })}
        </p>
        <div className="mt-4 flex justify-end gap-2">
          <button type="button" className="px-3 py-1.5 text-sm underline" onClick={onTimeout}>
            {t('common.actions.signOut')}
          </button>
          <button
            type="button"
            className="rounded bg-[var(--color-primary)] px-3 py-1.5 text-sm text-white hover:bg-[var(--color-primary-hover)]"
            onClick={reset}
          >
            {t('common.actions.staySignedIn')}
          </button>
        </div>
      </div>
    </div>
  );
}

export default IdleTimeoutDialog;
