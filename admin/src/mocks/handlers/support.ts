/**
 * Support — MSW handler'lari (Bosqich 8.1, fe-testing §MSW).
 */
import { http, HttpResponse } from 'msw';

import type { ListResponse, SupportTicket, SupportTicketMessage } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function supportTicketFixture(overrides: Partial<SupportTicket> = {}): SupportTicket {
  return {
    id: '6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f',
    subject: 'ELD device keeps disconnecting',
    description: 'The device drops the Bluetooth link every few minutes.',
    status: 'new',
    contact_on: 'email',
    attachments: [],
    driver_id: '2b7c4d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f',
    driver_name: 'John Miller',
    created_by: '8d3e2f1a-4b5c-4d6e-9f70-1a2b3c4d5e6f',
    creator_name: 'John Miller',
    message_count: 1,
    created_at: '2026-09-06T09:12:00Z',
    updated_at: '2026-09-06T09:12:00Z',
    ...overrides,
  };
}

export function supportTicketMessageFixture(
  overrides: Partial<SupportTicketMessage> = {},
): SupportTicketMessage {
  return {
    id: '3c9a1f2e-5d4b-4a6c-8e1f-0d2b3a4c5e6f',
    ticket_id: '6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f',
    sender_id: '8d3e2f1a-4b5c-4d6e-9f70-1a2b3c4d5e6f',
    sender_name: 'John Miller',
    text: 'The device drops the Bluetooth link every few minutes.',
    attachments: [],
    created_at: '2026-09-06T09:12:00Z',
    ...overrides,
  };
}

/** `GET /support-tickets` — muvaffaqiyatli. */
export const supportTicketsListHandler = http.get(url('/support-tickets'), () =>
  HttpResponse.json({
    data: [supportTicketFixture()],
    meta: listMeta(),
  } satisfies ListResponse<SupportTicket>),
);

/** `GET /support-tickets` — `422` (noto'g'ri `status`). */
export const supportTicketsListErrorHandler = http.get(url('/support-tickets'), () =>
  jsonError('VALIDATION_ERROR', 'invalid status filter', 422),
);

/** `GET /support-tickets/{id}` — muvaffaqiyatli. */
export const supportTicketDetailHandler = http.get(url('/support-tickets/:id'), ({ params }) =>
  HttpResponse.json({ data: supportTicketFixture({ id: params.id as string }) }),
);

/** `GET /support-tickets/{id}` — boshqa kompaniya/haydovchiniki (`404`, hech qachon `403`). */
export const supportTicketDetailNotFoundHandler = http.get(url('/support-tickets/:id'), () =>
  jsonError('NOT_FOUND', 'support ticket not found', 404),
);

/** `GET /support-tickets/{id}/messages` — muvaffaqiyatli. */
export const supportTicketMessagesHandler = http.get(
  url('/support-tickets/:id/messages'),
  ({ params }) =>
    HttpResponse.json({
      data: [supportTicketMessageFixture({ ticket_id: params.id as string })],
      meta: listMeta(),
    } satisfies ListResponse<SupportTicketMessage>),
);

/** `GET /support-tickets/{id}/messages` — `404`. */
export const supportTicketMessagesNotFoundHandler = http.get(
  url('/support-tickets/:id/messages'),
  () => jsonError('NOT_FOUND', 'support ticket not found', 404),
);

/** `POST /support-tickets/{id}/messages` — `201`. */
export const supportTicketMessageCreateHandler = http.post(
  url('/support-tickets/:id/messages'),
  ({ params }) =>
    HttpResponse.json(
      {
        data: supportTicketMessageFixture({
          id: 'msg-new',
          ticket_id: params.id as string,
          text: 'We shipped a replacement cable today.',
        }),
      },
      { status: 201 },
    ),
);

/** `POST /support-tickets/{id}/messages` — `422` (masalan 4 ta biriktirma). */
export const supportTicketMessageCreateErrorHandler = http.post(
  url('/support-tickets/:id/messages'),
  () =>
    jsonError('VALIDATION_ERROR', 'attachments must have at most 3 items', 422, [
      { field: 'attachments', message: 'too many' },
    ]),
);

/** `PATCH /support-tickets/{id}/status` — muvaffaqiyatli. */
export const supportTicketStatusUpdateHandler = http.patch(
  url('/support-tickets/:id/status'),
  ({ params }) =>
    HttpResponse.json({
      data: supportTicketFixture({ id: params.id as string, status: 'in_progress' }),
    }),
);

/** `PATCH /support-tickets/{id}/status` — `409 INVALID_STATE` (orqaga siljish). */
export const supportTicketStatusUpdateConflictHandler = http.patch(
  url('/support-tickets/:id/status'),
  () => jsonError('INVALID_STATE', 'status can only move forward', 409),
);
