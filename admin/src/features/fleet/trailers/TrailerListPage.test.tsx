/**
 * TrailerListPage — integratsiya testi (MSW): ro'yxat, Add forma, xato
 * holati, permission gate (2.7, fe-testing §MSW).
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
  trailerCreateHandler,
  trailersListEmptyHandler,
  trailersListErrorHandler,
  trailersListHandler,
} from '@/mocks/handlers/trailers';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { TrailerListPage } from './TrailerListPage';

function renderPage(permissions: readonly string[] = [PERM.trailersRead, PERM.trailersCreate]) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  function Wrapper(): ReactElement {
    return (
      <QueryClientProvider client={queryClient}>
        <PermissionsProvider permissions={permissions}>
          <ToastProvider>
            <MemoryRouter initialEntries={['/trailers']}>
              <TrailerListPage />
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

describe('TrailerListPage', () => {
  it('renders the trailer list', async () => {
    server.use(trailersListHandler);
    renderPage();

    expect(await screen.findByText('TR-4410')).toBeInTheDocument();
  });

  it('shows the empty state when there are no trailers', async () => {
    server.use(trailersListEmptyHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });

  it('shows an error state with retry on failure', async () => {
    server.use(trailersListErrorHandler);
    renderPage();

    expect(await screen.findByRole('alert')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /try again/i })).toBeInTheDocument();
  });

  it('hides Add Trailer without trailers.create permission', async () => {
    server.use(trailersListHandler);
    renderPage([PERM.trailersRead]);

    await screen.findByText('TR-4410');
    expect(screen.queryByRole('button', { name: /add trailer/i })).not.toBeInTheDocument();
  });

  it('creates a trailer through the Add modal', async () => {
    server.use(trailersListHandler, trailerCreateHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('TR-4410');
    await user.click(screen.getByRole('button', { name: /add trailer/i }));

    const dialog = await screen.findByRole('dialog');
    await user.type(within(dialog).getByLabelText(/number/i), 'TR-5000');
    await user.click(within(dialog).getByRole('button', { name: /create/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/created/i);
  });
});
