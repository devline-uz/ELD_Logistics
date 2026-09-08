/**
 * MSW handler registri — Bosqich 7 (Dashboard/Notifications/Chat) egaligi.
 *
 * Boshqa domenlar (`units`, `drivers`, `dvir`, …) hozircha o'z faylida
 * qoladi va testlar ularni to'g'ridan-to'g'ri import qiladi (fe-testing
 * §MSW: "har integratsiya testi o'z handler to'plamini import qiladi").
 * Bu fayl faqat dev/e2e uchun **muvaffaqiyat** yo'lini beruvchi aggregator —
 * kelajakda boshqa modullar ham o'z `<modul>BaseHandlers`ini shu yerga
 * qo'shishi mumkin.
 */
import { chatBaseHandlers } from './chat';
import { dashboardBaseHandlers } from './dashboard';
import { notificationsBaseHandlers } from './notifications';

export const handlers = [
  ...dashboardBaseHandlers,
  ...notificationsBaseHandlers,
  ...chatBaseHandlers,
];
