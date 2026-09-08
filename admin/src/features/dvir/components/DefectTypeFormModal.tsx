/**
 * Defect Type Add/Edit modali (5.12, §7.6.1).
 *
 * `POST /defect-types` / `PATCH /defect-types/{id}`. Standart (`is_system`)
 * bandlar tahrirlanmaydi — backend `409 DEFECT_TYPE_SYSTEM_LOCKED` qaytaradi,
 * UI esa `Edit` amalini umuman ko'rsatmaydi; poyga holatida xato matni
 * `dvir.errors.systemLocked` kaliti bilan tushuntiriladi.
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import type { DefectType } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormCheckbox } from '@/components/form/FormCheckbox';
import { FormInput } from '@/components/form/FormInput';
import { FormSelect } from '@/components/form/FormSelect';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import { useResetFormOnOpen } from '@/hooks/useResetFormOnOpen';

import { dvirErrorMessageKey } from '../lib/errors';
import {
  buildDefectTypeSchema,
  defectTypeDefaultValues,
  type DefectTypeFormValues,
} from '../lib/schemas';

export interface DefectTypeFormModalProps {
  open: boolean;
  onClose: () => void;
  /** Tahrirlanayotgan yozuv; `undefined` — yaratish rejimi. */
  defectType?: DefectType;
  onCreate: (values: DefectTypeFormValues) => Promise<unknown>;
  onUpdate: (id: string, values: DefectTypeFormValues) => Promise<unknown>;
  isPending: boolean;
  onSuccess: (isEdit: boolean, values: DefectTypeFormValues) => void;
}

function toFormValues(defectType: DefectType): DefectTypeFormValues {
  return {
    name: defectType.name ?? '',
    category: defectType.category ?? 'truck',
    is_critical: defectType.is_critical ?? false,
    is_active: defectType.is_active ?? true,
    sort_order: String(defectType.sort_order ?? 0),
  };
}

export function DefectTypeFormModal({
  open,
  onClose,
  defectType,
  onCreate,
  onUpdate,
  isPending,
  onSuccess,
}: DefectTypeFormModalProps) {
  const { t } = useTranslation();
  const schema = useMemo(() => buildDefectTypeSchema(t), [t]);
  const isEdit = Boolean(defectType);
  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);

  const form = useForm<DefectTypeFormValues>({
    resolver: zodResolver(schema),
    defaultValues: defectType ? toFormValues(defectType) : defectTypeDefaultValues,
    mode: 'onBlur',
  });

  useResetFormOnOpen(
    form,
    open,
    () => (defectType ? toFormValues(defectType) : defectTypeDefaultValues),
    [defectType],
    () => setFormMessage(undefined),
  );

  const submit = form.handleSubmit(async (values) => {
    setFormMessage(undefined);
    try {
      if (isEdit && defectType?.id) {
        await onUpdate(defectType.id, values);
      } else {
        await onCreate(values);
      }
      onSuccess(isEdit, values);
      onClose();
    } catch (error) {
      const moduleKey = dvirErrorMessageKey(error);
      if (moduleKey) {
        setFormMessage(t(moduleKey));
        return;
      }
      const result = applyServerErrors(form, error);
      setFormMessage(result.formMessage ?? t('dvir.defectTypes.toast.failed'));
    }
  });

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={isEdit ? t('dvir.defectTypes.form.editTitle') : t('dvir.defectTypes.form.addTitle')}
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
          label={t('dvir.defectTypes.form.name')}
          required
          maxLength={120}
        />

        <FormSelect
          name="category"
          control={form.control}
          label={t('dvir.defectTypes.form.category')}
          required
          options={[
            { value: 'truck', label: t('enums.defect_category.truck') },
            { value: 'trailer', label: t('enums.defect_category.trailer') },
          ]}
        />

        <FormInput
          name="sort_order"
          control={form.control}
          label={t('dvir.defectTypes.form.sortOrder')}
          type="number"
        />

        <FormCheckbox
          name="is_critical"
          control={form.control}
          label={t('dvir.defectTypes.form.isCritical')}
          description={t('dvir.defectTypes.form.isCriticalDescription')}
        />

        <FormCheckbox
          name="is_active"
          control={form.control}
          label={t('dvir.defectTypes.form.isActive')}
          description={t('dvir.defectTypes.form.isActiveDescription')}
        />
      </form>
    </Modal>
  );
}
