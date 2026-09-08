import { beforeEach, describe, expect, it } from 'vitest';

import { connectionState, useConnectionStore } from './connection';

beforeEach(() => {
  useConnectionStore.setState({ status: 'offline', reconnectAttempt: 0 });
});

describe('connection store', () => {
  it('defaults to offline', () => {
    expect(useConnectionStore.getState().status).toBe('offline');
  });

  it('resets reconnectAttempt when status becomes live', () => {
    connectionState().setReconnectAttempt(3);
    connectionState().setStatus('live');

    expect(useConnectionStore.getState()).toMatchObject({ status: 'live', reconnectAttempt: 0 });
  });

  it('resets reconnectAttempt when status becomes connecting', () => {
    connectionState().setReconnectAttempt(2);
    connectionState().setStatus('connecting');

    expect(useConnectionStore.getState().reconnectAttempt).toBe(0);
  });

  it('keeps reconnectAttempt when moving to paused', () => {
    connectionState().setReconnectAttempt(4);
    connectionState().setStatus('paused');

    expect(useConnectionStore.getState()).toMatchObject({ status: 'paused', reconnectAttempt: 4 });
  });
});
