/**
 * CompanySettingsPage — integratsiya testi (MSW): forma render, oddiy
 * saqlash, `unit_system`/`regulation_profile` o'zgarganda F145 tasdiq
 * dialogi, xato holati, `company.update` ruxsatisiz Save yashirilishi (8.2).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { act, render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  companyGetErrorHandler,
  companyGetHandler,
  companyUpdateHandler,
  companyUpdateMetricHandler,
} from '@/mocks/handlers/company';
import { useUnitSystem } from '@/hooks/useUnitSystem';
import { PERM, type Permission } from '@/lib/permissions';
import { server } from '@/test/msw-server';
import { DEFAULT_COMPANY_CONTEXT, useCompanyStore } from '@/store/company-store';

import { CompanySettingsPage } from './CompanySettingsPage';

const ALL_PERMISSIONS: Permission[] = [PERM.companyRead, PERM.companyUpdate];

/** Panel bo'ylab boshqa joyda masofa ko'rsatadigan probe — F145 reformat testi uchun. */
function DistanceProbe() {
  const { formatDistance } = useUnitSystem();
  return <span data-testid="distance-probe">{formatDistance(1609.344)}</span>;
}

function renderPage(
  permissions: readonly Permission[] = ALL_PERMISSIONS,
  { withProbe = false }: { withProbe?: boolean } = {},
) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/settings/company']}>
            {withProbe ? <DistanceProbe /> : null}
            <CompanySettingsPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
  act(() => {
    useCompanyStore.setState({ company: DEFAULT_COMPANY_CONTEXT });
  });
});

describe('CompanySettingsPage', () => {
  it('renders the company profile fields', async () => {
    server.use(companyGetHandler);
    renderPage();

    expect(await screen.findByDisplayValue('Onebook Logistics LLC')).toBeInTheDocument();
    expect(screen.getByDisplayValue('ops@onebook.example')).toBeInTheDocument();
  });

  it('shows an error state when the company fails to load', async () => {
    server.use(companyGetErrorHandler);
    renderPage();

    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });

  it('hides Save without company.update', async () => {
    server.use(companyGetHandler);
    renderPage([PERM.companyRead]);

    await screen.findByDisplayValue('Onebook Logistics LLC');
    expect(screen.queryByRole('button', { name: /save changes/i })).not.toBeInTheDocument();
  });

  it('saves a simple field change without a confirmation dialog', async () => {
    server.use(companyGetHandler, companyUpdateHandler);
    const user = userEvent.setup();
    renderPage();

    const nameInput = await screen.findByDisplayValue('Onebook Logistics LLC');
    await user.clear(nameInput);
    await user.type(nameInput, 'Onebook Logistics Inc');
    await user.tab();

    await user.click(screen.getByRole('button', { name: /save changes/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/company profile saved/i);
    expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument();
  });

  it('asks for confirmation before saving a unit_system change (F145)', async () => {
    server.use(companyGetHandler, companyUpdateHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByDisplayValue('Onebook Logistics LLC');
    const unitSystemSelect = screen.getByRole('combobox', { name: /unit system/i });
    await user.click(unitSystemSelect);
    await user.click(await screen.findByRole('option', { name: 'Metric' }));

    await user.click(screen.getByRole('button', { name: /save changes/i }));

    const dialog = await screen.findByRole('alertdialog');
    expect(dialog).toHaveTextContent(/this changes date formats and units/i);

    await user.click(within(dialog).getByRole('button', { name: /^confirm$/i }));
    expect(await screen.findByRole('status')).toHaveTextContent(/company profile saved/i);
  });

  it('asks for confirmation before saving a regulation_profile change (F145)', async () => {
    server.use(companyGetHandler, companyUpdateHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByDisplayValue('Onebook Logistics LLC');
    const profileSelect = screen.getByRole('combobox', { name: /regulation profile/i });
    await user.click(profileSelect);
    await user.click(await screen.findByRole('option', { name: 'Generic' }));

    await user.click(screen.getByRole('button', { name: /save changes/i }));

    const dialog = await screen.findByRole('alertdialog');
    expect(dialog).toHaveTextContent(/this changes date formats and units/i);

    await user.click(within(dialog).getByRole('button', { name: /^confirm$/i }));
    expect(await screen.findByRole('status')).toHaveTextContent(/company profile saved/i);
  });

  it('changes nothing when the format confirmation dialog is cancelled', async () => {
    // No companyUpdateHandler registered: an unexpected PATCH fails the test
    // (msw-server onUnhandledRequest: 'error'), proving Cancel never saves.
    server.use(companyGetHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByDisplayValue('Onebook Logistics LLC');
    const unitSystemSelect = screen.getByRole('combobox', { name: /unit system/i });
    await user.click(unitSystemSelect);
    await user.click(await screen.findByRole('option', { name: 'Metric' }));

    await user.click(screen.getByRole('button', { name: /save changes/i }));
    const dialog = await screen.findByRole('alertdialog');

    await user.click(within(dialog).getByRole('button', { name: /^cancel$/i }));

    expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument();
    expect(screen.queryByRole('status')).not.toBeInTheDocument();
    expect(useCompanyStore.getState().company.unitSystem).toBe('imperial');
  });

  it('reformats distance values shown elsewhere in the panel after confirming unit_system (F145)', async () => {
    server.use(companyGetHandler, companyUpdateMetricHandler);
    const user = userEvent.setup();
    renderPage(ALL_PERMISSIONS, { withProbe: true });

    await screen.findByDisplayValue('Onebook Logistics LLC');
    expect(screen.getByTestId('distance-probe')).toHaveTextContent('1.0 mi');

    const unitSystemSelect = screen.getByRole('combobox', { name: /unit system/i });
    await user.click(unitSystemSelect);
    await user.click(await screen.findByRole('option', { name: 'Metric' }));

    await user.click(screen.getByRole('button', { name: /save changes/i }));
    const dialog = await screen.findByRole('alertdialog');
    await user.click(within(dialog).getByRole('button', { name: /^confirm$/i }));

    await screen.findByRole('status');
    expect(screen.getByTestId('distance-probe')).toHaveTextContent('1.6 km');
  });
});
