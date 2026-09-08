/**
 * Chat query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 * Kursorli yuklash (`before`), optimistik yuborish + rollback, o'qilgan
 * belgisi va WS kesh-yangilash yordamchilariga alohida e'tibor.
 */
import { act, renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import type { InfiniteData, QueryClient } from '@tanstack/react-query';

import { server } from '@/test/msw-server';
import {
  chatMessageAckHandler,
  chatMessageFixture,
  chatMessageSendBlockedHandler,
  chatMessageSendHandler,
  chatMessagesListHandler,
  chatMessagesNotFoundHandler,
  chatThreadFixture,
  chatThreadsListErrorHandler,
  chatThreadsListHandler,
  createChatMessagesCursorHandler,
} from '@/mocks/handlers/chat';

import {
  applyChatMessageEvent,
  applyChatMessageReadEvent,
  chatKeys,
  flattenChatMessages,
  useChatMessageAck,
  useChatMessages,
  useChatMessageSend,
  useChatThreadsList,
  type ChatMessagesPage,
} from './chat';
import { createTestQueryClient, withQueryClient } from './test-utils';

const DRIVER_ID = '1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34';

describe('useChatThreadsList', () => {
  it("thread ro'yxatini {data, meta} shaklida qaytaradi", async () => {
    server.use(chatThreadsListHandler);
    const { result } = renderHook(() => useChatThreadsList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([chatThreadFixture()]);
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(chatThreadsListErrorHandler);
    const { result } = renderHook(() => useChatThreadsList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useChatMessages', () => {
  it('bitta sahifani (has_more: false) qaytaradi', async () => {
    server.use(chatMessagesListHandler);
    const { result } = renderHook(() => useChatMessages(DRIVER_ID), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(flattenChatMessages(result.current.data)).toEqual([chatMessageFixture()]);
    expect(result.current.hasNextPage).toBe(false);
  });

  it('`fetchNextPage` — `before` kursori bilan eskiroq sahifani yuklaydi', async () => {
    server.use(createChatMessagesCursorHandler());
    const { result } = renderHook(() => useChatMessages(DRIVER_ID), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.hasNextPage).toBe(true);

    await act(async () => {
      await result.current.fetchNextPage();
    });

    await waitFor(() => expect(result.current.hasNextPage).toBe(false));
    expect(flattenChatMessages(result.current.data)).toHaveLength(2);
  });

  it('boshqa haydovchining threadi uchun 404 qaytaradi', async () => {
    server.use(chatMessagesNotFoundHandler);
    const { result } = renderHook(() => useChatMessages(DRIVER_ID), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(404);
  });
});

describe('useChatMessageSend', () => {
  it('optimistik xabarni darhol qo‘shadi, so‘ng serverdan kelgan bilan almashtiradi', async () => {
    server.use(chatMessagesListHandler, chatMessageSendHandler);
    const client = createTestQueryClient();
    const messages = renderHook(() => useChatMessages(DRIVER_ID), {
      wrapper: withQueryClient(client),
    });
    await waitFor(() => expect(messages.result.current.isSuccess).toBe(true));

    const send = renderHook(() => useChatMessageSend(DRIVER_ID), {
      wrapper: withQueryClient(client),
    });
    act(() => {
      send.result.current.mutate({ kind: 'text', text: 'On my way' });
    });

    await waitFor(() =>
      expect(flattenChatMessages(messages.result.current.data)[0]?.text).toBe('On my way'),
    );
    await waitFor(() => expect(send.result.current.isSuccess).toBe(true));
    expect(flattenChatMessages(messages.result.current.data)[0]?.id).toBe('msg-new');
  });

  it('`409 DRIVING_MODE_BLOCKED` bo‘lsa optimistik xabarni orqaga qaytaradi', async () => {
    server.use(chatMessagesListHandler, chatMessageSendBlockedHandler);
    const client = createTestQueryClient();
    const messages = renderHook(() => useChatMessages(DRIVER_ID), {
      wrapper: withQueryClient(client),
    });
    await waitFor(() => expect(messages.result.current.isSuccess).toBe(true));
    const initialCount = flattenChatMessages(messages.result.current.data).length;

    const send = renderHook(() => useChatMessageSend(DRIVER_ID), {
      wrapper: withQueryClient(client),
    });
    act(() => {
      send.result.current.mutate({ kind: 'text', text: 'Head to dock 4' });
    });

    await waitFor(() => expect(send.result.current.isError).toBe(true));
    expect(send.result.current.error?.code).toBe('DRIVING_MODE_BLOCKED');
    expect(flattenChatMessages(messages.result.current.data)).toHaveLength(initialCount);
  });
});

describe('useChatMessageAck', () => {
  it("xabarni o'qilgan deb belgilaydi", async () => {
    server.use(chatMessagesListHandler, chatMessageAckHandler);
    const client = createTestQueryClient();
    const messages = renderHook(() => useChatMessages(DRIVER_ID), {
      wrapper: withQueryClient(client),
    });
    await waitFor(() => expect(messages.result.current.isSuccess).toBe(true));

    const ack = renderHook(() => useChatMessageAck(), { wrapper: withQueryClient(client) });
    act(() => {
      ack.result.current.mutate({ id: chatMessageFixture().id as string, driverId: DRIVER_ID });
    });

    await waitFor(() => expect(ack.result.current.isSuccess).toBe(true));
    const cached = client.getQueryData<InfiniteData<ChatMessagesPage>>(
      chatKeys.messagesForThread(DRIVER_ID),
    );
    expect(flattenChatMessages(cached)[0]?.status).toBe('read');
  });
});

describe('WS kesh-yangilash yordamchilari', () => {
  it('applyChatMessageEvent — ochiq thread keshiga yangi xabarni qo‘shadi', () => {
    const queryClient: QueryClient = createTestQueryClient();
    queryClient.setQueryData(chatKeys.messagesForThread(DRIVER_ID), {
      pages: [{ data: [chatMessageFixture({ id: 'msg-1' })], meta: { has_more: false } }],
      pageParams: [undefined],
    });

    applyChatMessageEvent(queryClient, chatMessageFixture({ id: 'msg-2', driver_id: DRIVER_ID }));

    const data = queryClient.getQueryData(chatKeys.messagesForThread(DRIVER_ID)) as {
      pages: { data?: { id?: string }[] }[];
    };
    expect(data.pages[0]?.data?.map((m) => m.id)).toEqual(['msg-2', 'msg-1']);
  });

  it('applyChatMessageReadEvent — xabar holatini `read`ga o‘zgartiradi', () => {
    const queryClient: QueryClient = createTestQueryClient();
    queryClient.setQueryData(chatKeys.messagesForThread(DRIVER_ID), {
      pages: [{ data: [chatMessageFixture({ id: 'msg-1', status: 'delivered' })], meta: {} }],
      pageParams: [undefined],
    });

    applyChatMessageReadEvent(queryClient, {
      id: 'msg-1',
      driver_id: DRIVER_ID,
      read_at: '2026-09-06T18:07:11Z',
    });

    const data = queryClient.getQueryData(chatKeys.messagesForThread(DRIVER_ID)) as {
      pages: { data?: { id?: string; status?: string }[] }[];
    };
    expect(data.pages[0]?.data?.[0]?.status).toBe('read');
  });
});
