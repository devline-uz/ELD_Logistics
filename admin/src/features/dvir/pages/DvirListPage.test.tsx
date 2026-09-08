/**
 * DvirListPage — integratsiya testi (MSW): ro'yxat, 6 holat badge'i,
 * `Pending certification` tabi, `out_of_service` banneri (F108) va
 * **F107** — admin DVIR yaratmaydi (hech qanday `Add`/`Generate` tugmasi yo'q).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { driversListHandler } from '@/mocks/handlers/drivers';
import {
  dvirListEmptyHandler,
  dvirListErrorHandler,
  dvirListHandler,
  dvirPendingCertificationHandler,
} from '@/mocks/handlers/dvir';
import { unitsListHandler } from '@/mocks/handlers/units';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { DvirListPage } from './DvirListPage';

// Modul fragmenti markaziy `en.json` ga bosqich oxirida birlashtiriladi.

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.dvirRead, PERM.dvirExport]}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/dvir']}>
            <DvirListPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('DvirListPage', () => {
  it('renders the report row with its status badge and the out-of-service banner (F108)', async () => {
    server.use(dvirListHandler, unitsListHandler, driversListHandler);
    renderPage();

    expect(await screen.findByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('Submitted - Defects Found')).toBeInTheDocument();
    expect(screen.getByRole('alert')).toHaveTextContent(/out of service/i);
  });

  it('never offers a way to create a DVIR from the admin panel (F107)', async () => {
    server.use(dvirListHandler, unitsListHandler, driversListHandler);
    renderPage();

    await screen.findByText('John Doe');
    expect(
      screen.queryByRole('button', { name: /generate report|add dvir|new dvir/i }),
    ).not.toBeInTheDocument();
    // Dizayndagi "Paste driver/mechanic signature here" formasi ham yo'q.
    expect(screen.queryByText(/paste .*signature/i)).not.toBeInTheDocument();
  });

  it('switches to the Pending certification tab', async () => {
    server.use(
      dvirListHandler,
      dvirPendingCertificationHandler,
      unitsListHandler,
      driversListHandler,
    );
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('Submitted - Defects Found');
    await user.click(screen.getByRole('tab', { name: /pending certification/i }));

    expect(await screen.findByText('Repaired')).toBeInTheDocument();
  });

  it('shows the empty state when there is no data', async () => {
    server.use(dvirListEmptyHandler, unitsListHandler, driversListHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });

  it('shows the error state when the list fails', async () => {
    server.use(dvirListErrorHandler, unitsListHandler, driversListHandler);
    renderPage();

    expect(await screen.findByRole('button', { name: /try again/i })).toBeInTheDocument();
  });
});
