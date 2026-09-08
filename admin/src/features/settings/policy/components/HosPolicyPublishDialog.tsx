/**
 * HOS Policy — "Publish" tasdiq dialogi (8.4, F147).
 *
 * Yangi versiya chop etish **eskisini o'zgartirmaydi** — shuning uchun
 * tasdiq matni aniq aytadi va o'zgargan maydonlar ro'yxati ko'rsatiladi
 * (`diffHosPolicy`).
 */
import { useTranslation } from 'react-i18next';

import { Modal } from '@/components/ui/Modal';
import { Button } from '@/components/ui/Button';
import { formatDuration } from '@/lib/format';

import type { HosPolicyDiffEntry } from '../lib/diff';
import { hosPolicyFieldLabelKey } from '../lib/fieldLabels';

export interface HosPolicyPublishDialogProps {
  open: boolean;
  onClose: () => void;
  onConfirm: () => void;
  diffEntries: HosPolicyDiffEntry[];
  effectiveFromLabel: string;
  loading?: boolean;
}

const DURATION_FIELDS = new Set([
  'drive_limit_min',
  'shift_window_min',
  'daily_rest_min',
  'break_required_after_drive_min',
  'break_duration_min',
  'cycle_limit_min',
  'cycle_restart_min',
  'adverse_conditions_extension_min',
  'warning_thresholds.drive',
  'warning_thresholds.shift',
  'warning_thresholds.break',
  'warning_thresholds.cycle',
]);

function formatDiffValue(field: string, value: unknown, t: (key: string) => string): string {
  if (value === undefined || value === null) return t('common.states.notAvailable');
  if (typeof value === 'boolean') return t(value ? 'common.boolean.yes' : 'common.boolean.no');
  if (Array.isArray(value)) {
    return value.length > 0
      ? value.map((item) => t(`enums.duty_status.${String(item)}`)).join(', ')
      : t('common.states.empty');
  }
  if (DURATION_FIELDS.has(field) && typeof value === 'number') {
    return formatDuration(value);
  }
  if (typeof value === 'number') return value.toString();
  if (typeof value === 'string') return value;
  return t('common.states.notAvailable');
}

export function HosPolicyPublishDialog({
  open,
  onClose,
  onConfirm,
  diffEntries,
  effectiveFromLabel,
  loading,
}: HosPolicyPublishDialogProps) {
  const { t } = useTranslation();

  return (
    <Modal
      open={open}
      onClose={onClose}
      role="alertdialog"
      title={t('settings.hos.publish.title')}
      closeOnBackdrop={!loading}
      size="lg"
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={loading}>
            {t('common.actions.cancel')}
          </Button>
          <Button onClick={onConfirm} loading={loading} disabled={diffEntries.length === 0}>
            {t('settings.hos.publish.confirm')}
          </Button>
        </>
      }
    >
      <p className="text-body text-neutral-700">
        {t('settings.hos.publish.description', { date: effectiveFromLabel })}
      </p>

      {diffEntries.length === 0 ? (
        <p className="mt-4 text-body text-neutral-500">{t('settings.hos.publish.noChanges')}</p>
      ) : (
        <table className="mt-4 w-full text-body-sm">
          <caption className="sr-only">{t('settings.hos.publish.diffTableCaption')}</caption>
          <thead>
            <tr className="border-b border-stroke text-left text-neutral-500">
              <th scope="col" className="py-2 pr-3 font-medium">
                {t('settings.hos.publish.field')}
              </th>
              <th scope="col" className="py-2 pr-3 font-medium">
                {t('settings.hos.publish.oldValue')}
              </th>
              <th scope="col" className="py-2 font-medium">
                {t('settings.hos.publish.newValue')}
              </th>
            </tr>
          </thead>
          <tbody>
            {diffEntries.map((entry) => (
              <tr key={entry.field} className="border-b border-stroke last:border-0">
                <td className="py-2 pr-3 text-neutral-800">
                  {t(hosPolicyFieldLabelKey(entry.field))}
                </td>
                <td className="py-2 pr-3 text-neutral-500">
                  {formatDiffValue(entry.field, entry.oldValue, t)}
                </td>
                <td className="py-2 font-medium text-neutral-900">
                  {formatDiffValue(entry.field, entry.newValue, t)}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </Modal>
  );
}

export default HosPolicyPublishDialog;
