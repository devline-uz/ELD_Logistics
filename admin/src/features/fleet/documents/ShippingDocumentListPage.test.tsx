/**
 * ShippingDocumentListPage — integratsiya testi (MSW): ro'yxat, Add forma,
 * xato holati, permission gate (2.7, fe-testing §MSW).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import type { ReactElement } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  shippingDocumentCreateHandler,
  shippingDocumentsListEmptyHandler,
  shippingDocumentsListErrorHandler,
  shippingDocumentsListHandler,
} from '@/mocks/handlers/shippingDocuments';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { ShippingDocumentListPage } from './ShippingDocumentListPage';

function renderPage(
  permissions: readonly string[] = [PERM.shippingDocumentsRead, PERM.shippingDocumentsCreate],
) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  function Wrapper(): ReactElement {
    return (
      <QueryClientProvider client={queryClient}>
        <PermissionsProvider permissions={permissions}>
          <ToastProvider>
            <MemoryRouter initialEntries={['/shipping-documents']}>
              <ShippingDocumentListPage />
            </MemoryRouter>
          </ToastProvider>
        </PermissionsProvider>
      </QueryClientProvider>
    );
  }
  return render(<Wrapper />);
}

afterEach(() => {
  server.resetHandlers();
});

describe('ShippingDocumentListPage', () => {
  it('renders the shipping document list', async () => {
    server.use(shippingDocumentsListHandler);
    renderPage();

    expect(await screen.findByText('BOL-99127')).toBeInTheDocument();
  });

  it('shows the empty state when there are no documents', async () => {
    server.use(shippingDocumentsListEmptyHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });

  it('shows an error state with retry on failure', async () => {
    server.use(shippingDocumentsListErrorHandler);
    renderPage();

    expect(await screen.findByRole('alert')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /try again/i })).toBeInTheDocument();
  });

  it('hides Add Document without shipping_documents.create permission', async () => {
    server.use(shippingDocumentsListHandler);
    renderPage([PERM.shippingDocumentsRead]);

    await screen.findByText('BOL-99127');
    expect(screen.queryByRole('button', { name: /add document/i })).not.toBeInTheDocument();
  });

  it('creates a shipping document through the Add modal', async () => {
    server.use(shippingDocumentsListHandler, shippingDocumentCreateHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('BOL-99127');
    await user.click(screen.getByRole('button', { name: /add document/i }));

    const dialog = await screen.findByRole('dialog');
    await user.type(within(dialog).getByLabelText(/number/i), 'BOL-50000');
    await user.click(within(dialog).getByRole('button', { name: /create/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/created/i);
  });
});
