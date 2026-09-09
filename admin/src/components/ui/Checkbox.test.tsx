import { createRef } from 'react';
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

  it('applies a muted style when disabled', () => {
    render(<Checkbox label="Accept" disabled />);
    expect(screen.getByRole('checkbox', { name: 'Accept' })).toBeDisabled();
  });

  it('forwards the DOM node via an object ref', () => {
    const ref = createRef<HTMLInputElement>();
    render(<Checkbox label="Accept" ref={ref} />);
    expect(ref.current).toBe(screen.getByRole('checkbox', { name: 'Accept' }));
  });

  it('forwards the DOM node via a callback ref', () => {
    const callback = vi.fn();
    render(<Checkbox label="Accept" ref={callback} />);
    expect(callback).toHaveBeenCalledWith(screen.getByRole('checkbox', { name: 'Accept' }));
  });

  it('renders with a description but no label', () => {
    render(<Checkbox description="Helper text" />);
    expect(screen.getByText('Helper text')).toBeInTheDocument();
    expect(screen.getByRole('checkbox')).toBeInTheDocument();
  });

  it('renders without a label or description', () => {
    render(<Checkbox />);
    const checkbox = screen.getByRole('checkbox');
    expect(checkbox).toBeInTheDocument();
    expect(checkbox.closest('label')?.querySelector('span.flex.flex-col')).toBeNull();
  });
});
