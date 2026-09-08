/**
 * Qator `···` amallar menyusi (fe-screens §1). Ro'yxat ekranlaridagi barcha
 * modullar (Units, ELD Devices, Trailers, Shipping Documents, Drivers,
 * Users, Roles) shu umumiy komponentdan foydalanadi — oldin har biri o'z
 * nusxasini saqlagan edi (bosqich 2 ko'rigi — dublikat topilmasi).
 */
import { useEffect, useRef, useState, type ReactNode } from 'react';
import { MoreVertical } from 'lucide-react';
import { useTranslation } from 'react-i18next';

import { IconButton } from '@/components/ui/IconButton';

export interface RowActionItem {
  key: string;
  label: string;
  onSelect: () => void;
  danger?: boolean;
  disabled?: boolean;
  disabledReason?: string;
}

export interface RowActionsMenuProps {
  items: RowActionItem[];
  ariaLabel: string;
}

export function RowActionsMenu({ items, ariaLabel }: RowActionsMenuProps): ReactNode {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const triggerRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    if (!open) return undefined;

    function handlePointerDown(event: MouseEvent) {
      if (!containerRef.current?.contains(event.target as Node)) {
        setOpen(false);
      }
    }
    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape') {
        setOpen(false);
        triggerRef.current?.focus();
      }
    }

    document.addEventListener('mousedown', handlePointerDown);
    document.addEventListener('keydown', handleKeyDown);
    return () => {
      document.removeEventListener('mousedown', handlePointerDown);
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, [open]);

  if (items.length === 0) return null;

  return (
    <div ref={containerRef} className="relative inline-block text-start">
      <IconButton
        ref={triggerRef}
        icon={MoreVertical}
        variant="ghost"
        size="sm"
        aria-label={ariaLabel || t('common.actions.more')}
        aria-haspopup="menu"
        aria-expanded={open}
        onClick={(event) => {
          event.stopPropagation();
          setOpen((value) => !value);
        }}
      />
      {open ? (
        <div
          role="menu"
          aria-label={ariaLabel}
          className="absolute end-0 z-20 mt-1 w-48 rounded-md border border-stroke bg-surface py-1 shadow-modal"
        >
          {items.map((item) => (
            <button
              key={item.key}
              type="button"
              role="menuitem"
              disabled={item.disabled}
              title={item.disabled ? item.disabledReason : undefined}
              onClick={() => {
                setOpen(false);
                item.onSelect();
              }}
              className={`block w-full px-3 py-2 text-start text-body-sm hover:bg-surface-muted disabled:cursor-not-allowed disabled:opacity-50 ${
                item.danger ? 'text-error-dark' : 'text-neutral-700'
              }`}
            >
              {item.label}
            </button>
          ))}
        </div>
      ) : null}
    </div>
  );
}

export default RowActionsMenu;
