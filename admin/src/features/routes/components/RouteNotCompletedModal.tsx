/**
 * "Close as not completed" modali — §7.7.3. `reason` fixed ro'yxatdan,
 * `other` uchun `note` majburiy. Faqat `ongoing` route uchun (409 aks holda).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import { useRouteNotCompleted } from '@/api/queries/routes';
import type { Route } from '@/api/types';
import { useToast } from '@/components/feedback/toast-context';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormSelect } from '@/components/form/FormSelect';
import { FormTextarea } from '@/components/form/FormTextarea';
import { Alert } from '@/components/feedback/Alert';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import type { SelectOption } from '@/components/ui/Select';
import { useResetFormOnOpen } from '@/hooks/useResetFormOnOpen';
import { isApiError } from '@/lib/errors';

import {
  NOT_COMPLETED_REASONS,
  notCompletedDefaultValues,
  notCompletedSchema,
  type NotCompletedFormValues,
} from '../schemas';

export interface RouteNotCompletedModalProps {
  open: boolean;
  onClose: () => void;
  route: Route | undefined;
}

export function RouteNotCompletedModal({ open, onClose, route }: RouteNotCompletedModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const mutation = useRouteNotCompleted();
  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);

  const form = useForm<NotCompletedFormValues>({
    resolver: zodResolver(notCompletedSchema),
    defaultValues: notCompletedDefaultValues,
    mode: 'onBlur',
  });

  useResetFormOnOpen(form, open, () => notCompletedDefaultValues, [route?.id]);

  const reasonOptions: SelectOption[] = NOT_COMPLETED_REASONS.map((reason) => ({
    value: reason,
    label: t(`routes.notCompleted.reasons.${reason}`),
  }));

  const onSubmit = form.handleSubmit(async (values) => {
    if (!route?.id) return;
    setFormMessage(undefined);
    try {
      await mutation.mutateAsync({
        id: route.id,
        body: { reason: values.reason, note: values.note?.trim() || undefined },
      });
      toast.show({ variant: 'success', message: t('routes.list.toast.closedNotCompleted') });
      onClose();
    } catch (error) {
      if (isApiError(error) && error.status === 409) {
        setFormMessage(error.message);
        return;
      }
      const result = applyServerErrors(form, error);
      if (result.formMessage) setFormMessage(result.formMessage);
    }
  });

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={t('routes.notCompleted.title')}
      closeOnBackdrop={!form.formState.isDirty}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={mutation.isPending}>
            {t('common.actions.cancel')}
          </Button>
          <Button
            variant="danger"
            onClick={() => {
              void onSubmit();
            }}
            loading={mutation.isPending}
          >
            {t('routes.list.actions.closeNotCompleted')}
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
        {formMessage ? <Alert message={formMessage} /> : null}
        <p className="text-body-sm text-neutral-600">{t('routes.notCompleted.description')}</p>
        <FormSelect
          name="reason"
          control={form.control}
          label={t('routes.notCompleted.reasonLabel')}
          options={reasonOptions}
          required
        />
        <FormTextarea
          name="note"
          control={form.control}
          label={t('routes.notCompleted.noteLabel')}
          maxLength={1000}
          rows={3}
        />
      </form>
    </Modal>
  );
}

export default RouteNotCompletedModal;
