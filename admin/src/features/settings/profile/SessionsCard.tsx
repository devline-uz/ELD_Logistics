import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import { useMySessions, useRevokeSession } from '@/api/queries/profile';
import { clearSession } from '@/api/session';
import type { SessionInfo } from '@/api/types';
import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { useToast } from '@/components/feedback/toast-context';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { useDateFormat } from '@/hooks/useDateFormat';
import { isApiError } from '@/lib/errors';

type PendingAction = { kind: 'one'; session: SessionInfo } | { kind: 'others' } | null;

/** Settings › Security «Active sessions» (7.13.7). `GET /auth/sessions`. */
export function SessionsCard() {
  const { t } = useTranslation();
  const toast = useToast();
  const navigate = useNavigate();
  const { formatDateTime } = useDateFormat();
  const { data: sessions, isPending, isError, error, refetch } = useMySessions();
  const revoke = useRevokeSession();
  const [pending, setPending] = useState<PendingAction>(null);

  const others = (sessions ?? []).filter((session) => !session.current);

  const signOutLocally = () => {
    clearSession();
    void navigate('/login?reason=user', { replace: true });
  };

  const confirmRevoke = async () => {
    if (!pending) return;

    if (pending.kind === 'one') {
      const { session } = pending;
      try {
        await revoke.mutateAsync(session.id ?? '');
        setPending(null);
        if (session.current) {
          signOutLocally();
          return;
        }
        toast.show({ variant: 'success', message: t('settings.security.sessions.revoked') });
      } catch {
        setPending(null);
      }
      return;
    }

    // 'others' — ketma-ket tugatiladi (backend "revoke all" endpointi yo'q).
    try {
      for (const session of others) {
        await revoke.mutateAsync(session.id ?? '');
      }
      setPending(null);
      toast.show({ variant: 'success', message: t('settings.security.sessions.revokedAllOthers') });
    } catch {
      setPending(null);
    }
  };

  return (
    <Card
      actions={
        others.length > 0 ? (
          <Button
            onClick={() => {
              setPending({ kind: 'others' });
            }}
            size="sm"
            variant="secondary"
          >
            {t('settings.security.sessions.revokeAllOthers')}
          </Button>
        ) : undefined
      }
      title={t('settings.security.sessions.title')}
    >
      {isPending ? (
        <Skeleton count={3} variant="table-row" />
      ) : isError ? (
        <ErrorState
          message={isApiError(error) ? error.message : t('settings.security.sessions.loadError')}
          onRetry={() => {
            void refetch();
          }}
        />
      ) : !sessions || sessions.length === 0 ? (
        <EmptyState description={t('settings.security.sessions.empty')} />
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-body-sm">
            <thead>
              <tr className="border-b border-stroke text-left text-neutral-600">
                <th className="py-2 pr-4 font-medium uppercase tracking-wide">
                  {t('settings.security.sessions.deviceType')}
                </th>
                <th className="py-2 pr-4 font-medium uppercase tracking-wide">
                  {t('settings.security.sessions.device')}
                </th>
                <th className="py-2 pr-4 font-medium uppercase tracking-wide">
                  {t('settings.security.sessions.ip')}
                </th>
                <th className="py-2 pr-4 font-medium uppercase tracking-wide">
                  {t('settings.security.sessions.lastSeen')}
                </th>
                <th className="py-2 pr-4" />
              </tr>
            </thead>
            <tbody>
              {sessions.map((session) => (
                <tr className="border-b border-stroke last:border-0" key={session.id}>
                  <td className="py-2 pr-4 text-neutral-800">
                    {session.device_type
                      ? t(`settings.security.sessions.deviceTypeLabels.${session.device_type}`)
                      : t('common.na')}
                  </td>
                  <td className="py-2 pr-4 text-neutral-800">
                    {session.user_agent ?? t('common.na')}
                  </td>
                  <td className="py-2 pr-4 text-neutral-800">{session.ip ?? t('common.na')}</td>
                  <td className="py-2 pr-4 text-neutral-800">
                    {session.last_seen_at ? formatDateTime(session.last_seen_at) : t('common.na')}
                  </td>
                  <td className="py-2 pr-4 text-right">
                    <div className="flex items-center justify-end gap-2">
                      {session.current ? (
                        <Badge tone="info">{t('settings.security.sessions.current')}</Badge>
                      ) : null}
                      <Button
                        aria-label={t('settings.security.sessions.revoke')}
                        onClick={() => {
                          setPending({ kind: 'one', session });
                        }}
                        size="sm"
                        variant="ghost"
                      >
                        {t('settings.security.sessions.revoke')}
                      </Button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <ConfirmDialog
        description={
          pending?.kind === 'one'
            ? pending.session.current
              ? t('settings.security.sessions.confirmRevokeCurrent')
              : t('settings.security.sessions.confirmRevoke')
            : t('settings.security.sessions.confirmRevokeOthers')
        }
        loading={revoke.isPending}
        onClose={() => {
          setPending(null);
        }}
        onConfirm={() => {
          void confirmRevoke();
        }}
        open={pending !== null}
        title={t('settings.security.sessions.confirmRevokeTitle')}
        variant="danger"
      />
    </Card>
  );
}

export default SessionsCard;
