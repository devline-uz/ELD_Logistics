/**
 * Status change modal — `Status` select + `Cancel`/`Save`
 * (`docs/tz/07-9-chat-support-audit.md` §7.10.1). Forward-only lifecycle:
 * only statuses reachable from the current one are offered
 * (`nextSupportTicketStatuses`). A `409 INVALID_STATE` response (race with
 * another admin) surfaces as a toast, the modal stays open (fe-screens §7 —
 * action-level error).
 */
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';

import { useSupportTicketStatusUpdate } from '@/api/queries/support';
import type { SupportTicket, SupportTicketStatusUpdate } from '@/api/types';
import { useToast } from '@/components/feedback/toast-context';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import { Select } from '@/components/ui/Select';
import { isApiError } from '@/lib/errors';

import { nextSupportTicketStatuses } from '../lib/status';

export interface SupportStatusModalProps {
  open: boolean;
  ticket: SupportTicket;
  onClose: () => void;
}

export function SupportStatusModal({ open, ticket, onClose }: SupportStatusModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const mutation = useSupportTicketStatusUpdate(ticket.id ?? '');

  const options = nextSupportTicketStatuses(ticket.status);
  const [status, setStatus] = useState<string | null>(options[0] ?? null);

  useEffect(() => {
    if (open) {
      setStatus(nextSupportTicketStatuses(ticket.status)[0] ?? null);
    }
  }, [open, ticket.status]);

  const handleSubmit = async () => {
    if (!status) return;
    try {
      await mutation.mutateAsync({ status } as SupportTicketStatusUpdate);
      toast.show({
        variant: 'success',
        message: t('support.statusModal.toast.updated', {
          subject: ticket.subject ?? t('common.na'),
        }),
      });
      onClose();
    } catch (error) {
      const message =
        isApiError(error) && error.code === 'INVALID_STATE'
          ? t('support.statusModal.errors.invalidState')
          : t('support.statusModal.errors.generic');
      toast.show({ variant: 'error', message });
    }
  };

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={t('support.statusModal.title')}
      closeOnBackdrop={!mutation.isPending}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={mutation.isPending}>
            {t('common.actions.cancel')}
          </Button>
          <Button
            onClick={() => void handleSubmit()}
            loading={mutation.isPending}
            disabled={!status}
          >
            {t('common.actions.save')}
          </Button>
        </>
      }
    >
      {options.length === 0 ? (
        <p className="text-body-sm text-neutral-600">{t('support.statusModal.noFurtherStatus')}</p>
      ) : (
        <Select
          label={t('support.statusModal.statusLabel')}
          value={status}
          onChange={setStatus}
          required
          options={options.map((value) => ({
            value,
            label: t(`enums.support_ticket_status.${value}`),
          }))}
        />
      )}
    </Modal>
  );
}

export default SupportStatusModal;
