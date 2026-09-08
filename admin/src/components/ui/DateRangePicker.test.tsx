import { act, render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import '@/app/i18n';
import { DateRangePicker } from './DateRangePicker';

describe('DateRangePicker', () => {
  it('shows a placeholder when no range is selected', () => {
    render(
      <DateRangePicker value={{ start: null, end: null }} onChange={() => {}} label="Range" />,
    );
    expect(screen.getByRole('button', { name: /Range/ })).toHaveTextContent(
      'Start date – End date',
    );
  });

  it('applies the "Today" preset and confirms with Apply', async () => {
    const onChange = vi.fn();
    render(
      <DateRangePicker value={{ start: null, end: null }} onChange={onChange} label="Range" />,
    );
    await userEvent.click(screen.getByRole('button', { name: /Range/ }));
    expect(screen.getByRole('dialog')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('button', { name: 'Today' }));
    await userEvent.click(screen.getByRole('button', { name: 'Apply' }));
    expect(onChange).toHaveBeenCalledTimes(1);
    const range = onChange.mock.calls[0]?.[0] as { start: Date; end: Date };
    expect(range.start.toDateString()).toBe(range.end.toDateString());
  });

  it('selects a custom range by clicking two days', async () => {
    const onChange = vi.fn();
    render(
      <DateRangePicker value={{ start: null, end: null }} onChange={onChange} label="Range" />,
    );
    await userEvent.click(screen.getByRole('button', { name: /Range/ }));
    await userEvent.click(screen.getByRole('gridcell', { name: '10' }));
    await userEvent.click(screen.getByRole('gridcell', { name: '20' }));
    await userEvent.click(screen.getByRole('button', { name: 'Apply' }));
    expect(onChange).toHaveBeenCalledTimes(1);
    const range = onChange.mock.calls[0]?.[0] as { start: Date; end: Date };
    expect(range.start.getDate()).toBe(10);
    expect(range.end.getDate()).toBe(20);
  });

  it('closes the dialog with Escape without calling onChange', async () => {
    const onChange = vi.fn();
    render(
      <DateRangePicker value={{ start: null, end: null }} onChange={onChange} label="Range" />,
    );
    await userEvent.click(screen.getByRole('button', { name: /Range/ }));
    expect(screen.getByRole('dialog')).toBeInTheDocument();
    act(() => {
      screen.getByRole('dialog').focus();
    });
    await userEvent.keyboard('{Escape}');
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
    expect(onChange).not.toHaveBeenCalled();
  });
});
