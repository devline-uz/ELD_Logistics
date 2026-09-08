/**
 * `tracking` WS kanaliga obunachi — umumiy `useChannel()` (`src/hooks/useChannel.ts`)
 * ustidan yupqa wrapper (bosqich 7 migratsiyasi).
 *
 * Ilgari bu yerda modulga xos, o'z ulanishini ochadigan vaqtinchalik
 * implementatsiya bor edi (auth/welcome, backoff, visibility — hammasi
 * `src/lib/ws.ts` yagona singleton klientiga ko'chirildi). Bu fayl endi
 * faqat `unit_ids` filtrini `useChannel`ga uzatadi va `unit_last_state`
 * hodisasini mavjud `TrackingListPage`/`TrackOnMapPage` shakliga moslaydi —
 * shu ikkala ekranning tashqi hook shartnomasi (props/import) o'zgarmagan.
 */
import { useEffect } from 'react';

import { useChannel } from '@/hooks/useChannel';
import type { RealtimeEvent } from '@/lib/ws';
import { type ConnectionStatus } from '@/stores/connection';

export interface UnitLastStateEvent {
  type: 'unit_last_state';
  data: Record<string, unknown>;
  ts?: string;
  replay?: boolean;
}

/** Eski nom saqlanadi — bu yerda global ulanish holatiga to'g'ridan-to'g'ri mos keladi. */
export type ChannelStatus = ConnectionStatus;

export interface UseTrackingChannelOptions {
  enabled: boolean;
  unitIds?: string[];
  onEvent: (event: UnitLastStateEvent) => void;
  onStatusChange?: (status: ChannelStatus) => void;
}

export function useTrackingChannel({
  enabled,
  unitIds,
  onEvent,
  onStatusChange,
}: UseTrackingChannelOptions): void {
  const filter = unitIds?.length ? { unit_ids: unitIds } : undefined;

  const { status } = useChannel(
    'tracking',
    filter,
    (event: RealtimeEvent) => {
      if (event.type !== 'unit_last_state') return;
      onEvent({ type: 'unit_last_state', data: event.data, ts: event.ts, replay: event.replay });
    },
    { enabled },
  );

  useEffect(() => {
    onStatusChange?.(status);
  }, [status, onStatusChange]);
}
