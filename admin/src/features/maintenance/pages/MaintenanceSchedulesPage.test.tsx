/**
 * Schedule tabi — integratsiya testi (5.6, 5.7, 5.8).
 *
 * Tekshiriladi: ro'yxat, **bo'sh holatda ustunlar o'zgarmasligi** (N11/F109),
 * xato + retry, `maintenance.create` ruxsati bo'lmasa `Add Maintenance`
 * yashirilishi, va jadvaldagi masofa qiymati foydalanuvchi birlik tizimida
 * ko'rsatilishi (5.8).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import type { ReactElement } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PERM } from '@/lib/permissions';
import {
  maintenanceDueListEmptyHandler,
  maintenanceSchedulesListEmptyHandler,
  maintenanceSchedulesListErrorHandler,
  maintenanceSchedulesListHandler,
} from '@/mocks/handlers/maintenance';
import { unitsListHandler } from '@/mocks/handlers/units';
import { useCompanyStore } from '@/store/company-store';
import { server } from '@/test/msw-server';

import { MaintenanceSchedulesPage } from './MaintenanceSchedulesPage';

// Modul fragmenti markaziy `en.json` ga bosqich oxirida qo'shiladi.

function renderPage(
  permissions: readonly string[] = [PERM.maintenanceRead, PERM.maintenanceCreate],
) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  function Wrapper(): ReactElement {
    return (
      <QueryClientProvider client={queryClient}>
        <PermissionsProvider permissions={permissions}>
          <ToastProvider>
            <MemoryRouter initialEntries={['/maintenance/schedules']}>
              <MaintenanceSchedulesPage />
            </MemoryRouter>
          </ToastProvider>
        </PermissionsProvider>
      </QueryClientProvider>
    );
  }
  return render(<Wrapper />);
}

beforeEach(() => {
  window.localStorage.clear();
  useCompanyStore.getState().setCompany({ unitSystem: 'imperial' });
});

afterEach(() => {
  server.resetHandlers();
  useCompanyStore.getState().resetCompany();
});

describe('MaintenanceSchedulesPage', () => {
  it('rejalar ro‘yxatini ko‘rsatadi', async () => {
    server.use(maintenanceSchedulesListHandler, maintenanceDueListEmptyHandler, unitsListHandler);
    renderPage();

    expect(await screen.findByText('Engine oil change')).toBeInTheDocument();
    expect(screen.getByText('Oil Change')).toBeInTheDocument();
  });

  it('masofa qiymatini foydalanuvchi birlik tizimida ko‘rsatadi (5.8)', async () => {
    // Fixture: `interval_unit: km`, `interval_value: 25000`; kompaniya imperial.
    server.use(maintenanceSchedulesListHandler, maintenanceDueListEmptyHandler, unitsListHandler);
    renderPage();

    expect(await screen.findByText('15,534.3 mi')).toBeInTheDocument();
  });

  it('bo‘sh holatda ham xuddi shu ustunlarni ko‘rsatadi (N11/F109)', async () => {
    server.use(
      maintenanceSchedulesListEmptyHandler,
      maintenanceDueListEmptyHandler,
      unitsListHandler,
    );
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
    for (const header of ['Unit #', 'Type', 'Schedule Name', 'Maintenance Frequency', 'Status']) {
      expect(screen.getByRole('columnheader', { name: header })).toBeInTheDocument();
    }
  });

  it('xato holatida retry tugmasi bor', async () => {
    server.use(
      maintenanceSchedulesListErrorHandler,
      maintenanceDueListEmptyHandler,
      unitsListHandler,
    );
    renderPage();

    expect(await screen.findByRole('alert')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /try again/i })).toBeInTheDocument();
  });

  it('maintenance.create ruxsatisiz Add Maintenance yashirin', async () => {
    server.use(maintenanceSchedulesListHandler, maintenanceDueListEmptyHandler, unitsListHandler);
    renderPage([PERM.maintenanceRead]);

    await screen.findByText('Engine oil change');
    await screen.findByText('15,534.3 mi');
    expect(screen.queryByRole('button', { name: /add maintenance/i })).not.toBeInTheDocument();
  });
});
