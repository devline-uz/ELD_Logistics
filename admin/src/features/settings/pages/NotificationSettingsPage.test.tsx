/**
 * NotificationSettingsPage — integratsiya testi (MSW): matritsa render,
 * majburiy (`hos_*`/`eld_*`) katak o'chirilmasligi (F148/Q89), Save faqat
 * o'zgargan qatorlarni yuboradi (8.5).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  notificationSettingsListErrorHandler,
  notificationSettingsListHandler,
  notificationSettingsUpdateHandler,
} from '@/mocks/handlers/notificationSettings';
import { rolesListHandler } from '@/mocks/handlers/roles';
import { PERM, type Permission } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { NotificationSettingsPage } from './NotificationSettingsPage';

const ALL_PERMISSIONS: Permission[] = [
  PERM.notificationSettingsRead,
  PERM.notificationSettingsUpdate,
  PERM.rolesRead,
];

function renderPage(permissions: readonly Permission[] = ALL_PERMISSIONS) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/settings/notifications']}>
            <NotificationSettingsPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('NotificationSettingsPage', () => {
  it('renders the matrix with alert type rows', async () => {
    server.use(notificationSettingsListHandler, rolesListHandler);
    renderPage();

    expect(await screen.findByText('HOS violation')).toBeInTheDocument();
    expect(screen.getByText('ELD disconnected')).toBeInTheDocument();
  });

  it('shows an error state when the list fails to load', async () => {
    server.use(notificationSettingsListErrorHandler, rolesListHandler);
    renderPage();

    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });

  it('keeps the locked push checkbox checked and disabled for hos_* alerts', async () => {
    server.use(notificationSettingsListHandler, rolesListHandler);
    renderPage();

    const row = (await screen.findByText('HOS violation')).closest('tr');
    expect(row).not.toBeNull();
    const pushCheckbox = within(row as HTMLElement).getByRole('checkbox', {
      name: /push: hos violation/i,
    });
    expect(pushCheckbox).toBeChecked();
    expect(pushCheckbox).toBeDisabled();
  });

  it('disables Save until a cell changes, then saves', async () => {
    server.use(
      notificationSettingsListHandler,
      rolesListHandler,
      notificationSettingsUpdateHandler,
    );
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('HOS violation');
    const saveButton = screen.getByRole('button', { name: /save changes/i });
    expect(saveButton).toBeDisabled();

    const chatRow = screen.getByText('Chat message').closest('tr');
    const smsCheckbox = within(chatRow as HTMLElement).getByRole('checkbox', {
      name: /sms: chat message/i,
    });
    await user.click(smsCheckbox);
    expect(saveButton).toBeEnabled();

    await user.click(saveButton);
    expect(await screen.findByRole('status')).toHaveTextContent(/notification settings saved/i);
  });

  it('hides Save without notification_settings.update', async () => {
    server.use(notificationSettingsListHandler, rolesListHandler);
    renderPage([PERM.notificationSettingsRead]);

    await screen.findByText('HOS violation');
    expect(screen.queryByRole('button', { name: /save changes/i })).not.toBeInTheDocument();
  });
});
