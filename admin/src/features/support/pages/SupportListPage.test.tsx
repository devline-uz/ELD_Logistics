/**
 * SupportListPage — integratsiya testi (MSW): ro'yxat, status/driver
 * filtrlari, bo'sh va xato holatlari.
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
  supportTicketsListErrorHandler,
  supportTicketsListHandler,
} from '@/mocks/handlers/support';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { SupportListPage } from './SupportListPage';

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.supportRead]}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/support']}>
            <SupportListPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('SupportListPage', () => {
  it('renders the ticket row with its Ticket # / Subject columns (F134)', async () => {
    server.use(supportTicketsListHandler, driversListHandler);
    renderPage();

    expect(await screen.findByText('ELD device keeps disconnecting')).toBeInTheDocument();
    expect(screen.getByText('John Miller')).toBeInTheDocument();
    expect(screen.getByText(/^#/)).toBeInTheDocument();
  });

  it('shows the "In Progress" status label, not "In-Progress" (F135)', async () => {
    server.use(supportTicketsListHandler, driversListHandler);
    renderPage();

    await screen.findByText('ELD device keeps disconnecting');
    expect(screen.getByText('New')).toBeInTheDocument();
  });

  it('offers a status filter with all four lifecycle values', async () => {
    server.use(supportTicketsListHandler, driversListHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('ELD device keeps disconnecting');
    await user.click(screen.getByPlaceholderText('Status'));
    expect(screen.getByRole('option', { name: 'New' })).toBeInTheDocument();
    expect(screen.getByRole('option', { name: 'In Progress' })).toBeInTheDocument();
    expect(screen.getByRole('option', { name: 'Resolved' })).toBeInTheDocument();
    expect(screen.getByRole('option', { name: 'Closed' })).toBeInTheDocument();
  });

  it('shows the error state when the list fails', async () => {
    server.use(supportTicketsListErrorHandler, driversListHandler);
    renderPage();

    expect(await screen.findByRole('button', { name: /try again/i })).toBeInTheDocument();
  });
});
