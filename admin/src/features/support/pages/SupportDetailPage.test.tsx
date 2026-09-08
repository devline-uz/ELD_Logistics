/**
 * SupportDetailPage — integratsiya testi (MSW): ticket detali, thread javob
 * yuborish, status o'zgartirish modali va 404 (cross-tenant) holati.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  supportTicketDetailHandler,
  supportTicketDetailNotFoundHandler,
  supportTicketMessageCreateHandler,
  supportTicketMessagesHandler,
  supportTicketStatusUpdateHandler,
} from '@/mocks/handlers/support';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { SupportDetailPage } from './SupportDetailPage';

function renderPage(
  permissions: string[] = [PERM.supportRead, PERM.supportCreate, PERM.supportUpdateStatus],
) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/support/6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f']}>
            <Routes>
              <Route path="/support/:id" element={<SupportDetailPage />} />
            </Routes>
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('SupportDetailPage', () => {
  it('renders the ticket details and thread', async () => {
    server.use(supportTicketDetailHandler, supportTicketMessagesHandler);
    renderPage();

    expect(await screen.findByText('ELD device keeps disconnecting')).toBeInTheDocument();
    expect(screen.getByText('John Miller')).toBeInTheDocument();
    expect(screen.getByText('Email')).toBeInTheDocument();
  });

  it('sends a reply through the thread composer', async () => {
    server.use(
      supportTicketDetailHandler,
      supportTicketMessagesHandler,
      supportTicketMessageCreateHandler,
    );
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('ELD device keeps disconnecting');
    await user.type(screen.getByLabelText('Reply'), 'We shipped a replacement cable today.');
    await user.click(screen.getByRole('button', { name: 'Send' }));

    expect(await screen.findByText('Reply sent')).toBeInTheDocument();
  });

  it('changes the ticket status through the status modal', async () => {
    server.use(
      supportTicketDetailHandler,
      supportTicketMessagesHandler,
      supportTicketStatusUpdateHandler,
    );
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('ELD device keeps disconnecting');
    await user.click(screen.getByRole('button', { name: 'Change status' }));
    await user.click(screen.getByRole('button', { name: 'Save' }));

    expect(await screen.findByText(/status updated/i)).toBeInTheDocument();
  });

  it('shows Not Found for a cross-tenant ticket (never 403)', async () => {
    server.use(supportTicketDetailNotFoundHandler);
    renderPage();

    expect(await screen.findByText(/not found/i)).toBeInTheDocument();
  });
});
