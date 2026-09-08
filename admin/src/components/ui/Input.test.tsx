import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import '@/app/i18n';
import { Input } from './Input';

describe('Input', () => {
  it('associates the label with the input', () => {
    render(<Input label="Unit number" />);
    expect(screen.getByLabelText('Unit number')).toBeInTheDocument();
  });

  it('fires onChange as the user types', async () => {
    const onChange = vi.fn();
    render(<Input label="Unit number" value="" onChange={onChange} />);
    await userEvent.type(screen.getByLabelText('Unit number'), 'A1');
    expect(onChange).toHaveBeenCalledTimes(2);
  });

  it('marks the input as invalid and links the error message', () => {
    render(<Input label="Unit number" error="Required field" />);
    const input = screen.getByLabelText('Unit number');
    expect(input).toHaveAttribute('aria-invalid', 'true');
    const errorId = input.getAttribute('aria-describedby');
    expect(errorId).toBeTruthy();
    expect(screen.getByRole('alert')).toHaveTextContent('Required field');
    expect(document.getElementById(errorId ?? '')).toHaveTextContent('Required field');
  });

  it('shows a remaining-characters counter when maxLength is set', () => {
    render(<Input label="Notes" value="Hi" maxLength={60} onChange={() => {}} />);
    expect(screen.getByText('58 characters remaining')).toBeInTheDocument();
  });
});
