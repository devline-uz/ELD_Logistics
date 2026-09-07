import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import { AlertTriangle, CheckCircle2, Info, XCircle, X as CloseIcon } from 'lucide-react';
import { useTranslation } from 'react-i18next';

import {
  ToastContext,
  type Toast,
  type ToastApi,
  type ToastVariant,
} from '@/components/feedback/toast-context';

/**
 * Har variant uchun avtomatik yopilish vaqti (fe-screens §8):
 * `success` — 4s, `info`/`warning` — 6s, `error` — qo'lda yopiladi.
 */
const AUTO_DISMISS_MS: Record<ToastVariant, number | null> = {
  success: 4_000,
  info: 6_000,
  warning: 6_000,
  error: null,
};

const MAX_VISIBLE = 3;

const VARIANT_ICON: Record<ToastVariant, typeof CheckCircle2> = {
  success: CheckCircle2,
  error: XCircle,
  warning: AlertTriangle,
  info: Info,
};

const VARIANT_ICON_CLASSES: Record<ToastVariant, string> = {
  success: 'text-success-base',
  error: 'text-error-base',
  warning: 'text-warning-dark',
  info: 'text-decorative-blue',
};

export function ToastProvider({ children }: { children: ReactNode }) {
  const { t } = useTranslation();
  const [visible, setVisible] = useState<Toast[]>([]);
  const queue = useRef<Toast[]>([]);
  const timers = useRef(new Map<string, ReturnType<typeof setTimeout>>());
  // `scheduleDismiss` va `dismiss` bir-birini chaqiradi (auto-yopilish ↔ navbatdan
  // ko'tarish) — halqani ref orqali uzamiz, TDZ/tartib muammosisiz.
  const dismissRef = useRef<(id: string) => void>(() => undefined);

  const scheduleDismiss = useCallback((toast: Toast) => {
    const duration = AUTO_DISMISS_MS[toast.variant];
    if (duration === null) {
      return;
    }
    timers.current.set(
      toast.id,
      setTimeout(() => {
        dismissRef.current(toast.id);
      }, duration),
    );
  }, []);

  const dismiss = useCallback(
    (id: string) => {
      const timer = timers.current.get(id);
      if (timer) {
        clearTimeout(timer);
        timers.current.delete(id);
      }
      setVisible((current) => {
        const next = current.filter((toast) => toast.id !== id);
        const promoted = queue.current.shift();
        if (promoted) {
          scheduleDismiss(promoted);
          return [...next, promoted];
        }
        return next;
      });
    },
    [scheduleDismiss],
  );

  useEffect(() => {
    dismissRef.current = dismiss;
  }, [dismiss]);

  const show = useCallback<ToastApi['show']>(
    (toast) => {
      const id = crypto.randomUUID();
      const next: Toast = { ...toast, id };
      setVisible((current) => {
        if (current.length < MAX_VISIBLE) {
          scheduleDismiss(next);
          return [...current, next];
        }
        queue.current.push(next);
        return current;
      });
      return id;
    },
    [scheduleDismiss],
  );

  const api = useMemo<ToastApi>(() => ({ show, dismiss }), [show, dismiss]);

  return (
    <ToastContext.Provider value={api}>
      {children}
      <div
        className="pointer-events-none fixed end-4 top-4 z-50 flex w-80 flex-col gap-2"
        role="region"
        aria-label={t('toast.region')}
      >
        {visible.map((toast) => {
          const Icon = VARIANT_ICON[toast.variant];
          const isError = toast.variant === 'error';
          return (
            <div
              key={toast.id}
              role={isError ? 'alert' : 'status'}
              className="pointer-events-auto flex items-start gap-3 rounded-lg border border-stroke bg-surface p-3 text-body text-neutral-800 shadow-dropdown"
              data-variant={toast.variant}
            >
              <Icon
                aria-hidden="true"
                className={`mt-0.5 h-5 w-5 shrink-0 ${VARIANT_ICON_CLASSES[toast.variant]}`}
              />
              <span className="flex-1">{toast.message}</span>
              {toast.actionLabel && toast.onAction ? (
                <button
                  type="button"
                  className="shrink-0 text-body-sm font-medium text-primary underline"
                  onClick={toast.onAction}
                >
                  {toast.actionLabel}
                </button>
              ) : null}
              <button
                type="button"
                className="shrink-0 text-neutral-500 hover:text-neutral-700"
                onClick={() => {
                  dismiss(toast.id);
                }}
                aria-label={t('toast.dismiss')}
              >
                <CloseIcon aria-hidden="true" className="h-4 w-4" />
              </button>
            </div>
          );
        })}
      </div>
    </ToastContext.Provider>
  );
}

export default ToastProvider;
