/**
 * `Record repair` modali (5.4) — `POST /dvir-reports/{id}/repair`
 * (`dvir.repair`), `submitted_defects_found` → `repaired`.
 *
 * Maydonlar (swagger `DvirRepair`): mexanik izohi (**majburiy**), vendor,
 * invoice raqami, narx va ixtiyoriy invoice fayli (`kind=invoice` — presign
 * oqimi, MIME/hajm tekshiruvi `FileUpload` da).
 *
 * `mechanic_signature_key` — backend uchun **majburiy** (swagger
 * `DvirRepair.required`), lekin **D30**: admin panel imzoni umuman olmaydi.
 * Kalit mobil/planshet ilovasida olingan va hisobotda allaqachon mavjud
 * bo'ladi — forma uni `defaultValues` orqali o'zgarishsiz qaytarib yuboradi.
 * Foydalanuvchidan hech qanday imzo so'ralmaydi; kalit yo'q bo'lsa modal
 * umuman ochilmaydi (`Record repair` tugmasi `disabled`).
 *
 * Yuborishdan oldin tasdiq dialogi (fe-screens §4) — amal audit-muhim va
 * holatni o'zgartiradi.
 */
import { zodResolver } from '@hookform/resolvers/zod';
import { useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import type { DvirRepair } from '@/api/types';
import { presignFile } from '@/api/queries/files';
import { Alert } from '@/components/feedback/Alert';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FileUpload } from '@/components/form/FileUpload';
import { FormInput } from '@/components/form/FormInput';
import { FormTextarea } from '@/components/form/FormTextarea';
import { Button } from '@/components/ui/Button';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { Modal } from '@/components/ui/Modal';
import { useResetFormOnOpen } from '@/hooks/useResetFormOnOpen';

import { dvirErrorMessageKey } from '../lib/errors';
import {
  buildDvirRepairSchema,
  dvirRepairDefaultValues,
  type DvirRepairFormValues,
} from '../lib/schemas';

export interface RecordRepairModalProps {
  open: boolean;
  /** Hisobotdagi mavjud mexanik imzosi kaliti (mobil ilovada olingan, D30). */
  mechanicSignatureKey: string;
  onClose: () => void;
  onSubmit: (body: DvirRepair) => Promise<unknown>;
  isPending: boolean;
  onSuccess: () => void;
}

export function RecordRepairModal({
  open,
  mechanicSignatureKey,
  onClose,
  onSubmit,
  isPending,
  onSuccess,
}: RecordRepairModalProps) {
  const { t } = useTranslation();
  const schema = useMemo(() => buildDvirRepairSchema(t), [t]);

  const [formMessage, setFormMessage] = useState<string | undefined>(undefined);
  const [invoice, setInvoice] = useState<{ key: string; filename: string } | undefined>(undefined);
  const [confirmOpen, setConfirmOpen] = useState(false);

  // Imzo kaliti foydalanuvchidan so'ralmaydi — hisobotdan keladi (D30).
  const defaults = useMemo<DvirRepairFormValues>(
    () => ({ ...dvirRepairDefaultValues, mechanic_signature_key: mechanicSignatureKey }),
    [mechanicSignatureKey],
  );

  const form = useForm<DvirRepairFormValues>({
    resolver: zodResolver(schema),
    defaultValues: defaults,
    mode: 'onBlur',
  });

  useResetFormOnOpen(
    form,
    open,
    () => defaults,
    [defaults],
    () => {
      setFormMessage(undefined);
      setInvoice(undefined);
      setConfirmOpen(false);
    },
  );

  const requestConfirm = form.handleSubmit(() => {
    setFormMessage(undefined);
    setConfirmOpen(true);
  });

  const submit = async () => {
    const values = form.getValues();
    const cost = values.cost.trim() ? Number(values.cost) : undefined;
    const body: DvirRepair = {
      mechanic_note: values.mechanic_note.trim(),
      mechanic_signature_key: values.mechanic_signature_key,
      ...(values.vendor.trim() ? { vendor: values.vendor.trim() } : {}),
      ...(values.invoice_no.trim() ? { invoice_no: values.invoice_no.trim() } : {}),
      ...(cost !== undefined && Number.isFinite(cost) ? { cost } : {}),
      ...(invoice ? { invoice_key: invoice.key } : {}),
    };

    try {
      await onSubmit(body);
      setConfirmOpen(false);
      onSuccess();
      onClose();
    } catch (error) {
      setConfirmOpen(false);
      const moduleKey = dvirErrorMessageKey(error);
      if (moduleKey) {
        setFormMessage(t(moduleKey));
        return;
      }
      const result = applyServerErrors(form, error);
      setFormMessage(result.formMessage ?? t('dvir.toast.repairFailed'));
    }
  };

  return (
    <>
      <Modal
        open={open}
        onClose={onClose}
        title={t('dvir.repair.title')}
        size="lg"
        closeOnBackdrop={!form.formState.isDirty}
        footer={
          <>
            <Button variant="secondary" onClick={onClose} disabled={isPending}>
              {t('common.actions.cancel')}
            </Button>
            <Button onClick={() => void requestConfirm()} loading={isPending}>
              {t('dvir.repair.submit')}
            </Button>
          </>
        }
      >
        <form className="flex flex-col gap-4" onSubmit={(event) => event.preventDefault()}>
          {formMessage ? <Alert variant="error" message={formMessage} /> : null}
          {/* Himoya to'sig'i: modal imzosiz ochilmaydi, lekin kalit yo'qolsa
              foydalanuvchi sababni ko'radi (D30). */}
          {form.formState.errors.mechanic_signature_key ? (
            <Alert variant="error" message={t('dvir.repair.signatureMissing')} />
          ) : null}

          <FormTextarea
            name="mechanic_note"
            control={form.control}
            label={t('dvir.repair.mechanicNote')}
            placeholder={t('dvir.repair.mechanicNotePlaceholder')}
            required
            maxLength={2000}
            rows={4}
          />

          <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
            <FormInput
              name="vendor"
              control={form.control}
              label={t('dvir.repair.vendor')}
              maxLength={200}
            />
            <FormInput
              name="invoice_no"
              control={form.control}
              label={t('dvir.repair.invoiceNo')}
              maxLength={64}
            />
            <FormInput
              name="cost"
              control={form.control}
              label={t('dvir.repair.cost')}
              type="number"
            />
          </div>

          <FileUpload
            kind="invoice"
            label={t('dvir.repair.invoice')}
            description={t('dvir.repair.invoiceDescription')}
            onPresign={presignFile}
            onUploaded={(result) => setInvoice({ key: result.key, filename: result.filename })}
            onError={() => setFormMessage(t('dvir.toast.uploadFailed'))}
          />
          {invoice ? (
            <p className="text-body-sm text-neutral-600">
              {t('dvir.repair.invoiceUploaded', { filename: invoice.filename })}
            </p>
          ) : null}
        </form>
      </Modal>

      <ConfirmDialog
        open={confirmOpen}
        onClose={() => setConfirmOpen(false)}
        onConfirm={() => void submit()}
        title={t('dvir.repair.confirmTitle')}
        description={t('dvir.repair.confirmDescription')}
        confirmLabel={t('common.actions.confirm')}
        loading={isPending}
      />
    </>
  );
}
