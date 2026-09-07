import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import { Switch } from './Switch';

describe('Switch', () => {
  it('renders with role switch and its label', () => {
    render(<Switch label="Enable notifications" />);
    expect(screen.getByRole('switch', { name: 'Enable notifications' })).toBeInTheDocument();
  });

  it('toggles when clicked', async () => {
    const onChange = vi.fn();
    render(<Switch label="Enable notifications" onChange={onChange} />);
    await userEvent.click(screen.getByRole('switch', { name: 'Enable notifications' }));
    expect(onChange).toHaveBeenCalledTimes(1);
  });

  it('toggles with the keyboard (space)', async () => {
    const onChange = vi.fn();
    render(<Switch label="Enable notifications" onChange={onChange} />);
    const el = screen.getByRole('switch', { name: 'Enable notifications' });
    el.focus();
    await userEvent.keyboard(' ');
    expect(onChange).toHaveBeenCalledTimes(1);
  });
});
