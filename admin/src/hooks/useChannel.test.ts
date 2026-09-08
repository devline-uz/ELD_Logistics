import { renderHook } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';

type SubscribeChannelFn = (
  channel: string,
  filter: unknown,
  onEvent: (event: unknown) => void,
  onError?: (code: string, message?: string) => void,
) => () => void;

const subscribeChannelMock = vi.fn<SubscribeChannelFn>(() => vi.fn());

vi.mock('@/lib/ws', () => ({
  subscribeChannel: (
    channel: string,
    filter: unknown,
    onEvent: (event: unknown) => void,
    onError?: (code: string, message?: string) => void,
  ) => subscribeChannelMock(channel, filter, onEvent, onError),
}));

vi.mock('@/stores/connection', () => ({
  useConnectionStore: (selector: (state: { status: string }) => unknown) =>
    selector({ status: 'live' }),
}));

import { useChannel } from './useChannel';

describe('useChannel', () => {
  it('subscribes on mount and unsubscribes on unmount', () => {
    const unsubscribe = vi.fn();
    subscribeChannelMock.mockReturnValueOnce(unsubscribe);
    const onEvent = vi.fn();

    const { unmount } = renderHook(() => useChannel('tracking', { unit_ids: ['u1'] }, onEvent));

    expect(subscribeChannelMock).toHaveBeenCalledWith(
      'tracking',
      { unit_ids: ['u1'] },
      expect.any(Function),
      expect.any(Function),
    );
    expect(unsubscribe).not.toHaveBeenCalled();

    unmount();
    expect(unsubscribe).toHaveBeenCalledTimes(1);
  });

  it('does not subscribe when disabled', () => {
    subscribeChannelMock.mockClear();
    renderHook(() => useChannel('tracking', undefined, vi.fn(), { enabled: false }));

    expect(subscribeChannelMock).not.toHaveBeenCalled();
  });

  it('re-subscribes when the filter content changes', () => {
    subscribeChannelMock.mockClear();
    const unsubscribeA = vi.fn();
    const unsubscribeB = vi.fn();
    subscribeChannelMock.mockReturnValueOnce(unsubscribeA).mockReturnValueOnce(unsubscribeB);

    const { rerender } = renderHook(({ filter }) => useChannel('tracking', filter, vi.fn()), {
      initialProps: { filter: { unit_ids: ['u1'] } },
    });
    expect(subscribeChannelMock).toHaveBeenCalledTimes(1);

    rerender({ filter: { unit_ids: ['u1'] } });
    expect(subscribeChannelMock).toHaveBeenCalledTimes(1); // bir xil mazmun — qayta obuna yo'q
    expect(unsubscribeA).not.toHaveBeenCalled();

    rerender({ filter: { unit_ids: ['u2'] } });
    expect(unsubscribeA).toHaveBeenCalledTimes(1);
    expect(subscribeChannelMock).toHaveBeenCalledTimes(2);
  });

  it('calls the latest onEvent without re-subscribing when the callback identity changes', () => {
    subscribeChannelMock.mockClear();
    let forwardedHandler: ((event: unknown) => void) | undefined;
    subscribeChannelMock.mockImplementationOnce((_channel, _filter, onEvent) => {
      forwardedHandler = onEvent;
      return vi.fn();
    });

    const first = vi.fn();
    const { rerender } = renderHook(({ onEvent }) => useChannel('tracking', undefined, onEvent), {
      initialProps: { onEvent: first },
    });

    const second = vi.fn();
    rerender({ onEvent: second });
    expect(subscribeChannelMock).toHaveBeenCalledTimes(1); // callback identitasi obunaga ta'sir qilmaydi

    forwardedHandler?.({ type: 'unit_last_state', data: {} });
    expect(first).not.toHaveBeenCalled();
    expect(second).toHaveBeenCalledTimes(1);
  });
});
