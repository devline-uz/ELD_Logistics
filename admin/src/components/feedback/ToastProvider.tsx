import { useCallback, useMemo, useRef, useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';

import { ToastContext, type Toast, type ToastApi } from '@/components/feedback/toast-context';

/** `error` qo'lda yopiladi, qolganlari 5 s dan keyin o'chadi (fe-design-system §6). */
const AUTO_DISMISS_MS = 5_000;
const MAX_VISIBLE = 3;

export function ToastProvider({ children }: { children: ReactNode }) {
  const { t } = useTranslation();
  const [toasts, setToasts] = useState<Toast[]>([]);
  const timers = useRef(new Map<string, ReturnType<typeof setTimeout>>());

  const dismiss = useCallback((id: string) => {
    const timer = timers.current.get(id);
    if (timer) {
      clearTimeout(timer);
      timers.current.delete(id);
    }
    setToasts((current) => current.filter((toast) => toast.id !== id));
  }, []);

  const show = useCallback<ToastApi['show']>(
    (toast) => {
      const id = crypto.randomUUID();
      setToasts((current) => [...current, { ...toast, id }].slice(-MAX_VISIBLE));
      if (toast.variant !== 'error') {
        timers.current.set(
          id,
          setTimeout(() => {
            dismiss(id);
          }, AUTO_DISMISS_MS),
        );
      }
      return id;
    },
    [dismiss],
  );

  const api = useMemo<ToastApi>(() => ({ show, dismiss }), [show, dismiss]);

  return (
    <ToastContext.Provider value={api}>
      {children}
      <div
        className="pointer-events-none fixed bottom-4 end-4 z-50 flex w-80 flex-col gap-2"
        role="region"
        aria-live="polite"
        aria-label={t('toast.region')}
      >
        {toasts.map((toast) => (
          <div
            key={toast.id}
            className="pointer-events-auto flex items-start gap-3 rounded border border-neutral-200 bg-white p-3 text-sm text-neutral-800 shadow-lg"
            data-variant={toast.variant}
          >
            <span className="flex-1">{toast.message}</span>
            <button
              type="button"
              className="text-neutral-500 underline"
              onClick={() => {
                dismiss(toast.id);
              }}
              aria-label={t('toast.dismiss')}
            >
              ×
            </button>
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}
