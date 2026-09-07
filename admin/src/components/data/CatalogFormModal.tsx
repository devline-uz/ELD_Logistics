/**
 * Sodda "katalog" Add/Edit modal — `number` (majburiy) + `notes` (≤ 60)
 * maydonlariga ega har qanday entity uchun (fe-screens §2/§3 patterni).
 *
 * `Trailers` (`docs/tz/07-3-fleet.md` §7.3.7) va `Shipping Documents`
 * (§7.3.8) oldin bayt-baytga bir xil modalni saqlagan edi — bosqich 2
 * ko'rigi (dublikat topilmasi). Modul-xos matn/ruxsat/hook'lar `labels` va
 * `onCreate`/`onUpdate` orqali beriladi.
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useState } from 'react';
import { useForm } from 'react-hook-form';

import { Alert } from '@/components/feedback/Alert';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormInput } from '@/components/form/FormInput';
import { FormTextarea } from '@/components/form/FormTextarea';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import { useResetFormOnOpen } from '@/hooks/useResetFormOnOpen';
import {
  catalogFormDefaultValues,
  catalogFormSchema,
  type CatalogFormValues,
} from '@/lib/validation';

export interface CatalogEntity {
  id?: string;
  number?: string;
  notes?: string;
}

export interface CatalogFormModalLabels {
  addTitle: string;
  editTitle: string;
  numberLabel: string;
  notesLabel: string;
  cancel: string;
  create: string;
  saveChanges: string;
}

export interface CatalogFormModalProps<T extends CatalogEntity> {
  open: boolean;
  onClose: () => void;
  entity?: T;
  labels: CatalogFormModalLabels;
  onCreate: (payload: { number: string; notes?: string }) => Promise<unknown>;
  onUpdate: (id: string, payload: { number: string; notes?: string }) => Promise<unknown>;
  isPending: boolean;
  /** Muvaffaqiyatli yuborilgandan keyin (masalan, success toast ko'rsatish uchun). */
  onSuccess: (isEdit: boolean, values: CatalogFormValues) => void;
}

function entityToFormValues(entity: CatalogEntity): CatalogFormValues {
  return { number: entity.number ?? '', notes: entity.notes ?? '' };
}

export function CatalogFormModal<T extends CatalogEntity>({
  open,
  onClose,
  entity,
  labels,
  onCreate,
  onUpdate,
  isPending,
  onSuccess,
}: CatalogFormModalProps<T>) {
  const isEdit = Boolean(entity);
  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);

  const form = useForm<CatalogFormValues>({
    resolver: zodResolver(catalogFormSchema),
    defaultValues: entity ? entityToFormValues(entity) : catalogFormDefaultValues,
  });

  useResetFormOnOpen(
    form,
    open,
    () => (entity ? entityToFormValues(entity) : catalogFormDefaultValues),
    [entity],
    () => setFormMessage(undefined),
  );

  const onSubmit = form.handleSubmit(async (values) => {
    setFormMessage(undefined);
    const payload = { number: values.number.trim(), notes: values.notes?.trim() || undefined };
    try {
      if (isEdit && entity?.id) {
        await onUpdate(entity.id, payload);
      } else {
        await onCreate(payload);
      }
      onSuccess(isEdit, values);
      onClose();
    } catch (error) {
      const result = applyServerErrors(form, error);
      if (result.formMessage) setFormMessage(result.formMessage);
    }
  });

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={isEdit ? labels.editTitle : labels.addTitle}
      closeOnBackdrop={!form.formState.isDirty}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={isPending}>
            {labels.cancel}
          </Button>
          <Button onClick={() => void onSubmit()} loading={isPending}>
            {isEdit ? labels.saveChanges : labels.create}
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
        <FormInput name="number" control={form.control} label={labels.numberLabel} required />
        <FormTextarea
          name="notes"
          control={form.control}
          label={labels.notesLabel}
          maxLength={60}
          rows={2}
        />
      </form>
    </Modal>
  );
}

export default CatalogFormModal;
