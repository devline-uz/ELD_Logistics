/**
 * Global WebSocket ulanish holati (`fe-realtime` F158, TZ 7.5).
 *
 * Yagona manba — `src/lib/ws.ts` klienti shu store'ni yangilaydi.
 * `LiveUpdatesBanner` va `useRealtimeOrPolling` shu yerdan o'qiydi.
 */
import { create } from 'zustand';

/**
 * - `connecting` — birinchi ulanish urinishi (hali qayta ulanish emas), banner
 *   ko'rsatilmaydi.
 * - `live` — `welcome` qabul qilingan, kanallar obuna bo'lgan.
 * - `paused` — ulanish uzildi va qayta ulanish davom etmoqda (banner + 60s
 *   polling fallback).
 * - `offline` — WS umuman ishlamayapti (token yo'q, sessiya tugadi, `auth_error`
 *   yoki qayta urinishlar chegarasidan oshildi, yoki faol kanal yo'q).
 */
export type ConnectionStatus = 'connecting' | 'live' | 'paused' | 'offline';

interface ConnectionState {
  status: ConnectionStatus;
  /** Joriy `paused` siklidagi qayta ulanish urinishi soni — banner matnida ko'rsatish uchun. */
  reconnectAttempt: number;
  setStatus: (status: ConnectionStatus) => void;
  setReconnectAttempt: (attempt: number) => void;
}

export const useConnectionStore = create<ConnectionState>((set) => ({
  status: 'offline',
  reconnectAttempt: 0,

  setStatus: (status) =>
    set((state) => ({
      status,
      reconnectAttempt: status === 'live' || status === 'connecting' ? 0 : state.reconnectAttempt,
    })),

  setReconnectAttempt: (reconnectAttempt) => set({ reconnectAttempt }),
}));

/** React'dan tashqarida (`lib/ws.ts`) o'qish/yozish uchun. */
export function connectionState(): ConnectionState {
  return useConnectionStore.getState();
}
