/**
 * Notification settings — matritsa (8.5, §7.13.4): qator = `alert_type`,
 * ustun = kanal (`push · email · sms · telegram`) + qabul qiluvchi rollar.
 *
 * Katta matritsa uchun a11y: har qator/ustun sarlavhasi `scope` bilan,
 * checkbox'lar `Tab`/`Space` bilan yuriladi (native input — qo'shimcha
 * klaviatura ishlovi shart emas). Majburiy kataklar (F148/Q89) `disabled`
 * bo'lsa ham **belgilangan** ko'rinadi va tooltip sababni tushuntiradi.
 */
import { useTranslation } from 'react-i18next';

import { isNotificationChannelLocked } from '@/api/queries/notificationSettings';
import type { Role } from '@/api/types';
import { Checkbox } from '@/components/ui/Checkbox';
import { MultiSelect } from '@/components/ui/MultiSelect';
import { Switch } from '@/components/ui/Switch';
import { Tooltip } from '@/components/ui/Tooltip';

import { NOTIFICATION_CHANNELS, toggleChannel, type NotificationMatrixRow } from '../lib/matrix';

export interface NotificationMatrixProps {
  rows: NotificationMatrixRow[];
  onChange: (
    alertType: string,
    updater: (row: NotificationMatrixRow) => NotificationMatrixRow,
  ) => void;
  roles?: Role[];
  disabled?: boolean;
}

export function NotificationMatrix({ rows, onChange, roles, disabled }: NotificationMatrixProps) {
  const { t } = useTranslation();

  const roleOptions = (roles ?? [])
    .filter((role): role is Role & { id: string } => Boolean(role.id))
    .map((role) => ({ value: role.id, label: role.name ?? role.id }));

  return (
    <div className="overflow-x-auto">
      <table className="w-full min-w-[720px] text-body-sm">
        <caption className="sr-only">{t('settings.notifications.matrix.caption')}</caption>
        <thead>
          <tr className="border-b border-stroke bg-surface-muted text-left uppercase tracking-wide text-neutral-600">
            <th scope="col" className="sticky left-0 bg-surface-muted px-3 py-2 font-medium">
              {t('settings.notifications.matrix.alertType')}
            </th>
            <th scope="col" className="px-3 py-2 font-medium">
              {t('settings.notifications.matrix.enabled')}
            </th>
            {NOTIFICATION_CHANNELS.map((channel) => (
              <th key={channel} scope="col" className="px-3 py-2 text-center font-medium">
                {t(`settings.notifications.channels.${channel}`)}
              </th>
            ))}
            {roles ? (
              <th scope="col" className="px-3 py-2 font-medium">
                {t('settings.notifications.matrix.recipients')}
              </th>
            ) : null}
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.alertType} className="border-b border-stroke last:border-0">
              <th
                scope="row"
                className="sticky left-0 bg-surface px-3 py-2 text-left font-medium text-neutral-800"
              >
                {t(`enums.alert_type.${row.alertType}`, row.alertType)}
              </th>
              <td className="px-3 py-2">
                <Switch
                  aria-label={t('settings.notifications.matrix.enabledFor', {
                    type: t(`enums.alert_type.${row.alertType}`, row.alertType),
                  })}
                  checked={row.enabled}
                  disabled={disabled}
                  onChange={(event) =>
                    onChange(row.alertType, (current) => ({
                      ...current,
                      enabled: event.target.checked,
                    }))
                  }
                />
              </td>
              {NOTIFICATION_CHANNELS.map((channel) => {
                const locked = isNotificationChannelLocked(row.alertType, channel);
                const checkbox = (
                  <Checkbox
                    aria-label={t('settings.notifications.matrix.channelFor', {
                      channel: t(`settings.notifications.channels.${channel}`),
                      type: t(`enums.alert_type.${row.alertType}`, row.alertType),
                    })}
                    checked={row.channels.includes(channel)}
                    disabled={disabled || locked}
                    onChange={(event) =>
                      onChange(row.alertType, (current) =>
                        toggleChannel(current, channel, event.target.checked),
                      )
                    }
                  />
                );
                return (
                  <td key={channel} className="px-3 py-2 text-center">
                    {locked ? (
                      <Tooltip content={t('settings.notifications.matrix.lockedReason')}>
                        {/* Majburiy (disabled) checkbox brauzerda Tab bilan o'tkazilmaydi —
                            wrapper klaviatura fokusini qabul qilib tooltip/sababni ochadi
                            (F148/Q89, ataylab ko'zga ko'rinmas interaktiv element emas). */}
                        {/* eslint-disable-next-line jsx-a11y/no-noninteractive-tabindex */}
                        <span tabIndex={0} className="inline-flex">
                          {checkbox}
                        </span>
                      </Tooltip>
                    ) : (
                      checkbox
                    )}
                  </td>
                );
              })}
              {roles ? (
                <td className="min-w-[220px] px-3 py-2">
                  <MultiSelect
                    label={t('settings.notifications.matrix.recipientsFor', {
                      type: t(`enums.alert_type.${row.alertType}`, row.alertType),
                    })}
                    options={roleOptions}
                    values={row.recipientRoles}
                    disabled={disabled}
                    onChange={(values) =>
                      onChange(row.alertType, (current) => ({ ...current, recipientRoles: values }))
                    }
                  />
                </td>
              ) : null}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default NotificationMatrix;
