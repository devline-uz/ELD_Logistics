/**
 * Regulator Export / FMCSA — "Generate" modali (7.8.3), `ExportJobModal` ustiga qurilgan.
 *
 * `REPORT DETAILS`: `Type*` (`Roadside inspection report (8 days)` / `Custom Range`) ·
 * `Driver*` · `From*`/`To*` (faqat Custom Range — shartli maydon) · `Comment*`.
 * `Roadside inspection report (8 days)` tanlanganda `from/to` **klient tomonida**
 * hisoblanadi — bugundan oldingi 8 kunlik oyna (`certification_window_days`, N24) —
 * foydalanuvchidan sana so'ralmaydi.
 *
 * F127: `us_fmcsa` (va boshqa FMCSA profillari) `501 FEATURE_DISABLED` qaytarishi
 * mumkin — bu holat `ExportJobModal` ichida allaqachon ko'rsatiladi.
 */
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';

import type { ExportJob } from '@/api/types';
import { DatePicker } from '@/components/ui/DatePicker';
import { Select, type SelectOption } from '@/components/ui/Select';
import { Textarea } from '@/components/ui/Textarea';
import { toDateParam } from '@/lib/format';

import { ExportJobModal } from './ExportJobModal';

type RegulatorReportType = 'roadside' | 'custom';

const ROADSIDE_WINDOW_DAYS = 8;

function roadsideWindow(): { from: string; to: string } {
  const to = new Date();
  const from = new Date(to);
  from.setDate(from.getDate() - (ROADSIDE_WINDOW_DAYS - 1));
  return { from: toDateParam(from), to: toDateParam(to) };
}

export interface RegulatorGenerateModalProps {
  open: boolean;
  onClose: () => void;
  driverOptions: readonly SelectOption[];
  driversLoading?: boolean;
  onJobDone?: (job: ExportJob) => void;
}

export function RegulatorGenerateModal({
  open,
  onClose,
  driverOptions,
  driversLoading,
  onJobDone,
}: RegulatorGenerateModalProps) {
  const { t } = useTranslation();
  const [type, setType] = useState<RegulatorReportType>('roadside');
  const [driverId, setDriverId] = useState<string | null>(null);
  const [from, setFrom] = useState<Date | null>(null);
  const [to, setTo] = useState<Date | null>(null);
  const [comment, setComment] = useState('');

  useEffect(() => {
    if (open) {
      setType('roadside');
      setDriverId(null);
      setFrom(null);
      setTo(null);
      setComment('');
    }
  }, [open]);

  const typeOptions: SelectOption<RegulatorReportType>[] = [
    { value: 'roadside', label: t('reports.regulator.generateModal.typeOptions.roadside') },
    { value: 'custom', label: t('reports.regulator.generateModal.typeOptions.custom') },
  ];

  const roadside = type === 'roadside' ? roadsideWindow() : null;
  const rangeFrom = roadside?.from ?? (from ? toDateParam(from) : undefined);
  const rangeTo = roadside?.to ?? (to ? toDateParam(to) : undefined);

  const generateDisabled = !driverId || !comment.trim() || !rangeFrom || !rangeTo;

  return (
    <ExportJobModal
      open={open}
      onClose={onClose}
      type="regulator"
      titleKey="reports.regulator.generateModal.title"
      formats={['csv', 'pdf']}
      generateDisabled={generateDisabled}
      generateDisabledReason={t('reports.regulator.generateModal.requiredFieldsReason')}
      params={{
        driver_ids: driverId ? [driverId] : undefined,
        from: rangeFrom,
        to: rangeTo,
        comment: comment.trim() || undefined,
      }}
      onJobDone={onJobDone}
    >
      <div className="flex flex-col gap-4">
        <p className="text-body-sm font-medium uppercase tracking-wide text-neutral-500">
          {t('reports.regulator.generateModal.sectionTitle')}
        </p>

        <Select
          label={t('reports.regulator.generateModal.type')}
          required
          value={type}
          onChange={(value) => value && setType(value)}
          options={typeOptions}
        />

        <Select
          label={t('reports.regulator.generateModal.driver')}
          placeholder={t('reports.regulator.generateModal.driverPlaceholder')}
          required
          searchable
          loading={driversLoading}
          value={driverId}
          onChange={setDriverId}
          options={driverOptions}
        />

        {type === 'custom' ? (
          <div className="grid grid-cols-2 gap-4">
            <DatePicker
              label={t('reports.regulator.generateModal.from')}
              required
              value={from}
              onChange={setFrom}
              maxDate={to ?? undefined}
            />
            <DatePicker
              label={t('reports.regulator.generateModal.to')}
              required
              value={to}
              onChange={setTo}
              minDate={from ?? undefined}
              maxDate={new Date()}
            />
          </div>
        ) : null}

        <Textarea
          label={t('reports.regulator.generateModal.comment')}
          placeholder={t('reports.regulator.generateModal.commentPlaceholder')}
          required
          maxLength={1000}
          value={comment}
          onChange={(event) => setComment(event.target.value)}
          rows={3}
        />
      </div>
    </ExportJobModal>
  );
}

export default RegulatorGenerateModal;
