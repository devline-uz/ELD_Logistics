import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { RouterProvider } from 'react-router-dom';

import { AppProviders } from '@/app/providers';
import { createAppRouter } from '@/app/router';
import '@/styles/index.css';

const container = document.getElementById('root');

if (!container) {
  throw new Error('Root container #root not found');
}

// Ruxsatlar va sessiya bayroqlari 0.12/0.15 da auth store'dan uzatiladi.
createRoot(container).render(
  <StrictMode>
    <AppProviders>
      <RouterProvider router={createAppRouter()} />
    </AppProviders>
  </StrictMode>,
);
