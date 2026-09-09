/**
 * Holat tarixi (5.3) — «kim, qachon, qaysi holatga».
 *
 * ⚠️ Backend `DvirReport` da alohida `history[]` massivi **yo'q** — tarix
 * mavjud vaqt tamg'alaridan (`created_at`/`performed_at`, `repaired_at`,
 * `certified_at`, `closed_at`) hosil qilinadi. §16 reestriga nomzod:
 * «DVIR holat tarixi uchun endpoint/maydon yo'q — UI derivativ chiziq
 * ko'rsatadi».
 */
import { useTranslation } from 'react-i18next';

import type { DvirReport } from '@/api/types';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';
import { formatPersonName } from '@/lib/format';

export interface DvirStatusHistoryProps {
  report: DvirReport;
  dateFormat: UseDateFormatResult;
}

interface HistoryEntry {
  key: string;
  label: string;
  at: string;
  by?: string;
  note?: string;
}

export function DvirStatusHistory({ report, dateFormat }: DvirStatusHistoryProps) {
  const { t } = useTranslation();

  const driverName = formatPersonName(report.driver, '') || undefined;

  const entries: HistoryEntry[] = [];

  const submittedAt = report.performed_at ?? report.created_at;
  if (submittedAt) {
    entries.push({
      key: 'submitted',
      label: t('dvir.detail.history.submitted'),
      at: submittedAt,
      by: driverName,
    });
  }
  if (report.repaired_at) {
    entries.push({
      key: 'repaired',
      label: t('dvir.detail.history.repaired'),
      at: report.repaired_at,
      note: report.mechanic_note,
    });
  }
  if (report.certified_at) {
    entries.push({
      key: 'certified',
      label: t('dvir.detail.history.certified'),
      at: report.certified_at,
      by: driverName,
    });
  }
  if (report.closed_at) {
    entries.push({
      key: 'closed',
      label: t('dvir.detail.history.closed'),
      at: report.closed_at,
      note: report.closed_reason,
    });
  }

  if (entries.length === 0) {
    return <p className="text-body-sm text-neutral-600">{t('dvir.detail.history.empty')}</p>;
  }

  return (
    <ol className="flex flex-col gap-3">
      {entries.map((entry) => (
        <li key={entry.key} className="flex gap-3">
          <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-primary" aria-hidden="true" />
          <div>
            <p className="text-body text-neutral-900">
              {entry.label}
              {entry.by ? ` — ${t('dvir.detail.history.by', { name: entry.by })}` : ''}
            </p>
            <p className="text-body-sm text-neutral-600">{dateFormat.formatDateTime(entry.at)}</p>
            {entry.note ? <p className="text-body-sm text-neutral-600">{entry.note}</p> : null}
          </div>
        </li>
      ))}
    </ol>
  );
}
