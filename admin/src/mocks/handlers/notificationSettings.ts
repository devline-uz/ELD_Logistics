/**
 * Notification settings — MSW handler'lari (Bosqich 8.1, fe-testing §MSW).
 */
import { http, HttpResponse } from 'msw';

import type { NotificationSetting } from '@/api/types';

import { jsonError, url } from './shared';

export function notificationSettingFixture(
  overrides: Partial<NotificationSetting> = {},
): NotificationSetting {
  return {
    alert_type: 'hos_violation',
    channels: ['push', 'email'],
    enabled: true,
    recipient_roles: ['6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f'],
    ...overrides,
  };
}

/** `GET /company/notification-settings` — muvaffaqiyatli, 2 turdagi qator. */
export const notificationSettingsListHandler = http.get(url('/company/notification-settings'), () =>
  HttpResponse.json({
    data: [
      notificationSettingFixture(),
      notificationSettingFixture({
        alert_type: 'eld_disconnected',
        channels: ['push'],
      }),
      notificationSettingFixture({
        alert_type: 'chat_message',
        channels: ['push', 'telegram'],
      }),
    ],
  }),
);

/** `GET /company/notification-settings` — `403`. */
export const notificationSettingsListErrorHandler = http.get(
  url('/company/notification-settings'),
  () => jsonError('FORBIDDEN', 'notification_settings.read required', 403),
);

/** `PATCH /company/notification-settings` — muvaffaqiyatli. */
export const notificationSettingsUpdateHandler = http.patch(
  url('/company/notification-settings'),
  () =>
    HttpResponse.json({
      data: [notificationSettingFixture({ channels: ['push', 'email', 'sms'] })],
    }),
);

/** `PATCH /company/notification-settings` — `422` (masalan `settings` bo'sh). */
export const notificationSettingsUpdateErrorHandler = http.patch(
  url('/company/notification-settings'),
  () =>
    jsonError('VALIDATION_ERROR', 'settings must have at least 1 item', 422, [
      { field: 'settings', message: 'required' },
    ]),
);
