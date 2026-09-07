import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { HosRings } from './HosRings';
import type { HosRingDatum, HosRingsLabels } from './types';

const labels: HosRingsLabels = {
  unknown: 'N/A',
  nearLimit: 'Near limit',
  exceeded: 'Limit exceeded',
  remainingSuffix: 'remaining',
};

function buildRings(overrides: Partial<HosRingDatum>[]): HosRingDatum[] {
  const base: HosRingDatum[] = [
    { id: 'break', label: 'BREAK', remainingMinutes: 180, limitMinutes: 480, tone: 'warning' },
    { id: 'drive', label: 'DRIVE', remainingMinutes: 420, limitMinutes: 660, tone: 'success' },
    { id: 'shift', label: 'SHIFT', remainingMinutes: 540, limitMinutes: 840, tone: 'info' },
    { id: 'cycle', label: 'CYCLE', remainingMinutes: 3600, limitMinutes: 4200, tone: 'primary' },
  ];
  return base.map((ring, index) => ({ ...ring, ...overrides[index] }));
}

describe('HosRings', () => {
  it('renders one role="img" ring per datum with an aria-label carrying the remaining time', () => {
    render(<HosRings rings={buildRings([{}, {}, {}, {}])} labels={labels} />);
    const break_ = screen.getByRole('img', { name: /BREAK: 03:00 remaining/ });
    expect(break_).toBeInTheDocument();
    expect(screen.getByText('BREAK')).toBeInTheDocument();
    expect(screen.getByText('03:00')).toBeInTheDocument();
  });

  it('never hardcodes an HOS limit — a ring with an unknown limit renders indeterminate, not a fake full/empty arc', () => {
    const { container } = render(
      <HosRings
        rings={[
          {
            id: 'cycle',
            label: 'CYCLE',
            remainingMinutes: null,
            limitMinutes: null,
            tone: 'primary',
          },
        ]}
        labels={labels}
      />,
    );
    expect(screen.getByRole('img', { name: /CYCLE: N\/A/ })).toBeInTheDocument();
    // Only the neutral "track" circle is drawn — no colored progress arc invented from nothing.
    expect(container.querySelectorAll('circle')).toHaveLength(1);
  });

  it('renders the known remaining value even when the limit is 0/unset, without drawing a progress arc', () => {
    const { container } = render(
      <HosRings
        rings={[
          { id: 'cycle', label: 'CYCLE', remainingMinutes: 0, limitMinutes: 0, tone: 'primary' },
        ]}
        labels={labels}
      />,
    );
    expect(screen.getByRole('img', { name: /CYCLE: 00:00 remaining/ })).toBeInTheDocument();
    expect(container.querySelectorAll('circle')).toHaveLength(1);
  });

  it('renders a full ring (remaining === limit) without a warning', () => {
    render(
      <HosRings
        rings={[
          {
            id: 'drive',
            label: 'DRIVE',
            remainingMinutes: 660,
            limitMinutes: 660,
            tone: 'success',
          },
        ]}
        labels={labels}
      />,
    );
    expect(screen.getByRole('img', { name: /DRIVE: 11:00 remaining$/ })).toBeInTheDocument();
    expect(screen.queryByText('Near limit')).not.toBeInTheDocument();
    expect(screen.queryByText('Limit exceeded')).not.toBeInTheDocument();
  });

  it('shows a near-limit warning once remaining drops under the threshold ratio', () => {
    render(
      <HosRings
        rings={[
          { id: 'break', label: 'BREAK', remainingMinutes: 50, limitMinutes: 480, tone: 'warning' },
        ]}
        labels={labels}
        warnThresholdRatio={0.2}
      />,
    );
    expect(screen.getByText('Near limit')).toBeInTheDocument();
    expect(screen.getByRole('img', { name: /Near limit/ })).toBeInTheDocument();
  });

  it('shows an exceeded warning once remaining is zero or negative, using formatDuration sign', () => {
    render(
      <HosRings
        rings={[
          {
            id: 'cycle',
            label: 'CYCLE',
            remainingMinutes: -30,
            limitMinutes: 4200,
            tone: 'primary',
          },
        ]}
        labels={labels}
      />,
    );
    expect(screen.getByText('Limit exceeded')).toBeInTheDocument();
    expect(screen.getByText('-00:30')).toBeInTheDocument();
  });

  it('renders zero-value rings (0 remaining out of a limit) as exceeded, not a crash', () => {
    render(
      <HosRings
        rings={[
          { id: 'break', label: 'BREAK', remainingMinutes: 0, limitMinutes: 480, tone: 'warning' },
        ]}
        labels={labels}
      />,
    );
    expect(screen.getByText('Limit exceeded')).toBeInTheDocument();
  });

  it('does not know or invent HOS limit numbers — nothing in the DOM mentions 660/480/840/4200 unless passed in', () => {
    render(<HosRings rings={buildRings([{}, {}, {}, {}])} labels={labels} />);
    // The component only ever renders the *remaining* time, formatted — never the raw limitMinutes value.
    expect(screen.queryByText('4200')).not.toBeInTheDocument();
    expect(screen.queryByText('70:00')).not.toBeInTheDocument();
  });
});
