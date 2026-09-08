/**
 * `useNotificationsRealtime` — global `notifications` WS obunachisi (F156,
 * F143). Kanal protokoli (`auth`/`welcome`/`since`) `src/lib/ws.test.ts` da
 * tekshiriladi — bu yerda faqat **moslashtirish**: kesh yangilanishi
 * (`applyNotificationCreatedEvent`), toast faqat F143 shartida va faqat
 * `notifications.read` ruxsati bo'lganda obuna yoqilishi.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { act, render, renderHook, screen } from '@testing-library/react';
import type { ReactNode } from 'react';
import { afterEach, describe, expect, it, vi } from 'vitest';

import type { RealtimeEvent } from '@/lib/ws';

const subscribeChannelMock =
  vi.fn<
    (
      channel: string,
      filter: unknown,
      onEvent: (event: RealtimeEvent) => void,
      options?: { enabled?: boolean },
    ) => { status: string }
  >();

vi.mock('@/hooks/useChannel', () => ({
  useChannel: (
    channel: string,
    filter: unknown,
    onEvent: (event: RealtimeEvent) => void,
    options?: { enabled?: boolean },
  ) => {
    subscribeChannelMock(channel, filter, onEvent, options);
    return { status: 'live' };
  },
}));

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { notificationsKeys } from '@/api/queries/notifications';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PERM } from '@/lib/permissions';

import { useNotificationsRealtime } from './useNotificationsRealtime';

function wrapper(permissions: readonly string[]) {
  const queryClient = new QueryClient();
  return {
    queryClient,
    Wrapper: ({ children }: { children: ReactNode }) => (
      <QueryClientProvider client={queryClient}>
        <PermissionsProvider permissions={permissions}>
          <ToastProvider>{children}</ToastProvider>
        </PermissionsProvider>
      </QueryClientProvider>
    ),
  };
}

afterEach(() => {
  subscribeChannelMock.mockClear();
});

describe('useNotificationsRealtime', () => {
  it('subscribes to the "notifications" channel only when notifications.read is granted', () => {
    const { Wrapper } = wrapper([PERM.notificationsRead]);
    renderHook(() => useNotificationsRealtime(), { wrapper: Wrapper });

    expect(subscribeChannelMock).toHaveBeenCalledWith(
      'notifications',
      undefined,
      expect.any(Function),
      { enabled: true },
    );
  });

  it('disables the subscription without the notifications.read permission', () => {
    const { Wrapper } = wrapper([]);
    renderHook(() => useNotificationsRealtime(), { wrapper: Wrapper });

    expect(subscribeChannelMock).toHaveBeenCalledWith(
      'notifications',
      undefined,
      expect.any(Function),
      { enabled: false },
    );
  });

  it('updates the unread-count cache on notification_created, replay or not', () => {
    const { Wrapper, queryClient } = wrapper([PERM.notificationsRead]);
    queryClient.setQueryData(notificationsKeys.unreadCount(), 1);
    renderHook(() => useNotificationsRealtime(), { wrapper: Wrapper });

    const onEvent = subscribeChannelMock.mock.calls.at(-1)?.[2];
    onEvent?.({
      type: 'notification_created',
      data: { id: 'n1', alert_type: 'chat_message', read: false },
      replay: true,
    });

    expect(queryClient.getQueryData(notificationsKeys.unreadCount())).toBe(2);
  });

  it('shows a toast for a non-replay critical alert (hos_violation)', () => {
    const { Wrapper } = wrapper([PERM.notificationsRead]);
    render(
      <Wrapper>
        <NotificationsRealtimeHarness />
      </Wrapper>,
    );

    const onEvent = subscribeChannelMock.mock.calls.at(-1)?.[2];
    act(() => {
      onEvent?.({
        type: 'notification_created',
        data: {
          id: 'n2',
          alert_type: 'hos_violation',
          title: '11-hour driving limit exceeded',
          read: false,
        },
        replay: false,
      });
    });

    expect(screen.getByText('11-hour driving limit exceeded')).toBeInTheDocument();
  });

  it('does not toast for a replay event, even if critical', () => {
    const { Wrapper } = wrapper([PERM.notificationsRead]);
    render(
      <Wrapper>
        <NotificationsRealtimeHarness />
      </Wrapper>,
    );

    const onEvent = subscribeChannelMock.mock.calls.at(-1)?.[2];
    act(() => {
      onEvent?.({
        type: 'notification_created',
        data: { id: 'n3', alert_type: 'hos_violation', title: 'Replay violation', read: false },
        replay: true,
      });
    });

    expect(screen.queryByText('Replay violation')).not.toBeInTheDocument();
  });

  it('does not toast for a non-critical alert type (F143)', () => {
    const { Wrapper } = wrapper([PERM.notificationsRead]);
    render(
      <Wrapper>
        <NotificationsRealtimeHarness />
      </Wrapper>,
    );

    const onEvent = subscribeChannelMock.mock.calls.at(-1)?.[2];
    act(() => {
      onEvent?.({
        type: 'notification_created',
        data: { id: 'n4', alert_type: 'chat_message', title: 'New chat message', read: false },
        replay: false,
      });
    });

    expect(screen.queryByText('New chat message')).not.toBeInTheDocument();
  });

  it("toast toshqinini cheklaydi — oynada 3 tadan ortiq toast ko'rsatilmaydi, kesh esa yangilanadi", () => {
    const { Wrapper, queryClient } = wrapper([PERM.notificationsRead]);
    queryClient.setQueryData(notificationsKeys.unreadCount(), 0);
    render(
      <Wrapper>
        <NotificationsRealtimeHarness />
      </Wrapper>,
    );

    const onEvent = subscribeChannelMock.mock.calls.at(-1)?.[2];
    act(() => {
      for (let index = 0; index < 8; index += 1) {
        onEvent?.({
          type: 'notification_created',
          data: {
            id: `flood-${index}`,
            alert_type: 'hos_violation',
            title: `Flood ${index}`,
            read: false,
          },
          replay: false,
        });
      }
    });

    // Kesh har hodisada yangilanadi, toast esa uchinchisidan keyin bostiriladi.
    expect(queryClient.getQueryData(notificationsKeys.unreadCount())).toBe(8);
    expect(screen.getByText('Flood 0')).toBeInTheDocument();
    expect(screen.getByText('Flood 2')).toBeInTheDocument();
    expect(screen.queryByText('Flood 3')).not.toBeInTheDocument();
  });

  it('ignores unrelated event types', () => {
    const { Wrapper, queryClient } = wrapper([PERM.notificationsRead]);
    queryClient.setQueryData(notificationsKeys.unreadCount(), 1);
    renderHook(() => useNotificationsRealtime(), { wrapper: Wrapper });

    const onEvent = subscribeChannelMock.mock.calls.at(-1)?.[2];
    onEvent?.({ type: 'unit_last_state', data: {} });

    expect(queryClient.getQueryData(notificationsKeys.unreadCount())).toBe(1);
  });
});

function NotificationsRealtimeHarness() {
  useNotificationsRealtime();
  return null;
}
