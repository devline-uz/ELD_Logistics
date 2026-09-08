import { useEffect, useRef, useState } from 'react';
import { Bell } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate } from 'react-router-dom';

import {
  NOTIFICATIONS_UNREAD_QUERY_PARAMS,
  useNotificationRead,
  useNotificationsList,
  useNotificationsReadAll,
  useNotificationsUnreadCount,
} from '@/api/queries/notifications';
import type { Notification } from '@/api/types';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { useToast } from '@/components/feedback/toast-context';
import { useDateFormat } from '@/hooks/useDateFormat';

import { NotificationListItem } from './NotificationListItem';
import { resolveNotificationPath } from '../lib/entityLinks';

/**
 * Header qo'ng'iroq dropdown'i (7.8): o'qilmaganlar soni belgisi, oxirgi
 * 10 ta bildirishnoma, `Mark all as read`, `View all` → `/notifications`.
 *
 * Ro'yxat faqat panel ochilganda so'raladi (`enabled: open`); belgi soni
 * doim yangi turishi uchun alohida, doimiy yoqilgan hook (`useNotificationsUnreadCount`).
 */
export function NotificationsDropdown() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const toast = useToast();
  const { formatRelative } = useDateFormat();

  const [open, setOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const toggleRef = useRef<HTMLButtonElement>(null);

  const unread = useNotificationsUnreadCount();
  const list = useNotificationsList(NOTIFICATIONS_UNREAD_QUERY_PARAMS, { enabled: open });
  const markRead = useNotificationRead();
  const markAllRead = useNotificationsReadAll();

  useEffect(() => {
    if (!open) return undefined;

    const onPointerDown = (event: MouseEvent) => {
      if (!containerRef.current?.contains(event.target as Node)) {
        setOpen(false);
      }
    };
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setOpen(false);
        toggleRef.current?.focus();
      }
    };
    document.addEventListener('mousedown', onPointerDown);
    document.addEventListener('keydown', onKeyDown);
    return () => {
      document.removeEventListener('mousedown', onPointerDown);
      document.removeEventListener('keydown', onKeyDown);
    };
  }, [open]);

  const unreadCount = unread.data ?? 0;
  const items = list.data?.data ?? [];

  const handleActivate = (notification: Notification) => {
    if (!notification.read && notification.id) {
      markRead.mutate(notification.id);
    }
    setOpen(false);
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
    <div className="relative" ref={containerRef}>
      <button
        ref={toggleRef}
        type="button"
        className="relative rounded p-1"
        aria-haspopup="menu"
        aria-expanded={open}
        aria-label={
          unreadCount > 0
            ? t('nav.brand.notificationsUnread', { count: unreadCount })
            : t('nav.brand.notifications')
        }
        onClick={() => {
          setOpen((value) => !value);
        }}
      >
        <Bell aria-hidden="true" className="h-5 w-5" strokeWidth={1.5} />
        {unreadCount > 0 ? (
          <span className="absolute -end-1 -top-1 rounded-full bg-white px-1 text-[10px] font-semibold text-primary">
            {unreadCount > 99 ? '99+' : unreadCount}
          </span>
        ) : null}
      </button>

      {open ? (
        <div
          role="menu"
          aria-label={t('notifications.dropdown.label')}
          className="absolute end-0 top-10 z-40 w-96 rounded-lg border border-stroke bg-surface text-neutral-800 shadow-dropdown"
        >
          <div className="flex items-center justify-between border-b border-stroke px-3 py-2">
            <span className="text-body-sm font-semibold text-neutral-900">
              {t('notifications.dropdown.title')}
            </span>
            <button
              type="button"
              onClick={handleMarkAllRead}
              disabled={unreadCount === 0 || markAllRead.isPending}
              className="text-body-sm font-medium text-primary disabled:cursor-not-allowed disabled:text-neutral-400"
            >
              {t('notifications.dropdown.markAllRead')}
            </button>
          </div>

          <div className="max-h-96 overflow-y-auto">
            {list.isLoading ? (
              <div className="p-3">
                <Skeleton variant="text" count={4} />
              </div>
            ) : list.isError ? (
              <ErrorState
                title={t('notifications.dropdown.errorTitle')}
                message={list.error?.message}
                onRetry={() => void list.refetch()}
              />
            ) : items.length === 0 ? (
              <p className="px-3 py-8 text-center text-body-sm text-neutral-500">
                {t('notifications.dropdown.empty')}
              </p>
            ) : (
              <ul role="none">
                {items.map((notification) => (
                  <li key={notification.id} role="none">
                    <NotificationListItem
                      notification={notification}
                      relativeTime={formatRelative(notification.created_at)}
                      onActivate={handleActivate}
                    />
                  </li>
                ))}
              </ul>
            )}
          </div>

          <Link
            role="menuitem"
            to="/notifications"
            onClick={() => {
              setOpen(false);
            }}
            className="block border-t border-stroke px-3 py-2 text-center text-body-sm font-medium text-primary hover:bg-surface-muted"
          >
            {t('notifications.dropdown.viewAll')}
          </Link>
        </div>
      ) : null}
    </div>
  );
}

export default NotificationsDropdown;
