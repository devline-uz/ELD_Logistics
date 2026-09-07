import {
  cloneElement,
  useId,
  useState,
  type FocusEvent,
  type KeyboardEvent,
  type MouseEvent,
  type ReactElement,
  type ReactNode,
} from 'react';

export interface TooltipProps {
  content: ReactNode;
  /** Yagona farzand — `aria-describedby`/hodisalar shu elementga qo'shiladi. */
  children: ReactElement;
  placement?: 'top' | 'bottom' | 'left' | 'right';
}

interface TriggerHandlerProps {
  onMouseEnter?: (event: MouseEvent) => void;
  onMouseLeave?: (event: MouseEvent) => void;
  onFocus?: (event: FocusEvent) => void;
  onBlur?: (event: FocusEvent) => void;
  onKeyDown?: (event: KeyboardEvent) => void;
}

const PLACEMENT_CLASSES: Record<NonNullable<TooltipProps['placement']>, string> = {
  top: 'bottom-full left-1/2 mb-2 -translate-x-1/2',
  bottom: 'top-full left-1/2 mt-2 -translate-x-1/2',
  left: 'right-full top-1/2 mr-2 -translate-y-1/2',
  right: 'left-full top-1/2 ml-2 -translate-y-1/2',
};

/**
 * Klaviatura fokusida ham ochiladi (faqat hover emas), `Escape` yopadi
 * (fe-a11y §1). Tooltip ma'lumotning yagona manbai bo'lmasligi kerak —
 * chaqiruvchi ekran shu matnni boshqa joyda ham (masalan jadval hujayrasida)
 * ko'rsatishi kerak.
 */
export function Tooltip({ content, children, placement = 'top' }: TooltipProps) {
  const [visible, setVisible] = useState(false);
  const id = useId();

  const triggerProps = children.props as TriggerHandlerProps;

  const trigger = cloneElement(children, {
    'aria-describedby': id,
    onMouseEnter: (event: MouseEvent) => {
      triggerProps.onMouseEnter?.(event);
      setVisible(true);
    },
    onMouseLeave: (event: MouseEvent) => {
      triggerProps.onMouseLeave?.(event);
      setVisible(false);
    },
    onFocus: (event: FocusEvent) => {
      triggerProps.onFocus?.(event);
      setVisible(true);
    },
    onBlur: (event: FocusEvent) => {
      triggerProps.onBlur?.(event);
      setVisible(false);
    },
    onKeyDown: (event: KeyboardEvent) => {
      triggerProps.onKeyDown?.(event);
      if (event.key === 'Escape') {
        setVisible(false);
      }
    },
  } as Partial<TriggerHandlerProps & { 'aria-describedby': string }>);

  return (
    <span className="relative inline-block">
      {trigger}
      {visible ? (
        <span
          role="tooltip"
          id={id}
          className={`pointer-events-none absolute z-50 whitespace-nowrap rounded-sm bg-neutral-800 px-2 py-1 text-body-xs text-white shadow-dropdown ${PLACEMENT_CLASSES[placement]}`}
        >
          {content}
        </span>
      ) : null}
    </span>
  );
}

export default Tooltip;
