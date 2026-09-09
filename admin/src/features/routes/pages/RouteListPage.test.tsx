/**
 * RouteListPage — integratsiya testi (MSW): ro'yxat, bo'sh holat va qator
 * amallari (§7.7.3; F118 — qo'lda "Complete" tugmasi yo'q).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PERM } from '@/lib/permissions';
import { routesListEmptyHandler, routesListHandler } from '@/mocks/handlers/routes';
import { server } from '@/test/msw-server';

import { RouteListPage } from './RouteListPage';

function renderPage(
  permissions: readonly string[] = [
    PERM.routesRead,
    PERM.routesCreate,
    PERM.routesUpdate,
    PERM.routesComplete,
    PERM.routesDelete,
  ],
) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/routes']}>
            <RouteListPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('RouteListPage', () => {
  it('renders the route rows', async () => {
    server.use(routesListHandler);
    renderPage();

    expect(await screen.findByText('Dallas, TX')).toBeInTheDocument();
    expect(screen.getByText('Chicago, IL')).toBeInTheDocument();
    expect(screen.getByText('John Miller')).toBeInTheDocument();
  });

  it('shows the empty state when there are no routes', async () => {
    server.use(routesListEmptyHandler);
    renderPage();

    expect(await screen.findByText(/no data found/i)).toBeInTheDocument();
  });

  it('offers "Close as not completed" in row actions and no manual "Complete" (F118)', async () => {
    server.use(routesListHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('Dallas, TX');
    await user.click(screen.getByRole('button', { name: /actions for route/i }));

    expect(await screen.findByText(/close as not completed/i)).toBeInTheDocument();
    expect(screen.queryByRole('menuitem', { name: /^complete$/i })).not.toBeInTheDocument();
  });

  it('does not make rows clickable without tracking.view_live (TD7)', async () => {
    server.use(routesListHandler);
    renderPage([PERM.routesRead]);

    await screen.findByText('Dallas, TX');
    const rows = screen.getAllByRole('row').slice(1);
    for (const row of rows) {
      expect(row).not.toHaveAttribute('tabindex');
    }
  });

  it('makes rows clickable when tracking.view_live is granted (TD7)', async () => {
    server.use(routesListHandler);
    renderPage([PERM.routesRead, PERM.trackingViewLive]);

    await screen.findByText('Dallas, TX');
    const rows = screen.getAllByRole('row').slice(1);
    expect(rows[0]).toHaveAttribute('tabindex', '0');
  });

  it('filters the current page client-side and explains the limit (TD3)', async () => {
    server.use(routesListHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('Dallas, TX');
    expect(screen.getByText(/only the rows loaded on this page/i)).toBeInTheDocument();

    await user.type(screen.getByRole('textbox'), 'zzzz-no-match');
    expect(await screen.findByText(/no data found/i)).toBeInTheDocument();
  });
});
