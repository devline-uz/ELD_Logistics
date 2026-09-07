/**
 * `DutyGrid` / `HosRings` uchun vizual tokenlar va layout konstantalari.
 *
 * Hech qanday xom hex kod yo'q — barchasi `src/styles/index.css` dagi CSS
 * o'zgaruvchilariga ishora qiladi (fe-design-system SKILL.md §1, §8). SVG
 * `fill`/`stroke` atributlari `var(--...)` qiymatini CSS sifatida qabul
 * qiladi, shuning uchun Tailwind class emas, to'g'ridan-to'g'ri shu
 * o'zgaruvchi ishlatiladi.
 */
import type { DutyEventType, DutyStatusCode, HosRingTone } from './types';

/** Grid qatorlari tartibi — TZ §7.4.3: «Qatorlar OFF · SB · DR · ON». */
export const DUTY_STATUS_ROWS: readonly DutyStatusCode[] = ['OFF', 'SB', 'DR', 'ON'];

/** Har status uchun rang tokeni (fe-design-system §1 semantik xaritasi). */
export const DUTY_STATUS_COLOR_VAR: Record<DutyStatusCode, string> = {
  OFF: 'var(--color-neutral-500)',
  SB: 'var(--color-decorative-purple)',
  DR: 'var(--color-success-base)',
  ON: 'var(--color-warning-base)',
};

/** Grid'ning bog'lovchi chizig'i rangi — TZ: «Chiziq rangi #466FF7». */
export const DUTY_GRID_LINE_COLOR_VAR = 'var(--color-decorative-blue)';
/** Qator ajratgichlar va o'q chizig'i. */
export const DUTY_GRID_STROKE_VAR = 'var(--color-stroke)';
/** Yorliq matnlari (soat o'qi, qator nomlari, jami). */
export const DUTY_GRID_LABEL_COLOR_VAR = 'var(--color-neutral-500)';
/** Fokus halqasi (klaviatura navigatsiyasi). */
export const DUTY_GRID_FOCUS_COLOR_VAR = 'var(--color-primary)';
/** PC/YM shtrix pattern chizig'i. */
export const DUTY_GRID_HATCH_COLOR_VAR = 'var(--color-neutral-700)';

/** Har hodisa turi uchun rang — shakl bilan birga ma'noni ikki marta kodlaydi (fe-a11y §3). */
export const DUTY_EVENT_COLOR_VAR: Record<DutyEventType, string> = {
  pti: 'var(--color-decorative-teal)',
  fuel: 'var(--color-decorative-orange)',
  certify: 'var(--color-success-base)',
  malfunction: 'var(--color-error-base)',
};

/**
 * Layout — SVG `viewBox` birliklari (px emas, nisbiy birlik;
 * `preserveAspectRatio` orqali konteyner kengligiga cho'ziladi).
 */
export const GRID_LAYOUT = {
  /** Chap ustun — qator nomlari (OFF/SB/DR/ON). */
  labelColWidth: 56,
  /** O'ng ustun — har qator jami (`HH:MM`). */
  totalColWidth: 64,
  /** Sutka kengligi — nominal 1440 (DST kunlarida ham shu kenglikka normallashadi). */
  dayWidth: 1440,
  /** Soat o'qi + hodisa markerlari uchun tepa maydon. */
  headerHeight: 36,
  /** Bitta status qatori balandligi. */
  rowHeight: 44,
  rows: 4,
} as const;

export const GRID_VIEWBOX_WIDTH =
  GRID_LAYOUT.labelColWidth + GRID_LAYOUT.dayWidth + GRID_LAYOUT.totalColWidth;
export const GRID_VIEWBOX_HEIGHT =
  GRID_LAYOUT.headerHeight + GRID_LAYOUT.rowHeight * GRID_LAYOUT.rows;

/** Halqa ohangi → rang tokeni (`HosRings`). */
export const HOS_RING_TONE_COLOR_VAR: Record<HosRingTone, string> = {
  warning: 'var(--color-warning-base)',
  success: 'var(--color-success-base)',
  info: 'var(--color-decorative-blue)',
  primary: 'var(--color-primary)',
  neutral: 'var(--color-neutral-400)',
};

/** Chegaraga yaqinlashganda ishlatiladigan ogohlantirish rangi. */
export const HOS_RING_NEAR_LIMIT_COLOR_VAR = 'var(--color-warning-base)';
/** Chegaradan oshganda ishlatiladigan xato rangi. */
export const HOS_RING_EXCEEDED_COLOR_VAR = 'var(--color-error-base)';
/** Halqa "iz" (track) fon rangi. */
export const HOS_RING_TRACK_COLOR_VAR = 'var(--color-neutral-200)';

/** Default chegara nisbati — bu HOS qoidasi emas, umumiy UI eshigi (0.2 = 20%). */
export const DEFAULT_WARN_THRESHOLD_RATIO = 0.2;
