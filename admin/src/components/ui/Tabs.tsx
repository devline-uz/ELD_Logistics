import { useRef, type KeyboardEvent } from 'react';

export interface TabItem {
  id: string;
  label: string;
  disabled?: boolean;
}

export interface TabsProps {
  tabs: TabItem[];
  activeId: string;
  onChange: (id: string) => void;
  ariaLabel: string;
  /** `aria-controls`/`id` prefiksi — panelni chaqiruvchi ekran render qiladi. */
  idPrefix?: string;
}

/**
 * Pastki chiziqli, `role="tablist"` + o'q tugmalari bilan navigatsiya
 * (fe-design-system §6, fe-a11y §2). URL bilan bog'lanmaydi — buni chaqiruvchi
 * ekran hal qiladi.
 */
export function Tabs({ tabs, activeId, onChange, ariaLabel, idPrefix = 'tab' }: TabsProps) {
  const buttonRefs = useRef<Record<string, HTMLButtonElement | null>>({});
  const enabledIds = tabs.filter((tab) => !tab.disabled).map((tab) => tab.id);

  const selectAndFocus = (id: string) => {
    onChange(id);
    buttonRefs.current[id]?.focus();
  };

  const handleKeyDown = (event: KeyboardEvent<HTMLButtonElement>, tab: TabItem) => {
    if (enabledIds.length === 0) {
      return;
    }
    const currentIndex = enabledIds.indexOf(tab.id);
    let nextIndex = currentIndex;
    if (event.key === 'ArrowRight') {
      nextIndex = (currentIndex + 1) % enabledIds.length;
    } else if (event.key === 'ArrowLeft') {
      nextIndex = (currentIndex - 1 + enabledIds.length) % enabledIds.length;
    } else if (event.key === 'Home') {
      nextIndex = 0;
    } else if (event.key === 'End') {
      nextIndex = enabledIds.length - 1;
    } else {
      return;
    }
    event.preventDefault();
    selectAndFocus(enabledIds[nextIndex]!);
  };

  return (
    <div role="tablist" aria-label={ariaLabel} className="flex gap-4 border-b border-stroke">
      {tabs.map((tab) => {
        const selected = tab.id === activeId;
        return (
          <button
            key={tab.id}
            ref={(el) => {
              buttonRefs.current[tab.id] = el;
            }}
            role="tab"
            type="button"
            id={`${idPrefix}-${tab.id}`}
            aria-selected={selected}
            aria-controls={`${idPrefix}panel-${tab.id}`}
            disabled={tab.disabled}
            tabIndex={selected ? 0 : -1}
            className={`border-b-2 px-1 pb-3 text-body font-medium disabled:cursor-not-allowed disabled:opacity-50 ${
              selected
                ? 'border-primary text-primary'
                : 'border-transparent text-neutral-500 hover:text-neutral-700'
            }`}
            onClick={() => {
              onChange(tab.id);
            }}
            onKeyDown={(event) => {
              handleKeyDown(event, tab);
            }}
          >
            {tab.label}
          </button>
        );
      })}
    </div>
  );
}

export default Tabs;
