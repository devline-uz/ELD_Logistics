/**
 * Ustun ko'rsatish/yashirish paneli — `⚙` tugmasi ochadi (fe-screens §1).
 * Saqlash (`localStorage`) `DataTable` tomonida boshqariladi — bu komponent
 * faqat taqdim etilgan holatni ko'rsatadi va almashtirish hodisalarini beradi.
 */
import { useEffect, useRef, useState } from 'react';
import { Settings2 } from 'lucide-react';

import { Checkbox } from '@/components/ui/Checkbox';
import { IconButton } from '@/components/ui/IconButton';

import { useTranslation } from 'react-i18next';

export interface ColumnPickerColumn {
  id: string;
  label: string;
  /** `false` bo'lsa doim ko'rinadi (yashirish taqiqlangan — masalan birinchi ustun). */
  hideable?: boolean;
}

export interface ColumnPickerProps {
  columns: ColumnPickerColumn[];
  visibility: Record<string, boolean>;
  onToggle: (id: string, visible: boolean) => void;
  onSelectAll: () => void;
  className?: string;
}

export function ColumnPicker({
  columns,
  visibility,
  onToggle,
  onSelectAll,
  className,
}: ColumnPickerProps) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const rootRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return undefined;
    const handleClickOutside = (event: MouseEvent) => {
      if (rootRef.current && !rootRef.current.contains(event.target as Node)) setOpen(false);
    };
    const handleEscape = (event: KeyboardEvent) => {
      if (event.key === 'Escape') setOpen(false);
    };
    document.addEventListener('mousedown', handleClickOutside);
    document.addEventListener('keydown', handleEscape);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
      document.removeEventListener('keydown', handleEscape);
    };
  }, [open]);

  const allVisible = columns.every((column) => visibility[column.id] !== false);
  const someVisible = columns.some((column) => visibility[column.id] !== false);

  return (
    <div className={`relative inline-block ${className ?? ''}`} ref={rootRef}>
      <IconButton
        icon={Settings2}
        aria-label={t('ui.data.columnPicker.trigger')}
        variant="secondary"
        onClick={() => setOpen((prev) => !prev)}
        aria-haspopup="true"
        aria-expanded={open}
      />

      {open ? (
        <div
          role="menu"
          aria-label={t('ui.data.columnPicker.trigger')}
          className="absolute end-0 z-20 mt-1 w-56 rounded-md border border-stroke bg-surface p-2 shadow-dropdown"
        >
          <div className="border-b border-stroke px-2 py-2">
            <Checkbox
              checked={allVisible}
              indeterminate={!allVisible && someVisible}
              onChange={() => onSelectAll()}
              label={t('ui.form.actions.selectAll')}
            />
          </div>

          <ul className="mt-1 max-h-64 overflow-auto">
            {columns.map((column) => (
              <li key={column.id} className="px-2 py-1.5">
                <Checkbox
                  checked={visibility[column.id] !== false}
                  disabled={column.hideable === false}
                  onChange={(event) => onToggle(column.id, event.target.checked)}
                  label={column.label}
                />
              </li>
            ))}
          </ul>
        </div>
      ) : null}
    </div>
  );
}
