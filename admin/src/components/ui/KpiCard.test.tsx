import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { KpiCard } from '@/components/ui/KpiCard';

describe('KpiCard', () => {
  it('renders label, value and delta', () => {
    render(
      <KpiCard label="Total Drivers" value={128} delta={{ value: '+4.2%', direction: 'up' }} />,
    );

    expect(screen.getByText('Total Drivers')).toBeInTheDocument();
    expect(screen.getByText('128')).toBeInTheDocument();
    expect(screen.getByText('+4.2%')).toBeInTheDocument();
  });

  it('shows a skeleton and marks the card busy while loading', () => {
    const { container } = render(<KpiCard label="Total Drivers" value={128} loading />);

    expect(screen.queryByText('128')).not.toBeInTheDocument();
    expect(container.querySelector('[aria-busy="true"]')).toBeInTheDocument();
  });
});
