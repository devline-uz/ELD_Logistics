import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, describe, expect, it, vi } from 'vitest';

import '@/app/i18n';
import {
  driverActivitiesHandler,
  driverCoDriversEmptyHandler,
  driverGetHandler,
  driverLicenseRevealHandler,
  driversListHandler,
} from '@/mocks/handlers/drivers';
import { hosSummaryHandler, hosSummaryNotFoundHandler } from '@/mocks/handlers/hos';
import { server } from '@/test/msw-server';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { PERM } from '@/lib/permissions';

import { DriverActivitiesPage, DriverDailyLogsPage, DriverDetailPage } from './DriverDetailPage';

function renderPage(permissions: string[]) {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={client}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/drivers/driver-1']}>
            <Routes>
              <Route element={<DriverDetailPage />} path="/drivers/:driverId" />
              <Route element={<DriverActivitiesPage />} path="/drivers/:driverId/activities" />
              <Route element={<DriverDailyLogsPage />} path="/drivers/:driverId/logs" />
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
    server.use(
      driversListHandler,
      driverGetHandler,
      driverCoDriversEmptyHandler,
      hosSummaryHandler,
    );
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
      hosSummaryHandler,
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

  it("B3: HOS summary blokini backend hisoblagichlaridan ko'rsatadi", async () => {
    server.use(
      driversListHandler,
      driverGetHandler,
      driverCoDriversEmptyHandler,
      hosSummaryHandler,
    );
    renderPage([PERM.driversRead]);

    await waitFor(() =>
      expect(screen.getByRole('heading', { name: 'John Doe' })).toBeInTheDocument(),
    );

    expect(await screen.findByText('Hours of Service')).toBeInTheDocument();
    // 300 daqiqa drive_left_min -> 05:00
    expect(screen.getByText('05:00')).toBeInTheDocument();
  });

  it("HOS summary `404` bo'lsa blok yashiriladi (endpoint hali `hos_policy` yo'q holat)", async () => {
    server.use(
      driversListHandler,
      driverGetHandler,
      driverCoDriversEmptyHandler,
      hosSummaryNotFoundHandler,
    );
    renderPage([PERM.driversRead]);

    await waitFor(() =>
      expect(screen.getByRole('heading', { name: 'John Doe' })).toBeInTheDocument(),
    );
    await waitFor(() => expect(screen.queryByText('Hours of Service')).not.toBeInTheDocument());
  });

  it("B4: Activities/Daily logs tablari haqiqiy marshrutga o'tadi (useState emas)", async () => {
    server.use(
      driversListHandler,
      driverGetHandler,
      driverCoDriversEmptyHandler,
      driverActivitiesHandler,
      hosSummaryHandler,
    );
    const user = userEvent.setup();
    renderPage([PERM.driversRead]);

    await waitFor(() =>
      expect(screen.getByRole('heading', { name: 'John Doe' })).toBeInTheDocument(),
    );

    await user.click(screen.getByRole('tab', { name: 'Activities' }));

    await waitFor(() =>
      expect(screen.getByRole('columnheader', { name: 'Time Stamp' })).toBeInTheDocument(),
    );
  });
});
