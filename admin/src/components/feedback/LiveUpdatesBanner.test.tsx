import { act, render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { afterEach, describe, expect, it, vi } from 'vitest';

import { useConnectionStore } from '@/stores/connection';

const reconnectNowMock = vi.fn<() => void>();
vi.mock('@/lib/ws', () => ({
  reconnectNow: (): void => reconnectNowMock(),
}));

import { LiveUpdatesBanner } from './LiveUpdatesBanner';

afterEach(() => {
  act(() => {
    useConnectionStore.setState({ status: 'offline', reconnectAttempt: 0 });
  });
  reconnectNowMock.mockClear();
});

describe('LiveUpdatesBanner', () => {
  it.each(['connecting', 'live', 'offline'] as const)(
    'stays hidden while status is %s',
    (status) => {
      act(() => {
        useConnectionStore.setState({ status });
      });
      render(<LiveUpdatesBanner />);

      expect(screen.queryByRole('status')).not.toBeInTheDocument();
    },
  );

  it('shows the "Live updates paused" banner while reconnecting', () => {
    act(() => {
      useConnectionStore.setState({ status: 'paused', reconnectAttempt: 2 });
    });
    render(<LiveUpdatesBanner />);

    expect(screen.getByRole('status')).toHaveTextContent('Live updates paused');
    expect(screen.getByRole('status')).toHaveTextContent('Attempt 2');
  });

  it('triggers a manual reconnect via the "Retry now" button', async () => {
    act(() => {
      useConnectionStore.setState({ status: 'paused' });
    });
    render(<LiveUpdatesBanner />);

    await userEvent.click(screen.getByRole('button', { name: 'Retry now' }));

    expect(reconnectNowMock).toHaveBeenCalledTimes(1);
  });
});
