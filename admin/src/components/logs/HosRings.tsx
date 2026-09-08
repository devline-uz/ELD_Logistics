/**
 * HOS hisoblagichlari — 4 halqa (SVG qo'lda, `recharts` emas — TZ §2.1).
 *
 * **Sof komponent**: hech qanday HOS qoidasini bilmaydi va hisoblamaydi.
 * `remainingMinutes`/`limitMinutes` to'liq `hos-summary` javobidan keladi
 * (F98 — `CYCLE 65:00` kabi hech qanday raqam hardcode qilinmaydi).
 * Komponent faqat: (a) `remaining/limit` nisbatidan halqa foizini chizadi,
 * (b) nisbat berilgan `warnThresholdRatio` dan past bo'lsa yoki
 * `remainingMinutes <= 0` bo'lsa ogohlantirish rangini tanlaydi — bu UI
 * chegarasi, HOS qoidasi emas.
 */
import { formatDuration } from '@/lib/format';

import {
  HOS_RING_EXCEEDED_COLOR_VAR,
  HOS_RING_NEAR_LIMIT_COLOR_VAR,
  HOS_RING_TONE_COLOR_VAR,
  HOS_RING_TRACK_COLOR_VAR,
  DEFAULT_WARN_THRESHOLD_RATIO,
} from './constants';
import type { HosRingDatum, HosRingsProps } from './types';
import { cx } from './utils';

const RADIUS = 40;
const STROKE_WIDTH = 8;
const CIRCUMFERENCE = 2 * Math.PI * RADIUS;
const SIZE = (RADIUS + STROKE_WIDTH) * 2;

type RingState = 'normal' | 'near-limit' | 'exceeded' | 'unknown';

function resolveState(ring: HosRingDatum, warnThresholdRatio: number): RingState {
  if (ring.remainingMinutes === null || ring.limitMinutes === null || ring.limitMinutes <= 0) {
    return 'unknown';
  }
  if (ring.remainingMinutes <= 0) return 'exceeded';
  if (ring.remainingMinutes / ring.limitMinutes <= warnThresholdRatio) return 'near-limit';
  return 'normal';
}

function resolveColor(ring: HosRingDatum, state: RingState): string {
  if (state === 'exceeded') return HOS_RING_EXCEEDED_COLOR_VAR;
  if (state === 'near-limit') return HOS_RING_NEAR_LIMIT_COLOR_VAR;
  return HOS_RING_TONE_COLOR_VAR[ring.tone];
}

function ringAriaLabel(
  ring: HosRingDatum,
  state: RingState,
  labels: HosRingsProps['labels'],
): string {
  const remainingText =
    ring.remainingMinutes === null
      ? labels.unknown
      : `${formatDuration(ring.remainingMinutes)} ${labels.remainingSuffix}`;
  const statusText =
    state === 'exceeded'
      ? `, ${labels.exceeded}`
      : state === 'near-limit'
        ? `, ${labels.nearLimit}`
        : '';
  return `${ring.label}: ${remainingText}${statusText}`;
}

function Ring({
  ring,
  labels,
  warnThresholdRatio,
}: {
  ring: HosRingDatum;
  labels: HosRingsProps['labels'];
  warnThresholdRatio: number;
}) {
  const state = resolveState(ring, warnThresholdRatio);
  const color = resolveColor(ring, state);

  const usedRatio =
    state === 'unknown'
      ? 0
      : Math.min(
          1,
          Math.max(
            0,
            (ring.limitMinutes! - Math.max(ring.remainingMinutes!, 0)) / ring.limitMinutes!,
          ),
        );
  const dashOffset = CIRCUMFERENCE * (1 - usedRatio);

  const centerText =
    ring.remainingMinutes === null ? labels.unknown : formatDuration(ring.remainingMinutes);

  return (
    <div className="flex flex-col items-center gap-2">
      <svg
        role="img"
        aria-label={ringAriaLabel(ring, state, labels)}
        viewBox={`0 0 ${SIZE} ${SIZE}`}
        width={SIZE}
        height={SIZE}
        className="motion-safe:[&_circle]:transition-[stroke-dashoffset]"
      >
        <title>{ringAriaLabel(ring, state, labels)}</title>
        <circle
          cx={SIZE / 2}
          cy={SIZE / 2}
          r={RADIUS}
          fill="none"
          stroke={HOS_RING_TRACK_COLOR_VAR}
          strokeWidth={STROKE_WIDTH}
        />
        {state !== 'unknown' && (
          <circle
            cx={SIZE / 2}
            cy={SIZE / 2}
            r={RADIUS}
            fill="none"
            stroke={color}
            strokeWidth={STROKE_WIDTH}
            strokeLinecap="round"
            strokeDasharray={CIRCUMFERENCE}
            strokeDashoffset={dashOffset}
            transform={`rotate(-90 ${SIZE / 2} ${SIZE / 2})`}
          />
        )}
        <text
          x={SIZE / 2}
          y={SIZE / 2 - 6}
          textAnchor="middle"
          dominantBaseline="middle"
          fontSize={16}
          fontWeight={600}
          fill="var(--color-neutral-800)"
        >
          {centerText}
        </text>
        <text
          x={SIZE / 2}
          y={SIZE / 2 + 14}
          textAnchor="middle"
          dominantBaseline="middle"
          fontSize={10}
          fill="var(--color-neutral-500)"
        >
          {ring.label}
        </text>
      </svg>
      {state === 'near-limit' && (
        <span className="text-body-sm font-medium text-warning-dark">{labels.nearLimit}</span>
      )}
      {state === 'exceeded' && (
        <span className="text-body-sm font-medium text-error-dark">{labels.exceeded}</span>
      )}
    </div>
  );
}

export function HosRings({
  rings,
  labels,
  warnThresholdRatio = DEFAULT_WARN_THRESHOLD_RATIO,
  className,
}: HosRingsProps) {
  return (
    <div className={cx('flex flex-wrap items-start gap-6', className)}>
      {rings.map((ring) => (
        <Ring key={ring.id} ring={ring} labels={labels} warnThresholdRatio={warnThresholdRatio} />
      ))}
    </div>
  );
}

export default HosRings;
