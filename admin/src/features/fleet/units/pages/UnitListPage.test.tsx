/**
 * UnitListPage — integratsiya testi (MSW): ro'yxat, filtr, Add forma, xato
 * holati, permission gate (2.2, fe-testing §MSW).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import type { ReactElement } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { eldDevicesListEmptyHandler } from '@/mocks/handlers/eldDevices';
import {
  unitCreateHandler,
  unitCreateValidationErrorHandler,
  unitsListEmptyHandler,
  unitsListErrorHandler,
  unitsListHandler,
} from '@/mocks/handlers/units';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { UnitListPage } from './UnitListPage';

// jsdom `Element.prototype.scrollIntoView` yo'q — `applyServerErrors` (shared,
// `components/form/`) chaqiradi. Repo-wide polyfill hali qo'shilmagan (W9
// hisobotida qayd etiladi); shu yerda faqat shu test faylini
// unhandled-rejection'dan himoya qilish uchun mahalliy stub.
if (!Element.prototype.scrollIntoView) {
  Element.prototype.scrollIntoView = () => undefined;
}

function renderPage(permissions: readonly string[] = [PERM.unitsRead, PERM.unitsCreate]) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  function Wrapper(): ReactElement {
    return (
      <QueryClientProvider client={queryClient}>
        <PermissionsProvider permissions={permissions}>
          <ToastProvider>
            <MemoryRouter initialEntries={['/units']}>
              <UnitListPage />
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

describe('UnitListPage', () => {
  it('renders the unit list with its columns', async () => {
    server.use(unitsListHandler);
    renderPage();

    expect(await screen.findByText('1021')).toBeInTheDocument();
    expect(screen.getByRole('columnheader', { name: /unit #/i })).toBeInTheDocument();
    expect(screen.getByRole('columnheader', { name: /make & model/i })).toBeInTheDocument();
  });

  it('shows the empty state when the filtered list has no rows', async () => {
    server.use(unitsListEmptyHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });

  it('shows an error state with retry when the list fails to load', async () => {
    server.use(unitsListErrorHandler);
    renderPage();

    expect(await screen.findByRole('alert')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /try again/i })).toBeInTheDocument();
  });

  it('hides the Add Unit button without units.create permission', async () => {
    server.use(unitsListHandler);
    renderPage([PERM.unitsRead]);

    await screen.findByText('1021');
    expect(screen.queryByRole('button', { name: /add unit/i })).not.toBeInTheDocument();
  });

  it('creates a unit through the Add modal and shows a success toast', async () => {
    server.use(unitsListHandler, unitCreateHandler, eldDevicesListEmptyHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('1021');
    await user.click(screen.getByRole('button', { name: /add unit/i }));

    const dialog = await screen.findByRole('dialog');
    await user.type(within(dialog).getByLabelText(/unit #/i), '2050');
    await user.type(within(dialog).getByLabelText(/^make/i), 'Volvo');
    await user.type(within(dialog).getByLabelText(/^model/i), 'VNL');
    await user.type(within(dialog).getByLabelText(/license plate number/i), 'XYZ123');
    await user.click(within(dialog).getByRole('button', { name: /create/i }));

    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument());
    expect(await screen.findByRole('status')).toHaveTextContent(/created/i);
  });

  it('surfaces server validation errors on the Add form', async () => {
    server.use(unitsListHandler, unitCreateValidationErrorHandler, eldDevicesListEmptyHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('1021');
    await user.click(screen.getByRole('button', { name: /add unit/i }));

    const dialog = await screen.findByRole('dialog');
    await user.type(within(dialog).getByLabelText(/unit #/i), '2050');
    await user.type(within(dialog).getByLabelText(/^make/i), 'Volvo');
    await user.type(within(dialog).getByLabelText(/^model/i), 'VNL');
    await user.type(within(dialog).getByLabelText(/license plate number/i), 'XYZ123');
    await user.click(within(dialog).getByRole('button', { name: /create/i }));

    expect(await within(dialog).findByText(/required/i)).toBeInTheDocument();
    expect(screen.getByRole('dialog')).toBeInTheDocument();
  });
});
