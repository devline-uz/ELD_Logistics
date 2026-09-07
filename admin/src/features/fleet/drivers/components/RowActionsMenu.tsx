/**
 * Qator amallari menyusi (`···`) — Driver/User/Role ro'yxatlarida umumiy
 * (fe-screens §1). `components/ui`da tayyor `Menu`/`Dropdown` topilmadi —
 * bu agent shu vaqtinchalik oddiy implementatsiyani `features/fleet/drivers`
 * ichida yozdi (fleet ichidagi `drivers`/`users`/`roles` bir-biridan import
 * qilishi ESLint bo'yicha ruxsat etilgan — chegara `features/<top-level>`
 * darajasida). Hisobotda `components/ui/Menu` sifatida umumiy komponentga
 * ko'chirish taklif qilinadi.
 */
import { useEffect, useRef, useState, type ReactNode } from 'react';
import { MoreVertical } from 'lucide-react';
import { useTranslation } from 'react-i18next';

import { IconButton } from '@/components/ui/IconButton';

export interface RowAction {
  key: string;
  label: string;
  onSelect: () => void;
  disabled?: boolean;
  disabledReason?: string;
  danger?: boolean;
}

export interface RowActionsMenuProps {
  actions: RowAction[];
  ariaLabel?: string;
}

export function RowActionsMenu({ actions, ariaLabel }: RowActionsMenuProps) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const rootRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return undefined;
    const handleClick = (event: MouseEvent) => {
      if (rootRef.current && !rootRef.current.contains(event.target as Node)) {
        setOpen(false);
      }
    };
    const handleKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') setOpen(false);
    };
    document.addEventListener('mousedown', handleClick);
    document.addEventListener('keydown', handleKey);
    return () => {
      document.removeEventListener('mousedown', handleClick);
      document.removeEventListener('keydown', handleKey);
    };
  }, [open]);

  if (actions.length === 0) {
    return null;
  }

  let menu: ReactNode = null;
  if (open) {
    menu = (
      <div
        role="menu"
        className="absolute right-0 z-20 mt-1 w-48 rounded-md border border-stroke bg-surface py-1 shadow-modal"
      >
        {actions.map((action) => (
          <button
            key={action.key}
            type="button"
            role="menuitem"
            disabled={action.disabled}
            title={action.disabled ? action.disabledReason : undefined}
            onClick={() => {
              setOpen(false);
              action.onSelect();
            }}
            className={`block w-full px-3 py-2 text-start text-body-sm hover:bg-surface-muted disabled:cursor-not-allowed disabled:opacity-50 ${
              action.danger ? 'text-error-dark' : 'text-neutral-800'
            }`}
          >
            {action.label}
          </button>
        ))}
      </div>
    );
  }

  return (
    <div ref={rootRef} className="relative inline-block">
      <IconButton
        icon={MoreVertical}
        variant="ghost"
        size="sm"
        aria-label={ariaLabel ?? t('ui.data.dataTable.rowActions')}
        aria-haspopup="menu"
        aria-expanded={open}
        onClick={(event) => {
          event.stopPropagation();
          setOpen((value) => !value);
        }}
      />
      {menu}
    </div>
  );
}

export default RowActionsMenu;
