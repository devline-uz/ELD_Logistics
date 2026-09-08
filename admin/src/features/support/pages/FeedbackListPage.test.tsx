/**
 * FeedbackListPage — integratsiya testi (MSW): ro'yxat, to'liq matn modali
 * (F137), bo'sh va xato holatlari.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { driversListHandler } from '@/mocks/handlers/drivers';
import {
  feedbackListEmptyHandler,
  feedbackListErrorHandler,
  feedbackListHandler,
} from '@/mocks/handlers/feedback';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { FeedbackListPage } from './FeedbackListPage';

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.feedbackRead]}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/feedback']}>
            <FeedbackListPage />
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('FeedbackListPage', () => {
  it('renders the feedback row with driver, rating and truncated text', async () => {
    server.use(feedbackListHandler, driversListHandler);
    renderPage();

    expect(await screen.findByText('John Miller')).toBeInTheDocument();
    expect(screen.getByText('The log screen is much faster now.')).toBeInTheDocument();
  });

  it('opens the full-text modal on row click and has no reply action (F137)', async () => {
    server.use(feedbackListHandler, driversListHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('John Miller');
    await user.click(screen.getByText('The log screen is much faster now.'));

    expect(await screen.findByRole('dialog')).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /reply/i })).not.toBeInTheDocument();
  });

  it('shows the empty state when there is no data', async () => {
    server.use(feedbackListEmptyHandler, driversListHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });

  it('shows the error state when the list fails', async () => {
    server.use(feedbackListErrorHandler, driversListHandler);
    renderPage();

    expect(await screen.findByRole('button', { name: /try again/i })).toBeInTheDocument();
  });
});
