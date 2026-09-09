/**
 * Ticket detail — `/support/:id` (8.8, §7.10.1). `TICKET DETAILS`: Ticket #,
 * Status, Driver, Contact On, Issue Date, Subject, Description + thread
 * (F136) + status-change modal.
 *
 * Cross-tenant / another driver's ticket answers **404**, never 403
 * (fe-permissions §5) — rendered as `ErrorState` + `errors.notFound`.
 *
 * D39: the design's "Contact On / Email or Phone" field pair has no backend
 * counterpart beyond `contact_on` (the channel enum) — the ticket DTO
 * carries no separate email/phone value. Only the channel is shown; see
 * `docs/tz/16-17-registry-open-questions.md` D39.
 */
import { useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useParams } from 'react-router-dom';
import { Paperclip } from 'lucide-react';

import { useSupportTicketDetail } from '@/api/queries/support';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { Button } from '@/components/ui/Button';
import { Icon } from '@/components/ui/Icon';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { useDateFormat } from '@/hooks/useDateFormat';
import { NA } from '@/lib/format';
import { PERM } from '@/lib/permissions';
import { resolveStorageUrl, storageFileNameFromKey } from '@/lib/storage';

import { SupportStatusBadge } from '../components/SupportStatusBadge';
import { SupportStatusModal } from '../components/SupportStatusModal';
import { SupportThread } from '../components/SupportThread';
import { nextSupportTicketStatuses } from '../lib/status';

function Field({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div>
      <dt className="text-body-sm text-neutral-600">{label}</dt>
      <dd className="text-body text-neutral-900">{value}</dd>
    </div>
  );
}

export function SupportDetailPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const dateFormat = useDateFormat();
  const { id } = useParams<{ id: string }>();

  const ticket = useSupportTicketDetail(id);
  const [statusModalOpen, setStatusModalOpen] = useState(false);

  if (ticket.isLoading) {
    return <Skeleton variant="card" count={3} />;
  }

  if (ticket.isError || !ticket.data?.id) {
    return (
      <ErrorState
        title={t('errors.notFound')}
        message={t('support.detail.notFound')}
        onRetry={() => void ticket.refetch()}
      />
    );
  }

  const data = ticket.data;
  const ticketLabel = `#${data.id!.slice(0, 8).toUpperCase()}`;
  const canChangeStatus = nextSupportTicketStatuses(data.status).length > 0;
  const attachments = data.attachments ?? [];

  return (
    <div className="flex flex-col gap-4">
      <Breadcrumb
        items={[{ label: t('support.list.title'), href: '/support' }, { label: ticketLabel }]}
      />

      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <h1 className="text-h3 font-bold text-neutral-900">{ticketLabel}</h1>
          <SupportStatusBadge status={data.status} />
        </div>

        <PermissionGate permission={PERM.supportUpdateStatus}>
          <Button
            variant="secondary"
            disabled={!canChangeStatus}
            title={canChangeStatus ? undefined : t('support.detail.statusFinal')}
            onClick={() => setStatusModalOpen(true)}
          >
            {t('support.detail.actions.changeStatus')}
          </Button>
        </PermissionGate>
      </div>

      <section className="flex flex-col gap-4 rounded-lg border border-stroke bg-surface p-4">
        <h2 className="text-body-lg font-semibold text-neutral-900">
          {t('support.detail.sections.details')}
        </h2>
        <dl className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <Field label={t('support.detail.fields.driver')} value={data.driver_name ?? NA} />
          <Field
            label={t('support.detail.fields.contactOn')}
            value={
              data.contact_on ? t(`enums.support_contact_on.${data.contact_on}`) : t('common.na')
            }
          />
          <Field
            label={t('support.detail.fields.issueDate')}
            value={dateFormat.formatDateTime(data.created_at)}
          />
          <Field label={t('support.detail.fields.subject')} value={data.subject ?? NA} />
        </dl>
        <div>
          <dt className="text-body-sm text-neutral-600">
            {t('support.detail.fields.description')}
          </dt>
          <dd className="mt-1 whitespace-pre-wrap text-body text-neutral-800">
            {data.description ?? NA}
          </dd>
        </div>
        {attachments.length > 0 ? (
          <div>
            <dt className="text-body-sm text-neutral-600">
              {t('support.detail.fields.attachments')}
            </dt>
            <ul className="mt-1 flex flex-wrap gap-2">
              {attachments.map((key) => {
                const href = resolveStorageUrl(key);
                const name = storageFileNameFromKey(key);
                return (
                  <li key={key}>
                    {href ? (
                      <a
                        href={href}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-1 rounded-md border border-stroke px-2 py-1 text-body-sm text-primary hover:underline"
                      >
                        <Icon icon={Paperclip} size={14} />
                        {name}
                      </a>
                    ) : (
                      <span className="inline-flex items-center gap-1 rounded-md border border-stroke px-2 py-1 text-body-sm text-neutral-600">
                        <Icon icon={Paperclip} size={14} />
                        {name}
                      </span>
                    )}
                  </li>
                );
              })}
            </ul>
          </div>
        ) : null}
      </section>

      <section className="rounded-lg border border-stroke bg-surface p-4">
        <SupportThread ticketId={data.id!} />
      </section>

      <div>
        <Button variant="ghost" onClick={() => navigate('/support')}>
          {t('support.actions.back')}
        </Button>
      </div>

      <SupportStatusModal
        open={statusModalOpen}
        ticket={data}
        onClose={() => setStatusModalOpen(false)}
      />
    </div>
  );
}

export default SupportDetailPage;
