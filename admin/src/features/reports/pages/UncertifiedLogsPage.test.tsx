/**
 * Uncertified Logs — integratsiya testi (Bosqich 6.6, §7.8.5, F128): ro'yxat,
 * `Send reminder` doim `disabled` (D29), `Open log` navigatsiyasi, xato holati.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import type { ReactElement } from 'react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PERM } from '@/lib/permissions';
import { driversListHandler } from '@/mocks/handlers/drivers';
import {
  reportsUncertifiedLogsErrorHandler,
  reportsUncertifiedLogsHandler,
} from '@/mocks/handlers/reports';
import { server } from '@/test/msw-server';

import { UncertifiedLogsPage } from './UncertifiedLogsPage';

function renderPage(): ReactElement {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return (
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.reportsRead]}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/reports/uncertified-logs']}>
            <Routes>
              <Route path="/reports/uncertified-logs" element={<UncertifiedLogsPage />} />
              <Route path="/logs/view/:logId" element={<div>Log view screen</div>} />
            </Routes>
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('UncertifiedLogsPage', () => {
  it('ro‘yxatni ustunlar bilan ko‘rsatadi (Unit/Totals — D33, N/A)', async () => {
    server.use(reportsUncertifiedLogsHandler, driversListHandler);
    render(renderPage());

    expect(await screen.findByText('Ali Karimov')).toBeInTheDocument();
    expect(screen.getByText('3')).toBeInTheDocument();

    const headerNames = screen.getAllByRole('columnheader').map((cell) => cell.textContent);
    expect(headerNames).toEqual([
      '#',
      'Driver',
      'Log date',
      'Days uncertified',
      'Unit',
      'Totals',
      'Action',
    ]);
    // D33 — backendda Unit/Totals maydoni yo'q, doim N/A.
    expect(screen.getAllByText('N/A').length).toBeGreaterThanOrEqual(2);
  });

  it('D29 — Send reminder doim disabled, sababi tooltipda ko‘rsatiladi', async () => {
    server.use(reportsUncertifiedLogsHandler, driversListHandler);
    render(renderPage());

    const sendReminder = await screen.findByRole('button', { name: 'Send reminder' });
    expect(sendReminder).toBeDisabled();
    expect(sendReminder).toHaveAttribute('title', 'Reminders are not available yet');
  });

  it('Open log bosilganda log ekraniga o‘tadi', async () => {
    server.use(reportsUncertifiedLogsHandler, driversListHandler);
    const user = userEvent.setup();
    render(renderPage());

    await user.click(await screen.findByRole('button', { name: 'Open log' }));

    expect(await screen.findByText('Log view screen')).toBeInTheDocument();
  });

  it('xato bo‘lganda ErrorState ko‘rsatiladi', async () => {
    server.use(reportsUncertifiedLogsErrorHandler, driversListHandler);
    render(renderPage());

    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });
});
