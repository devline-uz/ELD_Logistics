/**
 * HOS Policy — versiyalar tarixi (8.4, §7.13.3 «Versiyalar tarixi: `effective_from`,
 * `created_by`, farqlar (diff) ko'rinishi»).
 *
 * Alohida "list versions" endpointi yo'q (`api/queries/hosPolicy.ts` izohi) —
 * `GET /company/history?action=hos_policy_change` har o'zgargan maydon uchun
 * bitta yozuv qaytaradi (`field`/`old_value`/`new_value` — bu allaqachon
 * maydon darajasidagi diff), shuning uchun bu yerda alohida diff hisoblash
 * shart emas, faqat yorliq/format qo'llaniladi.
 */
import { useTranslation } from 'react-i18next';

import type { CompanyHistoryEntry } from '@/api/types';
import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { useDateFormat } from '@/hooks/useDateFormat';

import { hosPolicyFieldLabelKey } from '../lib/fieldLabels';

export interface HosPolicyVersionHistoryProps {
  entries: CompanyHistoryEntry[];
  isLoading: boolean;
  isError: boolean;
  errorMessage?: string;
  onRetry: () => void;
}

export function HosPolicyVersionHistory({
  entries,
  isLoading,
  isError,
  errorMessage,
  onRetry,
}: HosPolicyVersionHistoryProps) {
  const { t } = useTranslation();
  const { formatDateTime } = useDateFormat();

  if (isLoading) {
    return <Skeleton variant="table-row" count={4} />;
  }

  if (isError) {
    return <ErrorState message={errorMessage ?? t('errors.unknown')} onRetry={onRetry} />;
  }

  if (entries.length === 0) {
    return (
      <EmptyState
        title={t('settings.hos.history.empty.title')}
        description={t('settings.hos.history.empty.description')}
      />
    );
  }

  return (
    <table className="w-full text-body-sm">
      <caption className="sr-only">{t('settings.hos.history.title')}</caption>
      <thead>
        <tr className="border-b border-stroke bg-surface-muted text-left uppercase tracking-wide text-neutral-500">
          <th scope="col" className="px-3 py-2 font-medium">
            {t('settings.hos.history.columns.date')}
          </th>
          <th scope="col" className="px-3 py-2 font-medium">
            {t('settings.hos.history.columns.editedBy')}
          </th>
          <th scope="col" className="px-3 py-2 font-medium">
            {t('settings.hos.history.columns.field')}
          </th>
          <th scope="col" className="px-3 py-2 font-medium">
            {t('settings.hos.history.columns.oldValue')}
          </th>
          <th scope="col" className="px-3 py-2 font-medium">
            {t('settings.hos.history.columns.newValue')}
          </th>
        </tr>
      </thead>
      <tbody>
        {entries.map((entry) => (
          <tr key={entry.id} className="border-b border-stroke last:border-0">
            <td className="px-3 py-2 text-neutral-700">{formatDateTime(entry.ts)}</td>
            <td className="px-3 py-2 text-neutral-700">
              {entry.edited_by_name ?? t('common.states.notAvailable')}
            </td>
            <td className="px-3 py-2 text-neutral-800">
              {entry.field
                ? t(hosPolicyFieldLabelKey(entry.field))
                : t('common.states.notAvailable')}
            </td>
            <td className="px-3 py-2 text-neutral-500">
              {entry.old_value ?? t('common.states.notAvailable')}
            </td>
            <td className="px-3 py-2 font-medium text-neutral-900">
              {entry.new_value ?? t('common.states.notAvailable')}
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

export default HosPolicyVersionHistory;
