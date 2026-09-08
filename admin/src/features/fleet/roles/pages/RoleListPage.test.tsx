import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';
import { permissionsListHandler } from '@/mocks/handlers/permissions';
import {
  roleDeleteInUseHandler,
  rolesListHandler,
  roleUpdateHandler,
} from '@/mocks/handlers/roles';
import { server } from '@/test/msw-server';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { PERM } from '@/lib/permissions';

import { RoleListPage } from './RoleListPage';

function renderPage(
  permissions: string[] = [PERM.rolesRead, PERM.rolesCreate, PERM.rolesUpdate, PERM.rolesDelete],
) {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={client}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/roles']}>
            <RoleListPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('RoleListPage', () => {
  it("ro'yxatni ko'rsatadi (tizim + kompaniya rollari)", async () => {
    server.use(rolesListHandler, permissionsListHandler);
    renderPage();

    await waitFor(() => expect(screen.getByText('Administrator')).toBeInTheDocument());
    expect(screen.getByText('Fleet Manager')).toBeInTheDocument();
  });

  it('F92: tizim rol uchun Edit/Delete "disabled" va sabab bilan', async () => {
    server.use(rolesListHandler, permissionsListHandler);
    const user = userEvent.setup();
    renderPage();

    await waitFor(() => expect(screen.getByText('Administrator')).toBeInTheDocument());
    const menuButtons = screen.getAllByRole('button', { name: /actions for/i });
    await user.click(menuButtons[0]!);

    const editItem = screen.getByRole('menuitem', { name: 'Edit' });
    expect(editItem).toBeDisabled();
    expect(editItem).toHaveAttribute('title', expect.stringMatching(/system roles/i));

    const deleteItem = screen.getByRole('menuitem', { name: 'Delete' });
    expect(deleteItem).toBeDisabled();
  });

  it('F90: guruh "Select all" barcha kalitlarni tanlaydi', async () => {
    server.use(rolesListHandler, permissionsListHandler);
    const user = userEvent.setup();
    renderPage();

    await waitFor(() => expect(screen.getByText('Administrator')).toBeInTheDocument());
    await user.click(screen.getByRole('button', { name: /add role/i }));

    await screen.findByText('Units');
    const unitsSelectAll = screen.getAllByLabelText('Select all')[0]!;
    await user.click(unitsSelectAll);

    expect(screen.getByLabelText('View units')).toBeChecked();
    expect(screen.getByLabelText('Import units')).toBeChecked();
  });

  it("F93: 409 ROLE_IN_USE aniq xabar bilan ko'rsatiladi", async () => {
    server.use(rolesListHandler, permissionsListHandler, roleDeleteInUseHandler);
    const user = userEvent.setup();
    renderPage();

    await waitFor(() => expect(screen.getByText('Fleet Manager')).toBeInTheDocument());
    const menuButtons = screen.getAllByRole('button', { name: /actions for/i });
    // ikkinchi qator — kompaniya roli (Fleet Manager, system emas)
    await user.click(menuButtons[1]!);
    await user.click(screen.getByRole('menuitem', { name: 'Delete' }));
    await user.click(screen.getByRole('button', { name: /^confirm$/i }));

    expect(await screen.findByText(/still use this role/i)).toBeInTheDocument();
  });

  it('rolni tahrirlaydi (PATCH /roles/{id})', async () => {
    server.use(rolesListHandler, permissionsListHandler, roleUpdateHandler);
    const user = userEvent.setup();
    renderPage();

    await waitFor(() => expect(screen.getByText('Fleet Manager')).toBeInTheDocument());
    const menuButtons = screen.getAllByRole('button', { name: /actions for/i });
    await user.click(menuButtons[1]!);
    await user.click(screen.getByRole('menuitem', { name: 'Edit' }));

    await screen.findByDisplayValue('Fleet Manager');
    await user.click(screen.getByRole('button', { name: /save changes/i }));

    expect(await screen.findByText(/role updated/i)).toBeInTheDocument();
  });
});
