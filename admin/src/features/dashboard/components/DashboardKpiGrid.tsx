import { useTranslation } from 'react-i18next';
import {
  AlertOctagon,
  AlertTriangle,
  Clock,
  FileWarning,
  PenLine,
  Truck,
  UserX,
  Users,
  WifiOff,
} from 'lucide-react';

import type { DashboardSummary } from '@/api/types';
import { Icon } from '@/components/ui/Icon';
import type { KpiCardProps } from '@/components/ui/KpiCard';
import { NA } from '@/lib/format';

import { DutyStatusCard } from './DutyStatusCard';
import { KpiCardLink } from './KpiCardLink';

export interface DashboardKpiGridProps {
  summary: DashboardSummary | undefined;
  loading: boolean;
}

function kpiValue(value: number | null | undefined): string | number {
  return typeof value === 'number' ? value : NA;
}

/**
 * 9 KPI karta + Status bloki — §7.2 jadvali, 2 qatorli grid (F80: birinchi
 * qatorda eng muhim 5 tasi, "Status bloki (beshinchi karta)" shu qatorning
 * oxirgi katagi).
 *
 * **KpiCard tone bo'shlig'i (D34):** dizayn "Active Units" uchun
 * `decorative-orange` chizig'ini talab qiladi, lekin umumiy `KpiCard`
 * (`components/ui`, bu moduldan tashqarida) faqat
 * `primary/success/warning/error/info/neutral` tonlarini biladi — orange yo'q.
 * Eng yaqin ton — `warning` (issiq sariq-amber) ishlatiladi;
 * `docs/tz/16-17-registry-open-questions.md` ga yozildi.
 */
export function DashboardKpiGrid({ summary, loading }: DashboardKpiGridProps) {
  const { t } = useTranslation();
  const kpi = summary?.kpi;

  const violationsFrom = summary?.week?.from;
  const violationsHref = violationsFrom
    ? `/violations?from=${encodeURIComponent(violationsFrom)}`
    : '/violations';

  const disconnectedCount = kpi?.disconnected_eld ?? 0;
  // F81 — chiziq neutral, qiymat > 0 bo'lsa error.
  const disconnectedTone: NonNullable<KpiCardProps['tone']> =
    disconnectedCount > 0 ? 'error' : 'neutral';

  return (
    <div className="grid grid-cols-2 gap-4 xl:grid-cols-5">
      <KpiCardLink
        to="/units?status=active"
        ariaLabel={t('dashboard.kpi.activeUnits.label')}
        label={t('dashboard.kpi.activeUnits.label')}
        value={kpiValue(kpi?.active_units)}
        tone="warning"
        loading={loading}
        icon={<Icon icon={Truck} />}
      />
      <KpiCardLink
        to="/drivers?status=active"
        ariaLabel={t('dashboard.kpi.activeDrivers.label')}
        label={t('dashboard.kpi.activeDrivers.label')}
        value={kpiValue(kpi?.active_drivers)}
        tone="info"
        loading={loading}
        icon={<Icon icon={Users} />}
      />
      <KpiCardLink
        to="/tracking"
        ariaLabel={t('dashboard.kpi.driversOnDuty.label')}
        label={t('dashboard.kpi.driversOnDuty.label')}
        value={kpiValue(kpi?.drivers_on_duty)}
        tone="info"
        loading={loading}
        icon={<Icon icon={Clock} />}
      />
      <KpiCardLink
        to={violationsHref}
        ariaLabel={t('dashboard.kpi.violations.label')}
        label={t('dashboard.kpi.violations.label')}
        value={kpiValue(kpi?.violations)}
        tone="error"
        loading={loading}
        icon={<Icon icon={AlertTriangle} />}
      />
      <DutyStatusCard status={summary?.status} loading={loading} />

      <KpiCardLink
        to="/tracking?online_status=disconnected"
        ariaLabel={t('dashboard.kpi.disconnectedEld.label')}
        label={t('dashboard.kpi.disconnectedEld.label')}
        value={kpiValue(kpi?.disconnected_eld)}
        tone={disconnectedTone}
        loading={loading}
        icon={<Icon icon={WifiOff} />}
      />
      <KpiCardLink
        to="/eld-devices?status=malfunction"
        ariaLabel={t('dashboard.kpi.malfunctionEld.label')}
        label={t('dashboard.kpi.malfunctionEld.label')}
        value={kpiValue(kpi?.malfunction_eld)}
        tone="error"
        loading={loading}
        icon={<Icon icon={AlertOctagon} />}
      />
      <KpiCardLink
        to="/reports/uncertified-logs"
        ariaLabel={t('dashboard.kpi.uncertifiedLogs.label')}
        label={t('dashboard.kpi.uncertifiedLogs.label')}
        value={kpiValue(kpi?.uncertified_logs)}
        tone="warning"
        loading={loading}
        icon={<Icon icon={FileWarning} />}
      />
      <KpiCardLink
        to="/logs/unassigned"
        ariaLabel={t('dashboard.kpi.unassignedDriving.label')}
        label={t('dashboard.kpi.unassignedDriving.label')}
        value={kpiValue(kpi?.unassigned_driving)}
        tone="warning"
        loading={loading}
        icon={<Icon icon={UserX} />}
      />
      <KpiCardLink
        to="/logs/edit-requests?status=pending"
        ariaLabel={t('dashboard.kpi.pendingLogEdits.label')}
        label={t('dashboard.kpi.pendingLogEdits.label')}
        value={kpiValue(kpi?.pending_log_edits)}
        tone="warning"
        loading={loading}
        icon={<Icon icon={PenLine} />}
      />
    </div>
  );
}

export default DashboardKpiGrid;
