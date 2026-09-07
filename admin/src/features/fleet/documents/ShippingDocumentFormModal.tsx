/**
 * Shipping Document Add/Edit modal (2.7, §7.3.8, 🎨 — fe-screens §2/§3 patterni).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import {
  useShippingDocumentCreate,
  useShippingDocumentUpdate,
} from '@/api/queries/shippingDocuments';
import type { ShippingDocument } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { useToast } from '@/components/feedback/toast-context';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormInput } from '@/components/form/FormInput';
import { FormTextarea } from '@/components/form/FormTextarea';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';

import { catalogFormDefaultValues, catalogFormSchema, type CatalogFormValues } from './schemas';

export interface ShippingDocumentFormModalProps {
  open: boolean;
  onClose: () => void;
  document?: ShippingDocument;
}

function documentToFormValues(document: ShippingDocument): CatalogFormValues {
  return { number: document.number ?? '', notes: document.notes ?? '' };
}

export function ShippingDocumentFormModal({
  open,
  onClose,
  document,
}: ShippingDocumentFormModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const isEdit = Boolean(document);
  const create = useShippingDocumentCreate();
  const update = useShippingDocumentUpdate();
  const pending = create.isPending || update.isPending;
  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);

  const form = useForm<CatalogFormValues>({
    resolver: zodResolver(catalogFormSchema),
    defaultValues: document ? documentToFormValues(document) : catalogFormDefaultValues,
  });

  useEffect(() => {
    if (open) form.reset(document ? documentToFormValues(document) : catalogFormDefaultValues);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, document]);

  const onSubmit = form.handleSubmit(async (values) => {
    setFormMessage(undefined);
    const payload = { number: values.number.trim(), notes: values.notes?.trim() || undefined };
    try {
      if (isEdit && document?.id) {
        await update.mutateAsync({ id: document.id, body: payload });
        toast.show({
          variant: 'success',
          message: t('fleet.shippingDocuments.toast.updated', { number: values.number }),
        });
      } else {
        await create.mutateAsync(payload);
        toast.show({
          variant: 'success',
          message: t('fleet.shippingDocuments.toast.created', { number: values.number }),
        });
      }
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
      title={
        isEdit
          ? t('fleet.shippingDocuments.form.editTitle')
          : t('fleet.shippingDocuments.form.addTitle')
      }
      closeOnBackdrop={!form.formState.isDirty}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={pending}>
            {t('common.actions.cancel')}
          </Button>
          <Button onClick={() => void onSubmit()} loading={pending}>
            {isEdit ? t('common.actions.saveChanges') : t('common.actions.create')}
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
        <FormInput
          name="number"
          control={form.control}
          label={t('fleet.shippingDocuments.form.fields.number')}
          required
        />
        <FormTextarea
          name="notes"
          control={form.control}
          label={t('fleet.shippingDocuments.form.fields.notes')}
          maxLength={60}
          rows={2}
        />
      </form>
    </Modal>
  );
}

export default ShippingDocumentFormModal;
