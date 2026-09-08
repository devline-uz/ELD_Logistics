/**
 * Full feedback text modal (F137) — the list truncates long text, the row
 * click opens this modal with the same row data (no detail endpoint exists,
 * `api/queries/feedback.ts`). No reply action: feedback is never answered.
 */
import { useTranslation } from 'react-i18next';
import { Star } from 'lucide-react';

import type { Feedback } from '@/api/types';
import { Button } from '@/components/ui/Button';
import { Icon } from '@/components/ui/Icon';
import { Modal } from '@/components/ui/Modal';
import { useDateFormat } from '@/hooks/useDateFormat';
import { NA } from '@/lib/format';

export interface FeedbackDetailModalProps {
  feedback: Feedback | undefined;
  onClose: () => void;
}

export function FeedbackDetailModal({ feedback, onClose }: FeedbackDetailModalProps) {
  const { t } = useTranslation();
  const dateFormat = useDateFormat();

  return (
    <Modal
      open={Boolean(feedback)}
      onClose={onClose}
      title={feedback?.driver_name ?? t('common.na')}
      footer={
        <Button variant="secondary" onClick={onClose}>
          {t('common.actions.close')}
        </Button>
      }
    >
      {feedback ? (
        <div className="flex flex-col gap-3">
          <div className="flex items-center gap-1" aria-label={t('feedback.detail.rating')}>
            {Array.from({ length: 5 }, (_, index) => (
              <Icon
                key={index}
                icon={Star}
                size={16}
                className={
                  typeof feedback.app_rating === 'number' && index < feedback.app_rating
                    ? 'fill-warning-base text-warning-base'
                    : 'text-neutral-300'
                }
              />
            ))}
            <span className="ms-1 text-body-sm text-neutral-500">
              {typeof feedback.app_rating === 'number' ? feedback.app_rating : NA}
            </span>
          </div>

          <p className="whitespace-pre-wrap text-body text-neutral-800">{feedback.text ?? NA}</p>

          <p className="text-body-sm text-neutral-500">
            {t('feedback.detail.submittedOn', {
              date: dateFormat.formatDateTime(feedback.submitted_at),
            })}
          </p>
        </div>
      ) : null}
    </Modal>
  );
}

export default FeedbackDetailModal;
