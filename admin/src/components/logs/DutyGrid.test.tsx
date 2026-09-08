import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { DutyGrid } from './DutyGrid';
import type { DutyEventMarker, DutyGridLabels, DutySegment } from './types';

const labels: DutyGridLabels = {
  statusRow: { OFF: 'OFF', SB: 'SB', DR: 'DR', ON: 'ON' },
  special: { pc: 'Personal Conveyance', ym: 'Yard Move' },
  eventType: {
    pti: 'PTI',
    fuel: 'Fuel',
    certify: 'Certify',
    malfunction: 'Malfunction',
  },
  total: 'Total',
  gridAriaLabel: '24-hour duty status grid for 2026-09-06',
  segmentsTableCaption: 'Duty status segments',
  columnStatus: 'Status',
  columnFrom: 'From',
  columnTo: 'To',
  columnDuration: 'Duration',
  columnNote: 'Note',
  eventsTableCaption: 'Events',
  columnEvent: 'Event',
  columnTime: 'Time',
  emptyState: 'No duty status recorded for this day.',
};

const TZ = 'America/Chicago';
const DATE = '2026-09-06';

/** Realistik kun: OFF -> SB -> DR -> ON(YM) -> DR -> OFF(PC) -> OFF. */
const REALISTIC_SEGMENTS: DutySegment[] = [
  { status: 'OFF', startTime: '2026-09-06T05:00:00Z', endTime: '2026-09-06T12:00:00Z' },
  { status: 'SB', startTime: '2026-09-06T12:00:00Z', endTime: '2026-09-06T13:00:00Z' },
  { status: 'DR', startTime: '2026-09-06T13:00:00Z', endTime: '2026-09-06T18:00:00Z' },
  {
    status: 'ON',
    special: 'ym',
    startTime: '2026-09-06T18:00:00Z',
    endTime: '2026-09-06T18:30:00Z',
    note: 'Yard shuffle',
  },
  { status: 'DR', startTime: '2026-09-06T18:30:00Z', endTime: '2026-09-06T21:00:00Z' },
  {
    status: 'OFF',
    special: 'pc',
    startTime: '2026-09-06T21:00:00Z',
    endTime: '2026-09-06T23:00:00Z',
    locationText: 'Home terminal',
  },
  { status: 'OFF', startTime: '2026-09-06T23:00:00Z', endTime: '2026-09-07T05:00:00Z' },
];

const REALISTIC_EVENTS: DutyEventMarker[] = [
  { type: 'pti', time: '2026-09-06T12:55:00Z', note: 'Pre-trip inspection' },
  { type: 'fuel', time: '2026-09-06T17:00:00Z' },
  { type: 'certify', time: '2026-09-06T23:00:00Z' },
  { type: 'malfunction', time: '2026-09-06T13:05:00Z', note: 'GPS signal lost' },
];

describe('DutyGrid — golden snapshot', () => {
  it('renders a stable SVG for a realistic day (segments + PC/YM + all 4 event types)', () => {
    const { container } = render(
      <DutyGrid
        date={DATE}
        timezone={TZ}
        segments={REALISTIC_SEGMENTS}
        events={REALISTIC_EVENTS}
        labels={labels}
      />,
    );
    expect(container.innerHTML).toMatchSnapshot();
  });
});

describe('DutyGrid — edge cases', () => {
  it('renders an empty day without crashing and shows the empty-state message', () => {
    render(<DutyGrid date={DATE} timezone={TZ} segments={[]} labels={labels} />);
    expect(screen.getByText('No duty status recorded for this day.')).toBeInTheDocument();
    expect(screen.getByText('Total: 00:00')).toBeInTheDocument();
  });

  it('renders a single segment spanning the entire day', () => {
    const segments: DutySegment[] = [
      {
        status: 'OFF',
        startTime: '2026-09-06T00:00:00-05:00',
        endTime: '2026-09-07T00:00:00-05:00',
      },
    ];
    render(<DutyGrid date={DATE} timezone={TZ} segments={segments} labels={labels} />);
    expect(screen.getByText('Total: 24:00')).toBeInTheDocument();
  });

  it('clips a segment that crosses midnight into the previous/next day', () => {
    const segments: DutySegment[] = [
      // Started the previous calendar day, ends 2h into this one.
      {
        status: 'SB',
        startTime: '2026-09-05T22:00:00-05:00',
        endTime: '2026-09-06T02:00:00-05:00',
      },
      // Starts 22h in, continues into the next calendar day — clipped at day end.
      {
        status: 'OFF',
        startTime: '2026-09-06T22:00:00-05:00',
        endTime: '2026-09-07T04:00:00-05:00',
      },
    ];
    render(<DutyGrid date={DATE} timezone={TZ} segments={segments} labels={labels} />);
    // SB clipped to 2h (00:00-02:00), OFF clipped to 2h (22:00-24:00) — 4h accounted, not the raw 4h+6h.
    expect(screen.getByText('Total: 04:00')).toBeInTheDocument();
  });

  it('renders overlapping events at (near) the same instant without crashing', () => {
    const events: DutyEventMarker[] = [
      { type: 'pti', time: '2026-09-06T12:00:00Z' },
      { type: 'fuel', time: '2026-09-06T12:00:00Z' },
      { type: 'malfunction', time: '2026-09-06T12:01:00Z' },
    ];
    const segments: DutySegment[] = [
      { status: 'DR', startTime: '2026-09-06T05:00:00Z', endTime: '2026-09-06T20:00:00Z' },
    ];
    render(
      <DutyGrid date={DATE} timezone={TZ} segments={segments} events={events} labels={labels} />,
    );
    expect(screen.getAllByRole('img', { name: /PTI|Fuel|Malfunction/ })).toHaveLength(3);
  });

  it('handles a 23-hour DST spring-forward day without NaN coordinates', () => {
    // America/Chicago: 2026-03-08 is a spring-forward day (23h).
    const segments: DutySegment[] = [
      { status: 'OFF', startTime: '2026-03-08T06:00:00Z', endTime: '2026-03-09T06:00:00Z' },
    ];
    const { container } = render(
      <DutyGrid date="2026-03-08" timezone={TZ} segments={segments} labels={labels} />,
    );
    expect(container.querySelector('svg')).not.toBeNull();
    expect(container.innerHTML).not.toContain('NaN');
    expect(screen.getByText('Total: 23:00')).toBeInTheDocument();
  });

  it('handles a 25-hour DST fall-back day without NaN coordinates', () => {
    // America/Chicago: 2026-11-01 is a fall-back day (25h).
    const segments: DutySegment[] = [
      { status: 'OFF', startTime: '2026-11-01T05:00:00Z', endTime: '2026-11-02T06:00:00Z' },
    ];
    const { container } = render(
      <DutyGrid date="2026-11-01" timezone={TZ} segments={segments} labels={labels} />,
    );
    expect(container.querySelector('svg')).not.toBeNull();
    expect(container.innerHTML).not.toContain('NaN');
    expect(screen.getByText('Total: 25:00')).toBeInTheDocument();
  });
});

describe('DutyGrid — a11y', () => {
  it('exposes role="img" with a descriptive aria-label on the grid', () => {
    render(<DutyGrid date={DATE} timezone={TZ} segments={REALISTIC_SEGMENTS} labels={labels} />);
    expect(
      screen.getByRole('img', { name: '24-hour duty status grid for 2026-09-06' }),
    ).toBeInTheDocument();
  });

  it('exposes a sr-only table equivalent listing every segment', () => {
    render(<DutyGrid date={DATE} timezone={TZ} segments={REALISTIC_SEGMENTS} labels={labels} />);
    const table = screen.getByText('Duty status segments').closest('table');
    expect(table).not.toBeNull();
    expect(screen.getByRole('columnheader', { name: 'Status' })).toBeInTheDocument();
    // +1 for the header row; scoped to this table so the (empty) events table doesn't count.
    expect(table && within(table).getAllByRole('row')).toHaveLength(REALISTIC_SEGMENTS.length + 1);
  });

  it('exposes a sr-only events table', () => {
    render(
      <DutyGrid
        date={DATE}
        timezone={TZ}
        segments={REALISTIC_SEGMENTS}
        events={REALISTIC_EVENTS}
        labels={labels}
      />,
    );
    expect(screen.getByText('Events').closest('table')).not.toBeNull();
    expect(screen.getByRole('columnheader', { name: 'Event' })).toBeInTheDocument();
  });

  it('makes every segment keyboard-focusable with a full descriptive aria-label', () => {
    render(<DutyGrid date={DATE} timezone={TZ} segments={REALISTIC_SEGMENTS} labels={labels} />);
    const pcSegment = screen.getByRole('img', { name: /Personal Conveyance/ });
    expect(pcSegment.tabIndex).toBe(0);
    expect(pcSegment.getAttribute('aria-label')).toContain('Home terminal');
  });

  it('gives each event marker a distinct, descriptive aria-label', () => {
    render(
      <DutyGrid
        date={DATE}
        timezone={TZ}
        segments={REALISTIC_SEGMENTS}
        events={REALISTIC_EVENTS}
        labels={labels}
      />,
    );
    expect(screen.getByRole('img', { name: /^PTI/ })).toBeInTheDocument();
    expect(screen.getByRole('img', { name: /^Malfunction/ })).toBeInTheDocument();
  });
});
