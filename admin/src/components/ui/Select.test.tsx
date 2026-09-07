import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import { Select } from './Select';

const OPTIONS = [
  { value: 'metric', label: 'Metric' },
  { value: 'imperial', label: 'Imperial' },
  { value: 'generic', label: 'Generic' },
];

describe('Select', () => {
  it('renders a combobox with the selected label', () => {
    render(<Select label="Unit system" options={OPTIONS} value="metric" onChange={() => {}} />);
    expect(screen.getByRole('combobox')).toBeInTheDocument();
    expect(screen.getByDisplayValue('Metric')).toBeInTheDocument();
  });

  it('opens the listbox on click and selects an option', async () => {
    const onChange = vi.fn();
    render(<Select label="Unit system" options={OPTIONS} value={null} onChange={onChange} />);
    await userEvent.click(screen.getByRole('combobox'));
    expect(screen.getByRole('listbox')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('option', { name: 'Imperial' }));
    expect(onChange).toHaveBeenCalledWith('imperial');
  });

  it('supports full keyboard control: ArrowDown, Enter, Escape', async () => {
    const onChange = vi.fn();
    render(<Select label="Unit system" options={OPTIONS} value={null} onChange={onChange} />);
    const input = screen.getByRole('combobox');
    await userEvent.click(input);
    expect(screen.getByRole('listbox')).toBeInTheDocument();
    await userEvent.keyboard('{ArrowDown}');
    await userEvent.keyboard('{Enter}');
    expect(onChange).toHaveBeenCalledWith('imperial');

    await userEvent.keyboard('{ArrowDown}');
    expect(screen.getByRole('listbox')).toBeInTheDocument();
    await userEvent.keyboard('{Escape}');
    expect(screen.queryByRole('listbox')).not.toBeInTheDocument();
  });

  it('marks aria-expanded correctly and clears the value when clearable', async () => {
    const onChange = vi.fn();
    render(
      <Select label="Unit system" options={OPTIONS} value="metric" onChange={onChange} clearable />,
    );
    const combobox = screen.getByRole('combobox');
    expect(combobox).toHaveAttribute('aria-expanded', 'false');
    await userEvent.click(screen.getByRole('button', { name: 'Clear' }));
    expect(onChange).toHaveBeenCalledWith(null);
  });
});
