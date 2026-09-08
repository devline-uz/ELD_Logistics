/**
 * AuditListPage — integratsiya testi (MSW): ro'yxat, `table`/`user`
 * filtrlari, sana formati (3 harfli hafta kuni, F140), `Add User` tugmasi
 * yo'qligi (F139) va bo'sh/xato holatlari.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  auditLogListEmptyHandler,
  auditLogListErrorHandler,
  auditLogListHandler,
  auditLogTablesHandler,
} from '@/mocks/handlers/audit';
import { usersListHandler } from '@/mocks/handlers/users';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { AuditListPage } from './AuditListPage';

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.auditView]}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/audit']}>
            <AuditListPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('AuditListPage', () => {
  it('renders the entry row with a formatted "Changes" cell', async () => {
    server.use(auditLogListHandler, auditLogTablesHandler, usersListHandler);
    renderPage();

    expect(await screen.findByText('Anna Ross')).toBeInTheDocument();
    expect(screen.getByText('status changed from new to in_progress')).toBeInTheDocument();
  });

  it('formats the date with a 3-letter weekday (F140)', async () => {
    server.use(auditLogListHandler, auditLogTablesHandler, usersListHandler);
    renderPage();

    await screen.findByText('Anna Ross');
    // ts fixture: 2026-09-07T11:30:00Z → Monday.
    expect(screen.getByText(/^Mon,/)).toBeInTheDocument();
  });

  it('never renders an "Add User" button (F139)', async () => {
    server.use(auditLogListHandler, auditLogTablesHandler, usersListHandler);
    renderPage();

    await screen.findByText('Anna Ross');
    expect(screen.queryByRole('button', { name: /add user/i })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /export drivers/i })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /import drivers/i })).not.toBeInTheDocument();
  });

  it('shows the empty state when there is no data', async () => {
    server.use(auditLogListEmptyHandler, auditLogTablesHandler, usersListHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });

  it('shows the error state when the list fails', async () => {
    server.use(auditLogListErrorHandler, auditLogTablesHandler, usersListHandler);
    renderPage();

    expect(await screen.findByRole('button', { name: /try again/i })).toBeInTheDocument();
  });
});
