/**
 * Shipping Document Add/Edit modal (2.7, §7.3.8, 🎨 — fe-screens §2/§3
 * patterni). Umumiy `CatalogFormModal` (`components/data/`) ustidan yupqa
 * moslama — modul-xos i18n matn va
 * `useShippingDocumentCreate`/`useShippingDocumentUpdate` hooklari.
 */
import { useTranslation } from 'react-i18next';

import {
  useShippingDocumentCreate,
  useShippingDocumentUpdate,
} from '@/api/queries/shippingDocuments';
import type { ShippingDocument } from '@/api/types';
import { CatalogFormModal } from '@/components/data/CatalogFormModal';
import { useToast } from '@/components/feedback/toast-context';

export interface ShippingDocumentFormModalProps {
  open: boolean;
  onClose: () => void;
  document?: ShippingDocument;
}

export function ShippingDocumentFormModal({
  open,
  onClose,
  document,
}: ShippingDocumentFormModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const create = useShippingDocumentCreate();
  const update = useShippingDocumentUpdate();

  return (
    <CatalogFormModal
      open={open}
      onClose={onClose}
      entity={document}
      isPending={create.isPending || update.isPending}
      onCreate={(payload) => create.mutateAsync(payload)}
      onUpdate={(id, payload) => update.mutateAsync({ id, body: payload })}
      onSuccess={(isEdit, values) =>
        toast.show({
          variant: 'success',
          message: t(
            isEdit
              ? 'fleet.shippingDocuments.toast.updated'
              : 'fleet.shippingDocuments.toast.created',
            { number: values.number },
          ),
        })
      }
      labels={{
        addTitle: t('fleet.shippingDocuments.form.addTitle'),
        editTitle: t('fleet.shippingDocuments.form.editTitle'),
        numberLabel: t('fleet.shippingDocuments.form.fields.number'),
        notesLabel: t('fleet.shippingDocuments.form.fields.notes'),
        cancel: t('common.actions.cancel'),
        create: t('common.actions.create'),
        saveChanges: t('common.actions.saveChanges'),
      }}
    />
  );
}

export default ShippingDocumentFormModal;
