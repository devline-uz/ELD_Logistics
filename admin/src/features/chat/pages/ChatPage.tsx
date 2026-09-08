/**
 * Chat — `/chat` (7.9/7.10, `docs/tz/07-9-chat-support-audit.md` §7.9).
 *
 * Ikki panelli ekran: chapda suhbatlar ro'yxati (qidiruv, oxirgi xabar,
 * o'qilmagan badge), o'ngda tanlangan haydovchi bilan yozishma. Tanlangan
 * haydovchi URL query-stringda saqlanadi (`?driver=`) — havola ulashiladi.
 *
 * WS `chat` kanali: yangi xabar/holat o'zgarishi keshni yangilaydi
 * (`applyChatMessageEvent`/`applyChatMessageReadEvent`); ochiq bo'lmagan
 * threaddan kelgan (o'zimiz yubormagan, `replay`siz) xabar uchun toast (F163).
 * `live` bo'lmasa `useRealtimeOrPolling` 60s fallback bilan ro'yxatni yangilaydi.
 */
import { useTranslation } from 'react-i18next';
import { useQueryClient } from '@tanstack/react-query';

import {
  applyChatMessageEvent,
  applyChatMessageReadEvent,
  useChatThreadsList,
} from '@/api/queries/chat';
import { EmptyState } from '@/components/feedback/EmptyState';
import { useToast } from '@/components/feedback/toast-context';
import { useListParams } from '@/hooks/useListParams';
import { useRealtimeOrPolling } from '@/hooks/useRealtimeOrPolling';

import { ChatConversationPanel } from '../components/ChatConversationPanel';
import { ChatThreadListPanel } from '../components/ChatThreadListPanel';
import { useChatChannel } from '../hooks/useChatChannel';

export function ChatPage() {
  const { t } = useTranslation();
  const toast = useToast();
  const queryClient = useQueryClient();
  const listParams = useListParams();

  const selectedDriverId = listParams.filters.driver || undefined;

  const threadsQuery = useChatThreadsList({ page: listParams.page, per_page: listParams.perPage });
  useRealtimeOrPolling(() => void threadsQuery.refetch());

  const threads = threadsQuery.data?.data ?? [];
  const total = threadsQuery.data?.meta?.total ?? threads.length;
  const selectedThread = threads.find((thread) => thread.driver_id === selectedDriverId);

  useChatChannel({
    enabled: true,
    onMessage: (event) => {
      applyChatMessageEvent(queryClient, event.data);
      const isFromDriver = event.data.sender_side === 'driver';
      const isOtherThread =
        Boolean(event.data.driver_id) && event.data.driver_id !== selectedDriverId;
      if (!event.replay && isFromDriver && isOtherThread) {
        const driverName =
          threads.find((thread) => thread.driver_id === event.data.driver_id)?.driver_name ??
          t('common.na');
        toast.show({
          variant: 'info',
          message: t('chat.notifications.newMessage', { name: driverName }),
        });
      }
    },
    onMessageRead: (event) => {
      applyChatMessageReadEvent(queryClient, event.data);
    },
  });

  return (
    <div className="flex h-full min-h-[600px] flex-col gap-4">
      <h1 className="text-h3 font-bold text-neutral-900">{t('chat.page.title')}</h1>

      <div className="flex min-h-[520px] flex-1 overflow-hidden rounded-lg border border-stroke bg-surface">
        <ChatThreadListPanel
          threads={threads}
          total={total}
          isLoading={threadsQuery.isLoading}
          isError={threadsQuery.isError}
          onRetry={() => void threadsQuery.refetch()}
          search={listParams.search}
          onSearchChange={listParams.setSearch}
          selectedDriverId={selectedDriverId}
          onSelect={(driverId) => listParams.setFilter('driver', driverId)}
          page={listParams.page}
          perPage={listParams.perPage}
          onPageChange={listParams.setPage}
          onPerPageChange={listParams.setPerPage}
        />

        {selectedDriverId ? (
          <ChatConversationPanel
            key={selectedDriverId}
            driverId={selectedDriverId}
            driverName={selectedThread?.driver_name ?? t('common.na')}
            driverStatus={selectedThread?.driver_status}
          />
        ) : (
          <div className="flex flex-1 items-center justify-center">
            <EmptyState
              title={t('chat.conversation.selectDriver.title')}
              description={t('chat.conversation.selectDriver.description')}
            />
          </div>
        )}
      </div>
    </div>
  );
}

export default ChatPage;
