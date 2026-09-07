import { act, renderHook } from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { useDelayedLoading } from '@/hooks/useDelayedLoading';

describe('useDelayedLoading', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('stays false before the delay elapses', () => {
    const { result } = renderHook(() => useDelayedLoading(true, 300));
    expect(result.current).toBe(false);

    act(() => {
      vi.advanceTimersByTime(299);
    });
    expect(result.current).toBe(false);
  });

  it('becomes true once the delay elapses while still loading', () => {
    const { result } = renderHook(() => useDelayedLoading(true, 300));
    act(() => {
      vi.advanceTimersByTime(300);
    });
    expect(result.current).toBe(true);
  });

  it('resets to false immediately once loading stops, even mid-delay', () => {
    const { result, rerender } = renderHook(({ loading }) => useDelayedLoading(loading, 300), {
      initialProps: { loading: true },
    });

    act(() => {
      vi.advanceTimersByTime(150);
    });
    rerender({ loading: false });
    expect(result.current).toBe(false);

    act(() => {
      vi.advanceTimersByTime(300);
    });
    expect(result.current).toBe(false);
  });
});
