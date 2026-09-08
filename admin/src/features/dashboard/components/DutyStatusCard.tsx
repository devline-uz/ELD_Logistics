import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';

import type { DashboardStatusBlock } from '@/api/types';
import { Skeleton } from '@/components/feedback/Skeleton';
import { NA } from '@/lib/format';

export interface DutyStatusCardProps {
  status: DashboardStatusBlock | undefined;
  loading: boolean;
}

/** §7.2 "Status bloki (beshinchi karta)" — 4 raqam + rangli nuqta (fe-design-system §1 semantik xarita). */
const DUTY_STATUS_ITEMS = [
  { key: 'dr', field: 'dr', dot: 'bg-success-base' },
  { key: 'on', field: 'on', dot: 'bg-warning-base' },
  { key: 'sb', field: 'sb', dot: 'bg-decorative-purple' },
  { key: 'off', field: 'off', dot: 'bg-neutral-500' },
] as const satisfies readonly { key: string; field: keyof DashboardStatusBlock; dot: string }[];

/** KPI grid'ining "beshinchi kartasi" — bosilganda `/tracking?duty_status=…` (§7.2). */
export function DutyStatusCard({ status, loading }: DutyStatusCardProps) {
  const { t } = useTranslation();

  return (
    <div
      className="overflow-hidden rounded-xl border border-stroke bg-surface shadow-card"
      aria-busy={loading}
    >
      <div className="p-5">
        <p className="truncate text-body-sm font-medium uppercase tracking-wide text-neutral-500">
          {t('dashboard.status.title')}
        </p>
        {loading ? (
          <div className="mt-3">
            <Skeleton variant="text" count={4} />
          </div>
        ) : (
          <ul className="mt-3 flex flex-col gap-1.5">
            {DUTY_STATUS_ITEMS.map((item) => {
              const label = t(`dashboard.status.${item.key}`);
              const count = status?.[item.field];
              return (
                <li key={item.key}>
                  <Link
                    to={`/tracking?duty_status=${item.key.toUpperCase()}`}
                    aria-label={t('dashboard.status.linkAriaLabel', { label, count: count ?? 0 })}
                    className="flex items-center justify-between gap-2 rounded-md px-1 py-0.5 text-body-sm hover:bg-surface-muted focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary"
                  >
                    <span className="flex items-center gap-1.5 text-neutral-700">
                      <span className={`h-2 w-2 rounded-full ${item.dot}`} aria-hidden="true" />
                      {label}
                    </span>
                    <span className="font-semibold text-neutral-900">
                      {typeof count === 'number' ? count : NA}
                    </span>
                  </Link>
                </li>
              );
            })}
          </ul>
        )}
      </div>
    </div>
  );
}

export default DutyStatusCard;
