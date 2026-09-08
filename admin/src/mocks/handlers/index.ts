/**
 * MSW handler registri — Bosqich 7 (Dashboard/Notifications/Chat) va
 * Bosqich 8.1 (Company/HOS Policy/Notification settings/Support/Feedback/
 * Audit) egaligi.
 *
 * Boshqa domenlar (`units`, `drivers`, `dvir`, …) hozircha o'z faylida
 * qoladi va testlar ularni to'g'ridan-to'g'ri import qiladi (fe-testing
 * §MSW: "har integratsiya testi o'z handler to'plamini import qiladi").
 * Bu fayl faqat dev/e2e uchun **muvaffaqiyat** yo'lini beruvchi aggregator —
 * kelajakda boshqa modullar ham o'z `<modul>BaseHandlers`ini shu yerga
 * qo'shishi mumkin.
 */
import { auditLogListHandler, auditLogTablesHandler } from './audit';
import { chatBaseHandlers } from './chat';
import { companyGetHandler, companyHistoryListHandler, companyUpdateHandler } from './company';
import { dashboardBaseHandlers } from './dashboard';
import { feedbackListHandler } from './feedback';
import { hosPolicyGetHandler, hosPolicyPublishHandler } from './hosPolicy';
import { inspectionEmailSendHandler, inspectionLogsHandler } from './inspection';
import {
  notificationSettingsListHandler,
  notificationSettingsUpdateHandler,
} from './notificationSettings';
import { notificationsBaseHandlers } from './notifications';
import {
  supportTicketDetailHandler,
  supportTicketMessageCreateHandler,
  supportTicketMessagesHandler,
  supportTicketsListHandler,
  supportTicketStatusUpdateHandler,
} from './support';

export const handlers = [
  ...dashboardBaseHandlers,
  ...notificationsBaseHandlers,
  ...chatBaseHandlers,
  companyGetHandler,
  companyUpdateHandler,
  companyHistoryListHandler,
  hosPolicyGetHandler,
  hosPolicyPublishHandler,
  notificationSettingsListHandler,
  notificationSettingsUpdateHandler,
  supportTicketsListHandler,
  supportTicketDetailHandler,
  supportTicketMessagesHandler,
  supportTicketMessageCreateHandler,
  supportTicketStatusUpdateHandler,
  feedbackListHandler,
  auditLogListHandler,
  auditLogTablesHandler,
  inspectionLogsHandler,
  inspectionEmailSendHandler,
];
