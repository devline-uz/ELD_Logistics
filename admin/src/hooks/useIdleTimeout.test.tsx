import { act, renderHook } from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { useIdleTimeout } from '@/hooks/useIdleTimeout';

describe('useIdleTimeout', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('warns before the deadline and signs out after it', () => {
    const onTimeout = vi.fn();
    const { result } = renderHook(() =>
      useIdleTimeout({ timeoutMs: 10_000, warningMs: 3_000, onTimeout }),
    );

    expect(result.current.isWarning).toBe(false);

    act(() => {
      vi.advanceTimersByTime(8_000);
    });
    expect(result.current.isWarning).toBe(true);
    expect(onTimeout).not.toHaveBeenCalled();

    act(() => {
      vi.advanceTimersByTime(3_000);
    });
    expect(onTimeout).toHaveBeenCalled();
  });

  it('user activity postpones the deadline', () => {
    const onTimeout = vi.fn();
    const { result } = renderHook(() =>
      useIdleTimeout({ timeoutMs: 10_000, warningMs: 3_000, onTimeout }),
    );

    act(() => {
      vi.advanceTimersByTime(6_000);
      window.dispatchEvent(new KeyboardEvent('keydown', { key: 'a' }));
      vi.advanceTimersByTime(6_000);
    });

    expect(onTimeout).not.toHaveBeenCalled();
    expect(result.current.isWarning).toBe(false);
  });
});
