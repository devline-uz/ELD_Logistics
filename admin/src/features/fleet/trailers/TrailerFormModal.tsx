/**
 * Trailer Add/Edit modal (2.7, §7.3.7, 🎨 — fe-screens §2/§3 patterni).
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import { useTrailerCreate, useTrailerUpdate } from '@/api/queries/trailers';
import type { Trailer } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { useToast } from '@/components/feedback/toast-context';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormInput } from '@/components/form/FormInput';
import { FormTextarea } from '@/components/form/FormTextarea';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';

import { catalogFormDefaultValues, catalogFormSchema, type CatalogFormValues } from './schemas';

export interface TrailerFormModalProps {
  open: boolean;
  onClose: () => void;
  trailer?: Trailer;
}

function trailerToFormValues(trailer: Trailer): CatalogFormValues {
  return { number: trailer.number ?? '', notes: trailer.notes ?? '' };
}

export function TrailerFormModal({ open, onClose, trailer }: TrailerFormModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const isEdit = Boolean(trailer);
  const create = useTrailerCreate();
  const update = useTrailerUpdate();
  const pending = create.isPending || update.isPending;
  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);

  const form = useForm<CatalogFormValues>({
    resolver: zodResolver(catalogFormSchema),
    defaultValues: trailer ? trailerToFormValues(trailer) : catalogFormDefaultValues,
  });

  useEffect(() => {
    if (open) form.reset(trailer ? trailerToFormValues(trailer) : catalogFormDefaultValues);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, trailer]);

  const onSubmit = form.handleSubmit(async (values) => {
    setFormMessage(undefined);
    const payload = { number: values.number.trim(), notes: values.notes?.trim() || undefined };
    try {
      if (isEdit && trailer?.id) {
        await update.mutateAsync({ id: trailer.id, body: payload });
        toast.show({
          variant: 'success',
          message: t('fleet.trailers.toast.updated', { number: values.number }),
        });
      } else {
        await create.mutateAsync(payload);
        toast.show({
          variant: 'success',
          message: t('fleet.trailers.toast.created', { number: values.number }),
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
      title={isEdit ? t('fleet.trailers.form.editTitle') : t('fleet.trailers.form.addTitle')}
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
          label={t('fleet.trailers.form.fields.number')}
          required
        />
        <FormTextarea
          name="notes"
          control={form.control}
          label={t('fleet.trailers.form.fields.notes')}
          maxLength={60}
          rows={2}
        />
      </form>
    </Modal>
  );
}

export default TrailerFormModal;
