/**
 * `chat` WS kanaliga obunachi — umumiy `useChannel()` ustidan yupqa wrapper
 * (7.9, `useTrackingChannel` bilan bir xil naqsh). Filtrsiz obuna bo'ladi —
 * chat kanali butun kompaniyani tashiydi (F163), ekran keshni o'zi
 * `applyChatMessageEvent`/`applyChatMessageReadEvent` bilan yangilaydi.
 */
import { useChannel } from '@/hooks/useChannel';
import type { ChatMessage } from '@/api/types';
import type { RealtimeEvent } from '@/lib/ws';
import type { ConnectionStatus } from '@/stores/connection';

export interface ChatMessageEvent {
  type: 'chat_message';
  data: ChatMessage;
  replay?: boolean;
}

export interface ChatMessageReadEvent {
  type: 'chat_message_read';
  data: { id: string; driver_id: string; read_at?: string };
  replay?: boolean;
}

export interface UseChatChannelOptions {
  enabled: boolean;
  onMessage: (event: ChatMessageEvent) => void;
  onMessageRead: (event: ChatMessageReadEvent) => void;
}

export interface UseChatChannelResult {
  status: ConnectionStatus;
}

export function useChatChannel({
  enabled,
  onMessage,
  onMessageRead,
}: UseChatChannelOptions): UseChatChannelResult {
  const { status } = useChannel(
    'chat',
    undefined,
    (event: RealtimeEvent) => {
      if (event.type === 'chat_message') {
        onMessage({ type: 'chat_message', data: event.data, replay: event.replay });
        return;
      }
      if (event.type === 'chat_message_read') {
        onMessageRead({
          type: 'chat_message_read',
          data: event.data as ChatMessageReadEvent['data'],
          replay: event.replay,
        });
      }
    },
    { enabled },
  );

  return { status };
}
