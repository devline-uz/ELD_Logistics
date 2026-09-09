/**
 * Bitta xabar pufakchasi — matn/rasm/fayl/joylashuv, holat belgichalari
 * (`sent · delivered · read`) faqat o'z (ofis) xabarlarida (F130).
 */
import {
  AlertCircle,
  Check,
  CheckCheck,
  Download,
  FileText,
  MapPin,
  RotateCcw,
} from 'lucide-react';
import { useTranslation } from 'react-i18next';

import type { ChatMessage } from '@/api/types';
import { Icon } from '@/components/ui/Icon';
import { useDateFormat } from '@/hooks/useDateFormat';
import { formatCoordinatePair } from '@/lib/format';

import { formatFileSize, resolveStorageUrl, storageFileNameFromKey } from '@/lib/storage';

export interface ChatFileMeta {
  filename: string;
  size?: number;
}

export interface ChatMessageBubbleProps {
  message: ChatMessage;
  isOwn: boolean;
  fileMeta?: ChatFileMeta;
  /** Ko'rinish maydoniga kirishini kuzatish uchun (o'qilgan belgisi, F130). */
  bubbleRef?: (el: HTMLElement | null) => void;
}

function StatusIcon({ status }: { status: ChatMessage['status'] }) {
  const { t } = useTranslation();
  if (status === 'read') {
    return (
      <Icon
        icon={CheckCheck}
        size={14}
        label={t('chat.conversation.status.read')}
        className="text-decorative-blue"
      />
    );
  }
  if (status === 'delivered') {
    return (
      <Icon
        icon={CheckCheck}
        size={14}
        label={t('chat.conversation.status.delivered')}
        className="text-white/70"
      />
    );
  }
  return (
    <Icon
      icon={Check}
      size={14}
      label={t('chat.conversation.status.sent')}
      className="text-white/70"
    />
  );
}

export function ChatMessageBubble({ message, isOwn, fileMeta, bubbleRef }: ChatMessageBubbleProps) {
  const { t } = useTranslation();
  const dateFormat = useDateFormat();

  const time = dateFormat.formatTime(message.sent_at);
  const fileUrl = resolveStorageUrl(message.file_key);
  const filename = fileMeta?.filename ?? storageFileNameFromKey(message.file_key);
  const sizeLabel = fileMeta?.size !== undefined ? formatFileSize(fileMeta.size) : undefined;

  return (
    <div
      ref={bubbleRef}
      data-message-id={message.id}
      className={`flex ${isOwn ? 'justify-end' : 'justify-start'}`}
    >
      <div
        className={`flex max-w-md flex-col gap-1 rounded-lg px-3 py-2 ${
          isOwn ? 'bg-primary text-white' : 'border border-stroke bg-surface text-neutral-900'
        }`}
      >
        {message.kind === 'image' ? (
          fileUrl ? (
            <a href={fileUrl} target="_blank" rel="noopener noreferrer">
              <img
                src={fileUrl}
                alt={filename || t('chat.conversation.attachment.imageAlt')}
                className="max-h-64 rounded-md object-cover"
              />
            </a>
          ) : (
            <p className="text-body-sm italic opacity-80">
              {t('chat.conversation.attachment.previewUnavailable')}
            </p>
          )
        ) : null}

        {message.kind === 'file' ? (
          <div className="flex items-center gap-2 rounded-md bg-black/5 p-2">
            <Icon icon={FileText} size={20} />
            <div className="flex flex-col">
              <span className="text-body-sm font-medium">{filename || t('common.na')}</span>
              {sizeLabel ? <span className="text-body-xs opacity-70">{sizeLabel}</span> : null}
            </div>
            {fileUrl ? (
              <a
                href={fileUrl}
                target="_blank"
                rel="noopener noreferrer"
                aria-label={t('chat.conversation.attachment.download')}
                className="ml-2"
              >
                <Icon icon={Download} size={16} />
              </a>
            ) : null}
          </div>
        ) : null}

        {message.kind === 'location' ? (
          <div className="flex items-center gap-2">
            <Icon icon={MapPin} size={16} />
            <span className="text-body-sm">{formatCoordinatePair(message.lat, message.lng)}</span>
          </div>
        ) : null}

        {message.text ? <p className="whitespace-pre-wrap text-body">{message.text}</p> : null}

        <div
          className={`flex items-center justify-end gap-1 text-body-xs ${
            isOwn ? 'text-white/70' : 'text-neutral-400'
          }`}
        >
          <span>{time}</span>
          {isOwn ? <StatusIcon status={message.status} /> : null}
        </div>
      </div>
    </div>
  );
}

export interface ChatFailedMessageProps {
  text: string;
  onRetry: () => void;
  onDiscard: () => void;
  errorMessage: string;
}

/** Optimistik yuborish rad etilganda — "yuborilmadi" holati + qayta urinish (7.9). */
export function ChatFailedMessage({
  text,
  onRetry,
  onDiscard,
  errorMessage,
}: ChatFailedMessageProps) {
  const { t } = useTranslation();

  return (
    <div className="flex justify-end">
      <div className="flex max-w-md flex-col gap-1 rounded-lg border border-error-base bg-error-bg px-3 py-2">
        {text ? <p className="whitespace-pre-wrap text-body text-neutral-900">{text}</p> : null}
        <div className="flex items-center gap-2 text-body-xs text-error-dark">
          <Icon icon={AlertCircle} size={14} />
          <span>{errorMessage}</span>
        </div>
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={onRetry}
            className="inline-flex items-center gap-1 text-body-xs font-medium text-error-dark hover:underline"
          >
            <Icon icon={RotateCcw} size={12} />
            {t('chat.conversation.retry')}
          </button>
          <button
            type="button"
            onClick={onDiscard}
            className="text-body-xs font-medium text-neutral-600 hover:underline"
          >
            {t('common.actions.delete')}
          </button>
        </div>
      </div>
    </div>
  );
}

export default ChatMessageBubble;
