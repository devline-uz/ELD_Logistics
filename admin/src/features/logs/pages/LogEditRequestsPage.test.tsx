/**
 * LogEditRequestsPage — integratsiya testi (MSW): ro'yxat, **F103** (o'z
 * taklifini o'zi tasdiqlay olmaydi — `Approve` yashirin), reject `reason`
 * majburiy (3.11, `docs/tz/07-4-logs.md` 7.4.4).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';

import '@/app/i18n';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  logEditRequestApproveHandler,
  logEditRequestRejectHandler,
  logEditRequestsListHandler,
} from '@/mocks/handlers/logEditRequests';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';
import { useAuthStore } from '@/store/auth-store';

import { LogEditRequestsPage } from './LogEditRequestsPage';

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.logsRead, PERM.logsApproveEdit, PERM.logsRejectEdit]}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/logs/edit-requests']}>
            <LogEditRequestsPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
  useAuthStore.getState().reset();
});

beforeEach(() => {
  useAuthStore.getState().reset();
});

describe('LogEditRequestsPage', () => {
  it("hides Approve for the admin's own request (F103)", async () => {
    // Fixture: `requested_by: 'admin-1'`.
    useAuthStore.setState({ profile: { id: 'admin-1' } });
    server.use(logEditRequestsListHandler);
    renderPage();

    await screen.findByText('John Doe');
    expect(screen.queryByRole('button', { name: /^approve$/i })).not.toBeInTheDocument();
    expect(screen.getByRole('button', { name: /^reject$/i })).toBeInTheDocument();
  });

  it("shows Approve for a different admin's request", async () => {
    useAuthStore.setState({ profile: { id: 'someone-else' } });
    server.use(logEditRequestsListHandler);
    renderPage();

    await screen.findByText('John Doe');
    expect(screen.getByRole('button', { name: /^approve$/i })).toBeInTheDocument();
  });

  it('rejects a request through the reason dialog', async () => {
    useAuthStore.setState({ profile: { id: 'someone-else' } });
    server.use(logEditRequestsListHandler, logEditRequestRejectHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('John Doe');
    await user.click(screen.getByRole('button', { name: /^reject$/i }));

    const dialog = await screen.findByRole('alertdialog');
    await user.type(within(dialog).getByLabelText(/reason/i), 'That was my co-driver');
    await user.click(within(dialog).getByRole('button', { name: /^confirm$/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/rejected/i);
  });

  it('approves a request', async () => {
    useAuthStore.setState({ profile: { id: 'someone-else' } });
    server.use(logEditRequestsListHandler, logEditRequestApproveHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('John Doe');
    await user.click(screen.getByRole('button', { name: /^approve$/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/approved/i);
  });
});
