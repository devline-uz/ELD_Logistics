/**
 * DVIR Report — integratsiya testi (Bosqich 6.5, §7.8.4): ro'yxat, filtrlar,
 * xato holati, `reports.export` ruxsatiga bog'liq `Export` tugmasi va **F107
 * — imzo joylashtirish formasi yo'qligi**.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import type { ReactElement } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PERM } from '@/lib/permissions';
import { driversListHandler } from '@/mocks/handlers/drivers';
import { dvirListErrorHandler, dvirListHandler } from '@/mocks/handlers/dvir';
import { unitsListHandler } from '@/mocks/handlers/units';
import { server } from '@/test/msw-server';

import { DvirReportPage } from './DvirReportPage';

function renderPage(permissions: readonly string[]): ReactElement {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return (
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/reports/dvir']}>
            <DvirReportPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('DvirReportPage', () => {
  it('ro‘yxatni va filtrlarni ko‘rsatadi', async () => {
    server.use(dvirListHandler, unitsListHandler, driversListHandler);
    render(renderPage([PERM.reportsRead, PERM.reportsExport]));

    expect(await screen.findByText('John Doe')).toBeInTheDocument();
    expect(screen.getByRole('heading', { name: 'DVIR Report' })).toBeInTheDocument();
    expect(screen.getByRole('combobox', { name: 'Driver' })).toBeInTheDocument();
    expect(screen.getByRole('combobox', { name: 'Unit' })).toBeInTheDocument();
    expect(screen.getByRole('combobox', { name: 'Type' })).toBeInTheDocument();
    expect(screen.getByRole('combobox', { name: 'Status' })).toBeInTheDocument();
    expect(screen.getByText('Date range')).toBeInTheDocument();
  });

  it('F107 — hech qanday imzo joylashtirish elementi yo‘q', async () => {
    server.use(dvirListHandler, unitsListHandler, driversListHandler);
    render(renderPage([PERM.reportsRead, PERM.reportsExport]));

    await screen.findByText('John Doe');

    expect(screen.queryByText(/signature/i)).not.toBeInTheDocument();
    expect(document.querySelector('input[type="file"]')).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /certify/i })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /repair/i })).not.toBeInTheDocument();
  });

  it('`reports.export` bo‘lmasa Export tugmasi ko‘rinmaydi', async () => {
    server.use(dvirListHandler, unitsListHandler, driversListHandler);
    render(renderPage([PERM.reportsRead]));

    await screen.findByText('John Doe');
    expect(screen.queryByRole('button', { name: 'Export' })).not.toBeInTheDocument();
  });

  it('xato bo‘lganda ErrorState ko‘rsatiladi', async () => {
    server.use(dvirListErrorHandler, unitsListHandler, driversListHandler);
    render(renderPage([PERM.reportsRead, PERM.reportsExport]));

    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });
});
