import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';

import '@/styles/index.css';

const container = document.getElementById('root');

if (!container) {
  throw new Error('Root container #root not found');
}

createRoot(container).render(
  <StrictMode>
    {/* Bosqich 0 (B qismi): providers.tsx + router.tsx shu yerga ulanadi */}
    <div />
  </StrictMode>,
);
