import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';

import type { DashboardRoute } from '@/api/types';
import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { Card } from '@/components/ui/Card';
import { StatusChip } from '@/components/ui/StatusChip';
import { Tooltip } from '@/components/ui/Tooltip';
import { useDateFormat } from '@/hooks/useDateFormat';
import { NA } from '@/lib/format';

import {
  DASHBOARD_ROUTE_STATUS_TONE,
  resolveDashboardRouteDisplayStatus,
} from '../lib/routeStatus';

export interface RouteDetailsCardProps {
  routes: DashboardRoute[] | undefined;
  loading: boolean;
  isError: boolean;
  errorMessage?: string;
  onRetry: () => void;
}

/** Truncate + tooltip'li manzil hujayrasi (§7.2 "From"/"To" ustunlari). */
function AddressCell({ value }: { value: string | null | undefined }) {
  const text = value ?? NA;
  return (
    <Tooltip content={text}>
      {/* eslint-disable-next-line jsx-a11y/no-noninteractive-tabindex -- to'liq matn
          faqat tooltip orqali ko'rinadi, klaviatura fokusi bilan ochilishi shart (fe-a11y §1). */}
      <span tabIndex={0} className="block max-w-[16rem] truncate outline-none">
        {text}
      </span>
    </Tooltip>
  );
}

/**
 * "Route's Details" bloki — bugungi marshrutlar, 10 satr + vertikal scroll,
 * sahifalash yo'q (§7.2, dizayn saqlanadi). Mustaqil xato/bo'sh holat —
 * KPI/status blokidan alohida (fe-screens §7 2-daraja).
 */
export function RouteDetailsCard({
  routes,
  loading,
  isError,
  errorMessage,
  onRetry,
}: RouteDetailsCardProps) {
  const { t } = useTranslation();
  const { formatDateTime } = useDateFormat();

  return (
    <Card
      title={t('dashboard.routes.title')}
      actions={
        <Link to="/routes" className="text-body-sm font-medium text-primary hover:underline">
          {t('dashboard.routes.viewAll')}
        </Link>
      }
    >
      {isError ? (
        <ErrorState message={errorMessage ?? t('dashboard.routes.error')} onRetry={onRetry} />
      ) : loading ? (
        <Skeleton variant="table-row" count={5} />
      ) : !routes || routes.length === 0 ? (
        <EmptyState
          title={t('dashboard.routes.empty.title')}
          description={t('dashboard.routes.empty.description')}
        />
      ) : (
        <div className="max-h-[420px] overflow-y-auto overflow-x-auto">
          <table className="w-full text-left text-body-sm">
            <thead className="sticky top-0 bg-surface-muted text-body-sm font-medium uppercase tracking-wide text-neutral-500">
              <tr>
                <th className="px-3 py-2" scope="col">
                  {t('dashboard.routes.columns.unitNumber')}
                </th>
                <th className="px-3 py-2" scope="col">
                  {t('dashboard.routes.columns.date')}
                </th>
                <th className="px-3 py-2" scope="col">
                  {t('dashboard.routes.columns.driverName')}
                </th>
                <th className="px-3 py-2" scope="col">
                  {t('dashboard.routes.columns.from')}
                </th>
                <th className="px-3 py-2" scope="col">
                  {t('dashboard.routes.columns.to')}
                </th>
                <th className="px-3 py-2" scope="col">
                  {t('dashboard.routes.columns.status')}
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stroke">
              {routes.map((route, index) => {
                const displayStatus = resolveDashboardRouteDisplayStatus(route.status);
                return (
                  <tr key={route.id ?? index}>
                    <td className="px-3 py-2 text-neutral-900">{route.unit_number ?? NA}</td>
                    <td className="px-3 py-2 text-neutral-700">
                      {formatDateTime(route.created_at)}
                    </td>
                    <td className="px-3 py-2 text-neutral-700">{route.driver_name ?? NA}</td>
                    <td className="px-3 py-2 text-neutral-700">
                      <AddressCell value={route.origin} />
                    </td>
                    <td className="px-3 py-2 text-neutral-700">
                      <AddressCell value={route.destination} />
                    </td>
                    <td className="px-3 py-2">
                      <StatusChip
                        status={t(`enums.route_status.${displayStatus}`)}
                        tone={DASHBOARD_ROUTE_STATUS_TONE[displayStatus]}
                      />
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </Card>
  );
}

export default RouteDetailsCard;
