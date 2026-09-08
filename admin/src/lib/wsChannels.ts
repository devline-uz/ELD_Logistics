/**
 * `lib/ws.ts` uchun yordamchi — kanal registri turlari va sof funksiyalar
 * (filtr birlashtirish, dublikat aniqlash). Alohida faylga chiqarilgan —
 * `ws.ts`ning o'zi yagona `WebSocket` klienti mantig'iga bag'ishlangan
 * bo'lishi uchun (W5: 500 qatordan uzun fayl yozilmaydi).
 */

/** Backend qo'llab-quvvatlaydigan kanallar (`fe-realtime` kanallar jadvali). */
export type ChannelName = 'tracking' | 'notifications' | 'chat' | 'dashboard';

/** `subscribe` freymidagi `filter` — hozircha faqat id ro'yxatlari. */
export interface ChannelFilter {
  unit_ids?: string[];
  driver_ids?: string[];
}

/** `filter.unit_ids` / `driver_ids` uchun maksimal id soni (`fe-realtime`). */
export const MAX_FILTER_IDS = 500;

/** Kanaldan kelgan hodisa — `replay: true` bo'lsa backfill (toastsiz). */
export interface RealtimeEvent<T = Record<string, unknown>> {
  type: string;
  data: T;
  ts?: string;
  replay?: boolean;
  id?: string;
}

/** Ma'lum kodlar: `FORBIDDEN`, `NOT_FOUND`, `UNAUTHORIZED` — server kelajakda boshqasini ham yuborishi mumkin. */
export type ChannelErrorCode = string;

/** Hodisa turi → kanal xaritasi (ma'lumot freymlarida `channel` maydoni yo'q). */
export const EVENT_TYPE_CHANNEL: Record<string, ChannelName> = {
  unit_last_state: 'tracking',
  notification_created: 'notifications',
  chat_message: 'chat',
  chat_message_read: 'chat',
  dashboard_summary: 'dashboard',
};

export interface ChannelSubscriber {
  id: number;
  filter?: ChannelFilter;
  onEvent: (event: RealtimeEvent) => void;
  onError?: (code: ChannelErrorCode, message?: string) => void;
}

export interface ChannelState {
  subscribers: Map<number, ChannelSubscriber>;
  /** Oxirgi qayta ishlangan hodisaning `ts`i — `since` backfill uchun (F157). */
  lastTs?: string;
  /** Oxirgi ko'rilgan hodisa id'lari — dublikat oldini olish uchun cheklangan to'plam. */
  seenIds: string[];
  /** `FORBIDDEN`/`NOT_FOUND` javobidan keyin — qayta obuna urinilmaydi. */
  forbidden: boolean;
  /** Serverdan `subscribed` ack kelganmi (hozirgi ulanish davomida). */
  acked: boolean;
}

export function createChannelState(): ChannelState {
  return { subscribers: new Map(), seenIds: [], forbidden: false, acked: false };
}

/**
 * Bir nechta obunachining filtrlarini bitta `subscribe` freymiga birlashtiradi
 * (`fe-realtime`: "bitta kanalga bir nechta obunachi — bitta subscribe freymi").
 * Har qanday obunachi filtrsiz (hammasi) so'rasa — natija filtrsiz bo'ladi.
 */
export function mergeFilters(subscribers: Iterable<ChannelSubscriber>): ChannelFilter | undefined {
  const unitIds = new Set<string>();
  const driverIds = new Set<string>();
  let hasAny = false;
  for (const subscriber of subscribers) {
    hasAny = true;
    if (!subscriber.filter || (!subscriber.filter.unit_ids && !subscriber.filter.driver_ids)) {
      // Filtrsiz obunachi bor — butun kanalga obuna bo'lish kerak.
      return undefined;
    }
    subscriber.filter.unit_ids?.forEach((id) => unitIds.add(id));
    subscriber.filter.driver_ids?.forEach((id) => driverIds.add(id));
  }
  if (!hasAny) return undefined;
  const filter: ChannelFilter = {};
  if (unitIds.size > 0) filter.unit_ids = [...unitIds].slice(0, MAX_FILTER_IDS);
  if (driverIds.size > 0) filter.driver_ids = [...driverIds].slice(0, MAX_FILTER_IDS);
  return filter.unit_ids || filter.driver_ids ? filter : undefined;
}

const MAX_SEEN_IDS = 200;

/**
 * Hodisa avval ko'rilganmi (id yoki `ts` bo'yicha) — takrorlanmasin (F157).
 * Yangi bo'lsa `channel` holati **joyida** yangilanadi.
 */
export function isDuplicateEvent(channel: ChannelState, event: RealtimeEvent): boolean {
  if (event.id) {
    if (channel.seenIds.includes(event.id)) return true;
    channel.seenIds.push(event.id);
    if (channel.seenIds.length > MAX_SEEN_IDS) channel.seenIds.shift();
  } else if (event.ts && channel.lastTs && event.ts <= channel.lastTs) {
    return true;
  }
  if (event.ts && (!channel.lastTs || event.ts > channel.lastTs)) {
    channel.lastTs = event.ts;
  }
  return false;
}
