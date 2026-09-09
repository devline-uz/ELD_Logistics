import type { ReactNode } from 'react';
import { ArrowDown, ArrowUp } from 'lucide-react';

import { Skeleton } from '@/components/feedback/Skeleton';

export interface KpiCardDelta {
  /** Tayyor, formatlangan matn (masalan `+4.2%`) — chaqiruvchi hisoblaydi. */
  value: string;
  direction?: 'up' | 'down' | 'neutral';
}

export interface KpiCardProps {
  label: string;
  value: ReactNode;
  delta?: KpiCardDelta;
  icon?: ReactNode;
  tone?: 'primary' | 'success' | 'warning' | 'error' | 'info' | 'neutral';
  loading?: boolean;
}

const TONE_LINE_CLASSES: Record<NonNullable<KpiCardProps['tone']>, string> = {
  primary: 'bg-primary',
  success: 'bg-success-base',
  warning: 'bg-warning-base',
  error: 'bg-error-base',
  info: 'bg-decorative-blue',
  neutral: 'bg-neutral-400',
};

const DELTA_CLASSES: Record<NonNullable<KpiCardDelta['direction']>, string> = {
  up: 'text-success-dark',
  down: 'text-error-dark',
  neutral: 'text-neutral-600',
};

/** Sarlavha + qiymat + delta + ikonka + pastki rangli chiziq; yuklanishda skeleton (fe-design-system §6). */
export function KpiCard({
  label,
  value,
  delta,
  icon,
  tone = 'primary',
  loading = false,
}: KpiCardProps) {
  const direction = delta?.direction ?? 'neutral';

  return (
    <div
      className="overflow-hidden rounded-xl border border-stroke bg-surface shadow-card"
      aria-busy={loading}
    >
      <div className="flex items-start justify-between gap-3 p-5">
        <div className="min-w-0 flex-1">
          <p className="truncate text-body-sm font-medium uppercase tracking-wide text-neutral-600">
            {label}
          </p>
          {loading ? (
            <div className="mt-2">
              <Skeleton variant="text" />
            </div>
          ) : (
            <p className="mt-1 text-h3 font-bold text-neutral-900">{value}</p>
          )}
          {delta && !loading ? (
            <p
              className={`mt-1 flex items-center gap-1 text-body-sm font-medium ${DELTA_CLASSES[direction]}`}
            >
              {direction === 'up' ? <ArrowUp aria-hidden="true" className="h-3.5 w-3.5" /> : null}
              {direction === 'down' ? (
                <ArrowDown aria-hidden="true" className="h-3.5 w-3.5" />
              ) : null}
              <span>{delta.value}</span>
            </p>
          ) : null}
        </div>
        {icon ? (
          <div className="text-neutral-400" aria-hidden="true">
            {icon}
          </div>
        ) : null}
      </div>
      <div className={`h-1 w-full ${TONE_LINE_CLASSES[tone]}`} />
    </div>
  );
}

export default KpiCard;
