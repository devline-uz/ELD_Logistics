/**
 * InspectionLogsPage — integratsiya testi (MSW, 8.11, §7.12). "Select a
 * driver" bo'sh holati, tanlangan haydovchi bilan roadside oynasi jadvali,
 * kunlar bo'sh/xato holatlari va "Email report" tugmasi ruxsat gate'i.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PERM } from '@/lib/permissions';
import { driversListHandler } from '@/mocks/handlers/drivers';
import {
  inspectionLogsEmptyHandler,
  inspectionLogsErrorHandler,
  inspectionLogsHandler,
} from '@/mocks/handlers/inspection';
import { server } from '@/test/msw-server';

import { InspectionLogsPage } from './InspectionLogsPage';

function renderPage(initialEntry: string, permissions: string[] = [PERM.inspectionView]) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={[initialEntry]}>
            <InspectionLogsPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('InspectionLogsPage', () => {
  it('shows the "select a driver" empty state when no driver is chosen', async () => {
    server.use(driversListHandler);
    renderPage('/inspection');

    expect(await screen.findByText('Select a driver')).toBeInTheDocument();
    expect(
      screen.getByText('Select driver first, to display the data in the table.'),
    ).toBeInTheDocument();
  });

  it('renders the roadside window table once a driver is selected', async () => {
    server.use(driversListHandler, inspectionLogsHandler);
    renderPage('/inspection?driver_id=driver-1&date=2026-09-06');

    expect(await screen.findByText('Ali Karimov')).toBeInTheDocument();
    expect(screen.getByText('Certified')).toBeInTheDocument();
  });

  it('shows the empty state when the report has no days', async () => {
    server.use(driversListHandler, inspectionLogsEmptyHandler);
    renderPage('/inspection?driver_id=driver-1');

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });

  it('shows the error state when the report fails to load', async () => {
    server.use(driversListHandler, inspectionLogsErrorHandler);
    renderPage('/inspection?driver_id=driver-1');

    expect(await screen.findByRole('button', { name: /try again/i })).toBeInTheDocument();
  });

  it('hides "Email report" without inspection.email permission', async () => {
    server.use(driversListHandler, inspectionLogsHandler);
    renderPage('/inspection?driver_id=driver-1', [PERM.inspectionView]);

    await screen.findByText('Ali Karimov');
    expect(screen.queryByRole('button', { name: /email report/i })).not.toBeInTheDocument();
  });

  it('shows "Email report" with inspection.email permission', async () => {
    server.use(driversListHandler, inspectionLogsHandler);
    renderPage('/inspection?driver_id=driver-1', [PERM.inspectionView, PERM.inspectionEmail]);

    expect(await screen.findByRole('button', { name: /email report/i })).toBeInTheDocument();
  });
});
