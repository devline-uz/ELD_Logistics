/**
 * Due tabi — integratsiya testi (5.6, 5.10).
 *
 * Tekshiriladi: `Remaining Frequency` + `Reminder Sent` ustunlari **bo'sh va
 * to'la holatda bir xil** (N11/F109), `Mark as Complete` modali ochilishi va
 * `Cancel` sabab talab qilishi.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import type { ReactElement } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PERM } from '@/lib/permissions';
import {
  maintenanceCancelHandler,
  maintenanceDueListEmptyHandler,
  maintenanceDueListHandler,
} from '@/mocks/handlers/maintenance';
import { unitsListHandler } from '@/mocks/handlers/units';
import { useCompanyStore } from '@/store/company-store';
import { server } from '@/test/msw-server';

import { MaintenanceDuePage } from './MaintenanceDuePage';

const DUE_COLUMNS = [
  'Unit #',
  'License Plate',
  'Type',
  'Schedule Name',
  'Remaining Frequency',
  'Reminder Sent',
];

function renderPage(
  permissions: readonly string[] = [
    PERM.maintenanceRead,
    PERM.maintenanceComplete,
    PERM.maintenanceCancel,
  ],
) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  function Wrapper(): ReactElement {
    return (
      <QueryClientProvider client={queryClient}>
        <PermissionsProvider permissions={permissions}>
          <ToastProvider>
            <MemoryRouter initialEntries={['/maintenance/due']}>
              <MaintenanceDuePage />
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
  useCompanyStore.getState().setCompany({ unitSystem: 'metric' });
});

afterEach(() => {
  server.resetHandlers();
  useCompanyStore.getState().resetCompany();
});

describe('MaintenanceDuePage', () => {
  it('to‘la holatda Remaining Frequency va Reminder Sent ustunlari bor', async () => {
    server.use(maintenanceDueListHandler, unitsListHandler);
    renderPage();

    expect(await screen.findByText('1021')).toBeInTheDocument();
    await screen.findByText('AA123BB');
    for (const header of DUE_COLUMNS) {
      expect(screen.getByRole('columnheader', { name: header })).toBeInTheDocument();
    }
    // `remaining: 1330`, `interval_unit: km`, kompaniya metric.
    expect(screen.getByText('1,330.0 km')).toBeInTheDocument();
    expect(screen.getByText('Not sent')).toBeInTheDocument();
  });

  it('bo‘sh holatda ustunlar to‘plami o‘zgarmaydi (N11/F109)', async () => {
    server.use(maintenanceDueListEmptyHandler, unitsListHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
    for (const header of DUE_COLUMNS) {
      expect(screen.getByRole('columnheader', { name: header })).toBeInTheDocument();
    }
  });

  it('Cancel sabab kiritilmasa yuborilmaydi, kiritilgach bekor qiladi', async () => {
    server.use(maintenanceDueListHandler, unitsListHandler, maintenanceCancelHandler);
    const user = userEvent.setup();
    renderPage();

    // `License Plate` — `GET /units` javobidan; u kelgach barcha so'rov tugagan.
    await screen.findByText('AA123BB');
    await user.click(screen.getByRole('button', { name: /actions for unit 1021/i }));
    await user.click(await screen.findByRole('menuitem', { name: /^cancel$/i }));

    const dialog = await screen.findByRole('alertdialog');
    await user.click(within(dialog).getByRole('button', { name: /confirm/i }));
    // Sabab bo'sh — dialog ochiq qoladi.
    expect(screen.getByRole('alertdialog')).toBeInTheDocument();

    await user.type(within(dialog).getByLabelText(/reason/i), 'Unit sold');
    await user.click(within(dialog).getByRole('button', { name: /confirm/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/cancelled/i);
  });

  it('Mark as Complete modalini ochadi', async () => {
    server.use(maintenanceDueListHandler, unitsListHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('AA123BB');
    await user.click(screen.getByRole('button', { name: /actions for unit 1021/i }));
    await user.click(await screen.findByRole('menuitem', { name: /mark as complete/i }));

    const dialog = await screen.findByRole('dialog');
    expect(within(dialog).getByText(/mark maintenance as complete/i)).toBeInTheDocument();
    expect(within(dialog).getByText(/pdf, jpg or png, up to 10 mb/i)).toBeInTheDocument();
  });
});
