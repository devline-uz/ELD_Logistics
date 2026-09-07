import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';
import {
  driverCreateHandler,
  driversListEmptyHandler,
  driversListErrorHandler,
  driversListHandler,
} from '@/mocks/handlers/drivers';
import { usersListHandler } from '@/mocks/handlers/users';
import { server } from '@/test/msw-server';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { PERM } from '@/lib/permissions';

import { DriverListPage } from './DriverListPage';

function renderPage(permissions: string[] = [PERM.driversRead, PERM.driversCreate]) {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={client}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/drivers']}>
            <DriverListPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('DriverListPage', () => {
  it("ro'yxatni ko'rsatadi va ustunlarda haydovchi ma'lumotini chizadi", async () => {
    server.use(driversListHandler, usersListHandler);
    renderPage();

    await waitFor(() => expect(screen.getByText('John')).toBeInTheDocument());
    expect(screen.getByText('Doe')).toBeInTheDocument();
    expect(screen.getByText('jdoe')).toBeInTheDocument();
  });

  it("bo'sh holatni ko'rsatadi", async () => {
    server.use(driversListEmptyHandler, usersListHandler);
    renderPage();

    expect(await screen.findByText(/no drivers yet/i)).toBeInTheDocument();
  });

  it("xato holatida qayta urinish tugmasini ko'rsatadi", async () => {
    server.use(driversListErrorHandler, usersListHandler);
    renderPage();

    expect(await screen.findByRole('alert')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /try again/i })).toBeInTheDocument();
  });

  it("`drivers.create` bo'lmasa \"Add Driver\" tugmasi DOM'da yo'q", async () => {
    server.use(driversListHandler, usersListHandler);
    renderPage([PERM.driversRead]);

    await waitFor(() => expect(screen.getByText('John')).toBeInTheDocument());
    expect(screen.queryByRole('button', { name: /add driver/i })).not.toBeInTheDocument();
  });

  it("Add Driver modalida hech qanday parol maydoni yo'q", async () => {
    server.use(driversListHandler, usersListHandler, driverCreateHandler);
    const user = userEvent.setup();
    renderPage();

    await waitFor(() => expect(screen.getByText('John')).toBeInTheDocument());
    await user.click(screen.getByRole('button', { name: /add driver/i }));

    const dialog = await screen.findByRole('dialog');
    expect(within(dialog).queryByLabelText(/password/i)).not.toBeInTheDocument();
    expect(dialog.querySelector('input[type="password"]')).toBeNull();
  });
});
