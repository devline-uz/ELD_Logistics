import { useId, useRef, type ReactNode } from 'react';
import { createPortal } from 'react-dom';
import { X } from 'lucide-react';
import { useTranslation } from 'react-i18next';

import { useFocusTrap } from '@/components/ui/Modal';

export interface DrawerProps {
  open: boolean;
  onClose: () => void;
  title: ReactNode;
  children: ReactNode;
  footer?: ReactNode;
  size?: 'sm' | 'md' | 'lg';
  closeOnBackdrop?: boolean;
}

const SIZE_CLASSES: Record<NonNullable<DrawerProps['size']>, string> = {
  sm: 'max-w-sm',
  md: 'max-w-md',
  lg: 'max-w-xl',
};

/**
 * O'ng tomondan chiquvchi panel — Modal bilan bir xil fokus/klaviatura qoidalari
 * (fe-design-system §6, fe-a11y §1/§4).
 */
export function Drawer({
  open,
  onClose,
  title,
  children,
  footer,
  size = 'md',
  closeOnBackdrop = true,
}: DrawerProps) {
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
      className="fixed inset-0 z-50 flex justify-end bg-neutral-900/40"
      onMouseDown={(event) => {
        if (closeOnBackdrop && event.target === event.currentTarget) {
          onClose();
        }
      }}
    >
      {/* Panel ichidagi klik backdrop'ga tarqalmasligi uchun (yopilib qolmasligi). */}
      {/* eslint-disable-next-line jsx-a11y/no-noninteractive-element-interactions */}
      <div
        ref={containerRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className={`flex h-full w-full ${SIZE_CLASSES[size]} flex-col bg-surface shadow-modal focus:outline-none`}
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
            className="rounded-md p-1 text-neutral-500 hover:bg-surface-muted hover:text-neutral-700"
            onClick={onClose}
            aria-label={t('common.actions.close')}
          >
            <X aria-hidden="true" className="h-5 w-5" />
          </button>
        </div>
        <div data-focus-scope className="flex-1 overflow-y-auto px-6 py-4">
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

export default Drawer;
