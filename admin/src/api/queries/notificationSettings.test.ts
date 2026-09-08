/**
 * Notification settings query hooklari — integratsiya testi (MSW orqali,
 * fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  notificationSettingFixture,
  notificationSettingsListErrorHandler,
  notificationSettingsListHandler,
  notificationSettingsUpdateErrorHandler,
  notificationSettingsUpdateHandler,
} from '@/mocks/handlers/notificationSettings';

import {
  isNotificationChannelLocked,
  useNotificationSettingsList,
  useNotificationSettingsUpdate,
} from './notificationSettings';
import { withQueryClient } from './test-utils';

describe('useNotificationSettingsList', () => {
  it('matritsa qatorlarini qaytaradi', async () => {
    server.use(notificationSettingsListHandler);
    const { result } = renderHook(() => useNotificationSettingsList(), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual([
      notificationSettingFixture(),
      notificationSettingFixture({ alert_type: 'eld_disconnected', channels: ['push'] }),
      notificationSettingFixture({ alert_type: 'chat_message', channels: ['push', 'telegram'] }),
    ]);
  });

  it('403 javobida ApiError bilan tugaydi', async () => {
    server.use(notificationSettingsListErrorHandler);
    const { result } = renderHook(() => useNotificationSettingsList(), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(403);
  });
});

describe('useNotificationSettingsUpdate', () => {
  it('muvaffaqiyatli yangilaydi', async () => {
    server.use(notificationSettingsUpdateHandler);
    const { result } = renderHook(() => useNotificationSettingsUpdate(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ settings: [{ alert_type: 'hos_violation', channels: ['push'] }] });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.[0]?.channels).toEqual(['push', 'email', 'sms']);
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(notificationSettingsUpdateErrorHandler);
    const { result } = renderHook(() => useNotificationSettingsUpdate(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ settings: [] });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('isNotificationChannelLocked', () => {
  it('hos_* va eld_* turlarida push kanalini bloklaydi (F148/Q89)', () => {
    expect(isNotificationChannelLocked('hos_violation', 'push')).toBe(true);
    expect(isNotificationChannelLocked('eld_disconnected', 'push')).toBe(true);
  });

  it('boshqa kanal yoki boshqa turda bloklamaydi', () => {
    expect(isNotificationChannelLocked('hos_violation', 'email')).toBe(false);
    expect(isNotificationChannelLocked('chat_message', 'push')).toBe(false);
  });
});
