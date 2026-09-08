/**
 * Export Jobs — integratsiya testi (Bosqich 6.7, §7.8.7): `mine` toggle (F129),
 * `Params` xulosasi, muddati o'tgan yuklab olish havolasi, xato holati.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import type { ReactElement } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PERM } from '@/lib/permissions';
import { exportJobFixture } from '@/mocks/handlers/reports';
import { jsonError, listMeta, url } from '@/mocks/handlers/shared';
import { usersListEmptyHandler } from '@/mocks/handlers/users';
import { server } from '@/test/msw-server';
import { useAuthStore } from '@/store/auth-store';
import { useCompanyStore } from '@/store/company-store';

import { ExportJobsPage } from './ExportJobsPage';

const jobsHandler = http.get(url('/reports/export-jobs'), () =>
  HttpResponse.json({
    data: [
      exportJobFixture({
        id: 'job-own',
        type: 'distance_by_region',
        format: 'xlsx',
        status: 'done',
        requested_by: 'user-1',
        finished_at: '2026-09-06T05:12:31Z',
        download_url: 'https://storage.example.com/onebook/job-own.xlsx',
        expires_at: new Date(Date.now() - 60_000).toISOString(),
        file_size_b: 20_480,
        params: { quarter: 3, year: 2026, mode: 'regions_and_units' },
      }),
      exportJobFixture({
        id: 'job-other',
        type: 'activity',
        format: 'csv',
        status: 'running',
        requested_by: 'user-2',
        params: { subject: 'units', from: '2026-09-01', to: '2026-09-07' },
      }),
    ],
    meta: listMeta({ total: 2 }),
  }),
);

const jobsErrorHandler = http.get(url('/reports/export-jobs'), () =>
  jsonError('VALIDATION_ERROR', 'unsupported status', 422),
);

function renderPage(): ReactElement {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return (
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.reportsRead]}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/reports/exports']}>
            <ExportJobsPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>
  );
}

beforeEach(() => {
  useAuthStore.getState().setProfile({
    id: 'user-1',
    first_name: 'Jane',
    last_name: 'Admin',
    permissions: [],
    status: 'active',
    scope: 'company',
  });
});

afterEach(() => {
  server.resetHandlers();
  useAuthStore.getState().reset();
  useCompanyStore.getState().resetCompany();
});

describe('ExportJobsPage', () => {
  it('ro‘yxatni ko‘rsatadi: joriy foydalanuvchi ismi, muddati o‘tgan havola, Params xulosasi', async () => {
    server.use(jobsHandler, usersListEmptyHandler);
    render(renderPage());

    expect(await screen.findByText('Jane Admin')).toBeInTheDocument();
    expect(screen.getByText('user-2…')).toBeInTheDocument();
    expect(screen.getByText('Q3 2026 · Regions and units')).toBeInTheDocument();
    expect(screen.getByText('20.0 KB')).toBeInTheDocument();

    // job-own `done`, lekin `expires_at` o'tgan — Download o'chirilgan, sabab ko'rsatilgan.
    const downloadButtons = screen.getAllByRole('button', { name: /^Download/ });
    expect(downloadButtons[0]).toBeDisabled();
  });

  it('"Show all" almashtirilganda `mine` filtri o‘zgaradi', async () => {
    server.use(jobsHandler, usersListEmptyHandler);
    const user = userEvent.setup();
    render(renderPage());

    await screen.findByText('Jane Admin');
    const toggle = screen.getByRole('switch', { name: 'Show all' });
    expect(toggle).not.toBeChecked();

    await user.click(toggle);
    expect(toggle).toBeChecked();
  });

  it('us_fmcsa profilida Type ustuni "IFTA Report" deb ko‘rsatadi', async () => {
    useCompanyStore.getState().setCompany({ regulationProfile: 'us_fmcsa' });
    server.use(jobsHandler, usersListEmptyHandler);
    render(renderPage());

    expect(await screen.findByText('IFTA Report')).toBeInTheDocument();
  });

  it('xato bo‘lganda ErrorState ko‘rsatiladi', async () => {
    server.use(jobsErrorHandler, usersListEmptyHandler);
    render(renderPage());

    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });
});
