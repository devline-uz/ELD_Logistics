import { useCallback, useEffect, useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';

import { runBootstrap } from '@/app/bootstrap';

type BootstrapStatus = 'loading' | 'ready' | 'error';

export interface BootstrapGateProps {
  /** Testda bootstrap'ni o'tkazib yuborish uchun. */
  skip?: boolean;
  children: ReactNode;
}

/**
 * Bootstrap darvozasi (0.14/0.15).
 *
 * `GET /app/config` + sessiyani tiklash + `GET /me` tugamaguncha ilova
 * render qilinmaydi — to'liq ekranli yuklanish holati ko'rsatiladi
 * (fe-api §4: «Ilova bu javobsiz render qilinmaydi»).
 *
 * Muvaffaqiyatsizlikda — to'liq ekranli xato + «Try again» (fe-screens §7,
 * 1-daraja: global xato).
 */
export function BootstrapGate({ skip = false, children }: BootstrapGateProps) {
  const { t } = useTranslation();
  const [status, setStatus] = useState<BootstrapStatus>(skip ? 'ready' : 'loading');
  const [attempt, setAttempt] = useState(0);

  useEffect(() => {
    if (skip) return undefined;

    // StrictMode dev rejimida effektni ikki marta chaqiradi (mount → cleanup
    // → mount, bitta sinxron bosqichda). Oldin bu yerda "bir marta ketishi
    // shart" degan `useRef` darvozasi bor edi: u ikkinchi (haqiqiy qoladigan)
    // chaqiruvni butunlay bloklardi, birinchisi esa `cleanup`da `cancelled`
    // bo'lib qolib, promise tugagach `setStatus` hech qachon chaqirilmasdi —
    // ilova "Loading…" holatida abadiy qolib ketardi (9.1 e2e orqali
    // `npm run dev`da aniqlangan, productionda StrictMode yo'q — ko'rinmagan).
    // To'g'ri yechim: darvozasiz, har chaqiruv o'zining `cancelled`
    // bayrog'iga tayanadi — birinchisi bekor qilinadi, ikkinchisi yakunlaydi.
    let cancelled = false;
    setStatus('loading');

    runBootstrap()
      .then(() => {
        if (!cancelled) setStatus('ready');
      })
      .catch((error: unknown) => {
        console.error('[bootstrap] failed', error);
        if (!cancelled) setStatus('error');
      });

    return () => {
      cancelled = true;
    };
  }, [attempt, skip]);

  const retry = useCallback(() => {
    setAttempt((value) => value + 1);
  }, []);

  if (status === 'loading') {
    return (
      <div
        aria-busy="true"
        aria-live="polite"
        className="flex min-h-screen items-center justify-center"
        role="status"
      >
        <p className="text-sm">{t('bootstrap.loading')}</p>
      </div>
    );
  }

  if (status === 'error') {
    return (
      <div className="flex min-h-screen items-center justify-center px-6">
        <div className="w-full max-w-md text-center" role="alert">
          <h1 className="text-lg font-semibold">{t('bootstrap.error.title')}</h1>
          <p className="mt-2 text-sm">{t('bootstrap.error.description')}</p>
          <button
            className="mt-4 rounded border px-4 py-2 text-sm"
            onClick={retry}
            style={{ borderColor: 'var(--color-stroke)' }}
            type="button"
          >
            {t('common.actions.tryAgain')}
          </button>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}

export default BootstrapGate;
