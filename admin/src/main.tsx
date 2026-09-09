import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { RouterProvider } from 'react-router-dom';

import { AppProviders } from '@/app/providers';
import { createAppRouter } from '@/app/router';
import { initSentry } from '@/lib/sentry';
import '@/styles/index.css';

const container = document.getElementById('root');

if (!container) {
  throw new Error('Root container #root not found');
}

// Xato monitoringi (9.12): `VITE_SENTRY_DSN` bo'sh bo'lsa `@sentry/react`
// chunk'i umuman so'ralmaydi va bu chaqiruv darhol tugaydi.
void initSentry();

const root = createRoot(container);

function renderApp(): void {
  // Ruxsatlar va sessiya bayroqlari 0.12/0.15 da auth store'dan uzatiladi.
  root.render(
    <StrictMode>
      <AppProviders>
        <RouterProvider router={createAppRouter()} />
      </AppProviders>
    </StrictMode>,
  );
}

/**
 * MSW (Mock Service Worker) — faqat dev rejimida va `VITE_ENABLE_MSW=1`
 * bo'lganda ishga tushadi (9.1, Playwright e2e). `import.meta.env.DEV` shart
 * tekshiruvi build vaqtida `false`ga aylanadi — dinamik import butunlay
 * tree-shake qilinadi, prod bundle'ga `src/mocks/browser.ts` TUSHMAYDI
 * (F206, bundle byudjeti buzilmaydi).
 */
if (import.meta.env.DEV && import.meta.env.VITE_ENABLE_MSW === '1') {
  void import('@/mocks/browser').then(({ worker }) =>
    worker
      .start({
        onUnhandledRequest: 'bypass',
        serviceWorker: { url: '/mockServiceWorker.js' },
      })
      .then(renderApp),
  );
} else {
  renderApp();
}
