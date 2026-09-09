/**
 * Super Admin — Subscription modali (9.15, §7.14). `PATCH
 * /companies/{id}/subscription`. MVP billing qo'lda: platforma admini
 * to'lovdan keyin `subscription_end_at`ni uzaytiradi (`tz.md` qaror 24).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import type { AdminCompany, SubscriptionUpdate } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormCheckbox } from '@/components/form/FormCheckbox';
import { FormDatePicker } from '@/components/form/FormDatePicker';
import { FormInput } from '@/components/form/FormInput';
import { FormSelect } from '@/components/form/FormSelect';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import { useResetFormOnOpen } from '@/hooks/useResetFormOnOpen';
import { toDateParam } from '@/lib/format';

import {
  buildSubscriptionSchema,
  SUBSCRIPTION_STATUS_VALUES,
  subscriptionFormDefaultValues,
  type SubscriptionFormValues,
} from '../lib/schemas';

export interface SubscriptionFormModalProps {
  open: boolean;
  onClose: () => void;
  company?: AdminCompany;
  onSubmit: (id: string, body: SubscriptionUpdate) => Promise<unknown>;
  isPending: boolean;
  onSuccess: (name: string) => void;
}

function parseIso(value: string | undefined): Date | null {
  if (!value) return null;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

function toFormValues(company: AdminCompany): SubscriptionFormValues {
  return {
    subscription_status:
      (company.subscription_status as SubscriptionFormValues['subscription_status']) ?? 'trial',
    plan: company.plan ?? '',
    subscription_end_at: parseIso(company.subscription_end_at),
    clear_end_at: false,
  };
}

function toBody(values: SubscriptionFormValues): SubscriptionUpdate {
  return {
    subscription_status: values.subscription_status,
    ...(values.plan.trim() ? { plan: values.plan.trim() } : {}),
    clear_end_at: values.clear_end_at,
    ...(values.clear_end_at
      ? {}
      : values.subscription_end_at
        ? { subscription_end_at: `${toDateParam(values.subscription_end_at)}T23:59:59Z` }
        : {}),
  };
}

export function SubscriptionFormModal({
  open,
  onClose,
  company,
  onSubmit,
  isPending,
  onSuccess,
}: SubscriptionFormModalProps) {
  const { t } = useTranslation();
  const schema = buildSubscriptionSchema(t);
  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);

  const form = useForm<SubscriptionFormValues>({
    resolver: zodResolver(schema),
    defaultValues: company ? toFormValues(company) : subscriptionFormDefaultValues,
    mode: 'onBlur',
  });

  useResetFormOnOpen(
    form,
    open,
    () => (company ? toFormValues(company) : subscriptionFormDefaultValues),
    [company],
    () => setFormMessage(undefined),
  );

  const clearEndAt = form.watch('clear_end_at');

  const submit = form.handleSubmit(async (values) => {
    if (!company?.id) return;
    setFormMessage(undefined);
    try {
      await onSubmit(company.id, toBody(values));
      onSuccess(company.name ?? '');
      onClose();
    } catch (error) {
      const result = applyServerErrors(form, error);
      setFormMessage(result.formMessage ?? t('superadmin.companies.toast.saveFailed'));
    }
  });

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={t('superadmin.companies.subscription.title', { name: company?.name ?? '' })}
      closeOnBackdrop={!form.formState.isDirty}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={isPending}>
            {t('common.actions.cancel')}
          </Button>
          <Button onClick={() => void submit()} loading={isPending}>
            {t('common.actions.saveChanges')}
          </Button>
        </>
      }
    >
      <form className="flex flex-col gap-4" onSubmit={(event) => event.preventDefault()}>
        {formMessage ? <Alert variant="error" message={formMessage} /> : null}

        <FormSelect
          name="subscription_status"
          control={form.control}
          label={t('superadmin.companies.form.subscriptionStatus')}
          required
          options={SUBSCRIPTION_STATUS_VALUES.map((value) => ({
            value,
            label: t(`superadmin.companies.status.${value}`),
          }))}
        />

        <FormInput
          name="plan"
          control={form.control}
          label={t('superadmin.companies.form.plan')}
          maxLength={64}
        />

        <FormDatePicker
          name="subscription_end_at"
          control={form.control}
          label={t('superadmin.companies.form.subscriptionEndAt')}
          disabled={clearEndAt}
        />

        <FormCheckbox
          name="clear_end_at"
          control={form.control}
          label={t('superadmin.companies.form.clearEndAt')}
          description={t('superadmin.companies.form.clearEndAtHint')}
        />
      </form>
    </Modal>
  );
}

export default SubscriptionFormModal;
