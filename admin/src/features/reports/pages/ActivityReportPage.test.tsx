/**
 * Activity Report — integratsiya testi (Bosqich 6.2, §7.8.1): ro'yxat, tab almashinuvi
 * (`Units`/`Drivers`), xato holati.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import type { ReactElement } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PERM } from '@/lib/permissions';
import { driversListHandler } from '@/mocks/handlers/drivers';
import { reportsActivityErrorHandler, reportsActivityHandler } from '@/mocks/handlers/reports';
import { unitsListHandler } from '@/mocks/handlers/units';
import { useCompanyStore } from '@/store/company-store';
import { server } from '@/test/msw-server';

import { ActivityReportPage } from './ActivityReportPage';

function renderPage(): ReactElement {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return (
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.reportsRead, PERM.reportsExport]}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/reports/activity']}>
            <ActivityReportPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>
  );
}

beforeEach(() => {
  useCompanyStore.getState().setCompany({ unitSystem: 'metric' });
});

afterEach(() => {
  server.resetHandlers();
  useCompanyStore.getState().resetCompany();
});

describe('ActivityReportPage', () => {
  it('Units tabida ustunlar va ma’lumot ko‘rinadi (F120 tartibi)', async () => {
    server.use(reportsActivityHandler, unitsListHandler, driversListHandler);
    render(renderPage());

    expect(await screen.findByText('1021')).toBeInTheDocument();

    const headerRow = screen.getAllByRole('columnheader');
    const headerNames = headerRow.map((cell) => cell.textContent);
    expect(headerNames).toEqual([
      '#',
      'Unit #',
      'Start Odometer',
      'End Odometer',
      'Odometer Change',
      'Driving Time',
    ]);
  });

  it('Drivers tabiga o‘tganda Driver Name ustuni ko‘rinadi', async () => {
    server.use(reportsActivityHandler, unitsListHandler, driversListHandler);
    const user = userEvent.setup();
    render(renderPage());

    await screen.findByText('1021');
    await user.click(screen.getByRole('tab', { name: 'Drivers' }));

    expect(await screen.findByRole('columnheader', { name: 'Driver Name' })).toBeInTheDocument();
  });

  it('xato bo‘lganda ErrorState ko‘rsatiladi', async () => {
    server.use(reportsActivityErrorHandler, unitsListHandler, driversListHandler);
    render(renderPage());

    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });
});
