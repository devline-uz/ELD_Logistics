/**
 * Notifications — MSW handler'lari (Bosqich 7, fe-testing §MSW). Har endpoint
 * uchun muvaffaqiyat + xato varianti; ro'yxat `{data, meta:{…,unread}}` konverti.
 */
import { http, HttpResponse } from 'msw';

import type { Notification, NotificationReadResult } from '@/api/types';

import { jsonError, url } from './shared';

export function notificationFixture(overrides: Partial<Notification> = {}): Notification {
  return {
    id: '6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f',
    alert_type: 'hos_violation',
    title: '11-hour driving limit exceeded',
    body: 'Driver John Doe exceeded the 11 hour driving limit at 18:05Z.',
    channels: ['push', 'email', 'in_app'],
    entity_type: 'violations',
    entity_id: '1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34',
    read: false,
    sent_at: '2026-09-06T18:05:00Z',
    created_at: '2026-09-06T18:05:00Z',
    ...overrides,
  };
}

export function notificationReadResultFixture(
  overrides: Partial<NotificationReadResult> = {},
): NotificationReadResult {
  return { updated: 1, unread: 3, ...overrides };
}

/** `GET /notifications` — muvaffaqiyatli, 1 o'qilmagan yozuv + belgi. */
export const notificationsListHandler = http.get(url('/notifications'), () =>
  HttpResponse.json({
    data: [notificationFixture()],
    meta: { page: 1, per_page: 25, total: 1, unread: 4 },
  }),
);

/** `GET /notifications` — bo'sh inbox. */
export const notificationsListEmptyHandler = http.get(url('/notifications'), () =>
  HttpResponse.json({ data: [], meta: { page: 1, per_page: 25, total: 0, unread: 0 } }),
);

/** `GET /notifications` — `422` (noto'g'ri `alert_type`). */
export const notificationsListErrorHandler = http.get(url('/notifications'), () =>
  jsonError('VALIDATION_ERROR', 'invalid alert_type filter', 422),
);

/** `PATCH /notifications/{id}/read` — muvaffaqiyatli. */
export const notificationReadHandler = http.patch(url('/notifications/:id/read'), () =>
  HttpResponse.json({ data: notificationReadResultFixture() }),
);

/** `PATCH /notifications/{id}/read` — boshqa foydalanuvchi/kompaniya (`404`, hech qachon `403`). */
export const notificationReadNotFoundHandler = http.patch(url('/notifications/:id/read'), () =>
  jsonError('NOT_FOUND', 'Notification not found', 404),
);

/** `POST /notifications/read-all` — muvaffaqiyatli, belgi nolga tushadi. */
export const notificationsReadAllHandler = http.post(url('/notifications/read-all'), () =>
  HttpResponse.json({ data: notificationReadResultFixture({ updated: 7, unread: 0 }) }),
);

/** `POST /notifications/read-all` — `429`. */
export const notificationsReadAllErrorHandler = http.post(url('/notifications/read-all'), () =>
  jsonError('RATE_LIMITED', 'too many requests', 429),
);

/** Bazaviy to'plam — dev/e2e mock rejimi uchun. */
export const notificationsBaseHandlers = [
  notificationsListHandler,
  notificationReadHandler,
  notificationsReadAllHandler,
];
