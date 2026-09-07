import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import { Checkbox } from './Checkbox';

describe('Checkbox', () => {
  it('renders a checkbox with label and description', () => {
    render(<Checkbox label="Notify me" description="Send an email on change" />);
    expect(screen.getByRole('checkbox', { name: 'Notify me' })).toBeInTheDocument();
    expect(screen.getByText('Send an email on change')).toBeInTheDocument();
  });

  it('toggles on click and calls onChange', async () => {
    const onChange = vi.fn();
    render(<Checkbox label="Notify me" onChange={onChange} />);
    await userEvent.click(screen.getByRole('checkbox', { name: 'Notify me' }));
    expect(onChange).toHaveBeenCalledTimes(1);
  });

  it('sets the indeterminate DOM property', () => {
    render(<Checkbox label="Select all" indeterminate />);
    const checkbox = screen.getByRole('checkbox', { name: 'Select all' });
    expect((checkbox as HTMLInputElement).indeterminate).toBe(true);
  });

  it('marks the field invalid and shows the error message', () => {
    render(<Checkbox label="Accept" error="Required" />);
    expect(screen.getByRole('checkbox', { name: 'Accept' })).toHaveAttribute(
      'aria-invalid',
      'true',
    );
    expect(screen.getByRole('alert')).toHaveTextContent('Required');
  });
});
