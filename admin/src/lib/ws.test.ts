/**
 * `lib/ws.ts` — yagona WS klienti protokol testlari (`fe-realtime` F154-F163).
 *
 * Har `it` singleton modul holatini yangidan boshlaydi (`vi.resetModules()` +
 * dinamik import) — aks holda `ws.ts`dagi modul darajasidagi o'zgaruvchilar
 * (kanal registri, taymerlar) testlar orasida sizib o'tardi.
 */
import { act } from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import type { RealtimeEvent } from './ws';

const WS_URL = 'wss://eldapi.test/api/v1/ws';

/** Real `WebSocket`ning `reconnecting-websocket` talab qiladigan minimal shakli. */
class MockWebSocket {
  static instances: MockWebSocket[] = [];
  static readonly CONNECTING = 0;
  static readonly OPEN = 1;
  static readonly CLOSING = 2;
  static readonly CLOSED = 3;

  readyState = MockWebSocket.CONNECTING;
  sent: string[] = [];
  listeners: Record<'open' | 'close' | 'message' | 'error', Array<(event: unknown) => void>> = {
    open: [],
    close: [],
    message: [],
    error: [],
  };

  constructor(public url: string) {
    MockWebSocket.instances.push(this);
  }

  addEventListener(type: keyof MockWebSocket['listeners'], listener: (event: unknown) => void) {
    this.listeners[type].push(listener);
  }

  removeEventListener(type: keyof MockWebSocket['listeners'], listener: (event: unknown) => void) {
    this.listeners[type] = this.listeners[type].filter((l) => l !== listener);
  }

  send(data: string) {
    this.sent.push(data);
  }

  close(code = 1000, reason = '') {
    if (this.readyState === MockWebSocket.CLOSED) return;
    this.readyState = MockWebSocket.CLOSED;
    this.listeners.close.forEach((l) => l({ code, reason }));
  }

  open() {
    this.readyState = MockWebSocket.OPEN;
    this.listeners.open.forEach((l) => l({}));
  }

  message(data: unknown) {
    this.listeners.message.forEach((l) => l({ data: JSON.stringify(data) }));
  }
}

async function tick(ms = 0) {
  await act(async () => {
    await vi.advanceTimersByTimeAsync(ms);
  });
}

function lastSocket(): MockWebSocket {
  const socket = MockWebSocket.instances.at(-1);
  if (!socket) throw new Error('no socket created');
  return socket;
}

function sentFrames(socket: MockWebSocket): Record<string, unknown>[] {
  return socket.sent.map((raw) => JSON.parse(raw) as Record<string, unknown>);
}

/** Ulanishni `welcome`gacha olib boradi va soketni qaytaradi. */
async function connectAndWelcome(): Promise<MockWebSocket> {
  await tick(0);
  const socket = lastSocket();
  socket.open();
  socket.message({ type: 'welcome', ts: '2026-09-08T00:00:00Z' });
  return socket;
}

beforeEach(() => {
  vi.resetModules();
  vi.useFakeTimers();
  MockWebSocket.instances = [];
  vi.stubGlobal('WebSocket', MockWebSocket);
  vi.stubEnv('VITE_WS_URL', WS_URL);
});

afterEach(() => {
  vi.useRealTimers();
  vi.unstubAllEnvs();
  vi.unstubAllGlobals();
});

async function setup() {
  const session = await import('@/api/session');
  const ws = await import('./ws');
  const { useConnectionStore } = await import('@/stores/connection');
  session.setAccessToken('secret-token');
  return { session, ws, useConnectionStore };
}

describe('lib/ws — auth va welcome oqimi', () => {
  it('F154 [MUST]: token never appears in the WS URL — only in the "auth" frame', async () => {
    const { ws } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    await tick(0);

    const socket = lastSocket();
    expect(socket.url).toBe(WS_URL);
    expect(socket.url).not.toMatch(/[?&](token|access_token|jwt|bearer|authorization|api_key)=/i);

    socket.open();
    expect(JSON.parse(socket.sent[0]!)).toEqual({ type: 'auth', token: 'secret-token' });
  });

  it('does not open a socket when there is no access token', async () => {
    const { ws } = await setup();
    const session = await import('@/api/session');
    session.setAccessToken(null);

    ws.subscribeChannel('tracking', undefined, () => undefined);
    await tick(0);

    expect(MockWebSocket.instances).toHaveLength(0);
  });

  it('sends "subscribe" only after "welcome" (deny-by-default)', async () => {
    const { ws } = await setup();
    ws.subscribeChannel('tracking', { unit_ids: ['u1'] }, () => undefined);
    await tick(0);
    const socket = lastSocket();

    socket.open();
    expect(sentFrames(socket).some((f) => f.type === 'subscribe')).toBe(false);

    socket.message({ type: 'welcome' });
    const subscribeFrame = sentFrames(socket).find((f) => f.type === 'subscribe');
    expect(subscribeFrame).toEqual({
      type: 'subscribe',
      channel: 'tracking',
      filter: { unit_ids: ['u1'] },
    });
  });

  it('sets connection status to "live" after welcome', async () => {
    const { ws, useConnectionStore } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    await connectAndWelcome();

    expect(useConnectionStore.getState().status).toBe('live');
  });

  it('merges filters from multiple subscribers into a single subscribe frame', async () => {
    const { ws } = await setup();
    ws.subscribeChannel('tracking', { unit_ids: ['u1'] }, () => undefined);
    const socket = await connectAndWelcome();
    ws.subscribeChannel('tracking', { unit_ids: ['u2'] }, () => undefined);

    const frames = sentFrames(socket).filter((f) => f.type === 'subscribe');
    expect(frames.at(-1)).toEqual({
      type: 'subscribe',
      channel: 'tracking',
      filter: { unit_ids: ['u1', 'u2'] },
    });
  });

  it('unsubscribes on last consumer teardown and closes the idle connection', async () => {
    const { ws } = await setup();
    const unsubscribe = ws.subscribeChannel('tracking', undefined, () => undefined);
    const socket = await connectAndWelcome();
    socket.message({ type: 'subscribed', channel: 'tracking' });

    unsubscribe();

    expect(sentFrames(socket).some((f) => f.type === 'unsubscribe')).toBe(true);
    expect(socket.readyState).toBe(MockWebSocket.CLOSED);
  });
});

describe('lib/ws — since backfill va dublikat', () => {
  it('forwards replay:true events without special handling, updates lastTs', async () => {
    const { ws } = await setup();
    const onEvent = vi.fn();
    ws.subscribeChannel('tracking', undefined, onEvent);
    const socket = await connectAndWelcome();

    socket.message({
      type: 'unit_last_state',
      data: { unit_id: 'u1' },
      ts: '2026-09-06T17:55:00Z',
      replay: true,
    });

    expect(onEvent).toHaveBeenCalledTimes(1);
    expect(onEvent.mock.calls[0]![0]).toMatchObject({ replay: true, ts: '2026-09-06T17:55:00Z' });
  });

  it('drops duplicate events with an equal or older ts', async () => {
    const { ws } = await setup();
    const onEvent = vi.fn();
    ws.subscribeChannel('tracking', undefined, onEvent);
    const socket = await connectAndWelcome();

    socket.message({
      type: 'unit_last_state',
      data: { unit_id: 'u1' },
      ts: '2026-09-06T17:55:00Z',
    });
    socket.message({
      type: 'unit_last_state',
      data: { unit_id: 'u1' },
      ts: '2026-09-06T17:55:00Z',
    });
    socket.message({
      type: 'unit_last_state',
      data: { unit_id: 'u1' },
      ts: '2026-09-06T17:54:00Z',
    });

    expect(onEvent).toHaveBeenCalledTimes(1);
  });

  it('drops duplicate events with the same id even if ts differs', async () => {
    const { ws } = await setup();
    const onEvent = vi.fn();
    ws.subscribeChannel('tracking', undefined, onEvent);
    const socket = await connectAndWelcome();

    socket.message({ type: 'unit_last_state', id: 'evt-1', data: {}, ts: '2026-09-06T17:55:00Z' });
    socket.message({ type: 'unit_last_state', id: 'evt-1', data: {}, ts: '2026-09-06T17:56:00Z' });

    expect(onEvent).toHaveBeenCalledTimes(1);
  });

  it('sends "since" = last processed ts on the resubscribe after a reconnect', async () => {
    const { ws } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    const socket = await connectAndWelcome();
    socket.message({ type: 'unit_last_state', data: {}, ts: '2026-09-06T17:55:00Z' });

    // Tashqi (server) uzilish — RWS o'zining backoff'i bilan qayta ulanadi.
    socket.close();
    await tick(1000);
    const reconnected = lastSocket();
    reconnected.open();
    reconnected.message({ type: 'welcome' });

    const subscribeFrame = sentFrames(reconnected).find((f) => f.type === 'subscribe');
    expect(subscribeFrame).toMatchObject({ since: '2026-09-06T17:55:00Z' });
  });

  it('resubscribes all active channels after a reconnect, each with its own last "since"', async () => {
    const { ws } = await setup();
    ws.subscribeChannel('tracking', { unit_ids: ['u1'] }, () => undefined);
    ws.subscribeChannel('notifications', undefined, () => undefined);
    const socket = await connectAndWelcome();
    socket.message({ type: 'unit_last_state', data: {}, ts: '2026-09-06T17:50:00Z' });
    socket.message({ type: 'notification_created', data: {}, ts: '2026-09-06T17:52:00Z' });

    socket.close();
    await tick(1000);
    const reconnected = lastSocket();
    reconnected.open();
    reconnected.message({ type: 'welcome' });

    const frames = sentFrames(reconnected).filter((f) => f.type === 'subscribe');
    expect(frames).toEqual(
      expect.arrayContaining([
        {
          type: 'subscribe',
          channel: 'tracking',
          filter: { unit_ids: ['u1'] },
          since: '2026-09-06T17:50:00Z',
        },
        { type: 'subscribe', channel: 'notifications', since: '2026-09-06T17:52:00Z' },
      ]),
    );
    expect(frames).toHaveLength(2);
  });

  it('drops backfilled events already seen before a reconnect, forwards new ones', async () => {
    const { ws } = await setup();
    const onEvent = vi.fn();
    ws.subscribeChannel('tracking', undefined, onEvent);
    const socket = await connectAndWelcome();
    socket.message({
      type: 'unit_last_state',
      id: 'evt-1',
      data: { seq: 1 },
      ts: '2026-09-06T17:55:00Z',
    });
    expect(onEvent).toHaveBeenCalledTimes(1);

    socket.close();
    await tick(1000);
    const reconnected = lastSocket();
    reconnected.open();
    reconnected.message({ type: 'welcome' });

    // Server replays events since last ts, including one already processed (evt-1) and a new one.
    reconnected.message({
      type: 'unit_last_state',
      id: 'evt-1',
      data: { seq: 1 },
      ts: '2026-09-06T17:55:00Z',
      replay: true,
    });
    reconnected.message({
      type: 'unit_last_state',
      id: 'evt-2',
      data: { seq: 2 },
      ts: '2026-09-06T17:56:00Z',
      replay: true,
    });

    expect(onEvent).toHaveBeenCalledTimes(2);
    expect(onEvent.mock.calls[1]![0]).toMatchObject({ id: 'evt-2', replay: true });
  });
});

describe('lib/ws — xatolar', () => {
  it('FORBIDDEN channel is not retried on reconnect, other channels keep working', async () => {
    const { ws } = await setup();
    const trackingError = vi.fn();
    ws.subscribeChannel('tracking', undefined, () => undefined, trackingError);
    ws.subscribeChannel('notifications', undefined, () => undefined);
    const socket = await connectAndWelcome();

    socket.message({ type: 'error', channel: 'tracking', code: 'FORBIDDEN', message: 'no access' });
    expect(trackingError).toHaveBeenCalledWith('FORBIDDEN', 'no access');

    socket.close();
    await tick(1000);
    const reconnected = lastSocket();
    reconnected.open();
    reconnected.message({ type: 'welcome' });

    const frames = sentFrames(reconnected).filter((f) => f.type === 'subscribe');
    expect(frames.map((f) => f.channel)).toEqual(['notifications']);
  });

  it('auth_error stops the client — no further reconnect attempts', async () => {
    const { ws, useConnectionStore } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    await tick(0);
    const socket = lastSocket();
    socket.open();

    socket.message({ type: 'auth_error' });
    expect(useConnectionStore.getState().status).toBe('offline');

    await tick(60_000);
    expect(MockWebSocket.instances).toHaveLength(1);
  });

  it('closes immediately (code 1000) and stops reconnecting when the session ends', async () => {
    const { ws, session } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    const socket = await connectAndWelcome();

    session.endSession('user');

    expect(socket.readyState).toBe(MockWebSocket.CLOSED);
    await tick(60_000);
    expect(MockWebSocket.instances).toHaveLength(1);
  });

  it('clears a pending forced-reconnect backoff timer when the session ends mid-backoff', async () => {
    const { ws, session } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    await tick(0);
    const socket = lastSocket();
    socket.open();
    await tick(10_000); // welcome deadline -> forceReconnect schedules a backoff timer

    session.endSession('user');

    await tick(60_000);
    expect(MockWebSocket.instances).toHaveLength(1); // no further reconnect — timer was cleared
  });

  it('sessiya tugagach kanal holati tozalanadi — yangi sessiya `since`/`forbidden` ni meros olmaydi', async () => {
    const { ws, session } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    const first = await connectAndWelcome();
    first.message({ type: 'unit_last_state', ts: '2026-09-08T10:00:00Z', data: {} });
    first.message({ type: 'error', channel: 'tracking', code: 'FORBIDDEN' });

    session.endSession('user');
    session.setAccessToken('next-user-token');

    ws.reconnectNow();
    const second = await connectAndWelcome();
    const subscribe = sentFrames(second).find((frame) => frame.type === 'subscribe');

    expect(subscribe).toBeDefined();
    expect(subscribe?.channel).toBe('tracking');
    expect(subscribe?.since).toBeUndefined();
  });

  it('closes without retrying if the access token disappears before "open" fires', async () => {
    const { ws, session } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    await tick(0);
    const socket = lastSocket();

    session.setAccessToken(null);
    socket.open();

    expect(socket.readyState).toBe(MockWebSocket.CLOSED);
    await tick(60_000);
    expect(MockWebSocket.instances).toHaveLength(1);
  });

  it('ignores malformed JSON and non-object payloads without throwing', async () => {
    const { ws, useConnectionStore } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    const socket = await connectAndWelcome();

    expect(() =>
      socket.listeners.message.forEach((l) => l({ data: '{not valid json' })),
    ).not.toThrow();
    expect(() => socket.message(42)).not.toThrow();

    expect(useConnectionStore.getState().status).toBe('live');
  });

  it('ignores a "subscribed" ack for a missing or unknown channel', async () => {
    const { ws } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    const socket = await connectAndWelcome();

    expect(() => socket.message({ type: 'subscribed' })).not.toThrow();
    expect(() => socket.message({ type: 'subscribed', channel: 'chat' })).not.toThrow();
    expect(socket.readyState).toBe(MockWebSocket.OPEN);
  });

  it('UNAUTHORIZED with no channel forces a reconnect at the connection level', async () => {
    const { ws } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    const socket = await connectAndWelcome();

    socket.message({ type: 'error', code: 'UNAUTHORIZED' });
    await tick(1_500); // our forced backoff + RWS's near-instant reconnect

    expect(MockWebSocket.instances.length).toBeGreaterThan(1);
  });

  it('UNAUTHORIZED for a specific channel is a per-channel error, not a global reconnect', async () => {
    const { ws } = await setup();
    const onError = vi.fn();
    ws.subscribeChannel('tracking', undefined, () => undefined, onError);
    const socket = await connectAndWelcome();

    socket.message({ type: 'error', channel: 'tracking', code: 'UNAUTHORIZED' });

    expect(onError).toHaveBeenCalledWith('UNAUTHORIZED', undefined);
    expect(socket.readyState).toBe(MockWebSocket.OPEN);
  });

  it('ignores error frames with no channel and a non-UNAUTHORIZED code, and errors for unknown channels', async () => {
    const { ws } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    const socket = await connectAndWelcome();

    expect(() => socket.message({ type: 'error', code: 'RATE_LIMITED' })).not.toThrow();
    expect(() => socket.message({ type: 'error', channel: 'chat', code: 'UNKNOWN' })).not.toThrow();
    expect(socket.readyState).toBe(MockWebSocket.OPEN);
  });

  it('defaults to code "UNKNOWN" when the error frame omits it, without forbidding the channel', async () => {
    const { ws } = await setup();
    const onError = vi.fn();
    ws.subscribeChannel('tracking', undefined, () => undefined, onError);
    const socket = await connectAndWelcome();

    socket.message({ type: 'error', channel: 'tracking' });
    expect(onError).toHaveBeenCalledWith('UNKNOWN', undefined);

    // Channel is still usable — an unrelated error code does not mark it forbidden.
    socket.close();
    await tick(1000);
    const reconnected = lastSocket();
    reconnected.open();
    reconnected.message({ type: 'welcome' });
    expect(
      sentFrames(reconnected).some((f) => f.type === 'subscribe' && f.channel === 'tracking'),
    ).toBe(true);
  });

  it('ignores a data frame for a channel that has no active subscribers', async () => {
    const { ws } = await setup();
    const onEvent = vi.fn();
    const unsubTracking = ws.subscribeChannel('tracking', undefined, onEvent);
    ws.subscribeChannel('notifications', undefined, () => undefined); // keeps the socket alive
    const socket = await connectAndWelcome();
    socket.message({ type: 'subscribed', channel: 'tracking' });
    unsubTracking();

    expect(() =>
      socket.message({ type: 'unit_last_state', data: { unit_id: 'u1' } }),
    ).not.toThrow();
    expect(onEvent).not.toHaveBeenCalled();
  });

  it('calling the unsubscribe cleanup twice is a no-op', async () => {
    const { ws } = await setup();
    const unsubscribe = ws.subscribeChannel('tracking', undefined, () => undefined);
    const socket = await connectAndWelcome();
    socket.message({ type: 'subscribed', channel: 'tracking' });

    unsubscribe();
    expect(() => unsubscribe()).not.toThrow();
    expect(sentFrames(socket).filter((f) => f.type === 'unsubscribe')).toHaveLength(1);
  });

  it('unsubscribing one of several subscribers resyncs the filter instead of leaving the channel', async () => {
    const { ws } = await setup();
    const unsubA = ws.subscribeChannel('tracking', { unit_ids: ['u1'] }, () => undefined);
    ws.subscribeChannel('tracking', { unit_ids: ['u2'] }, () => undefined);
    const socket = await connectAndWelcome();

    unsubA();

    const frames = sentFrames(socket).filter((f) => f.type === 'subscribe');
    expect(frames.at(-1)).toEqual({
      type: 'subscribe',
      channel: 'tracking',
      filter: { unit_ids: ['u2'] },
    });
    expect(sentFrames(socket).some((f) => f.type === 'unsubscribe')).toBe(false);
    expect(socket.readyState).toBe(MockWebSocket.OPEN);
  });
});

describe('lib/ws — deadline, ping/pong, visibility', () => {
  it('reconnects when no "welcome" arrives within the 10s auth deadline', async () => {
    const { ws } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    await tick(0);
    const socket = lastSocket();
    socket.open();

    await tick(10_000); // welcome deadline
    await tick(1_500); // o'z backoff'imiz (~1s) + RWS ning 0ms _wait()

    expect(MockWebSocket.instances.length).toBeGreaterThan(1);
  });

  it('sends a ping every 60s and reconnects if pong does not arrive within 10s', async () => {
    const { ws } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    const socket = await connectAndWelcome();

    await tick(60_000);
    expect(sentFrames(socket).some((f) => f.type === 'ping')).toBe(true);

    await tick(10_000); // pong timeout
    await tick(1_500);
    expect(MockWebSocket.instances.length).toBeGreaterThan(1);
  });

  it('a pong within the deadline keeps the connection alive', async () => {
    const { ws } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    const socket = await connectAndWelcome();

    await tick(60_000);
    socket.message({ type: 'pong' });
    await tick(10_000);

    expect(MockWebSocket.instances).toHaveLength(1);
  });

  it('closes the connection after 5 minutes hidden and reconnects with backfill when visible again', async () => {
    const { ws } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    const socket = await connectAndWelcome();
    socket.message({ type: 'unit_last_state', data: {}, ts: '2026-09-06T17:55:00Z' });

    Object.defineProperty(document, 'visibilityState', { configurable: true, value: 'hidden' });
    document.dispatchEvent(new Event('visibilitychange'));

    await tick(5 * 60_000);
    expect(socket.readyState).toBe(MockWebSocket.CLOSED);

    Object.defineProperty(document, 'visibilityState', { configurable: true, value: 'visible' });
    document.dispatchEvent(new Event('visibilitychange'));
    await tick(0);

    const resumed = lastSocket();
    expect(resumed).not.toBe(socket);
    resumed.open();
    resumed.message({ type: 'welcome' });
    const subscribeFrame = sentFrames(resumed).find((f) => f.type === 'subscribe');
    expect(subscribeFrame).toMatchObject({ since: '2026-09-06T17:55:00Z' });
  });

  it('goes offline after 5 consecutive welcome failures and stops retrying (MAX_FAILED_ATTEMPTS)', async () => {
    const { ws, useConnectionStore } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    await tick(0);

    for (let i = 0; i < 5; i += 1) {
      const socket = lastSocket();
      socket.open();
      await tick(10_000); // welcome deadline
      await tick(40_000); // our backoff (grows, capped at 30s) + RWS's near-instant reconnect
    }

    expect(useConnectionStore.getState().status).toBe('offline');

    // No further reconnect attempts, and any stray internal timers do not resurrect the client.
    await tick(120_000);
    expect(useConnectionStore.getState().status).toBe('offline');
  });
});

describe('lib/ws — reconnectNow()', () => {
  it('connects immediately when there is no active socket yet', async () => {
    const { ws } = await setup();
    expect(MockWebSocket.instances).toHaveLength(0);

    ws.reconnectNow();
    await tick(0);

    expect(MockWebSocket.instances).toHaveLength(1);
  });

  it('cancels the pending backoff and reconnects immediately ("Retry now" banner action)', async () => {
    const { ws } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    await tick(0);
    const socket = lastSocket();
    socket.open();
    await tick(10_000); // welcome deadline -> forceReconnect schedules a backoff timer

    expect(MockWebSocket.instances).toHaveLength(1); // still waiting on the backoff

    ws.reconnectNow();
    await tick(0);

    expect(MockWebSocket.instances.length).toBeGreaterThan(1); // backoff skipped
  });
});

describe('lib/ws — useChannel bilan integratsiya', () => {
  it('exports RealtimeEvent type usable by consumers', () => {
    const sample: RealtimeEvent = { type: 'unit_last_state', data: {} };
    expect(sample.type).toBe('unit_last_state');
  });
});

describe('lib/ws — D54 tenant almashtirish reseti (F155)', () => {
  it('super admin tenantga kirganda ulanishni yopadi va qayta ulanmaydi', async () => {
    const { ws, session, useConnectionStore } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    await connectAndWelcome();
    expect(useConnectionStore.getState().status).toBe('live');

    session.setCompanyId('company-42');
    await tick(0);

    expect(useConnectionStore.getState().status).toBe('offline');
    // Keyingi obunachi ham ulanishni qayta tiklamaydi — impersonatsiya davom etadi.
    ws.subscribeChannel('chat', undefined, () => undefined);
    await tick(0);
    expect(useConnectionStore.getState().status).toBe('offline');
  });

  it('impersonatsiyadan chiqilganda ulanish va kanallar qayta tiklanadi', async () => {
    const { ws, session } = await setup();
    ws.subscribeChannel('tracking', undefined, () => undefined);
    await connectAndWelcome();

    session.setCompanyId('company-42');
    await tick(0);
    expect(MockWebSocket.instances.at(-1)?.readyState).toBe(MockWebSocket.CLOSED);

    session.setCompanyId(null);
    await tick(0);

    const socket = lastSocket();
    expect(socket.readyState).not.toBe(MockWebSocket.CLOSED);
  });
});
