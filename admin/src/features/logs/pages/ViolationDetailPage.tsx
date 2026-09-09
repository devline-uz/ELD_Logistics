/**
 * Violation detail — `/violations/:violationId` (3.13, 7.4.6).
 *
 * Tur tavsifi, HOS konteksti (`details`), tegishli daily log'ga havola,
 * `resolved_at`/`resolved_reason`. **F105**: hech qanday `Delete`/`Resolve`
 * amali yo'q — bu faqat ko'rish ekrani.
 */
import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useParams } from 'react-router-dom';

import { useViolation } from '@/api/queries/violations';
import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { useDateFormat } from '@/hooks/useDateFormat';

function Field({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div>
      <dt className="text-body-sm text-neutral-600">{label}</dt>
      <dd className="text-body text-neutral-900">{value}</dd>
    </div>
  );
}

export function ViolationDetailPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { violationId } = useParams<{ violationId: string }>();
  const dateFormat = useDateFormat();

  const violation = useViolation(violationId);

  if (violation.isLoading) {
    return <Skeleton variant="card" count={4} />;
  }

  if (violation.isError || !violation.data) {
    return (
      <ErrorState
        title={t('errors.notFound')}
        message={t('logs.violationDetail.notFound')}
        onRetry={() => void violation.refetch()}
      />
    );
  }

  const data = violation.data;

  return (
    <div className="flex flex-col gap-4">
      <Breadcrumb
        items={[
          { label: t('logs.violationsList.title'), href: '/violations' },
          { label: t(`logs.violations.type.${data.type}`) },
        ]}
      />

      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-h3 font-bold text-neutral-900">
          {t(`logs.violations.type.${data.type}`)}
        </h1>
        <Badge tone={data.severity === 'violation' ? 'error' : 'warning'}>
          {t(`logs.violationsList.severity.${data.severity ?? 'warning'}`)}
        </Badge>
      </div>

      <dl className="grid grid-cols-1 gap-4 rounded-lg border border-stroke p-4 sm:grid-cols-2 lg:grid-cols-3">
        <Field
          label={t('logs.violationDetail.fields.driver')}
          value={data.driver_name ?? t('common.na')}
        />
        <Field
          label={t('logs.violationDetail.fields.unit')}
          value={data.unit_id ?? t('common.na')}
        />
        <Field
          label={t('logs.violationDetail.fields.logDate')}
          value={dateFormat.formatDate(data.log_date)}
        />
        <Field
          label={t('logs.violationDetail.fields.occurredAt')}
          value={dateFormat.formatDateTime(data.occurred_at)}
        />
        <Field
          label={t('logs.violationDetail.fields.limit')}
          value={dateFormat.formatDuration(data.details?.limit_min ?? null)}
        />
        <Field
          label={t('logs.violationDetail.fields.remaining')}
          value={dateFormat.formatDuration(data.details?.remaining_min ?? null)}
        />
        <Field
          label={t('logs.violationDetail.fields.note')}
          value={data.details?.note ?? t('common.na')}
        />
        <Field
          label={t('logs.violationDetail.fields.resolvedAt')}
          value={
            data.resolved_at ? (
              <Badge tone="success">{dateFormat.formatDateTime(data.resolved_at)}</Badge>
            ) : (
              t('common.na')
            )
          }
        />
        <Field
          label={t('logs.violationDetail.fields.resolvedReason')}
          value={data.resolved_reason ?? t('common.na')}
        />
      </dl>

      {data.daily_log_id ? (
        <div>
          <Button variant="secondary" onClick={() => navigate(`/logs/view/${data.daily_log_id}`)}>
            {t('logs.violationDetail.openLog')}
          </Button>
        </div>
      ) : null}
    </div>
  );
}

export default ViolationDetailPage;
