import { useEffect, useId, useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';

import { Modal } from '@/components/ui/Modal';

export interface ConfirmDialogProps {
  open: boolean;
  onClose: () => void;
  /** `reason` faqat `requireReason` bo'lsa yuboriladi. */
  onConfirm: (reason?: string) => void;
  title?: ReactNode;
  description: ReactNode;
  /** Destruktiv amal (Delete) uchun `danger` (fe-screens §4). */
  variant?: 'default' | 'danger';
  confirmLabel?: string;
  cancelLabel?: string;
  loading?: boolean;
  /** Sabab majburiy bo'lgan holat (masalan, log edit request) uchun matn maydoni. */
  requireReason?: boolean;
  reasonLabel?: string;
}

/** `role="alertdialog"` — tasdiqlash/destruktiv amallar uchun (fe-screens §4). */
export function ConfirmDialog({
  open,
  onClose,
  onConfirm,
  title,
  description,
  variant = 'default',
  confirmLabel,
  cancelLabel,
  loading = false,
  requireReason = false,
  reasonLabel,
}: ConfirmDialogProps) {
  const { t } = useTranslation();
  const uid = useId();
  const descriptionId = `${uid}-description`;
  const reasonFieldId = `${uid}-reason`;
  const reasonErrorId = `${uid}-reason-error`;

  const [reason, setReason] = useState('');
  const [reasonError, setReasonError] = useState<'required' | 'length' | null>(null);

  useEffect(() => {
    if (!open) {
      setReason('');
      setReasonError(null);
    }
  }, [open]);

  const REASON_MIN_LENGTH = 3;
  const REASON_MAX_LENGTH = 500;

  const handleConfirm = () => {
    if (requireReason) {
      const trimmed = reason.trim();
      if (trimmed.length === 0) {
        setReasonError('required');
        return;
      }
      if (trimmed.length < REASON_MIN_LENGTH || trimmed.length > REASON_MAX_LENGTH) {
        setReasonError('length');
        return;
      }
    }
    onConfirm(requireReason ? reason.trim() : undefined);
  };

  const confirmToneClasses =
    variant === 'danger'
      ? 'bg-error-base text-white hover:bg-error-dark'
      : 'bg-primary text-white hover:bg-primary-hover';

  return (
    <Modal
      open={open}
      onClose={onClose}
      role="alertdialog"
      title={title ?? t('ui.overlay.confirmDialog.title')}
      describedById={descriptionId}
      closeOnBackdrop={!loading}
      footer={
        <>
          <button
            type="button"
            className="rounded-md border border-stroke px-4 py-2 text-body font-medium text-neutral-700 hover:bg-surface-muted disabled:cursor-not-allowed disabled:opacity-50"
            onClick={onClose}
            disabled={loading}
          >
            {cancelLabel ?? t('common.actions.cancel')}
          </button>
          <button
            type="button"
            className={`rounded-md px-4 py-2 text-body font-medium disabled:cursor-not-allowed disabled:opacity-50 ${confirmToneClasses}`}
            onClick={handleConfirm}
            disabled={loading}
            aria-busy={loading}
          >
            {confirmLabel ?? t('common.actions.confirm')}
          </button>
        </>
      }
    >
      <p id={descriptionId} className="text-body text-neutral-700">
        {description}
      </p>
      {requireReason ? (
        <div className="mt-4">
          <label
            htmlFor={reasonFieldId}
            className="mb-1 block text-body-sm font-medium text-neutral-700"
          >
            {reasonLabel ?? t('ui.overlay.confirmDialog.reasonLabel')}{' '}
            <span aria-hidden="true">*</span>
          </label>
          <textarea
            id={reasonFieldId}
            required
            aria-required="true"
            aria-invalid={reasonError !== null}
            aria-describedby={reasonError ? reasonErrorId : undefined}
            value={reason}
            onChange={(event) => {
              setReason(event.target.value);
              if (reasonError) {
                setReasonError(null);
              }
            }}
            rows={3}
            className="w-full rounded-md border border-stroke px-3 py-2 text-body focus-visible:outline focus-visible:outline-2 focus-visible:outline-primary"
          />
          {reasonError ? (
            <p id={reasonErrorId} role="alert" className="mt-1 text-body-sm text-error-dark">
              {reasonError === 'required'
                ? t('ui.overlay.confirmDialog.reasonRequired')
                : t('ui.overlay.confirmDialog.reasonLength', {
                    min: REASON_MIN_LENGTH,
                    max: REASON_MAX_LENGTH,
                  })}
            </p>
          ) : null}
        </div>
      ) : null}
    </Modal>
  );
}

export default ConfirmDialog;
