/**
 * `Mark as Complete` + `Cancel` amallari (5.10) — `Due` tabi va reja ichidagi
 * «N Units» ekrani uchun bir xil. Ikkala ekran ham shu hookni chaqiradi va
 * `dialogs` ni render qiladi.
 *
 * `Cancel` — sabab **majburiy** (`ConfirmDialog requireReason`), bekor
 * qilingan yozuvda moliyaviy maydonlar bo'lmaydi (Q43).
 */
import { useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';

import { useMaintenanceCancel } from '@/api/queries/maintenance';
import type { MaintenanceScheduleUnit } from '@/api/types';
import { useToast } from '@/components/feedback/toast-context';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { isApiError } from '@/lib/errors';

import { CompleteMaintenanceModal } from './CompleteMaintenanceModal';

export interface UseMaintenanceActionsResult {
  openComplete: (row: MaintenanceScheduleUnit) => void;
  openCancel: (row: MaintenanceScheduleUnit) => void;
  dialogs: ReactNode;
}

export function useMaintenanceActions(): UseMaintenanceActionsResult {
  const { t } = useTranslation();
  const toast = useToast();
  const cancel = useMaintenanceCancel();
  const [completeTarget, setCompleteTarget] = useState<MaintenanceScheduleUnit | undefined>();
  const [cancelTarget, setCancelTarget] = useState<MaintenanceScheduleUnit | undefined>();

  const handleCancel = async (reason?: string) => {
    if (!cancelTarget?.id) return;
    try {
      await cancel.mutateAsync({
        id: cancelTarget.id,
        body: { cancelled_reason: reason ?? '' },
      });
      toast.show({
        variant: 'success',
        message: t('maintenance.toast.cancelled', { unit: cancelTarget.unit_number ?? '' }),
      });
      setCancelTarget(undefined);
    } catch (error) {
      toast.show({
        variant: 'error',
        message:
          isApiError(error) && error.status === 409
            ? t('maintenance.complete.errors.conflict')
            : t('errors.unknown'),
      });
    }
  };

  const dialogs = (
    <>
      <CompleteMaintenanceModal
        open={Boolean(completeTarget)}
        onClose={() => setCompleteTarget(undefined)}
        scheduleUnit={completeTarget}
      />

      <ConfirmDialog
        open={Boolean(cancelTarget)}
        onClose={() => setCancelTarget(undefined)}
        onConfirm={(reason) => void handleCancel(reason)}
        loading={cancel.isPending}
        variant="danger"
        title={t('maintenance.cancelDialog.title')}
        description={t('maintenance.cancelDialog.description', {
          unit: cancelTarget?.unit_number ?? '',
        })}
        requireReason
        reasonLabel={t('maintenance.cancelDialog.reasonLabel')}
      />
    </>
  );

  return {
    openComplete: (row) => setCompleteTarget(row),
    openCancel: (row) => setCancelTarget(row),
    dialogs,
  };
}
