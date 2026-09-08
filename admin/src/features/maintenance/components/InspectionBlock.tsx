/**
 * `PRE-TRIP INSPECTION` / `POST-TRIP INSPECTION` bloklari (5.11, **F113**).
 *
 * Dizaynda bu bloklar bo'sh edi — o'sha unit uchun **o'sha sanadagi** DVIR'lar
 * bilan to'ldiriladi (`GET /dvir-reports?unit_id=&type=&from=&to=`), har biri
 * `/dvir/:id` ga havola.
 *
 * ⚠️ `features/dvir/**` ga bog'liqlik yo'q (ESLint `no-restricted-imports`) —
 * faqat `api/queries/dvir.ts` hooki va oddiy `Link` ishlatiladi.
 */
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';

import { useDvirList } from '@/api/queries/dvir';
import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { Badge } from '@/components/ui/Badge';
import { Card } from '@/components/ui/Card';
import { useDateFormat } from '@/hooks/useDateFormat';
import { NA } from '@/lib/format';

export interface InspectionBlockProps {
  type: 'pre_trip' | 'post_trip';
  unitId?: string;
  /** Texnik xizmat sanasi (ISO) — shu kunning boshi/oxiri oralig'i olinadi. */
  performedAt?: string;
}

/** ISO sanadan o'sha kunning `from`/`to` chegaralarini quradi (UTC). */
function dayRange(iso: string | undefined): { from?: string; to?: string } {
  if (!iso) return {};
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return {};
  const from = new Date(date);
  from.setUTCHours(0, 0, 0, 0);
  const to = new Date(date);
  to.setUTCHours(23, 59, 59, 999);
  return { from: from.toISOString(), to: to.toISOString() };
}

export function InspectionBlock({ type, unitId, performedAt }: InspectionBlockProps) {
  const { t } = useTranslation();
  const { formatDateTime } = useDateFormat();
  const range = dayRange(performedAt);

  const list = useDvirList(
    unitId ? { unit_id: unitId, type, from: range.from, to: range.to, per_page: 10 } : {},
  );

  const title = t(
    type === 'pre_trip' ? 'maintenance.inspections.preTrip' : 'maintenance.inspections.postTrip',
  );

  const reports = list.data?.data ?? [];

  return (
    <Card title={title}>
      {list.isLoading ? (
        <Skeleton variant="line" />
      ) : list.isError ? (
        <ErrorState
          message={list.error?.message ?? t('maintenance.inspections.error')}
          onRetry={() => void list.refetch()}
        />
      ) : reports.length === 0 ? (
        <EmptyState
          title={t('maintenance.empty.title')}
          description={t('maintenance.inspections.empty')}
        />
      ) : (
        <ul className="flex flex-col gap-2">
          {reports.map((report) => (
            <li
              key={report.id}
              className="flex items-center justify-between gap-4 border-b border-stroke pb-2 last:border-b-0"
            >
              <span className="flex items-center gap-3">
                <span className="text-body text-neutral-900">
                  {report.performed_at ? formatDateTime(report.performed_at) : NA}
                </span>
                <Badge tone={report.has_critical_defect ? 'error' : 'success'}>
                  {t('maintenance.inspections.defects', { count: report.defects?.length ?? 0 })}
                </Badge>
              </span>
              <Link
                to={`/dvir/${report.id ?? ''}`}
                className="text-body-sm text-primary hover:underline"
              >
                {t('maintenance.inspections.openReport')}
              </Link>
            </li>
          ))}
        </ul>
      )}
    </Card>
  );
}

export default InspectionBlock;
