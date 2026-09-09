/**
 * Sentry SDK ning **yagona statik** import nuqtasi (9.12).
 *
 * ⚠️ Bu modul faqat `src/lib/sentry.ts` dan `import()` orqali chaqiriladi.
 * Nega alohida fayl: `import('@sentry/react')` namespace sifatida saqlansa
 * tree-shaking ishlamaydi va Session Replay (rrweb, ~150 KB) ham chunk'ga
 * tushadi. Bu yerda faqat kerakli nomlar import qilinadi — replay va
 * tracing integratsiyalari bundle'ga umuman kirmaydi.
 */
import { captureException as sentryCaptureException, init } from '@sentry/react';

import { scrubBreadcrumbData, scrubEvent } from '@/lib/sentry.scrub';

export function initClient(dsn: string, environment: string): void {
  init({
    dsn,
    environment,
    // Faqat xato hisobotlari: performance/replay integratsiyalari yoqilmagan
    // (qo'shimcha PII manbai va bundle og'irligi).
    integrations: [],
    tracesSampleRate: 0,
    sendDefaultPii: false,
    beforeSend: (event) => scrubEvent(event),
    beforeBreadcrumb: (crumb) => {
      if (crumb.data) crumb.data = scrubBreadcrumbData(crumb.data);
      return crumb;
    },
  });
}

export function capture(error: unknown, context?: Record<string, unknown>): void {
  sentryCaptureException(
    error,
    context ? { extra: scrubEvent({ extra: { ...context } }).extra } : undefined,
  );
}
