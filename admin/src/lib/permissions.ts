/**
 * Permission kalitlari, `usePermission()` va ruxsat kontekstining yagona manbai.
 *
 * TAXMINIY — `GET /permissions` bilan tasdiqlanmagan. `DOCS_TOKEN` kelgach
 * 0.17 CI testi bilan solishtiriladi (backend manbai:
 * `backend/internal/auth/permissions.go`, 105 kalit). Quyidagi ro'yxat
 * `fe-permissions` skillidagi marshrut → modul prefiksi jadvalidan kelib chiqib
 * tuzilgan; drift aniqlanganda **backend ustun** va bu fayl yangilanadi.
 *
 * Qoida (fe-permissions §1): kod hech qachon xom satr yozmaydi — faqat `PERM.*`.
 */

import { createContext, useContext, useMemo } from 'react';

/** Modul guruhi — Roles ekranidagi checkbox guruhlash uchun ham ishlatiladi. */
export const PERMISSION_GROUPS = [
  'dashboard',
  'tracking',
  'routes',
  'logs',
  'violations',
  'units',
  'drivers',
  'eld_devices',
  'trailers',
  'shipping_documents',
  'users',
  'roles',
  'maintenance',
  'dvir',
  'reports',
  'audit',
  'support',
  'feedback',
  'chat',
  'notifications',
  'files',
  'company',
  'hos_policy',
  'companies',
  'permissions',
  'billing',
] as const;

export type PermissionGroup = (typeof PERMISSION_GROUPS)[number];

/**
 * Permission kalitlari konstantasi (typo kompilyatsiya vaqtida topiladi).
 * Guruhlar tartibi `PERMISSION_GROUPS` bilan bir xil.
 */
export const PERM = {
  // dashboard
  dashboardRead: 'dashboard.read',

  // tracking
  trackingViewLive: 'tracking.view_live',
  trackingViewHistory: 'tracking.view_history',

  // routes
  routesRead: 'routes.read',
  routesCreate: 'routes.create',
  routesUpdate: 'routes.update',
  routesDelete: 'routes.delete',

  // logs
  logsRead: 'logs.read',
  logsProposeEdit: 'logs.propose_edit',
  logsCertify: 'logs.certify',
  logsExport: 'logs.export',
  logsEditRequestsRead: 'logs.edit_requests.read',
  logsEditRequestsApprove: 'logs.edit_requests.approve',
  logsEditRequestsReject: 'logs.edit_requests.reject',
  logsUnassignedRead: 'logs.unassigned.read',
  logsUnassignedAssign: 'logs.unassigned.assign',

  // violations
  violationsRead: 'violations.read',
  violationsResolve: 'violations.resolve',

  // units
  unitsRead: 'units.read',
  unitsCreate: 'units.create',
  unitsUpdate: 'units.update',
  unitsDelete: 'units.delete',
  unitsExport: 'units.export',
  unitsImport: 'units.import',
  unitsIncludeInactive: 'units.include_inactive',
  unitsDiagnosticsRead: 'units.diagnostics.read',

  // drivers
  driversRead: 'drivers.read',
  driversCreate: 'drivers.create',
  driversUpdate: 'drivers.update',
  driversDelete: 'drivers.delete',
  driversExport: 'drivers.export',
  driversIncludeInactive: 'drivers.include_inactive',
  driversLicenseView: 'drivers.license.view',
  driversResetPassword: 'drivers.reset_password',

  // eld_devices
  eldDevicesRead: 'eld_devices.read',
  eldDevicesCreate: 'eld_devices.create',
  eldDevicesUpdate: 'eld_devices.update',
  eldDevicesDelete: 'eld_devices.delete',
  eldDevicesAssignUnit: 'eld_devices.assign_unit',

  // trailers
  trailersRead: 'trailers.read',
  trailersCreate: 'trailers.create',
  trailersUpdate: 'trailers.update',
  trailersDelete: 'trailers.delete',

  // shipping_documents
  shippingDocumentsRead: 'shipping_documents.read',
  shippingDocumentsCreate: 'shipping_documents.create',
  shippingDocumentsUpdate: 'shipping_documents.update',
  shippingDocumentsDelete: 'shipping_documents.delete',

  // users
  usersRead: 'users.read',
  usersCreate: 'users.create',
  usersUpdate: 'users.update',
  usersDelete: 'users.delete',
  usersInvite: 'users.invite',
  usersActivate: 'users.activate',
  usersDeactivate: 'users.deactivate',
  usersResetPassword: 'users.reset_password',

  // roles
  rolesRead: 'roles.read',
  rolesCreate: 'roles.create',
  rolesUpdate: 'roles.update',
  rolesDelete: 'roles.delete',

  // maintenance
  maintenanceRead: 'maintenance.read',
  maintenanceCreate: 'maintenance.create',
  maintenanceUpdate: 'maintenance.update',
  maintenanceDelete: 'maintenance.delete',
  maintenanceComplete: 'maintenance.complete',

  // dvir
  dvirRead: 'dvir.read',
  dvirUpdate: 'dvir.update',
  dvirResolveDefect: 'dvir.resolve_defect',
  dvirExport: 'dvir.export',

  // reports
  reportsRead: 'reports.read',
  reportsExport: 'reports.export',

  // audit
  auditView: 'audit.view',

  // support
  supportRead: 'support.read',
  supportReply: 'support.reply',
  supportClose: 'support.close',

  // feedback
  feedbackRead: 'feedback.read',

  // chat
  chatRead: 'chat.read',
  chatSend: 'chat.send',

  // notifications
  notificationsRead: 'notifications.read',
  notificationsUpdate: 'notifications.update',

  // files
  filesUpload: 'files.upload',

  // company (Settings › Company)
  companyRead: 'company.read',
  companyUpdate: 'company.update',

  // hos_policy (Settings › HOS)
  hosPolicyRead: 'hos_policy.read',
  hosPolicyUpdate: 'hos_policy.update',

  // companies — faqat super_admin (x-permission: super_admin)
  companiesRead: 'companies.read',
  companiesCreate: 'companies.create',
  companiesUpdate: 'companies.update',
  companiesDelete: 'companies.delete',

  // permissions — Roles ekranidagi kalit ro'yxati
  permissionsRead: 'permissions.read',

  // billing / subscription
  billingRead: 'billing.read',
} as const;

export type Permission = (typeof PERM)[keyof typeof PERM];

/** Barcha kalitlar massivi — 0.17 CI snapshot testi shu ro'yxatni solishtiradi. */
export const ALL_PERMISSIONS: readonly Permission[] = Object.freeze(
  Object.values(PERM) as Permission[],
);

/** Kalit → modul guruhi (Roles ekranida guruhlash uchun). */
export function permissionGroupOf(permission: Permission): string {
  const [head = '', second = ''] = permission.split('.');
  const twoSegment = `${head}_${second}`;
  return (PERMISSION_GROUPS as readonly string[]).includes(twoSegment) ? twoSegment : head;
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
  /** `super_admin` bayrog'i — `/companies*` endpointlari faqat shunga ochiq. */
  isSuperAdmin: boolean;
}

export const EMPTY_PERMISSION_STATE: PermissionState = Object.freeze({
  permissions: Object.freeze([]),
  isSuperAdmin: false,
});

/**
 * Kontekstdan mustaqil sof funksiya — testda va router loader'ida ishlatiladi.
 *
 * `super_admin` **hamma narsani ochmaydi**: u faqat `companies.*` kalitlarini
 * qo'shimcha beradi. Qolgan modullar uchun oddiy ruxsat ro'yxati amal qiladi
 * (backend ham shunday tekshiradi — frontend kengroq ruxsat ko'rsatmasligi kerak).
 */
export function createPermissionChecker(state: PermissionState): PermissionChecker {
  const granted = new Set(state.permissions);

  const has = (permission: Permission): boolean => {
    if (state.isSuperAdmin && permission.startsWith('companies.')) {
      return true;
    }
    return granted.has(permission);
  };

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
