/**
 * Dashboard — `/` (§7.2). Kompaniyaning joriy holati bir ekranda: 9 KPI
 * kartasi + duty-status bloki, jonli kuzatuv xaritasi, bugungi marshrutlar.
 *
 * Ruxsat: `dashboard.read` — marshrut darajasida `RouteGuard` bilan tekshiriladi
 * (`src/app/router/dashboard.routes.tsx`, `guardedIndexRoute`), shu sabab bu
 * komponent ichida qayta gate qo'yilmaydi.
 *
 * Real-vaqt: `dashboard_summary` WS hodisasi keshni to'g'ridan-to'g'ri
 * yangilaydi (`applyDashboardSummaryEvent`, invalidatsiya kerak emas — server
 * bir xil shaklda qayta yuboradi). WS `live` bo'lmasa 60 s polling fallback
 * (`useRealtimeOrPolling`).
 */
import { useCallback } from 'react';
import { useTranslation } from 'react-i18next';
import { useQueryClient } from '@tanstack/react-query';

import { applyDashboardSummaryEvent, useDashboardSummary } from '@/api/queries/dashboard';
import type { DashboardSummary } from '@/api/types';
import { ErrorState } from '@/components/feedback/ErrorState';
import { useChannel } from '@/hooks/useChannel';
import { useRealtimeOrPolling } from '@/hooks/useRealtimeOrPolling';
import type { RealtimeEvent } from '@/lib/ws';

import { DashboardKpiGrid } from '../components/DashboardKpiGrid';
import { RouteDetailsCard } from '../components/RouteDetailsCard';
import { UnitsTrackingCard } from '../components/UnitsTrackingCard';

export function DashboardPage() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  const summary = useDashboardSummary();

  const handleSummaryEvent = useCallback(
    (event: RealtimeEvent<DashboardSummary>) => {
      if (event.type !== 'dashboard_summary') return;
      applyDashboardSummaryEvent(queryClient, event.data);
    },
    [queryClient],
  );

  useChannel<DashboardSummary>('dashboard', undefined, handleSummaryEvent);
  useRealtimeOrPolling(() => void summary.refetch());

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-h3 font-bold text-neutral-900">{t('pages.dashboard.title')}</h1>

      {summary.isError ? (
        <div className="rounded-xl border border-stroke bg-surface p-6">
          <ErrorState
            message={summary.error?.message ?? t('dashboard.summary.error')}
            onRetry={() => void summary.refetch()}
          />
        </div>
      ) : (
        <DashboardKpiGrid summary={summary.data} loading={summary.isLoading} />
      )}

      {/* fe-screens §7 (2-daraja) — Route's Details bloki mustaqil xato holati bilan
          o'z Card'ida ko'rsatiladi, KPI blokining yiqilishi bundan mustaqil. */}
      <RouteDetailsCard
        routes={summary.data?.routes}
        loading={summary.isLoading}
        isError={summary.isError}
        errorMessage={summary.error?.message}
        onRetry={() => void summary.refetch()}
      />

      {/* Xarita bloki o'z so'rovidan (`GET /tracking/live`) foydalanadi — summary
          yiqilishi bu blokka ta'sir qilmaydi (fe-screens §7). */}
      <UnitsTrackingCard />
    </div>
  );
}

export default DashboardPage;
