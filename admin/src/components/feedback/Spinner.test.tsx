import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import '@/app/i18n';
import { Spinner } from '@/components/feedback/Spinner';

describe('Spinner', () => {
  it('exposes a status role with an accessible loading label', () => {
    render(<Spinner />);
    expect(screen.getByRole('status')).toHaveTextContent('Loading');
  });

  it('accepts a custom label', () => {
    render(<Spinner label="Preparing your file…" />);
    expect(screen.getByRole('status')).toHaveTextContent('Preparing your file…');
  });

  it('wraps in a centered container when fullScreen', () => {
    const { container } = render(<Spinner fullScreen />);
    expect(container.querySelector('.min-h-\\[12rem\\]')).toBeInTheDocument();
  });
});
