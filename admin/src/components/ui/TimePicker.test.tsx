import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import { TimePicker } from './TimePicker';

describe('TimePicker', () => {
  it('renders hours, minutes and seconds inputs with zero-padded values', () => {
    render(
      <TimePicker
        label="Duty time"
        value={{ hours: 8, minutes: 5, seconds: 0 }}
        onChange={() => {}}
      />,
    );
    expect(screen.getByRole('group', { name: 'Duty time' })).toBeInTheDocument();
    expect(screen.getByLabelText('Hours')).toHaveValue('08');
    expect(screen.getByLabelText('Minutes')).toHaveValue('05');
    expect(screen.getByLabelText('Seconds')).toHaveValue('00');
  });

  it('hides the seconds segment when showSeconds is false', () => {
    render(
      <TimePicker
        label="Duty time"
        value={{ hours: 8, minutes: 5, seconds: 0 }}
        onChange={() => {}}
        showSeconds={false}
      />,
    );
    expect(screen.queryByLabelText('Seconds')).not.toBeInTheDocument();
  });

  it('increments the hours value with ArrowUp', async () => {
    const onChange = vi.fn();
    render(
      <TimePicker
        label="Duty time"
        value={{ hours: 8, minutes: 5, seconds: 0 }}
        onChange={onChange}
      />,
    );
    const hours = screen.getByLabelText('Hours');
    hours.focus();
    await userEvent.keyboard('{ArrowUp}');
    expect(onChange).toHaveBeenCalledWith({ hours: 9, minutes: 5, seconds: 0 });
  });

  it('clamps typed values to the valid range', async () => {
    const onChange = vi.fn();
    render(
      <TimePicker
        label="Duty time"
        value={{ hours: 8, minutes: 5, seconds: 0 }}
        onChange={onChange}
      />,
    );
    const minutes = screen.getByLabelText('Minutes');
    await userEvent.clear(minutes);
    await userEvent.type(minutes, '99');
    const lastCall = onChange.mock.calls.at(-1)?.[0] as { minutes: number } | undefined;
    expect(lastCall?.minutes).toBeLessThanOrEqual(59);
  });
});
