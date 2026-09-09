import { useId, useRef, type ReactNode } from 'react';
import { createPortal } from 'react-dom';
import { X } from 'lucide-react';
import { useTranslation } from 'react-i18next';

import { useFocusTrap } from '@/hooks/useFocusTrap';

export interface ModalProps {
  open: boolean;
  onClose: () => void;
  title: ReactNode;
  children: ReactNode;
  footer?: ReactNode;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  /** ConfirmDialog `alertdialog` sifatida ochadi (fe-a11y). */
  role?: 'dialog' | 'alertdialog';
  /** Backdrop bosilganda yopiladimi (o'zgargan forma bo'lsa `false` qilib, tasdiq orqali yopiladi). */
  closeOnBackdrop?: boolean;
  describedById?: string;
}

const SIZE_CLASSES: Record<NonNullable<ModalProps['size']>, string> = {
  sm: 'max-w-sm',
  md: 'max-w-md',
  lg: 'max-w-lg',
  xl: 'max-w-2xl',
};

/** `role="dialog"` + `aria-modal`, focus trap, Escape va backdrop bilan yopiladi (fe-design-system §6). */
export function Modal({
  open,
  onClose,
  title,
  children,
  footer,
  size = 'md',
  role = 'dialog',
  closeOnBackdrop = true,
  describedById,
}: ModalProps) {
  const { t } = useTranslation();
  const titleId = useId();
  const containerRef = useRef<HTMLDivElement>(null);

  useFocusTrap(open, containerRef, onClose);

  if (!open) {
    return null;
  }

  return createPortal(
    // Backdrop — sichqoncha bilan yopish qulayligi; klaviatura funksionalligi
    // (Escape, X tugmasi) alohida ta'minlangan (fe-a11y §1).
    // eslint-disable-next-line jsx-a11y/no-static-element-interactions
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-neutral-900/40 p-4"
      onMouseDown={(event) => {
        if (closeOnBackdrop && event.target === event.currentTarget) {
          onClose();
        }
      }}
    >
      <div
        ref={containerRef}
        role={role}
        aria-modal="true"
        aria-labelledby={titleId}
        aria-describedby={describedById}
        tabIndex={-1}
        className={`flex max-h-[85vh] w-full ${SIZE_CLASSES[size]} flex-col rounded-xl bg-surface shadow-modal focus:outline-none`}
        onMouseDown={(event) => {
          event.stopPropagation();
        }}
      >
        <div className="flex shrink-0 items-start justify-between gap-4 border-b border-stroke px-6 py-4">
          <h2 id={titleId} className="text-h4 font-bold text-neutral-900">
            {title}
          </h2>
          <button
            type="button"
            className="rounded-md p-1 text-neutral-600 hover:bg-surface-muted hover:text-neutral-700"
            onClick={onClose}
            aria-label={t('common.actions.close')}
          >
            <X aria-hidden="true" className="h-5 w-5" />
          </button>
        </div>
        <div data-focus-scope className="overflow-y-auto px-6 py-4">
          {children}
        </div>
        {footer ? (
          <div className="flex shrink-0 justify-end gap-2 border-t border-stroke px-6 py-4">
            {footer}
          </div>
        ) : null}
      </div>
    </div>,
    document.body,
  );
}

export default Modal;
