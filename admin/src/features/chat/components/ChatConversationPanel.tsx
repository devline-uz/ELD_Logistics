/**
 * O'ng panel — tanlangan haydovchi bilan yozishma: sarlavha, xabarlar
 * ro'yxati, yozish maydoni (7.9/7.10). Optimistik yuborish xatosi
 * (`useChatMessageSend`ning `onError`i keshni tozalaydi) shu yerda mahalliy
 * "yuborilmadi" navbatiga aylantiriladi — xabar matni yo'qolmaydi, qayta
 * urinish imkoni bilan qoladi (7.9 talabi).
 */
import { useCallback, useState } from 'react';
import { useTranslation } from 'react-i18next';

import {
  flattenChatMessages,
  useChatMessageAck,
  useChatMessages,
  useChatMessageSend,
} from '@/api/queries/chat';
import type { ChatMessageCreate } from '@/api/types';
import { useToast } from '@/components/feedback/toast-context';
import type { FileUploadResult } from '@/components/form/FileUpload';
import { Avatar } from '@/components/ui/Avatar';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { isApiError } from '@/lib/errors';
import { PERM } from '@/lib/permissions';

import type { ChatFileMeta } from './ChatMessageBubble';
import { ChatComposer } from './ChatComposer';
import { ChatMessageList, type ChatFailedMessageEntry } from './ChatMessageList';

export interface ChatConversationPanelProps {
  driverId: string;
  driverName?: string;
  driverStatus?: 'active' | 'inactive';
}

let failedIdSeq = 0;
function nextFailedId(): string {
  failedIdSeq += 1;
  return `failed-${Date.now().toString(16)}-${failedIdSeq}`;
}

interface FailedEntry extends ChatFailedMessageEntry {
  body: ChatMessageCreate;
}

export function ChatConversationPanel({
  driverId,
  driverName,
  driverStatus,
}: ChatConversationPanelProps) {
  const { t } = useTranslation();
  const toast = useToast();

  const messagesQuery = useChatMessages(driverId);
  const sendMutation = useChatMessageSend(driverId);
  const ackMutation = useChatMessageAck();

  const [failedMessages, setFailedMessages] = useState<FailedEntry[]>([]);
  const [fileMetaByKey, setFileMetaByKey] = useState<Record<string, ChatFileMeta>>({});

  const messages = flattenChatMessages(messagesQuery.data).slice().reverse();

  const handleSend = useCallback(
    async (body: ChatMessageCreate) => {
      try {
        await sendMutation.mutateAsync(body);
      } catch (error) {
        const isBlocked = isApiError(error) && error.code === 'DRIVING_MODE_BLOCKED';
        const message = isBlocked
          ? t('chat.composer.errors.drivingModeBlocked')
          : t('chat.composer.errors.sendFailed');
        setFailedMessages((previous) => [
          ...previous,
          { localId: nextFailedId(), text: body.text ?? '', errorMessage: message, body },
        ]);
        toast.show({ variant: isBlocked ? 'warning' : 'error', message });
      }
    },
    [sendMutation, t, toast],
  );

  const handleRetryFailed = useCallback(
    (localId: string) => {
      const entry = failedMessages.find((failed) => failed.localId === localId);
      if (!entry) return;
      setFailedMessages((previous) => previous.filter((failed) => failed.localId !== localId));
      void handleSend(entry.body);
    },
    [failedMessages, handleSend],
  );

  const handleDiscardFailed = useCallback((localId: string) => {
    setFailedMessages((previous) => previous.filter((failed) => failed.localId !== localId));
  }, []);

  const handleAttachmentUploaded = useCallback((result: FileUploadResult) => {
    setFileMetaByKey((previous) => ({
      ...previous,
      [result.key]: { filename: result.filename, size: result.size },
    }));
  }, []);

  const handleMessageVisible = useCallback(
    (messageId: string) => {
      ackMutation.mutate({ id: messageId, driverId });
    },
    [ackMutation, driverId],
  );

  return (
    <div className="flex flex-1 flex-col">
      <div className="flex items-center gap-3 border-b border-stroke p-4">
        <Avatar name={driverName ?? t('common.na')} size="md" />
        <div>
          <p className="text-body font-semibold text-neutral-900">{driverName ?? t('common.na')}</p>
          {driverStatus === 'inactive' ? (
            <p className="text-body-xs text-neutral-600">{t('chat.conversation.driverInactive')}</p>
          ) : null}
        </div>
      </div>

      <ChatMessageList
        driverId={driverId}
        messages={messages}
        isLoading={messagesQuery.isLoading}
        isError={messagesQuery.isError}
        onRetryLoad={() => void messagesQuery.refetch()}
        hasNextPage={Boolean(messagesQuery.hasNextPage)}
        isFetchingNextPage={messagesQuery.isFetchingNextPage}
        onLoadOlder={() => void messagesQuery.fetchNextPage()}
        fileMetaByKey={fileMetaByKey}
        failedMessages={failedMessages}
        onRetryFailed={handleRetryFailed}
        onDiscardFailed={handleDiscardFailed}
        onMessageVisible={handleMessageVisible}
      />

      <PermissionGate
        permission={PERM.chatSend}
        fallback={
          <div className="border-t border-stroke p-4 text-body-sm text-neutral-600">
            {t('chat.composer.readOnly')}
          </div>
        }
      >
        <ChatComposer
          isSending={sendMutation.isPending}
          onSend={(body) => void handleSend(body)}
          onAttachmentUploaded={handleAttachmentUploaded}
        />
      </PermissionGate>
    </div>
  );
}

export default ChatConversationPanel;
