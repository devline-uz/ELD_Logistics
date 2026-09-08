import type { Notification } from '@/api/types';

export interface NotificationDayGroup {
  /** `Today` / `Yesterday` / kompaniya profiliga mos sana matni. */
  label: string;
  items: Notification[];
}

/**
 * Sahifa spetsifikatsiyasi (7.11): `Today`, `Yesterday`, keyin `<sana>`.
 * Kun taqqoslash **kompaniya Home Terminal timezone**ida bo'lishi shart
 * (F193) — shuning uchun taqqoslash `date-fns` bilan emas, chaqiruvchi
 * bergan `formatDate` (allaqachon kompaniya TZ/profiliga bog'langan,
 * `useDateFormat()`) natijalarini solishtirish orqali amalga oshiriladi.
 * Ro'yxat backenddan eng yangisi birinchi tartibda keladi — guruhlar shu
 * tartibni saqlaydi (qayta saralanmaydi).
 */
export function groupNotificationsByDay(
  items: readonly Notification[],
  formatDate: (value: string | Date | null | undefined) => string,
  labels: { today: string; yesterday: string },
  now: Date = new Date(),
): NotificationDayGroup[] {
  const todayLabel = formatDate(now);
  const yesterdayLabel = formatDate(new Date(now.getTime() - 24 * 60 * 60 * 1000));

  const groups: NotificationDayGroup[] = [];
  const indexByLabel = new Map<string, number>();

  for (const item of items) {
    const dayLabel = formatDate(item.created_at);
    const displayLabel =
      dayLabel === todayLabel
        ? labels.today
        : dayLabel === yesterdayLabel
          ? labels.yesterday
          : dayLabel;

    let index = indexByLabel.get(displayLabel);
    if (index === undefined) {
      index = groups.length;
      indexByLabel.set(displayLabel, index);
      groups.push({ label: displayLabel, items: [] });
    }
    groups[index]?.items.push(item);
  }

  return groups;
}
