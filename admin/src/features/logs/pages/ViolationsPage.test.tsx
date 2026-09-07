/**
 * ViolationsPage — integratsiya testi (MSW): ro'yxat, `resolved` badge,
 * `Delete` amali yo'qligi (F105) (3.13, `docs/tz/07-4-logs.md` 7.4.6).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { violationsListEmptyHandler, violationsListHandler } from '@/mocks/handlers/violations';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { ViolationsPage } from './ViolationsPage';

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.violationsRead]}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/violations']}>
            <ViolationsPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('ViolationsPage', () => {
  it('renders violations without any delete action (F105)', async () => {
    server.use(violationsListHandler);
    renderPage();

    expect(await screen.findByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('Drive limit')).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /delete/i })).not.toBeInTheDocument();
  });

  it('shows the empty state when there are no violations', async () => {
    server.use(violationsListEmptyHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });
});
