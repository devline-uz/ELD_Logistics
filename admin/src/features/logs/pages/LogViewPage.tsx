/**
 * Log view — `/logs/view/:logId` (3.6–3.10, `docs/tz/07-4-logs.md` 7.4.3).
 *
 * Tablar: **Driver's Log** (DutyGrid + Voqealar jadvali + LOG FORM bloki),
 * **Report** (PDF), **Trip Planner** (placeholder xarita + segmentlar +
 * "Create route").
 *
 * **F100 [MUST]**: bu ekran logni hech qachon to'g'ridan-to'g'ri
 * tahrirlamaydi — "Propose edit" faqat `SendEditRequestPanel`ni ochadi
 * (taklif → haydovchi tasdig'i, `useLogEditRequestPropose`).
 * `useLogAddEvent` bu ekranda **chaqirilmaydi** (D28 — haydovchining o'z
 * tuzatishi).
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useParams } from 'react-router-dom';

import { useDailyLog, useDriverDailyLogs } from '@/api/queries/logs';
import { useHosSummary } from '@/api/queries/hos';
import type { DailyLogDetail } from '@/api/types';
import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { Button } from '@/components/ui/Button';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { Tabs } from '@/components/ui/Tabs';
import { DutyGrid } from '@/components/logs/DutyGrid';
import { HosRings } from '@/components/logs/HosRings';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useUnitSystem } from '@/hooks/useUnitSystem';

import { buildDutyEventMarkers, buildDutySegments } from '../lib/dutyGrid';
import { buildHosRings } from '../lib/hosRings';
import { buildDutyGridLabels, buildHosRingsLabels } from '../lib/labels';
import { buildEditableDutySegments } from '../lib/logEditRequest';
import { LogEventsTable } from '../components/LogEventsTable';
import { LogFormBlock } from '../components/LogFormBlock';
import { ReportTab } from '../components/ReportTab';
import { SendEditRequestPanel } from '../components/SendEditRequestPanel';
import { TripPlannerTab } from '../components/TripPlannerTab';

type LogEvent = NonNullable<DailyLogDetail['events']>[number];
type ViewTab = 'log' | 'report' | 'tripPlanner';

export function LogViewPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { logId } = useParams<{ logId: string }>();
  const dateFormat = useDateFormat();
  const unitSystem = useUnitSystem();

  const [tab, setTab] = useState<ViewTab>('log');
  const [editingEvent, setEditingEvent] = useState<LogEvent | undefined>(undefined);

  const dailyLog = useDailyLog(logId);
  const driverId = dailyLog.data?.driver_id;
  const logDate = dailyLog.data?.log_date;
  const timezone = dailyLog.data?.timezone ?? dateFormat.timezone;

  const hosSummary = useHosSummary(driverId, logDate);

  const neighborWindow = useDriverDailyLogs(
    driverId,
    logDate
      ? {
          from: shiftDate(logDate, -7),
          to: shiftDate(logDate, 7),
          per_page: 50,
        }
      : {},
  );

  const { previousLogId, nextLogId } = useMemo(() => {
    const days = [...(neighborWindow.data?.data ?? [])].sort((a, b) =>
      (a.log_date ?? '').localeCompare(b.log_date ?? ''),
    );
    const index = days.findIndex((day) => day.id === logId);
    return {
      previousLogId: index > 0 ? days[index - 1]?.id : undefined,
      nextLogId: index >= 0 && index < days.length - 1 ? days[index + 1]?.id : undefined,
    };
  }, [neighborWindow.data, logId]);

  const events = useMemo(() => dailyLog.data?.events ?? [], [dailyLog.data]);
  const segments = useMemo(() => buildDutySegments(events), [events]);
  const markers = useMemo(() => buildDutyEventMarkers(events), [events]);
  const editableSegments = useMemo(() => buildEditableDutySegments(events), [events]);

  const editingSegment = editingEvent
    ? editableSegments.find((segment) => segment.event.id === editingEvent.id)
    : undefined;

  if (dailyLog.isLoading) {
    return <Skeleton variant="card" count={4} />;
  }

  if (dailyLog.isError || !dailyLog.data) {
    return (
      <ErrorState
        title={t('errors.notFound')}
        message={t('logs.view.notFound')}
        onRetry={() => void dailyLog.refetch()}
      />
    );
  }

  const data = dailyLog.data;
  const hosRings = buildHosRings(hosSummary.data, t);

  return (
    <div className="flex flex-col gap-4">
      <Breadcrumb
        items={[
          { label: t('logs.byUnit.title'), href: '/logs/by-unit' },
          { label: data.driver_name ?? t('common.na') },
          { label: dateFormat.formatDate(data.log_date) },
        ]}
      />

      <div className="flex flex-wrap items-center justify-between gap-3 rounded-lg border border-stroke p-4">
        <div>
          <h1 className="text-h3 font-bold text-neutral-900">
            {data.driver_name ?? t('common.na')}
          </h1>
          <p className="text-body-sm text-neutral-600">
            {t('logs.view.certified', {
              value:
                data.certification_status === 'certified'
                  ? t('common.boolean.yes')
                  : t('common.boolean.no'),
            })}
            {' · '}
            {t('logs.view.violationsCount', { count: data.violations?.length ?? 0 })}
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button
            variant="secondary"
            disabled={!previousLogId}
            onClick={() => previousLogId && navigate(`/logs/view/${previousLogId}`)}
            aria-label={t('logs.view.previousDay')}
          >
            {'‹'}
          </Button>
          <span className="text-body-sm font-medium text-neutral-700">
            {dateFormat.formatDate(data.log_date)}
          </span>
          <Button
            variant="secondary"
            disabled={!nextLogId}
            onClick={() => nextLogId && navigate(`/logs/view/${nextLogId}`)}
            aria-label={t('logs.view.nextDay')}
          >
            {'›'}
          </Button>
        </div>
      </div>

      <HosRings rings={hosRings} labels={buildHosRingsLabels(t)} />

      <Tabs
        tabs={[
          { id: 'log', label: t('logs.view.tabs.log') },
          { id: 'report', label: t('logs.view.tabs.report') },
          { id: 'tripPlanner', label: t('logs.view.tabs.tripPlanner') },
        ]}
        activeId={tab}
        onChange={(id) => setTab(id as ViewTab)}
        ariaLabel={t('logs.view.tabsLabel')}
      />

      {tab === 'log' ? (
        <div className="flex flex-col gap-4">
          <DutyGrid
            date={data.log_date ?? ''}
            timezone={timezone}
            segments={segments}
            events={markers}
            labels={buildDutyGridLabels(t)}
          />

          {(data.violations ?? []).map((violation) => (
            <p
              key={violation.id}
              role={violation.severity === 'violation' ? 'alert' : 'status'}
              className={
                violation.severity === 'violation'
                  ? 'text-body-sm text-error-dark'
                  : 'text-body-sm text-warning-dark'
              }
            >
              {t(`logs.violations.type.${violation.type}`)}
              {violation.resolved_at ? (
                <span className="ms-2 text-neutral-400">
                  {t('logs.view.resolvedAt', {
                    value: dateFormat.formatDateTime(violation.resolved_at),
                  })}
                </span>
              ) : null}
            </p>
          ))}

          <LogEventsTable
            events={events}
            dateFormat={dateFormat}
            unitSystem={unitSystem}
            onProposeEdit={(event) => setEditingEvent(event)}
          />

          <LogFormBlock form={data.form} dateFormat={dateFormat} unitSystem={unitSystem} />
        </div>
      ) : null}

      {tab === 'report' ? data.id ? <ReportTab dailyLogId={data.id} /> : null : null}

      {tab === 'tripPlanner' ? (
        <TripPlannerTab
          unitId={data.unit_ids?.[0]}
          driverId={data.driver_id ?? ''}
          logDate={data.log_date ?? ''}
          dateFormat={dateFormat}
        />
      ) : null}

      {data.id && driverId ? (
        <SendEditRequestPanel
          open={Boolean(editingEvent)}
          onClose={() => setEditingEvent(undefined)}
          dailyLogId={data.id}
          driverId={driverId}
          timezone={timezone}
          segment={editingSegment}
        />
      ) : null}
    </div>
  );
}

function shiftDate(isoDate: string, days: number): string {
  const date = new Date(`${isoDate}T00:00:00Z`);
  date.setUTCDate(date.getUTCDate() + days);
  return date.toISOString().slice(0, 10);
}

export default LogViewPage;
