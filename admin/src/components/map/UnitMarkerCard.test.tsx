import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';

import '@/app/i18n';

import { UnitMarkerCard } from './UnitMarkerCard';

function renderCard(onViewTracking = vi.fn()) {
  render(
    <UnitMarkerCard
      driverName="John Doe"
      dutyStatus="DR"
      dutyStatusTone="success"
      unitNumber="1021"
      odometer="120.5 mi"
      location="Dallas, TX"
      hasCoordinates
      relativeTime="2 minutes ago"
      onlineTone="success"
      onlineLabel="Online"
      onViewTracking={onViewTracking}
    />,
  );
  return onViewTracking;
}

describe('UnitMarkerCard', () => {
  it('driver, status va unit maʻlumotlarini koʻrsatadi', () => {
    renderCard();

    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('DR')).toBeInTheDocument();
    expect(screen.getByText('1021')).toBeInTheDocument();
    expect(screen.getByText('120.5 mi')).toBeInTheDocument();
    expect(screen.getByText('Dallas, TX')).toBeInTheDocument();
  });

  it('"View Tracking" bosilganda onViewTracking chaqiriladi', () => {
    const onViewTracking = renderCard();

    fireEvent.click(screen.getByRole('button', { name: /view tracking/i }));

    expect(onViewTracking).toHaveBeenCalledTimes(1);
  });
});
