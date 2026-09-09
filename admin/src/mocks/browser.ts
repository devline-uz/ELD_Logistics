/**
 * MSW browser worker — dev server uchun (9.1, `VITE_ENABLE_MSW=1`).
 *
 * `src/main.tsx` bu modulni **faqat** `import.meta.env.DEV &&
 * VITE_ENABLE_MSW === '1'` bo'lganda dinamik import qiladi — prod bundle'ga
 * tushmaydi (F206, bundle byudjeti buzilmaydi).
 *
 * Playwright e2e shu worker ustida ishlaydi (`playwright.config.ts`
 * `webServer` bloki `VITE_API_BASE_URL=http://eldapi.test/api/v1` bilan dev
 * serverni ko'taradi — bu baza `mocks/handlers/shared.ts`dagi `url()` bilan
 * bitta manba, shuning uchun ilova so'rovlari va bu yerdagi handler'lar bir
 * xil yo'lga tushadi).
 *
 * Auth/company/daily-log uchun handler'lar **shu faylda** yozilgan (modul
 * fayllariga tegilmaydi, W2): login/refresh/logout/`/me` uchta rolni (admin ·
 * manager · restricted) qo'llab-quvvatlaydi (3-bosqich F87 ikki holati va
 * 8-bosqich cheklangan rol ssenariysi uchun), `/company` holatli GET/PATCH
 * (9.8 — metric/imperial, generic/us_fmcsa konvertatsiya oqimi), bitta
 * `/daily-logs/:id` tahrirlanadigan voqealar bilan (4-oqim — "Send edit
 * request").
 */
import { http, HttpResponse } from 'msw';
import { setupWorker } from 'msw/browser';

import type { Company, LoginResult, Profile, Tokens } from '@/api/types';
import { ALL_PERMISSIONS, PERM } from '@/lib/permissions';

import { auditLogListHandler, auditLogTablesHandler } from './handlers/audit';
import {
  branchCreateHandler,
  branchDeleteHandler,
  branchesListHandler,
  branchUpdateHandler,
} from './handlers/branches';
import { chatBaseHandlers } from './handlers/chat';
import { companyFixture } from './handlers/company';
import { dashboardBaseHandlers } from './handlers/dashboard';
import { E2E_CREDENTIALS, type E2eRole } from './e2e-credentials';
import {
  driverActivateHandler,
  driverCoDriversHandler,
  driverDeactivateHandler,
  driverLicenseRevealHandler,
  driversBaseHandlers,
} from './handlers/drivers';
import { dvirBaseHandlers } from './handlers/dvir';
import { eldDevicesBaseHandlers } from './handlers/eldDevices';
import { feedbackListHandler } from './handlers/feedback';
import { filesPresignHandler } from './handlers/files';
import { hosSummaryHandler } from './handlers/hos';
import { hosPolicyGetHandler, hosPolicyPublishHandler } from './handlers/hosPolicy';
import { inspectionEmailSendHandler, inspectionLogsHandler } from './handlers/inspection';
import {
  logEditRequestApproveHandler,
  logEditRequestProposeHandler,
  logEditRequestRejectHandler,
  logEditRequestsListHandler,
} from './handlers/logEditRequests';
import { dailyLogDetailFixture, driverDailyLogsHandler } from './handlers/logs';
import {
  maintenanceBaseHandlers,
  maintenanceCancelHandler,
  maintenanceCompleteHandler,
  maintenanceScheduleUnitFixture,
} from './handlers/maintenance';
import {
  notificationSettingsListHandler,
  notificationSettingsUpdateHandler,
} from './handlers/notificationSettings';
import { notificationsBaseHandlers } from './handlers/notifications';
import { permissionsBaseHandlers } from './handlers/permissions';
import {
  exportJobCreateHandler,
  exportJobFixture,
  exportJobsListHandler,
  reportsActivityHandler,
  reportsDistanceByRegionHandler,
  reportsUncertifiedLogsHandler,
} from './handlers/reports';
import { rolesBaseHandlers } from './handlers/roles';
import { shippingDocumentsBaseHandlers } from './handlers/shippingDocuments';
import { jsonError, listMeta, url } from './handlers/shared';
import {
  supportTicketDetailHandler,
  supportTicketMessageCreateHandler,
  supportTicketMessagesHandler,
  supportTicketsListHandler,
  supportTicketStatusUpdateHandler,
} from './handlers/support';
import { trackingLiveHandler, tripGetHandler, unitTripsHandler } from './handlers/tracking';
import { trailersBaseHandlers } from './handlers/trailers';
import {
  unitActivateHandler,
  unitDeactivateHandler,
  unitDiagnosticsHandler,
  unitHistoryHandler,
  unitsBaseHandlers,
} from './handlers/units';
import { usersBaseHandlers } from './handlers/users';
import { violationsListHandler } from './handlers/violations';

/* ------------------------------------------------------------------ *
 * Auth — 3 rol (9.1 oqim 1/3/8, 9.8): admin · manager · restricted.
 * Token'lar rolga qarab nomlanadi (`access-token-<role>`), `/me` va
 * `/auth/refresh` `Authorization`/`refresh_token` ichidagi rol nomini
 * o'qib mos profilni qaytaradi — haqiqiy rotation shart emas (mock).
 * ------------------------------------------------------------------ */

function roleOf(token: string | null | undefined): E2eRole {
  if (!token) return 'admin';
  if (token.includes('manager')) return 'manager';
  if (token.includes('restricted')) return 'restricted';
  return 'admin';
}

function permissionsFor(role: E2eRole): Profile['permissions'] {
  if (role === 'restricted') return [PERM.dashboardRead];
  if (role === 'manager') return ALL_PERMISSIONS.filter((p) => p !== PERM.driversLicenseView);
  return [...ALL_PERMISSIONS];
}

function profileFor(role: E2eRole): Profile {
  const names: Record<E2eRole, { first: string; last: string; roleName: string }> = {
    admin: { first: 'Jane', last: 'Admin', roleName: 'Fleet Manager' },
    manager: { first: 'Sam', last: 'Manager', roleName: 'Fleet Manager (No License View)' },
    restricted: { first: 'Riley', last: 'Viewer', roleName: 'Viewer' },
  };
  const { first, last, roleName } = names[role];
  return {
    id: `user-${role}`,
    company_id: 'company-1',
    username: E2E_CREDENTIALS[role].username,
    first_name: first,
    last_name: last,
    email: `${E2E_CREDENTIALS[role].username}@example.com`,
    role_id: `role-${role}`,
    role_name: roleName,
    scope: 'company',
    status: 'active',
    totp_enabled: false,
    permissions: permissionsFor(role),
    is_super_admin: false,
  };
}

function tokensFor(role: E2eRole): Tokens {
  return {
    access_token: `access-token-${role}`,
    expires_in: 900,
    refresh_token: `refresh-token-${role}`,
    refresh_expires_at: '2030-01-01T00:00:00Z',
    token_type: 'Bearer',
  };
}

function loginResultFor(role: E2eRole): LoginResult {
  return {
    ...tokensFor(role),
    session_id: `session-${role}`,
    requires_totp_setup: false,
    replaced_session: false,
    subscription_readonly: false,
  };
}

const appConfigHandler = http.get(url('/app/config'), () =>
  HttpResponse.json({
    data: {
      server_time: new Date().toISOString(),
      feature_flags: {},
      access_token_ttl_seconds: 900,
      support_email: 'support@example.com',
    },
  }),
);

const loginHandler = http.post(url('/auth/login'), async ({ request }) => {
  const body = (await request.json()) as { username?: string; password?: string };
  const match = (Object.keys(E2E_CREDENTIALS) as E2eRole[]).find(
    (role) =>
      E2E_CREDENTIALS[role].username === body.username &&
      E2E_CREDENTIALS[role].password === body.password,
  );
  if (!match) return jsonError('UNAUTHORIZED', 'Invalid credentials', 401);
  return HttpResponse.json({ data: loginResultFor(match) });
});

const refreshHandler = http.post(url('/auth/refresh'), async ({ request }) => {
  const body = (await request.json()) as { refresh_token?: string };
  return HttpResponse.json({ data: tokensFor(roleOf(body.refresh_token)) });
});

const logoutHandler = http.post(url('/auth/logout'), () => new HttpResponse(null, { status: 204 }));

const meHandler = http.get(url('/me'), ({ request }) => {
  const auth = request.headers.get('authorization');
  return HttpResponse.json({ data: profileFor(roleOf(auth)) });
});

/* ------------------------------------------------------------------ *
 * Company — holatli GET/PATCH (9.8: unit_system/regulation_profile
 * almashinuvi bitta sessiya davomida round-trip bo'lishi kerak).
 *
 * ⚠️ Oddiy modul darajasidagi `let` yetarli emas: MSW handler funksiyalari
 * **sahifa** JS kontekstida ishlaydi (Service Worker faqat umumiy
 * `mockServiceWorker.js` marshrutchisi — haqiqiy handler kodi sahifa
 * bundle'ida yashaydi). `page.goto()` (to'liq qayta yuklash, 9.8 testida
 * `Settings company` → report sahifasiga o'tish) sahifa JS modulini
 * **butunlay qayta ishga tushiradi** — oddiy `let` o'zgaruvchi boshlang'ich
 * qiymatga qaytib qoladi. `sessionStorage` esa bitta tab/kontekst ichida
 * to'liq qayta yuklashdan ham omon qoladi (har Playwright testi — yangi
 * kontekst, shuning uchun testlar orasida sizib o'tish yo'q).
 * ------------------------------------------------------------------ */

const COMPANY_OVERRIDE_KEY = 'e2e.company-override';

function readCompanyOverride(): Partial<Company> {
  try {
    const raw = sessionStorage.getItem(COMPANY_OVERRIDE_KEY);
    return raw ? (JSON.parse(raw) as Partial<Company>) : {};
  } catch {
    return {};
  }
}

function writeCompanyOverride(next: Partial<Company>): void {
  try {
    sessionStorage.setItem(COMPANY_OVERRIDE_KEY, JSON.stringify(next));
  } catch {
    // e'tiborsiz — sessionStorage bloklangan muhitda kompaniya konteksti
    // shunchaki sahifa umri davomida standart qiymatda qoladi.
  }
}

const companyGetHandler = http.get(url('/company'), () =>
  HttpResponse.json({ data: { ...companyFixture(), ...readCompanyOverride() } }),
);

const companyPatchHandler = http.patch(url('/company'), async ({ request }) => {
  const body = (await request.json()) as Partial<Company>;
  const next = { ...companyFixture(), ...readCompanyOverride(), ...body };
  writeCompanyOverride(next);
  return HttpResponse.json({ data: next });
});

/* ------------------------------------------------------------------ *
 * Daily log — tahrirlanadigan (lock'lanmagan) voqealar bilan (4-oqim:
 * Logs By Driver → Log view → "Send edit request"). `logs.ts`dagi
 * standart fixture `locked:true`/`event_type` yo'q bo'lgani uchun
 * "Propose edit" hech qachon ko'rinmaydi — shu sabab qayta yoziladi.
 * ------------------------------------------------------------------ */

const editableDailyLog = dailyLogDetailFixture({
  id: 'daily-log-1',
  driver_id: 'driver-1',
  events: [
    {
      id: 'event-off-1',
      event_type: 'duty_status',
      status: 'OFF',
      special: 'none',
      event_time: '2026-09-06T13:00:00Z',
      origin: 'driver',
      locked: false,
      edited: false,
      unit_id: 'unit-1',
      unit_number: '1021',
    },
    {
      id: 'event-on-1',
      event_type: 'duty_status',
      status: 'ON',
      special: 'none',
      event_time: '2026-09-06T15:00:00Z',
      origin: 'driver',
      locked: false,
      edited: false,
      unit_id: 'unit-1',
      unit_number: '1021',
    },
  ],
});

const dailyLogGetHandler = http.get(url('/daily-logs/:id'), ({ params }) =>
  HttpResponse.json({ data: { ...editableDailyLog, id: params.id as string } }),
);

/* ------------------------------------------------------------------ *
 * Fayl yuklash — invoice `PUT` to'g'ridan-to'g'ri "storage"ga ketadi
 * (6-oqim: Mark as Complete + invoice). `files.ts`dagi presign javobi
 * `https://storage.test/invoice.pdf` manzilini beradi — bu yerda shu
 * manzilga mock `200` javobi, real tarmoqqa chiqish yo'q (F226).
 * ------------------------------------------------------------------ */

const storageUploadHandler = http.put(
  'https://storage.test/invoice.pdf',
  () => new HttpResponse(null, { status: 200 }),
);

/* ------------------------------------------------------------------ *
 * Export job — "done", muddati o'tmagan (7-oqim: Generate → Download).
 * `reports.ts`dagi statik `exportJobDoneHandler` `expires_at`i qattiq
 * yozilgan o'tmish sana (2026-09-07) — joriy sana undan keyin bo'lganda
 * "Link expired" xatosini beradi. Bu yerda `expires_at` doim **hozirdan
 * 1 kun keyin** hisoblanadi.
 * ------------------------------------------------------------------ */

const exportJobDoneHandler = http.get(url('/reports/export-jobs/:id'), ({ params }) =>
  HttpResponse.json({
    data: exportJobFixture({
      id: params.id as string,
      status: 'done',
      started_at: new Date().toISOString(),
      finished_at: new Date().toISOString(),
      download_url: 'https://storage.example.com/onebook/job-1.xlsx',
      expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      file_name: 'distance-by-region-2026-Q3.xlsx',
      file_size_b: 20_480,
    }),
  }),
);

/* ------------------------------------------------------------------ *
 * Maintenance Due — F215 chegaraviy qiymatlar (9.8: 0, manfiy, juda katta
 * odometer). `page.route()` bilan ushlashga urinish ishonchsiz: MSW Service
 * Worker ba'zan poyga holatida ustun chiqadi (SW `fetch` hodisasi CDP
 * Network domeni ko'rishidan OLDIN javob beradi). Shu sabab chegaraviy
 * senariy Playwright darajasida emas, **shu yerda**, `unit_id` filtridagi
 * maxsus marker (`e2e-boundary`) orqali tanlanadi — UI filtr qiymatlari
 * ro'yxatida yo'q, faqat URL query-string orqali (`?unit_id=e2e-boundary`)
 * qo'lda o'rnatiladi va haqiqiy backendda hech qachon uchramaydi.
 * ------------------------------------------------------------------ */

const maintenanceDueHandler = http.get(url('/maintenance/due'), ({ request }) => {
  const unitId = new URL(request.url).searchParams.get('unit_id');
  if (unitId !== 'e2e-boundary') {
    return HttpResponse.json({ data: [maintenanceScheduleUnitFixture()], meta: listMeta() });
  }
  return HttpResponse.json({
    data: [
      maintenanceScheduleUnitFixture({
        id: 'schedule-unit-zero',
        schedule_name: 'Zero remaining',
        remaining: 0,
        overdue: false,
        reminder_due: false,
      }),
      maintenanceScheduleUnitFixture({
        id: 'schedule-unit-negative',
        schedule_name: 'Deep overdue',
        remaining: -500_000,
        overdue: true,
        reminder_due: true,
      }),
      maintenanceScheduleUnitFixture({
        id: 'schedule-unit-huge',
        schedule_name: 'Huge odometer',
        interval_value: 999_999_999,
        remaining: 999_999_999,
        overdue: false,
        reminder_due: false,
      }),
    ],
    meta: listMeta({ total: 3 }),
  });
});

/* ------------------------------------------------------------------ *
 * Handler reestri — barcha domenlar (dev/e2e "muvaffaqiyat" yo'li).
 * ------------------------------------------------------------------ */

export const handlers = [
  appConfigHandler,
  loginHandler,
  refreshHandler,
  logoutHandler,
  meHandler,
  companyGetHandler,
  companyPatchHandler,
  dailyLogGetHandler,
  storageUploadHandler,

  ...dashboardBaseHandlers,
  ...notificationsBaseHandlers,
  ...chatBaseHandlers,
  ...unitsBaseHandlers,
  unitHistoryHandler,
  unitDiagnosticsHandler,
  unitActivateHandler,
  unitDeactivateHandler,
  ...driversBaseHandlers,
  driverLicenseRevealHandler,
  driverActivateHandler,
  driverDeactivateHandler,
  driverCoDriversHandler,
  ...eldDevicesBaseHandlers,
  ...trailersBaseHandlers,
  ...shippingDocumentsBaseHandlers,
  ...usersBaseHandlers,
  ...rolesBaseHandlers,
  ...dvirBaseHandlers,
  maintenanceDueHandler,
  ...maintenanceBaseHandlers,
  maintenanceCompleteHandler,
  maintenanceCancelHandler,
  driverDailyLogsHandler,
  logEditRequestsListHandler,
  logEditRequestProposeHandler,
  logEditRequestApproveHandler,
  logEditRequestRejectHandler,
  trackingLiveHandler,
  unitTripsHandler,
  tripGetHandler,
  hosSummaryHandler,
  violationsListHandler,
  reportsActivityHandler,
  reportsDistanceByRegionHandler,
  reportsUncertifiedLogsHandler,
  exportJobsListHandler,
  exportJobCreateHandler,
  exportJobDoneHandler,
  ...permissionsBaseHandlers,
  branchesListHandler,
  branchCreateHandler,
  branchUpdateHandler,
  branchDeleteHandler,
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
  filesPresignHandler,
];

export const worker = setupWorker(...handlers);
