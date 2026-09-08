/**
 * `NotificationsPage` — `/notifications` (7.8): sana bo'yicha guruhlash,
 * `read`/`alert_type` filtrlari, bitta/hammasi o'qilgan deb belgilash,
 * loading/empty/error holatlari.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  notificationFixture,
  notificationsListEmptyHandler,
  notificationsListErrorHandler,
  notificationsReadAllHandler,
} from '@/mocks/handlers/notifications';
import { url } from '@/mocks/handlers/shared';
import { server } from '@/test/msw-server';

import { NotificationsPage } from './NotificationsPage';

function renderPage(initialEntries: string[] = ['/notifications']) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <ToastProvider>
        <MemoryRouter initialEntries={initialEntries}>
          <Routes>
            <Route path="/notifications" element={<NotificationsPage />} />
            <Route path="/violations/:id" element={<div>violation detail marker</div>} />
          </Routes>
        </MemoryRouter>
      </ToastProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('NotificationsPage', () => {
  it('groups notifications by day (Today / Yesterday / date)', async () => {
    const now = new Date();
    const yesterday = new Date(now.getTime() - 24 * 60 * 60 * 1000).toISOString();

    server.use(
      http.get(url('/notifications'), () =>
        HttpResponse.json({
          data: [
            notificationFixture({ id: 'a', title: 'Today item', created_at: now.toISOString() }),
            notificationFixture({ id: 'b', title: 'Yesterday item', created_at: yesterday }),
          ],
          meta: { page: 1, per_page: 25, total: 2, unread: 2 },
        }),
      ),
    );
    renderPage();

    expect(await screen.findByText('Today')).toBeInTheDocument();
    expect(screen.getByText('Yesterday')).toBeInTheDocument();
    expect(screen.getByText('Today item')).toBeInTheDocument();
    expect(screen.getByText('Yesterday item')).toBeInTheDocument();
  });

  it('shows the empty state when there is no data', async () => {
    server.use(notificationsListEmptyHandler);
    renderPage();

    expect(await screen.findByText('No Data Found')).toBeInTheDocument();
  });

  it('shows an error state with retry when the list fails', async () => {
    server.use(notificationsListErrorHandler);
    renderPage();

    expect(await screen.findByRole('button', { name: /try again/i })).toBeInTheDocument();
  });

  it('sends the read=false filter when "Unread" is selected', async () => {
    const seenReadParams: (string | null)[] = [];
    server.use(
      http.get(url('/notifications'), ({ request }) => {
        seenReadParams.push(new URL(request.url).searchParams.get('read'));
        return HttpResponse.json({
          data: [notificationFixture()],
          meta: { page: 1, per_page: 25, total: 1, unread: 1 },
        });
      }),
    );
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('11-hour driving limit exceeded');
    await user.click(screen.getByLabelText('Status'));
    await user.click(await screen.findByRole('option', { name: 'Unread' }));

    expect(await screen.findByText('11-hour driving limit exceeded')).toBeInTheDocument();
    expect(seenReadParams.at(-1)).toBe('false');
  });

  it('marks all as read and shows a confirmation toast', async () => {
    server.use(
      http.get(url('/notifications'), () =>
        HttpResponse.json({
          data: [notificationFixture()],
          meta: { page: 1, per_page: 25, total: 1, unread: 1 },
        }),
      ),
      notificationsReadAllHandler,
    );
    const user = userEvent.setup();
    renderPage();

    await user.click(await screen.findByRole('button', { name: /mark all as read/i }));

    expect(await screen.findByText('All notifications marked as read')).toBeInTheDocument();
  });

  it('marks an item as read and navigates via entity_type on click', async () => {
    server.use(
      http.get(url('/notifications'), () =>
        HttpResponse.json({
          data: [notificationFixture()],
          meta: { page: 1, per_page: 25, total: 1, unread: 1 },
        }),
      ),
      http.patch(url('/notifications/:id/read'), () =>
        HttpResponse.json({ data: { updated: 1, unread: 0 } }),
      ),
    );
    const user = userEvent.setup();
    renderPage();

    await user.click(await screen.findByText('11-hour driving limit exceeded'));

    expect(await screen.findByText('violation detail marker')).toBeInTheDocument();
  });

  it('shows the filtered empty state and offers "Clear filters"', async () => {
    server.use(
      http.get(url('/notifications'), ({ request }) => {
        const readParam = new URL(request.url).searchParams.get('read');
        return HttpResponse.json({
          data: readParam ? [] : [notificationFixture()],
          meta: { page: 1, per_page: 25, total: readParam ? 0 : 1, unread: 1 },
        });
      }),
    );
    renderPage(['/notifications?read=read']);

    expect(await screen.findByText('No results')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /clear filters/i })).toBeInTheDocument();
  });
});
