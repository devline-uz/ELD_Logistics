/**
 * Regressiya testi — D49 (ikkinchi qism).
 *
 * `StrictMode` effektni ikki marta chaqiradi. Oldingi `useRef` darvozasi
 * ikkinchi (qoladigan) chaqiruvni bloklab, birinchisini `cancelled` qilardi —
 * natijada `setStatus` hech qachon chaqirilmay, ilova abadiy "Loading…"
 * holatida qolardi.
 */
import { render, screen, waitFor } from '@testing-library/react';
import { StrictMode } from 'react';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';
import { BootstrapGate } from '@/app/providers/BootstrapGate';
import { appConfigHandler } from '@/features/auth/mocks/handlers';
import { server } from '@/test/msw-server';
import { useAuthStore } from '@/store/auth-store';

afterEach(() => {
  useAuthStore.getState().reset();
  sessionStorage.clear();
});

describe('BootstrapGate', () => {
  it('renders children under StrictMode double-invoked effects', async () => {
    server.use(appConfigHandler);

    render(
      <StrictMode>
        <BootstrapGate>
          <div>app shell</div>
        </BootstrapGate>
      </StrictMode>,
    );

    await waitFor(() => {
      expect(screen.getByText('app shell')).toBeInTheDocument();
    });
  });

  it('skips bootstrap when asked', () => {
    render(
      <BootstrapGate skip>
        <div>app shell</div>
      </BootstrapGate>,
    );

    expect(screen.getByText('app shell')).toBeInTheDocument();
  });
});
