/**
 * Co-Driver boshqaruvi — Driver View ichidagi blok (2.4, TZ 7.3.5 F86/D3).
 *
 * `Co-Driver` maydoni Add/Edit formasidan chiqarilgan (D3 — ixtiyoriy,
 * View ichidagi alohida blokka ko'chgan). Bog'lash/uzish
 * `drivers.manage_co_drivers` bilan himoyalangan.
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import {
  useDriverCoDriverLink,
  useDriverCoDriverUnlink,
  useDriverCoDrivers,
} from '@/api/queries/drivers';
import { useDriversList } from '@/api/queries/drivers';
import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { Select } from '@/components/ui/Select';
import { useToast } from '@/components/feedback/toast-context';
import { PERM } from '@/lib/permissions';
import { formatPersonName } from '@/lib/format';

export interface CoDriversPanelProps {
  driverId: string;
}

export function CoDriversPanel({ driverId }: CoDriversPanelProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const coDriversQuery = useDriverCoDrivers(driverId);
  const candidatesQuery = useDriversList({ status: 'active', per_page: 50 });
  const link = useDriverCoDriverLink();
  const unlink = useDriverCoDriverUnlink();

  const [selectedCandidate, setSelectedCandidate] = useState<string | null>(null);
  const [unlinkTarget, setUnlinkTarget] = useState<string | undefined>();

  const candidateOptions = useMemo(() => {
    const existingIds = new Set((coDriversQuery.data?.data ?? []).map((c) => c.driver_id));
    return (candidatesQuery.data?.data ?? [])
      .filter((d) => d.id && d.id !== driverId && !existingIds.has(d.id))
      .map((d) => ({
        value: d.id ?? '',
        label: formatPersonName(d, ''),
      }));
  }, [candidatesQuery.data, coDriversQuery.data, driverId]);

  const handleLink = () => {
    if (!selectedCandidate) return;
    link.mutate(
      { id: driverId, body: { co_driver_id: selectedCandidate } },
      {
        onSuccess: () => {
          toast.show({ variant: 'success', message: t('fleetDrivers.coDrivers.linked') });
          setSelectedCandidate(null);
        },
        onError: () => {
          toast.show({ variant: 'error', message: t('fleetDrivers.coDrivers.linkFailed') });
        },
      },
    );
  };

  const handleUnlink = () => {
    if (!unlinkTarget) return;
    unlink.mutate(
      { id: driverId, coDriverId: unlinkTarget },
      {
        onSuccess: () => {
          toast.show({ variant: 'success', message: t('fleetDrivers.coDrivers.unlinked') });
          setUnlinkTarget(undefined);
        },
        onError: () => {
          toast.show({ variant: 'error', message: t('fleetDrivers.coDrivers.unlinkFailed') });
          setUnlinkTarget(undefined);
        },
      },
    );
  };

  if (coDriversQuery.isLoading) {
    return <Skeleton variant="card" className="h-24" />;
  }

  if (coDriversQuery.isError) {
    return (
      <ErrorState
        message={t('fleetDrivers.coDrivers.loadError')}
        onRetry={() => void coDriversQuery.refetch()}
      />
    );
  }

  const coDrivers = coDriversQuery.data?.data ?? [];

  return (
    <div className="flex flex-col gap-3">
      <h3 className="text-body-lg font-semibold text-neutral-900">
        {t('fleetDrivers.coDrivers.title')}
      </h3>

      {coDrivers.length === 0 ? (
        <EmptyState
          title={t('fleetDrivers.coDrivers.emptyTitle')}
          description={t('fleetDrivers.coDrivers.emptyDescription')}
        />
      ) : (
        <ul className="flex flex-col gap-2">
          {coDrivers.map((coDriver) => (
            <li
              key={coDriver.pair_id ?? coDriver.driver_id}
              className="flex items-center justify-between rounded-md border border-stroke px-3 py-2"
            >
              <span className="flex items-center gap-2 text-body text-neutral-800">
                {formatPersonName(coDriver, '')}
                <Badge tone={coDriver.status === 'active' ? 'success' : 'neutral'}>
                  {coDriver.status}
                </Badge>
              </span>
              <PermissionGate permission={PERM.driversManageCoDrivers}>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setUnlinkTarget(coDriver.driver_id)}
                >
                  {t('fleetDrivers.coDrivers.unlink')}
                </Button>
              </PermissionGate>
            </li>
          ))}
        </ul>
      )}

      <PermissionGate permission={PERM.driversManageCoDrivers}>
        <div className="flex flex-wrap items-end gap-2">
          <Select
            value={selectedCandidate}
            onChange={setSelectedCandidate}
            options={candidateOptions}
            placeholder={t('fleetDrivers.coDrivers.selectPlaceholder')}
            searchable
            className="w-64"
          />
          <Button
            variant="secondary"
            onClick={handleLink}
            disabled={!selectedCandidate}
            loading={link.isPending}
          >
            {t('fleetDrivers.coDrivers.link')}
          </Button>
        </div>
      </PermissionGate>

      <ConfirmDialog
        open={Boolean(unlinkTarget)}
        onClose={() => setUnlinkTarget(undefined)}
        onConfirm={handleUnlink}
        variant="danger"
        loading={unlink.isPending}
        title={t('ui.overlay.confirmDialog.title')}
        description={t('fleetDrivers.coDrivers.unlinkConfirm')}
      />
    </div>
  );
}

export default CoDriversPanel;
