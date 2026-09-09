/**
 * 24 soatlik duty-status grid — klassik "paper log" uslubida: 4 qator
 * (OFF/SB/DR/ON), qatorlar orasida sakraydigan bog'lovchi chiziq, PC/YM
 * uchun shtrix pattern, hodisa markerlari (`pti`/`fuel`/`certify`/
 * `malfunction`) va hover/fokus tooltip (TZ §7.4.3, F99).
 *
 * **Sof komponent** — hech qanday query chaqirmaydi, hech qanday HOS
 * qoidasini bilmaydi. Barcha ma'lumot va matn props orqali keladi.
 *
 * Koordinata tizimi: `utils.ts` da tasvirlangan — vaqt "kun boshidan
 * o'tgan daqiqa"ga aylantiriladi (epoch farqi orqali), shuning uchun DST
 * kuni (23/25 soatlik sutka) avtomatik to'g'ri ishlaydi, faqat butun kun
 * `GRID_LAYOUT.dayWidth` ga normallashtiriladi.
 */
import { useId, useMemo, useState } from 'react';

import { formatDuration } from '@/lib/format';

import {
  DUTY_EVENT_COLOR_VAR,
  DUTY_GRID_HATCH_COLOR_VAR,
  DUTY_GRID_LABEL_COLOR_VAR,
  DUTY_GRID_LINE_COLOR_VAR,
  DUTY_GRID_STROKE_VAR,
  DUTY_STATUS_COLOR_VAR,
  DUTY_STATUS_ROWS,
  GRID_LAYOUT,
  GRID_VIEWBOX_HEIGHT,
  GRID_VIEWBOX_WIDTH,
} from './constants';
import type { DutyEventType, DutyGridProps } from './types';
import {
  buildStaircasePath,
  clipSegmentsToDay,
  computeDayBounds,
  computeHourTicks,
  computeRowTotals,
  cx,
  formatClockTime,
  positionEvents,
  rowIndexForStatus,
  xForMinute,
  yForRow,
} from './utils';

interface TooltipState {
  x: number;
  y: number;
  lines: string[];
}

const MARKER_SIZE = 5;

function EventShape({ type, color }: { type: DutyEventType; color: string }) {
  switch (type) {
    case 'pti':
      return <circle r={MARKER_SIZE} fill={color} />;
    case 'fuel':
      return (
        <polygon
          points={`0,-${MARKER_SIZE} ${MARKER_SIZE},${MARKER_SIZE} -${MARKER_SIZE},${MARKER_SIZE}`}
          fill={color}
        />
      );
    case 'certify':
      return (
        <polygon
          points={`0,-${MARKER_SIZE} ${MARKER_SIZE},0 0,${MARKER_SIZE} -${MARKER_SIZE},0`}
          fill={color}
        />
      );
    case 'malfunction':
      return (
        <rect
          x={-MARKER_SIZE}
          y={-MARKER_SIZE}
          width={MARKER_SIZE * 2}
          height={MARKER_SIZE * 2}
          fill={color}
        />
      );
    default:
      return null;
  }
}

export function DutyGrid({
  date,
  timezone,
  segments,
  events = [],
  labels,
  className,
}: DutyGridProps) {
  const hatchId = useId();
  const [tooltip, setTooltip] = useState<TooltipState | null>(null);

  const bounds = useMemo(() => computeDayBounds(date, timezone), [date, timezone]);
  const clipped = useMemo(() => clipSegmentsToDay(segments, bounds), [segments, bounds]);
  const positionedEvents = useMemo(() => positionEvents(events, bounds), [events, bounds]);
  const hourTicks = useMemo(
    () => computeHourTicks(date, timezone, bounds),
    [date, timezone, bounds],
  );
  const staircasePath = useMemo(() => buildStaircasePath(clipped, bounds), [clipped, bounds]);
  const rowTotals = useMemo(() => computeRowTotals(clipped), [clipped]);
  const totalMinutes = DUTY_STATUS_ROWS.reduce((sum, status) => sum + rowTotals[status], 0);

  const isEmpty = clipped.length === 0;

  const segmentLabel = (segment: (typeof clipped)[number]['segment']): string => {
    const parts = [labels.statusRow[segment.status]];
    if (segment.special && segment.special !== 'none') {
      parts.push(labels.special[segment.special]);
    }
    parts.push(
      `${formatClockTime(segment.startTime, timezone)} – ${formatClockTime(segment.endTime, timezone)}`,
    );
    if (segment.locationText) parts.push(segment.locationText);
    if (segment.note) parts.push(segment.note);
    return parts.join(', ');
  };

  const eventLabel = (event: (typeof positionedEvents)[number]['event']): string => {
    const parts = [labels.eventType[event.type], formatClockTime(event.time, timezone)];
    if (event.note) parts.push(event.note);
    return parts.join(', ');
  };

  const showSegmentTooltip = (
    segment: (typeof clipped)[number]['segment'],
    startMin: number,
    endMin: number,
  ) => {
    const x = (xForMinute(startMin, bounds) + xForMinute(endMin, bounds)) / 2;
    const y = yForRow(rowIndexForStatus(segment.status)) - GRID_LAYOUT.rowHeight / 2 - 4;
    const lines = [
      segment.special && segment.special !== 'none'
        ? `${labels.statusRow[segment.status]} (${labels.special[segment.special]})`
        : labels.statusRow[segment.status],
      `${formatClockTime(segment.startTime, timezone)} – ${formatClockTime(segment.endTime, timezone)}`,
    ];
    if (segment.locationText) lines.push(segment.locationText);
    if (segment.note) lines.push(segment.note);
    setTooltip({ x, y, lines });
  };

  const showEventTooltip = (
    event: (typeof positionedEvents)[number]['event'],
    minute: number,
    clusterIndex: number,
  ) => {
    const x = xForMinute(minute, bounds);
    const y = GRID_LAYOUT.headerHeight / 2 - clusterIndex * 10 - 8;
    const lines = [labels.eventType[event.type], formatClockTime(event.time, timezone)];
    if (event.note) lines.push(event.note);
    setTooltip({ x, y, lines });
  };

  const hideTooltip = () => setTooltip(null);

  const tooltipWidth = tooltip ? Math.max(...tooltip.lines.map((l) => l.length)) * 5.5 + 12 : 0;
  const tooltipX = tooltip
    ? Math.min(Math.max(tooltip.x - tooltipWidth / 2, 2), GRID_VIEWBOX_WIDTH - tooltipWidth - 2)
    : 0;
  const tooltipHeight = tooltip ? tooltip.lines.length * 12 + 8 : 0;
  const tooltipY = tooltip ? Math.max(tooltip.y - tooltipHeight, 0) : 0;

  return (
    <div className={cx('w-full', className)}>
      <svg
        role="img"
        aria-label={labels.gridAriaLabel}
        viewBox={`0 0 ${GRID_VIEWBOX_WIDTH} ${GRID_VIEWBOX_HEIGHT}`}
        preserveAspectRatio="xMidYMid meet"
        className="h-auto w-full"
      >
        <title>{labels.gridAriaLabel}</title>
        <defs>
          <pattern
            id={hatchId}
            width={6}
            height={6}
            patternTransform="rotate(45)"
            patternUnits="userSpaceOnUse"
          >
            <line x1={0} y1={0} x2={0} y2={6} stroke={DUTY_GRID_HATCH_COLOR_VAR} strokeWidth={2} />
          </pattern>
        </defs>

        {/* Qator fonlari, ajratgichlar va nomlari */}
        {DUTY_STATUS_ROWS.map((status, rowIndex) => {
          const top = GRID_LAYOUT.headerHeight + rowIndex * GRID_LAYOUT.rowHeight;
          return (
            <g key={status}>
              <rect
                x={GRID_LAYOUT.labelColWidth}
                y={top}
                width={GRID_LAYOUT.dayWidth}
                height={GRID_LAYOUT.rowHeight}
                fill="none"
                stroke={DUTY_GRID_STROKE_VAR}
                strokeWidth={1}
              />
              <text
                x={GRID_LAYOUT.labelColWidth - 6}
                y={top + GRID_LAYOUT.rowHeight / 2}
                textAnchor="end"
                dominantBaseline="middle"
                fontSize={11}
                fill={DUTY_GRID_LABEL_COLOR_VAR}
              >
                {labels.statusRow[status]}
              </text>
              <text
                x={GRID_LAYOUT.labelColWidth + GRID_LAYOUT.dayWidth + 8}
                y={top + GRID_LAYOUT.rowHeight / 2}
                textAnchor="start"
                dominantBaseline="middle"
                fontSize={11}
                fill={DUTY_GRID_LABEL_COLOR_VAR}
              >
                {formatDuration(rowTotals[status])}
              </text>
            </g>
          );
        })}

        {/* Soat o'qi */}
        {hourTicks.map(({ hour, x }) => (
          <g key={hour}>
            <line
              x1={x}
              y1={GRID_LAYOUT.headerHeight}
              x2={x}
              y2={GRID_VIEWBOX_HEIGHT}
              stroke={DUTY_GRID_STROKE_VAR}
              strokeWidth={hour % 6 === 0 ? 1 : 0.5}
            />
            {hour % 2 === 0 && hour < 24 && (
              <text
                x={x}
                y={GRID_LAYOUT.headerHeight - 6}
                textAnchor="middle"
                fontSize={9}
                fill={DUTY_GRID_LABEL_COLOR_VAR}
              >
                {String(hour).padStart(2, '0')}
              </text>
            )}
          </g>
        ))}

        {isEmpty ? (
          <text
            x={GRID_LAYOUT.labelColWidth + GRID_LAYOUT.dayWidth / 2}
            y={GRID_LAYOUT.headerHeight + (GRID_LAYOUT.rowHeight * GRID_LAYOUT.rows) / 2}
            textAnchor="middle"
            dominantBaseline="middle"
            fontSize={12}
            fill={DUTY_GRID_LABEL_COLOR_VAR}
          >
            {labels.emptyState}
          </text>
        ) : (
          <>
            {/* Bog'lovchi "paper log" chizig'i */}
            <path d={staircasePath} fill="none" stroke={DUTY_GRID_LINE_COLOR_VAR} strokeWidth={2} />

            {/* Har segment uchun interaktiv hit-area + PC/YM shtrix */}
            {clipped.map(({ segment, startMin, endMin }, index) => {
              const rowIndex = rowIndexForStatus(segment.status);
              const top = GRID_LAYOUT.headerHeight + rowIndex * GRID_LAYOUT.rowHeight;
              const x1 = xForMinute(startMin, bounds);
              const x2 = xForMinute(endMin, bounds);
              const isSpecial = segment.special && segment.special !== 'none';
              return (
                <rect
                  key={`segment-${index}`}
                  x={x1}
                  y={top + 6}
                  width={Math.max(x2 - x1, 0.5)}
                  height={GRID_LAYOUT.rowHeight - 12}
                  fill={isSpecial ? `url(#${hatchId})` : 'transparent'}
                  stroke={isSpecial ? DUTY_STATUS_COLOR_VAR[segment.status] : 'none'}
                  strokeWidth={isSpecial ? 1 : 0}
                  tabIndex={0}
                  role="img"
                  aria-label={segmentLabel(segment)}
                  className="cursor-pointer outline-none focus-visible:outline focus-visible:outline-2 focus-visible:outline-primary"
                  onMouseEnter={() => showSegmentTooltip(segment, startMin, endMin)}
                  onMouseLeave={hideTooltip}
                  onFocus={() => showSegmentTooltip(segment, startMin, endMin)}
                  onBlur={hideTooltip}
                />
              );
            })}

            {/* Hodisa markerlari */}
            {positionedEvents.map(({ event, minute, clusterIndex }, index) => {
              if (minute === null) return null;
              const x = xForMinute(minute, bounds);
              const y = GRID_LAYOUT.headerHeight / 2 - clusterIndex * 10;
              const color = DUTY_EVENT_COLOR_VAR[event.type];
              return (
                <g
                  key={`event-${index}`}
                  transform={`translate(${x}, ${y})`}
                  tabIndex={0}
                  role="img"
                  aria-label={eventLabel(event)}
                  className="cursor-pointer outline-none focus-visible:outline focus-visible:outline-2 focus-visible:outline-primary"
                  onMouseEnter={() => showEventTooltip(event, minute, clusterIndex)}
                  onMouseLeave={hideTooltip}
                  onFocus={() => showEventTooltip(event, minute, clusterIndex)}
                  onBlur={hideTooltip}
                >
                  <EventShape type={event.type} color={color} />
                </g>
              );
            })}
          </>
        )}

        {tooltip && (
          <g className="motion-safe:transition-opacity" pointerEvents="none">
            <rect
              x={tooltipX}
              y={tooltipY}
              width={tooltipWidth}
              height={tooltipHeight}
              rx={4}
              fill="var(--color-neutral-800)"
            />
            {tooltip.lines.map((line, i) => (
              <text
                key={i}
                x={tooltipX + 6}
                y={tooltipY + 14 + i * 12}
                fontSize={10}
                fill="var(--color-surface)"
              >
                {line}
              </text>
            ))}
          </g>
        )}
      </svg>

      <p className="mt-1 text-body-sm text-neutral-600">
        {labels.total}: {formatDuration(totalMinutes)}
      </p>

      <SegmentsTableFallback
        clipped={clipped}
        events={positionedEvents}
        timezone={timezone}
        labels={labels}
      />
    </div>
  );
}

/**
 * Skrin-rider uchun jadval ekvivalenti — grid vizual bo'lgani uchun
 * SVG'dagi rect/marker'larni navigatsiya qilish og'ir; shu jadval barcha
 * segment/hodisalarni oddiy `<table>` tartibida beradi (fe-a11y §1/§2).
 */
function SegmentsTableFallback({
  clipped,
  events,
  timezone,
  labels,
}: {
  clipped: ReturnType<typeof clipSegmentsToDay>;
  events: ReturnType<typeof positionEvents>;
  timezone: string;
  labels: DutyGridProps['labels'];
}) {
  return (
    <div className="sr-only">
      <table>
        <caption>{labels.segmentsTableCaption}</caption>
        <thead>
          <tr>
            <th scope="col">{labels.columnStatus}</th>
            <th scope="col">{labels.columnFrom}</th>
            <th scope="col">{labels.columnTo}</th>
            <th scope="col">{labels.columnDuration}</th>
            <th scope="col">{labels.columnNote}</th>
          </tr>
        </thead>
        <tbody>
          {clipped.map(({ segment, startMin, endMin }, index) => (
            <tr key={index}>
              <td>
                {labels.statusRow[segment.status]}
                {segment.special && segment.special !== 'none'
                  ? ` (${labels.special[segment.special]})`
                  : ''}
              </td>
              <td>{formatClockTime(segment.startTime, timezone)}</td>
              <td>{formatClockTime(segment.endTime, timezone)}</td>
              <td>{formatDuration(endMin - startMin)}</td>
              <td>{[segment.locationText, segment.note].filter(Boolean).join(' — ')}</td>
            </tr>
          ))}
        </tbody>
      </table>

      <table>
        <caption>{labels.eventsTableCaption}</caption>
        <thead>
          <tr>
            <th scope="col">{labels.columnEvent}</th>
            <th scope="col">{labels.columnTime}</th>
            <th scope="col">{labels.columnNote}</th>
          </tr>
        </thead>
        <tbody>
          {events.map(({ event }, index) => (
            <tr key={index}>
              <td>{labels.eventType[event.type]}</td>
              <td>{formatClockTime(event.time, timezone)}</td>
              <td>{event.note ?? ''}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default DutyGrid;
