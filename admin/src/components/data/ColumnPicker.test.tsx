import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import { ColumnPicker, type ColumnPickerColumn } from './ColumnPicker';

const columns: ColumnPickerColumn[] = [
  { id: 'name', label: 'Name', hideable: false },
  { id: 'status', label: 'Status' },
  { id: 'make', label: 'Make' },
];

describe('ColumnPicker', () => {
  it('opens the menu and toggles a column', async () => {
    const onToggle = vi.fn();
    render(
      <ColumnPicker columns={columns} visibility={{}} onToggle={onToggle} onSelectAll={vi.fn()} />,
    );

    await userEvent.click(screen.getByRole('button'));
    expect(screen.getByRole('menu')).toBeInTheDocument();

    await userEvent.click(screen.getByRole('checkbox', { name: 'Status' }));
    expect(onToggle).toHaveBeenCalledWith('status', false);
  });

  it('disables the checkbox for non-hideable columns', async () => {
    render(
      <ColumnPicker columns={columns} visibility={{}} onToggle={vi.fn()} onSelectAll={vi.fn()} />,
    );
    await userEvent.click(screen.getByRole('button'));
    expect(screen.getByRole('checkbox', { name: 'Name' })).toBeDisabled();
  });

  it('closes on Escape', async () => {
    render(
      <ColumnPicker columns={columns} visibility={{}} onToggle={vi.fn()} onSelectAll={vi.fn()} />,
    );
    await userEvent.click(screen.getByRole('button'));
    expect(screen.getByRole('menu')).toBeInTheDocument();

    await userEvent.keyboard('{Escape}');
    expect(screen.queryByRole('menu')).not.toBeInTheDocument();
  });

  it('calls onSelectAll when the header checkbox is toggled', async () => {
    const onSelectAll = vi.fn();
    render(
      <ColumnPicker
        columns={columns}
        visibility={{}}
        onToggle={vi.fn()}
        onSelectAll={onSelectAll}
      />,
    );
    await userEvent.click(screen.getByRole('button'));
    await userEvent.click(screen.getByRole('checkbox', { name: /select all/i }));
    expect(onSelectAll).toHaveBeenCalled();
  });
});
