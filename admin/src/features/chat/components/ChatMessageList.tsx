/**
 * O'ng panel — xabarlar ro'yxati: sana ajratgichlari, kursorli "Load older"
 * (yuqoriga scroll + tugma, scroll pozitsiyasi saqlanadi), `IntersectionObserver`
 * bilan o'qilgan belgisi (guruhlangan, 1s debounce) va muvaffaqiyatsiz
 * yuborilgan xabarlar (F130).
 */
import { useCallback, useEffect, useLayoutEffect, useRef } from 'react';
import { useTranslation } from 'react-i18next';

import type { ChatMessage } from '@/api/types';
import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { useDateFormat } from '@/hooks/useDateFormat';

import { resolveDateGroupKind } from '../lib/dateGroups';
import { ChatFailedMessage, ChatMessageBubble, type ChatFileMeta } from './ChatMessageBubble';

export interface ChatFailedMessageEntry {
  localId: string;
  text: string;
  errorMessage: string;
}

export interface ChatMessageListProps {
  driverId: string;
  messages: ChatMessage[];
  isLoading: boolean;
  isError: boolean;
  onRetryLoad: () => void;
  hasNextPage: boolean;
  isFetchingNextPage: boolean;
  onLoadOlder: () => void;
  fileMetaByKey: Record<string, ChatFileMeta>;
  failedMessages: ChatFailedMessageEntry[];
  onRetryFailed: (localId: string) => void;
  onDiscardFailed: (localId: string) => void;
  onMessageVisible: (messageId: string) => void;
}

function DateSeparator({ label }: { label: string }) {
  return (
    <div className="flex items-center gap-3 py-2" role="separator" aria-label={label}>
      <div className="h-px flex-1 bg-stroke" aria-hidden="true" />
      <span className="text-body-xs font-medium uppercase tracking-wide text-neutral-600">
        {label}
      </span>
      <div className="h-px flex-1 bg-stroke" aria-hidden="true" />
    </div>
  );
}

export function ChatMessageList({
  driverId,
  messages,
  isLoading,
  isError,
  onRetryLoad,
  hasNextPage,
  isFetchingNextPage,
  onLoadOlder,
  fileMetaByKey,
  failedMessages,
  onRetryFailed,
  onDiscardFailed,
  onMessageVisible,
}: ChatMessageListProps) {
  const { t } = useTranslation();
  const dateFormat = useDateFormat();

  const containerRef = useRef<HTMLDivElement | null>(null);
  const prevScrollHeightRef = useRef<number | null>(null);
  const lastMessageIdRef = useRef<string | undefined>(undefined);
  const lastDriverIdRef = useRef<string | undefined>(undefined);

  // Eski sahifa yuklanishidan oldin balandlikni saqlaydi — kursorli
  // "Load older" scroll pozitsiyasini sakratmasligi uchun (F130).
  const handleLoadOlder = useCallback(() => {
    const el = containerRef.current;
    if (el) prevScrollHeightRef.current = el.scrollHeight;
    onLoadOlder();
  }, [onLoadOlder]);

  const handleScroll = useCallback(() => {
    const el = containerRef.current;
    if (!el || isFetchingNextPage || !hasNextPage) return;
    if (el.scrollTop < 80) handleLoadOlder();
  }, [handleLoadOlder, hasNextPage, isFetchingNextPage]);

  useLayoutEffect(() => {
    const el = containerRef.current;
    if (!el) return;

    const threadChanged = lastDriverIdRef.current !== driverId;
    lastDriverIdRef.current = driverId;

    if (threadChanged) {
      el.scrollTop = el.scrollHeight;
      lastMessageIdRef.current = messages[messages.length - 1]?.id;
      return;
    }

    if (prevScrollHeightRef.current !== null) {
      const delta = el.scrollHeight - prevScrollHeightRef.current;
      el.scrollTop += delta;
      prevScrollHeightRef.current = null;
      return;
    }

    const newestId = messages[messages.length - 1]?.id;
    if (newestId && newestId !== lastMessageIdRef.current) {
      const distanceFromBottom = el.scrollHeight - el.scrollTop - el.clientHeight;
      if (distanceFromBottom < 200) el.scrollTop = el.scrollHeight;
    }
    lastMessageIdRef.current = newestId;
  }, [messages, driverId]);

  // `IntersectionObserver` — ko'rinib turgan o'qilmagan xabarlarni guruhlab
  // belgilaydi (1s debounce), test muhitida global mavjud bo'lmasa jim o'tadi.
  const observerRef = useRef<IntersectionObserver | null>(null);
  const pendingRef = useRef<Set<string>>(new Set());
  const ackedRef = useRef<Set<string>>(new Set());
  const flushTimerRef = useRef<ReturnType<typeof setTimeout>>();
  const onMessageVisibleRef = useRef(onMessageVisible);
  onMessageVisibleRef.current = onMessageVisible;

  useEffect(() => {
    if (typeof IntersectionObserver === 'undefined') return undefined;

    observerRef.current = new IntersectionObserver(
      (entries) => {
        let changed = false;
        for (const entry of entries) {
          if (!entry.isIntersecting) continue;
          const id = (entry.target as HTMLElement).dataset.messageId;
          if (!id || ackedRef.current.has(id)) continue;
          pendingRef.current.add(id);
          changed = true;
        }
        if (changed) {
          window.clearTimeout(flushTimerRef.current);
          flushTimerRef.current = setTimeout(() => {
            const ids = Array.from(pendingRef.current);
            pendingRef.current.clear();
            for (const id of ids) {
              ackedRef.current.add(id);
              onMessageVisibleRef.current(id);
            }
          }, 1000);
        }
      },
      { threshold: 0.6 },
    );

    return () => {
      observerRef.current?.disconnect();
      window.clearTimeout(flushTimerRef.current);
    };
  }, []);

  const bubbleRef = useCallback((el: HTMLElement | null) => {
    if (el && observerRef.current) observerRef.current.observe(el);
  }, []);

  if (isLoading) {
    return (
      <div className="flex flex-1 flex-col gap-3 p-4">
        <Skeleton variant="card" count={4} />
      </div>
    );
  }

  if (isError) {
    return (
      <ErrorState
        title={t('common.states.error')}
        message={t('chat.conversation.loadFailed')}
        onRetry={onRetryLoad}
      />
    );
  }

  if (messages.length === 0 && failedMessages.length === 0) {
    return (
      <EmptyState
        title={t('chat.conversation.empty.title')}
        description={t('chat.conversation.empty.description')}
      />
    );
  }

  let previousTimestamp: string | undefined;

  return (
    <div
      ref={containerRef}
      onScroll={handleScroll}
      role="log"
      aria-label={t('chat.conversation.messagesLabel')}
      className="flex flex-1 flex-col gap-2 overflow-y-auto p-4"
    >
      {hasNextPage ? (
        <div className="flex justify-center pb-2">
          <button
            type="button"
            onClick={handleLoadOlder}
            disabled={isFetchingNextPage}
            className="text-body-sm font-medium text-primary hover:underline disabled:cursor-not-allowed disabled:opacity-60"
          >
            {isFetchingNextPage
              ? t('chat.conversation.loadingOlder')
              : t('chat.conversation.loadOlder')}
          </button>
        </div>
      ) : null}

      {messages.map((message) => {
        const kind = resolveDateGroupKind(message.sent_at, dateFormat.timezone);
        const showSeparator =
          !previousTimestamp ||
          resolveDateGroupKind(previousTimestamp, dateFormat.timezone) !== kind;
        previousTimestamp = message.sent_at;

        const separatorLabel =
          kind === 'today'
            ? t('chat.conversation.dateGroups.today')
            : kind === 'yesterday'
              ? t('chat.conversation.dateGroups.yesterday')
              : kind === 'weekday'
                ? dateFormat.formatWeekday(message.sent_at)
                : dateFormat.formatDateWithWeekday(message.sent_at);

        const isOwn = message.sender_side === 'office';
        const isUnread = !isOwn && message.status !== 'read';

        return (
          <div key={message.id}>
            {showSeparator ? <DateSeparator label={separatorLabel} /> : null}
            <ChatMessageBubble
              message={message}
              isOwn={isOwn}
              fileMeta={message.file_key ? fileMetaByKey[message.file_key] : undefined}
              bubbleRef={isUnread && message.id ? bubbleRef : undefined}
            />
          </div>
        );
      })}

      {failedMessages.map((failed) => (
        <ChatFailedMessage
          key={failed.localId}
          text={failed.text}
          errorMessage={failed.errorMessage}
          onRetry={() => onRetryFailed(failed.localId)}
          onDiscard={() => onDiscardFailed(failed.localId)}
        />
      ))}
    </div>
  );
}

export default ChatMessageList;
