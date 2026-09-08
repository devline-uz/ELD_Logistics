/**
 * DVIR holat mashinasi — **F106, 6 holat** (`docs/tz/07-5-dvir-maintenance.md`
 * §7.5). Backend enum'i yagona haqiqat manbai; dizayndagi 7 qiymat shu
 * yerda moslashtirilgan.
 *
 * ```
 *                    (mobil)                (admin: dvir.repair)   (haydovchi: dvir.certify)
 *   draft ──┬─► submitted_no_defects ─────────────────────────────────────────┐
 *           └─► submitted_defects_found ──► repaired ──► certified            │
 *                        │                     │                              │
 *                        └─────────────────────┴──► closed_no_certification ◄─┘
 *                                   (backend: unit inactive / 7 kun javobsiz)
 * ```
 *
 * UI **bitta** o'tishni boshlaydi: `submitted_defects_found → repaired`
 * (`Record repair`, Service Manager amali) — va faqat hisobotda mobil ilovada
 * olingan `mechanic_signature_key` bo'lsa (D30). `repaired → certified` — **haydovchi
 * endpointi**: `POST /dvir-reports/{id}/certify` chaqiruvchidan driver record'ga
 * ega bo'lishni talab qiladi va imzo haydovchiniki, shuning uchun admin panelda
 * `Certify` tugmasi **yo'q** (faqat kutish holati matni ko'rsatiladi).
 * Boshqa har qanday holatda tugma **umuman ko'rsatilmaydi** (yashiriladi) —
 * shu sabab noto'g'ri o'tish so'rovi yuborilmaydi. Poyga holatida (ro'yxat
 * eskirgan bo'lsa) backend `409 DVIR_INVALID_TRANSITION` qaytaradi va
 * `dvirErrorMessageKey` uni aniq matn bilan ko'rsatadi.
 */
import type { DvirReport } from '@/api/types';

export type DvirStatus = NonNullable<DvirReport['status']>;

/** Backend enum tartibi — filtr `Select` va tarix chizig'i uchun. */
export const DVIR_STATUSES: readonly DvirStatus[] = [
  'draft',
  'submitted_no_defects',
  'submitted_defects_found',
  'repaired',
  'certified',
  'closed_no_certification',
] as const;

/**
 * `draft` — mobil qurilmadagi lokal holat; admin ro'yxatida ko'rsatilmaydi
 * (Q30.2), shuning uchun status filtri variantlaridan chiqarib tashlanadi.
 */
export const DVIR_FILTERABLE_STATUSES: readonly DvirStatus[] = DVIR_STATUSES.filter(
  (status) => status !== 'draft',
);

/** Ruxsat etilgan o'tishlar grafi — UI shu jadvaldan tashqariga chiqmaydi. */
const TRANSITIONS: Record<DvirStatus, readonly DvirStatus[]> = {
  draft: ['submitted_no_defects', 'submitted_defects_found'],
  submitted_no_defects: ['certified', 'closed_no_certification'],
  submitted_defects_found: ['repaired', 'closed_no_certification'],
  repaired: ['certified', 'closed_no_certification'],
  certified: [],
  closed_no_certification: [],
};

export function canTransition(from: DvirStatus | undefined, to: DvirStatus): boolean {
  if (!from) return false;
  return TRANSITIONS[from].includes(to);
}

/**
 * `Record repair` — faqat `submitted_defects_found` dan (`dvir.repair`) **va**
 * hisobotda mexanik imzosi kaliti bo'lganda.
 *
 * **D30**: admin panel imzoni umuman olmaydi (§1.1) — mexanik imzosi mobil/
 * planshet ilovasida olinadi va hisobotga `mechanic_signature_key` bo'lib
 * tushadi. Backend bu maydonni `POST /dvir-reports/{id}/repair` da majburiy
 * qiladi, shuning uchun kalit yo'q bo'lsa amal boshlanmaydi: tugma
 * `disabled` va sababi ko'rsatiladi.
 */
export function canRecordRepair(report: {
  status?: DvirStatus;
  mechanic_signature_key?: string;
}): boolean {
  const { status, mechanic_signature_key: signatureKey } = report;
  if (status !== 'submitted_defects_found' || !canTransition(status, 'repaired')) return false;
  return Boolean(signatureKey);
}

/** Holat bo'yicha o'tish mumkin, lekin imzo kaliti hali yo'q (D30 sababi). */
export function isRepairBlockedByMissingSignature(report: {
  status?: DvirStatus;
  mechanic_signature_key?: string;
}): boolean {
  return report.status === 'submitted_defects_found' && !report.mechanic_signature_key;
}

/**
 * `repaired` — sertifikatlash kutilmoqda. Admin panel bu o'tishni **bajara
 * olmaydi** (haydovchi mobil ilovada imzo bilan tasdiqlaydi), shuning uchun
 * tugma emas, faqat tushuntirish matni ko'rsatiladi.
 */
export function awaitsDriverCertification(status: DvirStatus | undefined): boolean {
  return status === 'repaired' && canTransition(status, 'certified');
}

/** Badge rangi (fe-design-system §1 semantik xaritasi). */
export function dvirStatusTone(
  status: DvirStatus | undefined,
): 'success' | 'warning' | 'error' | 'neutral' | 'info' {
  switch (status) {
    case 'submitted_no_defects':
      return 'info';
    case 'submitted_defects_found':
      return 'error';
    case 'repaired':
      return 'warning';
    case 'certified':
      return 'success';
    case 'closed_no_certification':
      return 'error';
    default:
      return 'neutral';
  }
}

/** `enums.dvir_status.*` i18n kaliti. */
export function dvirStatusKey(status: DvirStatus | undefined): string {
  return `enums.dvir_status.${status ?? 'draft'}`;
}
