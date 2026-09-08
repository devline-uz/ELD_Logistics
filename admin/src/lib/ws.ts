/**
 * Yagona WebSocket klienti (`fe-realtime` F154-F163, TZ bosqich 7).
 *
 * Bitta `reconnecting-websocket` singleton — barcha kanal obunachilari
 * (`useChannel`) shu modul orqali ishlaydi, har biri o'z ulanishini ochmaydi.
 *
 * Oqim: ulanish → 10 s ichida `{"type":"auth","token":…}` → `{"type":"welcome"}`
 * kutiladi → shundan keyingina faol kanallarga (har biriga alohida `since`
 * bilan) `subscribe` yuboriladi. Token **hech qachon** URL'da emas (F154) —
 * faqat birinchi freym sifatida, xotiradagi `getAccessToken()`dan.
 *
 * Xavfsizlik (fe-security §11): sessiya tugaganda (`onSessionEnded`) soket
 * `1000` kodi bilan darhol yopiladi, qayta ulanish qilinmaydi.
 */
import ReconnectingWebSocket, { type Options as RwsOptions } from 'reconnecting-websocket';

import { getAccessToken, onSessionEnded } from '@/api/session';
import { connectionState, type ConnectionStatus } from '@/stores/connection';

import {
  type ChannelErrorCode,
  type ChannelFilter,
  type ChannelName,
  type ChannelState,
  createChannelState,
  EVENT_TYPE_CHANNEL,
  isDuplicateEvent,
  mergeFilters,
  type RealtimeEvent,
} from './wsChannels';

export type { ChannelErrorCode, ChannelFilter, ChannelName, RealtimeEvent } from './wsChannels';

/** `fe-realtime`: upgrade'dan keyin auth/welcome deadline. */
const WELCOME_TIMEOUT_MS = 10_000;
/** Amaliy keepalive intervali va `pong` deadline (`fe-realtime` F162). */
const PING_INTERVAL_MS = 60_000;
const PONG_TIMEOUT_MS = 10_000;
/** `visibilitychange`: sahifa shuncha vaqt yashirin bo'lsa soket yopiladi (F161). */
const HIDDEN_CLOSE_MS = 5 * 60_000;
/** `welcome`/`pong` kelmagan protokol darajasidagi majburiy qayta ulanishlar uchun o'z backoff'imiz. */
const MIN_FORCED_DELAY_MS = 1000;
const MAX_FORCED_DELAY_MS = 30_000;
const FORCED_GROW_FACTOR = 1.5;
/** Ketma-ket `welcome`siz qolgan urinishlar chegarasi — cheksiz sikldan himoya. */
const MAX_FAILED_ATTEMPTS = 5;

const RWS_OPTIONS: RwsOptions = {
  minReconnectionDelay: 1000,
  maxReconnectionDelay: 30_000,
  reconnectionDelayGrowFactor: 1.5,
  maxRetries: Infinity,
  connectionTimeout: 10_000,
};

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

function getWsUrl(): string | undefined {
  const url = import.meta.env.VITE_WS_URL;
  return typeof url === 'string' && url.length > 0 ? url : undefined;
}

/* ------------------------------------------------------------------ *
 * Singleton holati
 * ------------------------------------------------------------------ */

let rws: ReconnectingWebSocket | undefined;
/** Joriy ulanish urinishida `welcome` kelganmi (yo'qotilgan ulanishni hisoblash uchun). */
let welcomedThisAttempt = false;
let failedHandshakes = 0;
let forcedDelay = MIN_FORCED_DELAY_MS;

let welcomeTimer: ReturnType<typeof setTimeout> | undefined;
let forcedTimer: ReturnType<typeof setTimeout> | undefined;
let pingInterval: ReturnType<typeof setInterval> | undefined;
let pongTimer: ReturnType<typeof setTimeout> | undefined;
let hiddenTimer: ReturnType<typeof setTimeout> | undefined;

let subscriberIdCounter = 0;
const channels = new Map<ChannelName, ChannelState>();

function setStatus(status: ConnectionStatus): void {
  connectionState().setStatus(status);
}

function sendFrame(frame: Record<string, unknown>): void {
  rws?.send(JSON.stringify(frame));
}

/* ------------------------------------------------------------------ *
 * Ulanish yashash sikli
 * ------------------------------------------------------------------ */

function ensureConnected(): void {
  if (rws) return;
  const url = getWsUrl();
  if (!url) return;
  // Token yo'q bo'lsa ulanmaymiz — aks holda server handshake'ni uzadi va
  // bu cheksiz reconnect siklini hosil qiladi.
  if (!getAccessToken()) return;

  setStatus('connecting');
  const socket = new ReconnectingWebSocket(url, undefined, RWS_OPTIONS);
  rws = socket;
  socket.onopen = handleOpen;
  socket.onmessage = handleMessage;
  socket.onclose = handleClose;
  socket.onerror = () => undefined; // RWS o'zi qayta ulanishni boshqaradi.
}

/** Ulanishni **atayin** va to'liq yopadi — qayta ulanish shu instansiyadan endi bo'lmaydi. */
function closeConnection(code: number, reason: string, nextStatus: ConnectionStatus): void {
  clearAllTimers();
  rws?.close(code, reason);
  rws = undefined;
  welcomedThisAttempt = false;
  setStatus(nextStatus);
}

function clearAllTimers(): void {
  if (hiddenTimer) {
    clearTimeout(hiddenTimer);
    hiddenTimer = undefined;
  }
  if (welcomeTimer) {
    clearTimeout(welcomeTimer);
    welcomeTimer = undefined;
  }
  if (forcedTimer) {
    clearTimeout(forcedTimer);
    forcedTimer = undefined;
  }
  stopPing();
}

/**
 * Butun protokol holatini boshlang'ich holatga qaytaradi — sessiya tugaganda
 * chaqiriladi. Ikki sabab (fe-security §10, §11):
 *
 * 1. **Tenant izolyatsiyasi** — `lastTs`/`seenIds` eski sessiyaniki bo'lib
 *    qolsa, yangi sessiya (boshqa foydalanuvchi yoki boshqa kompaniya) uchun
 *    `since` bilan begona backfill so'ralishi mumkin edi; `forbidden` esa
 *    yangi foydalanuvchida ruxsat bo'lsa ham kanalni yopiq qoldirardi.
 * 2. **Ishlash qobiliyati** — `failedHandshakes` eski sessiyadan qolsa, yangi
 *    sessiyada WS darhol `too-many-failed-attempts` bilan o'chib qolardi.
 */
function resetProtocolState(): void {
  failedHandshakes = 0;
  forcedDelay = MIN_FORCED_DELAY_MS;
  for (const state of channels.values()) {
    state.lastTs = undefined;
    state.seenIds = [];
    state.forbidden = false;
    state.acked = false;
  }
}

/** Protokol darajasidagi nosozlik (welcome/pong deadline, UNAUTHORIZED) uchun o'z backoff'imiz bilan majburiy qayta ulanish. */
function forceReconnect(reason: string): void {
  if (failedHandshakes >= MAX_FAILED_ATTEMPTS) {
    closeConnection(1000, 'too-many-failed-attempts', 'offline');
    return;
  }
  setStatus('paused');
  if (forcedTimer) clearTimeout(forcedTimer);
  const delay = forcedDelay;
  forcedDelay = Math.min(
    forcedDelay * FORCED_GROW_FACTOR * (0.9 + Math.random() * 0.2),
    MAX_FORCED_DELAY_MS,
  );
  forcedTimer = setTimeout(() => {
    forcedTimer = undefined;
    rws?.reconnect(1000, reason);
  }, delay);
}

/** Banner «Retry now» tugmasi — backoff kutishni chetlab, darhol qayta ulanadi. */
export function reconnectNow(): void {
  if (forcedTimer) {
    clearTimeout(forcedTimer);
    forcedTimer = undefined;
  }
  if (rws) {
    rws.reconnect();
  } else {
    ensureConnected();
  }
}

/* ------------------------------------------------------------------ *
 * Ping/pong (F162)
 * ------------------------------------------------------------------ */

function startPing(): void {
  stopPing();
  pingInterval = setInterval(sendPing, PING_INTERVAL_MS);
}

function stopPing(): void {
  if (pingInterval) {
    clearInterval(pingInterval);
    pingInterval = undefined;
  }
  clearPongTimer();
}

function clearPongTimer(): void {
  if (pongTimer) {
    clearTimeout(pongTimer);
    pongTimer = undefined;
  }
}

function sendPing(): void {
  if (!rws) return;
  sendFrame({ type: 'ping' });
  clearPongTimer();
  pongTimer = setTimeout(() => forceReconnect('pong-timeout'), PONG_TIMEOUT_MS);
}

/* ------------------------------------------------------------------ *
 * Protokol handlerlari
 * ------------------------------------------------------------------ */

function handleOpen(): void {
  welcomedThisAttempt = false;
  if (welcomeTimer) clearTimeout(welcomeTimer);

  const token = getAccessToken();
  if (!token) {
    closeConnection(1000, 'no-token', 'offline');
    return;
  }
  sendFrame({ type: 'auth', token });
  welcomeTimer = setTimeout(() => forceReconnect('welcome-timeout'), WELCOME_TIMEOUT_MS);
}

function onWelcome(): void {
  welcomedThisAttempt = true;
  if (welcomeTimer) {
    clearTimeout(welcomeTimer);
    welcomeTimer = undefined;
  }
  failedHandshakes = 0;
  forcedDelay = MIN_FORCED_DELAY_MS;
  setStatus('live');
  startPing();
  for (const channel of channels.keys()) syncChannelSubscription(channel);
}

function handleMessage(event: MessageEvent): void {
  let parsed: unknown;
  try {
    parsed = JSON.parse(String(event.data));
  } catch {
    return;
  }
  if (!isRecord(parsed)) return;
  const type = parsed.type;

  if (type === 'welcome') {
    onWelcome();
    return;
  }

  if (type === 'subscribed') {
    const channel =
      typeof parsed.channel === 'string' ? (parsed.channel as ChannelName) : undefined;
    const state = channel ? channels.get(channel) : undefined;
    if (state) state.acked = true;
    return;
  }

  if (type === 'auth_error') {
    // Token rad etildi — qayta urinish foydasiz (token yangilanmaguncha).
    closeConnection(1000, 'auth-error', 'offline');
    return;
  }

  if (type === 'pong') {
    clearPongTimer();
    return;
  }

  if (type === 'error') {
    handleErrorFrame(parsed);
    return;
  }

  if (typeof type === 'string' && type in EVENT_TYPE_CHANNEL) {
    handleDataFrame(type, parsed);
  }
}

function handleErrorFrame(parsed: Record<string, unknown>): void {
  const channel = typeof parsed.channel === 'string' ? (parsed.channel as ChannelName) : undefined;
  const code: ChannelErrorCode = typeof parsed.code === 'string' ? parsed.code : 'UNKNOWN';
  const message = typeof parsed.message === 'string' ? parsed.message : undefined;

  // Freym darajasidagi UNAUTHORIZED — socket yopiladi, token yangilangach qayta ulanadi.
  if (code === 'UNAUTHORIZED' && !channel) {
    forceReconnect('unauthorized');
    return;
  }
  if (!channel) return;

  const state = channels.get(channel);
  if (!state) return;

  if (code === 'FORBIDDEN' || code === 'NOT_FOUND') {
    // Bu kanalga qayta obuna bo'linmaydi — boshqa kanallar ishlashda davom etadi.
    state.forbidden = true;
    // Server matni foydalanuvchi/PII ma'lumotini o'z ichiga olishi mumkin —
    // prod konsoliga yozilmaydi (fe-security §5).
    if (import.meta.env.DEV) {
      console.warn(`[ws] channel "${channel}" ${code}${message ? `: ${message}` : ''}`);
    }
  }
  for (const subscriber of state.subscribers.values()) subscriber.onError?.(code, message);
}

function handleDataFrame(type: string, parsed: Record<string, unknown>): void {
  const channel = EVENT_TYPE_CHANNEL[type];
  if (!channel) return;
  const state = channels.get(channel);
  if (!state) return;

  const realtimeEvent: RealtimeEvent = {
    type,
    data: isRecord(parsed.data) ? parsed.data : {},
    ts: typeof parsed.ts === 'string' ? parsed.ts : undefined,
    replay: parsed.replay === true,
    id: typeof parsed.id === 'string' ? parsed.id : undefined,
  };
  if (isDuplicateEvent(state, realtimeEvent)) return;
  for (const subscriber of state.subscribers.values()) subscriber.onEvent(realtimeEvent);
}

function handleClose(): void {
  stopPing();
  if (welcomeTimer) {
    clearTimeout(welcomeTimer);
    welcomeTimer = undefined;
  }
  // `closeConnection()` allaqachon `rws`ni `undefined` qilgan bo'lsa — bu
  // atayin yopilish, qayta ishlov berilmaydi (RWS o'zi qayta ulanmaydi).
  if (!rws) return;

  if (!welcomedThisAttempt) {
    failedHandshakes += 1;
  }
  if (failedHandshakes >= MAX_FAILED_ATTEMPTS) {
    closeConnection(1000, 'too-many-failed-attempts', 'offline');
    return;
  }
  setStatus('paused');
  connectionState().setReconnectAttempt(rws.retryCount);
}

/* ------------------------------------------------------------------ *
 * Kanal obunasi
 * ------------------------------------------------------------------ */

function syncChannelSubscription(channel: ChannelName): void {
  if (!rws || !welcomedThisAttempt) return;
  const state = channels.get(channel);
  if (!state || state.forbidden || state.subscribers.size === 0) return;

  const filter = mergeFilters(state.subscribers.values());
  const frame: Record<string, unknown> = { type: 'subscribe', channel };
  if (filter) frame.filter = filter;
  if (state.lastTs) frame.since = state.lastTs;
  sendFrame(frame);
}

/**
 * `useChannel()` uchun asosiy kirish nuqtasi. Bir nechta obunachi bitta
 * kanalga obuna bo'lsa — filtrlar birlashtiriladi va bitta `subscribe`
 * freymi yuboriladi (`fe-realtime`).
 */
export function subscribeChannel(
  channel: ChannelName,
  filter: ChannelFilter | undefined,
  onEvent: (event: RealtimeEvent) => void,
  onError?: (code: ChannelErrorCode, message?: string) => void,
): () => void {
  const id = ++subscriberIdCounter;
  let state = channels.get(channel);
  if (!state) {
    state = createChannelState();
    channels.set(channel, state);
  }
  state.subscribers.set(id, { id, filter, onEvent, onError });

  ensureConnected();
  syncChannelSubscription(channel);

  return () => {
    const current = channels.get(channel);
    if (!current) return;
    current.subscribers.delete(id);

    if (current.subscribers.size === 0) {
      if (rws && current.acked && !current.forbidden) {
        sendFrame({ type: 'unsubscribe', channel });
      }
      channels.delete(channel);
      if (channels.size === 0) {
        closeConnection(1000, 'idle', 'offline');
      }
    } else {
      syncChannelSubscription(channel);
    }
  };
}

/* ------------------------------------------------------------------ *
 * Global (bir martalik) tinglovchilar — modul yuklanganda ro'yxatdan o'tadi
 * ------------------------------------------------------------------ */

onSessionEnded(() => {
  closeConnection(1000, 'session-ended', 'offline');
  resetProtocolState();
});

if (typeof document !== 'undefined') {
  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'hidden') {
      hiddenTimer = setTimeout(() => {
        if (rws) closeConnection(1000, 'hidden', 'offline');
      }, HIDDEN_CLOSE_MS);
      return;
    }
    if (hiddenTimer) {
      clearTimeout(hiddenTimer);
      hiddenTimer = undefined;
    }
    if (!rws && channels.size > 0) ensureConnected();
  });
}
