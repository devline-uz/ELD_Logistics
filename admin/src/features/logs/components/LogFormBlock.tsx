/**
 * LOG FORM bloki (7.4.3): `Unit #(lar) · Driver · Co-Driver · Distance ·
 * Trailers[] · Shipping Docs[] · Signature`.
 *
 * **F100 [MUST] faqat ko'rish.** Bu blok hech qanday tahrirlash imkoniyati
 * bermaydi — imzo faqat rasm sifatida ko'rsatiladi, hech qanday "Edit"
 * tugmasi yo'q. Admin bu ekrandan **hech qachon** imzo qo'ymaydi yoki
 * shaklni to'g'ridan-to'g'ri o'zgartirmaydi.
 */
import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';

import type { DailyLogDetail } from '@/api/types';
import { Badge } from '@/components/ui/Badge';
import { StatusChip } from '@/components/ui/StatusChip';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';
import type { UseUnitSystemResult } from '@/hooks/useUnitSystem';

export interface LogFormBlockProps {
  form: DailyLogDetail['form'] | undefined;
  dateFormat: UseDateFormatResult;
  unitSystem: UseUnitSystemResult;
}

function Field({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div>
      <dt className="text-body-sm text-neutral-600">{label}</dt>
      <dd className="text-body text-neutral-900">{value}</dd>
    </div>
  );
}

export function LogFormBlock({ form, dateFormat, unitSystem }: LogFormBlockProps) {
  const { t } = useTranslation();

  if (!form) {
    return <p className="text-body-sm text-neutral-600">{t('logs.view.form.empty')}</p>;
  }

  const units = form.units ?? [];
  const trailers = form.trailers ?? [];
  const docs = form.shipping_docs ?? [];
  const signed = Boolean(form.signed_at);

  return (
    <div className="flex flex-col gap-4 rounded-lg border border-stroke p-4">
      <dl className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <Field
          label={t('logs.view.form.fields.units')}
          value={units.map((unit) => unit.unit_number).join(', ') || t('common.na')}
        />
        <Field
          label={t('logs.view.form.fields.driver')}
          value={form.driver_name ?? t('common.na')}
        />
        <Field
          label={t('logs.view.form.fields.coDriver')}
          value={form.co_driver_name ?? t('common.na')}
        />
        <Field
          label={t('logs.view.form.fields.distance')}
          value={unitSystem.formatDistance(form.distance_m)}
        />
        <Field
          label={t('logs.view.form.fields.homeTerminal')}
          value={form.home_terminal_address ?? t('common.na')}
        />
      </dl>

      <div>
        <p className="mb-1 text-body-sm text-neutral-600">{t('logs.view.form.fields.trailers')}</p>
        {trailers.length === 0 ? (
          <span className="text-body-sm text-neutral-400">{t('logs.view.form.notSet')}</span>
        ) : (
          <div className="flex flex-wrap gap-2">
            {trailers.map((trailer) => (
              <Badge key={trailer.id ?? trailer.number} tone="success">
                {trailer.number}
              </Badge>
            ))}
          </div>
        )}
      </div>

      <div>
        <p className="mb-1 text-body-sm text-neutral-600">
          {t('logs.view.form.fields.shippingDocs')}
        </p>
        {docs.length === 0 ? (
          <span className="text-body-sm text-neutral-400">{t('logs.view.form.notSet')}</span>
        ) : (
          <div className="flex flex-wrap gap-2">
            {docs.map((doc) => (
              <Badge key={doc.id ?? doc.number} tone="success">
                {doc.number}
              </Badge>
            ))}
          </div>
        )}
      </div>

      <div>
        <p className="mb-1 text-body-sm text-neutral-600">{t('logs.view.form.fields.signature')}</p>
        <div className="flex items-center gap-3">
          <StatusChip
            status={signed ? t('logs.view.form.signed') : t('logs.view.form.notSigned')}
            tone={signed ? 'success' : 'danger'}
          />
          {signed ? (
            <span className="text-body-sm text-neutral-600">
              {dateFormat.formatDateTime(form.signed_at)}
            </span>
          ) : null}
        </div>
        {/*
         * ⚠️ Ma'lum bo'shliq: `signature_key` — object-storage kaliti, to'g'ridan-to'g'ri
         * <img src> sifatida ishlatib bo'lmaydi (presign kerak). Bu bosqichda faqat
         * "Signed/Not Signed" holati va vaqt ko'rsatiladi; tasvirni ko'rsatish uchun
         * `files.ts` (yoki alohida `GET /daily-logs/{id}/signature`) presign hook kerak
         * (hisobotda qayd etilgan).
         */}
      </div>
    </div>
  );
}
