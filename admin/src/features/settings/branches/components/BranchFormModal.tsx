/**
 * Branch Add/Edit modali (8.3, §7.13.2). `POST /company/branches` /
 * `PATCH /company/branches/{id}`. Nom to'qnashuvida `422 VALIDATION_ERROR`
 * (`name`) — `applyServerErrors` orqali maydonga bog'lanadi.
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import type { Branch } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormInput } from '@/components/form/FormInput';
import { FormSelect } from '@/components/form/FormSelect';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import { useResetFormOnOpen } from '@/hooks/useResetFormOnOpen';
import { TIMEZONE_OPTIONS } from '@/features/settings/company/lib/timezones';

import { branchDefaultValues, buildBranchSchema, type BranchFormValues } from '../lib/schemas';

export interface BranchFormModalProps {
  open: boolean;
  onClose: () => void;
  /** Tahrirlanayotgan filial; `undefined` — yaratish rejimi. */
  branch?: Branch;
  onCreate: (values: BranchFormValues) => Promise<unknown>;
  onUpdate: (id: string, values: BranchFormValues) => Promise<unknown>;
  isPending: boolean;
  onSuccess: (isEdit: boolean, values: BranchFormValues) => void;
}

function toFormValues(branch: Branch): BranchFormValues {
  return {
    name: branch.name ?? '',
    address: branch.address ?? '',
    timezone: branch.timezone ?? '',
  };
}

export function BranchFormModal({
  open,
  onClose,
  branch,
  onCreate,
  onUpdate,
  isPending,
  onSuccess,
}: BranchFormModalProps) {
  const { t } = useTranslation();
  const schema = useMemo(() => buildBranchSchema(t), [t]);
  const isEdit = Boolean(branch);
  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);

  const form = useForm<BranchFormValues>({
    resolver: zodResolver(schema),
    defaultValues: branch ? toFormValues(branch) : branchDefaultValues,
    mode: 'onBlur',
  });

  useResetFormOnOpen(
    form,
    open,
    () => (branch ? toFormValues(branch) : branchDefaultValues),
    [branch],
    () => setFormMessage(undefined),
  );

  const submit = form.handleSubmit(async (values) => {
    setFormMessage(undefined);
    try {
      if (isEdit && branch?.id) {
        await onUpdate(branch.id, values);
      } else {
        await onCreate(values);
      }
      onSuccess(isEdit, values);
      onClose();
    } catch (error) {
      const result = applyServerErrors(form, error);
      setFormMessage(result.formMessage ?? t('settings.branches.toast.failed'));
    }
  });

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={isEdit ? t('settings.branches.form.editTitle') : t('settings.branches.form.addTitle')}
      closeOnBackdrop={!form.formState.isDirty}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={isPending}>
            {t('common.actions.cancel')}
          </Button>
          <Button onClick={() => void submit()} loading={isPending}>
            {isEdit ? t('common.actions.saveChanges') : t('common.actions.create')}
          </Button>
        </>
      }
    >
      <form className="flex flex-col gap-4" onSubmit={(event) => event.preventDefault()}>
        {formMessage ? <Alert variant="error" message={formMessage} /> : null}

        <FormInput
          name="name"
          control={form.control}
          label={t('settings.branches.form.name')}
          required
          maxLength={160}
        />

        <FormInput
          name="address"
          control={form.control}
          label={t('settings.branches.form.address')}
          maxLength={512}
        />

        <FormSelect
          name="timezone"
          control={form.control}
          label={t('settings.branches.form.timezone')}
          searchable
          clearable
          options={TIMEZONE_OPTIONS}
        />
      </form>
    </Modal>
  );
}

export default BranchFormModal;
