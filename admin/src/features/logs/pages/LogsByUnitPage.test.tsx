/**
 * LogsByUnitPage — integratsiya testi (MSW): jadval, HOS kengaytirilgan
 * ustunlar, xato holati (3.2, `docs/tz/07-4-logs.md` 7.4.1).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { hosSummaryHandler } from '@/mocks/handlers/hos';
import { trackingLiveForbiddenHandler, trackingLiveHandler } from '@/mocks/handlers/logs';
import { violationsListEmptyHandler } from '@/mocks/handlers/violations';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { LogsByUnitPage } from './LogsByUnitPage';

function renderPage(permissions: readonly string[] = [PERM.logsRead, PERM.trackingViewLive]) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/logs/by-unit']}>
            <LogsByUnitPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('LogsByUnitPage', () => {
  it('renders the live tracking rows', async () => {
    server.use(trackingLiveHandler, violationsListEmptyHandler);
    renderPage();

    expect(await screen.findByText('1021')).toBeInTheDocument();
    expect(screen.getByText('John Doe')).toBeInTheDocument();
  });

  it('fetches hos-summary counters only after "Show HOS counters" is clicked', async () => {
    server.use(trackingLiveHandler, violationsListEmptyHandler, hosSummaryHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('1021');
    expect(screen.queryByText('05:00')).not.toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: /show hos counters/i }));

    await waitFor(() => expect(screen.getAllByText('05:00').length).toBeGreaterThan(0));
  });

  it('shows an error state when tracking/live is forbidden', async () => {
    server.use(trackingLiveForbiddenHandler, violationsListEmptyHandler);
    renderPage();

    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });
});
