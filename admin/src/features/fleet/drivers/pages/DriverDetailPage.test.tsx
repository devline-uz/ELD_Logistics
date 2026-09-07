import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, describe, expect, it, vi } from 'vitest';

import '@/app/i18n';
import {
  driverCoDriversEmptyHandler,
  driverGetHandler,
  driverLicenseRevealHandler,
  driversListHandler,
} from '@/mocks/handlers/drivers';
import { server } from '@/test/msw-server';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { PERM } from '@/lib/permissions';

import { DriverDetailPage } from './DriverDetailPage';

function renderPage(permissions: string[]) {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={client}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/drivers/driver-1']}>
            <Routes>
              <Route element={<DriverDetailPage />} path="/drivers/:driverId" />
            </Routes>
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
  vi.useRealTimers();
});

describe('DriverDetailPage', () => {
  it('`drivers.license.view` bo\'lmasa "Reveal" tugmasi ko\'rinmaydi', async () => {
    server.use(driversListHandler, driverGetHandler, driverCoDriversEmptyHandler);
    renderPage([PERM.driversRead]);

    await waitFor(() =>
      expect(screen.getByRole('heading', { name: 'John Doe' })).toBeInTheDocument(),
    );
    expect(
      screen.queryByRole('button', { name: /reveal license number/i }),
    ).not.toBeInTheDocument();
  });

  it('F87: "Reveal" bosilganda ochiq qiymat ko\'rinadi va 30s dan keyin qayta maskalanadi', async () => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
    server.use(
      driversListHandler,
      driverGetHandler,
      driverCoDriversEmptyHandler,
      driverLicenseRevealHandler,
    );
    const user = userEvent.setup({ delay: null, advanceTimers: vi.advanceTimersByTime });

    renderPage([PERM.driversRead, PERM.driversLicenseView]);

    await waitFor(() =>
      expect(screen.getByRole('heading', { name: 'John Doe' })).toBeInTheDocument(),
    );

    const revealButton = screen.getByRole('button', { name: /reveal license number/i });
    await user.click(revealButton);

    await waitFor(() => expect(screen.getByText('TX-9930-4821')).toBeInTheDocument());

    await vi.advanceTimersByTimeAsync(30_000);

    await waitFor(() => expect(screen.queryByText('TX-9930-4821')).not.toBeInTheDocument());
  });
});
