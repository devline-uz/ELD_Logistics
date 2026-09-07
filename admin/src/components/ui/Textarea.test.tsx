import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import '@/app/i18n';
import { Textarea } from './Textarea';

describe('Textarea', () => {
  it('associates the label with the textarea', () => {
    render(<Textarea label="Notes" />);
    expect(screen.getByLabelText('Notes')).toBeInTheDocument();
  });

  it('fires onChange as the user types', async () => {
    const onChange = vi.fn();
    render(<Textarea label="Notes" value="" onChange={onChange} />);
    await userEvent.type(screen.getByLabelText('Notes'), 'Hi');
    expect(onChange).toHaveBeenCalledTimes(2);
  });

  it('marks the textarea as invalid and links the error message', () => {
    render(<Textarea label="Notes" error="Too long" />);
    const textarea = screen.getByLabelText('Notes');
    expect(textarea).toHaveAttribute('aria-invalid', 'true');
    expect(screen.getByRole('alert')).toHaveTextContent('Too long');
  });

  it('shows a remaining-characters counter capped at maxLength 60', () => {
    render(<Textarea label="Notes" value="Hello" maxLength={60} onChange={() => {}} />);
    expect(screen.getByText('55 characters remaining')).toBeInTheDocument();
  });
});
