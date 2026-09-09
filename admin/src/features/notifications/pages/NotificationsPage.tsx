/**
 * Notifications sahifasi — `/notifications` (7.8, TZ §7.11).
 *
 * Sana bo'yicha guruhlangan (`Today` / `Yesterday` / `<sana>`), `read` va
 * `alert_type` filtrlari, bitta va hammasini o'qilgan deb belgilash,
 * 10/25/50 sahifalash. Ruxsat — `notifications.read` (marshrutda `RouteGuard`
 * orqali; uchala endpoint ham bitta kalit bilan yopiladi).
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import {
  useNotificationRead,
  useNotificationsList,
  useNotificationsReadAll,
} from '@/api/queries/notifications';
import type { Notification, NotificationsListParams } from '@/api/types';
import { Pagination } from '@/components/data/Pagination';
import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { useToast } from '@/components/feedback/toast-context';
import { Select, type SelectOption } from '@/components/ui/Select';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';

import { NotificationListItem } from '../components/NotificationListItem';
import { ALERT_TYPES } from '../lib/alertTypes';
import { resolveNotificationPath } from '../lib/entityLinks';
import { groupNotificationsByDay } from '../lib/groupByDay';

type ReadFilter = 'all' | 'unread' | 'read';

function toReadParam(filter: ReadFilter): boolean | undefined {
  if (filter === 'unread') return false;
  if (filter === 'read') return true;
  return undefined;
}

export function NotificationsPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const toast = useToast();
  const { formatDate, formatRelative } = useDateFormat();
  const listParams = useListParams();

  const readFilter: ReadFilter =
    listParams.filters.read === 'unread' || listParams.filters.read === 'read'
      ? listParams.filters.read
      : 'all';
  const alertTypeFilter = listParams.filters.alert_type || null;

  const queryParams = useMemo<NotificationsListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      read: toReadParam(readFilter),
      alert_type: (alertTypeFilter as NotificationsListParams['alert_type']) || undefined,
    }),
    [listParams.page, listParams.perPage, readFilter, alertTypeFilter],
  );

  const list = useNotificationsList(queryParams);
  const markRead = useNotificationRead();
  const markAllRead = useNotificationsReadAll();

  const items = useMemo(() => list.data?.data ?? [], [list.data]);
  const total = list.data?.meta?.total ?? 0;
  const unreadTotal = list.data?.meta?.unread ?? 0;

  const groups = useMemo(
    () =>
      groupNotificationsByDay(items, formatDate, {
        today: t('notifications.page.groups.today'),
        yesterday: t('notifications.page.groups.yesterday'),
      }),
    [items, formatDate, t],
  );

  const readOptions: SelectOption<ReadFilter>[] = [
    { value: 'all', label: t('notifications.page.filters.readAll') },
    { value: 'unread', label: t('notifications.page.filters.readUnread') },
    { value: 'read', label: t('notifications.page.filters.readRead') },
  ];

  const alertTypeOptions: SelectOption<string>[] = ALERT_TYPES.map((type) => ({
    value: type,
    label: t(`enums.alert_type.${type}`),
  }));

  const handleActivate = (notification: Notification) => {
    if (!notification.read && notification.id) {
      markRead.mutate(notification.id);
    }
    const path = resolveNotificationPath(notification.entity_type, notification.entity_id);
    if (path) navigate(path);
  };

  const handleMarkAllRead = () => {
    markAllRead.mutate(undefined, {
      onSuccess: () => {
        toast.show({ variant: 'success', message: t('notifications.toast.markAllRead') });
      },
    });
  };

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-h3 font-bold text-neutral-900">{t('notifications.page.title')}</h1>
        <button
          type="button"
          onClick={handleMarkAllRead}
          disabled={unreadTotal === 0 || markAllRead.isPending}
          className="rounded-md border border-stroke px-3 py-1.5 text-body-sm font-medium text-primary disabled:cursor-not-allowed disabled:text-neutral-400"
        >
          {t('notifications.page.markAllRead')}
        </button>
      </div>

      <div className="flex flex-wrap gap-3">
        <Select
          id="notifications-filter-read"
          label={t('notifications.page.filters.readLabel')}
          options={readOptions}
          value={readFilter}
          onChange={(value) =>
            listParams.setFilter('read', value && value !== 'all' ? value : undefined)
          }
          className="w-48"
        />
        <Select
          id="notifications-filter-alert-type"
          label={t('notifications.page.filters.alertTypeLabel')}
          options={alertTypeOptions}
          value={alertTypeFilter}
          onChange={(value) => listParams.setFilter('alert_type', value ?? undefined)}
          placeholder={t('notifications.page.filters.alertTypeAll')}
          clearable
          className="w-64"
        />
      </div>

      <div className="rounded-lg border border-stroke bg-surface">
        {list.isLoading ? (
          <div className="p-4">
            <Skeleton variant="text" count={5} />
          </div>
        ) : list.isError ? (
          <ErrorState
            title={t('notifications.page.errorTitle')}
            message={list.error?.message}
            onRetry={() => void list.refetch()}
          />
        ) : items.length === 0 ? (
          <EmptyState
            title={
              listParams.hasActiveFilters
                ? t('notifications.page.empty.filteredTitle')
                : t('notifications.page.empty.title')
            }
            description={
              listParams.hasActiveFilters
                ? t('notifications.page.empty.filteredDescription')
                : t('notifications.page.empty.description')
            }
            action={
              listParams.hasActiveFilters ? (
                <button
                  type="button"
                  onClick={listParams.clearFilters}
                  className="text-body-sm font-medium text-primary"
                >
                  {t('notifications.page.empty.clearFilters')}
                </button>
              ) : undefined
            }
          />
        ) : (
          <div>
            {groups.map((group) => (
              <div key={group.label}>
                <h2 className="border-b border-t border-stroke bg-surface-muted px-4 py-2 text-body-sm font-medium uppercase tracking-wide text-neutral-600">
                  {group.label}
                </h2>
                <ul>
                  {group.items.map((notification) => (
                    <li key={notification.id} className="border-b border-stroke last:border-b-0">
                      <NotificationListItem
                        notification={notification}
                        relativeTime={formatRelative(notification.created_at)}
                        onActivate={handleActivate}
                      />
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        )}
      </div>

      <Pagination
        page={listParams.page}
        perPage={listParams.perPage}
        total={total}
        onPageChange={listParams.setPage}
        onPerPageChange={listParams.setPerPage}
      />
    </div>
  );
}

export default NotificationsPage;
