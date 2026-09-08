/**
 * `DutyGrid` / `HosRings` uchun umumiy tiplar.
 *
 * Ikkala komponent ham **sof** — hech qanday HOS qoidasini bilmaydi va
 * hisoblamaydi, hech qanday query chaqirmaydi. Barcha qiymatlar va matnlar
 * props orqali keladi (TZ §7.4.3, ui-component-builder topshirig'i 3.4/3.5).
 */

/** FMCSA duty-status kodlari — grid qatorlari shu tartibda: OFF, SB, DR, ON. */
export type DutyStatusCode = 'OFF' | 'SB' | 'DR' | 'ON';

/** `special` — Personal Conveyance / Yard Move; grid'da shtrix pattern bilan ajratiladi. */
export type DutySpecialCode = 'none' | 'pc' | 'ym';

/** Grid ustidagi hodisa markerlari — faqat shu 4 turi (`tz.md` Q15). */
export type DutyEventType = 'pti' | 'fuel' | 'certify' | 'malfunction';

/**
 * Bitta duty-status segmenti. `startTime`/`endTime` — ISO 8601 UTC
 * instant'lar (backend formatiga mos). Komponent ularni `timezone` asosida
 * kompaniya kuni ichidagi nisbiy pozitsiyaga aylantiradi va sutka
 * chegarasidan tashqariga chiqqan qismini kesib tashlaydi (yarim tunni
 * kesib o'tuvchi segment holati).
 */
export interface DutySegment {
  status: DutyStatusCode;
  special?: DutySpecialCode;
  /** ISO 8601 UTC instant. */
  startTime: string;
  /** ISO 8601 UTC instant, `startTime` dan keyin bo'lishi shart. */
  endTime: string;
  /** Tooltip/jadval ekvivalenti uchun ixtiyoriy izoh. */
  note?: string;
  /** Tooltip/jadval ekvivalenti uchun ixtiyoriy joylashuv matni. */
  locationText?: string;
}

/** Grid ustidagi bitta hodisa markeri. */
export interface DutyEventMarker {
  type: DutyEventType;
  /** ISO 8601 UTC instant. */
  time: string;
  note?: string;
}

/**
 * `DutyGrid` render qiladigan barcha matnlar — komponent domen bilmaydi,
 * shuning uchun har bir yorliq chaqiruvchi tomonidan (i18n `t()` orqali)
 * beriladi. Ixtiyoriy default yo'q — bo'sh matn bilan chiqib ketmaslik
 * uchun ataylab majburiy qilingan.
 */
export interface DutyGridLabels {
  statusRow: Record<DutyStatusCode, string>;
  special: Record<Exclude<DutySpecialCode, 'none'>, string>;
  eventType: Record<DutyEventType, string>;
  /** Masalan «Total». */
  total: string;
  /** SVG `aria-label` uchun sarlavha, masalan «24-hour duty status grid». */
  gridAriaLabel: string;
  /** Skrin-rider uchun jadval sarlavhasi, masalan «Duty status segments». */
  segmentsTableCaption: string;
  columnStatus: string;
  columnFrom: string;
  columnTo: string;
  columnDuration: string;
  columnNote: string;
  /** Hodisalar jadvali sarlavhasi, masalan «Events». */
  eventsTableCaption: string;
  columnEvent: string;
  columnTime: string;
  /** Bo'sh sutka holati, masalan «No duty status recorded for this day.» */
  emptyState: string;
}

export interface DutyGridProps {
  /** Home terminal kalendar kuni, `YYYY-MM-DD`. */
  date: string;
  /** IANA zona nomi (`company.timezone`) — sutka chegarasi shu zonada. */
  timezone: string;
  segments: DutySegment[];
  events?: DutyEventMarker[];
  labels: DutyGridLabels;
  className?: string;
}

/* ------------------------------------------------------------------ *
 * HosRings
 * ------------------------------------------------------------------ */

/** Halqa uchun vizual ohang — komponent buni faqat rang tanlashda ishlatadi. */
export type HosRingTone = 'warning' | 'success' | 'info' | 'primary' | 'neutral';

/**
 * Bitta HOS halqasi uchun ma'lumot — hammasi `hos-summary` javobidan
 * (`counters.*_left_min`) kelishi kerak. `limitMinutes` `null` bo'lsa,
 * komponent hech qanday chegarani taxmin qilmaydi — halqa noaniq holatda
 * chiziladi.
 */
export interface HosRingDatum {
  id: string;
  /** Halqa ustidagi qisqa yorliq, masalan «BREAK» (chaqiruvchi tomonidan tarjima qilingan). */
  label: string;
  /** Qolgan daqiqalar; `null` — noma'lum. */
  remainingMinutes: number | null;
  /** Siyosat chegarasi (daqiqada); `null` — noma'lum (F98 — hardcode qilinmaydi). */
  limitMinutes: number | null;
  tone: HosRingTone;
}

export interface HosRingsLabels {
  /** Qiymat noma'lum bo'lganda ko'rsatiladigan matn, masalan «N/A». */
  unknown: string;
  /** Chegaraga yaqinlashganda ko'rsatiladigan holat matni. */
  nearLimit: string;
  /** Chegaradan oshganda ko'rsatiladigan holat matni. */
  exceeded: string;
  /** `aria-label` shabloni uchun «remaining» so'zi. */
  remainingSuffix: string;
}

export interface HosRingsProps {
  /** Odatda 4 ta (BREAK/DRIVE/SHIFT/CYCLE), lekin komponent sonini bilmaydi. */
  rings: HosRingDatum[];
  labels: HosRingsLabels;
  /** Shu nisbatdan past qolganda «near limit» ogohlantirishi (default 0.2). */
  warnThresholdRatio?: number;
  className?: string;
}
