import type { ReactNode } from 'react';

export type BadgeTone = 'success' | 'warning' | 'error' | 'neutral' | 'info';

export interface BadgeProps {
  tone?: BadgeTone;
  /** `dot` — Online/Offline kabi holatlar uchun (fe-design-system §6). */
  variant?: 'soft' | 'dot';
  children: ReactNode;
  className?: string;
}

const SOFT_CLASSES: Record<BadgeTone, string> = {
  success: 'bg-success-bg text-success-dark',
  warning: 'bg-warning-bg text-warning-dark',
  error: 'bg-error-bg text-error-dark',
  neutral: 'bg-neutral-100 text-neutral-600',
  info: 'bg-light text-decorative-blue',
};

const DOT_CLASSES: Record<BadgeTone, string> = {
  success: 'bg-success-base',
  warning: 'bg-warning-base',
  error: 'bg-error-base',
  neutral: 'bg-neutral-400',
  info: 'bg-decorative-blue',
};

/** Domenni bilmaydi — faqat `tone` + matn (rang yagona ma'no manbai emas). */
export function Badge({ tone = 'neutral', variant = 'soft', children, className }: BadgeProps) {
  if (variant === 'dot') {
    return (
      <span
        className={`inline-flex items-center gap-1.5 text-body-sm font-medium text-neutral-700 ${className ?? ''}`}
      >
        <span className={`h-2 w-2 rounded-full ${DOT_CLASSES[tone]}`} aria-hidden="true" />
        {children}
      </span>
    );
  }

  return (
    <span
      className={`inline-flex items-center rounded-sm px-2 py-0.5 text-body-sm font-medium ${SOFT_CLASSES[tone]} ${className ?? ''}`}
    >
      {children}
    </span>
  );
}

export default Badge;
