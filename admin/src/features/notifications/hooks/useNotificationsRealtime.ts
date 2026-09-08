/**
 * `notifications` WS kanaliga global obuna (F156 — ildizda bir marta,
 * unmount bo'lmaydi). `NotificationsRealtimeProvider` shu hookni chaqiradi.
 *
 * Har `notification_created` hodisasida kesh yangilanadi
 * (`applyNotificationCreatedEvent` — `api/queries/notifications.ts`, mavjud
 * sof funksiya). Toast faqat F143 shartida: replay **emas** va `alert_type`
 * `*_violation` / `dvir_critical` / `eld_malfunction` oilasidan bo'lsa.
 *
 * `useNavigate()` ataylab ishlatilmaydi — bu provayder `RouterProvider`dan
 * **yuqorida** (`main.tsx`: `AppProviders > RouterProvider`) turadi, Router
 * konteksti hali mavjud emas. Toast shunchaki xabar beradi; foydalanuvchi
 * qo'ng'iroq yoki `/notifications` orqali navigatsiya qiladi.
 */
import { useRef } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';

import { applyNotificationCreatedEvent } from '@/api/queries/notifications';
import type { Notification } from '@/api/types';
import { useToast } from '@/components/feedback/toast-context';
import { useChannel } from '@/hooks/useChannel';
import { PERM, usePermission } from '@/lib/permissions';
import type { RealtimeEvent } from '@/lib/ws';

import { shouldToastForAlertType } from '../lib/alertTypes';

/**
 * Toast toshqinidan himoya (fe-security — WS hodisalari DoS'i): buzilgan yoki
 * shovqinli oqim yuzlab `*_violation` hodisasini yuborsa, `ToastProvider`
 * navbati cheksiz o'sib, `error` toastlari o'zi yopilmagani uchun ekranni
 * bosib qolardi. Kesh **har doim** yangilanadi — faqat toast cheklanadi.
 */
const TOAST_WINDOW_MS = 10_000;
const MAX_TOASTS_PER_WINDOW = 3;

export function useNotificationsRealtime(): void {
  const can = usePermission();
  const queryClient = useQueryClient();
  const toast = useToast();
  const { t } = useTranslation();
  /** Joriy oynadagi toast vaqtlari — eskilar har chaqiruvda tashlab yuboriladi. */
  const recentToastsRef = useRef<number[]>([]);

  useChannel<Notification>(
    'notifications',
    undefined,
    (event: RealtimeEvent<Notification>) => {
      if (event.type !== 'notification_created') return;
      const notification = event.data;

      applyNotificationCreatedEvent(queryClient, notification);

      if (event.replay) return;
      if (!shouldToastForAlertType(notification.alert_type)) return;

      const now = Date.now();
      recentToastsRef.current = recentToastsRef.current.filter((at) => now - at < TOAST_WINDOW_MS);
      if (recentToastsRef.current.length >= MAX_TOASTS_PER_WINDOW) return;
      recentToastsRef.current.push(now);

      toast.show({
        variant: 'error',
        message: notification.title || t('notifications.toast.newAlert'),
      });
    },
    { enabled: can(PERM.notificationsRead) },
  );
}
