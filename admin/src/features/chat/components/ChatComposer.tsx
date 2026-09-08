/**
 * Yozish maydoni — matn (≤ 2000), fayl biriktirish (`kind=chat`, 7.10) va
 * haydash rejimi haqida doimiy eslatma (F133). Backendda haydovchining
 * joriy `duty_status`i chat endpointlarida qaytarilmaydi (§17 D36 —
 * pre-send bloklovchi tekshiruv imkonsiz), shuning uchun eslatma doimiy
 * ko'rinadi va haqiqiy blok `409 DRIVING_MODE_BLOCKED` javobi orqali
 * amalga oshiriladi.
 */
import { useId, useRef, useState, type KeyboardEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { Info, Paperclip, Send, X } from 'lucide-react';

import type { ChatMessageCreate } from '@/api/types';
import { presignFile } from '@/api/queries/files';
import { FileUpload, type FileUploadResult } from '@/components/form/FileUpload';
import { Icon } from '@/components/ui/Icon';
import { IconButton } from '@/components/ui/IconButton';
import { useToast } from '@/components/feedback/toast-context';

import { CHAT_MESSAGE_MAX_LENGTH, isChatMessageTextValid } from '../schemas';
import { formatFileSize } from '@/lib/storage';

export interface ChatComposerProps {
  disabled?: boolean;
  isSending: boolean;
  onSend: (body: ChatMessageCreate) => void;
  onAttachmentUploaded: (result: FileUploadResult) => void;
}

export function ChatComposer({
  disabled,
  isSending,
  onSend,
  onAttachmentUploaded,
}: ChatComposerProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const textareaId = useId();

  const [text, setText] = useState('');
  const [attachment, setAttachment] = useState<FileUploadResult | undefined>(undefined);
  const [attachOpen, setAttachOpen] = useState(false);
  const [textError, setTextError] = useState<string | undefined>(undefined);
  const textareaRef = useRef<HTMLTextAreaElement | null>(null);

  const canSubmit = !disabled && (text.trim().length > 0 || Boolean(attachment));

  const handleSubmit = () => {
    if (!canSubmit) return;
    if (!isChatMessageTextValid(text)) {
      setTextError(t('chat.composer.errors.tooLong', { max: CHAT_MESSAGE_MAX_LENGTH }));
      return;
    }

    const body: ChatMessageCreate = attachment
      ? {
          kind: attachment.contentType.startsWith('image/') ? 'image' : 'file',
          file_key: attachment.key,
          text: text.trim() || undefined,
        }
      : { kind: 'text', text: text.trim() };

    onSend(body);
    setText('');
    setAttachment(undefined);
    setAttachOpen(false);
    setTextError(undefined);
  };

  const handleKeyDown = (event: KeyboardEvent<HTMLTextAreaElement>) => {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      handleSubmit();
    }
  };

  return (
    <div className="flex flex-col gap-2 border-t border-stroke p-4">
      <div className="flex items-start gap-2 rounded-md bg-light px-3 py-2 text-body-sm text-neutral-600">
        <Icon icon={Info} size={16} className="mt-0.5 shrink-0 text-decorative-blue" />
        <span>{t('chat.composer.drivingModeHint')}</span>
      </div>

      {attachOpen && !attachment ? (
        <FileUpload
          kind="chat"
          label={t('chat.composer.attachment.label')}
          onPresign={presignFile}
          onUploaded={(result) => {
            setAttachment(result);
            onAttachmentUploaded(result);
            setAttachOpen(false);
          }}
          onError={(message) => toast.show({ variant: 'error', message })}
        />
      ) : null}

      {attachment ? (
        <div className="flex items-center gap-2 rounded-md border border-stroke bg-surface px-3 py-2">
          <Paperclip className="h-4 w-4 text-neutral-500" aria-hidden="true" />
          <span className="flex-1 truncate text-body-sm text-neutral-700">
            {attachment.filename}
            {attachment.size ? ` (${formatFileSize(attachment.size)})` : ''}
          </span>
          <IconButton
            icon={X}
            size="sm"
            variant="ghost"
            aria-label={t('chat.composer.attachment.remove')}
            onClick={() => setAttachment(undefined)}
          />
        </div>
      ) : null}

      <div className="flex items-end gap-2">
        <IconButton
          icon={Paperclip}
          variant="secondary"
          aria-label={t('chat.composer.attachment.add')}
          disabled={disabled || Boolean(attachment)}
          onClick={() => setAttachOpen((open) => !open)}
        />

        <div className="flex-1">
          <label htmlFor={textareaId} className="sr-only">
            {t('chat.composer.label')}
          </label>
          <textarea
            ref={textareaRef}
            id={textareaId}
            value={text}
            disabled={disabled}
            maxLength={CHAT_MESSAGE_MAX_LENGTH}
            placeholder={t('chat.composer.placeholder')}
            onChange={(event) => {
              setText(event.target.value);
              if (textError) setTextError(undefined);
            }}
            onKeyDown={handleKeyDown}
            rows={2}
            aria-invalid={Boolean(textError)}
            aria-describedby={textError ? `${textareaId}-error` : undefined}
            className="w-full resize-none rounded-md border border-stroke bg-surface px-3 py-2 text-body text-neutral-800 outline-none placeholder:text-neutral-400 focus:ring-2 focus:ring-primary focus:ring-offset-1 disabled:cursor-not-allowed disabled:bg-surface-muted disabled:opacity-60"
          />
          {textError ? (
            <p
              id={`${textareaId}-error`}
              role="alert"
              className="mt-1 text-body-sm text-error-dark"
            >
              {textError}
            </p>
          ) : null}
        </div>

        <IconButton
          icon={Send}
          variant="primary"
          aria-label={t('chat.composer.send')}
          disabled={!canSubmit}
          loading={isSending}
          onClick={handleSubmit}
        />
      </div>
    </div>
  );
}

export default ChatComposer;
