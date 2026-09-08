/**
 * UnassignedDrivingPage — integratsiya testi (MSW): ro'yxat, 8 kun qoidasi
 * (F104), Assign/Annotate amallari (3.12, `docs/tz/07-4-logs.md` 7.4.5).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import type { ListResponse, TrackingUnidentifiedEvent } from '@/api/types';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { driversListHandler } from '@/mocks/handlers/drivers';
import { url } from '@/mocks/handlers/shared';
import {
  unidentifiedAnnotateHandler,
  unidentifiedAssignHandler,
  unidentifiedEventFixture,
  unidentifiedEventsListHandler,
} from '@/mocks/handlers/unidentified';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { UnassignedDrivingPage } from './UnassignedDrivingPage';

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider
        permissions={[PERM.logsAssignUnidentified, PERM.logsAnnotateUnidentified, PERM.logsRead]}
      >
        <ToastProvider>
          <MemoryRouter initialEntries={['/logs/unassigned']}>
            <UnassignedDrivingPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('UnassignedDrivingPage', () => {
  it('renders pending events and flags 8+ day overdue rows (F104)', async () => {
    const overdueHandler = http.get(url('/unidentified-events'), () =>
      HttpResponse.json({
        data: [unidentifiedEventFixture({ pending_days: 9 })],
        meta: { page: 1, per_page: 25, total: 1 },
      } satisfies ListResponse<TrackingUnidentifiedEvent>),
    );
    server.use(overdueHandler, driversListHandler);
    renderPage();

    expect(await screen.findByText('1021')).toBeInTheDocument();
    expect(screen.getByText(/9 days overdue/i)).toBeInTheDocument();
  });

  it('assigns an unassigned block to a driver', async () => {
    server.use(unidentifiedEventsListHandler, driversListHandler, unidentifiedAssignHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('1021');
    await user.click(screen.getByRole('button', { name: /assign to driver/i }));

    const dialog = await screen.findByRole('dialog');
    await user.click(within(dialog).getByRole('combobox', { name: /driver/i }));
    await user.click(await within(dialog).findByRole('option', { name: /john doe/i }));
    await user.type(within(dialog).getByLabelText(/note/i), 'Matches dispatch');
    await user.click(within(dialog).getByRole('button', { name: /^send$/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/sent to the driver/i);
  });

  it('annotates an unassigned block with a reason', async () => {
    server.use(unidentifiedEventsListHandler, unidentifiedAnnotateHandler, driversListHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('1021');
    await user.click(screen.getByRole('button', { name: /^annotate$/i }));

    const dialog = await screen.findByRole('alertdialog');
    await user.type(within(dialog).getByLabelText(/annotation/i), 'Mechanic test drive');
    await user.click(within(dialog).getByRole('button', { name: /^confirm$/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/annotated/i);
  });
});
