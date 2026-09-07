import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import { Radio } from './Radio';

describe('Radio', () => {
  it('renders a radio input with its label', () => {
    render(<Radio name="profile" label="Metric" />);
    expect(screen.getByRole('radio', { name: 'Metric' })).toBeInTheDocument();
  });

  it('selects the group option on click', async () => {
    const onChange = vi.fn();
    render(
      <>
        <Radio name="profile" label="Metric" value="metric" onChange={onChange} />
        <Radio name="profile" label="Imperial" value="imperial" onChange={onChange} />
      </>,
    );
    await userEvent.click(screen.getByRole('radio', { name: 'Imperial' }));
    expect(onChange).toHaveBeenCalledTimes(1);
  });

  it('marks the field invalid and shows the error message', () => {
    render(<Radio label="Metric" error="Choose one" />);
    expect(screen.getByRole('radio', { name: 'Metric' })).toHaveAttribute('aria-invalid', 'true');
    expect(screen.getByRole('alert')).toHaveTextContent('Choose one');
  });
});
