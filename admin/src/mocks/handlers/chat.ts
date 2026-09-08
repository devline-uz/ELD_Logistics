/**
 * Chat — MSW handler'lari (Bosqich 7, fe-testing §MSW). Har endpoint uchun
 * muvaffaqiyat + xato varianti; xabarlar ro'yxati kursorli `meta` konverti.
 */
import { http, HttpResponse } from 'msw';

import type { ChatMessage, ChatReadResult, ChatThread } from '@/api/types';

import { jsonError, url } from './shared';

export function chatMessageFixture(overrides: Partial<ChatMessage> = {}): ChatMessage {
  return {
    id: '6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f',
    driver_id: '1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34',
    sender_id: '3a2b1c0d-9e8f-4a5b-8c7d-6e5f4a3b2c1d',
    sender_side: 'office',
    kind: 'text',
    text: 'Please head to dock 4 after your break.',
    status: 'delivered',
    sent_at: '2026-09-06T18:05:00Z',
    delivered_at: '2026-09-06T18:05:04Z',
    ...overrides,
  };
}

export function chatThreadFixture(overrides: Partial<ChatThread> = {}): ChatThread {
  return {
    driver_id: '1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34',
    driver_name: 'John Doe',
    driver_status: 'active',
    unread_count: 3,
    last_message: chatMessageFixture(),
    ...overrides,
  };
}

export function chatReadResultFixture(overrides: Partial<ChatReadResult> = {}): ChatReadResult {
  return { updated: 1, unread: 0, ...overrides };
}

/** `GET /chat/threads` — muvaffaqiyatli. */
export const chatThreadsListHandler = http.get(url('/chat/threads'), () =>
  HttpResponse.json({ data: [chatThreadFixture()], meta: { page: 1, per_page: 25, total: 1 } }),
);

/** `GET /chat/threads` — bo'sh (haydovchi yo'q). */
export const chatThreadsListEmptyHandler = http.get(url('/chat/threads'), () =>
  HttpResponse.json({ data: [], meta: { page: 1, per_page: 25, total: 0 } }),
);

/** `GET /chat/threads` — `422`. */
export const chatThreadsListErrorHandler = http.get(url('/chat/threads'), () =>
  jsonError('VALIDATION_ERROR', 'invalid pagination', 422),
);

/** `GET /chat/threads/{driver_id}/messages` — bitta sahifa, `has_more: false`. */
export const chatMessagesListHandler = http.get(url('/chat/threads/:driverId/messages'), () =>
  HttpResponse.json({
    data: [chatMessageFixture()],
    meta: { has_more: false, per_page: 50, unread: 1 },
  }),
);

/**
 * `GET /chat/threads/{driver_id}/messages` — kursor bosqichini simulyatsiya
 * qiladi: `before` bo'lmasa yangi sahifa (`has_more: true`), `before` bo'lsa
 * eski sahifa (`has_more: false`). "Load older" oqimini sinash uchun.
 */
export function createChatMessagesCursorHandler() {
  return http.get(url('/chat/threads/:driverId/messages'), ({ request }) => {
    const before = new URL(request.url).searchParams.get('before');
    if (!before) {
      return HttpResponse.json({
        data: [
          chatMessageFixture({
            id: 'msg-2',
            text: 'Newer page message',
            sent_at: '2026-09-06T18:05:00Z',
          }),
        ],
        meta: { has_more: true, next_before: '2026-09-06T18:05:00Z', per_page: 50, unread: 1 },
      });
    }
    return HttpResponse.json({
      data: [
        chatMessageFixture({
          id: 'msg-1',
          text: 'Older page message',
          sent_at: '2026-09-06T17:40:00Z',
        }),
      ],
      meta: { has_more: false, per_page: 50, unread: 0 },
    });
  });
}

/** `GET /chat/threads/{driver_id}/messages` — boshqa haydovchining threadi (`404`). */
export const chatMessagesNotFoundHandler = http.get(url('/chat/threads/:driverId/messages'), () =>
  jsonError('NOT_FOUND', 'Driver not found', 404),
);

/** `POST /chat/threads/{driver_id}/messages` — muvaffaqiyatli yuborish. */
export const chatMessageSendHandler = http.post(
  url('/chat/threads/:driverId/messages'),
  async ({ params, request }) => {
    const body = (await request.json()) as { text?: string; kind?: string };
    return HttpResponse.json(
      {
        data: chatMessageFixture({
          id: 'msg-new',
          driver_id: params.driverId as string,
          text: body.text,
          status: 'sent',
        }),
      },
      { status: 201 },
    );
  },
);

/** `POST /chat/threads/{driver_id}/messages` — haydovchi `DR`da (`409 DRIVING_MODE_BLOCKED`). */
export const chatMessageSendBlockedHandler = http.post(
  url('/chat/threads/:driverId/messages'),
  () => jsonError('DRIVING_MODE_BLOCKED', 'Driver is currently driving', 409),
);

/** `POST /chat/threads/{driver_id}/messages` — `422 MESSAGE_TOO_LONG`. */
export const chatMessageSendValidationErrorHandler = http.post(
  url('/chat/threads/:driverId/messages'),
  () =>
    jsonError('MESSAGE_TOO_LONG', 'validation failed', 422, [
      { field: 'text', message: 'must be at most 2000 characters' },
    ]),
);

/** `POST /chat/messages/{id}/read` — muvaffaqiyatli. */
export const chatMessageAckHandler = http.post(url('/chat/messages/:id/read'), () =>
  HttpResponse.json({ data: chatReadResultFixture() }),
);

/** `POST /chat/messages/{id}/read` — boshqa kompaniyaniki (`404`). */
export const chatMessageAckNotFoundHandler = http.post(url('/chat/messages/:id/read'), () =>
  jsonError('NOT_FOUND', 'Message not found', 404),
);

/** Bazaviy to'plam — dev/e2e mock rejimi uchun. */
export const chatBaseHandlers = [
  chatThreadsListHandler,
  chatMessagesListHandler,
  chatMessageSendHandler,
  chatMessageAckHandler,
];
