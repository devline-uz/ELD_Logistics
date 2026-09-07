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
 */
import { useEffect, useRef } from 'react';

import { getAccessToken } from '@/api/session';

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
    let closedByEffect = false;
    let reconnectDelay = MIN_RECONNECT_DELAY_MS;
    let reconnectTimer: ReturnType<typeof setTimeout> | undefined;
    let hiddenTimer: ReturnType<typeof setTimeout> | undefined;

    const setStatus = (status: ChannelStatus) => onStatusRef.current?.(status);

    const scheduleReconnect = () => {
      if (closedByEffect) return;
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
      setStatus('connecting');
      const ws = new WebSocket(wsUrl);
      socket = ws;

      ws.onopen = () => {
        const token = getAccessToken();
        if (token) ws.send(JSON.stringify({ type: 'auth', token }));
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
        if (!closedByEffect) scheduleReconnect();
      };
      ws.onerror = () => {
        ws.close();
      };
    }

    connect();

    const onVisibilityChange = () => {
      if (document.visibilityState === 'hidden') {
        hiddenTimer = setTimeout(() => socket?.close(1000, 'hidden'), HIDDEN_CLOSE_MS);
      } else if (hiddenTimer) {
        clearTimeout(hiddenTimer);
      }
    };
    document.addEventListener('visibilitychange', onVisibilityChange);

    return () => {
      closedByEffect = true;
      document.removeEventListener('visibilitychange', onVisibilityChange);
      if (reconnectTimer) clearTimeout(reconnectTimer);
      if (hiddenTimer) clearTimeout(hiddenTimer);
      socket?.close(1000, 'unmount');
      setStatus('offline');
    };
  }, [enabled, unitIdsKey]);
}
