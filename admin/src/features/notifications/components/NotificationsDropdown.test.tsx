/**
 * `NotificationsDropdown` — header qo'ng'iroq dropdown'i (7.8): badge,
 * ro'yxat (loading/empty/error), `Mark all as read`, `entity_type` bo'yicha
 * navigatsiya (`View` bosilganda).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { http, HttpResponse } from 'msw';

import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  notificationReadResultFixture,
  notificationsListEmptyHandler,
  notificationsListErrorHandler,
  notificationsListHandler,
  notificationsReadAllHandler,
} from '@/mocks/handlers/notifications';
import { url } from '@/mocks/handlers/shared';
import { server } from '@/test/msw-server';

import { NotificationsDropdown } from './NotificationsDropdown';

function renderDropdown() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <ToastProvider>
        <MemoryRouter initialEntries={['/']}>
          <Routes>
            <Route
              path="/"
              element={
                <div>
                  <NotificationsDropdown />
                  <span>home marker</span>
                </div>
              }
            />
            <Route path="/violations/:id" element={<div>violation detail marker</div>} />
            <Route path="/notifications" element={<div>notifications page marker</div>} />
          </Routes>
        </MemoryRouter>
      </ToastProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('NotificationsDropdown', () => {
  it('shows the unread count badge from meta.unread', async () => {
    server.use(notificationsListHandler);
    renderDropdown();

    expect(await screen.findByText('4')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /4 unread notification/i })).toBeInTheDocument();
  });

  it('opens the panel and lists the latest notifications', async () => {
    server.use(notificationsListHandler);
    const user = userEvent.setup();
    renderDropdown();

    await user.click(await screen.findByRole('button', { name: /unread notification/i }));

    const menu = await screen.findByRole('menu', { name: /notifications/i });
    expect(within(menu).getByText('11-hour driving limit exceeded')).toBeInTheDocument();
  });

  it('shows the empty state when there are no notifications', async () => {
    server.use(notificationsListEmptyHandler);
    const user = userEvent.setup();
    renderDropdown();

    await user.click(await screen.findByRole('button', { name: /notifications/i }));

    expect(await screen.findByText(/all caught up/i)).toBeInTheDocument();
  });

  it('shows an error state with retry when the list fails to load', async () => {
    server.use(notificationsListErrorHandler);
    const user = userEvent.setup();
    renderDropdown();

    await user.click(await screen.findByRole('button', { name: /notifications/i }));

    expect(await screen.findByRole('button', { name: /try again/i })).toBeInTheDocument();
  });

  it('marks all notifications as read and shows a confirmation toast', async () => {
    server.use(notificationsListHandler, notificationsReadAllHandler);
    const user = userEvent.setup();
    renderDropdown();

    await user.click(await screen.findByRole('button', { name: /unread notification/i }));
    await user.click(await screen.findByRole('button', { name: /mark all as read/i }));

    expect(await screen.findByText('All notifications marked as read')).toBeInTheDocument();
  });

  it('marks the item as read and navigates via entity_type on click', async () => {
    server.use(
      notificationsListHandler,
      http.patch(url('/notifications/:id/read'), () =>
        HttpResponse.json({ data: notificationReadResultFixture({ unread: 3 }) }),
      ),
    );
    const user = userEvent.setup();
    renderDropdown();

    await user.click(await screen.findByRole('button', { name: /unread notification/i }));
    await user.click(await screen.findByText('11-hour driving limit exceeded'));

    expect(await screen.findByText('violation detail marker')).toBeInTheDocument();
  });

  it('navigates to the full page via "View all"', async () => {
    server.use(notificationsListHandler);
    const user = userEvent.setup();
    renderDropdown();

    await user.click(await screen.findByRole('button', { name: /unread notification/i }));
    await user.click(await screen.findByRole('menuitem', { name: /view all/i }));

    expect(await screen.findByText('notifications page marker')).toBeInTheDocument();
  });
});
