/**
 * `useTrackingChannel` — xavfsizlik regressiya testlari (fe-realtime F154,
 * fe-security §11): token URL'da yuborilmaydi, tokensiz ulanilmaydi,
 * logoutda soket yopiladi, `welcome` 10 s ichida kelmasa soket qayta ochiladi.
 */
import { renderHook } from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { endSession, setAccessToken } from '@/api/session';

import { useTrackingChannel } from './useTrackingChannel';

const WS_URL = 'wss://eldapi.test/api/v1/ws';

class FakeWebSocket {
  static instances: FakeWebSocket[] = [];
  static readonly OPEN = 1;

  onopen: (() => void) | null = null;
  onmessage: ((event: { data: string }) => void) | null = null;
  onclose: (() => void) | null = null;
  onerror: (() => void) | null = null;

  sent: string[] = [];
  closed: { code?: number; reason?: string } | null = null;

  constructor(public url: string) {
    FakeWebSocket.instances.push(this);
  }

  send(data: string) {
    this.sent.push(data);
  }

  close(code?: number, reason?: string) {
    this.closed = { code, reason };
    this.onclose?.();
  }

  open() {
    this.onopen?.();
  }
}

beforeEach(() => {
  FakeWebSocket.instances = [];
  vi.stubEnv('VITE_WS_URL', WS_URL);
  vi.stubGlobal('WebSocket', FakeWebSocket);
});

afterEach(() => {
  vi.unstubAllEnvs();
  vi.unstubAllGlobals();
  vi.useRealTimers();
  setAccessToken(null);
});

function renderChannel() {
  return renderHook(() => useTrackingChannel({ enabled: true, onEvent: () => undefined }));
}

describe('useTrackingChannel', () => {
  it('does not open a socket when there is no access token', () => {
    setAccessToken(null);

    renderChannel();

    expect(FakeWebSocket.instances).toHaveLength(0);
  });

  it('never puts the token in the URL and sends it as the first auth frame (F154)', () => {
    setAccessToken('secret-token');

    renderChannel();

    const socket = FakeWebSocket.instances[0]!;
    expect(socket.url).toBe(WS_URL);
    expect(socket.url).not.toMatch(/token|jwt|bearer|authorization|api_key/i);

    socket.open();
    expect(JSON.parse(socket.sent[0]!)).toEqual({ type: 'auth', token: 'secret-token' });
  });

  it('closes the socket when the session ends (logout) and does not reconnect', () => {
    vi.useFakeTimers();
    setAccessToken('secret-token');

    renderChannel();
    const socket = FakeWebSocket.instances[0]!;
    socket.open();

    endSession('user');

    expect(socket.closed?.code).toBe(1000);
    vi.advanceTimersByTime(60_000);
    expect(FakeWebSocket.instances).toHaveLength(1);
  });

  it('closes the socket when no welcome frame arrives within the auth deadline', () => {
    vi.useFakeTimers();
    setAccessToken('secret-token');

    renderChannel();
    const socket = FakeWebSocket.instances[0]!;
    socket.open();
    expect(socket.closed).toBeNull();

    vi.advanceTimersByTime(10_000);

    expect(socket.closed?.reason).toBe('welcome-timeout');
  });

  it('stops reconnecting after repeated failures without a welcome frame', () => {
    vi.useFakeTimers();
    setAccessToken('secret-token');

    renderChannel();

    for (let i = 0; i < 10; i++) {
      const socket = FakeWebSocket.instances.at(-1)!;
      socket.open();
      vi.advanceTimersByTime(10_000);
      vi.advanceTimersByTime(60_000);
    }

    expect(FakeWebSocket.instances.length).toBeLessThanOrEqual(6);
  });
});
