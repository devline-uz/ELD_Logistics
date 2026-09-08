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
});
