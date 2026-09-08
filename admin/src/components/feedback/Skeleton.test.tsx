import { render } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { Skeleton } from '@/components/feedback/Skeleton';

describe('Skeleton', () => {
  it('is hidden from assistive technology', () => {
    const { container } = render(<Skeleton />);
    expect(container.firstChild).toHaveAttribute('aria-hidden', 'true');
  });

  it('renders the requested number of blocks', () => {
    const { container } = render(<Skeleton variant="table-row" count={5} />);
    expect(container.querySelectorAll(':scope > div > div')).toHaveLength(5);
  });

  it('only animates via the motion-safe variant', () => {
    const { container } = render(<Skeleton variant="card" />);
    const block = container.querySelector('[aria-hidden="true"] > div');
    expect(block?.className).toContain('motion-safe:animate-pulse');
  });
});
