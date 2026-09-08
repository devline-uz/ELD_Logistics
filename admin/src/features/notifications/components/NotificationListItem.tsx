import { useTranslation } from 'react-i18next';

import type { Notification } from '@/api/types';

import { alertSeverity } from '../lib/alertTypes';

export interface NotificationListItemProps {
  notification: Notification;
  /** Kompaniya TZ/profiliga bog'langan nisbiy vaqt (`useDateFormat().formatRelative`). */
  relativeTime: string;
  onActivate: (notification: Notification) => void;
}

const SEVERITY_DOT_CLASSES: Record<string, string> = {
  error: 'bg-error-base',
  warning: 'bg-warning-base',
  neutral: 'bg-neutral-400',
};

/**
 * Bitta bildirishnoma qatori — dropdown va sahifada bir xil ko'rinish.
 * Bosilganda `onActivate` chaqiriladi (o'qilgan deb belgilash + mumkin
 * bo'lsa navigatsiya — qaror chaqiruvchida, `entityLinks.ts` orqali).
 */
export function NotificationListItem({
  notification,
  relativeTime,
  onActivate,
}: NotificationListItemProps) {
  const { t } = useTranslation();
  const unread = !notification.read;
  const severity = alertSeverity(notification.alert_type);

  return (
    <button
      type="button"
      onClick={() => onActivate(notification)}
      className={`flex w-full items-start gap-3 px-3 py-2.5 text-start hover:bg-surface-muted ${
        unread ? 'bg-light' : ''
      }`}
      aria-label={
        unread
          ? t('notifications.item.unreadLabel', { title: notification.title ?? '' })
          : (notification.title ?? '')
      }
    >
      <span
        aria-hidden="true"
        className={`mt-1.5 h-2 w-2 shrink-0 rounded-full ${SEVERITY_DOT_CLASSES[severity]}`}
      />
      <span className="min-w-0 flex-1">
        <span className="block truncate text-body-sm font-medium text-neutral-900">
          {notification.title}
        </span>
        {notification.body ? (
          <span className="line-clamp-2 block text-body-sm text-neutral-500">
            {notification.body}
          </span>
        ) : null}
        <span className="mt-0.5 block text-body-xs text-neutral-400">{relativeTime}</span>
      </span>
      {unread ? (
        <span
          aria-hidden="true"
          className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full bg-primary"
          title={t('notifications.item.unread')}
        />
      ) : null}
    </button>
  );
}

export default NotificationListItem;
