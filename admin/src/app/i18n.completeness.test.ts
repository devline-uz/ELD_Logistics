/**
 * i18n butunlik testlari (9.5, 9.6, 9.7 — i18n-keeper).
 *
 * Uchta mustaqil tekshiruv:
 *  1. Kodda chaqirilgan har bir `t(...)` kaliti birlashtirilgan resursda bor
 *     (yo'qolgan 0) va resursdagi har bir barg kalit kodda (to'g'ridan-to'g'ri
 *     yoki ma'lum dinamik naqsh orqali) ishlatiladi (ortiqcha 0).
 *  2. Swagger'dagi barcha backend `enum` qiymatlari `enums.*` /
 *     `settings.company.enums.*` kalitlarida bor.
 *  3. `src/lib/errors.ts` dagi `ERROR_CODES`/`ERROR_I18N_KEYS` swagger javob
 *     tavsiflarida uchraydigan barcha xato kodlarini qamrab oladi va har bir
 *     xarita qiymati haqiqiy i18n kaliti sifatida mavjud.
 *
 * Statik skaner faqat `t('...')`/`t("...")`/`t(\`...\`)` chaqiruvlarini
 * ko'radi — aliaslangan (`const translate = t`) chaqiruvlar yo'q (loyihada
 * hamma joyda `const { t } = useTranslation()`, tekshirilgan). Ba'zi kalitlar
 * `t(...)` dan tashqarida, ma'lumot sifatida saqlanadi va boshqa joyda
 * dinamik chaqiriladi — bular pastdagi `KNOWN_INDIRECTIONS` da hujjatlangan.
 */
import { readFileSync, readdirSync } from 'node:fs';
import path from 'node:path';

import { describe, expect, it } from 'vitest';

import { enResources } from '@/app/i18n';
import type { LocaleResource } from '@/app/i18n';
import { ERROR_CODES, ERROR_I18N_KEYS } from '@/lib/errors';

// Vitest `cwd` — loyihaning `admin/` ildizi (`package.json` joylashgan yer).
const ADMIN_ROOT = process.cwd();
const SRC_ROOT = path.join(ADMIN_ROOT, 'src');

const EXCLUDED = /(\.test\.|\.spec\.|[\\/]mocks[\\/]|__mocks__)/;

/** `src/**\/*.{ts,tsx}` ro'yxati — testlar, mock'lar chiqarib tashlanadi. */
function listSourceFiles(dir: string): string[] {
  const out: string[] = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      out.push(...listSourceFiles(full));
      continue;
    }
    if (!/\.(ts|tsx)$/.test(entry.name)) continue;
    if (EXCLUDED.test(full.replace(/\\/g, '/'))) continue;
    out.push(full);
  }
  return out;
}

const isPlainObject = (value: unknown): value is LocaleResource =>
  typeof value === 'object' && value !== null && !Array.isArray(value);

function lookup(tree: LocaleResource, key: string): unknown {
  return key.split('.').reduce<unknown>((acc, part) => {
    if (isPlainObject(acc) && part in acc) return acc[part];
    return undefined;
  }, tree);
}

/** i18next ko'plik qo'shimchalari (`_one`/`_other`/`_zero`) bilan mos keladi. */
function resolves(tree: LocaleResource, key: string): boolean {
  if (lookup(tree, key) !== undefined) return true;
  return ['_one', '_other', '_zero'].some((suffix) => lookup(tree, key + suffix) !== undefined);
}

function collectLeaves(node: unknown, prefix: string, out: Set<string>): void {
  if (isPlainObject(node)) {
    for (const [key, value] of Object.entries(node)) {
      collectLeaves(value, prefix ? `${prefix}.${key}` : key, out);
    }
    return;
  }
  if (prefix) out.add(prefix);
}

interface ScanResult {
  /** `t('literal.key')` / `t(\`literal.key\`)` (interpolyatsiyasiz) — to'liq kalit. */
  literalKeys: Set<string>;
  /** `t(\`prefix.${var}\`)` — `${` dan oldingi statik qism. */
  templatePrefixes: Set<string>;
  /** Har qanday qatorda uchraydigan nuqtali-kichik-harf satr literallari —
   *  kalit xaritalarida (`MODULE_ERROR_KEYS`, `nav-config.ts` kabi) qiymat
   *  sifatida saqlanib, keyin boshqa joyda dinamik `t(variable)` orqali
   *  chaqiriladigan kalitlarni tutish uchun. */
  candidateStrings: Set<string>;
  /** `<ImportModal i18nNamespace="fleet.units.import" />` kabi qayta
   *  ishlatiladigan komponentlarga uzatilgan dinamik namespace qiymatlari. */
  namespaceValues: Set<string>;
}

const KEY_LIKE = /^[a-z][a-zA-Z0-9]*(\.[a-z][a-zA-Z0-9]*){1,8}$/;

function scanSource(): ScanResult {
  const literalKeys = new Set<string>();
  const templatePrefixes = new Set<string>();
  const candidateStrings = new Set<string>();
  const namespaceValues = new Set<string>();

  for (const file of listSourceFiles(SRC_ROOT)) {
    const text = readFileSync(file, 'utf-8');

    for (const m of text.matchAll(/\bt\(\s*'([^']+)'/g)) {
      if (m[1] !== undefined) literalKeys.add(m[1]);
    }
    for (const m of text.matchAll(/\bt\(\s*"([^"]+)"/g)) {
      if (m[1] !== undefined) literalKeys.add(m[1]);
    }

    for (const m of text.matchAll(/\bt\(\s*`([^`]+)`/g)) {
      const raw = m[1];
      if (raw === undefined) continue;
      const idx = raw.indexOf('${');
      if (idx === -1) {
        literalKeys.add(raw);
      } else if (idx > 0) {
        const prefix = raw.slice(0, idx).replace(/\.$/, '');
        if (prefix) templatePrefixes.add(prefix);
      }
    }

    for (const m of text.matchAll(/'([a-z][a-zA-Z0-9.]*\.[a-zA-Z0-9.]+)'/g)) {
      if (m[1] !== undefined && KEY_LIKE.test(m[1])) candidateStrings.add(m[1]);
    }
    for (const m of text.matchAll(/"([a-z][a-zA-Z0-9.]*\.[a-zA-Z0-9.]+)"/g)) {
      if (m[1] !== undefined && KEY_LIKE.test(m[1])) candidateStrings.add(m[1]);
    }

    for (const m of text.matchAll(/i18nNamespace=["']([a-zA-Z0-9.]+)["']/g)) {
      if (m[1] !== undefined) namespaceValues.add(m[1]);
    }
  }

  return { literalKeys, templatePrefixes, candidateStrings, namespaceValues };
}

/**
 * Statik skaner topolmaydigan, lekin tasdiqlangan dinamik kalit-xarita
 * naqshlari — har biri manba faylga havola bilan.
 */
const KNOWN_INDIRECTIONS: readonly string[] = [
  // `historyColumns.ts` → `formatHistoryChange`: `settings.history.actions.${action}`
  // (KNOWN_ACTIONS to'plami orqali, swagger HistoryEntry.action bilan mos).
  'settings.history.actions',
  // `lib/profileLabel.ts` → `useProfileLabel('reports.<ekran>.screenName')`
  // `t('reports.<ekran>.screenName.' + profile)` ni chaqiradi.
  'reports.distanceByRegion.screenName',
  'reports.regulator.screenName',
  'reports.exportJobs.types.distance_by_region',
  'reports.exportJobs.types.regulator',
];

const scan = scanSource();

describe('i18n completeness (9.5): missing keys', () => {
  it('every literal t() key resolves in the merged resource tree', () => {
    const missing = [...scan.literalKeys].filter((key) => !resolves(enResources, key)).sort();

    expect(missing).toEqual([]);
  });

  it('every dynamic template prefix resolves to an object node', () => {
    const missing = [...scan.templatePrefixes]
      .filter((prefix) => !isPlainObject(lookup(enResources, prefix)))
      .sort();

    expect(missing).toEqual([]);
  });
});

describe('i18n completeness (9.5): unused keys', () => {
  it('every leaf translation key is reachable from source code', () => {
    const used = new Set<string>();

    for (const key of scan.literalKeys) {
      if (!resolves(enResources, key)) continue;
      used.add(key);
      for (const suffix of ['_one', '_other', '_zero']) used.add(key + suffix);
    }
    for (const prefix of scan.templatePrefixes) {
      collectLeaves(lookup(enResources, prefix), prefix, used);
    }
    for (const candidate of scan.candidateStrings) {
      if (resolves(enResources, candidate)) used.add(candidate);
    }
    for (const prefix of KNOWN_INDIRECTIONS) {
      collectLeaves(lookup(enResources, prefix), prefix, used);
    }
    // Qayta ishlatiladigan `ImportModal` (`i18nNamespace` prop) — har bir
    // chaqiruv o'rnidagi namespace qiymati ostidagi butun daraxt ishlatiladi.
    for (const namespace of scan.namespaceValues) {
      collectLeaves(lookup(enResources, namespace), namespace, used);
    }

    const allLeaves = new Set<string>();
    collectLeaves(enResources, '', allLeaves);

    const extra = [...allLeaves].filter((key) => !used.has(key)).sort();
    expect(extra).toEqual([]);
  });
});

// ---------------------------------------------------------------------------
// 9.6 — Swagger enum qiymatlari → `enums.*` / `settings.company.enums.*`
// ---------------------------------------------------------------------------

/**
 * Swagger `definitions`dagi enum maydonlarining kanonik qiymatlari —
 * `openapi/swagger.json`dan qo'lda ko'chirilgan (fe-conventions W13: katta
 * faylni to'liq o'qimaslik; bu yerda faqat tegishli enum ro'yxatlari).
 * Bir nechta DTO bir xil maydonni takrorlasa — bittasi yetarli. Ba'zi
 * guruhlar (`duty_status`, `connection_status`) bir nechta swagger
 * maydonining (masalan `status` + `special`, yoki `online_status` +
 * `connection_state`) birlashtirilgan/kengaytirilgan ko'rinishi — bu
 * domen qarori (fe-conventions §8), shu sabab ustidan qo'yilgan qiymatlar.
 */
const SWAGGER_ENUM_GROUPS: Readonly<Record<string, readonly string[]>> = {
  // NotificationSetting.alert_type / Notification.alert_type
  alert_type: [
    'hos_warning',
    'hos_violation',
    'route_assigned',
    'route_completed',
    'dvir_defects',
    'dvir_critical',
    'log_edit_request',
    'log_edit_resolved',
    'uncertified_log',
    'unidentified_driving',
    'eld_disconnected',
    'eld_malfunction',
    'maintenance_upcoming',
    'maintenance_overdue',
    'chat_message',
    'subscription_expiring',
  ],
  // auditlog Entry.action
  audit_action: [
    'insert',
    'create',
    'update',
    'soft_delete',
    'delete',
    'restore',
    'login',
    'logout',
    'failed_login',
    'export',
    'permission_change',
    'log_edit_request',
    'hos_policy_change',
    'token_reuse',
    'cross_tenant_attempt',
    'certify',
    'assign',
    'approve',
    'reject',
    'license_reveal',
  ],
  // LiveUnit.online_status ∪ UnitDiagnostics.connection_state
  connection_status: ['online', 'offline', 'disconnected', 'malfunction', 'no_device'],
  // EldDevice.connection_type / UnitDiagnostics.connection_type
  connection_type: ['bluetooth', 'wifi', 'cellular', 'usb'],
  // Defect.category / DefectType.category
  defect_category: ['truck', 'trailer'],
  // Driver.status
  driver_status: ['invited', 'active', 'inactive'],
  // DutyStatusEvent.status ∪ .special (pc/ym kombinatsiyasi — fe-conventions §8)
  duty_status: ['OFF', 'SB', 'DR', 'ON', 'PC', 'YM'],
  // DvirReport.source
  dvir_source: ['app', 'paper_import'],
  // DvirReport.status
  dvir_status: [
    'draft',
    'submitted_no_defects',
    'submitted_defects_found',
    'repaired',
    'certified',
    'closed_no_certification',
  ],
  // DvirReport.type / DvirCreate.type
  dvir_type: ['pre_trip', 'post_trip'],
  // ExportJob.status
  export_job_status: ['queued', 'running', 'done', 'failed'],
  // Schedule.interval_unit
  maintenance_interval_unit: ['km', 'mi', 'days', 'engine_hours'],
  // Record.status
  maintenance_record_status: ['completed', 'cancelled'],
  // Schedule.status
  maintenance_schedule_status: ['active', 'inactive'],
  // ScheduleUnit.status
  maintenance_unit_status: ['scheduled', 'due', 'completed', 'cancelled'],
  // routes_dto Route.status (dashboard_dto'dagi planned/in_progress
  // `features/dashboard/lib/routeStatus.ts` orqali shu to'rttasiga mos keladi)
  route_status: ['ongoing', 'completed', 'not_completed', 'cancelled'],
  // support_dto Ticket.status
  support_ticket_status: ['new', 'in_progress', 'resolved', 'closed'],
  // support_dto TicketCreate.contact_on
  support_contact_on: ['email', 'phone', 'sms', 'in_app'],
  // User.status
  user_status: ['invited', 'active', 'inactive'],
};

/**
 * `Schedule.alert_type` (notification/email/sms/none) va
 * `Schedule.delivery_methods` (push/email/sms/in_app) swagger'da `enum`
 * kalit so'zisiz oddiy `string`/`string[]` sifatida belgilangan — qiymatlar
 * faqat `example` va TZ'da hujjatlashtirilgan, shu sabab bu ikkisi
 * (`maintenance_alert_type`, `maintenance_delivery_method`) va
 * `maintenance_type` (`oil_change`…) yuqoridagi ro'yxatga kiritilmagan —
 * ularning to'liqligi swagger'dan emas, TZ §7.5 dan tasdiqlanadi.
 */
const SWAGGER_COMPANY_ENUM_GROUPS: Readonly<Record<string, readonly string[]>> = {
  // Company.region
  region: ['PK', 'UZ', 'US', 'other'],
  // Company.unit_system
  unitSystem: ['metric', 'imperial'],
  // Company.regulation_profile
  regulationProfile: ['us_fmcsa', 'generic', 'canada', 'texas', 'california', 'alaska', 'hawaii'],
  // Settings.distance_regions_set
  distanceRegionsSet: ['us_states', 'pk_provinces', 'uz_regions', 'none'],
  // Company.subscription_status
  subscriptionStatus: ['trial', 'active', 'grace', 'readonly'],
};

describe('i18n completeness (9.6): swagger enum coverage', () => {
  it.each(Object.entries(SWAGGER_ENUM_GROUPS))(
    'enums.%s has a translation for every swagger value',
    (group, values) => {
      const missing = values.filter(
        (value) => lookup(enResources, `enums.${group}.${value}`) === undefined,
      );
      expect(missing).toEqual([]);
    },
  );

  it.each(Object.entries(SWAGGER_COMPANY_ENUM_GROUPS))(
    'settings.company.enums.%s has a translation for every swagger value',
    (group, values) => {
      const missing = values.filter(
        (value) => lookup(enResources, `settings.company.enums.${group}.${value}`) === undefined,
      );
      expect(missing).toEqual([]);
    },
  );
});

// ---------------------------------------------------------------------------
// 9.7 — `src/lib/errors.ts` xarita to'liqligi swagger xato kodlariga nisbatan
// ---------------------------------------------------------------------------

/**
 * `openapi/swagger.json` dagi har bir `4xx`/`5xx` javob tavsifidan (faqat
 * error-kod shaklidagi — kamida bitta pasttirnoq bo'lgan YUQORI_HARF so'z)
 * barcha backend xato kodlarini yig'ib chiqadi. Tavsiflar ko'pincha
 * `"CODE_A / CODE_B"` shaklida bir nechta muqobil kodni sanaydi.
 */
function collectSwaggerErrorCodes(): Set<string> {
  const swaggerPath = path.join(ADMIN_ROOT, 'openapi', 'swagger.json');
  const spec = JSON.parse(readFileSync(swaggerPath, 'utf-8')) as {
    paths: Record<string, Record<string, { responses?: Record<string, { description?: string }> }>>;
  };

  const codes = new Set<string>();
  for (const methods of Object.values(spec.paths)) {
    for (const operation of Object.values(methods)) {
      if (typeof operation !== 'object' || operation === null) continue;
      for (const [status, response] of Object.entries(operation.responses ?? {})) {
        if (!/^[45]/.test(status)) continue;
        const description = response.description ?? '';
        for (const part of description.split(/[\s/,]+/)) {
          const token = part.replace(/^[.(]+|[.)]+$/g, '');
          // Kamida bitta pastki chiziqli, faqat YUQORI_HARF/raqam kodlar —
          // shovqinli akronimlar (PDF, CSV, FMCSA, Q13 …) chiqarib tashlanadi.
          if (/^[A-Z][A-Z0-9]*_[A-Z0-9_]+$/.test(token)) codes.add(token);
        }
      }
    }
  }
  return codes;
}

describe('i18n completeness (9.7): backend error code coverage', () => {
  it('every swagger 4xx/5xx error code has a central ERROR_CODES entry', () => {
    const swaggerCodes = collectSwaggerErrorCodes();
    const known = new Set<string>(ERROR_CODES);
    const missing = [...swaggerCodes].filter((code) => !known.has(code)).sort();

    expect(missing).toEqual([]);
  });

  it('every ERROR_CODES entry has a matching ERROR_I18N_KEYS mapping', () => {
    const missing = ERROR_CODES.filter((code) => ERROR_I18N_KEYS[code] === undefined);
    expect(missing).toEqual([]);
  });

  it('every ERROR_I18N_KEYS value resolves to a real translation', () => {
    const missing = Object.entries(ERROR_I18N_KEYS)
      .filter(([, key]) => lookup(enResources, key) === undefined)
      .map(([code]) => code);

    expect(missing).toEqual([]);
  });
});
