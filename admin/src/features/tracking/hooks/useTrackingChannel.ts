/**
 * `tracking` WS kanaliga minimal obunachi (`fe-realtime` skill).
 *
 * ⚠️ Bu — **shu modulga xos, yengil** implementatsiya, umumiy `useChannel()`/
 * `lib/ws.ts` infratuzilmasi hali (boshqa bosqichda) qurilmagan. Shuning
 * uchun bu hook `lib/`ga chiqarilmagan — faqat `features/tracking/**` ichida
 * ishlatiladi va umumiy WS mijozini almashtirmaydi (hisobotda ochiq band
 * sifatida qayd etilgan).
 *
 * Protokol (`fe-realtime` F154-F163): header'siz ulanish → 10s ichida
 * `{"type":"auth","token":...}` → `{"type":"welcome"}` kutiladi → shundan
 * keyingina `subscribe`. `unit_last_state` hodisasi `onEvent`ga uzatiladi.
 * Token URL'da yuborilmaydi (F154). Oddiy eksponensial backoff bilan
 * qayta ulanadi; `document.visibilityState==='hidden'` 5 daqiqadan uzoq
 * bo'lsa ulanish yopiladi (F161).
 *
 * Xavfsizlik (fe-security §11):
 * - Sessiya tugaganda (`onSessionEnded` — logout yoki refresh-reuse) soket
 *   `1000` kodi bilan **darhol** yopiladi va qayta ulanish to'xtatiladi;
 *   aks holda logoutdan keyin ochiq soket qolib ketardi (F160).
 * - Access token bo'lmasa umuman ulanilmaydi — aks holda server handshake'ni
 *   uzadi va cheksiz reconnect sikli hosil bo'lardi.
 * - `welcome` 10 soniyada kelmasa soket yopiladi (auth deadline), `auth_error`
 *   kelsa qayta urinilmaydi, ketma-ket muvaffaqiyatsiz urinishlar soni
 *   `MAX_FAILED_ATTEMPTS` dan oshsa ulanish `offline` holatida to'xtaydi.
 */
import { useEffect, useRef } from 'react';

import { getAccessToken, onSessionEnded } from '@/api/session';

export interface UnitLastStateEvent {
  type: 'unit_last_state';
  data: Record<string, unknown>;
  ts?: string;
  replay?: boolean;
}

export type ChannelStatus = 'connecting' | 'open' | 'reconnecting' | 'offline';

export interface UseTrackingChannelOptions {
  enabled: boolean;
  unitIds?: string[];
  onEvent: (event: UnitLastStateEvent) => void;
  onStatusChange?: (status: ChannelStatus) => void;
}

const MIN_RECONNECT_DELAY_MS = 1000;
const MAX_RECONNECT_DELAY_MS = 30_000;
const GROW_FACTOR = 1.5;
const HIDDEN_CLOSE_MS = 5 * 60_000;
/** `fe-realtime`: upgrade'dan keyin auth deadline — 10 s. */
const WELCOME_TIMEOUT_MS = 10_000;
/** Ketma-ket `welcome`siz yopilishlar chegarasi — cheksiz sikldan himoya. */
const MAX_FAILED_ATTEMPTS = 5;

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

export function useTrackingChannel({
  enabled,
  unitIds,
  onEvent,
  onStatusChange,
}: UseTrackingChannelOptions): void {
  const onEventRef = useRef(onEvent);
  onEventRef.current = onEvent;
  const onStatusRef = useRef(onStatusChange);
  onStatusRef.current = onStatusChange;
  const unitIdsRef = useRef(unitIds);
  unitIdsRef.current = unitIds;
  /** `useEffect` bog'liqligi uchun barqaror primitiv (massiv identifikatori emas). */
  const unitIdsKey = unitIds?.join(',') ?? '';

  useEffect(() => {
    const wsUrl = import.meta.env.VITE_WS_URL;
    if (!enabled || !wsUrl) return undefined;

    let socket: WebSocket | undefined;
    /** Effekt (unmount/logout) tomonidan yopildi — qayta ulanish qilinmaydi. */
    let stopped = false;
    let reconnectDelay = MIN_RECONNECT_DELAY_MS;
    let reconnectTimer: ReturnType<typeof setTimeout> | undefined;
    let hiddenTimer: ReturnType<typeof setTimeout> | undefined;
    let welcomeTimer: ReturnType<typeof setTimeout> | undefined;
    /** Ketma-ket `welcome`gacha yetib bormagan urinishlar soni. */
    let failedAttempts = 0;

    const setStatus = (status: ChannelStatus) => onStatusRef.current?.(status);

    const clearWelcomeTimer = () => {
      if (welcomeTimer) {
        clearTimeout(welcomeTimer);
        welcomeTimer = undefined;
      }
    };

    /** Qayta ulanishni butunlay to'xtatadi (logout, auth xatosi, urinishlar chegarasi). */
    const stop = (reason: string) => {
      stopped = true;
      clearWelcomeTimer();
      if (reconnectTimer) clearTimeout(reconnectTimer);
      reconnectTimer = undefined;
      socket?.close(1000, reason);
      socket = undefined;
      setStatus('offline');
    };

    const scheduleReconnect = () => {
      if (stopped) return;
      if (failedAttempts >= MAX_FAILED_ATTEMPTS) {
        stop('too-many-failed-attempts');
        return;
      }
      setStatus('reconnecting');
      reconnectTimer = setTimeout(() => {
        reconnectDelay = Math.min(
          reconnectDelay * GROW_FACTOR * (0.9 + Math.random() * 0.2),
          MAX_RECONNECT_DELAY_MS,
        );
        connect();
      }, reconnectDelay);
    };

    function connect() {
      if (stopped) return;
      // Token yo'q bo'lsa ulanmaymiz: server handshake'ni uzadi va bu cheksiz
      // reconnect siklini hosil qiladi (X2).
      const token = getAccessToken();
      if (!token) {
        stop('no-token');
        return;
      }

      setStatus('connecting');
      const ws = new WebSocket(wsUrl);
      socket = ws;
      /** Shu ulanish `welcome`gacha yetib bordimi (urinishlar hisobi uchun). */
      let welcomed = false;

      ws.onopen = () => {
        ws.send(JSON.stringify({ type: 'auth', token }));
        // Auth deadline (10 s): `welcome` kelmasa soketni yopamiz va
        // reconnect sxemasiga o'tamiz (X3).
        clearWelcomeTimer();
        welcomeTimer = setTimeout(() => {
          welcomeTimer = undefined;
          ws.close(4000, 'welcome-timeout');
        }, WELCOME_TIMEOUT_MS);
      };

      ws.onmessage = (message) => {
        let parsed: unknown;
        try {
          parsed = JSON.parse(String(message.data));
        } catch {
          return;
        }
        if (!isRecord(parsed)) return;

        if (parsed.type === 'welcome') {
          welcomed = true;
          clearWelcomeTimer();
          failedAttempts = 0;
          reconnectDelay = MIN_RECONNECT_DELAY_MS;
          setStatus('open');
          ws.send(
            JSON.stringify({
              type: 'subscribe',
              channel: 'tracking',
              filter: unitIdsRef.current?.length ? { unit_ids: unitIdsRef.current } : undefined,
            }),
          );
          return;
        }

        // Auth rad etildi — qayta urinish foydasiz (token yangilanmaguncha).
        if (
          parsed.type === 'auth_error' ||
          (parsed.type === 'error' && parsed.code === 'UNAUTHORIZED')
        ) {
          stop('auth-error');
          return;
        }

        if (parsed.type === 'unit_last_state') {
          onEventRef.current({
            type: 'unit_last_state',
            data: isRecord(parsed.data) ? parsed.data : {},
            ts: typeof parsed.ts === 'string' ? parsed.ts : undefined,
            replay: parsed.replay === true,
          });
        }
      };

      ws.onclose = () => {
        // `welcome`gacha yetib bormagan ulanish — muvaffaqiyatsiz urinish.
        if (!welcomed) failedAttempts += 1;
        clearWelcomeTimer();
        if (!stopped) scheduleReconnect();
      };
      ws.onerror = () => {
        ws.close();
      };
    }

    connect();

    // Logout / refresh-reuse: soket darhol yopiladi (fe-security §11, F160).
    const offSessionEnded = onSessionEnded(() => {
      stop('session-ended');
    });

    const onVisibilityChange = () => {
      if (document.visibilityState === 'hidden') {
        hiddenTimer = setTimeout(() => socket?.close(1000, 'hidden'), HIDDEN_CLOSE_MS);
      } else if (hiddenTimer) {
        clearTimeout(hiddenTimer);
      }
    };
    document.addEventListener('visibilitychange', onVisibilityChange);

    return () => {
      offSessionEnded();
      document.removeEventListener('visibilitychange', onVisibilityChange);
      if (hiddenTimer) clearTimeout(hiddenTimer);
      stop('unmount');
    };
  }, [enabled, unitIdsKey]);
}
