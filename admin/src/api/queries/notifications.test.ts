/**
 * Notifications query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import type { QueryClient } from '@tanstack/react-query';

import { server } from '@/test/msw-server';
import {
  notificationFixture,
  notificationReadHandler,
  notificationReadNotFoundHandler,
  notificationsListEmptyHandler,
  notificationsListErrorHandler,
  notificationsListHandler,
  notificationsReadAllHandler,
} from '@/mocks/handlers/notifications';

import {
  applyNotificationCreatedEvent,
  notificationsKeys,
  useNotificationRead,
  useNotificationsList,
  useNotificationsReadAll,
  useNotificationsUnreadCount,
} from './notifications';
import { createTestQueryClient, withQueryClient } from './test-utils';

describe('useNotificationsList', () => {
  it("ro'yxatni {data, meta:{…,unread}} shaklida qaytaradi", async () => {
    server.use(notificationsListHandler);
    const { result } = renderHook(() => useNotificationsList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([notificationFixture()]);
    expect(result.current.data?.meta?.unread).toBe(4);
  });

  it("bo'sh inboxni qaytaradi", async () => {
    server.use(notificationsListEmptyHandler);
    const { result } = renderHook(() => useNotificationsList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([]);
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(notificationsListErrorHandler);
    const { result } = renderHook(() => useNotificationsList({ alert_type: 'chat_message' }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useNotificationsUnreadCount', () => {
  it('faqat `meta.unread`ni qaytaradi', async () => {
    server.use(notificationsListHandler);
    const { result } = renderHook(() => useNotificationsUnreadCount(), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toBe(4);
  });
});

describe('useNotificationRead', () => {
  it("bitta yozuvni o'qilgan deb belgilaydi va belgi hisoblagichini yangilaydi", async () => {
    server.use(notificationReadHandler);
    const client = createTestQueryClient();
    client.setQueryData(notificationsKeys.unreadCount(), 4);
    const { result } = renderHook(() => useNotificationRead(), {
      wrapper: withQueryClient(client),
    });

    result.current.mutate('notif-1');

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(client.getQueryData(notificationsKeys.unreadCount())).toBe(3);
  });

  it('boshqa foydalanuvchi/kompaniya yozuvi uchun 404 qaytaradi', async () => {
    server.use(notificationReadNotFoundHandler);
    const { result } = renderHook(() => useNotificationRead(), { wrapper: withQueryClient() });

    result.current.mutate('notif-999');

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(404);
  });
});

describe('useNotificationsReadAll', () => {
  it("butun inboxni o'qilgan deb belgilaydi, belgi 0ga tushadi", async () => {
    server.use(notificationsReadAllHandler);
    const { result } = renderHook(() => useNotificationsReadAll(), { wrapper: withQueryClient() });

    result.current.mutate();

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.unread).toBe(0);
  });
});

describe('applyNotificationCreatedEvent', () => {
  it("o'qilmagan yangi bildirishnoma kelganda belgi hisoblagichini oshiradi", () => {
    const queryClient: QueryClient = createTestQueryClient();
    queryClient.setQueryData(notificationsKeys.unreadCount(), 2);

    applyNotificationCreatedEvent(queryClient, notificationFixture({ read: false }));

    expect(queryClient.getQueryData(notificationsKeys.unreadCount())).toBe(3);
  });

  it("o'qilgan holatda kelgan hodisa belgini oshirmaydi", () => {
    const queryClient: QueryClient = createTestQueryClient();
    queryClient.setQueryData(notificationsKeys.unreadCount(), 2);

    applyNotificationCreatedEvent(queryClient, notificationFixture({ read: true }));

    expect(queryClient.getQueryData(notificationsKeys.unreadCount())).toBe(2);
  });
});
