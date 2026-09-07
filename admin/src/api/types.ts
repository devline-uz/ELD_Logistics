/**
 * Domen tiplari uchun qulay alias'lar.
 *
 * `schema.d.ts` dagi Go paket prefiksli uzun nomlar
 * (`github_com_devline_onebook-eld_internal_domain_fleet_dto.Unit`)
 * komponentlarda **hech qachon** ko'rinmasligi kerak — faqat shu fayl orqali.
 *
 * Manba: `openapi/swagger.json` (Swagger 2.0) → `openapi/openapi3.json` →
 * `src/api/schema.d.ts` (`npm run api`). Nom noto'g'ri yozilsa `Dto<>` helper'i
 * kompilyatsiya xatosi beradi — `unknown`/`any` ga sirg'alib ketmaydi.
 */
import type { components, operations, paths } from './schema';
import type { ApiError } from '@/lib/errors';

export type { components, operations, paths };

/**
 * TanStack Query v5 `Register` kengaytmasi — `useQuery`/`useMutation`ning
 * standart xato tipini `ApiError` qiladi (2.1). Shu bilan `api/queries/**`
 * dagi har bir hook `error`ni alohida generic bermasdan `ApiError` sifatida
 * oladi (`errorMiddleware` har doim `ApiError` otadi — `client.ts`, §6).
 */
declare module '@tanstack/react-query' {
  interface Register {
    defaultError: ApiError;
  }
}

type Schemas = components['schemas'];
type SchemaName = keyof Schemas;

/** Barcha domen DTO'larining Go paket prefiksi. */
type DomainPrefix = 'github_com_devline_onebook-eld_internal_domain_';

/** Berilgan domenda mavjud DTO nomlari (`Unit`, `Driver`, …). */
type DtoNames<D extends string> =
  Extract<
    SchemaName,
    `${DomainPrefix}${D}_dto.${string}`
  > extends `${DomainPrefix}${D}_dto.${infer T}`
    ? T
    : never;

/**
 * Domen DTO tipi. `D` yoki `T` spec'da bo'lmasa — TypeScript xatosi
 * (`DtoNames<D>` bo'sh bo'lib qoladi), shuning uchun typo jim o'tmaydi.
 */
type Dto<D extends string, T extends DtoNames<D>> = Schemas[Extract<
  SchemaName,
  `${DomainPrefix}${D}_dto.${T}`
>];

/** `internal/httpx/dto` paketidagi umumiy tiplar (xato konverti). */
type Httpx<T extends string> = Schemas[Extract<
  SchemaName,
  `github_com_devline_onebook-eld_internal_httpx_dto.${T}`
>];

/* ------------------------------------------------------------------ *
 * Umumiy primitive'lar
 * ------------------------------------------------------------------ */

/** RFC3339 sana-vaqt (`format: date-time`). Spec'da oddiy `string`. */
export type IsoDateTime = string;
/** `YYYY-MM-DD` (`format: date`). Spec'da oddiy `string`. */
export type IsoDate = string;
/** UUID v4 identifikator. Spec'da oddiy `string`. */
export type Uuid = string;

/* ------------------------------------------------------------------ *
 * Xato konverti — `{"error":{"code","message","details"}}`
 * ------------------------------------------------------------------ */

/** Xato tanasi: `code`, `message`, `details[]`. */
export type ErrorBody = Httpx<'ErrorBody'>;
/** `details[]` elementi: `{field, message}`. */
export type FieldError = Httpx<'FieldError'>;
/** To'liq xato javobi. */
export interface ErrorResponse {
  error?: ErrorBody;
}
/** `{"message": "..."}` — o'chirish/amal javoblari. */
export type MessageResponse = Httpx<'MessageResponse'>;

/* ------------------------------------------------------------------ *
 * Ro'yxat konvertlari
 * ------------------------------------------------------------------ */

/**
 * Ro'yxat javobidagi `meta` bloki: `{ page, per_page, total }`.
 * Har domenda o'z `Meta` DTO'si bor, ammo shakli bir xil — `auth_dto.Meta`
 * kanonik nusxa sifatida ishlatiladi.
 */
export type ListMeta = Dto<'auth', 'Meta'>;

/** Bildirishnomalar `meta` si — `{ page, per_page, total, unread }`. */
export type NotificationListMeta = Dto<'notifications', 'ListMeta'>;

/** Chat xabarlari kursorli `meta` si — `{ has_more, next_before, per_page, unread }`. */
export type CursorMeta = Dto<'chat', 'CursorMeta'>;

/**
 * Ro'yxat javobi konverti.
 *
 * ⚠️ `data`/`meta` **ixtiyoriy** — swaggo DTO'larida `required` yo'q, shuning
 * uchun generatsiya qilingan `*ListEnvelope` tiplarida ham ular `?` bilan
 * keladi. Shakl aynan mos kelsin uchun bu yerda ham ixtiyoriy qoldirilgan
 * (F1: swagger ustun).
 */
export interface ListResponse<T> {
  data?: T[];
  meta?: ListMeta;
}

/** Yagona obyekt javobi konverti: `{ data }`. */
export interface ItemResponse<T> {
  data?: T;
}

/**
 * Ruxsat etilgan sahifa hajmlari. Boshqa qiymat backendda **422** beradi,
 * shuning uchun tip darajasida cheklangan (spec'da `per_page` oddiy `integer`,
 * `enum` yo'q — cheklov faqat tavsifda: «Rows per page (10/25/50)»).
 */
export type PerPage = 10 | 25 | 50;

/** `PerPage` ning ish vaqtidagi ro'yxati (Select uchun). */
export const PER_PAGE_OPTIONS = [10, 25, 50] as const satisfies readonly PerPage[];

/** Standart sahifa hajmi. */
export const DEFAULT_PER_PAGE: PerPage = 25;

/** Saralash yo'nalishi. */
export type SortOrder = 'asc' | 'desc';

/** Barcha ro'yxat ekranlari uchun umumiy query parametrlari. */
export interface ListParams {
  page?: number;
  per_page?: PerPage;
  sort?: string;
  order?: SortOrder;
  search?: string;
}

/** Kursorli ro'yxatlar (chat) uchun parametrlar. */
export interface CursorParams {
  before?: IsoDateTime;
  limit?: number;
}

/* ------------------------------------------------------------------ *
 * Auth / sessiya
 * ------------------------------------------------------------------ */

export type LoginRequest = Dto<'auth', 'LoginRequest'>;
export type LoginResult = Dto<'auth', 'LoginResult'>;
export type Tokens = Dto<'auth', 'Tokens'>;
export type RefreshRequest = Dto<'auth', 'RefreshRequest'>;
export type LogoutRequest = Dto<'auth', 'LogoutRequest'>;
export type SessionInfo = Dto<'auth', 'Session'>;
export type Profile = Dto<'auth', 'Profile'>;
export type AppConfig = Dto<'auth', 'AppConfig'>;
export type TotpSetup = Dto<'auth', 'TOTPSetup'>;
export type TotpVerifyRequest = Dto<'auth', 'TOTPVerifyRequest'>;
export type TotpVerified = Dto<'auth', 'TOTPVerified'>;
export type PinVerifyRequest = Dto<'auth', 'PINVerifyRequest'>;
export type PinVerified = Dto<'auth', 'PINVerified'>;
export type InvitationAcceptRequest = Dto<'auth', 'InvitationAcceptRequest'>;
export type PasswordForgotRequest = Dto<'auth', 'PasswordForgotRequest'>;
export type PasswordResetRequest = Dto<'auth', 'PasswordResetRequest'>;

/* ------------------------------------------------------------------ *
 * Foydalanuvchilar, rollar, ruxsatlar
 * ------------------------------------------------------------------ */

export type User = Dto<'users', 'User'>;
export type UserCreate = Dto<'users', 'UserCreate'>;
export type UserUpdate = Dto<'users', 'UserUpdate'>;
export type UserRole = Dto<'users', 'UserRole'>;
export type InvitationSent = Dto<'users', 'InvitationSent'>;
export type Role = Dto<'users', 'Role'>;
export type RoleCreate = Dto<'users', 'RoleCreate'>;
export type RoleUpdate = Dto<'users', 'RoleUpdate'>;
export type Permission = Dto<'users', 'Permission'>;
export type PermissionModule = Dto<'users', 'PermissionModule'>;

/* ------------------------------------------------------------------ *
 * Kompaniya, filial, sozlamalar
 * ------------------------------------------------------------------ */

/** Joriy tenant kompaniyasi (Settings › Company). */
export type Company = Dto<'company', 'Company'>;
export type CompanyUpdate = Dto<'company', 'CompanyUpdate'>;
export type CompanySettings = Dto<'company', 'Settings'>;
export type CompanyHistoryEntry = Dto<'company', 'HistoryEntry'>;
export type WarningThresholds = Dto<'company', 'WarningThresholds'>;

/** Platforma (super admin) ko'rinishidagi kompaniya. */
export type AdminCompany = Dto<'companies', 'Company'>;
export type AdminCompanyCreate = Dto<'companies', 'CompanyCreate'>;
export type AdminCompanyUpdate = Dto<'companies', 'CompanyUpdate'>;
export type AdminCompanyCreated = Dto<'companies', 'CompanyCreated'>;
export type AdministratorInvite = Dto<'companies', 'AdministratorInvite'>;
export type SubscriptionUpdate = Dto<'companies', 'SubscriptionUpdate'>;

export type Branch = Dto<'company', 'Branch'>;
export type BranchCreate = Dto<'company', 'BranchCreate'>;
export type BranchUpdate = Dto<'company', 'BranchUpdate'>;

export type HosPolicy = Dto<'company', 'HosPolicy'>;
export type HosPolicyCreate = Dto<'company', 'HosPolicyCreate'>;
export type HosPolicyDoc = Dto<'company', 'HosPolicyDoc'>;

export type NotificationSetting = Dto<'company', 'NotificationSetting'>;
export type NotificationSettingUpdate = Dto<'company', 'NotificationSettingUpdate'>;
export type NotificationSettingsUpdate = Dto<'company', 'NotificationSettingsUpdate'>;

/* ------------------------------------------------------------------ *
 * Park: unit, tirkama, ELD qurilma, yuk hujjati
 * ------------------------------------------------------------------ */

export type Unit = Dto<'fleet', 'Unit'>;
export type UnitCreate = Dto<'fleet', 'UnitCreate'>;
export type UnitUpdate = Dto<'fleet', 'UnitUpdate'>;
export type UnitAssignment = Dto<'fleet', 'UnitAssignment'>;
export type UnitAssignDriver = Dto<'fleet', 'UnitAssignDriver'>;
export type UnitDiagnostics = Dto<'fleet', 'UnitDiagnostics'>;
export type UnitTelemetry = Dto<'fleet', 'UnitTelemetry'>;
export type UnitHistoryEntry = Dto<'fleet', 'UnitHistoryEntry'>;
export type MalfunctionCode = Dto<'fleet', 'MalfunctionCode'>;

export type Trailer = Dto<'fleet', 'Trailer'>;
export type EldDevice = Dto<'fleet', 'EldDevice'>;
export type EldDeviceCreate = Dto<'fleet', 'EldDeviceCreate'>;
export type EldDeviceUpdate = Dto<'fleet', 'EldDeviceUpdate'>;
export type EldDeviceAssignUnit = Dto<'fleet', 'EldDeviceAssignUnit'>;
export type ShippingDocument = Dto<'fleet', 'ShippingDocument'>;
export type CatalogCreate = Dto<'fleet', 'CatalogCreate'>;
export type CatalogUpdate = Dto<'fleet', 'CatalogUpdate'>;

/* ------------------------------------------------------------------ *
 * Haydovchilar
 * ------------------------------------------------------------------ */

export type Driver = Dto<'drivers', 'Driver'>;
export type DriverCreate = Dto<'drivers', 'DriverCreate'>;
export type DriverUpdate = Dto<'drivers', 'DriverUpdate'>;
export type DriverLicense = Dto<'drivers', 'DriverLicense'>;
export type DriverActivity = Dto<'drivers', 'Activity'>;
export type DriverStatusChange = Dto<'drivers', 'StatusChange'>;
export type CoDriver = Dto<'drivers', 'CoDriver'>;
export type CoDriverCreate = Dto<'drivers', 'CoDriverCreate'>;
export type DriverResetPasswordResult = Dto<'drivers', 'ResetPasswordResult'>;

/* ------------------------------------------------------------------ *
 * Kunlik loglar, hodisalar, tahrir so'rovlari, buzilishlar
 * ------------------------------------------------------------------ */

export type DailyLogSummary = Dto<'logs', 'DailyLogSummary'>;
export type DailyLogDetail = Dto<'logs', 'DailyLogDetail'>;
export type DayTotals = Dto<'logs', 'DayTotals'>;
export type LogForm = Dto<'logs', 'LogForm'>;
export type LogEvent = Dto<'logs', 'LogEvent'>;
export type LogEventCreate = Dto<'logs', 'LogEventCreate'>;
export type LogEditRequest = Dto<'logs', 'LogEditRequest'>;
export type LogEditRequestCreate = Dto<'logs', 'LogEditRequestCreate'>;
export type LogEditChange = Dto<'logs', 'LogEditChange'>;
export type LogEditReject = Dto<'logs', 'LogEditReject'>;
export type UncertifiedLog = Dto<'logs', 'UncertifiedLog'>;
export type CertifyRequest = Dto<'logs', 'CertifyRequest'>;
export type UnidentifiedEvent = Dto<'logs', 'UnidentifiedEvent'>;
export type UnidentifiedAssign = Dto<'logs', 'UnidentifiedAssign'>;
export type UnidentifiedAnnotate = Dto<'logs', 'UnidentifiedAnnotate'>;
export type Violation = Dto<'logs', 'Violation'>;
export type ViolationDetails = Dto<'logs', 'ViolationDetails'>;

export type InspectionSession = Dto<'logs', 'InspectionSession'>;
export type InspectionReport = Dto<'logs', 'InspectionReport'>;
export type InspectionTransfer = Dto<'logs', 'InspectionTransfer'>;
export type InspectionEmail = Dto<'logs', 'InspectionEmail'>;

/* ------------------------------------------------------------------ *
 * HOS (duty)
 * ------------------------------------------------------------------ */

export type HosSummary = Dto<'duty', 'HosSummary'>;
export type HosCounters = Dto<'duty', 'Counters'>;
export type HosRecapDay = Dto<'duty', 'RecapDay'>;
export type HosDayTotals = Dto<'duty', 'DayTotals'>;
export type DutyStatusEvent = Dto<'duty', 'DutyStatusEvent'>;
export type DutyViolation = Dto<'duty', 'Violation'>;

/* ------------------------------------------------------------------ *
 * DVIR
 * ------------------------------------------------------------------ */

export type DvirReport = Dto<'dvir', 'DvirReport'>;
export type DvirCreate = Dto<'dvir', 'DvirCreate'>;
export type DvirCertify = Dto<'dvir', 'DvirCertify'>;
export type DvirRepair = Dto<'dvir', 'DvirRepair'>;
export type DvirDefect = Dto<'dvir', 'Defect'>;
export type DvirDefectInput = Dto<'dvir', 'DefectInput'>;
export type DefectType = Dto<'dvir', 'DefectType'>;
export type DefectTypeCreate = Dto<'dvir', 'DefectTypeCreate'>;
export type DefectTypeUpdate = Dto<'dvir', 'DefectTypeUpdate'>;

/* ------------------------------------------------------------------ *
 * Texnik xizmat
 * ------------------------------------------------------------------ */

export type MaintenanceRecord = Dto<'maintenance', 'Record'>;
export type MaintenanceSchedule = Dto<'maintenance', 'Schedule'>;
export type MaintenanceScheduleCreate = Dto<'maintenance', 'ScheduleCreate'>;
export type MaintenanceScheduleUpdate = Dto<'maintenance', 'ScheduleUpdate'>;
export type MaintenanceScheduleUnit = Dto<'maintenance', 'ScheduleUnit'>;
export type MaintenanceScheduleUnitInput = Dto<'maintenance', 'ScheduleUnitInput'>;
export type MaintenanceComplete = Dto<'maintenance', 'CompleteInput'>;
export type MaintenanceCancel = Dto<'maintenance', 'CancelInput'>;

/* ------------------------------------------------------------------ *
 * Tracking va reyslar
 * ------------------------------------------------------------------ */

export type LiveUnit = Dto<'tracking', 'LiveUnit'>;
export type TrackingDriverBrief = Dto<'tracking', 'DriverBrief'>;
export type Trip = Dto<'tracking', 'Trip'>;
export type TripDetail = Dto<'tracking', 'TripDetail'>;
export type TrackingUnidentifiedEvent = Dto<'tracking', 'UnidentifiedEvent'>;

/* ------------------------------------------------------------------ *
 * Marshrutlar
 * ------------------------------------------------------------------ */

export type Route = Dto<'routes', 'Route'>;
export type RouteCreate = Dto<'routes', 'RouteCreate'>;
export type RouteUpdate = Dto<'routes', 'RouteUpdate'>;
export type RouteNotCompleted = Dto<'routes', 'RouteNotCompleted'>;
export type Waypoint = Dto<'routes', 'Waypoint'>;
export type WaypointInput = Dto<'routes', 'WaypointInput'>;
export type Directions = Dto<'routes', 'Directions'>;

/* ------------------------------------------------------------------ *
 * Hisobotlar va eksport
 * ------------------------------------------------------------------ */

export type ActivityRow = Dto<'reports', 'ActivityRow'>;
export type RegionDistanceRow = Dto<'reports', 'RegionDistanceRow'>;
export type DistanceByRegionMeta = Dto<'reports', 'DistanceByRegionMeta'>;
export type ExportJob = Dto<'reports', 'ExportJob'>;
export type ExportJobCreate = Dto<'reports', 'ExportJobCreate'>;
export type ExportParams = Dto<'reports', 'ExportParams'>;

/* ------------------------------------------------------------------ *
 * Dashboard
 * ------------------------------------------------------------------ */

export type DashboardSummary = Dto<'dashboard', 'Summary'>;
export type DashboardKpi = Dto<'dashboard', 'KPI'>;
export type DashboardStatusBlock = Dto<'dashboard', 'StatusBlock'>;
export type DashboardRoute = Dto<'dashboard', 'Route'>;
export type DashboardWindow = Dto<'dashboard', 'Window'>;

/* ------------------------------------------------------------------ *
 * Chat
 * ------------------------------------------------------------------ */

export type ChatThread = Dto<'chat', 'Thread'>;
export type ChatMessage = Dto<'chat', 'Message'>;
export type ChatMessageCreate = Dto<'chat', 'MessageCreate'>;
export type ChatReadResult = Dto<'chat', 'ReadResult'>;

/* ------------------------------------------------------------------ *
 * Bildirishnomalar
 * ------------------------------------------------------------------ */

export type Notification = Dto<'notifications', 'Notification'>;
export type NotificationReadResult = Dto<'notifications', 'ReadResult'>;
export type PushToken = Dto<'notifications', 'PushToken'>;
export type PushTokenCreate = Dto<'notifications', 'PushTokenCreate'>;

/* ------------------------------------------------------------------ *
 * Qo'llab-quvvatlash
 * ------------------------------------------------------------------ */

export type SupportTicket = Dto<'support', 'Ticket'>;
export type SupportTicketCreate = Dto<'support', 'TicketCreate'>;
export type SupportTicketStatusUpdate = Dto<'support', 'TicketStatusUpdate'>;
export type SupportTicketMessage = Dto<'support', 'TicketMessage'>;
export type SupportTicketMessageCreate = Dto<'support', 'TicketMessageCreate'>;
export type Feedback = Dto<'support', 'Feedback'>;
export type FeedbackCreate = Dto<'support', 'FeedbackCreate'>;

/* ------------------------------------------------------------------ *
 * Audit log
 * ------------------------------------------------------------------ */

export type AuditLogEntry = Dto<'auditlog', 'Entry'>;

/* ------------------------------------------------------------------ *
 * Fayllar (presign, import)
 * ------------------------------------------------------------------ */

export type PresignRequest = Dto<'files', 'PresignRequest'>;
export type PresignResponse = Dto<'files', 'PresignResponse'>;
export type ImportResult = Dto<'files', 'ImportResult'>;
export type ImportRowError = Dto<'files', 'ImportRowError'>;

/* ------------------------------------------------------------------ *
 * Ro'yxat/eksport so'rov parametrlari — `paths` dan (2.1).
 *
 * Bular DTO emas, query-string shakllari, shuning uchun `Dto<>` orqali
 * emas — bevosita generatsiya qilingan `paths` tipidan olinadi. `openapi`
 * yangilansa (`npm run api`) va bu yo'l o'zgarsa — TypeScript shu yerda
 * xato beradi (`paths['/units']` `never` ga sirg'alib ketmaydi).
 * ------------------------------------------------------------------ */

export type UnitsListParams = NonNullable<paths['/units']['get']['parameters']['query']>;
export type UnitHistoryParams = NonNullable<
  paths['/units/{id}/history']['get']['parameters']['query']
>;
export type UnitsExportParams = NonNullable<paths['/units/export']['get']['parameters']['query']>;
export type UnitsImportTemplateParams = NonNullable<
  paths['/units/import-template']['get']['parameters']['query']
>;

export type DriversListParams = NonNullable<paths['/drivers']['get']['parameters']['query']>;
export type DriversExportParams = NonNullable<
  paths['/drivers/export']['get']['parameters']['query']
>;
export type DriversImportTemplateParams = NonNullable<
  paths['/drivers/import-template']['get']['parameters']['query']
>;

export type EldDevicesListParams = NonNullable<paths['/eld-devices']['get']['parameters']['query']>;

export type TrailersListParams = NonNullable<paths['/trailers']['get']['parameters']['query']>;

export type ShippingDocumentsListParams = NonNullable<
  paths['/shipping-documents']['get']['parameters']['query']
>;

export type UsersListParams = NonNullable<paths['/users']['get']['parameters']['query']>;

export type RolesListParams = NonNullable<paths['/roles']['get']['parameters']['query']>;

/**
 * `GET /company/branches` — `scope=company` administratori uchun filial
 * tanlovi (Unit/Driver/User Add/Edit formalari va ro'yxat filtrlari,
 * `docs/tz/07-3-fleet.md` §7.3.1/§7.3.4/§7.3.9, bosqich 2 ko'rigi B1).
 */
export type BranchesListParams = NonNullable<
  paths['/company/branches']['get']['parameters']['query']
>;

/** `GET /drivers/{id}/daily-logs` — Logs By Driver oynasi (3.1). */
export type DriverDailyLogsParams = NonNullable<
  paths['/drivers/{id}/daily-logs']['get']['parameters']['query']
>;

/** `GET /drivers/{id}/hos-summary` — `date` (YYYY-MM-DD), default bugun. */
export type HosSummaryParams = NonNullable<
  paths['/drivers/{id}/hos-summary']['get']['parameters']['query']
>;

/** `GET /log-edit-requests` — `status`/`driver_id` filtri + pagination. */
export type LogEditRequestsListParams = NonNullable<
  paths['/log-edit-requests']['get']['parameters']['query']
>;

/** `GET /tracking/live` — Logs By Unit asosiy manbai (F95). */
export type TrackingLiveParams = NonNullable<paths['/tracking/live']['get']['parameters']['query']>;

/** `GET /unidentified-events` — Unassigned Driving ro'yxati. */
export type UnidentifiedEventsListParams = NonNullable<
  paths['/unidentified-events']['get']['parameters']['query']
>;

/** `GET /violations` — 10 turdagi filtr + `severity`/`resolved`/sana oralig'i. */
export type ViolationsListParams = NonNullable<paths['/violations']['get']['parameters']['query']>;
