import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { X } from 'lucide-react';
import { describe, expect, it, vi } from 'vitest';

import { IconButton } from './IconButton';

describe('IconButton', () => {
  it('exposes the required aria-label as the accessible name', () => {
    render(<IconButton icon={X} aria-label="Close" />);
    expect(screen.getByRole('button', { name: 'Close' })).toBeInTheDocument();
  });

  it('calls onClick when clicked', async () => {
    const onClick = vi.fn();
    render(<IconButton icon={X} aria-label="Close" onClick={onClick} />);
    await userEvent.click(screen.getByRole('button', { name: 'Close' }));
    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it('disables the button and shows a spinner while loading', () => {
    render(<IconButton icon={X} aria-label="Close" loading />);
    const button = screen.getByRole('button', { name: 'Close' });
    expect(button).toBeDisabled();
    expect(button).toHaveAttribute('aria-busy', 'true');
  });
});
