/**
 * Notification settings — `/settings/notifications` (8.5, §7.13.4).
 *
 * `GET/PATCH /company/notification-settings`. Matritsa: qator — `alert_type`
 * (backend nechta qaytarsa, o'shancha — hardcode qilinmagan), ustun — kanal
 * (`push · email · sms · telegram`, D38: `in_app` **yo'q**). Saqlash faqat
 * o'zgargan qatorlarni yuboradi, muvaffaqiyatsiz bo'lsa oldingi holat
 * qaytariladi (optimistik emas — fe-screens §2).
 */
import { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import {
  useNotificationSettingsList,
  useNotificationSettingsUpdate,
} from '@/api/queries/notificationSettings';
import { useRolesList } from '@/api/queries/roles';
import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { useToast } from '@/components/feedback/toast-context';
import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { Button } from '@/components/ui/Button';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { isApiError } from '@/lib/errors';
import { PERM, usePermission } from '@/lib/permissions';

import { NotificationMatrix } from '../notifications/components/NotificationMatrix';
import {
  buildNotificationSettingsPayload,
  settingsToRows,
  type NotificationMatrixRow,
} from '../notifications/lib/matrix';

export function NotificationSettingsPage() {
  const { t } = useTranslation();
  const toast = useToast();
  const can = usePermission();

  const listQuery = useNotificationSettingsList();
  const update = useNotificationSettingsUpdate();
  const canReadRoles = can(PERM.rolesRead);
  // `useRolesList` `enabled` parametrini qabul qilmaydi (api/queries — o'zgartirilmaydi,
  // fe-conventions W2), shuning uchun so'rov har doim yuboriladi; natija faqat
  // `roles.read` bo'lganda ishlatiladi (backend ruxsatsiz so'rovni 403 bilan rad etadi).
  const rolesQuery = useRolesList({ per_page: 100 });

  const [rows, setRows] = useState<NotificationMatrixRow[]>([]);
  const [originalRows, setOriginalRows] = useState<NotificationMatrixRow[]>([]);

  useEffect(() => {
    if (listQuery.data) {
      const nextRows = settingsToRows(listQuery.data);
      setRows(nextRows);
      setOriginalRows(nextRows);
    }
  }, [listQuery.data]);

  const canUpdate = can(PERM.notificationSettingsUpdate);

  const payload = useMemo(
    () => buildNotificationSettingsPayload(originalRows, rows),
    [originalRows, rows],
  );
  const isDirty = payload.length > 0;

  const updateRow = (
    alertType: string,
    updater: (row: NotificationMatrixRow) => NotificationMatrixRow,
  ) => {
    setRows((current) => current.map((row) => (row.alertType === alertType ? updater(row) : row)));
  };

  const handleSave = async () => {
    try {
      const saved = await update.mutateAsync({ settings: payload });
      const nextRows = settingsToRows(saved);
      setRows(nextRows);
      setOriginalRows(nextRows);
      toast.show({ variant: 'success', message: t('settings.notifications.toast.saved') });
    } catch (error) {
      toast.show({
        variant: 'error',
        message: isApiError(error) ? error.message : t('errors.unknown'),
      });
      // Muvaffaqiyatsiz bo'lsa — oldingi (server) holatga qaytariladi (optimistik emas).
      setRows(originalRows);
    }
  };

  if (listQuery.isLoading) {
    return (
      <div className="flex flex-col gap-4 p-6">
        <Skeleton variant="text" className="h-8 w-64" />
        <Skeleton variant="card" count={4} />
      </div>
    );
  }

  if (listQuery.isError) {
    return (
      <ErrorState message={listQuery.error?.message} onRetry={() => void listQuery.refetch()} />
    );
  }

  return (
    <div className="flex flex-col gap-6 p-6">
      <Breadcrumb
        items={[
          { label: t('settings.notifications.breadcrumb.settings') },
          { label: t('settings.notifications.title') },
        ]}
      />

      <div className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-h3 font-bold text-neutral-900">
            {t('settings.notifications.title')}
          </h1>
          <p className="text-body text-neutral-600">{t('settings.notifications.description')}</p>
        </div>
        <PermissionGate permission={PERM.notificationSettingsUpdate}>
          <Button onClick={() => void handleSave()} loading={update.isPending} disabled={!isDirty}>
            {t('common.actions.saveChanges')}
          </Button>
        </PermissionGate>
      </div>

      {rows.length === 0 ? (
        <EmptyState
          title={t('settings.notifications.empty.title')}
          description={t('settings.notifications.empty.description')}
        />
      ) : (
        <NotificationMatrix
          rows={rows}
          onChange={updateRow}
          roles={canReadRoles ? rolesQuery.data?.data : undefined}
          disabled={!canUpdate}
        />
      )}
    </div>
  );
}

export default NotificationSettingsPage;
