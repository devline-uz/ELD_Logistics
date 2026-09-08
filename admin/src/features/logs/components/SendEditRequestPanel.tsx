/**
 * "Insert / Edit Duty Status" paneli (7.4.3(b)).
 *
 * **F100 [MUST] Bu — to'g'ridan-to'g'ri tahrir EMAS.** Tugma nomi
 * ataylab `Send edit request` (dizayndagi `Confirm` emas) — panel tepasida
 * izoh bor: bu log haydovchi tasdiqlagunicha o'zgarmaydi.
 *
 * **Q17.1 [MUST]**: avtomatik yozib olingan `DR` segmenti tanlanganda —
 * boshqa statusga o'tish bloklangan (tugmalar `disabled` + sabab tooltip),
 * va taklif qilingan oraliq asl oraliqni qisqartira olmaydi.
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useEffect, useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import { useLogEditRequestPropose } from '@/api/queries/logEditRequests';
import { Alert } from '@/components/feedback/Alert';
import { useToast } from '@/components/feedback/toast-context';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormTextarea } from '@/components/form/FormTextarea';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';

import {
  editRequestSchema,
  isoToLocalInput,
  localInputToIso,
  type EditRequestFormValues,
} from '../lib/editRequestSchema';
import {
  DUTY_EDIT_BUTTONS,
  isImmutableAutoDriving,
  shrinksOriginalInterval,
  type EditableDutySegment,
} from '../lib/logEditRequest';

export interface SendEditRequestPanelProps {
  open: boolean;
  onClose: () => void;
  dailyLogId: string;
  driverId: string;
  timezone: string;
  segment: EditableDutySegment | undefined;
}

export function SendEditRequestPanel({
  open,
  onClose,
  dailyLogId,
  driverId,
  timezone,
  segment,
}: SendEditRequestPanelProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const navigate = useNavigate();
  const propose = useLogEditRequestPropose();
  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);

  const immutable = segment ? isImmutableAutoDriving(segment) : false;

  const defaultValues = useMemo<EditRequestFormValues>(() => {
    if (!segment) {
      return { status: 'OFF', special: 'none', from: '', to: '', note: '' };
    }
    return {
      status: segment.event.status ?? 'OFF',
      special: (segment.event.special as EditRequestFormValues['special']) ?? 'none',
      from: isoToLocalInput(segment.startTime, timezone),
      to: isoToLocalInput(segment.endTime, timezone),
      note: '',
    };
  }, [segment, timezone]);

  const form = useForm<EditRequestFormValues>({
    resolver: zodResolver(editRequestSchema),
    defaultValues,
  });

  useEffect(() => {
    if (open) form.reset(defaultValues);
  }, [open, defaultValues, form]);

  const watchStatus = form.watch('status');
  const watchSpecial = form.watch('special');
  const watchFrom = form.watch('from');
  const watchTo = form.watch('to');

  const statusChangedOnAuto =
    immutable && segment ? watchStatus !== segment.event.status || watchSpecial !== 'none' : false;

  const shrinksInterval =
    immutable && segment && watchFrom && watchTo
      ? shrinksOriginalInterval(segment, {
          from: localInputToIso(watchFrom, timezone),
          to: localInputToIso(watchTo, timezone),
        })
      : false;

  const blockedByImmutability = statusChangedOnAuto || shrinksInterval;

  const onSubmit = form.handleSubmit(async (values) => {
    if (blockedByImmutability) return;
    setFormMessage(undefined);
    try {
      const result = await propose.mutateAsync({
        daily_log_id: dailyLogId,
        driver_id: driverId,
        changes: [
          {
            status: values.status,
            special: values.special,
            from: localInputToIso(values.from, timezone),
            to: localInputToIso(values.to, timezone),
            note: values.note.trim(),
          },
        ],
      });
      toast.show({ variant: 'success', message: t('logs.view.editRequest.toast.sent') });
      onClose();
      if (result?.id) {
        navigate('/logs/edit-requests');
      }
    } catch (error) {
      const applied = applyServerErrors(form, error);
      if (applied.formMessage) setFormMessage(applied.formMessage);
    }
  });

  return (
    <Modal
      open={open}
      onClose={onClose}
      size="lg"
      title={t('logs.view.editRequest.title')}
      closeOnBackdrop={!form.formState.isDirty}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={propose.isPending}>
            {t('common.actions.cancel')}
          </Button>
          <Button
            onClick={() => void onSubmit()}
            loading={propose.isPending}
            disabled={blockedByImmutability}
          >
            {t('logs.view.editRequest.submit')}
          </Button>
        </>
      }
    >
      <form
        className="flex flex-col gap-4"
        noValidate
        onSubmit={(event) => {
          event.preventDefault();
          void onSubmit();
        }}
      >
        <Alert variant="info" message={t('logs.view.editRequest.notice')} />

        {formMessage ? <Alert message={formMessage} /> : null}

        {immutable ? (
          <Alert variant="warning" message={t('logs.view.editRequest.immutableWarning')} />
        ) : null}

        <div>
          <p className="mb-2 text-body-sm font-medium text-neutral-700">
            {t('logs.view.editRequest.fields.status')}
          </p>
          <div className="flex flex-wrap gap-2">
            {DUTY_EDIT_BUTTONS.map((option) => {
              const selected = watchStatus === option.status && watchSpecial === option.special;
              const disallowed =
                immutable && (option.status !== segment?.event.status || option.special !== 'none');
              return (
                <button
                  key={`${option.status}-${option.special}`}
                  type="button"
                  disabled={disallowed}
                  title={disallowed ? t('logs.view.editRequest.immutableTooltip') : undefined}
                  onClick={() => {
                    form.setValue('status', option.status, { shouldDirty: true });
                    form.setValue('special', option.special, { shouldDirty: true });
                  }}
                  className={`rounded-md border px-3 py-1.5 text-body-sm font-medium disabled:cursor-not-allowed disabled:opacity-50 ${
                    selected
                      ? 'border-primary bg-primary text-white'
                      : 'border-stroke bg-surface text-neutral-700 hover:bg-surface-muted'
                  }`}
                >
                  {t(
                    option.special === 'none'
                      ? `logs.dutyGrid.status.${option.status.toLowerCase()}`
                      : `logs.dutyGrid.special.${option.special}`,
                  )}
                </button>
              );
            })}
          </div>
        </div>

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div>
            <label
              htmlFor="edit-request-from"
              className="mb-1 block text-body-sm font-medium text-neutral-700"
            >
              {t('logs.view.editRequest.fields.from')} <span aria-hidden="true">*</span>
            </label>
            <input
              id="edit-request-from"
              type="datetime-local"
              required
              aria-required="true"
              value={watchFrom}
              onChange={(event) => form.setValue('from', event.target.value, { shouldDirty: true })}
              className="w-full rounded-md border border-stroke px-3 py-2 text-body focus-visible:outline focus-visible:outline-2 focus-visible:outline-primary"
            />
          </div>
          <div>
            <label
              htmlFor="edit-request-to"
              className="mb-1 block text-body-sm font-medium text-neutral-700"
            >
              {t('logs.view.editRequest.fields.to')} <span aria-hidden="true">*</span>
            </label>
            <input
              id="edit-request-to"
              type="datetime-local"
              required
              aria-required="true"
              value={watchTo}
              onChange={(event) => form.setValue('to', event.target.value, { shouldDirty: true })}
              className="w-full rounded-md border border-stroke px-3 py-2 text-body focus-visible:outline focus-visible:outline-2 focus-visible:outline-primary"
            />
            {form.formState.errors.to ? (
              <p role="alert" className="mt-1 text-body-sm text-error-dark">
                {t('logs.view.editRequest.errors.toAfterFrom')}
              </p>
            ) : null}
          </div>
        </div>

        {shrinksInterval ? (
          <Alert message={t('logs.view.editRequest.errors.shrinksInterval')} />
        ) : null}

        <FormTextarea
          name="note"
          control={form.control}
          label={t('logs.view.editRequest.fields.note')}
          required
          maxLength={60}
          rows={3}
        />
      </form>
    </Modal>
  );
}
