/**
 * Trailer Add/Edit modal (2.7, §7.3.7, 🎨 — fe-screens §2/§3 patterni).
 * Umumiy `CatalogFormModal` (`components/data/`) ustidan yupqa moslama —
 * modul-xos i18n matn va `useTrailerCreate`/`useTrailerUpdate` hooklari.
 */
import { useTranslation } from 'react-i18next';

import { useTrailerCreate, useTrailerUpdate } from '@/api/queries/trailers';
import type { Trailer } from '@/api/types';
import { CatalogFormModal } from '@/components/data/CatalogFormModal';
import { useToast } from '@/components/feedback/toast-context';

export interface TrailerFormModalProps {
  open: boolean;
  onClose: () => void;
  trailer?: Trailer;
}

export function TrailerFormModal({ open, onClose, trailer }: TrailerFormModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const create = useTrailerCreate();
  const update = useTrailerUpdate();

  return (
    <CatalogFormModal
      open={open}
      onClose={onClose}
      entity={trailer}
      isPending={create.isPending || update.isPending}
      onCreate={(payload) => create.mutateAsync(payload)}
      onUpdate={(id, payload) => update.mutateAsync({ id, body: payload })}
      onSuccess={(isEdit, values) =>
        toast.show({
          variant: 'success',
          message: t(isEdit ? 'fleet.trailers.toast.updated' : 'fleet.trailers.toast.created', {
            number: values.number,
          }),
        })
      }
      labels={{
        addTitle: t('fleet.trailers.form.addTitle'),
        editTitle: t('fleet.trailers.form.editTitle'),
        numberLabel: t('fleet.trailers.form.fields.number'),
        notesLabel: t('fleet.trailers.form.fields.notes'),
        cancel: t('common.actions.cancel'),
        create: t('common.actions.create'),
        saveChanges: t('common.actions.saveChanges'),
      }}
    />
  );
}

export default TrailerFormModal;
