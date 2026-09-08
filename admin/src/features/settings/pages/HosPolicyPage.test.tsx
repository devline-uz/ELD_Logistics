/**
 * HosPolicyPage — integratsiya testi (MSW): joriy siyosat yuklanishi, preset
 * qo'llash, Publish tasdiq dialogida diff ko'rsatilishi va muvaffaqiyatli
 * chop etish (8.4).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  hosPolicyGetErrorHandler,
  hosPolicyGetHandler,
  hosPolicyPublishErrorHandler,
  hosPolicyPublishHandler,
  hosPolicyVersionsEmptyHandler,
  hosPolicyVersionsHandler,
} from '@/mocks/handlers/hosPolicy';
import { PERM, type Permission } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { HosPolicyPage } from './HosPolicyPage';

const ALL_PERMISSIONS: Permission[] = [PERM.hosPolicyRead, PERM.hosPolicyUpdate];

function renderPage(permissions: readonly Permission[] = ALL_PERMISSIONS) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/settings/hos']}>
            <HosPolicyPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('HosPolicyPage', () => {
  it('renders the current policy', async () => {
    server.use(hosPolicyGetHandler, hosPolicyVersionsHandler);
    renderPage();

    expect(await screen.findByRole('heading', { name: 'HOS Policy' })).toBeInTheDocument();
    expect(screen.getByRole('heading', { name: 'Version history' })).toBeInTheDocument();
  });

  it('shows an error state when the policy fails to load', async () => {
    server.use(hosPolicyGetErrorHandler, hosPolicyVersionsEmptyHandler);
    renderPage();

    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });

  it('shows the version history empty state', async () => {
    server.use(hosPolicyGetHandler, hosPolicyVersionsEmptyHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });

  it('opens the publish dialog with a diff and publishes a new version', async () => {
    server.use(hosPolicyGetHandler, hosPolicyVersionsHandler, hosPolicyPublishHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByRole('heading', { name: 'HOS Policy' });
    await user.click(screen.getByRole('button', { name: /^fmcsa 60\/7$/i }));
    await user.click(screen.getByRole('button', { name: /publish new version/i }));

    const dialog = await screen.findByRole('alertdialog');
    expect(within(dialog).getByText('Cycle days')).toBeInTheDocument();

    await user.click(within(dialog).getByRole('button', { name: /^publish$/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/hos policy published/i);
  });

  it('keeps the draft form values when publish fails', async () => {
    server.use(hosPolicyGetHandler, hosPolicyVersionsHandler, hosPolicyPublishErrorHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByRole('heading', { name: 'HOS Policy' });
    // fmcsa_60_7 preset changes cycle_days 8 -> 7, a plain labelled number input.
    await user.click(screen.getByRole('button', { name: /^fmcsa 60\/7$/i }));
    expect(screen.getByLabelText(/^cycle days/i)).toHaveValue(7);

    await user.click(screen.getByRole('button', { name: /publish new version/i }));
    const dialog = await screen.findByRole('alertdialog');
    await user.click(within(dialog).getByRole('button', { name: /^publish$/i }));

    expect(await screen.findByRole('alert')).toHaveTextContent(
      /effective_from must not be in the past/i,
    );
    // Dialog stays open and the draft (preset) form values are not reset on error.
    expect(dialog).toBeInTheDocument();
    expect(screen.getByLabelText(/^cycle days/i)).toHaveValue(7);
  });

  it('renders version history entries with field label and edited-by name', async () => {
    server.use(hosPolicyGetHandler, hosPolicyVersionsHandler);
    renderPage();

    await screen.findByRole('heading', { name: 'HOS Policy' });
    const historySection = screen
      .getByRole('heading', { name: 'Version history' })
      .closest('section');
    expect(historySection).not.toBeNull();
    expect(within(historySection as HTMLElement).getByText('Drive limit')).toBeInTheDocument();
    expect(within(historySection as HTMLElement).getByText('660')).toBeInTheDocument();
    expect(within(historySection as HTMLElement).getByText('600')).toBeInTheDocument();
    expect(within(historySection as HTMLElement).getByText('Jane Doe')).toBeInTheDocument();
  });

  it('hides the publish action without hos_policy.update', async () => {
    server.use(hosPolicyGetHandler, hosPolicyVersionsHandler);
    renderPage([PERM.hosPolicyRead]);

    await screen.findByRole('heading', { name: 'HOS Policy' });
    expect(screen.queryByRole('button', { name: /publish new version/i })).not.toBeInTheDocument();
    expect(screen.getByText(/read-only access/i)).toBeInTheDocument();
  });
});
