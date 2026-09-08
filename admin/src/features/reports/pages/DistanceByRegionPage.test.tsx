/**
 * Distance by Region — integratsiya testi (Bosqich 6.3, §7.8.2): ekran nomi (F122),
 * KPI, tab almashinuvi, filtr, xato holati.
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
import {
  reportsDistanceByRegionErrorHandler,
  reportsDistanceByRegionHandler,
} from '@/mocks/handlers/reports';
import { unitsListHandler } from '@/mocks/handlers/units';
import { useCompanyStore } from '@/store/company-store';
import { server } from '@/test/msw-server';

import { DistanceByRegionPage } from './DistanceByRegionPage';

function renderPage(): ReactElement {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return (
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.reportsRead, PERM.reportsExport]}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/reports/distance-by-region']}>
            <DistanceByRegionPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>
  );
}

beforeEach(() => {
  useCompanyStore.getState().setCompany({ unitSystem: 'metric', region: 'US' });
});

afterEach(() => {
  server.resetHandlers();
  useCompanyStore.getState().resetCompany();
});

describe('DistanceByRegionPage', () => {
  it('generic profilda "Distance by Region" nomini ko‘rsatadi va ma’lumot yuklaydi', async () => {
    server.use(reportsDistanceByRegionHandler, unitsListHandler);
    render(renderPage());

    expect(await screen.findByRole('heading', { name: 'Distance by Region' })).toBeInTheDocument();
    expect(await screen.findByText('Illinois')).toBeInTheDocument();
    // Ikkinchi (parallel) so'rov — `GET /units` (VIN join) — ham hal bo'lishini kutamiz,
    // aks holda test tugagach kelgan javob `act()`dan tashqarida holatni yangilaydi.
    expect(await screen.findByText('1FUJGLDR9CLBP8834')).toBeInTheDocument();
  });

  it('us_fmcsa profilida "IFTA Report" nomini ko‘rsatadi (F122)', async () => {
    useCompanyStore.getState().setCompany({ unitSystem: 'metric', regulationProfile: 'us_fmcsa' });
    server.use(reportsDistanceByRegionHandler, unitsListHandler);
    render(renderPage());

    expect(await screen.findByRole('heading', { name: 'IFTA Report' })).toBeInTheDocument();
    expect(await screen.findByText('1FUJGLDR9CLBP8834')).toBeInTheDocument();
  });

  it('Regions tabiga o‘tganda "Total distance" ustuni ko‘rinadi', async () => {
    server.use(reportsDistanceByRegionHandler, unitsListHandler);
    const user = userEvent.setup();
    render(renderPage());

    await screen.findByText('1FUJGLDR9CLBP8834');
    await user.click(screen.getByRole('tab', { name: 'Regions' }));

    expect(await screen.findByRole('columnheader', { name: 'Total distance' })).toBeInTheDocument();
    // Mode almashgach yangi so'rov (`mode=regions_only`) qatori qayta ko'rinishini kutamiz —
    // aks holda test tugagach kelgan javob `act()`dan tashqarida holatni yangilaydi.
    expect(await screen.findByText('Illinois')).toBeInTheDocument();
  });

  it('xato bo‘lganda ErrorState ko‘rsatiladi', async () => {
    server.use(reportsDistanceByRegionErrorHandler, unitsListHandler);
    const user = userEvent.setup();
    render(renderPage());

    expect(await screen.findByRole('alert')).toBeInTheDocument();
    // `GET /units` (parallel so'rov) ham hal bo'lishini kutamiz.
    await user.click(screen.getByRole('combobox', { name: 'Unit' }));
    expect(await screen.findByRole('option', { name: '1021' })).toBeInTheDocument();
  });
});
