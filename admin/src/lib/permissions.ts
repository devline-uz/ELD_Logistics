/**
 * Permission kalitlari, `usePermission()` va ruxsat kontekstining yagona manbai.
 *
 * Manba: `admin/openapi/swagger.json` dagi `x-permission` maydonlari, hujjat
 * ko'rinishi — `docs/api/permissions.md` (28 guruh, **104 kalit**).
 * Qayta yaratish: `npm run api` (swagger yangilanadi) → `docs/api/permissions.md`
 * qayta generatsiya qilinadi; `src/lib/permissions.catalog.test.ts` esa CI da
 * swagger va bu fayl orasidagi driftni ikki tomonlama tekshiradi.
 *
 * Uchta `x-permission` qiymati permission EMAS va bu yerda yo'q:
 * - `public` (6 operatsiya) — auth talab qilmaydi (login, parol tiklash, invitation);
 * - `authenticated` (7) — har qanday tizimga kirgan foydalanuvchi, kalit tekshirilmaydi;
 * - `super_admin` (4) — alohida bayroq, rol emas (F33); faqat `/companies*`,
 *   `PermissionState.isSuperAdmin` orqali tekshiriladi.
 *
 * Qoida (fe-permissions §1): kod hech qachon xom satr yozmaydi — faqat `PERM.*`.
 */

import { createContext, useContext, useMemo } from 'react';

/** Modul guruhi (28 ta) — Roles ekranidagi checkbox guruhlash uchun ham ishlatiladi. */
export const PERMISSION_GROUPS = [
  'audit',
  'branches',
  'chat',
  'company',
  'dashboard',
  'defect_types',
  'drivers',
  'dvir',
  'eld_devices',
  'feedback',
  'files',
  'hos_policy',
  'inspection',
  'logs',
  'maintenance',
  'notification_settings',
  'notifications',
  'permissions',
  'reports',
  'roles',
  'routes',
  'shipping_documents',
  'support',
  'tracking',
  'trailers',
  'units',
  'users',
  'violations',
] as const;

export type PermissionGroup = (typeof PERMISSION_GROUPS)[number];

/**
 * Permission kalitlari konstantasi (typo kompilyatsiya vaqtida topiladi).
 * Guruhlar tartibi `PERMISSION_GROUPS` bilan bir xil (alifbo tartibida).
 */
export const PERM = {
  // audit
  auditView: 'audit.view',

  // branches
  branchesCreate: 'branches.create',
  branchesDelete: 'branches.delete',
  branchesRead: 'branches.read',
  branchesUpdate: 'branches.update',

  // chat
  chatRead: 'chat.read',
  chatSend: 'chat.send',

  // company
  companyHistoryView: 'company.history.view',
  companyRead: 'company.read',
  companyUpdate: 'company.update',

  // dashboard
  dashboardRead: 'dashboard.read',

  // defect_types
  defectTypesCreate: 'defect_types.create',
  defectTypesRead: 'defect_types.read',
  defectTypesUpdate: 'defect_types.update',

  // drivers
  driversActivate: 'drivers.activate',
  driversCreate: 'drivers.create',
  driversDeactivate: 'drivers.deactivate',
  driversDelete: 'drivers.delete',
  driversExport: 'drivers.export',
  driversImport: 'drivers.import',
  driversLicenseView: 'drivers.license.view',
  driversManageCoDrivers: 'drivers.manage_co_drivers',
  driversRead: 'drivers.read',
  driversResetPassword: 'drivers.reset_password',
  driversUpdate: 'drivers.update',

  // dvir
  dvirCertify: 'dvir.certify',
  dvirCreate: 'dvir.create',
  dvirExport: 'dvir.export',
  dvirRead: 'dvir.read',
  dvirRepair: 'dvir.repair',

  // eld_devices
  eldDevicesAssignUnit: 'eld_devices.assign_unit',
  eldDevicesCreate: 'eld_devices.create',
  eldDevicesDelete: 'eld_devices.delete',
  eldDevicesRead: 'eld_devices.read',
  eldDevicesUpdate: 'eld_devices.update',

  // feedback
  feedbackCreate: 'feedback.create',
  feedbackRead: 'feedback.read',

  // files
  filesUpload: 'files.upload',

  // hos_policy
  hosPolicyRead: 'hos_policy.read',
  hosPolicyUpdate: 'hos_policy.update',

  // inspection
  inspectionEmail: 'inspection.email',
  inspectionTransfer: 'inspection.transfer',
  inspectionView: 'inspection.view',

  // logs
  logsAddEvent: 'logs.add_event',
  logsAnnotateUnidentified: 'logs.annotate_unidentified',
  logsApproveEdit: 'logs.approve_edit',
  logsAssignUnidentified: 'logs.assign_unidentified',
  logsCertify: 'logs.certify',
  logsClaimUnidentified: 'logs.claim_unidentified',
  logsExport: 'logs.export',
  logsProposeEdit: 'logs.propose_edit',
  logsRead: 'logs.read',
  logsRejectEdit: 'logs.reject_edit',

  // maintenance
  maintenanceCancel: 'maintenance.cancel',
  maintenanceComplete: 'maintenance.complete',
  maintenanceCreate: 'maintenance.create',
  maintenanceDelete: 'maintenance.delete',
  maintenanceRead: 'maintenance.read',
  maintenanceUpdate: 'maintenance.update',

  // notification_settings
  notificationSettingsRead: 'notification_settings.read',
  notificationSettingsUpdate: 'notification_settings.update',

  // notifications
  notificationsRead: 'notifications.read',

  // permissions
  permissionsRead: 'permissions.read',

  // reports
  reportsExport: 'reports.export',
  reportsRead: 'reports.read',

  // roles
  rolesCreate: 'roles.create',
  rolesDelete: 'roles.delete',
  rolesRead: 'roles.read',
  rolesUpdate: 'roles.update',

  // routes
  routesComplete: 'routes.complete',
  routesCreate: 'routes.create',
  routesDelete: 'routes.delete',
  routesRead: 'routes.read',
  routesUpdate: 'routes.update',

  // shipping_documents
  shippingDocumentsCreate: 'shipping_documents.create',
  shippingDocumentsDelete: 'shipping_documents.delete',
  shippingDocumentsRead: 'shipping_documents.read',
  shippingDocumentsUpdate: 'shipping_documents.update',

  // support
  supportCreate: 'support.create',
  supportRead: 'support.read',
  supportUpdateStatus: 'support.update_status',

  // tracking
  trackingViewHistory: 'tracking.view_history',
  trackingViewLive: 'tracking.view_live',

  // trailers
  trailersCreate: 'trailers.create',
  trailersDelete: 'trailers.delete',
  trailersRead: 'trailers.read',
  trailersUpdate: 'trailers.update',

  // units
  unitsActivate: 'units.activate',
  unitsAssignDriver: 'units.assign_driver',
  unitsCreate: 'units.create',
  unitsDeactivate: 'units.deactivate',
  unitsDelete: 'units.delete',
  unitsDiagnostics: 'units.diagnostics',
  unitsExport: 'units.export',
  unitsImport: 'units.import',
  unitsRead: 'units.read',
  unitsUpdate: 'units.update',

  // users
  usersCreate: 'users.create',
  usersDelete: 'users.delete',
  usersInvite: 'users.invite',
  usersRead: 'users.read',
  usersResetPassword: 'users.reset_password',
  usersUpdate: 'users.update',

  // violations
  violationsRead: 'violations.read',
} as const;

export type Permission = (typeof PERM)[keyof typeof PERM];

/**
 * Barcha kalitlar massivi (104) — 0.17 katalog testi
 * (`permissions.catalog.test.ts`) shu ro'yxatni swagger bilan solishtiradi.
 */
export const ALL_PERMISSIONS: readonly Permission[] = Object.freeze(
  Object.values(PERM) as Permission[],
);

/**
 * Kalit → modul guruhi (Roles ekranida guruhlash uchun).
 *
 * Har bir kalit `<guruh>.<amal>` shaklida; guruh nomidagi `_` kalitning bir
 * qismi (`eld_devices.read`, `notification_settings.update`), shuning uchun
 * birinchi nuqtagacha bo'lgan bo'lak — guruh. Uch bo'g'inli kalitlar
 * (`drivers.license.view`, `company.history.view`) ham o'z guruhiga tushadi.
 */
export function permissionGroupOf(permission: Permission): string {
  const [head = ''] = permission.split('.');
  return head;
}

/** `usePermission()` qaytaradigan chaqiriladigan tekshiruvchi. */
export interface PermissionChecker {
  (permission: Permission): boolean;
  /** Kamida bittasi mavjud bo'lsa `true`. Bo'sh ro'yxat → `false`. */
  any: (permissions: readonly Permission[]) => boolean;
  /** Hammasi mavjud bo'lsa `true`. Bo'sh ro'yxat → `true`. */
  all: (permissions: readonly Permission[]) => boolean;
  /** `super_admin` — rol emas, alohida bayroq (F33). */
  isSuperAdmin: boolean;
}

export interface PermissionState {
  /** `GET /me` javobidagi ruxsat kalitlari. */
  permissions: readonly string[];
  /**
   * `super_admin` bayrog'i — rol ham, permission kaliti ham emas (F33).
   * `x-permission: super_admin` bo'lgan 4 ta `/companies*` operatsiyasi
   * faqat shu bayroq bilan ochiladi.
   */
  isSuperAdmin: boolean;
}

export const EMPTY_PERMISSION_STATE: PermissionState = Object.freeze({
  permissions: Object.freeze([]),
  isSuperAdmin: false,
});

/**
 * Kontekstdan mustaqil sof funksiya — testda va router loader'ida ishlatiladi.
 *
 * `super_admin` **hech qanday permission kalitini ochmaydi**: katalogda
 * `companies.*` kaliti yo'q — `/companies*` operatsiyalari `x-permission:
 * super_admin` bilan qo'riqlanadi va UI ularni `can.isSuperAdmin` orqali
 * tekshiradi. Qolgan modullar uchun faqat `GET /me` bergan ro'yxat amal qiladi
 * (backend ham shunday tekshiradi — frontend kengroq ruxsat ko'rsatmasligi kerak).
 */
export function createPermissionChecker(state: PermissionState): PermissionChecker {
  const granted = new Set(state.permissions);

  const has = (permission: Permission): boolean => granted.has(permission);

  const checker = ((permission: Permission) => has(permission)) as PermissionChecker;
  checker.any = (permissions) => permissions.some(has);
  checker.all = (permissions) => permissions.every(has);
  checker.isSuperAdmin = state.isSuperAdmin;
  return checker;
}

/**
 * Ruxsat konteksti. Auth store (0.12/0.15) tayyor bo'lgach `PermissionsProvider`
 * qiymatni `GET /me` javobidan oladi; hozircha props orqali beriladi (test uchun ham).
 */
export const PermissionsContext = createContext<PermissionState>(EMPTY_PERMISSION_STATE);

/** `can(PERM.x)` · `can.any([...])` · `can.all([...])` (fe-permissions §2). */
export function usePermission(): PermissionChecker {
  const state = useContext(PermissionsContext);
  return useMemo(() => createPermissionChecker(state), [state]);
}

/** `super_admin` bayrog'i — rol emas. */
export function useIsSuperAdmin(): boolean {
  return useContext(PermissionsContext).isSuperAdmin;
}
