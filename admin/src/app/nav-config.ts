/**
 * Navigatsiya modeli — `fe-permissions` §6 jadvalining yagona kod ko'rinishi.
 *
 * Kanonik nomlar (W11): **Fleet Management**, **Reports**, **Support & History**
 * (`Fleet Operations` / `Report` / `Histories` — ishlatilmaydi; `Histories`
 * faqat Support & History ichidagi punkt nomi).
 *
 * Ko'rinish qoidasi: element ruxsat bo'lmasa **DOM'da bo'lmaydi**; marshrutning
 * o'zi esa `RouteGuard` bilan 403 ekraniga olib boradi (fe-permissions §3).
 */

import { PERM, type Permission, type PermissionChecker } from '@/lib/permissions';
import type { ProfileLabelBucket } from '@/lib/profileLabel';

export interface NavLeaf {
  id: string;
  path: string;
  labelKey: string;
  /**
   * Base i18n kalit — mavjud bo'lsa, ko'rsatiladigan nom `labelKey` o'rniga
   * `${profileLabelKey}.${bucket}` orqali hal qilinadi (`regulation_profile`
   * bucketiga qarab, D32). Masalan Distance by Region / IFTA Report,
   * Regulator Export / FMCSA Report — `resolveNavLabelKey()` bilan birga.
   */
  profileLabelKey?: string;
  /** Flyout punktining tavsif matni (dizayndagi lorem ipsum o'rniga). */
  descriptionKey?: string;
  /**
   * Ko'rinish sharti — kamida bittasi yetarli. `superAdminOnly` elementlari
   * uchun bo'sh massiv (permission kaliti yo'q, `can.isSuperAdmin` tekshiradi).
   */
  anyOf: readonly Permission[];
  /**
   * `super_admin` bayrog'i — rol emas, `PERM` katalogida yo'q (F33).
   * Faqat Super Admin konsoli (`/companies`, 9.15, §7.14) uchun.
   */
  superAdminOnly?: boolean;
}

/**
 * Nav/breadcrumb elementi uchun ko'rsatiladigan i18n kalitni hal qiladi (D32).
 * `profileLabelKey` mavjud bo'lsa profilga bog'liq kalit, aks holda statik `labelKey`.
 */
export function resolveNavLabelKey(
  entry: Pick<NavLeaf, 'labelKey' | 'profileLabelKey'>,
  bucket: ProfileLabelBucket,
): string {
  return entry.profileLabelKey ? `${entry.profileLabelKey}.${bucket}` : entry.labelKey;
}

export interface NavGroup {
  id: string;
  labelKey: string;
  /** Guruh o'zi bosiladigan bo'lsa (Maintenance). */
  path?: string;
  children: readonly NavLeaf[];
}

export type NavEntry = NavLeaf | NavGroup;

export function isNavGroup(entry: NavEntry): entry is NavGroup {
  return 'children' in entry;
}

export const NAV_ENTRIES: readonly NavEntry[] = [
  {
    id: 'dashboard',
    path: '/',
    labelKey: 'nav.dashboard',
    anyOf: [PERM.dashboardRead],
  },
  {
    id: 'tracking',
    path: '/tracking',
    labelKey: 'nav.tracking',
    anyOf: [PERM.trackingViewLive],
  },
  {
    id: 'logs',
    labelKey: 'nav.logs.label',
    children: [
      {
        id: 'logs-by-unit',
        path: '/logs/by-unit',
        labelKey: 'nav.logs.byUnit',
        descriptionKey: 'nav.logs.byUnitDescription',
        anyOf: [PERM.logsRead],
      },
      {
        id: 'logs-by-driver',
        path: '/logs/by-driver',
        labelKey: 'nav.logs.byDriver',
        descriptionKey: 'nav.logs.byDriverDescription',
        anyOf: [PERM.logsRead],
      },
      {
        id: 'logs-edit-requests',
        path: '/logs/edit-requests',
        labelKey: 'nav.logs.editRequests',
        descriptionKey: 'nav.logs.editRequestsDescription',
        // `GET /log-edit-requests` → `logs.read` (alohida `logs.edit_requests.*`
        // guruhi yo'q; tasdiqlash/rad etish — `logs.approve_edit`/`logs.reject_edit`).
        anyOf: [PERM.logsRead],
      },
      {
        id: 'logs-unassigned',
        path: '/logs/unassigned',
        labelKey: 'nav.logs.unassigned',
        descriptionKey: 'nav.logs.unassignedDescription',
        // `GET /unidentified-events` — OR mantiq: swagger `logs.assign_unidentified`
        // ko'rsatadi, backend `logs.read` ni ham qabul qiladi (docs/api/permissions.md).
        anyOf: [PERM.logsAssignUnidentified, PERM.logsRead],
      },
      {
        id: 'violations',
        path: '/violations',
        labelKey: 'nav.logs.violations',
        descriptionKey: 'nav.logs.violationsDescription',
        anyOf: [PERM.violationsRead],
      },
    ],
  },
  {
    id: 'fleet',
    labelKey: 'nav.fleet.label',
    children: [
      {
        id: 'units',
        path: '/units',
        labelKey: 'nav.fleet.units',
        descriptionKey: 'nav.fleet.unitsDescription',
        anyOf: [PERM.unitsRead],
      },
      {
        id: 'drivers',
        path: '/drivers',
        labelKey: 'nav.fleet.drivers',
        descriptionKey: 'nav.fleet.driversDescription',
        anyOf: [PERM.driversRead],
      },
      {
        id: 'eld-devices',
        path: '/eld-devices',
        labelKey: 'nav.fleet.eldDevices',
        descriptionKey: 'nav.fleet.eldDevicesDescription',
        anyOf: [PERM.eldDevicesRead],
      },
      {
        id: 'trailers',
        path: '/trailers',
        labelKey: 'nav.fleet.trailers',
        descriptionKey: 'nav.fleet.trailersDescription',
        anyOf: [PERM.trailersRead],
      },
      {
        id: 'shipping-documents',
        path: '/shipping-documents',
        labelKey: 'nav.fleet.shippingDocuments',
        descriptionKey: 'nav.fleet.shippingDocumentsDescription',
        anyOf: [PERM.shippingDocumentsRead],
      },
      {
        id: 'users',
        path: '/users',
        labelKey: 'nav.fleet.users',
        descriptionKey: 'nav.fleet.usersDescription',
        anyOf: [PERM.usersRead],
      },
      {
        id: 'roles',
        path: '/roles',
        labelKey: 'nav.fleet.roles',
        descriptionKey: 'nav.fleet.rolesDescription',
        anyOf: [PERM.rolesRead],
      },
    ],
  },
  {
    id: 'maintenance',
    labelKey: 'nav.maintenance.label',
    path: '/maintenance',
    children: [
      {
        id: 'maintenance-schedule',
        path: '/maintenance',
        labelKey: 'nav.maintenance.schedule',
        descriptionKey: 'nav.maintenance.scheduleDescription',
        anyOf: [PERM.maintenanceRead],
      },
      {
        id: 'dvir',
        path: '/dvir',
        labelKey: 'nav.maintenance.dvir',
        descriptionKey: 'nav.maintenance.dvirDescription',
        anyOf: [PERM.dvirRead],
      },
    ],
  },
  {
    id: 'reports',
    labelKey: 'nav.reports.label',
    children: [
      {
        id: 'report-activity',
        path: '/reports/activity',
        labelKey: 'nav.reports.activity',
        descriptionKey: 'nav.reports.activityDescription',
        anyOf: [PERM.reportsRead],
      },
      {
        id: 'report-distance-by-region',
        path: '/reports/distance-by-region',
        labelKey: 'nav.reports.distanceByRegion',
        // D32: profil bo'yicha "IFTA Report" (us_fmcsa) / "Distance by Region" (generic) —
        // sahifa h1 bilan bir xil i18n kalit (`reports.distanceByRegion.screenName.*`).
        profileLabelKey: 'reports.distanceByRegion.screenName',
        descriptionKey: 'nav.reports.distanceByRegionDescription',
        anyOf: [PERM.reportsRead],
      },
      {
        id: 'report-regulator',
        path: '/reports/regulator',
        labelKey: 'nav.reports.regulator',
        // D32: profil bo'yicha "FMCSA Report" (us_fmcsa) / "Regulator Export" (generic).
        profileLabelKey: 'reports.regulator.screenName',
        descriptionKey: 'nav.reports.regulatorDescription',
        anyOf: [PERM.reportsRead],
      },
      {
        id: 'report-dvir',
        path: '/reports/dvir',
        labelKey: 'nav.reports.dvir',
        descriptionKey: 'nav.reports.dvirDescription',
        anyOf: [PERM.reportsRead],
      },
      {
        id: 'report-uncertified',
        path: '/reports/uncertified-logs',
        labelKey: 'nav.reports.uncertified',
        descriptionKey: 'nav.reports.uncertifiedDescription',
        anyOf: [PERM.reportsRead],
      },
      {
        id: 'report-exports',
        path: '/reports/exports',
        labelKey: 'nav.reports.exports',
        descriptionKey: 'nav.reports.exportsDescription',
        anyOf: [PERM.reportsRead],
      },
    ],
  },
  {
    id: 'support',
    labelKey: 'nav.support.label',
    children: [
      {
        id: 'audit',
        path: '/audit',
        labelKey: 'nav.support.audit',
        descriptionKey: 'nav.support.auditDescription',
        anyOf: [PERM.auditView],
      },
      {
        id: 'support-tickets',
        path: '/support',
        labelKey: 'nav.support.contact',
        descriptionKey: 'nav.support.contactDescription',
        anyOf: [PERM.supportRead],
      },
      {
        id: 'feedback',
        path: '/feedback',
        labelKey: 'nav.support.feedback',
        descriptionKey: 'nav.support.feedbackDescription',
        anyOf: [PERM.feedbackRead],
      },
    ],
  },
  {
    id: 'chat',
    path: '/chat',
    labelKey: 'nav.chat',
    anyOf: [PERM.chatRead],
  },
  {
    id: 'companies',
    path: '/companies',
    labelKey: 'nav.companies',
    anyOf: [],
    superAdminOnly: true,
  },
];

/**
 * Nav'dan tashqaridagi ekranlar (breadcrumb sarlavhasi uchun).
 * Settings — profil menyusi orqali; detal ekranlari — ro'yxatlardan.
 */
export const EXTRA_ROUTE_TITLES: Readonly<Record<string, string>> = Object.freeze({
  '/routes': 'pages.routes.title',
  '/settings/profile': 'pages.settingsProfile.title',
  '/settings/company': 'pages.settingsCompany.title',
  '/settings/branches': 'pages.settingsBranches.title',
  '/settings/history': 'pages.settingsHistory.title',
  '/settings/hos': 'pages.settingsHos.title',
  '/settings/notifications': 'pages.settingsNotifications.title',
  '/settings/security': 'pages.settingsSecurity.title',
  // Nav tashqarisidagi ekran — faqat qo'ng'iroq dropdown'idan ochiladi (7.8).
  '/notifications': 'notifications.page.title',
});

export interface VisibleNavLeaf extends NavLeaf {
  kind: 'leaf';
}

export interface VisibleNavGroup {
  kind: 'group';
  id: string;
  labelKey: string;
  path?: string;
  children: VisibleNavLeaf[];
}

export type VisibleNavEntry = VisibleNavLeaf | VisibleNavGroup;

/**
 * Nav daraxtini ruxsatlar bo'yicha filtrlaydi. Bo'sh qolgan guruh butunlay
 * tushib qoladi (fe-permissions §3 — "Nav elementi / flyout punkti → yashiriladi").
 *
 * `can` to'liq `PermissionChecker` (callable + `.any`/`.all`/`.isSuperAdmin`)
 * — `superAdminOnly` elementlari (`/companies`, 9.15) `can.isSuperAdmin`
 * bilan tekshiriladi, oddiy `anyOf` permission tekshiruvidan mustaqil.
 */
export function filterNav(entries: readonly NavEntry[], can: PermissionChecker): VisibleNavEntry[] {
  const allowed = (leaf: NavLeaf) =>
    leaf.superAdminOnly === true ? can.isSuperAdmin : leaf.anyOf.some(can);
  const result: VisibleNavEntry[] = [];

  for (const entry of entries) {
    if (isNavGroup(entry)) {
      const children = entry.children.filter(allowed).map<VisibleNavLeaf>((leaf) => ({
        ...leaf,
        kind: 'leaf',
      }));
      if (children.length > 0) {
        result.push({
          kind: 'group',
          id: entry.id,
          labelKey: entry.labelKey,
          ...(entry.path === undefined ? {} : { path: entry.path }),
          children,
        });
      }
    } else if (allowed(entry)) {
      result.push({ ...entry, kind: 'leaf' });
    }
  }

  return result;
}

/** Barcha nav punktlari — breadcrumb va marshrut sarlavhalari uchun tekis ro'yxat. */
export function flattenNav(entries: readonly NavEntry[] = NAV_ENTRIES): NavLeaf[] {
  return entries.flatMap((entry) => (isNavGroup(entry) ? [...entry.children] : [entry]));
}

/**
 * `pathname` → sarlavha i18n kaliti (breadcrumb oxirgi bo'g'ini uchun).
 * `bucket` faqat `profileLabelKey`ga ega leaf'lar uchun ishlatiladi (D32).
 */
export function routeTitleKey(
  pathname: string,
  bucket: ProfileLabelBucket = 'generic',
): string | undefined {
  const leaf = flattenNav().find((item) => item.path === pathname);
  if (leaf) {
    return resolveNavLabelKey(leaf, bucket);
  }
  return EXTRA_ROUTE_TITLES[pathname];
}

/** `pathname` qaysi nav guruhiga tegishli (breadcrumbning o'rta bo'g'ini). */
export function navGroupOf(pathname: string): NavGroup | undefined {
  return NAV_ENTRIES.filter(isNavGroup).find((group) =>
    group.children.some((leaf) => pathname === leaf.path || pathname.startsWith(`${leaf.path}/`)),
  );
}
