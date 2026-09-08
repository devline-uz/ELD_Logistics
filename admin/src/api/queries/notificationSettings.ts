/**
 * Notification settings — TanStack Query hooklari (Bosqich 8.1, fe-api §3,
 * `docs/tz/07-13-settings-admin.md` §7.13.4, TZ A§19/Q89).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /company/notification-settings`, `PATCH /company/notification-settings`.
 * Ruxsatlar: `notification_settings.read`, `notification_settings.update`.
 *
 * Matritsa: qator — `alert_type` (swagger enumida **16** ta, kompaniya
 * moslashtirmagan turlar ham default kanallari bilan qaytadi — "Alert types
 * the company never customised are returned with the defaults of the
 * specification table"), ustun — `channels` (`push · email · sms · telegram`).
 *
 * ⚠️ TZ §7.13.4 kanal ustunini `push · email · sms · in_app` deb yozgan, ammo
 * swagger `NotificationSetting.channels`/`NotificationSettingUpdate.channels`
 * enumi **`push · email · sms · telegram`** (`in_app` yo'q). Backend — haqiqat
 * manbai (fe-api §1): ekran shu 4 kanalni ko'rsatadi, `in_app` yozilmaydi.
 *
 * Turlar ro'yxati bu faylda **hardcode qilinmagan** — `useNotificationSettingsList`
 * backend nima qaytarsa (necha va qaysi `alert_type`) o'shani beradi; screen
 * ustunlarni shu ro'yxatdan quradi. `isNotificationChannelLocked` — F148 (Q89)
 * qoidasini **qiymat prefiksidan** hisoblaydi (`hos_*`/`eld_*`), backend
 * qaytargan `alert_type` string'iga qarab — turlarning o'zi bu yerda ro'yxat
 * sifatida saqlanmaydi.
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { NotificationSetting, NotificationSettingsUpdate } from '@/api/types';
import type { ApiError } from '@/lib/errors';

/** Query key fabrikasi — `['notification-settings', <tur>, ...]` (fe-conventions §3). */
export const notificationSettingsKeys = {
  all: ['notification-settings'] as const,
  list: () => [...notificationSettingsKeys.all, 'list'] as const,
};

/**
 * `GET /company/notification-settings` (`notification_settings.read`) —
 * bildirishnoma matritsasi (7.13.4).
 */
export function useNotificationSettingsList(
  options: { enabled?: boolean } = {},
): UseQueryResult<NotificationSetting[], ApiError> {
  return useQuery({
    queryKey: notificationSettingsKeys.list(),
    queryFn: async () => {
      const { data } = await api.GET('/company/notification-settings', {});
      return data?.data ?? [];
    },
    enabled: options.enabled ?? true,
  });
}

/**
 * `PATCH /company/notification-settings` (`notification_settings.update`) —
 * faqat `settings[]` da ko'rsatilgan turlar yoziladi, qolganlari o'zgarmaydi
 * (swagger, Q89). `channels` butunlay almashtiriladi — bo'sh ro'yxat barcha
 * kanallarni o'chiradi.
 */
export function useNotificationSettingsUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: NotificationSettingsUpdate) => {
      const { data } = await api.PATCH('/company/notification-settings', { body });
      return data?.data ?? [];
    },
    onSuccess: (settings) => {
      queryClient.setQueryData(notificationSettingsKeys.list(), settings);
      void queryClient.invalidateQueries({ queryKey: notificationSettingsKeys.list() });
    },
  });
}

/**
 * F148 (Q89): `hos_*` va `eld_*` bilan boshlanuvchi `alert_type` uchun `push`
 * kanali o'chirilmaydi — checkbox `disabled` + sabab tooltipi bilan ko'rsatiladi.
 * Qoida backend qaytargan `alert_type` **qiymatidan** hisoblanadi, o'zi
 * ro'yxat sifatida hardcode qilinmagan (yangi `hos_*`/`eld_*` turi backendda
 * paydo bo'lsa, bu funksiya kod o'zgarishisiz to'g'ri ishlaydi).
 */
export function isNotificationChannelLocked(alertType: string, channel: string): boolean {
  return channel === 'push' && (alertType.startsWith('hos_') || alertType.startsWith('eld_'));
}
