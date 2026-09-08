/**
 * Maintenance uchta tabi — bitta marshrut oilasi (`docs/tz/07-5-*.md` §7.6).
 * Tab almashishi URL'ni o'zgartiradi (har tabning o'z endpointi bor).
 */
import type { ListScreenTab } from '@/components/data/ListScreen';

export type MaintenanceTabKey = 'schedules' | 'due' | 'history';

export const MAINTENANCE_TAB_PATHS: Record<MaintenanceTabKey, string> = {
  schedules: '/maintenance/schedules',
  due: '/maintenance/due',
  history: '/maintenance/history',
};

/** `t` bilan tarjima qilingan tab ro'yxati. */
export function maintenanceTabs(t: (key: string) => string): ListScreenTab[] {
  return [
    { key: 'schedules', label: t('maintenance.tabs.schedules') },
    { key: 'due', label: t('maintenance.tabs.due') },
    { key: 'history', label: t('maintenance.tabs.history') },
  ];
}
