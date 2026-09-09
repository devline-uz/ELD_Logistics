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

  it('closes the dialog when clicking outside, discarding the draft', async () => {
    const onChange = vi.fn();
    render(
      <div>
        <button type="button">Outside</button>
        <DateRangePicker value={{ start: null, end: null }} onChange={onChange} label="Range" />
      </div>,
    );
    await userEvent.click(screen.getByRole('button', { name: /Range/ }));
    expect(screen.getByRole('dialog')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('button', { name: 'Outside' }));
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
    expect(onChange).not.toHaveBeenCalled();
  });

  it.each(['Yesterday', 'Last 7 days', 'Last 30 days', 'This month'])(
    'applies the "%s" preset',
    async (presetName) => {
      const onChange = vi.fn();
      render(
        <DateRangePicker value={{ start: null, end: null }} onChange={onChange} label="Range" />,
      );
      await userEvent.click(screen.getByRole('button', { name: /Range/ }));
      await userEvent.click(screen.getByRole('button', { name: presetName }));
      await userEvent.click(screen.getByRole('button', { name: 'Apply' }));
      expect(onChange).toHaveBeenCalledTimes(1);
      const range = onChange.mock.calls[0]?.[0] as { start: Date; end: Date };
      expect(range.start).toBeInstanceOf(Date);
      expect(range.end).toBeInstanceOf(Date);
    },
  );

  it('swaps the range when a second click lands before the first selected day', async () => {
    const onChange = vi.fn();
    render(
      <DateRangePicker value={{ start: null, end: null }} onChange={onChange} label="Range" />,
    );
    await userEvent.click(screen.getByRole('button', { name: /Range/ }));
    await userEvent.click(screen.getByRole('gridcell', { name: '20' }));
    await userEvent.click(screen.getByRole('gridcell', { name: '10' }));
    await userEvent.click(screen.getByRole('button', { name: 'Apply' }));
    const range = onChange.mock.calls[0]?.[0] as { start: Date; end: Date };
    expect(range.start.getDate()).toBe(10);
    expect(range.end.getDate()).toBe(20);
  });

  it('moves focus between days with arrow keys and selects with the Enter key', async () => {
    const onChange = vi.fn();
    render(
      <DateRangePicker value={{ start: null, end: null }} onChange={onChange} label="Range" />,
    );
    await userEvent.click(screen.getByRole('button', { name: /Range/ }));
    act(() => {
      screen.getByRole('gridcell', { name: '15' }).focus();
    });
    await userEvent.keyboard('{ArrowRight}');
    expect(screen.getByRole('gridcell', { name: '16' })).toHaveFocus();
    await userEvent.keyboard('{Enter}');
    await userEvent.keyboard('{ArrowRight}');
    expect(screen.getByRole('gridcell', { name: '17' })).toHaveFocus();
    await userEvent.keyboard('{Enter}');
    await userEvent.click(screen.getByRole('button', { name: 'Apply' }));
    const range = onChange.mock.calls[0]?.[0] as { start: Date; end: Date };
    expect(range.start.getDate()).toBe(16);
    expect(range.end.getDate()).toBe(17);
  });

  it('navigates to the previous and next month', async () => {
    render(
      <DateRangePicker value={{ start: null, end: null }} onChange={() => {}} label="Range" />,
    );
    await userEvent.click(screen.getByRole('button', { name: /Range/ }));
    const initialMonth = screen.getByText(/\d{4}/).textContent;
    await userEvent.click(screen.getByRole('button', { name: 'Previous month' }));
    await userEvent.click(screen.getByRole('button', { name: 'Next month' }));
    expect(screen.getByText(/\d{4}/).textContent).toBe(initialMonth);
  });
});
