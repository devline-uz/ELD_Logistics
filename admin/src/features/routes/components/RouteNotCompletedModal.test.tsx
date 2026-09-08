/**
 * RouteNotCompletedModal — `other` sababi tanlanganda `note` majburiy
 * (§7.7.3, `notCompletedSchema`).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { afterEach, describe, expect, it, vi } from 'vitest';

import '@/app/i18n';

import { ToastProvider } from '@/components/feedback/ToastProvider';
import { routeFixture, routeNotCompletedHandler } from '@/mocks/handlers/routes';
import { server } from '@/test/msw-server';

import { RouteNotCompletedModal } from './RouteNotCompletedModal';

function renderModal(onClose = vi.fn()) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  render(
    <QueryClientProvider client={queryClient}>
      <ToastProvider>
        <RouteNotCompletedModal open onClose={onClose} route={routeFixture()} />
      </ToastProvider>
    </QueryClientProvider>,
  );
  return onClose;
}

afterEach(() => {
  server.resetHandlers();
});

describe('RouteNotCompletedModal', () => {
  it('requires a note when the reason is "Other"', async () => {
    const user = userEvent.setup();
    const onClose = renderModal();

    await user.click(screen.getByRole('combobox', { name: /reason/i }));
    await user.click(await screen.findByRole('option', { name: /^other$/i }));
    await user.click(screen.getByRole('button', { name: /close as not completed/i }));

    expect(await screen.findByText(/a note is required/i)).toBeInTheDocument();
    expect(onClose).not.toHaveBeenCalled();
  });

  it('submits when a reason without a note is chosen', async () => {
    server.use(routeNotCompletedHandler);
    const user = userEvent.setup();
    const onClose = renderModal();

    await user.click(screen.getByRole('button', { name: /close as not completed/i }));

    await waitFor(() => expect(onClose).toHaveBeenCalledTimes(1));
  });
});
