import { act, render, screen } from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import '@/app/i18n';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { useToast } from '@/components/feedback/toast-context';

function Trigger() {
  const toast = useToast();
  return (
    <div>
      <button
        type="button"
        onClick={() => toast.show({ variant: 'success', message: 'Unit 101 created' })}
      >
        success
      </button>
      <button
        type="button"
        onClick={() => toast.show({ variant: 'error', message: 'Save failed' })}
      >
        error
      </button>
      <button
        type="button"
        onClick={() => toast.show({ variant: 'info', message: `info ${Math.random()}` })}
      >
        info
      </button>
    </div>
  );
}

function renderProvider() {
  return render(
    <ToastProvider>
      <Trigger />
    </ToastProvider>,
  );
}

describe('ToastProvider', () => {
  beforeEach(() => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('shows a success toast with role="status" and auto-dismisses after 4s', () => {
    renderProvider();
    act(() => {
      screen.getByRole('button', { name: 'success' }).click();
    });

    expect(screen.getByRole('status')).toHaveTextContent('Unit 101 created');

    act(() => {
      vi.advanceTimersByTime(4_000);
    });
    expect(screen.queryByText('Unit 101 created')).not.toBeInTheDocument();
  });

  it('shows an error toast with role="alert" that requires manual dismissal', () => {
    renderProvider();
    act(() => {
      screen.getByRole('button', { name: 'error' }).click();
    });

    const alert = screen.getByRole('alert');
    expect(alert).toHaveTextContent('Save failed');

    act(() => {
      vi.advanceTimersByTime(20_000);
    });
    expect(screen.getByText('Save failed')).toBeInTheDocument();

    act(() => {
      screen.getByRole('button', { name: 'Dismiss notification' }).click();
    });
    expect(screen.queryByText('Save failed')).not.toBeInTheDocument();
  });

  it('caps visible toasts at 3 and promotes queued ones on dismiss', () => {
    renderProvider();
    const infoButton = screen.getByRole('button', { name: 'info' });

    act(() => {
      infoButton.click();
      infoButton.click();
      infoButton.click();
      infoButton.click();
    });

    expect(screen.getAllByRole('status')).toHaveLength(3);

    act(() => {
      vi.advanceTimersByTime(6_000);
    });
    // First batch of 3 dismisses after 6s; the 4th, queued one becomes visible
    // and is still within its own 6s window.
    expect(screen.getAllByRole('status')).toHaveLength(1);
  });
});
