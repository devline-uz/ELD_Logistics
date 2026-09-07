import { Loader2 } from 'lucide-react';
import { useTranslation } from 'react-i18next';

export interface SpinnerProps {
  size?: 'sm' | 'md' | 'lg';
  /** Skrin-rider matni — berilmasa `common.states.loading`. */
  label?: string;
  /** To'liq ekranli konteynerga o'raladi (markazlashtirilgan). */
  fullScreen?: boolean;
}

const SIZE_CLASSES: Record<NonNullable<SpinnerProps['size']>, string> = {
  sm: 'h-4 w-4',
  md: 'h-6 w-6',
  lg: 'h-10 w-10',
};

/** Inline va to'liq ekranli spinner, `role="status"` (fe-a11y §2). */
export function Spinner({ size = 'md', label, fullScreen = false }: SpinnerProps) {
  const { t } = useTranslation();
  const accessibleLabel = label ?? t('common.states.loading');

  const spinner = (
    <span role="status" aria-live="polite" className="inline-flex items-center gap-2">
      <Loader2
        aria-hidden="true"
        className={`motion-safe:animate-spin text-primary ${SIZE_CLASSES[size]}`}
      />
      <span className="sr-only">{accessibleLabel}</span>
    </span>
  );

  if (!fullScreen) {
    return spinner;
  }

  return <div className="flex min-h-[12rem] w-full items-center justify-center">{spinner}</div>;
}

export default Spinner;
