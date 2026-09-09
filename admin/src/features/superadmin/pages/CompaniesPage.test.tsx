/**
 * CompaniesPage — integratsiya testi (MSW): ro'yxat, bo'sh holat, yaratish,
 * tahrirlash, obuna holatini yangilash, tenant almashtirish (9.15, §7.14).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  adminCompaniesListEmptyHandler,
  adminCompaniesListHandler,
  adminCompanyCreateHandler,
  adminCompanyFixture,
  adminCompanySubscriptionUpdateHandler,
  adminCompanyUpdateHandler,
} from '@/mocks/handlers/companies';
import { url } from '@/mocks/handlers/shared';
import { server } from '@/test/msw-server';
import { useAuthStore } from '@/store/auth-store';

import { CompaniesPage } from './CompaniesPage';

function renderPage(isSuperAdmin = true) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider isSuperAdmin={isSuperAdmin}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/companies']}>
            <Routes>
              <Route path="/companies" element={<CompaniesPage />} />
              <Route path="/" element={<p>Dashboard stub</p>} />
            </Routes>
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

describe('CompaniesPage', () => {
  it('renders the tenant list', async () => {
    server.use(adminCompaniesListHandler);
    renderPage();

    expect(await screen.findByText('Onebook Logistics LLC')).toBeInTheDocument();
  });

  it('shows the empty state', async () => {
    server.use(adminCompaniesListEmptyHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });

  it('creates a company', async () => {
    const { http, HttpResponse } = await import('msw');
    server.use(
      http.get(url('/companies'), () =>
        HttpResponse.json({ data: [], meta: { page: 1, per_page: 25, total: 0 } }),
      ),
      adminCompanyCreateHandler,
    );
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('No Data Found');
    await user.click(screen.getByRole('button', { name: /add company/i }));

    const modal = await screen.findByRole('dialog', { name: /add company/i });
    await user.type(within(modal).getByLabelText(/company name/i), 'Northside Freight Co');
    await user.type(within(modal).getByLabelText(/^timezone/i), 'America/Chicago');
    await user.type(within(modal).getByLabelText(/first name/i), 'Jane');
    await user.type(within(modal).getByLabelText(/last name/i), 'Doe');
    await user.type(within(modal).getByLabelText(/administrator email/i), 'jane@example.com');
    await user.click(within(modal).getByRole('button', { name: /^create$/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/northside freight co created/i);
  });

  it('edits a company', async () => {
    server.use(adminCompaniesListHandler, adminCompanyUpdateHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('Onebook Logistics LLC');
    await user.click(screen.getByRole('button', { name: /more actions/i }));
    await user.click(await screen.findByRole('menuitem', { name: /^edit$/i }));

    const modal = await screen.findByRole('dialog', { name: /edit company/i });
    const nameInput = within(modal).getByLabelText(/^company name/i);
    await user.clear(nameInput);
    await user.type(nameInput, 'Acme Updated Co');
    await user.click(within(modal).getByRole('button', { name: /save changes/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/acme updated co updated/i);
  });

  it('updates the subscription', async () => {
    server.use(adminCompaniesListHandler, adminCompanySubscriptionUpdateHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('Onebook Logistics LLC');
    await user.click(screen.getByRole('button', { name: /more actions/i }));
    await user.click(await screen.findByRole('menuitem', { name: /subscription/i }));

    const modal = await screen.findByRole('dialog', { name: /subscription/i });
    await user.click(within(modal).getByRole('button', { name: /save changes/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(
      /subscription updated for onebook logistics llc/i,
    );
  });

  it('D54: entering a company sets the tenant context and navigates to the dashboard', async () => {
    server.use(adminCompaniesListHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('Onebook Logistics LLC');
    await user.click(screen.getByRole('button', { name: /more actions/i }));
    await user.click(await screen.findByRole('menuitem', { name: /enter as this company/i }));

    expect(await screen.findByText('Dashboard stub')).toBeInTheDocument();
    expect(useAuthStore.getState().impersonatedCompanyId).toBe(adminCompanyFixture().id);
  });
});
