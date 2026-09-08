/**
 * DefectTypesPage — integratsiya testi (MSW): ro'yxat, yaratish, standart
 * (`is_system`) bandda amal menyusi yo'qligi va `defect_types.create`
 * ruxsatisiz `Add` tugmasi yashirilishi (5.12, §7.6.1).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  defectTypeCreateHandler,
  defectTypeFixture,
  defectTypeUpdateHandler,
  defectTypesListEmptyHandler,
  defectTypesListHandler,
} from '@/mocks/handlers/defectTypes';
import { url } from '@/mocks/handlers/shared';
import { PERM, type Permission } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { DefectTypesPage } from './DefectTypesPage';

const ALL_PERMISSIONS: Permission[] = [
  PERM.defectTypesRead,
  PERM.defectTypesCreate,
  PERM.defectTypesUpdate,
];

function renderPage(permissions: readonly Permission[] = ALL_PERMISSIONS) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/settings/defect-types']}>
            <DefectTypesPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('DefectTypesPage', () => {
  it('renders the catalogue row with its badges', async () => {
    server.use(defectTypesListHandler);
    renderPage();

    expect(await screen.findByText('Brakes (Service)')).toBeInTheDocument();
    expect(screen.getByText('Truck')).toBeInTheDocument();
  });

  it('offers no row action for a standard (is_system) defect type', async () => {
    server.use(defectTypesListHandler);
    renderPage();

    await screen.findByText('Brakes (Service)');
    expect(screen.queryByRole('button', { name: /more actions/i })).not.toBeInTheDocument();
  });

  it('creates a company defect type', async () => {
    const { http, HttpResponse } = await import('msw');
    server.use(
      http.get(url('/defect-types'), () =>
        HttpResponse.json({
          data: [defectTypeFixture({ id: 'dt-2', name: 'Mirrors', is_system: false })],
          meta: { page: 1, per_page: 25, total: 1 },
        }),
      ),
      defectTypeCreateHandler,
    );
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('Mirrors');
    await user.click(screen.getByRole('button', { name: /add defect type/i }));

    const modal = await screen.findByRole('dialog', { name: /add defect type/i });
    await user.type(within(modal).getByLabelText(/name/i), 'Wipers');
    await user.click(within(modal).getByRole('button', { name: /^create$/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/wipers created/i);
  });

  it('deactivates a company defect type through the confirmation dialog', async () => {
    const { http, HttpResponse } = await import('msw');
    server.use(
      http.get(url('/defect-types'), () =>
        HttpResponse.json({
          data: [defectTypeFixture({ id: 'dt-2', name: 'Mirrors', is_system: false })],
          meta: { page: 1, per_page: 25, total: 1 },
        }),
      ),
      defectTypeUpdateHandler,
    );
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('Mirrors');
    await user.click(screen.getByRole('button', { name: /more actions/i }));
    await user.click(await screen.findByRole('menuitem', { name: /deactivate/i }));

    const confirm = await screen.findByRole('alertdialog');
    await user.click(within(confirm).getByRole('button', { name: /^confirm$/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/deactivated/i);
  });

  it('hides Add without the defect_types.create permission', async () => {
    server.use(defectTypesListHandler);
    renderPage([PERM.defectTypesRead]);

    await screen.findByText('Brakes (Service)');
    expect(screen.queryByRole('button', { name: /add defect type/i })).not.toBeInTheDocument();
  });

  it('shows the empty state', async () => {
    server.use(defectTypesListEmptyHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });
});
