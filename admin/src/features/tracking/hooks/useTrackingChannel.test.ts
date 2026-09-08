/**
 * `useTrackingChannel` endi umumiy `useChannel()` ustida yupqa wrapper
 * (bosqich 7 migratsiyasi) — shuning uchun bu yerda faqat **moslashtirish**
 * tekshiriladi (to'g'ri kanal/filtr bilan chaqirilishi, `unit_last_state`
 * hodisasining eski shaklga o'girilishi). Protokolning o'zi (auth/welcome,
 * `since` backfill, FORBIDDEN, ping, visibility, negativ URL testi) —
 * `src/lib/ws.test.ts` da, yagona haqiqat manbaida.
 */
import { renderHook } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';

import type { RealtimeEvent } from '@/lib/ws';

const subscribeChannelMock =
  vi.fn<
    (channel: string, filter: unknown, onEvent: (event: RealtimeEvent) => void) => () => void
  >();

vi.mock('@/hooks/useChannel', () => ({
  useChannel: (channel: string, filter: unknown, onEvent: (event: RealtimeEvent) => void) => {
    subscribeChannelMock(channel, filter, onEvent);
    return { status: 'live' };
  },
}));

import { useTrackingChannel } from './useTrackingChannel';

describe('useTrackingChannel', () => {
  it('subscribes to the "tracking" channel with a unit_ids filter', () => {
    renderHook(() =>
      useTrackingChannel({ enabled: true, unitIds: ['u1', 'u2'], onEvent: () => undefined }),
    );

    expect(subscribeChannelMock).toHaveBeenCalledWith(
      'tracking',
      { unit_ids: ['u1', 'u2'] },
      expect.any(Function),
    );
  });

  it('passes no filter when no unit_ids are given (subscribe to all)', () => {
    renderHook(() => useTrackingChannel({ enabled: true, onEvent: () => undefined }));

    expect(subscribeChannelMock).toHaveBeenCalledWith('tracking', undefined, expect.any(Function));
  });

  it('adapts a raw unit_last_state event to the legacy shape, including replay', () => {
    const onEvent = vi.fn();
    renderHook(() => useTrackingChannel({ enabled: true, onEvent }));

    const forwardedHandler = subscribeChannelMock.mock.calls.at(-1)?.[2];
    forwardedHandler?.({
      type: 'unit_last_state',
      data: { unit_id: 'u1' },
      ts: '2026-09-06T17:55:00Z',
      replay: true,
    });

    expect(onEvent).toHaveBeenCalledWith({
      type: 'unit_last_state',
      data: { unit_id: 'u1' },
      ts: '2026-09-06T17:55:00Z',
      replay: true,
    });
  });

  it('ignores events of a different type', () => {
    const onEvent = vi.fn();
    renderHook(() => useTrackingChannel({ enabled: true, onEvent }));

    const forwardedHandler = subscribeChannelMock.mock.calls.at(-1)?.[2];
    forwardedHandler?.({ type: 'notification_created', data: {} });

    expect(onEvent).not.toHaveBeenCalled();
  });
});
