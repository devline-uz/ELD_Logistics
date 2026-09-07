/**
 * LogsByDriverPage — integratsiya testi (MSW): "Select driver first" bo'sh
 * holati va haydovchi tanlangandan keyin ro'yxat (3.3, 7.4.2).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { driversListHandler } from '@/mocks/handlers/drivers';
import { driverDailyLogsHandler } from '@/mocks/handlers/logs';
import { violationsListEmptyHandler } from '@/mocks/handlers/violations';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { LogsByDriverPage } from './LogsByDriverPage';

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.logsRead]}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/logs/by-driver']}>
            <LogsByDriverPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('LogsByDriverPage', () => {
  it('shows the "select driver first" empty state until a driver is chosen', async () => {
    server.use(driversListHandler, violationsListEmptyHandler);
    renderPage();

    expect(await screen.findByText(/select driver first/i)).toBeInTheDocument();
  });

  it('loads the daily logs once a driver is selected', async () => {
    server.use(driversListHandler, driverDailyLogsHandler, violationsListEmptyHandler);
    const user = userEvent.setup();
    renderPage();

    const combobox = await screen.findByRole('combobox', { name: /driver/i });
    await user.click(combobox);
    await user.click(await screen.findByRole('option', { name: /john doe/i }));

    expect(await screen.findByText('06/09/2026')).toBeInTheDocument();
  });
});
