/**
 * Ticket thread — oldest-first message list + reply composer
 * (`docs/tz/07-9-chat-support-audit.md` §7.10.1, F136). At most 3
 * attachments per reply (`TicketMessageCreate.attachments`, swagger); text
 * ≤ 4000 chars.
 */
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Paperclip, X } from 'lucide-react';

import { presignFile } from '@/api/queries/files';
import { useSupportTicketMessageCreate, useSupportTicketMessages } from '@/api/queries/support';
import type { SupportTicketMessageCreate } from '@/api/types';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { useToast } from '@/components/feedback/toast-context';
import { FileUpload, type FileUploadResult } from '@/components/form/FileUpload';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import { Icon } from '@/components/ui/Icon';
import { IconButton } from '@/components/ui/IconButton';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { Textarea } from '@/components/ui/Textarea';
import { useDateFormat } from '@/hooks/useDateFormat';
import { PERM } from '@/lib/permissions';
import { resolveStorageUrl, storageFileNameFromKey } from '@/lib/storage';

const MAX_ATTACHMENTS = 3;
const MAX_TEXT_LENGTH = 4000;

export interface SupportThreadProps {
  ticketId: string;
}

export function SupportThread({ ticketId }: SupportThreadProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const dateFormat = useDateFormat();

  const messagesQuery = useSupportTicketMessages(ticketId, { per_page: 50 });
  const sendMutation = useSupportTicketMessageCreate(ticketId);

  const [text, setText] = useState('');
  const [attachments, setAttachments] = useState<FileUploadResult[]>([]);
  const [attachOpen, setAttachOpen] = useState(false);

  const messages = messagesQuery.data?.data ?? [];
  const canSubmit = text.trim().length > 0 || attachments.length > 0;

  const handleSend = async () => {
    if (!canSubmit) return;
    const body: SupportTicketMessageCreate = {
      text: text.trim(),
      attachments: attachments.map((attachment) => attachment.key),
    };
    try {
      await sendMutation.mutateAsync(body);
      setText('');
      setAttachments([]);
      setAttachOpen(false);
      toast.show({ variant: 'success', message: t('support.thread.toast.sent') });
    } catch {
      toast.show({ variant: 'error', message: t('support.thread.toast.sendFailed') });
    }
  };

  return (
    <div className="flex flex-col gap-4">
      <h2 className="text-body-lg font-semibold text-neutral-900">
        {t('support.detail.sections.thread')}
      </h2>

      {messagesQuery.isLoading ? (
        <Skeleton variant="card" count={2} />
      ) : messagesQuery.isError ? (
        <ErrorState
          message={messagesQuery.error?.message}
          onRetry={() => void messagesQuery.refetch()}
        />
      ) : messages.length === 0 ? (
        <p className="text-body-sm text-neutral-500">{t('support.thread.empty')}</p>
      ) : (
        <ul className="flex flex-col gap-3">
          {messages.map((message) => (
            <li
              key={message.id}
              className="flex gap-3 rounded-lg border border-stroke bg-surface p-3"
            >
              <Avatar name={message.sender_name ?? t('common.na')} size="sm" />
              <div className="flex-1">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <span className="text-body-sm font-semibold text-neutral-900">
                    {message.sender_name ?? t('common.na')}
                  </span>
                  <span className="text-body-xs text-neutral-500">
                    {dateFormat.formatDateTime(message.created_at)}
                  </span>
                </div>
                <p className="mt-1 whitespace-pre-wrap text-body text-neutral-700">
                  {message.text}
                </p>
                {(message.attachments ?? []).length > 0 ? (
                  <ul className="mt-2 flex flex-wrap gap-2">
                    {(message.attachments ?? []).map((key) => {
                      const href = resolveStorageUrl(key);
                      const name = storageFileNameFromKey(key);
                      return (
                        <li key={key}>
                          {href ? (
                            <a
                              href={href}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="inline-flex items-center gap-1 rounded-md border border-stroke px-2 py-1 text-body-sm text-primary hover:underline"
                            >
                              <Icon icon={Paperclip} size={14} />
                              {name}
                            </a>
                          ) : (
                            <span className="inline-flex items-center gap-1 rounded-md border border-stroke px-2 py-1 text-body-sm text-neutral-500">
                              <Icon icon={Paperclip} size={14} />
                              {name}
                            </span>
                          )}
                        </li>
                      );
                    })}
                  </ul>
                ) : null}
              </div>
            </li>
          ))}
        </ul>
      )}

      <PermissionGate
        permission={PERM.supportCreate}
        fallback={<p className="text-body-sm text-neutral-500">{t('support.thread.readOnly')}</p>}
      >
        <div className="flex flex-col gap-2 border-t border-stroke pt-4">
          <Textarea
            label={t('support.thread.replyLabel')}
            value={text}
            maxLength={MAX_TEXT_LENGTH}
            onChange={(event) => setText(event.target.value)}
            placeholder={t('support.thread.replyPlaceholder')}
          />

          {attachments.map((attachment) => (
            <div
              key={attachment.key}
              className="flex items-center gap-2 rounded-md border border-stroke bg-surface px-3 py-2"
            >
              <Icon icon={Paperclip} size={14} className="text-neutral-500" />
              <span className="flex-1 truncate text-body-sm text-neutral-700">
                {attachment.filename}
              </span>
              <IconButton
                icon={X}
                size="sm"
                variant="ghost"
                aria-label={t('support.thread.removeAttachment')}
                onClick={() =>
                  setAttachments((previous) => previous.filter((a) => a.key !== attachment.key))
                }
              />
            </div>
          ))}

          {attachOpen && attachments.length < MAX_ATTACHMENTS ? (
            <FileUpload
              kind="chat"
              label={t('support.thread.attachmentLabel')}
              onPresign={presignFile}
              onUploaded={(result) => {
                setAttachments((previous) => [...previous, result]);
                setAttachOpen(false);
              }}
              onError={(message) => toast.show({ variant: 'error', message })}
            />
          ) : null}

          <div className="flex items-center justify-between gap-2">
            <Button
              variant="secondary"
              iconLeft={<Icon icon={Paperclip} size={16} />}
              disabled={attachments.length >= MAX_ATTACHMENTS}
              onClick={() => setAttachOpen((value) => !value)}
            >
              {t('support.thread.attach')}
            </Button>
            <Button
              onClick={() => void handleSend()}
              loading={sendMutation.isPending}
              disabled={!canSubmit}
            >
              {t('support.thread.send')}
            </Button>
          </div>
        </div>
      </PermissionGate>
    </div>
  );
}

export default SupportThread;
