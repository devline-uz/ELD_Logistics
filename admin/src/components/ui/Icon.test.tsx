import { render, screen } from '@testing-library/react';
import { Check } from 'lucide-react';
import { describe, expect, it } from 'vitest';

import { Icon } from './Icon';

describe('Icon', () => {
  it('is hidden from screen readers when no label is given (decorative)', () => {
    const { container } = render(<Icon icon={Check} />);
    const svg = container.querySelector('svg');
    expect(svg).toHaveAttribute('aria-hidden', 'true');
  });

  it('exposes an accessible name when a label is given', () => {
    render(<Icon icon={Check} label="Completed" />);
    expect(screen.getByRole('img', { name: 'Completed' })).toBeInTheDocument();
  });

  it('applies the requested size', () => {
    const { container } = render(<Icon icon={Check} size={32} />);
    const svg = container.querySelector('svg');
    expect(svg).toHaveAttribute('width', '32');
    expect(svg).toHaveAttribute('height', '32');
  });
});
