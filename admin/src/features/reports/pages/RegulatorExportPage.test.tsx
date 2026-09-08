/**
 * Regulator Export / FMCSA — integratsiya testi (Bosqich 6.4, §7.8.3): ekran nomi
 * (F125), job ro'yxati (`Job ID`, F126), Generate modalining shartli maydoni
 * (Custom Range → From/To), xato holati.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import type { ReactElement } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PERM } from '@/lib/permissions';
import { driversListHandler } from '@/mocks/handlers/drivers';
import { exportJobFixture } from '@/mocks/handlers/reports';
import { jsonError, listMeta, url } from '@/mocks/handlers/shared';
import { server } from '@/test/msw-server';
import { useCompanyStore } from '@/store/company-store';

import { RegulatorExportPage } from './RegulatorExportPage';

const regulatorJobsHandler = http.get(url('/reports/export-jobs'), () =>
  HttpResponse.json({
    data: [
      exportJobFixture({
        id: 'job-reg-1',
        type: 'regulator',
        status: 'done',
        finished_at: '2026-09-06T05:12:31Z',
        params: {
          driver_ids: ['driver-1'],
          comment: 'Roadside inspection, unit 1021',
          from: '2026-08-30',
          to: '2026-09-06',
        },
      }),
    ],
    meta: listMeta(),
  }),
);

const regulatorJobsErrorHandler = http.get(url('/reports/export-jobs'), () =>
  jsonError('VALIDATION_ERROR', 'unsupported type', 422),
);

function renderPage(): ReactElement {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return (
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.reportsRead, PERM.reportsExport]}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/reports/regulator']}>
            <RegulatorExportPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>
  );
}

afterEach(() => {
  server.resetHandlers();
  useCompanyStore.getState().resetCompany();
});

describe('RegulatorExportPage', () => {
  it('generic profilda "Regulator Export" nomini va Job ID ustunini ko‘rsatadi', async () => {
    server.use(regulatorJobsHandler, driversListHandler);
    render(renderPage());

    expect(await screen.findByRole('heading', { name: 'Regulator Export' })).toBeInTheDocument();
    expect(await screen.findByText('job-reg-1')).toBeInTheDocument();
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('Roadside inspection, unit 1021')).toBeInTheDocument();
  });

  it('us_fmcsa profilida "FMCSA Report" nomini ko‘rsatadi (F125)', async () => {
    useCompanyStore.getState().setCompany({ regulationProfile: 'us_fmcsa' });
    server.use(regulatorJobsHandler, driversListHandler);
    render(renderPage());

    expect(await screen.findByRole('heading', { name: 'FMCSA Report' })).toBeInTheDocument();
  });

  it('Generate modalida Custom Range tanlanganda From/To maydonlari ko‘rinadi', async () => {
    server.use(regulatorJobsHandler, driversListHandler);
    const user = userEvent.setup();
    render(renderPage());

    await screen.findByText('job-reg-1');
    await user.click(screen.getByRole('button', { name: 'Generate' }));

    expect(screen.queryByRole('button', { name: /^From /i })).not.toBeInTheDocument();

    await user.click(screen.getByRole('combobox', { name: 'Type' }));
    await user.click(screen.getByRole('option', { name: 'Custom Range' }));

    expect(await screen.findByRole('button', { name: /^From /i })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /^To /i })).toBeInTheDocument();
  });

  it('xato bo‘lganda ErrorState ko‘rsatiladi', async () => {
    server.use(regulatorJobsErrorHandler, driversListHandler);
    render(renderPage());

    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });
});
