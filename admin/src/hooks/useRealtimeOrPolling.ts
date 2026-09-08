/**
 * WS `live` bo'lmaganda 60 s polling fallback (`fe-realtime` F158, TZ 7.5).
 *
 * Har ekran o'zicha `setInterval` yozmasin deb umumiy hook sifatida
 * chiqarilgan — WS holati `connecting|paused|offline` bo'lganda `refetch`
 * har `intervalMs` (standart 60s) da chaqiriladi; `live` bo'lganda polling
 * to'xtaydi (WS hodisalari keshni real-vaqtda yangilaydi).
 */
import { useEffect, useRef } from 'react';

import { useConnectionStore } from '@/stores/connection';

const DEFAULT_INTERVAL_MS = 60_000;

export function useRealtimeOrPolling(refetch: () => void, intervalMs = DEFAULT_INTERVAL_MS): void {
  const status = useConnectionStore((state) => state.status);
  const refetchRef = useRef(refetch);
  refetchRef.current = refetch;

  useEffect(() => {
    if (status === 'live') return undefined;

    const id = setInterval(() => refetchRef.current(), intervalMs);
    return () => clearInterval(id);
  }, [status, intervalMs]);
}
