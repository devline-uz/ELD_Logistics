import { useEffect, useRef, type RefObject } from 'react';

const FOCUSABLE_SELECTOR =
  'a[href], button:not([disabled]), textarea:not([disabled]), input:not([disabled]), select:not([disabled]), [tabindex]:not([tabindex="-1"])';

/**
 * Modal/Drawer/ConfirmDialog umumiy fokus boshqaruvi (fe-a11y §1, §4).
 *
 * - ochilganda konteyner ichidagi birinchi fokuslanadigan elementga fokus beradi
 * - `Tab`/`Shift+Tab` konteyner ichida aylanadi (focus trap)
 * - `Escape` — `onClose` chaqiradi
 * - yopilganda ochilishdan oldingi fokusni chaqirgan elementga tiklaydi
 * - sahifa scroll'i bloklanadi, orqa fon (`#root`) `aria-hidden` bo'ladi
 */
export function useFocusTrap(
  active: boolean,
  containerRef: RefObject<HTMLElement>,
  onClose: () => void,
): void {
  const previouslyFocused = useRef<HTMLElement | null>(null);
  const onCloseRef = useRef(onClose);

  useEffect(() => {
    onCloseRef.current = onClose;
  });

  useEffect(() => {
    if (!active) {
      return;
    }

    previouslyFocused.current = document.activeElement as HTMLElement | null;
    const container = containerRef.current;
    const root = document.getElementById('root');
    const previousBodyOverflow = document.body.style.overflow;

    document.body.style.overflow = 'hidden';
    root?.setAttribute('aria-hidden', 'true');

    const getFocusable = (): HTMLElement[] =>
      container ? Array.from(container.querySelectorAll<HTMLElement>(FOCUSABLE_SELECTOR)) : [];

    // Boshlang'ich fokus — kontent (`[data-focus-scope]`) ichidagi birinchi
    // maydon (fe-screens §3: "birinchi maydonga fokus"), header/footer emas.
    const focusScope = container?.querySelector<HTMLElement>('[data-focus-scope]');
    const scopedFirst = focusScope?.querySelector<HTMLElement>(FOCUSABLE_SELECTOR);
    (scopedFirst ?? getFocusable()[0] ?? container)?.focus();

    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape') {
        event.stopPropagation();
        onCloseRef.current();
        return;
      }
      if (event.key !== 'Tab') {
        return;
      }
      const items = getFocusable();
      if (items.length === 0) {
        event.preventDefault();
        return;
      }
      const first = items[0]!;
      const last = items[items.length - 1]!;
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    }

    document.addEventListener('keydown', handleKeyDown, true);

    return () => {
      document.removeEventListener('keydown', handleKeyDown, true);
      document.body.style.overflow = previousBodyOverflow;
      root?.removeAttribute('aria-hidden');
      previouslyFocused.current?.focus();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps -- containerRef obyekt sifatida barqaror
  }, [active]);
}
