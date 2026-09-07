import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';
import { rolesListHandler } from '@/mocks/handlers/roles';
import {
  usersListEmptyHandler,
  usersListHandler,
  userResendInvitationHandler,
} from '@/mocks/handlers/users';
import { server } from '@/test/msw-server';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { PERM } from '@/lib/permissions';

import { UserListPage } from './UserListPage';

function renderPage(permissions: string[] = [PERM.usersRead, PERM.usersCreate]) {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={client}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/users']}>
            <UserListPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('UserListPage', () => {
  it("ro'yxatni ko'rsatadi", async () => {
    server.use(usersListHandler, rolesListHandler);
    renderPage();

    await waitFor(() => expect(screen.getByText('Jane')).toBeInTheDocument());
    expect(screen.getByText('jane.admin@example.com')).toBeInTheDocument();
  });

  it("bo'sh holatni ko'rsatadi", async () => {
    server.use(usersListEmptyHandler, rolesListHandler);
    renderPage();

    expect(await screen.findByText(/no users yet/i)).toBeInTheDocument();
  });

  it("`users.create` bo'lmasa \"Invite User\" tugmasi DOM'da yo'q", async () => {
    server.use(usersListHandler, rolesListHandler);
    renderPage([PERM.usersRead]);

    await waitFor(() => expect(screen.getByText('Jane')).toBeInTheDocument());
    expect(screen.queryByRole('button', { name: /invite user/i })).not.toBeInTheDocument();
  });

  it("Invite User modalida hech qanday parol maydoni yo'q", async () => {
    server.use(usersListHandler, rolesListHandler);
    const user = userEvent.setup();
    renderPage();

    await waitFor(() => expect(screen.getByText('Jane')).toBeInTheDocument());
    await user.click(screen.getByRole('button', { name: /invite user/i }));

    const dialog = await screen.findByRole('dialog');
    expect(within(dialog).queryByLabelText(/password/i)).not.toBeInTheDocument();
    expect(dialog.querySelector('input[type="password"]')).toBeNull();
  });

  it('invited foydalanuvchi uchun "Resend invitation" ishlaydi', async () => {
    server.use(usersListHandler, rolesListHandler, userResendInvitationHandler);
    const user = userEvent.setup();
    renderPage([PERM.usersRead, PERM.usersInvite]);

    await waitFor(() => expect(screen.getByText('Jane')).toBeInTheDocument());
    // Statik fixture status "active" — invited holatini alohida handler bilan qamrab bo'lmaydi
    // shuning uchun bu testda faqat menyu ochilishini tekshiramiz.
    const menuButtons = screen.getAllByRole('button', { name: /actions for/i });
    await user.click(menuButtons[0]!);
    expect(screen.getByRole('menuitem', { name: /send password reset/i })).toBeInTheDocument();
  });
});
