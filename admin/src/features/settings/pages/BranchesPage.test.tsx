/**
 * BranchesPage — integratsiya testi (MSW): ro'yxat, yaratish, tahrirlash,
 * o'chirish (tasdiq dialogi orqali) + `409 RESOURCE_IN_USE` xato holati,
 * ruxsat holatlari (8.3).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  branchCreateHandler,
  branchDeleteHandler,
  branchDeleteInUseHandler,
  branchesListEmptyHandler,
  branchesListHandler,
  branchUpdateHandler,
} from '@/mocks/handlers/branches';
import { url } from '@/mocks/handlers/shared';
import { PERM, type Permission } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { BranchesPage } from './BranchesPage';

const ALL_PERMISSIONS: Permission[] = [
  PERM.branchesRead,
  PERM.branchesCreate,
  PERM.branchesUpdate,
  PERM.branchesDelete,
];

function renderPage(permissions: readonly Permission[] = ALL_PERMISSIONS) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/settings/branches']}>
            <BranchesPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('BranchesPage', () => {
  it('renders the branch list', async () => {
    server.use(branchesListHandler);
    renderPage();

    expect(await screen.findByText('Dallas Terminal')).toBeInTheDocument();
    expect(screen.getByText('America/Chicago')).toBeInTheDocument();
  });

  it('shows the empty state', async () => {
    server.use(branchesListEmptyHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });

  it('creates a branch', async () => {
    const { http, HttpResponse } = await import('msw');
    server.use(
      http.get(url('/company/branches'), () =>
        HttpResponse.json({ data: [], meta: { page: 1, per_page: 25, total: 0 } }),
      ),
      branchCreateHandler,
    );
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('No Data Found');
    await user.click(screen.getByRole('button', { name: /add branch/i }));

    const modal = await screen.findByRole('dialog', { name: /add branch/i });
    await user.type(within(modal).getByLabelText(/branch name/i), 'Houston Terminal');
    await user.click(within(modal).getByRole('button', { name: /^create$/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/houston terminal created/i);
  });

  it('edits a branch', async () => {
    server.use(branchesListHandler, branchUpdateHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('Dallas Terminal');
    await user.click(screen.getByRole('button', { name: /more actions/i }));
    await user.click(await screen.findByRole('menuitem', { name: /^edit$/i }));

    const modal = await screen.findByRole('dialog', { name: /edit branch/i });
    await user.click(within(modal).getByRole('button', { name: /save changes/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/dallas terminal updated/i);
  });

  it('deletes a branch through the confirmation dialog', async () => {
    server.use(branchesListHandler, branchDeleteHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('Dallas Terminal');
    await user.click(screen.getByRole('button', { name: /more actions/i }));
    await user.click(await screen.findByRole('menuitem', { name: /^delete$/i }));

    const confirm = await screen.findByRole('alertdialog');
    expect(confirm).toHaveTextContent(/cannot be undone/i);
    await user.click(within(confirm).getByRole('button', { name: /^confirm$/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/dallas terminal deleted/i);
  });

  it('shows a specific toast when deleting a branch that has assigned users (409)', async () => {
    server.use(branchesListHandler, branchDeleteInUseHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('Dallas Terminal');
    await user.click(screen.getByRole('button', { name: /more actions/i }));
    await user.click(await screen.findByRole('menuitem', { name: /^delete$/i }));

    const confirm = await screen.findByRole('alertdialog');
    await user.click(within(confirm).getByRole('button', { name: /^confirm$/i }));

    expect(await screen.findByRole('alert')).toHaveTextContent(/assigned users/i);
  });

  it('hides Add without branches.create and hides row actions without update/delete', async () => {
    server.use(branchesListHandler);
    renderPage([PERM.branchesRead]);

    await screen.findByText('Dallas Terminal');
    expect(screen.queryByRole('button', { name: /add branch/i })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /more actions/i })).not.toBeInTheDocument();
  });
});
