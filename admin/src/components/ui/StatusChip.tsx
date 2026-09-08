export type StatusChipTone = 'neutral' | 'info' | 'success' | 'warning' | 'danger';

export interface StatusChipProps {
  /** Qisqartma — masalan `DR`/`OFF`/`SB`/`ON` (domen bilmaydi, chaqiruvchi beradi). */
  status: string;
  tone?: StatusChipTone;
  /** Skrin-rider/tooltip uchun to'liq matn (masalan «Driving»). */
  label?: string;
}

const TONE_CLASSES: Record<StatusChipTone, string> = {
  neutral: 'bg-neutral-100 text-neutral-700',
  info: 'bg-light text-decorative-blue',
  success: 'bg-success-bg text-success-dark',
  warning: 'bg-warning-bg text-warning-dark',
  danger: 'bg-error-bg text-error-dark',
};

/**
 * Duty status kabi domen holatlarini **bilmaydi** — `status` + `tone` prop
 * qabul qiladi (fe-design-system §1: rang xaritasini chaqiruvchi hal qiladi).
 */
export function StatusChip({ status, tone = 'neutral', label }: StatusChipProps) {
  return (
    <span
      className={`inline-flex items-center justify-center rounded-full px-2.5 py-0.5 text-body-sm font-semibold ${TONE_CLASSES[tone]}`}
      aria-label={label}
    >
      {status}
    </span>
  );
}

export default StatusChip;
