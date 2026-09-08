/**
 * `useChatChannel` — moslashtirish testi (protokolning o'zi `src/lib/ws.test.ts` da).
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

import { useChatChannel } from './useChatChannel';

describe('useChatChannel', () => {
  it('subscribes to the "chat" channel without a filter', () => {
    renderHook(() =>
      useChatChannel({ enabled: true, onMessage: () => undefined, onMessageRead: () => undefined }),
    );

    expect(subscribeChannelMock).toHaveBeenCalledWith('chat', undefined, expect.any(Function));
  });

  it('forwards chat_message events', () => {
    const onMessage = vi.fn();
    renderHook(() => useChatChannel({ enabled: true, onMessage, onMessageRead: () => undefined }));

    const handler = subscribeChannelMock.mock.calls.at(-1)?.[2];
    handler?.({ type: 'chat_message', data: { id: 'm1', driver_id: 'd1' }, replay: false });

    expect(onMessage).toHaveBeenCalledWith({
      type: 'chat_message',
      data: { id: 'm1', driver_id: 'd1' },
      replay: false,
    });
  });

  it('forwards chat_message_read events', () => {
    const onMessageRead = vi.fn();
    renderHook(() => useChatChannel({ enabled: true, onMessage: () => undefined, onMessageRead }));

    const handler = subscribeChannelMock.mock.calls.at(-1)?.[2];
    handler?.({ type: 'chat_message_read', data: { id: 'm1', driver_id: 'd1', read_at: 'x' } });

    expect(onMessageRead).toHaveBeenCalledWith({
      type: 'chat_message_read',
      data: { id: 'm1', driver_id: 'd1', read_at: 'x' },
      replay: undefined,
    });
  });

  it('ignores events of a different type', () => {
    const onMessage = vi.fn();
    const onMessageRead = vi.fn();
    renderHook(() => useChatChannel({ enabled: true, onMessage, onMessageRead }));

    const handler = subscribeChannelMock.mock.calls.at(-1)?.[2];
    handler?.({ type: 'notification_created', data: {} });

    expect(onMessage).not.toHaveBeenCalled();
    expect(onMessageRead).not.toHaveBeenCalled();
  });
});
