/**
 * EldDeviceListPage — integratsiya testi (MSW): ro'yxat, filtr, Add forma,
 * xato holati, permission gate (2.6, fe-testing §MSW).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import type { ReactElement } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  eldDeviceCreateHandler,
  eldDevicesListEmptyHandler,
  eldDevicesListErrorHandler,
  eldDevicesListHandler,
} from '@/mocks/handlers/eldDevices';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { EldDeviceListPage } from './EldDeviceListPage';

function renderPage(permissions: readonly string[] = [PERM.eldDevicesRead, PERM.eldDevicesCreate]) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  function Wrapper(): ReactElement {
    return (
      <QueryClientProvider client={queryClient}>
        <PermissionsProvider permissions={permissions}>
          <ToastProvider>
            <MemoryRouter initialEntries={['/eld-devices']}>
              <EldDeviceListPage />
            </MemoryRouter>
          </ToastProvider>
        </PermissionsProvider>
      </QueryClientProvider>
    );
  }
  return render(<Wrapper />);
}

afterEach(() => {
  server.resetHandlers();
});

describe('EldDeviceListPage', () => {
  it('renders the device list', async () => {
    server.use(eldDevicesListHandler);
    renderPage();

    expect(await screen.findByText('ELD-000123')).toBeInTheDocument();
    expect(screen.getByRole('columnheader', { name: /serial/i })).toBeInTheDocument();
  });

  it('shows the empty state when there are no devices', async () => {
    server.use(eldDevicesListEmptyHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });

  it('shows an error state with retry on failure', async () => {
    server.use(eldDevicesListErrorHandler);
    renderPage();

    expect(await screen.findByRole('alert')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /try again/i })).toBeInTheDocument();
  });

  it('hides Register device without eld_devices.create permission', async () => {
    server.use(eldDevicesListHandler);
    renderPage([PERM.eldDevicesRead]);

    await screen.findByText('ELD-000123');
    expect(screen.queryByRole('button', { name: /register device/i })).not.toBeInTheDocument();
  });

  it('registers a device through the Add modal', async () => {
    server.use(eldDevicesListHandler, eldDeviceCreateHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('ELD-000123');
    await user.click(screen.getByRole('button', { name: /register device/i }));

    const dialog = await screen.findByRole('dialog');
    await user.type(within(dialog).getByLabelText(/^serial/i), 'ELD-999999');
    await user.type(within(dialog).getByLabelText(/^vendor/i), 'Samsara');
    await user.click(within(dialog).getByRole('button', { name: /create/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/registered/i);
  });
});
