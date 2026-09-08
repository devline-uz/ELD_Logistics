/**
 * CompanyHistoryPage — integratsiya testi (MSW): ro'yxat, "Changes" matni,
 * bo'sh/xato holat, `table` filtri `GET /company/history`ga uzatilishi
 * (8.7, F149).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import {
  companyHistoryListEmptyHandler,
  companyHistoryListErrorHandler,
  companyHistoryListHandler,
} from '@/mocks/handlers/company';
import { url } from '@/mocks/handlers/shared';
import { PERM, type Permission } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { CompanyHistoryPage } from './CompanyHistoryPage';

const ALL_PERMISSIONS: Permission[] = [PERM.companyHistoryView];

function renderPage(permissions: readonly Permission[] = ALL_PERMISSIONS) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={permissions}>
        <MemoryRouter initialEntries={['/settings/history']}>
          <CompanyHistoryPage />
        </MemoryRouter>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('CompanyHistoryPage', () => {
  it('renders the history row with editor, change description and date', async () => {
    server.use(companyHistoryListHandler);
    renderPage();

    expect(await screen.findByText('Jane Doe')).toBeInTheDocument();
    expect(screen.getByText(/updated timezone/i)).toBeInTheDocument();
  });

  it('shows the empty state', async () => {
    server.use(companyHistoryListEmptyHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });

  it('shows an error state when the journal fails to load', async () => {
    server.use(companyHistoryListErrorHandler);
    renderPage();

    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });

  it('sends the "table" filter to GET /company/history', async () => {
    const { http, HttpResponse } = await import('msw');
    let capturedTable: string | null = null;
    server.use(
      http.get(url('/company/history'), ({ request }) => {
        capturedTable = new URL(request.url).searchParams.get('table');
        return HttpResponse.json({ data: [], meta: { page: 1, per_page: 25, total: 0 } });
      }),
    );
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('No Data Found');
    await user.type(screen.getByLabelText(/^table$/i), 'branches');

    await waitFor(() => expect(capturedTable).toBe('branches'), { timeout: 2000 });
  });
});
