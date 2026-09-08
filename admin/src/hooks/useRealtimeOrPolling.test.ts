import { renderHook } from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { useConnectionStore } from '@/stores/connection';

import { useRealtimeOrPolling } from './useRealtimeOrPolling';

beforeEach(() => {
  vi.useFakeTimers();
  useConnectionStore.setState({ status: 'offline', reconnectAttempt: 0 });
});

afterEach(() => {
  vi.useRealTimers();
});

describe('useRealtimeOrPolling', () => {
  it('polls every 60s while WS is not live', () => {
    const refetch = vi.fn();
    renderHook(() => useRealtimeOrPolling(refetch));

    expect(refetch).not.toHaveBeenCalled();
    vi.advanceTimersByTime(60_000);
    expect(refetch).toHaveBeenCalledTimes(1);
    vi.advanceTimersByTime(60_000);
    expect(refetch).toHaveBeenCalledTimes(2);
  });

  it('stops polling once the connection is live', () => {
    const refetch = vi.fn();
    useConnectionStore.setState({ status: 'live' });
    renderHook(() => useRealtimeOrPolling(refetch));

    vi.advanceTimersByTime(120_000);
    expect(refetch).not.toHaveBeenCalled();
  });

  it('respects a custom interval', () => {
    const refetch = vi.fn();
    renderHook(() => useRealtimeOrPolling(refetch, 5_000));

    vi.advanceTimersByTime(5_000);
    expect(refetch).toHaveBeenCalledTimes(1);
  });
});
