import { act, render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import '@/app/i18n';
import { DatePicker } from './DatePicker';

describe('DatePicker', () => {
  it('renders a button labelled by its field label, showing the formatted value', () => {
    render(<DatePicker label="Start date" value={new Date(2025, 11, 17)} onChange={() => {}} />);
    const button = screen.getByRole('button', { name: 'Start date 17/12/2025' });
    expect(button).toHaveTextContent('17/12/2025');
  });

  it('opens a calendar dialog on click and selects a day', async () => {
    const onChange = vi.fn();
    render(<DatePicker label="Start date" value={new Date(2025, 11, 17)} onChange={onChange} />);
    await userEvent.click(screen.getByRole('button', { name: 'Start date 17/12/2025' }));
    expect(screen.getByRole('dialog')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('gridcell', { name: '20' }));
    expect(onChange).toHaveBeenCalledWith(expect.any(Date));
    const selected = onChange.mock.calls[0]?.[0] as Date;
    expect(selected.getDate()).toBe(20);
  });

  it('closes the calendar with Escape', async () => {
    render(<DatePicker label="Start date" value={new Date(2025, 11, 17)} onChange={() => {}} />);
    await userEvent.click(screen.getByRole('button', { name: 'Start date 17/12/2025' }));
    expect(screen.getByRole('dialog')).toBeInTheDocument();
    act(() => {
      screen.getByRole('gridcell', { name: '17' }).focus();
    });
    await userEvent.keyboard('{Escape}');
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('closes the calendar when clicking outside', async () => {
    render(
      <div>
        <button type="button">Outside</button>
        <DatePicker label="Start date" value={new Date(2025, 11, 17)} onChange={() => {}} />
      </div>,
    );
    await userEvent.click(screen.getByRole('button', { name: 'Start date 17/12/2025' }));
    expect(screen.getByRole('dialog')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('button', { name: 'Outside' }));
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('moves focus between days with arrow keys and selects the focused day with Enter', async () => {
    const onChange = vi.fn();
    render(<DatePicker label="Start date" value={new Date(2025, 11, 17)} onChange={onChange} />);
    await userEvent.click(screen.getByRole('button', { name: 'Start date 17/12/2025' }));
    act(() => {
      screen.getByRole('gridcell', { name: '17' }).focus();
    });
    await userEvent.keyboard('{ArrowRight}');
    expect(screen.getByRole('gridcell', { name: '18' })).toHaveFocus();
    await userEvent.keyboard('{Enter}');
    expect(onChange).toHaveBeenCalledWith(expect.any(Date));
    expect((onChange.mock.calls[0]?.[0] as Date).getDate()).toBe(18);
  });

  it('navigates to the previous and next month', async () => {
    render(<DatePicker label="Start date" value={new Date(2025, 11, 17)} onChange={() => {}} />);
    await userEvent.click(screen.getByRole('button', { name: 'Start date 17/12/2025' }));
    expect(screen.getByText('December 2025')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('button', { name: 'Previous month' }));
    expect(screen.getByText('November 2025')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('button', { name: 'Next month' }));
    await userEvent.click(screen.getByRole('button', { name: 'Next month' }));
    expect(screen.getByText('January 2026')).toBeInTheDocument();
  });
});
