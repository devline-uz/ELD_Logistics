import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { StatusChip } from '@/components/ui/StatusChip';

describe('StatusChip', () => {
  it('always shows the status code as text, not just color', () => {
    render(<StatusChip status="DR" tone="success" label="Driving" />);
    const chip = screen.getByText('DR');
    expect(chip).toHaveAccessibleName('Driving');
  });

  it('accepts every documented tone', () => {
    const tones = ['neutral', 'info', 'success', 'warning', 'danger'] as const;
    tones.forEach((tone) => {
      const { unmount } = render(<StatusChip status={tone.toUpperCase()} tone={tone} />);
      expect(screen.getByText(tone.toUpperCase())).toBeInTheDocument();
      unmount();
    });
  });
});
