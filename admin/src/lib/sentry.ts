/**
 * Sentry (xato monitoringi) — **ixtiyoriy** integratsiya (vazifa 9.12).
 *
 * Qat'iy shartlar:
 *   1. `VITE_SENTRY_DSN` bo'sh bo'lsa `@sentry/react` chunk'i **umuman
 *      yuklanmaydi** — SDK ga yagona havola `sentry.client.ts` dagi dinamik
 *      `import()`. Boshlang'ich bundle byudjeti (TZ §12, 250 KB gzip)
 *      shu sabab o'zgarmaydi.
 *   2. **PII yuborilmaydi** (F206) — `lib/sentry.scrub.ts` dagi
 *      `beforeSend`/`beforeBreadcrumb` filtri: `Authorization`/`Cookie`,
 *      access/refresh token, parol, `license_no`, ism/telefon/email.
 *
 * DSN yo'q bo'lganda barcha eksportlar xavfsiz no-op bo'ladi.
 */
import type * as SentryClient from '@/lib/sentry.client';

const dsn = import.meta.env.VITE_SENTRY_DSN?.trim() ?? '';

/** DSN berilganmi — faqat shunda SDK yuklanadi. */
export function isSentryEnabled(): boolean {
  return dsn.length > 0;
}

let client: typeof SentryClient | null = null;
let initPromise: Promise<void> | null = null;

/**
 * SDK ni bir marta yuklaydi va sozlaydi. DSN bo'lmasa — hech narsa qilmaydi
 * (chunk ham so'ralmaydi). Yuklash muvaffaqiyatsiz bo'lsa ilova ishlashda
 * davom etadi: monitoring hech qachon UI ni to'xtatmaydi.
 */
export function initSentry(): Promise<void> {
  if (!isSentryEnabled()) return Promise.resolve();
  initPromise ??= import('@/lib/sentry.client')
    .then((module) => {
      module.initClient(dsn, import.meta.env.MODE);
      client = module;
    })
    .catch(() => {
      /* monitoring ixtiyoriy — yuklab bo'lmasa jim o'tiladi */
    });
  return initPromise;
}

/** Xatoni Sentry'ga yuboradi; SDK yoqilmagan bo'lsa — no-op. */
export function captureException(error: unknown, context?: Record<string, unknown>): void {
  client?.capture(error, context);
}
