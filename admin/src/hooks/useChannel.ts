/**
 * `useChannel()` — WS kanaliga React komponenti darajasida obuna bo'lish
 * (`fe-realtime` "useChannel() hook API shakli").
 *
 * `mount` → `subscribe`, `unmount` → `unsubscribe`. `onEvent` `ref` orqali
 * ushlanadi — uni har render qayta yaratish qayta obunaga olib kelmaydi.
 * `filter` mazmuni o'zgarsa (chuqur taqqoslash — `JSON.stringify`) — eski
 * obuna bekor qilinib, yangisi ochiladi.
 */
import { useEffect, useRef } from 'react';

import {
  type ChannelErrorCode,
  type ChannelFilter,
  type ChannelName,
  type RealtimeEvent,
  subscribeChannel,
} from '@/lib/ws';
import { type ConnectionStatus, useConnectionStore } from '@/stores/connection';

export interface UseChannelOptions {
  /** `false` bo'lsa obuna ochilmaydi (masalan ruxsat yo'q yoki ekran hali tayyor emas). */
  enabled?: boolean;
  onError?: (code: ChannelErrorCode, message?: string) => void;
}

export interface UseChannelResult {
  /** Global WS ulanish holati — barcha kanallar uchun umumiy (F158). */
  status: ConnectionStatus;
}

export function useChannel<T = Record<string, unknown>>(
  channel: ChannelName,
  filter: ChannelFilter | undefined,
  onEvent: (event: RealtimeEvent<T>) => void,
  options: UseChannelOptions = {},
): UseChannelResult {
  const { enabled = true, onError } = options;

  const onEventRef = useRef(onEvent);
  onEventRef.current = onEvent;
  const onErrorRef = useRef(onError);
  onErrorRef.current = onError;

  const status = useConnectionStore((state) => state.status);

  /** Obyekt identifikatori emas, mazmuni bo'yicha barqaror `useEffect` bog'liqligi. */
  const filterKey = filter ? JSON.stringify(filter) : '';

  useEffect(() => {
    if (!enabled) return undefined;

    const unsubscribe = subscribeChannel(
      channel,
      filter,
      (event) => onEventRef.current(event as RealtimeEvent<T>),
      (code, message) => onErrorRef.current?.(code, message),
    );

    return unsubscribe;
    // eslint-disable-next-line react-hooks/exhaustive-deps -- `filterKey` mazmun bo'yicha barqaror kalit.
  }, [channel, filterKey, enabled]);

  return { status };
}
