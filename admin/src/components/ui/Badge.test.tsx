import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { Badge } from '@/components/ui/Badge';

describe('Badge', () => {
  it('renders soft variant text', () => {
    render(<Badge tone="success">Completed</Badge>);
    expect(screen.getByText('Completed')).toBeInTheDocument();
  });

  it('renders a dot variant with a hidden decorative dot', () => {
    const { container } = render(
      <Badge tone="neutral" variant="dot">
        Offline
      </Badge>,
    );
    expect(screen.getByText('Offline')).toBeInTheDocument();
    const dot = container.querySelector('[aria-hidden="true"]');
    expect(dot).toBeInTheDocument();
  });
});
