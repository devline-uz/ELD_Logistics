/**
 * ChatPage — integratsiya testi (MSW):
 * - threadlar ro'yxati + tanlash
 * - kursorli yuklash (`before`) — "Load older messages" eski sahifani qo'shadi
 * - optimistik yuborish + xato bo'lganda "yuborilmadi" holati (qayta urinish)
 * - `IntersectionObserver` bilan o'qilgan belgisi (guruhlangan, debounce)
 * - WS `chat_message` hodisasida yangi xabar keshni yangilaydi
 * - `409 DRIVING_MODE_BLOCKED` aniq xabar bilan ko'rsatiladi
 * - fayl biriktirish: MIME rad etilishi
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { act, render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PERM, type Permission } from '@/lib/permissions';
import {
  chatMessageFixture,
  chatMessageSendBlockedHandler,
  chatMessageSendHandler,
  chatMessageSendValidationErrorHandler,
  chatMessagesListHandler,
  chatThreadFixture,
  chatThreadsListHandler,
  createChatMessagesCursorHandler,
} from '@/mocks/handlers/chat';
import { http, HttpResponse } from 'msw';
import { server } from '@/test/msw-server';
import { url } from '@/mocks/handlers/shared';

import type { ChatMessageEvent, ChatMessageReadEvent } from '../hooks/useChatChannel';
import { ChatPage } from './ChatPage';

const DRIVER_ID = '1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34';
const ALL_PERMISSIONS: Permission[] = [PERM.chatRead, PERM.chatSend];

interface CapturedChannel {
  onMessage: (event: ChatMessageEvent) => void;
  onMessageRead: (event: ChatMessageReadEvent) => void;
}

let capturedChannel: CapturedChannel | undefined;

vi.mock('../hooks/useChatChannel', () => ({
  useChatChannel: (options: CapturedChannel) => {
    capturedChannel = options;
    return { status: 'live' };
  },
}));

class MockIntersectionObserver {
  static instances: MockIntersectionObserver[] = [];
  callback: IntersectionObserverCallback;
  observed: Element[] = [];

  constructor(callback: IntersectionObserverCallback) {
    this.callback = callback;
    MockIntersectionObserver.instances.push(this);
  }

  observe(el: Element) {
    this.observed.push(el);
  }

  unobserve() {
    /* no-op */
  }

  disconnect() {
    /* no-op */
  }

  takeRecords(): IntersectionObserverEntry[] {
    return [];
  }

  trigger(el: Element) {
    this.callback(
      [{ isIntersecting: true, target: el } as IntersectionObserverEntry],
      this as unknown as IntersectionObserver,
    );
  }
}

function renderChatPage(
  permissions: readonly Permission[] = ALL_PERMISSIONS,
  initialEntry = '/chat',
) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={[initialEntry]}>
            <Routes>
              <Route path="/chat" element={<ChatPage />} />
            </Routes>
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

async function selectFirstThread() {
  const threadButton = await screen.findByRole('button', { name: /John Doe/ });
  await userEvent.click(threadButton);
}

beforeEach(() => {
  capturedChannel = undefined;
  MockIntersectionObserver.instances = [];
  vi.stubGlobal('IntersectionObserver', MockIntersectionObserver);
});

afterEach(() => {
  server.resetHandlers();
  vi.unstubAllGlobals();
  vi.restoreAllMocks();
});

describe('ChatPage', () => {
  it('renders the thread list and shows the conversation after selecting a driver', async () => {
    server.use(chatThreadsListHandler, chatMessagesListHandler);
    renderChatPage();

    await selectFirstThread();

    expect(await screen.findAllByText('John Doe')).not.toHaveLength(0);
    const log = await screen.findByRole('log');
    expect(within(log).getByText('Please head to dock 4 after your break.')).toBeInTheDocument();
  });

  it('loads an older page of messages via the cursor without discarding the newer page', async () => {
    server.use(chatThreadsListHandler, createChatMessagesCursorHandler());
    renderChatPage();

    await selectFirstThread();

    expect(await screen.findByText('Newer page message')).toBeInTheDocument();
    const loadOlder = await screen.findByRole('button', { name: 'Load older messages' });
    await userEvent.click(loadOlder);

    expect(await screen.findByText('Older page message')).toBeInTheDocument();
    expect(screen.getByText('Newer page message')).toBeInTheDocument();
  });

  it('shows a message as "not sent" with a retry option when sending fails', async () => {
    server.use(
      chatThreadsListHandler,
      chatMessagesListHandler,
      chatMessageSendValidationErrorHandler,
    );
    renderChatPage();
    await selectFirstThread();

    const textarea = await screen.findByLabelText('Message');
    await userEvent.type(textarea, 'Hello there');
    await userEvent.click(screen.getByRole('button', { name: 'Send message' }));

    expect(await screen.findByText('Hello there')).toBeInTheDocument();
    const log = await screen.findByRole('log');
    expect(within(log).getAllByText('Message could not be sent.').length).toBeGreaterThan(0);
    expect(within(log).getByRole('button', { name: 'Retry' })).toBeInTheDocument();

    server.use(chatThreadsListHandler, chatMessagesListHandler, chatMessageSendHandler);
    await userEvent.click(within(log).getByRole('button', { name: 'Retry' }));

    await waitFor(() =>
      expect(within(log).queryAllByText('Message could not be sent.')).toHaveLength(0),
    );
  });

  it('shows a clear message for a 409 DRIVING_MODE_BLOCKED response', async () => {
    server.use(chatThreadsListHandler, chatMessagesListHandler, chatMessageSendBlockedHandler);
    renderChatPage();
    await selectFirstThread();

    const textarea = await screen.findByLabelText('Message');
    await userEvent.type(textarea, 'Please stop at dock 4');
    await userEvent.click(screen.getByRole('button', { name: 'Send message' }));

    const matches = await screen.findAllByText(
      'The driver is currently driving; the message will be delivered but not shown until they stop.',
    );
    expect(matches.length).toBeGreaterThan(0);
  });

  it('acknowledges an unread incoming message once it becomes visible (grouped, debounced)', async () => {
    const ackSpy = vi.fn();
    server.use(
      chatThreadsListHandler,
      http.get(url('/chat/threads/:driverId/messages'), () =>
        HttpResponse.json({
          data: [
            chatMessageFixture({
              id: 'driver-msg-1',
              sender_side: 'driver',
              status: 'delivered',
              text: 'On my way',
            }),
          ],
          meta: { has_more: false, per_page: 50, unread: 1 },
        }),
      ),
      http.post(url('/chat/messages/:id/read'), ({ params }) => {
        ackSpy(params.id);
        return HttpResponse.json({ data: { updated: 1, unread: 0 } });
      }),
    );
    renderChatPage();
    await selectFirstThread();

    const bubble = await screen.findByText('On my way');
    const target = bubble.closest('[data-message-id]');
    expect(target).not.toBeNull();

    const observer = MockIntersectionObserver.instances.find((instance) =>
      instance.observed.includes(target as Element),
    );
    expect(observer).toBeDefined();
    observer?.trigger(target as Element);

    await waitFor(() => expect(ackSpy).toHaveBeenCalledWith('driver-msg-1'), { timeout: 2000 });
    expect(ackSpy).toHaveBeenCalledTimes(1);
  });

  it('applies a chat_message WS event to the open thread', async () => {
    server.use(chatThreadsListHandler, chatMessagesListHandler);
    renderChatPage();
    await selectFirstThread();

    const log = await screen.findByRole('log');
    within(log).getByText('Please head to dock 4 after your break.');

    act(() => {
      capturedChannel?.onMessage({
        type: 'chat_message',
        data: chatMessageFixture({
          id: 'ws-msg-1',
          driver_id: DRIVER_ID,
          sender_side: 'driver',
          text: 'Live update via WS',
        }),
        replay: false,
      });
    });

    expect(await within(log).findByText('Live update via WS')).toBeInTheDocument();
  });

  it('shows a toast for a WS message from a driver whose thread is not open', async () => {
    server.use(
      http.get(url('/chat/threads'), () =>
        HttpResponse.json({
          data: [
            chatThreadFixture({ driver_id: DRIVER_ID, driver_name: 'John Doe' }),
            chatThreadFixture({ driver_id: 'other-driver', driver_name: 'Jane Smith' }),
          ],
          meta: { page: 1, per_page: 25, total: 2 },
        }),
      ),
      chatMessagesListHandler,
    );
    renderChatPage();
    await selectFirstThread();

    act(() => {
      capturedChannel?.onMessage({
        type: 'chat_message',
        data: chatMessageFixture({
          id: 'ws-msg-2',
          driver_id: 'other-driver',
          sender_side: 'driver',
          text: 'Message from another driver',
        }),
        replay: false,
      });
    });

    expect(await screen.findByText('New message from Jane Smith')).toBeInTheDocument();
  });

  it('rejects an attachment with a disallowed MIME type before uploading', async () => {
    server.use(chatThreadsListHandler, chatMessagesListHandler);
    renderChatPage();
    await selectFirstThread();

    await userEvent.click(screen.getByRole('button', { name: 'Attach a file' }));

    const fileInput = document.querySelector('input[type="file"]');
    expect(fileInput).not.toBeNull();

    const file = new File(['hello'], 'notes.txt', { type: 'text/plain' });
    // `accept` atributi brauzer fayl tanlagichini cheklaydi, lekin haqiqiy
    // MIME tekshiruvi komponent ichida (`FileUpload`) amalga oshadi — shu
    // yo'lni sinash uchun `applyAccept: false` bilan sun'iy ravishda mos
    // kelmaydigan faylni tanlaymiz (user-event v14 avtomatik filtrlaydi).
    const user = userEvent.setup({ applyAccept: false });
    await user.upload(fileInput as HTMLInputElement, file);

    const dropzone = screen.getByRole('presentation');
    expect(await within(dropzone).findByRole('alert')).toHaveTextContent(
      /This file type is not supported/i,
    );
  });
});
