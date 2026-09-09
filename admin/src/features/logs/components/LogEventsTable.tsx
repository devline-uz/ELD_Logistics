/**
 * Voqealar jadvali (7.4.3): `# · Status · Start · Duration · Last Known
 * Location · Odometer · Engine Hours · Document · Trailer · Notes · Origin
 * · Action`.
 *
 * ⚠️ **Ma'lum bo'shliq.** `LogEvent` DTO'sida `Document`/`Trailer` maydonlari
 * yo'q (kunlik shakl darajasida `form.trailers[]`/`form.shipping_docs[]`
 * bor, lekin hodisa darajasida emas) — bu ustunlar `N/A` bilan ko'rsatiladi
 * (`docs/tz/16-17-registry-open-questions.md`ga qayd etilgan gap).
 *
 * `Origin` ustuni: `admin_edit`/`driver_edit` → `✎` belgisi + tooltip'da
 * kim/qachon/izoh (Q17.2) — `LogEvent.edited` bayrog'i va `notes` maydoni
 * orqali (asl qiymatning o'zi backend javobida alohida saqlanmaydi, faqat
 * `superseded_by` ko'rsatkichi bor — to'liq "asl qiymat" tarixi kelajakda
 * `GET /daily-logs/{id}/events/{eventId}/history` kabi endpoint talab qiladi,
 * hozircha `notes` matni bilan cheklanadi).
 */
import { useTranslation } from 'react-i18next';

import type { DailyLogDetail } from '@/api/types';
import { Badge } from '@/components/ui/Badge';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { StatusChip } from '@/components/ui/StatusChip';
import { Tooltip } from '@/components/ui/Tooltip';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';
import type { UseUnitSystemResult } from '@/hooks/useUnitSystem';
import { PERM } from '@/lib/permissions';
import { dutyStatusTone } from '@/lib/statusTone';

import { buildEditableDutySegments, isEventEditable } from '../lib/logEditRequest';

type LogEvent = NonNullable<DailyLogDetail['events']>[number];

export interface LogEventsTableProps {
  events: LogEvent[];
  dateFormat: UseDateFormatResult;
  unitSystem: UseUnitSystemResult;
  onProposeEdit: (event: LogEvent) => void;
}

export function LogEventsTable({
  events,
  dateFormat,
  unitSystem,
  onProposeEdit,
}: LogEventsTableProps) {
  const { t } = useTranslation();

  const sorted = [...events].sort((a, b) => (a.event_time ?? '').localeCompare(b.event_time ?? ''));
  const segments = buildEditableDutySegments(events);
  const durationById = new Map(
    segments.map((segment) => [
      segment.event.id ?? '',
      (new Date(segment.endTime).getTime() - new Date(segment.startTime).getTime()) / 60000,
    ]),
  );

  if (sorted.length === 0) {
    return <p className="text-body-sm text-neutral-600">{t('logs.view.events.empty')}</p>;
  }

  return (
    <div className="overflow-x-auto rounded-lg border border-stroke">
      <table className="w-full min-w-[960px] text-body-sm">
        <caption className="sr-only">{t('logs.view.events.caption')}</caption>
        <thead className="bg-neutral-50 text-start text-neutral-600">
          <tr>
            <th scope="col" className="sticky left-0 bg-neutral-50 px-3 py-2 text-start">
              #
            </th>
            <th scope="col" className="px-3 py-2 text-start">
              {t('logs.view.events.columns.status')}
            </th>
            <th scope="col" className="px-3 py-2 text-start">
              {t('logs.view.events.columns.start')}
            </th>
            <th scope="col" className="px-3 py-2 text-start">
              {t('logs.view.events.columns.duration')}
            </th>
            <th scope="col" className="px-3 py-2 text-start">
              {t('logs.view.events.columns.location')}
            </th>
            <th scope="col" className="px-3 py-2 text-start">
              {t('logs.view.events.columns.odometer')}
            </th>
            <th scope="col" className="px-3 py-2 text-start">
              {t('logs.view.events.columns.engineHours')}
            </th>
            <th scope="col" className="px-3 py-2 text-start">
              {t('logs.view.events.columns.document')}
            </th>
            <th scope="col" className="px-3 py-2 text-start">
              {t('logs.view.events.columns.trailer')}
            </th>
            <th scope="col" className="px-3 py-2 text-start">
              {t('logs.view.events.columns.notes')}
            </th>
            <th scope="col" className="px-3 py-2 text-start">
              {t('logs.view.events.columns.origin')}
            </th>
            <th scope="col" className="px-3 py-2 text-start">
              {t('logs.view.events.columns.action')}
            </th>
          </tr>
        </thead>
        <tbody>
          {sorted.map((event, index) => {
            const isDuty = event.event_type === 'duty_status';
            const durationMin = event.id ? durationById.get(event.id) : undefined;
            const editable = isEventEditable(event) && !event.locked;
            return (
              <tr key={event.id ?? index} className="border-t border-stroke">
                <td className="sticky left-0 bg-surface px-3 py-2">{index + 1}</td>
                <td className="px-3 py-2">
                  {isDuty ? (
                    <StatusChip status={event.status ?? ''} tone={dutyStatusTone(event.status)} />
                  ) : (
                    <Badge tone="neutral">{t(`logs.events.eventType.${event.event_type}`)}</Badge>
                  )}
                </td>
                <td className="px-3 py-2">{dateFormat.formatDateTime(event.event_time)}</td>
                <td className="px-3 py-2">
                  {isDuty && durationMin !== undefined
                    ? dateFormat.formatDuration(durationMin)
                    : t('common.na')}
                </td>
                <td className="px-3 py-2">{event.location_text ?? t('common.na')}</td>
                <td className="px-3 py-2">{unitSystem.formatDistance(event.odometer_m)}</td>
                <td className="px-3 py-2">
                  {event.engine_hours !== undefined ? event.engine_hours : t('common.na')}
                </td>
                <td className="px-3 py-2">{t('common.na')}</td>
                <td className="px-3 py-2">{t('common.na')}</td>
                <td className="px-3 py-2">{event.notes ?? ''}</td>
                <td className="px-3 py-2">
                  {event.edited ? (
                    <Tooltip
                      content={
                        <span>
                          {t(`logs.events.origin.${event.origin ?? 'auto'}`)}
                          {event.notes ? ` — ${event.notes}` : ''}
                        </span>
                      }
                    >
                      <span className="inline-flex cursor-help items-center gap-1">
                        <span aria-hidden="true">{t('logs.view.events.editedMark')}</span>
                        {t(`logs.events.origin.${event.origin ?? 'auto'}`)}
                      </span>
                    </Tooltip>
                  ) : (
                    t(`logs.events.origin.${event.origin ?? 'auto'}`)
                  )}
                </td>
                <td className="px-3 py-2">
                  <PermissionGate permission={PERM.logsProposeEdit}>
                    {editable ? (
                      <button
                        type="button"
                        className="text-body-sm font-medium text-primary hover:underline disabled:cursor-not-allowed disabled:text-neutral-400"
                        onClick={() => onProposeEdit(event)}
                      >
                        {t('logs.view.events.proposeEdit')}
                      </button>
                    ) : null}
                  </PermissionGate>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
